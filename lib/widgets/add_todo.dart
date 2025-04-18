import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/todo_model.dart';

class AddTodoScreen extends StatefulWidget {
  final Function(Todo todo) onAddTodo;
  final Todo? todoToEdit;

  const AddTodoScreen({Key? key, required this.onAddTodo, this.todoToEdit})
    : super(key: key);

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  // Controllers for the text fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Focus nodes to manage keyboard focus
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contentFocus = FocusNode();

  // Flag to check if we are editing an existing todo
  bool get isEditing => widget.todoToEdit != null;

  @override
  void initState() {
    super.initState();

    // If we're editing, pre-fill the text fields
    if (isEditing) {
      _titleController.text = widget.todoToEdit!.title;
      _contentController.text = widget.todoToEdit!.content;
    }
  }

  @override
  void dispose() {
    // Clean up controllers and focus nodes when widget is disposed
    _titleController.dispose();
    _contentController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  // Save the todo (either new or edited)
  void _saveTodo() {
    // Validate inputs
    if (_titleController.text.trim().isEmpty) {
      // Show error message if title is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final todo =
        isEditing
            ? Todo(
              id: widget.todoToEdit!.id,
              title: _titleController.text.trim(),
              content: _contentController.text.trim(),
              createdAt: widget.todoToEdit!.createdAt,
              isCompleted: widget.todoToEdit!.isCompleted,
            )
            : Todo(
              id: const Uuid().v4(), // Generate a unique ID for new todos
              title: _titleController.text.trim(),
              content: _contentController.text.trim(),
              createdAt: DateTime.now(),
            );

    // Send the todo back to the parent widget
    widget.onAddTodo(todo);

    // Close the screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with drag handle
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Task' : 'Add New Task',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title field
            TextField(
              controller: _titleController,
              focusNode: _titleFocus,
              decoration: InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter a title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) {
                // Move focus to the content field when next is pressed
                FocusScope.of(context).requestFocus(_contentFocus);
              },
            ),
            const SizedBox(height: 16),

            // Content field
            TextField(
              controller: _contentController,
              focusNode: _contentFocus,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter a description (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 5, // Allow multiple lines for content
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Status indicator for editing mode
            if (isEditing)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      widget.todoToEdit!.isCompleted
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.todoToEdit!.isCompleted
                          ? Icons.check_circle
                          : Icons.pending_actions,
                      color:
                          widget.todoToEdit!.isCompleted
                              ? Colors.green
                              : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Status: ${widget.todoToEdit!.isCompleted ? 'Completed' : 'Pending'}',
                      style: TextStyle(
                        color:
                            widget.todoToEdit!.isCompleted
                                ? Colors.green[700]
                                : Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveTodo,
                icon: Icon(isEditing ? Icons.save : Icons.add_task),
                label: Text(isEditing ? 'UPDATE TASK' : 'ADD TASK'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
