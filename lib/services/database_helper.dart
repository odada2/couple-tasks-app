import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite database helper for offline data persistence
/// 
/// Manages local database creation, migrations, and schema
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Get database instance (singleton)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('couple_tasks.db');
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Create database tables
  Future<void> _createDB(Database db, int version) async {
    print('📦 Creating database tables...');

    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        displayName TEXT,
        photoURL TEXT,
        coupleId TEXT,
        partnerId TEXT,
        partnerName TEXT,
        partnerEmail TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        syncStatus TEXT DEFAULT 'synced'
      )
    ''');

    // Couples table
    await db.execute('''
      CREATE TABLE couples (
        id TEXT PRIMARY KEY,
        user1Id TEXT NOT NULL,
        user1Name TEXT NOT NULL,
        user1Email TEXT NOT NULL,
        user2Id TEXT NOT NULL,
        user2Name TEXT NOT NULL,
        user2Email TEXT NOT NULL,
        tasksCompleted INTEGER DEFAULT 0,
        nudgesSent INTEGER DEFAULT 0,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        syncStatus TEXT DEFAULT 'synced'
      )
    ''');

    // Tasks table
    await db.execute('''
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
    ''');

    // Nudges table
    await db.execute('''
      CREATE TABLE nudges (
        id TEXT PRIMARY KEY,
        taskId TEXT NOT NULL,
        fromUserId TEXT NOT NULL,
        fromUserName TEXT NOT NULL,
        toUserId TEXT NOT NULL,
        toUserName TEXT NOT NULL,
        message TEXT NOT NULL,
        emoji TEXT,
        createdAt INTEGER NOT NULL,
        syncStatus TEXT DEFAULT 'synced',
        FOREIGN KEY (taskId) REFERENCES tasks (id)
      )
    ''');

    // Invites table
    await db.execute('''
      CREATE TABLE invites (
        id TEXT PRIMARY KEY,
        inviteCode TEXT NOT NULL UNIQUE,
        createdBy TEXT NOT NULL,
        createdByName TEXT NOT NULL,
        createdByEmail TEXT NOT NULL,
        expiresAt INTEGER NOT NULL,
        isUsed INTEGER DEFAULT 0,
        usedBy TEXT,
        usedAt INTEGER,
        coupleId TEXT,
        createdAt INTEGER NOT NULL,
        syncStatus TEXT DEFAULT 'synced'
      )
    ''');

    // Sync queue table (for offline operations)
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        collection TEXT NOT NULL,
        documentId TEXT NOT NULL,
        data TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        retryCount INTEGER DEFAULT 0,
        lastError TEXT
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_tasks_coupleId ON tasks(coupleId)');
    await db.execute('CREATE INDEX idx_tasks_assignedTo ON tasks(assignedTo)');
    await db.execute('CREATE INDEX idx_tasks_createdBy ON tasks(createdBy)');
    await db.execute('CREATE INDEX idx_tasks_syncStatus ON tasks(syncStatus)');
    await db.execute('CREATE INDEX idx_nudges_taskId ON nudges(taskId)');
    await db.execute('CREATE INDEX idx_nudges_toUserId ON nudges(toUserId)');
    await db.execute('CREATE INDEX idx_sync_queue_operation ON sync_queue(operation)');

    print('✅ Database tables created successfully');
  }

  /// Upgrade database schema (for future versions)
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    print('📦 Upgrading database from v$oldVersion to v$newVersion...');

    // Example migration for future versions:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE tasks ADD COLUMN newField TEXT');
    // }
  }

  /// Close database
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
    print('🔒 Database closed');
  }

  /// Clear all data (for testing/logout)
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('users');
    await db.delete('couples');
    await db.delete('tasks');
    await db.delete('nudges');
    await db.delete('invites');
    await db.delete('sync_queue');
    print('🗑️  All local data cleared');
  }

  /// Get database statistics
  Future<Map<String, int>> getStats() async {
    final db = await instance.database;
    
    final usersCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users')
    ) ?? 0;
    
    final couplesCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM couples')
    ) ?? 0;
    
    final tasksCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM tasks')
    ) ?? 0;
    
    final nudgesCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM nudges')
    ) ?? 0;
    
    final invitesCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM invites')
    ) ?? 0;
    
    final syncQueueCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM sync_queue')
    ) ?? 0;

    return {
      'users': usersCount,
      'couples': couplesCount,
      'tasks': tasksCount,
      'nudges': nudgesCount,
      'invites': invitesCount,
      'syncQueue': syncQueueCount,
    };
  }

  /// Get unsynced items count
  Future<int> getUnsyncedCount() async {
    final db = await instance.database;
    
    final tasksCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM tasks WHERE syncStatus != ?', ['synced'])
    ) ?? 0;
    
    final nudgesCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM nudges WHERE syncStatus != ?', ['synced'])
    ) ?? 0;
    
    final syncQueueCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM sync_queue')
    ) ?? 0;

    return tasksCount + nudgesCount + syncQueueCount;
  }
}
