// import 'package:flutter/material.dart';
// import '../models/task_model.dart';
// import '../widgets/task_tile.dart';

// class TasksScreen extends StatefulWidget {
//   const TasksScreen({super.key});

//   @override
//   _TasksScreenState createState() => _TasksScreenState();
// }

// class _TasksScreenState extends State<TasksScreen> {
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
//     return Scaffold(
//       appBar: AppBar(title: const Text('All Tasks')),
//       body: tasks.isEmpty
//           ? const Center(child: Text('No tasks added yet!'))
//           : ListView.builder(
//               itemCount: tasks.length,
//               itemBuilder: (context, index) {
//                 return TaskTile(
//                   task: tasks[index],
//                   onTaskDeleted: () {
//                     setState(() {
//                       tasks.removeAt(index); // Delete & refresh list
//                       _sortTasks();
//                     });
//                   },
//                   onTaskCompleted: () {
//                     setState(() {
//                       tasks[index].isCompleted = true; // Mark complete
//                       _sortTasks();
//                     });
//                   },
//                   onTaskIncompleted: () {
//                     setState(() {
//                       tasks[index].isCompleted = false; // Mark incomplete
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

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final FirestoreService _firestoreService = FirestoreService(); // Add Firestore service

  @override
  void initState() {
    super.initState();
    // _sortTasks(); // Removed as it's not needed with StreamBuilder
  }

  List<Task> _sortTasksList(List<Task> tasks) {
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
      appBar: AppBar(title: const Text('All Tasks')),
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
          if (tasks.isEmpty) {
            return const Center(child: Text('No tasks added yet!'));
          }
          // tasks.sort((a, b) {
          //   if (a.isCompleted == b.isCompleted) {
          //     return a.dueDateTime.compareTo(b.dueDateTime); // Sort by due date
          //   }
          //   return a.isCompleted ? 1 : -1; // Incomplete first
          // });
          final sortedTasks = _sortTasksList(List.from(tasks)); // Sort tasks
          return ListView.builder(
            itemCount: sortedTasks.length,
            itemBuilder: (context, index) {
              return TaskTile(
                task: sortedTasks[index],
                onTaskDeleted: () {
                  // setState(() {
                  //   tasks.removeAt(index); // Delete & refresh list
                  //   _sortTasks();
                  // });
                  _firestoreService.deleteTask(sortedTasks[index]); // Delete from Firestore
                },
                onTaskCompleted: () {
                  // setState(() {
                  //   tasks[index].isCompleted = true; // Mark complete
                  //   _sortTasks();
                  // });
                  sortedTasks[index].isCompleted = true;
                  _firestoreService.updateTask(sortedTasks[index]); // Update in Firestore
                },
                onTaskIncompleted: () {
                  // setState(() {
                  //   tasks[index].isCompleted = false; // Mark incomplete
                  //   _sortTasks();
                  // });
                  sortedTasks[index].isCompleted = false;
                  _firestoreService.updateTask(sortedTasks[index]); // Update in Firestore
                },
              );
            },
          );
        },
      ),
    );
  }
}