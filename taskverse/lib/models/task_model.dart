
class Task {
  String title;
  String description;
  DateTime dueDateTime; // Stores due date and time
  Duration targetedTime; // Estimated time to complete task
  bool isCompleted;
  bool isImportant;
  DateTime createdAt;
  List<DateTime> reminders; // List of reminders (manual or default)
  List<DateTime> customReminders;
  // New field for tracking alarm IDs
  List<int> alarmIds;

  Task({
    required this.title,
    required this.description,
    required this.dueDateTime,
    required this.targetedTime,
    this.isCompleted = false,
    this.isImportant = false,
    required this.createdAt,
    List<DateTime>? reminders, // Allow manual alarms
    List<DateTime>? customReminders,
    List<int>? alarmIds,
  }) : reminders = reminders ?? defaultReminders(dueDateTime, targetedTime),
       customReminders = customReminders ?? [],
       alarmIds = alarmIds ?? [];

  /// **Default Reminders**
  /// - 1 hour before the targeted time
  /// - 1 day before the targeted time
  static List<DateTime> defaultReminders(DateTime dueDateTime, Duration targetedTime) {
    return [
      dueDateTime.subtract(targetedTime + const Duration(hours: 1)), // 1 hour before
      dueDateTime.subtract(targetedTime + const Duration(days: 1)), // 1 day before
    ];
  }

   /// **Get All Reminders (Default + Custom)**
  List<DateTime> get allReminders => [...reminders, ...customReminders];

  /// **Check if Task is Due Today**
  bool isDueToday() {
    DateTime now = DateTime.now();
    return dueDateTime.year == now.year &&
        dueDateTime.month == now.month &&
        dueDateTime.day == now.day;
  }

/// **Check if Task is Planned for This Week**
bool isPlannedForThisWeek() {
  DateTime now = DateTime.now();
  // Start of week (Monday, 00:00:00)
  DateTime startOfWeek = DateTime(now.year, now.month, now.day - (now.weekday - 1));
  // End of week (Sunday, 23:59:59)
  DateTime endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  // Include tasks on or after startOfWeek and on or before endOfWeek
  return !dueDateTime.isBefore(startOfWeek) && !dueDateTime.isAfter(endOfWeek);
}

  /// **Convert Task to Map (For Storage)**
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDateTime': dueDateTime.toIso8601String(),
      'targetedTime': targetedTime.inMinutes,
      'isCompleted': isCompleted,
      'isImportant': isImportant,
      'createdAt': createdAt.toIso8601String(),
      'reminders': reminders.map((e) => e.toIso8601String()).toList(),
      'customReminders': customReminders.map((e) => e.toIso8601String()).toList(),
      'alarmIds': alarmIds, // Store alarm IDs
    };
  }

  /// **Convert Map to Task (For Retrieval)**
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDateTime: DateTime.parse(map['dueDateTime'] ?? DateTime.now().toIso8601String()),
      targetedTime: Duration(minutes: map['targetedTime'] ?? 0),
      isCompleted: map['isCompleted'] ?? false,
      isImportant: map['isImportant'] ?? false,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      reminders: (map['reminders'] as List<dynamic>?)?.cast<String>().map(DateTime.parse).toList() ?? [],
      customReminders: (map['customReminders'] as List<dynamic>?)?.cast<String>().map(DateTime.parse).toList() ?? [],
      alarmIds: (map['alarmIds'] as List<dynamic>?)?.cast<int>().toList() ?? [],
    );
  }
  /// **Add alarm ID to task**
  void addAlarmId(int id) {
    if (!alarmIds.contains(id)) {
      alarmIds.add(id);
    }
  }
    
  /// **Remove alarm ID from task**
  void removeAlarmId(int id) {
    alarmIds.remove(id);
  }
    
  /// **Clear all alarm IDs**
  void clearAlarmIds() {
    alarmIds.clear();
  }
}


/// **Global Task List (Temporary Storage)**
// List<Task> tasks = [];
