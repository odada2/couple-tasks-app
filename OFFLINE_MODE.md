## Offline Mode Implementation

### Overview

The Couple Tasks app now includes **full offline support** with SQLite local database persistence and automatic synchronization with Firestore. Users can create, update, and delete tasks without an internet connection, and all changes will automatically sync when connectivity is restored.

---

## Architecture

### Offline-First Approach

The app follows an **offline-first architecture**:

1. **All operations happen locally first** (SQLite)
2. **Sync to cloud in background** (Firestore)
3. **Real-time listeners** update local database
4. **Sync queue** handles failed operations

```
User Action
    ↓
Local SQLite Database (immediate)
    ↓
Sync Queue (if offline or error)
    ↓
Firestore (when online)
    ↓
Real-time Listener
    ↓
Update Local Database
```

---

## Components

### 1. Database Helper (`database_helper.dart`)

**Purpose**: Manages SQLite database creation, schema, and migrations

**Tables**:
- `users` - User profiles with couple information
- `couples` - Couple relationships
- `tasks` - Task data with sync status
- `nudges` - Nudge messages
- `invites` - Partner invitations
- `sync_queue` - Pending sync operations

**Key Features**:
- Automatic schema creation
- Migration system for future versions
- Indexes for query performance
- Statistics and diagnostics

**Usage**:
```dart
final db = await DatabaseHelper.instance.database;
final stats = await DatabaseHelper.instance.getStats();
```

### 2. Local Database Service (`local_database_service.dart`)

**Purpose**: Provides CRUD operations for local SQLite database

**Operations**:
- `createTaskLocal()` - Create task in SQLite
- `getTasksLocal()` - Get all tasks for couple
- `getTaskByIdLocal()` - Get single task
- `updateTaskLocal()` - Update task
- `deleteTaskLocal()` - Mark task for deletion
- `getUnsyncedTasks()` - Get tasks pending sync
- `markTaskSynced()` - Mark task as synced

**Sync Status**:
- `synced` - In sync with Firestore
- `pending` - Waiting to be uploaded
- `pending_delete` - Marked for deletion

**Usage**:
```dart
final localDb = LocalDatabaseService();

// Create task locally
await localDb.createTaskLocal(task, syncStatus: 'pending');

// Get all tasks
final tasks = await localDb.getTasksLocal(coupleId);

// Update task
await localDb.updateTaskLocal(task, syncStatus: 'pending');
```

### 3. Connectivity Service (`connectivity_service.dart`)

**Purpose**: Monitors online/offline status in real-time

**Features**:
- Real-time connectivity monitoring
- Stream of connectivity changes
- Manual connectivity check
- Automatic status updates

**Usage**:
```dart
final connectivity = ConnectivityService.instance;

// Initialize
await connectivity.initialize();

// Check current status
if (connectivity.isOnline) {
  // Online
}

// Listen to changes
connectivity.connectivityStream.listen((isOnline) {
  if (isOnline) {
    print('Connection restored');
  } else {
    print('Connection lost');
  }
});
```

### 4. Sync Service (`sync_service.dart`)

**Purpose**: Handles bidirectional sync between SQLite and Firestore

**Features**:
- Automatic sync on connectivity restore
- Upload local changes to Firestore
- Download remote changes to SQLite
- Real-time listeners for Firestore changes
- Sync queue processing with retry logic

**Operations**:
- `syncAll()` - Full sync (upload + download)
- `downloadTasks()` - Download tasks from Firestore
- `downloadUser()` - Download user data
- `downloadCouple()` - Download couple data
- `setupTasksListener()` - Real-time Firestore listener
- `getSyncStatus()` - Get sync statistics

**Usage**:
```dart
final syncService = SyncService();

// Initialize
syncService.initialize();

// Manual sync
await syncService.syncAll();

// Setup real-time listener
final subscription = syncService.setupTasksListener(coupleId);

// Get sync status
final status = await syncService.getSyncStatus();
// {isOnline: true, isSyncing: false, unsyncedCount: 0, syncQueueCount: 0}
```

### 5. Offline Task Service (`offline_task_service.dart`)

**Purpose**: Unified interface for task operations with automatic offline/online handling

**Features**:
- Always saves locally first (instant response)
- Automatically syncs to Firestore when online
- Queues operations when offline
- Background sync without blocking UI

**Operations**:
- `createTask()` - Create task (offline-first)
- `getTasks()` - Get all tasks (from local DB)
- `getTaskById()` - Get single task
- `updateTask()` - Update task (offline-first)
- `deleteTask()` - Delete task (offline-first)
- `completeTask()` - Mark task complete
- `getUnsyncedCount()` - Get pending sync count

**Usage**:
```dart
final taskService = OfflineTaskService();

// Create task (works offline!)
await taskService.createTask(task);
// ✅ Task created locally
// ✅ Task synced to Firestore (if online)
// OR
// 📴 Offline: Task queued for sync

// Get tasks (always from local DB)
final tasks = await taskService.getTasks(coupleId);

// Update task
await taskService.updateTask(task);

// Complete task
await taskService.completeTask(taskId, userId, userName);

// Check unsynced count
final count = await taskService.getUnsyncedCount();
```

---

## Data Flow

### Creating a Task (Offline)

```
User creates task
    ↓
OfflineTaskService.createTask()
    ↓
LocalDatabaseService.createTaskLocal()
    ↓
SQLite INSERT with syncStatus='pending'
    ↓
LocalDatabaseService.addToSyncQueue()
    ↓
User sees task immediately ✅
    ↓
(When connection restored)
    ↓
SyncService detects connectivity
    ↓
Process sync queue
    ↓
Upload to Firestore
    ↓
Mark as synced in SQLite
```

### Creating a Task (Online)

```
User creates task
    ↓
OfflineTaskService.createTask()
    ↓
LocalDatabaseService.createTaskLocal()
    ↓
SQLite INSERT with syncStatus='pending'
    ↓
User sees task immediately ✅
    ↓
(Parallel)
    ↓
FirestoreService.createTask()
    ↓
Firestore CREATE
    ↓
LocalDatabaseService.markTaskSynced()
    ↓
SQLite UPDATE syncStatus='synced'
```

### Real-Time Sync (Partner Updates)

```
Partner creates task (on their device)
    ↓
Firestore CREATE
    ↓
Real-time listener fires
    ↓
SyncService.setupTasksListener()
    ↓
LocalDatabaseService.createTaskLocal()
    ↓
SQLite INSERT with syncStatus='synced'
    ↓
UI updates automatically ✅
```

---

## Database Schema

### Tasks Table

```sql
CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  dueDate INTEGER,
  priority TEXT DEFAULT 'medium',
  assignedTo TEXT,
  assignedToName TEXT,
  createdBy TEXT NOT NULL,
  createdByName TEXT NOT NULL,
  coupleId TEXT NOT NULL,
  isCompleted INTEGER DEFAULT 0,
  completedAt INTEGER,
  completedBy TEXT,
  nudgeCount INTEGER DEFAULT 0,
  lastNudgeAt INTEGER,
  createdAt INTEGER NOT NULL,
  updatedAt INTEGER NOT NULL,
  syncStatus TEXT DEFAULT 'synced',
  FOREIGN KEY (coupleId) REFERENCES couples (id)
)
```

**Indexes**:
- `idx_tasks_coupleId` - Fast couple queries
- `idx_tasks_assignedTo` - Fast user queries
- `idx_tasks_createdBy` - Fast creator queries
- `idx_tasks_syncStatus` - Fast sync queries

### Sync Queue Table

```sql
CREATE TABLE sync_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  operation TEXT NOT NULL,        -- 'create', 'update', 'delete'
  collection TEXT NOT NULL,       -- 'tasks', 'nudges', etc.
  documentId TEXT NOT NULL,       -- Document ID
  data TEXT NOT NULL,             -- JSON data
  createdAt INTEGER NOT NULL,
  retryCount INTEGER DEFAULT 0,
  lastError TEXT
)
```

---

## Integration Steps

### 1. Initialize Services in `main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize connectivity service
  await ConnectivityService.instance.initialize();
  
  // Initialize sync service
  final syncService = SyncService();
  syncService.initialize();
  
  runApp(MyApp());
}
```

### 2. Use Offline Task Service in UI

```dart
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final OfflineTaskService _taskService = OfflineTaskService();
  List<TaskModel> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    final tasks = await _taskService.getTasks(coupleId);
    
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _createTask(TaskModel task) async {
    await _taskService.createTask(task);
    await _loadTasks(); // Refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? CircularProgressIndicator()
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return TaskTile(task: _tasks[index]);
              },
            ),
    );
  }
}
```

### 3. Show Offline Indicator

```dart
class OfflineIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final connectivity = ConnectivityService.instance;
    
    return StreamBuilder<bool>(
      stream: connectivity.connectivityStream,
      initialData: connectivity.isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;
        
        if (isOnline) {
          return SizedBox.shrink();
        }
        
        return Container(
          padding: EdgeInsets.all(8),
          color: Colors.orange,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(
                'Offline Mode',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### 4. Show Sync Status

```dart
class SyncStatusIndicator extends StatelessWidget {
  final SyncService syncService;
  
  const SyncStatusIndicator({required this.syncService});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: syncService.getSyncStatus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();
        
        final status = snapshot.data!;
        final unsyncedCount = status['unsyncedCount'] as int;
        
        if (unsyncedCount == 0) {
          return SizedBox.shrink();
        }
        
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Syncing $unsyncedCount items...',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

---

## Benefits

### User Experience

✅ **Instant Response** - All operations complete immediately  
✅ **Works Offline** - Full functionality without internet  
✅ **Automatic Sync** - Changes sync when connection restored  
✅ **Real-Time Updates** - See partner's changes instantly  
✅ **No Data Loss** - All changes persisted locally  

### Technical

✅ **Offline-First** - Local database is source of truth  
✅ **Sync Queue** - Failed operations automatically retry  
✅ **Conflict Resolution** - Last-write-wins strategy  
✅ **Performance** - Fast local queries with indexes  
✅ **Scalability** - Efficient sync with minimal data transfer  

---

## Testing

### Test Offline Mode

1. **Create task while offline**:
   - Turn off WiFi/mobile data
   - Create a new task
   - Task should appear immediately
   - Check sync queue: should have 1 item

2. **Restore connection**:
   - Turn on WiFi/mobile data
   - Sync should trigger automatically
   - Task should appear in Firestore
   - Sync queue should be empty

3. **Update task while offline**:
   - Turn off connection
   - Update task title
   - Changes should save locally
   - Turn on connection
   - Changes should sync to Firestore

4. **Real-time sync**:
   - Two devices with same couple
   - Create task on Device A
   - Task should appear on Device B
   - Both devices should show same data

### Test Sync Queue

```dart
// Check sync queue
final syncQueue = await localDb.getSyncQueue();
print('Sync queue: ${syncQueue.length} items');

// Check unsynced count
final unsyncedCount = await localDb.getUnsyncedCount();
print('Unsynced items: $unsyncedCount');

// Get database stats
final stats = await DatabaseHelper.instance.getStats();
print('Database stats: $stats');
```

---

## Troubleshooting

### Sync Not Working

**Check connectivity**:
```dart
final isOnline = await ConnectivityService.instance.checkConnection();
print('Online: $isOnline');
```

**Check sync status**:
```dart
final status = await syncService.getSyncStatus();
print('Sync status: $status');
```

**Check sync queue**:
```dart
final queue = await localDb.getSyncQueue();
print('Sync queue: ${queue.length} items');
```

### Clear Local Data

**For testing/debugging**:
```dart
await DatabaseHelper.instance.clearAllData();
print('All local data cleared');
```

### Reset Sync Queue

**If sync is stuck**:
```dart
await localDb.clearSyncQueue();
print('Sync queue cleared');
```

---

## Future Enhancements

### Phase 2

1. **Conflict Resolution**
   - Detect conflicts when both users edit same task
   - Show conflict resolution UI
   - Allow user to choose version

2. **Optimistic UI Updates**
   - Show pending operations with visual indicator
   - Rollback on error

3. **Selective Sync**
   - Only sync recent tasks
   - Archive old tasks locally

4. **Compression**
   - Compress sync queue data
   - Reduce storage usage

### Phase 3

1. **Background Sync**
   - Sync in background using WorkManager
   - Periodic sync even when app closed

2. **Delta Sync**
   - Only sync changed fields
   - Reduce bandwidth usage

3. **Offline Analytics**
   - Track offline usage patterns
   - Measure sync performance

---

## Dependencies

**Added to `pubspec.yaml`**:
```yaml
dependencies:
  # Local Database (SQLite)
  sqflite: ^2.3.3+1
  path: ^1.9.0
  
  # Connectivity
  connectivity_plus: ^6.0.5
```

---

## Files Created

1. **`lib/services/database_helper.dart`** - SQLite database management
2. **`lib/services/local_database_service.dart`** - Local CRUD operations
3. **`lib/services/connectivity_service.dart`** - Connectivity monitoring
4. **`lib/services/sync_service.dart`** - Firestore-SQLite sync
5. **`lib/services/offline_task_service.dart`** - Offline-first task service
6. **`OFFLINE_MODE.md`** - This documentation

---

## Summary

The Couple Tasks app now has **full offline support** with:

✅ **SQLite local database** for data persistence  
✅ **Offline-first architecture** for instant response  
✅ **Automatic synchronization** with Firestore  
✅ **Real-time updates** from partner  
✅ **Sync queue** for failed operations  
✅ **Connectivity monitoring** for status updates  

Users can now use the app **anywhere, anytime**, even without an internet connection! 🚀
