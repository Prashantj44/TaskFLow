class TaskModel {
  String id;
  String title;
  String description;
  DateTime date;
  bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.isCompleted = false,
  });

  factory TaskModel.fromMap(Map<String, dynamic> data, String documentId) {
    return TaskModel(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      isCompleted: data['status'] == 'completed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'status': isCompleted ? 'completed' : 'pending',
    };
  }
}
