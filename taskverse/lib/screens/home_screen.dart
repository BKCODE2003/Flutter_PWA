// import 'package:flutter/material.dart';
// import 'my_day_screen.dart';
// import 'important_screen.dart';
// import 'planned_screen.dart';
// import 'tasks_screen.dart';
// import 'add_task_screen.dart';
// import '../models/task_model.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   void _navigateTo(BuildContext context, Widget screen) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => screen),
//     );
//   }

//   void _addNewTask(Task newTask) {
//     setState(() {
//       tasks.add(newTask); // ✅ Updates UI after adding task
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ListView(
//         padding: const EdgeInsets.all(16.0),
//         children: [
//           _buildSection(context, 'My Day', Icons.wb_sunny, MyDayScreen()),
//           _buildSection(context, 'Important', Icons.star, ImportantScreen()),
//           _buildSection(context, 'Planned', Icons.calendar_today, PlannedScreen()),
//           _buildSection(context, 'Tasks', Icons.list, TasksScreen()),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => AddTaskScreen(
//                 onTaskAdded: _addNewTask, // ✅ Correctly updates state
//               ),
//             ),
//           );
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _buildSection(BuildContext context, String title, IconData icon, Widget screen) {
//     return Card(
//       child: ListTile(
//         leading: Icon(icon, color: Colors.blue),
//         title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
//         trailing: const Icon(Icons.arrow_forward_ios, size: 18),
//         onTap: () => _navigateTo(context, screen),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'my_day_screen.dart';
import 'important_screen.dart';
import 'planned_screen.dart';
import 'tasks_screen.dart';
import 'add_task_screen.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart'; // Add this import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService(); // Add Firestore service

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _addNewTask(Task newTask) {
    // setState(() {
    //   tasks.add(newTask); // ✅ Updates UI after adding task
    // });
    _firestoreService.saveTask(newTask); // Save to Firestore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(context, 'My Day', Icons.wb_sunny, MyDayScreen()),
          _buildSection(context, 'Important', Icons.star, ImportantScreen()),
          _buildSection(context, 'Planned', Icons.calendar_today, PlannedScreen()),
          _buildSection(context, 'Tasks', Icons.list, TasksScreen()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(
                onTaskAdded: _addNewTask, // ✅ Correctly updates state
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, Widget screen) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () => _navigateTo(context, screen),
      ),
    );
  }
}