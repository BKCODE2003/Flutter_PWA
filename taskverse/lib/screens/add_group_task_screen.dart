import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/group_task_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddGroupTaskScreen extends StatefulWidget {
  final String groupId;
  final Function(GroupTask) onTaskAdded;

  const AddGroupTaskScreen({super.key, required this.groupId, required this.onTaskAdded});

  @override
  _AddGroupTaskScreenState createState() => _AddGroupTaskScreenState();
}

class _AddGroupTaskScreenState extends State<AddGroupTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  Duration _targetedTime = const Duration(hours: 0, minutes: 30);
  bool _isImportant = false;
  final List<DateTime> _customReminders = [];
  bool _useDefaultAlarms = true;

  void _selectDueDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  void _selectDueTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _dueTime = pickedTime;
      });
    }
  }

  void _selectTargetedTime() async {
    int selectedHours = _targetedTime.inHours;
    int selectedMinutes = _targetedTime.inMinutes.remainder(60);

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Targeted Time",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    child: DropdownButton<int>(
                      value: selectedHours,
                      items: List.generate(13, (index) => index)
                          .map((e) => DropdownMenuItem(value: e, child: Text("$e h")))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedHours = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 80,
                    child: DropdownButton<int>(
                      value: selectedMinutes,
                      items: [0, 15, 30, 45]
                          .map((e) => DropdownMenuItem(value: e, child: Text("$e min")))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMinutes = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _targetedTime = Duration(hours: selectedHours, minutes: selectedMinutes);
                  });
                  Navigator.pop(context);
                },
                child: const Text("Set Time"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addCustomReminder() async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        DateTime reminderTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _customReminders.add(reminderTime);
        });
      }
    }
  }

  void _saveTask() {
    if (_titleController.text.isEmpty || _dueDate == null || _dueTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      Fluttertoast.showToast(msg: 'User not logged in');
      return;
    }

    DateTime fullDueDateTime = DateTime(
      _dueDate!.year,
      _dueDate!.month,
      _dueDate!.day,
      _dueTime!.hour,
      _dueTime!.minute,
    );

    List<DateTime> selectedReminders =
        _useDefaultAlarms ? GroupTask.defaultReminders(fullDueDateTime, _targetedTime) : [];

    final task = GroupTask(
      id: const Uuid().v4(),
      title: _titleController.text,
      description: _descriptionController.text,
      dueDateTime: fullDueDateTime,
      targetedTime: _targetedTime,
      isImportant: _isImportant,
      reminders: selectedReminders,
      customReminders: _customReminders,
      createdAt: DateTime.now(),
      createdByUid: userId,
      isCompleted: false,
    );

    widget.onTaskAdded(task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Group Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Due Date'),
              subtitle: Text(_dueDate != null
                  ? "${_dueDate!.toLocal()}".split(' ')[0]
                  : 'Select a date'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDueDate,
            ),
            ListTile(
              title: const Text('Due Time'),
              subtitle: Text(_dueTime != null ? _dueTime!.format(context) : 'Select a time'),
              trailing: const Icon(Icons.access_time),
              onTap: _selectDueTime,
            ),
            ListTile(
              title: const Text('Targeted Time'),
              subtitle:
                  Text("${_targetedTime.inHours} hrs ${_targetedTime.inMinutes.remainder(60)} min"),
              trailing: const Icon(Icons.timer),
              onTap: _selectTargetedTime,
            ),
            SwitchListTile(
              title: const Text('Use Default Reminders (1 hr & 1 day before)'),
              value: _useDefaultAlarms,
              onChanged: (value) {
                setState(() {
                  _useDefaultAlarms = value;
                });
              },
            ),
            ListTile(
              title: const Text('Add Custom Reminder'),
              trailing: const Icon(Icons.alarm_add),
              onTap: _addCustomReminder,
            ),
            ..._customReminders.map((reminder) => ListTile(
                  title: Text("Reminder: ${reminder.toLocal()}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _customReminders.remove(reminder);
                      });
                    },
                  ),
                )),
            SwitchListTile(
              title: const Text('Mark as Important'),
              value: _isImportant,
              onChanged: (value) {
                setState(() {
                  _isImportant = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTask,
              child: const Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }
}