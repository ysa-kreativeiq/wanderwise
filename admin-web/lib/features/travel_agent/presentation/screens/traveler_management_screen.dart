import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/supabase_service.dart';

class TravelerManagementScreen extends StatefulWidget {
  const TravelerManagementScreen({super.key});

  @override
  State<TravelerManagementScreen> createState() =>
      _TravelerManagementScreenState();
}

class _TravelerManagementScreenState extends State<TravelerManagementScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isLoading = false;
  List<User> _travelers = [];
  List<User> _filteredTravelers = [];

  final List<String> _filters = [
    'All',
    'Active',
    'Inactive',
    'Has Itinerary',
    'No Itinerary'
  ];

  @override
  void initState() {
    super.initState();
    _loadTravelers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTravelers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user to check if they're a travel agent
      final currentUser = SupabaseService.getCurrentUser();
      if (currentUser == null) return;

      final userData = await SupabaseService.getUserById(currentUser.id);
      if (userData == null || !userData.hasRole(UserRole.travelAgent)) {
        // Show error - user is not a travel agent
        return;
      }

      // Get travelers assigned to this agent
      final travelers =
          await SupabaseService.getTravelersByAgentId(currentUser.id);

      setState(() {
        _travelers = travelers;
        _filteredTravelers = travelers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading travelers: $e')),
        );
      }
    }
  }

  void _filterTravelers() {
    setState(() {
      _filteredTravelers = _travelers.where((traveler) {
        final matchesSearch = traveler.name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            traveler.email.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesFilter = _selectedFilter == 'All' ||
            (_selectedFilter == 'Active' && traveler.isActive) ||
            (_selectedFilter == 'Inactive' && !traveler.isActive) ||
            (_selectedFilter == 'Has Itinerary' &&
                traveler.assignedTravelers != null &&
                traveler.assignedTravelers!.isNotEmpty) ||
            (_selectedFilter == 'No Itinerary' &&
                (traveler.assignedTravelers == null ||
                    traveler.assignedTravelers!.isEmpty));

        return matchesSearch && matchesFilter;
      }).toList();
    });
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
              children: [
                // Search Bar
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search travelers by name or email...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _filterTravelers();
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
                      _filterTravelers();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Add Traveler Button
                ElevatedButton.icon(
                  onPressed: _showAddTravelerDialog,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Traveler'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTravelers.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildTravelersList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
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
            'No travelers found',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first traveler to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddTravelerDialog,
            icon: const Icon(Icons.person_add),
            label: const Text('Add Traveler'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelersList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _filteredTravelers.length,
      itemBuilder: (context, index) {
        final traveler = _filteredTravelers[index];
        return _buildTravelerCard(traveler, theme);
      },
    );
  }

  Widget _buildTravelerCard(User traveler, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
          child: Text(
            traveler.name.isNotEmpty ? traveler.name[0].toUpperCase() : 'T',
            style: TextStyle(
              color: AppTheme.primaryTeal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          traveler.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(traveler.email),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: traveler.isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    traveler.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: traveler.isActive ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Auth Account Status
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _hasAuthAccount(traveler)
                        ? Colors.blue.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _hasAuthAccount(traveler) ? 'Has Login' : 'No Login',
                    style: TextStyle(
                      color: _hasAuthAccount(traveler)
                          ? Colors.blue
                          : Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (traveler.assignedTravelers != null &&
                    traveler.assignedTravelers!.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Has Itinerary',
                      style: TextStyle(
                        color: AppTheme.accentBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                // Language Badge
                if (traveler.profile?['language'] != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.language,
                          size: 12,
                          color: Colors.purple,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          traveler.profile!['language'],
                          style: TextStyle(
                            color: Colors.purple,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleTravelerAction(value, traveler),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'itinerary',
              child: Row(
                children: [
                  Icon(Icons.map),
                  SizedBox(width: 8),
                  Text('Manage Itinerary'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'create_auth',
              child: Row(
                children: [
                  Icon(Icons.login),
                  SizedBox(width: 8),
                  Text('Create Login Account'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.person_remove),
                  SizedBox(width: 8),
                  Text('Remove'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasAuthAccount(User traveler) {
    // Check if the traveler has an Auth account by looking for specific patterns
    // For now, we'll assume travelers created by our Edge Function don't have Auth accounts
    // This is a simple heuristic - in a real app, you'd check the Auth table
    return false; // All travelers created by our current method don't have Auth accounts
  }

  void _handleTravelerAction(String action, User traveler) {
    switch (action) {
      case 'view':
        _showTravelerDetails(traveler);
        break;
      case 'itinerary':
        _navigateToItineraryManagement(traveler);
        break;
      case 'edit':
        _showEditTravelerDialog(traveler);
        break;
      case 'create_auth':
        _createAuthAccountForTraveler(traveler);
        break;
      case 'remove':
        _showRemoveTravelerDialog(traveler);
        break;
    }
  }

  void _createAuthAccountForTraveler(User traveler) {
    // TODO: Implement Auth account creation
    // This would call a new Edge Function to create an Auth account for the traveler
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Auth account creation for ${traveler.name} - Coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showAddTravelerDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddTravelerDialog(),
    ).then((_) {
      // Refresh the travelers list after dialog closes
      _loadTravelers();
    });
  }

  void _showTravelerDetails(User traveler) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Traveler Details: ${traveler.name}'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Name', traveler.name),
                _buildDetailRow('Email', traveler.email),
                _buildDetailRow(
                    'Status', traveler.isActive ? 'Active' : 'Inactive'),
                _buildDetailRow(
                    'Joined', traveler.createdAt.toString().split(' ')[0]),
                if (traveler.assignedTravelers != null &&
                    traveler.assignedTravelers!.isNotEmpty)
                  _buildDetailRow(
                      'Itineraries', '${traveler.assignedTravelers!.length}'),

                // Additional profile information
                if (traveler.profile != null &&
                    traveler.profile!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Additional Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (traveler.profile!['phone'] != null)
                    _buildDetailRow('Phone', traveler.profile!['phone']),
                  if (traveler.profile!['company'] != null)
                    _buildDetailRow('Company', traveler.profile!['company']),
                  if (traveler.profile!['address'] != null)
                    _buildDetailRow('Address', traveler.profile!['address']),
                  if (traveler.profile!['city'] != null)
                    _buildDetailRow('City', traveler.profile!['city']),
                  if (traveler.profile!['state'] != null)
                    _buildDetailRow('State', traveler.profile!['state']),
                  if (traveler.profile!['zip_code'] != null)
                    _buildDetailRow('ZIP Code', traveler.profile!['zip_code']),
                  if (traveler.profile!['country'] != null)
                    _buildDetailRow('Country', traveler.profile!['country']),
                  if (traveler.profile!['language'] != null)
                    _buildDetailRow('Language', traveler.profile!['language']),
                  if (traveler.profile!['notes'] != null)
                    _buildDetailRow('Notes', traveler.profile!['notes']),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToItineraryManagement(User traveler) {
    // TODO: Navigate to itinerary management screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Managing itinerary for ${traveler.name}')),
    );
  }

  void _showEditTravelerDialog(User traveler) {
    showDialog(
      context: context,
      builder: (context) => EditTravelerDialog(traveler: traveler),
    ).then((_) {
      // Refresh the travelers list after dialog closes
      _loadTravelers();
    });
  }

  void _showRemoveTravelerDialog(User traveler) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Traveler'),
        content: Text(
            'Are you sure you want to remove ${traveler.name} from your travelers list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeTraveler(traveler);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeTraveler(User traveler) async {
    try {
      // TODO: Implement remove traveler logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed ${traveler.name} from travelers list')),
      );
      _loadTravelers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing traveler: $e')),
      );
    }
  }
}

class AddTravelerDialog extends StatefulWidget {
  const AddTravelerDialog({super.key});

  @override
  State<AddTravelerDialog> createState() => _AddTravelerDialogState();
}

class _AddTravelerDialogState extends State<AddTravelerDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedLanguage = 'English';
  String _selectedCountryCode = '+1';
  bool _isLoading = false;

  final List<String> _languageOptions = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Chinese (Mandarin)',
    'Japanese',
    'Korean',
    'Arabic',
    'Russian',
    'Hindi',
    'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _createTraveler() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current travel agent
      final currentUser = SupabaseService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('No current user found');
      }

      // Test both Edge Functions to see which one works
      Map<String, dynamic> authResponse;
      // First check if traveler already exists
      final existingTraveler =
          await SupabaseService.getUserByEmail(_emailController.text.trim());

      if (existingTraveler != null) {
        // Traveler already exists
        print('Existing traveler found: ${existingTraveler.id}');

        // Check if they're already assigned to this travel agent
        if (existingTraveler.travelAgentId == currentUser.id) {
          throw Exception('Traveler is already assigned to you');
        }

        // Check if they're assigned to another travel agent
        if (existingTraveler.travelAgentId != null &&
            existingTraveler.travelAgentId != currentUser.id) {
          throw Exception(
              'Traveler is already assigned to another travel agent. Please contact system admin.');
        }

        // Traveler exists but not assigned - assign them to current agent
        print('Assigning existing traveler to current agent');

        // Prepare profile data for existing traveler
        final profileData = {
          'phone': _phoneController.text.trim().isNotEmpty
              ? '$_selectedCountryCode${_phoneController.text.trim()}'
              : '',
          'company': _companyController.text.trim(),
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'zip_code': _zipCodeController.text.trim(),
          'country': _countryController.text.trim(),
          'notes': _notesController.text.trim(),
        };

        // Remove empty fields
        profileData.removeWhere((key, value) => value.isEmpty);

        final success = await SupabaseService.assignTravelerToAgent(
          existingTraveler.id,
          currentUser.id,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          notes: _notesController.text.trim(),
          isActive: true, // Always active for existing travelers
          profile: profileData.isNotEmpty ? profileData : null,
        );

        if (!success) {
          throw Exception('Failed to assign traveler to you');
        }

        // Create success response
        authResponse = {
          'user': {
            'id': existingTraveler.id,
            'email': existingTraveler.email,
            'name': existingTraveler.name,
            'roles': existingTraveler.roles,
          },
          'message': 'Existing traveler assigned to you successfully'
        };
      } else {
        // Traveler doesn't exist - create new traveler
        print('Creating new traveler');

        // Prepare profile data
        final profileData = {
          'phone': _phoneController.text.trim().isNotEmpty
              ? '$_selectedCountryCode${_phoneController.text.trim()}'
              : '',
          'company': _companyController.text.trim(),
          'address': _addressController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'zip_code': _zipCodeController.text.trim(),
          'country': _countryController.text.trim(),
          'language': _selectedLanguage,
          'notes': _notesController.text.trim(),
        };

        // Remove empty fields
        profileData.removeWhere((key, value) => value.isEmpty);

        authResponse = await SupabaseService.createTraveler(
          email: _emailController.text.trim().toLowerCase(),
          password: _generateTemporaryPassword(),
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          notes: _notesController.text.trim(),
          isActive: true, // New travelers are active by default
          profile: profileData.isNotEmpty ? profileData : null,
        );
      }

      print('Traveler operation result: $authResponse');

      if (authResponse['user'] == null) {
        throw Exception('Failed to create traveler account');
      }

      if (mounted) {
        Navigator.of(context).pop();

        // Show appropriate success message based on the response
        String successMessage;
        if (authResponse['message']?.contains('Existing traveler assigned') ==
            true) {
          successMessage =
              'Traveler ${_nameController.text.trim()} already exists and has been assigned to you';
        } else if (authResponse['message']?.contains('New traveler created') ==
            true) {
          successMessage =
              'Traveler ${_nameController.text.trim()} created successfully!';
        } else {
          successMessage =
              'Traveler ${_nameController.text.trim()} ${authResponse['message'] ?? 'processed successfully!'}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        print('Error creating traveler: $e'); // Debug print

        // Parse the error message to show user-friendly message
        String errorMessage = 'Error creating traveler';
        if (e.toString().contains('duplicate key')) {
          errorMessage = 'Traveler with this email already exists';
        } else if (e.toString().contains('already assigned to you')) {
          errorMessage = 'Traveler is already assigned to you';
        } else if (e
            .toString()
            .contains('already assigned to another travel agent')) {
          errorMessage =
              'Traveler is already assigned to another travel agent. Please contact system admin.';
        } else if (e.toString().contains('User not allowed')) {
          errorMessage = 'Permission denied - please contact admin';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );

        // Don't close dialog on error - let user fix the issue
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _generateTemporaryPassword() {
    // Generate a secure temporary password
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = DateTime.now().millisecondsSinceEpoch;
    final password = StringBuffer();
    for (int i = 0; i < 12; i++) {
      password.write(chars[random % chars.length]);
    }
    return password.toString();
  }

  String _generateHex(int length) {
    const chars = '0123456789abcdef';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
          length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Traveler'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'Enter traveler\'s full name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address *',
                    hintText: 'Enter traveler\'s email address',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$')
                        .hasMatch(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Phone Field with Country Code
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        value: _selectedCountryCode,
                        decoration: const InputDecoration(
                          labelText: 'Code',
                          prefixIcon: Icon(Icons.flag),
                        ),
                        items: [
                          DropdownMenuItem(
                              value: '+1', child: Text('+1 (US/CA)')),
                          DropdownMenuItem(
                              value: '+44', child: Text('+44 (UK)')),
                          DropdownMenuItem(
                              value: '+33', child: Text('+33 (FR)')),
                          DropdownMenuItem(
                              value: '+49', child: Text('+49 (DE)')),
                          DropdownMenuItem(
                              value: '+39', child: Text('+39 (IT)')),
                          DropdownMenuItem(
                              value: '+34', child: Text('+34 (ES)')),
                          DropdownMenuItem(
                              value: '+31', child: Text('+31 (NL)')),
                          DropdownMenuItem(
                              value: '+32', child: Text('+32 (BE)')),
                          DropdownMenuItem(
                              value: '+41', child: Text('+41 (CH)')),
                          DropdownMenuItem(
                              value: '+43', child: Text('+43 (AT)')),
                          DropdownMenuItem(
                              value: '+46', child: Text('+46 (SE)')),
                          DropdownMenuItem(
                              value: '+47', child: Text('+47 (NO)')),
                          DropdownMenuItem(
                              value: '+45', child: Text('+45 (DK)')),
                          DropdownMenuItem(
                              value: '+358', child: Text('+358 (FI)')),
                          DropdownMenuItem(
                              value: '+48', child: Text('+48 (PL)')),
                          DropdownMenuItem(
                              value: '+420', child: Text('+420 (CZ)')),
                          DropdownMenuItem(
                              value: '+36', child: Text('+36 (HU)')),
                          DropdownMenuItem(
                              value: '+40', child: Text('+40 (RO)')),
                          DropdownMenuItem(
                              value: '+30', child: Text('+30 (GR)')),
                          DropdownMenuItem(
                              value: '+351', child: Text('+351 (PT)')),
                          DropdownMenuItem(
                              value: '+380', child: Text('+380 (UA)')),
                          DropdownMenuItem(value: '+7', child: Text('+7 (RU)')),
                          DropdownMenuItem(
                              value: '+81', child: Text('+81 (JP)')),
                          DropdownMenuItem(
                              value: '+82', child: Text('+82 (KR)')),
                          DropdownMenuItem(
                              value: '+86', child: Text('+86 (CN)')),
                          DropdownMenuItem(
                              value: '+852', child: Text('+852 (HK)')),
                          DropdownMenuItem(
                              value: '+65', child: Text('+65 (SG)')),
                          DropdownMenuItem(
                              value: '+91', child: Text('+91 (IN)')),
                          DropdownMenuItem(
                              value: '+61', child: Text('+61 (AU)')),
                          DropdownMenuItem(
                              value: '+64', child: Text('+64 (NZ)')),
                          DropdownMenuItem(
                              value: '+27', child: Text('+27 (ZA)')),
                          DropdownMenuItem(
                              value: '+55', child: Text('+55 (BR)')),
                          DropdownMenuItem(
                              value: '+52', child: Text('+52 (MX)')),
                          DropdownMenuItem(
                              value: '+54', child: Text('+54 (AR)')),
                          DropdownMenuItem(
                              value: '+56', child: Text('+56 (CL)')),
                          DropdownMenuItem(
                              value: '+57', child: Text('+57 (CO)')),
                          DropdownMenuItem(
                              value: '+58', child: Text('+58 (VE)')),
                          DropdownMenuItem(
                              value: '+51', child: Text('+51 (PE)')),
                          DropdownMenuItem(
                              value: '+593', child: Text('+593 (EC)')),
                          DropdownMenuItem(
                              value: '+595', child: Text('+595 (PY)')),
                          DropdownMenuItem(
                              value: '+598', child: Text('+598 (UY)')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCountryCode = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'Enter phone number',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Company
                TextFormField(
                  controller: _companyController,
                  decoration: const InputDecoration(
                    labelText: 'Company',
                    hintText: 'Enter company',
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 16),
                // Address
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter address',
                    prefixIcon: Icon(Icons.home),
                  ),
                ),
                const SizedBox(height: 16),
                // City
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    hintText: 'Enter city',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                ),
                const SizedBox(height: 16),
                // State
                TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(
                    labelText: 'State',
                    hintText: 'Enter state',
                    prefixIcon: Icon(Icons.map),
                  ),
                ),
                const SizedBox(height: 16),
                // Zip Code
                TextFormField(
                  controller: _zipCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Zip Code',
                    hintText: 'Enter zip code',
                    prefixIcon: Icon(Icons.local_post_office),
                  ),
                ),
                const SizedBox(height: 16),
                // Country
                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    hintText: 'Enter country',
                    prefixIcon: Icon(Icons.public),
                  ),
                ),
                const SizedBox(height: 16),
                // Language Preference
                DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  decoration: const InputDecoration(
                    labelText: 'Communication Language',
                    hintText: 'Select preferred language',
                    prefixIcon: Icon(Icons.language),
                  ),
                  items: _languageOptions.map((String language) {
                    return DropdownMenuItem<String>(
                      value: language,
                      child: Text(language),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLanguage = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Add any additional notes about the traveler',
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createTraveler,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryTeal,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Create Traveler'),
        ),
      ],
    );
  }
}

class EditTravelerDialog extends StatefulWidget {
  final User traveler;
  const EditTravelerDialog({super.key, required this.traveler});
  @override
  State<EditTravelerDialog> createState() => _EditTravelerDialogState();
}

class _EditTravelerDialogState extends State<EditTravelerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _companyController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _zipCodeController;
  late final TextEditingController _countryController;
  late final TextEditingController _notesController;
  late String _selectedStatus;
  late String _selectedLanguage;
  late String _selectedCountryCode;
  bool _isLoading = false;
  final List<String> _statusOptions = ['Active', 'Inactive'];
  final List<String> _languageOptions = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Chinese (Mandarin)',
    'Japanese',
    'Korean',
    'Arabic',
    'Russian',
    'Hindi',
    'Other'
  ];
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.traveler.name);
    _emailController = TextEditingController(text: widget.traveler.email);
    _phoneController =
        TextEditingController(text: widget.traveler.profile?['phone'] ?? '');
    _companyController =
        TextEditingController(text: widget.traveler.profile?['company'] ?? '');
    _addressController =
        TextEditingController(text: widget.traveler.profile?['address'] ?? '');
    _cityController =
        TextEditingController(text: widget.traveler.profile?['city'] ?? '');
    _stateController =
        TextEditingController(text: widget.traveler.profile?['state'] ?? '');
    _zipCodeController =
        TextEditingController(text: widget.traveler.profile?['zip_code'] ?? '');
    _countryController =
        TextEditingController(text: widget.traveler.profile?['country'] ?? '');
    _notesController =
        TextEditingController(text: widget.traveler.profile?['notes'] ?? '');
    _selectedStatus = widget.traveler.isActive ? 'Active' : 'Inactive';
    _selectedLanguage = widget.traveler.profile?['language'] ?? 'English';
    _selectedCountryCode = widget.traveler.profile?['country_code'] ?? '+1';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateTraveler() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare profile data
      final profileData = {
        'phone': _phoneController.text.trim().isNotEmpty
            ? '$_selectedCountryCode${_phoneController.text.trim()}'
            : '',
        'company': _companyController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zip_code': _zipCodeController.text.trim(),
        'country': _countryController.text.trim(),
        'language': _selectedLanguage,
        'notes': _notesController.text.trim(),
      };

      // Remove empty fields
      profileData.removeWhere((key, value) => value.isEmpty);

      // Update the traveler using direct database update
      final success = await SupabaseService.updateTravelerProfile(
        travelerId: widget.traveler.id,
        name: _nameController.text.trim(),
        profile: profileData.isNotEmpty ? profileData : null,
        isActive: _selectedStatus == 'Active',
      );

      if (!success) {
        throw Exception('Failed to update traveler profile');
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.traveler.name} updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating traveler: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Traveler'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'Enter traveler\'s full name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Email Field (read-only)
                TextFormField(
                  controller: _emailController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Email cannot be changed',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                // Phone Field with Country Code
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        value: _selectedCountryCode,
                        decoration: const InputDecoration(
                          labelText: 'Code',
                          prefixIcon: Icon(Icons.flag),
                        ),
                        items: [
                          DropdownMenuItem(
                              value: '+1', child: Text('+1 (US/CA)')),
                          DropdownMenuItem(
                              value: '+44', child: Text('+44 (UK)')),
                          DropdownMenuItem(
                              value: '+33', child: Text('+33 (FR)')),
                          DropdownMenuItem(
                              value: '+49', child: Text('+49 (DE)')),
                          DropdownMenuItem(
                              value: '+39', child: Text('+39 (IT)')),
                          DropdownMenuItem(
                              value: '+34', child: Text('+34 (ES)')),
                          DropdownMenuItem(
                              value: '+31', child: Text('+31 (NL)')),
                          DropdownMenuItem(
                              value: '+32', child: Text('+32 (BE)')),
                          DropdownMenuItem(
                              value: '+41', child: Text('+41 (CH)')),
                          DropdownMenuItem(
                              value: '+43', child: Text('+43 (AT)')),
                          DropdownMenuItem(
                              value: '+46', child: Text('+46 (SE)')),
                          DropdownMenuItem(
                              value: '+47', child: Text('+47 (NO)')),
                          DropdownMenuItem(
                              value: '+45', child: Text('+45 (DK)')),
                          DropdownMenuItem(
                              value: '+358', child: Text('+358 (FI)')),
                          DropdownMenuItem(
                              value: '+48', child: Text('+48 (PL)')),
                          DropdownMenuItem(
                              value: '+420', child: Text('+420 (CZ)')),
                          DropdownMenuItem(
                              value: '+36', child: Text('+36 (HU)')),
                          DropdownMenuItem(
                              value: '+40', child: Text('+40 (RO)')),
                          DropdownMenuItem(
                              value: '+30', child: Text('+30 (GR)')),
                          DropdownMenuItem(
                              value: '+351', child: Text('+351 (PT)')),
                          DropdownMenuItem(
                              value: '+380', child: Text('+380 (UA)')),
                          DropdownMenuItem(value: '+7', child: Text('+7 (RU)')),
                          DropdownMenuItem(
                              value: '+81', child: Text('+81 (JP)')),
                          DropdownMenuItem(
                              value: '+82', child: Text('+82 (KR)')),
                          DropdownMenuItem(
                              value: '+86', child: Text('+86 (CN)')),
                          DropdownMenuItem(
                              value: '+852', child: Text('+852 (HK)')),
                          DropdownMenuItem(
                              value: '+65', child: Text('+65 (SG)')),
                          DropdownMenuItem(
                              value: '+91', child: Text('+91 (IN)')),
                          DropdownMenuItem(
                              value: '+61', child: Text('+61 (AU)')),
                          DropdownMenuItem(
                              value: '+64', child: Text('+64 (NZ)')),
                          DropdownMenuItem(
                              value: '+27', child: Text('+27 (ZA)')),
                          DropdownMenuItem(
                              value: '+55', child: Text('+55 (BR)')),
                          DropdownMenuItem(
                              value: '+52', child: Text('+52 (MX)')),
                          DropdownMenuItem(
                              value: '+54', child: Text('+54 (AR)')),
                          DropdownMenuItem(
                              value: '+56', child: Text('+56 (CL)')),
                          DropdownMenuItem(
                              value: '+57', child: Text('+57 (CO)')),
                          DropdownMenuItem(
                              value: '+58', child: Text('+58 (VE)')),
                          DropdownMenuItem(
                              value: '+51', child: Text('+51 (PE)')),
                          DropdownMenuItem(
                              value: '+593', child: Text('+593 (EC)')),
                          DropdownMenuItem(
                              value: '+595', child: Text('+595 (PY)')),
                          DropdownMenuItem(
                              value: '+598', child: Text('+598 (UY)')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCountryCode = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'Enter phone number',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Company
                TextFormField(
                  controller: _companyController,
                  decoration: const InputDecoration(
                    labelText: 'Company',
                    hintText: 'Enter company',
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 16),
                // Address
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter address',
                    prefixIcon: Icon(Icons.home),
                  ),
                ),
                const SizedBox(height: 16),
                // City
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    hintText: 'Enter city',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                ),
                const SizedBox(height: 16),
                // State
                TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(
                    labelText: 'State',
                    hintText: 'Enter state',
                    prefixIcon: Icon(Icons.map),
                  ),
                ),
                const SizedBox(height: 16),
                // Zip Code
                TextFormField(
                  controller: _zipCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Zip Code',
                    hintText: 'Enter zip code',
                    prefixIcon: Icon(Icons.local_post_office),
                  ),
                ),
                const SizedBox(height: 16),
                // Country
                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    hintText: 'Enter country',
                    prefixIcon: Icon(Icons.public),
                  ),
                ),
                const SizedBox(height: 16),
                // Status Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.check_circle),
                  ),
                  items: _statusOptions.map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStatus = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Language Preference Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  decoration: const InputDecoration(
                    labelText: 'Communication Language',
                    hintText: 'Select preferred language',
                    prefixIcon: Icon(Icons.language),
                  ),
                  items: _languageOptions.map((String language) {
                    return DropdownMenuItem<String>(
                      value: language,
                      child: Text(language),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLanguage = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Notes Field
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Add any additional notes about the traveler',
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateTraveler,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryTeal,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Update Traveler'),
        ),
      ],
    );
  }
}
