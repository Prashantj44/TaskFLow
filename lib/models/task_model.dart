class SubTask {
  String title;
  bool isCompleted;

  SubTask({
    required this.title,
    this.isCompleted = false,
  });

  factory SubTask.fromMap(Map<String, dynamic> data) {
    return SubTask(
      title: data['title'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}

class TaskModel {
  String id;
  String title;
  String description;
  DateTime date;
  bool isCompleted;
  String priority; // 'high', 'medium', 'low'
  String category; // 'Work', 'Personal', 'Study', 'Health', 'Dev', 'Creative', 'General'
  List<SubTask> subtasks;
  int estimatedMinutes;
  String energyLevel; // 'High Focus', 'Quick Win', 'Low Energy'
  double aiPriorityScore; // 1 to 100

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.isCompleted = false,
    this.priority = 'medium',
    this.category = 'Work',
    List<SubTask>? subtasks,
    this.estimatedMinutes = 30,
    this.energyLevel = 'Quick Win',
    this.aiPriorityScore = 50.0,
  }) : subtasks = subtasks ?? [];

  factory TaskModel.fromMap(Map<String, dynamic> data, String documentId) {
    var rawSubtasks = data['subtasks'] as List<dynamic>?;
    List<SubTask> subtaskList = rawSubtasks != null
        ? rawSubtasks.map((item) => SubTask.fromMap(Map<String, dynamic>.from(item))).toList()
        : [];

    return TaskModel(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: data['date'] != null ? DateTime.tryParse(data['date']) ?? DateTime.now() : DateTime.now(),
      isCompleted: data['status'] == 'completed' || (data['isCompleted'] ?? false),
      priority: data['priority'] ?? 'medium',
      category: data['category'] ?? 'Work',
      subtasks: subtaskList,
      estimatedMinutes: data['estimatedMinutes'] ?? 30,
      energyLevel: data['energyLevel'] ?? 'Quick Win',
      aiPriorityScore: (data['aiPriorityScore'] as num?)?.toDouble() ?? 50.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'status': isCompleted ? 'completed' : 'pending',
      'isCompleted': isCompleted,
      'priority': priority,
      'category': category,
      'subtasks': subtasks.map((st) => st.toMap()).toList(),
      'estimatedMinutes': estimatedMinutes,
      'energyLevel': energyLevel,
      'aiPriorityScore': aiPriorityScore,
    };
  }

  double get completionPercentage {
    if (subtasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    int completed = subtasks.where((st) => st.isCompleted).length;
    return completed / subtasks.length;
  }
}

