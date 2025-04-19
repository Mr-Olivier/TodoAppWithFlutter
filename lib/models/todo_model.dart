// This class defines the structure of a Todo item
class Todo {
  String id; // Unique identifier for each todo
  String title; // Short title of the todo
  String content; // Detailed description of the todo
  DateTime createdAt; // Date and time when the todo was created
  bool isCompleted; // Status of the todo (completed or not)

  // Constructor for creating a new Todo
  Todo({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isCompleted = false, // Default value is false (not completed)
  });

  // Convert Todo object to Map (useful for storing in SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(), // Convert DateTime to String
      'isCompleted': isCompleted,
    };
  }

  // Create Todo object from Map (useful when retrieving from SharedPreferences)
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']), // Convert String to DateTime
      isCompleted: map['isCompleted'],
    );
  }
}
