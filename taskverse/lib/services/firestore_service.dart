import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get user-specific tasks collection
  CollectionReference _getTasksCollection() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');
    return _db.collection('users').doc(userId).collection('tasks');
  }

  // Save a new task
  Future<void> saveTask(Task task) async {
    final taskMap = task.toMap();
    await _getTasksCollection().doc(taskMap['createdAt']).set(taskMap);
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    final taskMap = task.toMap();
    await _getTasksCollection().doc(taskMap['createdAt']).update(taskMap);
  }

  // Delete a task
  Future<void> deleteTask(Task task) async {
    await _getTasksCollection().doc(task.createdAt.toIso8601String()).delete();
  }

  // Fetch all tasks for the current user
  Future<List<Task>> fetchTasks() async {
    final snapshot = await _getTasksCollection().get();
    return snapshot.docs.map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  // Stream tasks for real-time updates
  Stream<List<Task>> streamTasks() {
    return _getTasksCollection().snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  // Fetch user UID by email
  Future<String?> getUserUidByEmail(String email) async {
    try {
      final snapshot = await _db
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}