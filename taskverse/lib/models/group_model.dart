import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  String id; // Firestore document ID
  String name;
  String creatorUid; // UID of the user who created the group
  List<String> memberUids; // List of member UIDs
  DateTime createdAt;

  Group({
    required this.id,
    required this.name,
    required this.creatorUid,
    required this.memberUids,
    required this.createdAt,
  });

  // Convert Group to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'creatorUid': creatorUid,
      'memberUids': memberUids,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create Group from Firestore Map
  factory Group.fromMap(String id, Map<String, dynamic> map) {
    return Group(
      id: id,
      name: map['name'] ?? '',
      creatorUid: map['creatorUid'] ?? '',
      memberUids: List<String>.from(map['memberUids'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}