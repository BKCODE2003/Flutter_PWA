
// import 'package:flutter/material.dart';
// import '../models/task_model.dart';
// import 'package:intl/intl.dart';

// class TaskTile extends StatefulWidget {
//   final Task task;
//   final Function() onTaskDeleted;
//   final Function() onTaskCompleted;
  

//   const TaskTile({
//     Key? key,
//     required this.task,
//     required this.onTaskDeleted,
//     required this.onTaskCompleted,
//   }) : super(key: key);

//   @override
//   _TaskTileState createState() => _TaskTileState();
// }

// class _TaskTileState extends State<TaskTile> {
//   @override
//   Widget build(BuildContext context) {
//     return Dismissible(
//       key: Key(widget.task.title), // Unique identifier
//       background: Container(
//         color: Colors.green,
//         alignment: Alignment.centerLeft,
//         padding: const EdgeInsets.only(left: 20),
//         child: const Icon(Icons.check, color: Colors.white, size: 30),
//       ),
//       secondaryBackground: Container(
//         color: Colors.red,
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.only(right: 20),
//         child: const Icon(Icons.delete, color: Colors.white, size: 30),
//       ),
//       confirmDismiss: (direction) async {
//         if (direction == DismissDirection.endToStart) {
//           // Delete task
//           widget.onTaskDeleted();
//           return true;
//         } else if (direction == DismissDirection.startToEnd) {
//           // Mark as complete
//           widget.onTaskCompleted();
//           return true;
//         }
//         return false;
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
//         child: Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: ListTile(
//             leading: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   widget.task.isCompleted = !widget.task.isCompleted;
//                 });
//               },
//               child: Container(
//                 width: 30,
//                 height: 30,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.grey, width: 2),
//                   color: widget.task.isCompleted ? Colors.green : Colors.transparent,
//                 ),
//                 child: widget.task.isCompleted
//                     ? const Icon(Icons.check, color: Colors.white, size: 20)
//                     : null,
//               ),
//             ),
//             title: Text(
//               widget.task.title,
//               style: TextStyle(
//                 fontSize: 16,
//                 decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
//               ),
//             ),
//             subtitle: Row(
//               children: [
//                 const Icon(Icons.calendar_today, size: 16, color: Colors.blueGrey),
//                 const SizedBox(width: 5),
//                 Text(
//                   "${DateFormat('EEE, MMM d').format(widget.task.dueDateTime)} at ${DateFormat('hh:mm a').format(widget.task.dueDateTime)}",
//                   style: const TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//               ],
//             ),
//             trailing: IconButton(
//               icon: Icon(
//                 widget.task.isImportant ? Icons.star : Icons.star_border,
//                 color: widget.task.isImportant ? Colors.yellow : null,
//               ),
//               onPressed: () {
//                 setState(() {
//                   widget.task.isImportant = !widget.task.isImportant;
//                 });
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../screens/task_detail_screen.dart';
import '../services/firestore_service.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final VoidCallback onTaskDeleted;
  final VoidCallback onTaskCompleted;
  final VoidCallback onTaskIncompleted; // Added for marking as incomplete

  const TaskTile({
    super.key,
    required this.task,
    required this.onTaskDeleted,
    required this.onTaskCompleted,
    required this.onTaskIncompleted,
  });

  @override
  _TaskTileState createState() => _TaskTileState();
}

// class _TaskTileState extends State<TaskTile> {
//   void _openTaskDetails() async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TaskDetailScreen(
//           task: widget.task,
//           onTaskUpdated: () => setState(() {}),
//         ),
//       ),
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Dismissible(
//       key: Key(widget.task.title), // Unique identifier
//       background: widget.task.isCompleted
//           ? Container() // ✅ Empty container instead of null // Prevent right swipe on completed tasks
//           : Container(
//               color: Colors.green,
//               alignment: Alignment.centerLeft,
//               padding: const EdgeInsets.only(left: 20),
//               child: const Icon(Icons.check, color: Colors.white, size: 30),
//             ),
//       secondaryBackground: Container(
//         color: Colors.red,
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.only(right: 20),
//         child: const Icon(Icons.delete, color: Colors.white, size: 30),
//       ),
//       confirmDismiss: (direction) async {
//         if (direction == DismissDirection.endToStart) {
//           widget.onTaskDeleted(); // Delete task
//           return true;
//         } else if (direction == DismissDirection.startToEnd) {
//           if (widget.task.isCompleted) return false; // Block right swipe on completed tasks
//           setState(() {  
//               widget.task.isCompleted = true;  // 🔥 **Immediately update UI**
//           });

//           widget.onTaskCompleted(); // 🔥 **Ensure the UI updates instantly**
            
//           return false; // 🔥 **Prevent task from disappearing immediately**
//         }
//         return false;
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
//         child: Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: ListTile(
//             onTap: _openTaskDetails, // 🔥 **Click opens task details**
//             leading: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   widget.task.isCompleted = !widget.task.isCompleted;
//                   widget.task.isCompleted
//                       ? widget.onTaskCompleted()
//                       : widget.onTaskIncompleted(); // Handle incomplete state
//                 });
//               },
//               child: Container(
//                 width: 30,
//                 height: 30,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.grey, width: 2),
//                   color: widget.task.isCompleted ? Colors.green : Colors.transparent,
//                 ),
//                 child: widget.task.isCompleted
//                     ? const Icon(Icons.check, color: Colors.white, size: 20)
//                     : null,
//               ),
//             ),
//             title: Text(
//               widget.task.title,
//               style: TextStyle(
//                 fontSize: 16,
//                 decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
//               ),
//             ),
//             subtitle: Row(
//               children: [
//                 const Icon(Icons.calendar_today, size: 16, color: Colors.blueGrey),
//                 const SizedBox(width: 5),
//                 Text(
//                   "${DateFormat('EEE, MMM d').format(widget.task.dueDateTime)} at ${DateFormat('hh:mm a').format(widget.task.dueDateTime)}",
//                   style: const TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//               ],
//             ),
//             trailing: IconButton(
//               icon: Icon(
//                 widget.task.isImportant ? Icons.star : Icons.star_border,
//                 color: widget.task.isImportant ? Colors.yellow : null,
//               ),
//               onPressed: () {
//                 setState(() {
//                   widget.task.isImportant = !widget.task.isImportant;
//                 });
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
class _TaskTileState extends State<TaskTile> {
  final FirestoreService _firestoreService = FirestoreService(); // Add Firestore service
  bool _isUpdating = false; // Prevent duplicate updates

  void _openTaskDetails() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(
          task: widget.task,
          onTaskUpdated: () => setState(() {}),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.task.title), // Unique identifier
      background: widget.task.isCompleted
          ? Container() // ✅ Empty container instead of null // Prevent right swipe on completed tasks
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
          widget.onTaskDeleted(); // Delete task
          return true;
        } else if (direction == DismissDirection.startToEnd) {
          if (widget.task.isCompleted) return false; // Block right swipe on completed tasks
          setState(() {  
              widget.task.isCompleted = true;  // 🔥 **Immediately update UI**
          });
          widget.onTaskCompleted(); // 🔥 **Ensure the UI updates instantly**
          return false; // 🔥 **Prevent task from disappearing immediately**
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
            onTap: _openTaskDetails, // 🔥 **Click opens task details**
            leading: GestureDetector(
              onTap: () {
                setState(() {
                  widget.task.isCompleted = !widget.task.isCompleted;
                  widget.task.isCompleted
                      ? widget.onTaskCompleted()
                      : widget.onTaskIncompleted(); // Handle incomplete state
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
                  _firestoreService.updateTask(widget.task); // Persist to Firestore
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}