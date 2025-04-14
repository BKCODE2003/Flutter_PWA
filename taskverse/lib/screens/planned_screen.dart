// import 'package:flutter/material.dart';
// import '../models/task_model.dart';
// import '../widgets/task_tile.dart';

// class PlannedScreen extends StatefulWidget {
//   const PlannedScreen({super.key});

//   @override
//   _PlannedScreenState createState() => _PlannedScreenState();
// }

// class _PlannedScreenState extends State<PlannedScreen> {
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
//     // Filter only tasks planned for this week
//     List<Task> plannedTasks = tasks.where((task) => task.isPlannedForThisWeek()).toList();

//     // Remove completed tasks that are older than a week
//     plannedTasks.removeWhere((task) {
//       return task.isCompleted &&
//           task.dueDateTime.isBefore(DateTime.now().subtract(const Duration(days: 7)));
//     });

//     return Scaffold(
//       appBar: AppBar(title: const Text('Planned')),
//       body: plannedTasks.isEmpty
//           ? const Center(child: Text('No planned tasks!'))
//           : ListView.builder(
//               itemCount: plannedTasks.length,
//               itemBuilder: (context, index) {
//                 return TaskTile(
//                   task: plannedTasks[index],
//                   onTaskDeleted: () {
//                     setState(() {
//                       tasks.remove(plannedTasks[index]); // Delete task
//                       _sortTasks();
//                     });
//                   },
//                   onTaskCompleted: () {
//                     setState(() {
//                       plannedTasks[index].isCompleted = true; // Mark as complete
//                       _sortTasks();
//                     });
//                   },
//                   onTaskIncompleted: () {
//                     setState(() {
//                       plannedTasks[index].isCompleted = false; // Mark as incomplete
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

class PlannedScreen extends StatefulWidget {
  const PlannedScreen({super.key});

  @override
  _PlannedScreenState createState() => _PlannedScreenState();
}

class _PlannedScreenState extends State<PlannedScreen> {
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
      appBar: AppBar(title: const Text('Planned')),
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
          List<Task> plannedTasks = tasks.where((task) => task.isPlannedForThisWeek()).toList();
          // Remove completed tasks that are older than a week
          plannedTasks.removeWhere((task) {
            return task.isCompleted &&
                task.dueDateTime.isBefore(DateTime.now().subtract(const Duration(days: 7)));
          });
          plannedTasks = _sortTasks(plannedTasks);

          return plannedTasks.isEmpty
              ? const Center(child: Text('No planned tasks!'))
              : ListView.builder(
                  itemCount: plannedTasks.length,
                  itemBuilder: (context, index) {
                    return TaskTile(
                      task: plannedTasks[index],
                      onTaskDeleted: () {
                        // setState(() {
                        //   tasks.remove(plannedTasks[index]); // Delete task
                        //   _sortTasks();
                        // });
                        _firestoreService.deleteTask(plannedTasks[index]); // Delete from Firestore
                      },
                      onTaskCompleted: () {
                        // setState(() {
                        //   plannedTasks[index].isCompleted = true; // Mark as complete
                        //   _sortTasks();
                        // });
                        plannedTasks[index].isCompleted = true;
                        _firestoreService.updateTask(plannedTasks[index]); // Update in Firestore
                      },
                      onTaskIncompleted: () {
                        // setState(() {
                        //   plannedTasks[index].isCompleted = false; // Mark as incomplete
                        //   _sortTasks();
                        // });
                        plannedTasks[index].isCompleted = false;
                        _firestoreService.updateTask(plannedTasks[index]); // Update in Firestore
                      },
                    );
                  },
                );
        },
      ),
    );
  }
}