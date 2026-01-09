import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';
import '../utils/app_theme.dart';
import 'new_task_screen.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  UserModel? _currentUser;
  UserModel? _partner;
  String? _coupleId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _authService.getCurrentUserData();
    if (userData != null && mounted) {
      setState(() {
        _currentUser = userData;
        _coupleId = userData.coupleId;
      });

      if (_coupleId != null) {
        final partner =
            await _firestoreService.getPartner(_coupleId!, userData.id);
        if (mounted) {
          setState(() {
            _partner = partner;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_coupleId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: _currentUser?.photoUrl != null
                  ? NetworkImage(_currentUser!.photoUrl!)
                  : null,
              child: _currentUser?.photoUrl == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Shared Tasks',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (_partner != null)
                    Text(
                      'with ${_partner!.displayName}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search functionality
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _authService.signOut();
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: _firestoreService.getTasks(_coupleId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tasks = snapshot.data ?? [];
          final pendingTasks =
              tasks.where((t) => t.status == 'pending').toList();
          final completedTasks = tasks.where((t) => t.status == 'done').toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress card
                _buildProgressCard(pendingTasks.length, completedTasks.length),

                const SizedBox(height: 24),

                // Today's Focus section
                if (pendingTasks.isNotEmpty) ...[
                  Text(
                    "Today's Focus",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  ...pendingTasks.take(3).map((task) => _buildTaskCard(task)),
                ],

                const SizedBox(height: 24),

                // All tasks section
                Text(
                  'All Tasks',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),

                if (tasks.isEmpty)
                  _buildEmptyState()
                else
                  ...tasks.map((task) => _buildTaskCard(task)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewTaskScreen(
                coupleId: _coupleId!,
                currentUserId: _currentUser!.id,
                partnerId: _partner?.id,
              ),
            ),
          );
        },
        backgroundColor: AppTheme.primaryPink,
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }

  Widget _buildProgressCard(int pending, int completed) {
    final total = pending + completed;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryPink, Color(0xFFFF6B9D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🎯 Team Spirit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$completed/$total Completed',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'You & Alex are killing it today!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    final isOverdue =
        task.dueDate != null && task.dueDate!.isBefore(DateTime.now());
    final isDueSoon = task.dueDate != null &&
        task.dueDate!.difference(DateTime.now()).inHours < 24;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(
                task: task,
                currentUserId: _currentUser!.id,
                partnerId: _partner?.id ?? '',
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status checkbox
              GestureDetector(
                onTap: () {
                  if (task.status == 'pending') {
                    _firestoreService.completeTask(task.id);
                  }
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.status == 'done'
                          ? AppTheme.primaryPink
                          : AppTheme.mediumGray,
                      width: 2,
                    ),
                    color: task.status == 'done'
                        ? AppTheme.primaryPink
                        : Colors.transparent,
                  ),
                  child: task.status == 'done'
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 16),

              // Task info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            decoration: task.status == 'done'
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                    ),
                    if (task.dueDate != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: isOverdue
                                ? Colors.red
                                : isDueSoon
                                    ? Colors.orange
                                    : AppTheme.mediumGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d').format(task.dueDate!),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isOverdue
                                          ? Colors.red
                                          : isDueSoon
                                              ? Colors.orange
                                              : AppTheme.mediumGray,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Nudge indicator
              if (task.nudgesCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.lightPink,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '💛 ${task.nudgesCount}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const Text(
              '📝',
              style: TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks yet',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first task together',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mediumGray,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
