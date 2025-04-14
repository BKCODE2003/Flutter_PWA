import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/group_task_model.dart';
import '../services/group_firestore_service.dart';

class GroupTaskTile extends StatefulWidget {
  final GroupTask task;
  final String groupId;
  final VoidCallback onTaskDeleted;
  final VoidCallback onTaskCompleted;
  final VoidCallback onTaskIncompleted;

  const GroupTaskTile({
    super.key,
    required this.task,
    required this.groupId,
    required this.onTaskDeleted,
    required this.onTaskCompleted,
    required this.onTaskIncompleted,
  });

  @override
  _GroupTaskTileState createState() => _GroupTaskTileState();
}

class _GroupTaskTileState extends State<GroupTaskTile> {
  final GroupFirestoreService _groupService = GroupFirestoreService();

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.task.id),
      background: widget.task.isCompleted
          ? Container()
          : Container(
              color: Colors.green,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.check, color: Colors.white, size: 30),
            ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          widget.onTaskDeleted();
          return true;
        } else if (direction == DismissDirection.startToEnd && !widget.task.isCompleted) {
          setState(() {
            widget.task.isCompleted = true;
          });
          widget.onTaskCompleted();
          return false;
        }
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: GestureDetector(
              onTap: () {
                setState(() {
                  widget.task.isCompleted = !widget.task.isCompleted;
                  widget.task.isCompleted
                      ? widget.onTaskCompleted()
                      : widget.onTaskIncompleted();
                });
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 2),
                  color: widget.task.isCompleted ? Colors.green : Colors.transparent,
                ),
                child: widget.task.isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            ),
            title: Text(
              widget.task.title,
              style: TextStyle(
                fontSize: 16,
                decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.blueGrey),
                const SizedBox(width: 5),
                Text(
                  "${DateFormat('EEE, MMM d').format(widget.task.dueDateTime)} at ${DateFormat('hh:mm a').format(widget.task.dueDateTime)}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                widget.task.isImportant ? Icons.star : Icons.star_border,
                color: widget.task.isImportant ? Colors.yellow : null,
              ),
              onPressed: () {
                setState(() {
                  widget.task.isImportant = !widget.task.isImportant;
                  _groupService.updateGroupTask(widget.groupId, widget.task);
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}