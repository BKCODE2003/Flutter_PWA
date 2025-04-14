import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/group_model.dart';
import '../models/group_task_model.dart';
import '../services/group_firestore_service.dart';
import '../services/firestore_service.dart';
import 'add_group_task_screen.dart';
import '../widgets/group_task_tile.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final GroupFirestoreService _groupService = GroupFirestoreService();
  final FirestoreService _firestoreService = FirestoreService();

  void _addMember() async {
    final users = await _groupService.fetchAllUsers();
    final availableUsers = users.where((user) => !widget.group.memberUids.contains(user['uid'])).toList();

    if (availableUsers.isEmpty) {
      Fluttertoast.showToast(msg: 'No users available to add');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: availableUsers.length,
            itemBuilder: (context, index) {
              final user = availableUsers[index];
              return ListTile(
                title: Text(user['email']!),
                subtitle: Text(user['username']!),
                onTap: () async {
                  final added = await _groupService.addMemberByEmail(widget.group.id, user['email']!);
                  if (added) {
                    Fluttertoast.showToast(msg: 'Member added successfully');
                    setState(() {}); // Refresh UI
                  } else {
                    Fluttertoast.showToast(msg: 'Failed to add member');
                  }
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _removeMember(String memberUid) async {
    try {
      await _groupService.removeMember(widget.group.id, memberUid);
      Fluttertoast.showToast(msg: 'Member removed successfully');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error removing member: $e');
    }
  }

  void _addNewGroupTask(GroupTask task) {
    _groupService.saveGroupTask(widget.group.id, task);
  }

  List<GroupTask> _sortTasks(List<GroupTask> tasks) {
    tasks.sort((a, b) {
      if (a.isCompleted == b.isCompleted) {
        return a.dueDateTime.compareTo(b.dueDateTime);
      }
      return a.isCompleted ? 1 : -1;
    });
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final isCreator = widget.group.creatorUid == userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: isCreator
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Group'),
                        content: const Text('Are you sure you want to delete this group?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _groupService.deleteGroup(widget.group.id);
                      Navigator.pop(context);
                    }
                  },
                ),
              ]
            : [],
      ),
      body: StreamBuilder<List<GroupTask>>(
        stream: _groupService.streamGroupTasks(widget.group.id),
        builder: (context, taskSnapshot) {
          if (taskSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (taskSnapshot.hasError) {
            return Center(child: Text('Error loading tasks: ${taskSnapshot.error}'));
          }
          final tasks = taskSnapshot.data ?? [];
          final sortedTasks = _sortTasks(tasks);

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (isCreator) ...[
                const Text('Manage Members', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addMember,
                  child: const Text('Add Member'),
                ),
                const SizedBox(height: 10),
                StreamBuilder<DocumentSnapshot>(
                  stream: _db.collection('groups').doc(widget.group.id).snapshots(),
                  builder: (context, groupSnapshot) {
                    if (groupSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (groupSnapshot.hasError) {
                      return const Text('Error loading members');
                    }
                    final groupData = groupSnapshot.data?.data() as Map<String, dynamic>?;
                    final memberUids = List<String>.from(groupData?['memberUids'] ?? []);

                    return FutureBuilder<List<Map<String, String>>>(
                      future: _getMemberDetails(memberUids),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final members = snapshot.data ?? [];
                        return Column(
                          children: members.map((member) {
                            final memberUid = member['uid']!;
                            return ListTile(
                              title: Text(member['email']!),
                              subtitle: memberUid == widget.group.creatorUid
                                  ? const Text('Creator')
                                  : null,
                              trailing: memberUid != widget.group.creatorUid
                                  ? IconButton(
                                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                                      onPressed: () => _removeMember(memberUid),
                                    )
                                  : null,
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
              const Text('Group Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              sortedTasks.isEmpty
                  ? const Center(child: Text('No tasks in this group!'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sortedTasks.length,
                      itemBuilder: (context, index) {
                        return GroupTaskTile(
                          task: sortedTasks[index],
                          groupId: widget.group.id,
                          onTaskDeleted: () {
                            _groupService.deleteGroupTask(widget.group.id, sortedTasks[index].id);
                          },
                          onTaskCompleted: () {
                            sortedTasks[index].isCompleted = true;
                            _groupService.updateGroupTask(widget.group.id, sortedTasks[index]);
                          },
                          onTaskIncompleted: () {
                            sortedTasks[index].isCompleted = false;
                            _groupService.updateGroupTask(widget.group.id, sortedTasks[index]);
                          },
                        );
                      },
                    ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddGroupTaskScreen(
                groupId: widget.group.id,
                onTaskAdded: _addNewGroupTask,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<List<Map<String, String>>> _getMemberDetails(List<String> uids) async {
    List<Map<String, String>> members = [];
    for (var uid in uids) {
      final userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        members.add({
          'uid': uid,
          'email': userDoc['email'] ?? 'Unknown',
        });
      }
    }
    return members;
  }

  FirebaseFirestore get _db => FirebaseFirestore.instance;
}