import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/supabase_service.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  Future<List<User>>? _usersFuture;

  final List<String> _filters = [
    'All',
    'Active',
    'Inactive',
    'Admin',
    'Premium'
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = _getUsersWithDelay();
    });
  }

  Future<List<User>> _getUsersWithDelay() async {
    // Add a small delay to ensure database has updated
    await Future.delayed(const Duration(milliseconds: 500));
    final users = await SupabaseService.getAllUsers();

    return users;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Users Management',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Manage user accounts and permissions',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _loadUsers,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh Users',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _showAddUserDialog,
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add User'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Search Bar
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search users by name or email...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Filter Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    underline: const SizedBox(),
                    items: _filters.map((String filter) {
                      return DropdownMenuItem<String>(
                        value: filter,
                        child: Text(filter),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFilter = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Users List
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final users = snapshot.data ?? [];
                final filteredUsers = _filterUsers(users);

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No users found',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Try adjusting your search or filters',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _buildUserCard(user, theme);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<User> _filterUsers(List<User> users) {
    return users.where((user) {
      final name = user.name.toLowerCase();
      final email = user.email.toLowerCase();
      final isActive = user.isActive;

      // Search filter
      if (_searchQuery.isNotEmpty) {
        if (!name.contains(_searchQuery.toLowerCase()) &&
            !email.contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

      // Status filter
      if (_selectedFilter == 'Active' && !isActive) {
        return false;
      }
      if (_selectedFilter == 'Inactive' && isActive) {
        return false;
      }
      if (_selectedFilter == 'Admin' && !user.isAdmin) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _buildUserCard(User user, ThemeData theme) {
    final name = user.name;
    final email = user.email;
    final isActive = user.isActive;
    final createdAt = user.createdAt;

    final roles = user.roles;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: TextStyle(
                color: AppTheme.primaryTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Display roles
                    ...roles.map((role) => Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getRoleColor(role).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            role.toString().split('.').last.toUpperCase(),
                            style: TextStyle(
                              color: _getRoleColor(role),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: isActive ? Colors.green : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Joined: ${_formatDate(createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          PopupMenuButton<String>(
            onSelected: (value) => _handleUserAction(value, user),
            itemBuilder: (context) {
              final isAdmin = user.roles.contains(UserRole.admin);
              final isCurrentUser =
                  user.id == SupabaseService.getCurrentUser()?.id;

              return [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                // Show Suspend/Activate based on user status
                if (user.isActive)
                  const PopupMenuItem(
                    value: 'suspend',
                    child: Row(
                      children: [
                        Icon(Icons.block, size: 16),
                        SizedBox(width: 8),
                        Text('Suspend'),
                      ],
                    ),
                  )
                else
                  const PopupMenuItem(
                    value: 'activate',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 16),
                        SizedBox(width: 8),
                        Text('Activate'),
                      ],
                    ),
                  ),
                // Only show delete for non-admin users and not current user
                if (!isAdmin && !isCurrentUser)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ];
            },
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleUserAction(String action, User user) {
    switch (action) {
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'suspend':
        _showSuspendUserDialog(user);
        break;
      case 'activate':
        _activateUser(user);
        break;
      case 'delete':
        _showDeleteUserDialog(user);
        break;
    }
  }

  void _showAddUserDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddUserDialog(
        onUserCreated: _loadUsers,
      ),
    );

    // If user was created successfully, refresh the list
    if (result == true) {
      print('🔄 User created successfully via Supabase Edge Function!');

      // Call the callback to refresh the users list
      _loadUsers();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showEditUserDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(
        user: user,
        onUserUpdated: _loadUsers,
      ),
    );
  }

  void _showSuspendUserDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend User'),
        content: Text('Are you sure you want to suspend ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _suspendUser(user);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
            'Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteUser(user);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(User user) async {
    try {
      print('🔄 Deleting user: ${user.name} (${user.id})');

      // Call Supabase Edge Function to delete user
      final result = await SupabaseService.deleteUser(userId: user.id);

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User deleted successfully')),
          );
          // Refresh the users list
          setState(() {
            _usersFuture = _getUsersWithDelay();
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to delete user: ${result['error'] ?? 'Unknown error'}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting user: $e')),
        );
      }
    }
  }

  Future<void> _suspendUser(User user) async {
    try {
      // Prepare the updates to suspend the user
      final updates = {
        'is_active': false,
      };

      // Call Supabase Edge Function to update user
      final result = await SupabaseService.updateUser(
        userId: user.id,
        updates: updates,
      );

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User suspended successfully')),
          );
          // Refresh the users list
          setState(() {
            _usersFuture = _getUsersWithDelay();
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to suspend user: ${result['error'] ?? 'Unknown error'}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error suspending user: $e')),
        );
      }
    }
  }

  Future<void> _activateUser(User user) async {
    try {
      // Prepare the updates to activate the user
      final updates = {
        'is_active': true,
      };

      // Call Supabase Edge Function to update user
      final result = await SupabaseService.updateUser(
        userId: user.id,
        updates: updates,
      );

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User activated successfully')),
          );
          // Refresh the users list
          setState(() {
            _usersFuture = _getUsersWithDelay();
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to activate user: ${result['error'] ?? 'Unknown error'}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error activating user: $e')),
        );
      }
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.travelAgent:
        return Colors.blue;
      case UserRole.editor:
        return Colors.orange;
      case UserRole.contentEditor:
        return Colors.purple;
      case UserRole.traveler:
        return Colors.green;
    }
  }
}

class AddUserDialog extends StatefulWidget {
  final VoidCallback? onUserCreated;

  const AddUserDialog({super.key, this.onUserCreated});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final Set<UserRole> _selectedRoles = {UserRole.traveler};
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New User'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Role Selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Roles',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: UserRole.values.map((role) {
                    final isSelected = _selectedRoles.contains(role);
                    return FilterChip(
                      label: Text(role
                          .toString()
                          .split('.')
                          .last
                          .replaceAll('_', ' ')
                          .toUpperCase()),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedRoles.add(role);
                          } else {
                            _selectedRoles.remove(role);
                          }
                          // Ensure at least one role is selected
                          if (_selectedRoles.isEmpty) {
                            _selectedRoles.add(UserRole.traveler);
                          }
                        });
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: _getRoleColor(role).withOpacity(0.2),
                      checkmarkColor: _getRoleColor(role),
                      labelStyle: TextStyle(
                        color:
                            isSelected ? _getRoleColor(role) : Colors.grey[700],
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleAddUser,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add User'),
        ),
      ],
    );
  }

  Future<void> _handleAddUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        final email = _emailController.text.trim();
        final password = _passwordController.text;
        final name = _nameController.text.trim();

        // Create user via Supabase Edge Function
        final success = await _createCustomUser(email, password, name);

        if (success) {
          Navigator.of(context).pop(true); // Return true to indicate success
        } else {
          throw Exception('Failed to create user');
        }
      } catch (e) {
        print('Error creating user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating user: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _createCustomUser(
      String email, String password, String name) async {
    try {
      print('🔄 Creating user via Supabase Edge Function...');

      // Call Supabase Edge Function to create user
      final result = await SupabaseService.createUser(
        email: email,
        password: password,
        name: name,
        roles: _selectedRoles.toList(),
        photoUrl: null,
      );

      if (result['success'] == true) {
        print('✅ User created successfully via Supabase Edge Function!');
        print('🔍 Full result: $result');

        final userData = result['user'];
        print('🔍 User data: $userData');

        if (userData != null) {
          print('📧 Email: ${userData['email']}');
          print('👤 Name: ${userData['name']}');
          print('🆔 UID: ${userData['id']}');
          print('🔑 Roles: ${userData['roles']}');

          // Safe handling of roles
          final roles = userData['roles'];
          if (roles != null && roles is List) {
            print('🔑 Roles (joined): ${roles.join(', ')}');
          } else {
            print('🔑 Roles: ${roles ?? 'null'}');
          }
        } else {
          print(
              '⚠️ User data is null - checking alternative response structure');
          // Check if data is directly in result
          print('📧 Email: ${result['email']}');
          print('👤 Name: ${result['name']}');
          print('🆔 UID: ${result['id']}');
          print('🔑 Roles: ${result['roles']}');
        }

        // No session change - admin stays logged in!
        print('✅ Admin session remains intact');

        return true;
      } else {
        print('❌ User creation failed via Supabase Edge Function');
        return false;
      }
    } catch (e) {
      print('❌ Error creating custom user: $e');
      rethrow;
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.travelAgent:
        return Colors.blue;
      case UserRole.editor:
        return Colors.orange;
      case UserRole.contentEditor:
        return Colors.purple;
      case UserRole.traveler:
        return Colors.green;
    }
  }
}

class EditUserDialog extends StatefulWidget {
  final User user;
  final VoidCallback? onUserUpdated;

  const EditUserDialog({super.key, required this.user, this.onUserUpdated});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late Set<UserRole> _selectedRoles;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _selectedRoles = Set.from(widget.user.roles);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit User'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Role Selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Roles',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: UserRole.values.map((role) {
                    final isSelected = _selectedRoles.contains(role);
                    return FilterChip(
                      label: Text(role
                          .toString()
                          .split('.')
                          .last
                          .replaceAll('_', ' ')
                          .toUpperCase()),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedRoles.add(role);
                          } else {
                            _selectedRoles.remove(role);
                          }
                          // Ensure at least one role is selected
                          if (_selectedRoles.isEmpty) {
                            _selectedRoles.add(UserRole.traveler);
                          }
                        });
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: _getRoleColor(role).withOpacity(0.2),
                      checkmarkColor: _getRoleColor(role),
                      labelStyle: TextStyle(
                        color:
                            isSelected ? _getRoleColor(role) : Colors.grey[700],
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleEditUser,
          child: const Text('Save Changes'),
        ),
      ],
    );
  }

  void _handleEditUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        print('🔄 Updating user via Supabase Edge Function...');

        // Prepare the updates
        final updates = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'roles': _selectedRoles
              .map((role) => role.toString().split('.').last)
              .toList(),
        };

        print('📝 Updates: $updates');

        // Call Supabase Edge Function to update user
        final result = await SupabaseService.updateUser(
          userId: widget.user.id,
          updates: updates,
        );

        if (result['success'] == true) {
          print('✅ User updated successfully via Supabase Edge Function!');
          Navigator.of(context).pop();
          // Call the callback to refresh the users list
          widget.onUserUpdated?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User updated successfully')),
          );
        } else {
          print('❌ User update failed via Supabase Edge Function');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to update user: ${result['error'] ?? 'Unknown error'}')),
          );
        }
      } catch (e) {
        print('❌ Error updating user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating user: $e')),
        );
      }
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.travelAgent:
        return Colors.blue;
      case UserRole.editor:
        return Colors.orange;
      case UserRole.contentEditor:
        return Colors.purple;
      case UserRole.traveler:
        return Colors.green;
    }
  }
}
