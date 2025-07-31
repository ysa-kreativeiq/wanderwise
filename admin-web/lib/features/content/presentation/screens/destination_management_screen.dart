import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class Destination {
  final String id;
  final String name;
  final String description;
  final String country;
  final String? city;
  final String category;
  final List<String> tags;
  final double? latitude;
  final double? longitude;
  final List<String> imageUrls;
  final String? videoUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.country,
    this.city,
    required this.category,
    required this.tags,
    this.latitude,
    this.longitude,
    required this.imageUrls,
    this.videoUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}

class DestinationManagementScreen extends StatefulWidget {
  const DestinationManagementScreen({super.key});

  @override
  State<DestinationManagementScreen> createState() =>
      _DestinationManagementScreenState();
}

class _DestinationManagementScreenState
    extends State<DestinationManagementScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCountry = 'All';
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  bool _isLoading = false;
  List<Destination> _destinations = [];
  List<Destination> _filteredDestinations = [];

  final List<String> _countries = [
    'All',
    'France',
    'Italy',
    'Spain',
    'Germany',
    'United Kingdom',
    'United States',
    'Canada',
    'Japan',
    'Australia',
    'New Zealand',
    'Mexico',
    'Brazil',
    'Thailand',
    'Vietnam',
  ];

  final List<String> _categories = [
    'All',
    'Culture',
    'Nature',
    'Adventure',
    'Food',
    'History',
    'Beach',
    'Mountain',
    'City',
    'Rural',
    'Religious',
    'Entertainment',
  ];

  final List<String> _statuses = [
    'All',
    'Active',
    'Inactive',
  ];

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDestinations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement getDestinations in SupabaseService
      // For now, using mock data
      final destinations = await _getMockDestinations();

      setState(() {
        _destinations = destinations;
        _filteredDestinations = destinations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading destinations: $e')),
        );
      }
    }
  }

  Future<List<Destination>> _getMockDestinations() async {
    // Mock data for development
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();

    return [
      Destination(
        id: '1',
        name: 'Eiffel Tower',
        description:
            'Iconic iron lattice tower on the Champ de Mars in Paris, France. Named after engineer Gustave Eiffel, whose company designed and built the tower.',
        country: 'France',
        city: 'Paris',
        category: 'Culture',
        tags: ['landmark', 'architecture', 'romantic', 'nightlife'],
        latitude: 48.8584,
        longitude: 2.2945,
        imageUrls: [
          'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?w=800',
          'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?w=800',
        ],
        videoUrl: null,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),
      Destination(
        id: '2',
        name: 'Colosseum',
        description:
            'Ancient amphitheater in the center of Rome, Italy. The largest ancient amphitheater ever built, and is still the largest standing amphitheater in the world.',
        country: 'Italy',
        city: 'Rome',
        category: 'History',
        tags: ['ancient', 'architecture', 'gladiator', 'roman'],
        latitude: 41.8902,
        longitude: 12.4922,
        imageUrls: [
          'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800',
        ],
        videoUrl: null,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now,
      ),
      Destination(
        id: '3',
        name: 'Sagrada Familia',
        description:
            'Large unfinished Roman Catholic church in Barcelona, Spain. Designed by Catalan architect Antoni Gaudí.',
        country: 'Spain',
        city: 'Barcelona',
        category: 'Religious',
        tags: ['church', 'gaudi', 'architecture', 'gothic'],
        latitude: 41.4036,
        longitude: 2.1744,
        imageUrls: [
          'https://images.unsplash.com/photo-1583422409516-2895a77efded?w=800',
        ],
        videoUrl: null,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now,
      ),
      Destination(
        id: '4',
        name: 'Mount Fuji',
        description:
            'Japan\'s highest mountain, standing 3,776 meters tall. It is an active stratovolcano that last erupted in 1707.',
        country: 'Japan',
        category: 'Nature',
        tags: ['mountain', 'volcano', 'hiking', 'nature'],
        latitude: 35.3606,
        longitude: 138.7274,
        imageUrls: [
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        ],
        videoUrl: null,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now,
      ),
      Destination(
        id: '5',
        name: 'Times Square',
        description:
            'Major commercial intersection, tourist destination, entertainment center, and neighborhood in Midtown Manhattan, New York City.',
        country: 'United States',
        city: 'New York',
        category: 'Entertainment',
        tags: ['city', 'nightlife', 'shopping', 'broadway'],
        latitude: 40.7580,
        longitude: -73.9855,
        imageUrls: [
          'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=800',
        ],
        videoUrl: null,
        isActive: false,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now,
      ),
    ];
  }

  void _filterDestinations() {
    setState(() {
      _filteredDestinations = _destinations.where((destination) {
        final matchesSearch = destination.name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            destination.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            destination.tags.any((tag) =>
                tag.toLowerCase().contains(_searchQuery.toLowerCase()));

        final matchesCountry = _selectedCountry == 'All' ||
            destination.country == _selectedCountry;

        final matchesCategory = _selectedCategory == 'All' ||
            destination.category == _selectedCategory;

        final matchesStatus = _selectedStatus == 'All' ||
            (_selectedStatus == 'Active' && destination.isActive) ||
            (_selectedStatus == 'Inactive' && !destination.isActive);

        return matchesSearch &&
            matchesCountry &&
            matchesCategory &&
            matchesStatus;
      }).toList();
    });
  }

  void _createNewDestination() {
    // TODO: Navigate to destination creation screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Destination creation coming soon!')),
    );
  }

  void _editDestination(Destination destination) {
    // TODO: Navigate to destination editing screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing ${destination.name} coming soon!')),
    );
  }

  void _toggleActiveStatus(Destination destination) {
    // TODO: Implement toggle functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${destination.isActive ? 'Deactivating' : 'Activating'} ${destination.name} coming soon!'),
      ),
    );
  }

  void _deleteDestination(Destination destination) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Destination'),
        content: Text(
            'Are you sure you want to delete "${destination.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Deleting ${destination.name} coming soon!')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Destination Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewDestination,
            tooltip: 'Add New Destination',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search destinations...',
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
                    _filterDestinations();
                  },
                ),
                const SizedBox(height: 12),
                // Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCountry,
                        decoration: InputDecoration(
                          labelText: 'Country',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _countries.map((country) {
                          return DropdownMenuItem(
                            value: country,
                            child: Text(country),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCountry = value!;
                          });
                          _filterDestinations();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                          _filterDestinations();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _statuses.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                          _filterDestinations();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Destinations List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDestinations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No destinations found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first destination to get started',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredDestinations.length,
                        itemBuilder: (context, index) {
                          final destination = _filteredDestinations[index];
                          return _DestinationCard(
                            destination: destination,
                            onEdit: () => _editDestination(destination),
                            onToggleActive: () =>
                                _toggleActiveStatus(destination),
                            onDelete: () => _deleteDestination(destination),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const _DestinationCard({
    required this.destination,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          if (destination.imageUrls.isNotEmpty)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                image: DecorationImage(
                  image: NetworkImage(destination.imageUrls.first),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Status Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: destination.isActive
                            ? Colors.green.withOpacity(0.9)
                            : Colors.grey.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        destination.isActive ? 'Active' : 'Inactive',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  // Image Count Badge
                  if (destination.imageUrls.length > 1)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${destination.imageUrls.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            destination.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                destination.city != null
                                    ? '${destination.city}, ${destination.country}'
                                    : destination.country,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit();
                            break;
                          case 'toggle':
                            onToggleActive();
                            break;
                          case 'delete':
                            onDelete();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit Destination'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Row(
                            children: [
                              Icon(destination.isActive
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              const SizedBox(width: 8),
                              Text(destination.isActive
                                  ? 'Deactivate'
                                  : 'Activate'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Category and Tags
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        destination.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (destination.latitude != null &&
                        destination.longitude != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.map,
                              size: 12,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'GPS',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                // Description
                Text(
                  destination.description.length > 150
                      ? '${destination.description.substring(0, 150)}...'
                      : destination.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                // Tags
                if (destination.tags.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    children: destination.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryTeal,
                          side: BorderSide(color: AppTheme.primaryTeal),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onToggleActive,
                        icon: Icon(
                          destination.isActive
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 18,
                        ),
                        label: Text(
                            destination.isActive ? 'Deactivate' : 'Activate'),
                        style: FilledButton.styleFrom(
                          backgroundColor: destination.isActive
                              ? Colors.orange
                              : AppTheme.primaryTeal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
