import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo_model.dart';

class DetailViewScreen extends StatelessWidget {
  final Todo todo;
  final Function(Todo) onTodoEdit;
  final Function(String) onTodoDelete;
  final Function(Todo) onTodoToggle;

  const DetailViewScreen({
    Key? key,
    required this.todo,
    required this.onTodoEdit,
    required this.onTodoDelete,
    required this.onTodoToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format the date and time
    final formattedDate = DateFormat.yMMMMd().format(todo.createdAt);
    final formattedTime = DateFormat.jm().format(todo.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          // Edit action
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pop(context);
              onTodoEdit(todo);
            },
          ),
          // Delete action
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Delete Todo'),
                      content: const Text(
                        'Are you sure you want to delete this todo?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(
                              context,
                            ).pop(); // Close both dialog and detail screen
                            onTodoDelete(todo.id);
                          },
                          child: const Text(
                            'DELETE',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Status icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            todo.isCompleted
                                ? Colors.green[100]
                                : Colors.orange[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        todo.isCompleted
                            ? Icons.check_circle
                            : Icons.pending_actions,
                        color:
                            todo.isCompleted
                                ? Colors.green[700]
                                : Colors.orange[700],
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Status text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todo.isCompleted ? 'Completed' : 'Pending',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            todo.isCompleted
                                ? 'This task has been completed'
                                : 'This task is still pending',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    // Toggle button
                    Switch(
                      value: todo.isCompleted,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        // Create a new todo with toggled status
                        final updatedTodo = Todo(
                          id: todo.id,
                          title: todo.title,
                          content: todo.content,
                          createdAt: todo.createdAt,
                          isCompleted: value,
                        );
                        onTodoToggle(updatedTodo);
                        Navigator.pop(context); // Go back after toggle
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Title section
            const Text(
              'TITLE',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              todo.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Date and time section
            const Text(
              'CREATED ON',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[600], size: 16),
                const SizedBox(width: 8),
                Text(formattedDate, style: TextStyle(color: Colors.grey[800])),
                const SizedBox(width: 16),
                Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                const SizedBox(width: 8),
                Text(formattedTime, style: TextStyle(color: Colors.grey[800])),
              ],
            ),
            const SizedBox(height: 24),

            // Description section
            const Text(
              'DESCRIPTION',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                todo.content.isEmpty ? 'No description provided' : todo.content,
                style: TextStyle(
                  fontSize: 16,
                  color: todo.content.isEmpty ? Colors.grey : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom action button
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Mark as complete/incomplete button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final updatedTodo = Todo(
                      id: todo.id,
                      title: todo.title,
                      content: todo.content,
                      createdAt: todo.createdAt,
                      isCompleted: !todo.isCompleted,
                    );
                    onTodoToggle(updatedTodo);
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    todo.isCompleted ? Icons.refresh : Icons.check_circle,
                  ),
                  label: Text(
                    todo.isCompleted
                        ? 'Mark as Incomplete'
                        : 'Mark as Complete',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        todo.isCompleted ? Colors.orange : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
