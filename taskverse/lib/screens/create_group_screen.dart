import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/group_model.dart';
import '../services/group_firestore_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final GroupFirestoreService _groupService = GroupFirestoreService();
  bool _isLoading = false;
  final List<Map<String, String>> _invitedUsers = [];

  void _addUser() async {
    final users = await _groupService.fetchAllUsers();
    final availableUsers = users.where((user) => !_invitedUsers.any((u) => u['uid'] == user['uid'])).toList();

    if (availableUsers.isEmpty) {
      Fluttertoast.showToast(msg: 'No users available to invite');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Member'),
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
                onTap: () {
                  setState(() {
                    _invitedUsers.add(user);
                  });
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

  void _removeUser(Map<String, String> user) {
    setState(() {
      _invitedUsers.remove(user);
    });
  }

  void _createGroup() async {
    if (_nameController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter a group name');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      Fluttertoast.showToast(msg: 'User not logged in');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final groupId = const Uuid().v4();
    final group = Group(
      id: groupId,
      name: _nameController.text.trim(),
      creatorUid: userId,
      memberUids: [userId],
      createdAt: DateTime.now(),
    );

    try {
      print('Initiating group creation for userId: $userId, groupId: $groupId');
      await _groupService.createGroup(group);

      for (var user in _invitedUsers) {
        final added = await _groupService.addMemberByEmail(groupId, user['email']!);
        if (!added) {
          Fluttertoast.showToast(msg: 'Failed to add ${user['email']}');
        }
      }

      Fluttertoast.showToast(msg: 'Group created successfully!');
      Navigator.pop(context, true);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error creating group: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Group')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Group Name'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addUser,
                    child: const Text('Invite Member'),
                  ),
                  const SizedBox(height: 10),
                  ..._invitedUsers.map((user) => ListTile(
                        title: Text(user['email']!),
                        subtitle: Text(user['username']!),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeUser(user),
                        ),
                      )),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _createGroup,
                    child: const Text('Create Group'),
                  ),
                ],
              ),
      ),
    );
  }
}