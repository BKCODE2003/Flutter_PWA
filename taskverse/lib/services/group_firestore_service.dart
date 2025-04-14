import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/group_model.dart';
import '../models/group_task_model.dart';


class GroupFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create a new group
  Future<void> createGroup(Group group) async {
    try {
      final data = group.toMap();
      print('Creating group with ID: ${group.id}, data: $data');
      await _db.collection('groups').doc(group.id).set(data);
      print('Group created successfully: ${group.id}, memberUids: ${group.memberUids}');
    } catch (e) {
      print('Error creating group: $e');
      rethrow;
    }
  }

  // Update a group (e.g., add/remove members)
  Future<void> updateGroup(Group group) async {
    try {
      await _db.collection('groups').doc(group.id).update(group.toMap());
    } catch (e) {
      print('Error updating group: $e');
      rethrow;
    }
  }

  // Delete a group
  Future<void> deleteGroup(String groupId) async {
    try {
      await _db.collection('groups').doc(groupId).delete();
    } catch (e) {
      print('Error deleting group: $e');
      rethrow;
    }
  }

  // Stream groups for the current user
  Stream<List<Group>> streamGroups() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    print('Streaming groups for userId: $userId');
    if (userId == null) {
      print('No user logged in');
      return Stream.value([]);
    }
    return _db
        .collection('groups')
        .where('memberUids', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          print('Groups snapshot: ${snapshot.docs.length} groups found');
          for (var doc in snapshot.docs) {
            print('Group data: ${doc.data()}');
          }
          return snapshot.docs
              .map((doc) => Group.fromMap(doc.id, doc.data()))
              .toList();
        })
        .handleError((e) {
      print('Error streaming groups: $e');
      throw e;
    });
  }

  // Save a group task
  Future<void> saveGroupTask(String groupId, GroupTask task) async {
    try {
      await _db
          .collection('groups')
          .doc(groupId)
          .collection('tasks')
          .doc(task.id)
          .set(task.toMap());
    } catch (e) {
      print('Error saving group task: $e');
      rethrow;
    }
  }

  // Update a group task
  Future<void> updateGroupTask(String groupId, GroupTask task) async {
    try {
      await _db
          .collection('groups')
          .doc(groupId)
          .collection('tasks')
          .doc(task.id)
          .update(task.toMap());
    } catch (e) {
      print('Error updating group task: $e');
      rethrow;
    }
  }

  // Delete a group task
  Future<void> deleteGroupTask(String groupId, String taskId) async {
    try {
      await _db
          .collection('groups')
          .doc(groupId)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      print('Error deleting group task: $e');
      rethrow;
    }
  }

  // Stream group tasks
  Stream<List<GroupTask>> streamGroupTasks(String groupId) {
    return _db
        .collection('groups')
        .doc(groupId)
        .collection('tasks')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GroupTask.fromMap(doc.data()))
            .toList())
        .handleError((e) {
      print('Error streaming group tasks: $e');
      throw e;
    });
  }

  // Add a member to a group by email
  Future<bool> addMemberByEmail(String groupId, String email) async {
    try {
      final userSnapshot = await _db
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();
      if (userSnapshot.docs.isEmpty) {
        print('No user found with email: $email');
        return false;
      }

      final userId = userSnapshot.docs.first.id;
      final groupRef = _db.collection('groups').doc(groupId);
      await groupRef.update({
        'memberUids': FieldValue.arrayUnion([userId]),
      });
      print('Added member $userId to group $groupId');
      return true;
    } catch (e) {
      print('Error adding member by email: $e');
      return false;
    }
  }

  // Remove a member from a group
  Future<void> removeMember(String groupId, String memberUid) async {
    try {
      final groupRef = _db.collection('groups').doc(groupId);
      await groupRef.update({
        'memberUids': FieldValue.arrayRemove([memberUid]),
      });
    } catch (e) {
      print('Error removing member: $e');
      rethrow;
    }
  }

  // Fetch all users for member selection
  Future<List<Map<String, String>>> fetchAllUsers() async {
    try {
      final snapshot = await _db.collection('users').get();
      return snapshot.docs
          .map((doc) => {
                'uid': doc.id,
                'email': (doc.data()['email'] as String?) ?? 'Unknown',
                'username': (doc.data()['username'] as String?) ?? 'Unknown',
              })
          .toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }
}