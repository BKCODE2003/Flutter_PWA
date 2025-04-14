class GroupTask {
  String id; // Firestore document ID
  String title;
  String description;
  DateTime dueDateTime;
  Duration targetedTime;
  bool isCompleted;
  bool isImportant;
  DateTime createdAt;
  String createdByUid; // UID of the user who created the task
  List<DateTime> reminders;
  List<DateTime> customReminders;
  List<int> alarmIds;

  GroupTask({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDateTime,
    required this.targetedTime,
    this.isCompleted = false,
    this.isImportant = false,
    required this.createdAt,
    required this.createdByUid,
    List<DateTime>? reminders,
    List<DateTime>? customReminders,
    List<int>? alarmIds,
  }) : reminders = reminders ?? defaultReminders(dueDateTime, targetedTime),
       customReminders = customReminders ?? [],
       alarmIds = alarmIds ?? [];

  static List<DateTime> defaultReminders(DateTime dueDateTime, Duration targetedTime) {
    return [
      dueDateTime.subtract(targetedTime + const Duration(hours: 1)),
      dueDateTime.subtract(targetedTime + const Duration(days: 1)),
    ];
  }

  List<DateTime> get allReminders => [...reminders, ...customReminders];

  bool isDueToday() {
    DateTime now = DateTime.now();
    return dueDateTime.year == now.year &&
        dueDateTime.month == now.month &&
        dueDateTime.day == now.day;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDateTime': dueDateTime.toIso8601String(),
      'targetedTime': targetedTime.inMinutes,
      'isCompleted': isCompleted,
      'isImportant': isImportant,
      'createdAt': createdAt.toIso8601String(),
      'createdByUid': createdByUid,
      'reminders': reminders.map((e) => e.toIso8601String()).toList(),
      'customReminders': customReminders.map((e) => e.toIso8601String()).toList(),
      'alarmIds': alarmIds,
    };
  }

  factory GroupTask.fromMap(Map<String, dynamic> map) {
    return GroupTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDateTime: DateTime.parse(map['dueDateTime'] ?? DateTime.now().toIso8601String()),
      targetedTime: Duration(minutes: map['targetedTime'] ?? 0),
      isCompleted: map['isCompleted'] ?? false,
      isImportant: map['isImportant'] ?? false,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      createdByUid: map['createdByUid'] ?? '',
      reminders: (map['reminders'] as List<dynamic>?)?.cast<String>().map(DateTime.parse).toList() ?? [],
      customReminders: (map['customReminders'] as List<dynamic>?)?.cast<String>().map(DateTime.parse).toList() ?? [],
      alarmIds: (map['alarmIds'] as List<dynamic>?)?.cast<int>().toList() ?? [],
    );
  }

  void addAlarmId(int id) {
    if (!alarmIds.contains(id)) {
      alarmIds.add(id);
    }
  }

  void removeAlarmId(int id) {
    alarmIds.remove(id);
  }

  void clearAlarmIds() {
    alarmIds.clear();
  }
}