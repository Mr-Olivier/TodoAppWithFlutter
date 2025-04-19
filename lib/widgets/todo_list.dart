import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo_model.dart';

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final Function(Todo) onTodoToggle;
  final Function(String) onTodoDelete;
  final Function(Todo) onTodoEdit;
  final Function(Todo) onTodoView; // Added function to view todo details

  const TodoList({
    Key? key,
    required this.todos,
    required this.onTodoToggle,
    required this.onTodoDelete,
    required this.onTodoEdit,
    required this.onTodoView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If there are no todos, show an empty state message
    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tasks yet',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a new task by tapping the + button',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Otherwise, display a list of todos
    return ListView.builder(
      itemCount: todos.length,
      padding: const EdgeInsets.only(
        bottom: 80,
      ), // Extra padding at bottom for FAB
      itemBuilder: (context, index) {
        final todo = todos[index];

        // Format the date
        final formattedDate = DateFormat.yMMMd().format(todo.createdAt);

        return Dismissible(
          key: Key(todo.id),
          // Allow dismissing from right to left (for delete)
          direction: DismissDirection.endToStart,

          // Confirm deletion when dismissed
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Delete Todo'),
                    content: const Text(
                      'Are you sure you want to delete this todo?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          'DELETE',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
            );
          },

          // Delete the todo when dismissed
          onDismissed: (direction) {
            onTodoDelete(todo.id);

            // Show a snackbar with undo option
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Todo deleted'),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    // Add the todo back
                    onTodoToggle(todo);
                  },
                ),
              ),
            );
          },

          // Background shown when dismissing (delete indicator)
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),

          // The actual todo item
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  // Todo status checkbox
                  leading: IconButton(
                    icon: Icon(
                      todo.isCompleted
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color:
                          todo.isCompleted
                              ? Colors.green
                              : Theme.of(context).primaryColor,
                      size: 28,
                    ),
                    onPressed: () => onTodoToggle(todo),
                  ),

                  // Todo title
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration:
                          todo.isCompleted ? TextDecoration.lineThrough : null,
                      color: todo.isCompleted ? Colors.grey : null,
                    ),
                  ),

                  // Creation date
                  subtitle: Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 12),
                  ),

                  // Content preview (if any)
                  isThreeLine: todo.content.isNotEmpty,
                  dense: false,

                  // Tap to view details
                  onTap: () => onTodoView(todo),
                ),

                // Action buttons row
                Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // View button
                      IconButton(
                        onPressed: () => onTodoView(todo),
                        icon: const Icon(Icons.visibility),
                        tooltip: 'View details',
                        color: Colors.blue,
                      ),

                      // Edit button
                      IconButton(
                        onPressed: () => onTodoEdit(todo),
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit task',
                        color: Colors.orange,
                      ),

                      // Delete button
                      IconButton(
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
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      child: const Text('CANCEL'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
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
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete task',
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
