import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';

class NewTaskScreen extends StatefulWidget {
  final String coupleId;
  final String currentUserId;
  final String? partnerId;

  const NewTaskScreen({
    super.key,
    required this.coupleId,
    required this.currentUserId,
    this.partnerId,
  });

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  DateTime? _selectedDate;
  String _assignedTo = 'both'; // 'me', 'partner', 'both'
  bool _isLoading = false;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryPink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _createTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? assignedToUserId;
      if (_assignedTo == 'me') {
        assignedToUserId = widget.currentUserId;
      } else if (_assignedTo == 'partner') {
        assignedToUserId = widget.partnerId;
      }

      await _firestoreService.createTask(
        coupleId: widget.coupleId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        createdByUserId: widget.currentUserId,
        assignedToUserId: assignedToUserId,
        dueDate: _selectedDate,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created successfully! 🎉')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating task: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
        title: const Text('New Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              "WHAT'S THE TASK?",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'e.g., Book dinner reservation',
                border: InputBorder.none,
                filled: false,
              ),
              style: Theme.of(context).textTheme.titleLarge,
              maxLines: 2,
            ),

            const Divider(height: 32),

            // Description
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Add a sweet note',
                border: InputBorder.none,
                filled: false,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mediumGray,
                    ),
              ),
              maxLines: 3,
            ),

            const Divider(height: 32),

            // Assign to
            Text(
              'ASSIGN TO',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildAssignmentChip('Me', 'me', Icons.person),
                const SizedBox(width: 12),
                _buildAssignmentChip('Partner', 'partner', Icons.favorite),
                const SizedBox(width: 12),
                _buildAssignmentChip('Both', 'both', Icons.people),
              ],
            ),

            const SizedBox(height: 32),

            // Due date
            Text(
              'WHEN IS IT DUE?',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate != null
                          ? DateFormat('EEEE, MMMM d, y').format(_selectedDate!)
                          : 'Select a date',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Create button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createTask,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Create Task →'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentChip(String label, String value, IconData icon) {
    final isSelected = _assignedTo == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _assignedTo = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryPink : AppTheme.lightGray,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryPink : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.darkText,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
