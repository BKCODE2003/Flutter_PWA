// import 'package:flutter/material.dart';
// import '../models/task_model.dart';
// import '../widgets/task_tile.dart';

// class ImportantScreen extends StatefulWidget {
//   const ImportantScreen({super.key});

//   @override
//   _ImportantScreenState createState() => _ImportantScreenState();
// }

// class _ImportantScreenState extends State<ImportantScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _sortTasks();
//   }

//   void _sortTasks() {
//     setState(() {
//       tasks.sort((a, b) {
//         if (a.isCompleted == b.isCompleted) {
//           return a.dueDateTime.compareTo(b.dueDateTime); // Sort by due date
//         }
//         return a.isCompleted ? 1 : -1; // Incomplete first
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get only important tasks
//     List<Task> importantTasks = tasks.where((task) => task.isImportant).toList();

//     return Scaffold(
//       appBar: AppBar(title: const Text('Important')),
//       body: importantTasks.isEmpty
//           ? const Center(child: Text('No important tasks!'))
//           : ListView.builder(
//               itemCount: importantTasks.length,
//               itemBuilder: (context, index) {
//                 return TaskTile(
//                   task: importantTasks[index],
//                   onTaskDeleted: () {
//                     setState(() {
//                       tasks.remove(importantTasks[index]); // Delete task
//                       _sortTasks();
//                     });
//                   },
//                   onTaskCompleted: () {
//                     setState(() {
//                       importantTasks[index].isCompleted = true; // Mark as complete
//                       _sortTasks();
//                     });
//                   },
//                   onTaskIncompleted: () {
//                     setState(() {
//                       importantTasks[index].isCompleted = false; // Mark as incomplete
//                       _sortTasks();
//                     });
//                   },
//                 );
//               },
//             ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../widgets/task_tile.dart';
import '../services/firestore_service.dart'; // Add this import

class ImportantScreen extends StatefulWidget {
  const ImportantScreen({super.key});

  @override
  _ImportantScreenState createState() => _ImportantScreenState();
}

class _ImportantScreenState extends State<ImportantScreen> {
  final FirestoreService _firestoreService = FirestoreService(); // Add Firestore service

  List<Task> _sortTasks(List<Task> tasks) {
    tasks.sort((a, b) {
      if (a.isCompleted == b.isCompleted) {
        return a.dueDateTime.compareTo(b.dueDateTime); // Sort by due date
      }
      return a.isCompleted ? 1 : -1; // Incomplete first
    });
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Important')),
      body: StreamBuilder<List<Task>>(
        stream: _firestoreService.streamTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading tasks'));
          }
          final tasks = snapshot.data ?? [];
          List<Task> importantTasks = tasks.where((task) => task.isImportant).toList();
          importantTasks = _sortTasks(importantTasks);

          return importantTasks.isEmpty
              ? const Center(child: Text('No important tasks!'))
              : ListView.builder(
                  itemCount: importantTasks.length,
                  itemBuilder: (context, index) {
                    return TaskTile(
                      task: importantTasks[index],
                      onTaskDeleted: () {
                        // setState(() {
                        //   tasks.remove(importantTasks[index]); // Delete task
                        //   _sortTasks();
                        // });
                        _firestoreService.deleteTask(importantTasks[index]); // Delete from Firestore
                      },
                      onTaskCompleted: () {
                        // setState(() {
                        //   importantTasks[index].isCompleted = true; // Mark as complete
                        //   _sortTasks();
                        // });
                        importantTasks[index].isCompleted = true;
                        _firestoreService.updateTask(importantTasks[index]); // Update in Firestore
                      },
                      onTaskIncompleted: () {
                        // setState(() {
                        //   importantTasks[index].isCompleted = false; // Mark as incomplete
                        //   _sortTasks();
                        // });
                        importantTasks[index].isCompleted = false;
                        _firestoreService.updateTask(importantTasks[index]); // Update in Firestore
                      },
                    );
                  },
                );
        },
      ),
    );
  }
}