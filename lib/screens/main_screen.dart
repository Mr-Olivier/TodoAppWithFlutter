import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/todo_model.dart';
import '../widgets/todo_list.dart';
import '../widgets/add_todo.dart';
import 'detail_view_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // List to store all todos
  List<Todo> _todos = [];

  // Filter options
  bool _showCompleted = true;

  // Search functionality
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Get filtered todos based on current filter setting and search query
  List<Todo> get _filteredTodos {
    List<Todo> filtered = _todos;

    // Apply completion filter
    if (!_showCompleted) {
      filtered = filtered.where((todo) => !todo.isCompleted).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (todo) =>
                    todo.title.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    todo.content.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    // Load todos from storage when the app starts
    _loadTodos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Add a new todo or update an existing one
  void _addOrUpdateTodo(Todo todo) {
    setState(() {
      // Check if we're updating an existing todo
      final existingIndex = _todos.indexWhere((item) => item.id == todo.id);

      if (existingIndex >= 0) {
        // Update existing todo
        _todos[existingIndex] = todo;
        // Show success message for update
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Add new todo at the beginning of the list
        _todos.insert(0, todo);
        // Show success message for new task
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New task added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    // Save changes to storage
    _saveTodos();
  }

  // Toggle the completion status of a todo
  void _toggleTodo(Todo todo) {
    setState(() {
      final index = _todos.indexWhere((item) => item.id == todo.id);
      if (index >= 0) {
        // Create a new todo with toggled completion status
        _todos[index] = Todo(
          id: todo.id,
          title: todo.title,
          content: todo.content,
          createdAt: todo.createdAt,
          isCompleted: !todo.isCompleted,
        );

        // Show status message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _todos[index].isCompleted
                  ? 'Task marked as completed'
                  : 'Task marked as pending',
            ),
            backgroundColor:
                _todos[index].isCompleted ? Colors.green : Colors.orange,
          ),
        );
      }
    });

    // Save changes to storage
    _saveTodos();
  }

  // Delete a todo by its ID
  void _deleteTodo(String id) {
    // Find the todo before deleting for potential undo
    final deletedTodo = _todos.firstWhere((todo) => todo.id == id);
    final deletedIndex = _todos.indexWhere((todo) => todo.id == id);

    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
    });

    // Save changes to storage
    _saveTodos();

    // Show snackbar with undo option
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            // Restore the deleted todo
            setState(() {
              if (deletedIndex < _todos.length) {
                _todos.insert(deletedIndex, deletedTodo);
              } else {
                _todos.add(deletedTodo);
              }
              _saveTodos();
            });
          },
        ),
      ),
    );
  }

  // View todo details
  void _viewTodoDetails(Todo todo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => DetailViewScreen(
              todo: todo,
              onTodoEdit: (todo) => _showAddTodoBottomSheet(todoToEdit: todo),
              onTodoDelete: _deleteTodo,
              onTodoToggle: _toggleTodo,
            ),
      ),
    );
  }

  // Open the add/edit todo bottom sheet
  void _showAddTodoBottomSheet({Todo? todoToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // This allows the sheet to expand
      builder: (context) {
        return AddTodoScreen(
          onAddTodo: _addOrUpdateTodo,
          todoToEdit: todoToEdit,
        );
      },
    );
  }

  // Save todos to SharedPreferences
  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();

    // Convert todos to a format that can be stored in SharedPreferences
    final todoMaps = _todos.map((todo) => todo.toMap()).toList();
    final todosJson = json.encode(todoMaps);

    // Save to SharedPreferences
    await prefs.setString('todos', todosJson);
  }

  // Load todos from SharedPreferences
  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();

    // Get the JSON string from SharedPreferences
    final todosJson = prefs.getString('todos');

    if (todosJson != null) {
      try {
        // Decode the JSON string
        final todoMaps = json.decode(todosJson) as List;

        // Convert the list of maps to a list of Todo objects
        final todos =
            todoMaps
                .map((map) => Todo.fromMap(Map<String, dynamic>.from(map)))
                .toList();

        setState(() {
          _todos = todos;
        });
      } catch (e) {
        // Handle error (e.g., invalid JSON)
        debugPrint('Error loading todos: $e');
      }
    }
  }

  // Toggle search bar
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with search functionality
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search tasks...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                )
                : const Text(
                  'Todo App',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        centerTitle: !_isSearching,
        leading:
            _isSearching
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _toggleSearch,
                )
                : null,
        actions: [
          // Search button
          IconButton(
            icon: Icon(_isSearching ? Icons.clear : Icons.search),
            tooltip: _isSearching ? 'Clear search' : 'Search tasks',
            onPressed: _toggleSearch,
          ),
          // Filter button
          IconButton(
            icon: Icon(
              _showCompleted ? Icons.visibility : Icons.visibility_off,
            ),
            tooltip: _showCompleted ? 'Hide completed' : 'Show completed',
            onPressed: () {
              setState(() {
                _showCompleted = !_showCompleted;
              });
            },
          ),
          // More options menu
          PopupMenuButton(
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'deleteCompleted',
                    child: const Text('Delete completed tasks'),
                    onTap: () {
                      // Count completed tasks before deleting
                      final completedCount =
                          _todos.where((todo) => todo.isCompleted).length;

                      if (completedCount > 0) {
                        setState(() {
                          _todos.removeWhere((todo) => todo.isCompleted);
                        });
                        _saveTodos();

                        // Show confirmation message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$completedCount completed task(s) deleted',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  PopupMenuItem(
                    value: 'sortByDate',
                    child: const Text('Sort by date (newest first)'),
                    onTap: () {
                      setState(() {
                        _todos.sort(
                          (a, b) => b.createdAt.compareTo(a.createdAt),
                        );
                      });
                      _saveTodos();
                    },
                  ),
                  PopupMenuItem(
                    value: 'sortByName',
                    child: const Text('Sort by name'),
                    onTap: () {
                      setState(() {
                        _todos.sort((a, b) => a.title.compareTo(b.title));
                      });
                      _saveTodos();
                    },
                  ),
                ],
          ),
        ],
      ),

      // Side drawer with close button
      drawer: Drawer(
        child: Column(
          children: [
            // Drawer header with app name and close button
            Container(
              color: Theme.of(context).primaryColor,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                bottom: 16,
              ),
              width: double.infinity,
              child: Column(
                children: [
                  // Close button and app name row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Menu',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        // Close drawer button
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Close menu',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // App logo
                  const Icon(
                    Icons.check_circle_outline,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  // App name
                  const Text(
                    'Todo App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Drawer items
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text(
                'Home',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(
                'About Me',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                launchUrl(Uri.parse('https://olivier-ira.vercel.app/'));
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text(
                'Contact Me',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                launchUrl(Uri.parse('mailto:oiradukunda63@gmail.com'));
                Navigator.pop(context); // Close drawer
              },
            ),
            const Divider(),

            // Statistics
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistics',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  // Statistics cards in a row
                  Row(
                    children: [
                      _buildStatCard(
                        'Total',
                        _todos.length.toString(),
                        Icons.list,
                        Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _buildStatCard(
                        'Done',
                        _todos
                            .where((todo) => todo.isCompleted)
                            .length
                            .toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _buildStatCard(
                        'Pending',
                        _todos
                            .where((todo) => !todo.isCompleted)
                            .length
                            .toString(),
                        Icons.pending_actions,
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // App version at the bottom
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),

      // Main content - TodoList
      body:
          _filteredTodos.isEmpty && _searchQuery.isNotEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 70, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No results found',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try a different search term',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : TodoList(
                todos: _filteredTodos,
                onTodoToggle: _toggleTodo,
                onTodoDelete: _deleteTodo,
                onTodoEdit: (todo) => _showAddTodoBottomSheet(todoToEdit: todo),
                onTodoView: _viewTodoDetails,
              ),

      // Floating action button to add a new todo
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoBottomSheet(),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Helper method to build statistics cards
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
