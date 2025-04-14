import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final VoidCallback onTaskUpdated;

  const TaskDetailScreen({super.key, required this.task, required this.onTaskUpdated});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  Duration _targetedTime = const Duration(hours: 0, minutes: 30);
  bool _isImportant = false;
  final FirestoreService _firestoreService = FirestoreService(); // Add Firestore service


  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _dueDate = widget.task.dueDateTime;
    _dueTime = TimeOfDay.fromDateTime(widget.task.dueDateTime);
    _targetedTime = widget.task.targetedTime;
    _isImportant = widget.task.isImportant;
  }

  void _updateTask() {
    setState(() {
      widget.task.title = _titleController.text;
      widget.task.description = _descriptionController.text;
      widget.task.dueDateTime = DateTime(
        _dueDate!.year, _dueDate!.month, _dueDate!.day, _dueTime!.hour, _dueTime!.minute
      );
      widget.task.targetedTime = _targetedTime;
      widget.task.isImportant = _isImportant;
    });

    _firestoreService.updateTask(widget.task); // Update in Firestore
    widget.onTaskUpdated(); // 🔥 **Update UI in all screens**
    Navigator.pop(context);
  }


  Future<void> _selectDueDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context, initialDate: _dueDate!, firstDate: DateTime.now(), lastDate: DateTime(2101)
    );
    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  Future<void> _selectDueTime() async {
    TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: _dueTime!);
    if (pickedTime != null) {
      setState(() {
        _dueTime = pickedTime;
      });
    }
  }

  void _toggleImportant() {
    setState(() {
      _isImportant = !_isImportant;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 10),
            TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 10),
            
            ListTile(
              title: const Text('Due Date'),
              subtitle: Text(DateFormat('EEE, MMM d').format(_dueDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDueDate,
            ),
            ListTile(
              title: const Text('Due Time'),
              subtitle: Text(_dueTime!.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: _selectDueTime,
            ),

            ListTile(
              title: const Text('Mark as Important'),
              trailing: IconButton(
                icon: Icon(_isImportant ? Icons.star : Icons.star_border, color: _isImportant ? Colors.yellow : null),
                onPressed: _toggleImportant,
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateTask,
              child: const Text('Update Task'),
            ),
          ],
        ),
      ),
    );
  }
}
