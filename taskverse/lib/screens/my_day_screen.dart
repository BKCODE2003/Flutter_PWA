// import 'package:flutter/material.dart';
// import '../models/task_model.dart';
// import '../widgets/task_tile.dart';

// class MyDayScreen extends StatefulWidget {
//   const MyDayScreen({super.key});

//   @override
//   _MyDayScreenState createState() => _MyDayScreenState();
// }

// class _MyDayScreenState extends State<MyDayScreen> {
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
//     // Get only tasks due today
//     List<Task> myDayTasks = tasks.where((task) => task.isDueToday()).toList();

//     return Scaffold(
//       appBar: AppBar(title: const Text('My Day')),
//       body: myDayTasks.isEmpty
//           ? const Center(child: Text('No tasks for today!'))
//           : ListView.builder(
//               itemCount: myDayTasks.length,
//               itemBuilder: (context, index) {
//                 return TaskTile(
//                   task: myDayTasks[index],
//                   onTaskDeleted: () {
//                     setState(() {
//                       tasks.remove(myDayTasks[index]); // Delete task
//                       _sortTasks(); // Re-sort after delete
//                     });
//                   },
//                   onTaskCompleted: () {
//                     setState(() {
//                       myDayTasks[index].isCompleted = true; // Mark as complete
//                       _sortTasks(); // Re-sort after complete
//                     });
//                   },
//                   onTaskIncompleted: () {
//                     setState(() {
//                       myDayTasks[index].isCompleted = false; // Mark as incomplete
//                       _sortTasks(); // Re-sort after incomplete
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

class MyDayScreen extends StatefulWidget {
  const MyDayScreen({super.key});

  @override
  _MyDayScreenState createState() => _MyDayScreenState();
}

class _MyDayScreenState extends State<MyDayScreen> {
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
      appBar: AppBar(title: const Text('My Day')),
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
          List<Task> myDayTasks = tasks.where((task) => task.isDueToday()).toList();
          myDayTasks = _sortTasks(myDayTasks);

          return myDayTasks.isEmpty
              ? const Center(child: Text('No tasks for today!'))
              : ListView.builder(
                  itemCount: myDayTasks.length,
                  itemBuilder: (context, index) {
                    return TaskTile(
                      task: myDayTasks[index],
                      onTaskDeleted: () {
                        // setState(() {
                        //   tasks.remove(myDayTasks[index]); // Delete task
                        //   _sortTasks(); // Re-sort after delete
                        // });
                        _firestoreService.deleteTask(myDayTasks[index]); // Delete from Firestore
                      },
                      onTaskCompleted: () {
                        // setState(() {
                        //   myDayTasks[index].isCompleted = true; // Mark as complete
                        //   _sortTasks(); // Re-sort after complete
                        // });
                        myDayTasks[index].isCompleted = true;
                        _firestoreService.updateTask(myDayTasks[index]); // Update in Firestore
                      },
                      onTaskIncompleted: () {
                        // setState(() {
                        //   myDayTasks[index].isCompleted = false; // Mark as incomplete
                        //   _sortTasks(); // Re-sort after incomplete
                        // });
                        myDayTasks[index].isCompleted = false;
                        _firestoreService.updateTask(myDayTasks[index]); // Update in Firestore
                      },
                    );
                  },
                );
        },
      ),
    );
  }
}