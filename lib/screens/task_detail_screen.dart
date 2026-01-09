import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;
  final String currentUserId;
  final String partnerId;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.currentUserId,
    required this.partnerId,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _showNudgeOptions = false;

  final List<Map<String, String>> _nudgeMessages = [
    {'emoji': '💛', 'message': 'You got this!'},
    {'emoji': '🌸', 'message': 'Thanks, love!'},
    {'emoji': '👊', 'message': 'Great teamwork!'},
    {'emoji': '✨', 'message': 'Proud of you!'},
    {'emoji': '🎉', 'message': 'Amazing!'},
    {'emoji': '💪', 'message': "You're crushing it!"},
  ];

  Future<void> _sendNudge(String emoji, String message) async {
    try {
      await _firestoreService.sendNudge(
        taskId: widget.task.id,
        coupleId: widget.task.coupleId,
        fromUserId: widget.currentUserId,
        toUserId: widget.partnerId,
        emoji: emoji,
        customMessage: message,
      );

      if (mounted) {
        setState(() {
          _showNudgeOptions = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nudge sent! $emoji'),
            backgroundColor: AppTheme.primaryPink,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending nudge: $e')),
        );
      }
    }
  }

  Future<void> _toggleTaskStatus() async {
    try {
      if (widget.task.status == 'pending') {
        await _firestoreService.completeTask(widget.task.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task completed! 🎉'),
              backgroundColor: AppTheme.primaryPink,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        await _firestoreService.updateTask(widget.task.id, {
          'status': 'pending',
          'completedAt': null,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating task: $e')),
        );
      }
    }
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestoreService.deleteTask(widget.task.id);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting task: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _deleteTask();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _toggleTaskStatus,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.task.status == 'done'
                            ? AppTheme.primaryPink
                            : AppTheme.mediumGray,
                        width: 2,
                      ),
                      color: widget.task.status == 'done'
                          ? AppTheme.primaryPink
                          : Colors.transparent,
                    ),
                    child: widget.task.status == 'done'
                        ? const Icon(
                            Icons.check,
                            size: 20,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.task.title,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          decoration: widget.task.status == 'done'
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Description
            if (widget.task.description != null &&
                widget.task.description!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightPink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.task.description!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Task details
            _buildDetailRow(
              Icons.calendar_today,
              'Due Date',
              widget.task.dueDate != null
                  ? DateFormat('EEEE, MMMM d, y').format(widget.task.dueDate!)
                  : 'No due date',
            ),

            const SizedBox(height: 16),

            _buildDetailRow(
              Icons.person,
              'Assigned To',
              widget.task.assignedToUserId != null
                  ? (widget.task.assignedToUserId == widget.currentUserId
                      ? 'You'
                      : 'Partner')
                  : 'Both',
            ),

            const SizedBox(height: 32),

            // Nudge section
            if (widget.task.status == 'pending') ...[
              const Divider(),
              const SizedBox(height: 24),
              Text(
                'Send a Loving Nudge',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Light up their day with a quick boost',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mediumGray,
                    ),
              ),
              const SizedBox(height: 16),

              // Nudge button
              if (!_showNudgeOptions)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showNudgeOptions = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightPink,
                      foregroundColor: AppTheme.primaryPink,
                    ),
                    icon: const Text('💌', style: TextStyle(fontSize: 20)),
                    label: const Text('Send Nudge'),
                  ),
                ),

              // Nudge options
              if (_showNudgeOptions) ...[
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _nudgeMessages.map((nudge) {
                    return InkWell(
                      onTap: () =>
                          _sendNudge(nudge['emoji']!, nudge['message']!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightPink,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppTheme.primaryPink.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              nudge['emoji']!,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              nudge['message']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showNudgeOptions = false;
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ],

            // Completed message
            if (widget.task.status == 'done') ...[
              const Divider(),
              const SizedBox(height: 24),
              Container(
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
                  children: [
                    const Text(
                      '🎉',
                      style: TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Task Completed!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Completed on ${DateFormat('MMM d, y').format(widget.task.completedAt!)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.mediumGray),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGray,
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
