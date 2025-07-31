import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TravelTip {
  final String id;
  final String title;
  final String content;
  final String country;
  final String? city;
  final String category;
  final List<String> tags;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  TravelTip({
    required this.id,
    required this.title,
    required this.content,
    required this.country,
    this.city,
    required this.category,
    required this.tags,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });
}

class TravelTipsScreen extends StatefulWidget {
  const TravelTipsScreen({super.key});

  @override
  State<TravelTipsScreen> createState() => _TravelTipsScreenState();
}

class _TravelTipsScreenState extends State<TravelTipsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCountry = 'All';
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  bool _isLoading = false;
  List<TravelTip> _tips = [];
  List<TravelTip> _filteredTips = [];

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
  ];

  final List<String> _categories = [
    'All',
    'Safety',
    'Transport',
    'Culture',
    'Health',
    'Food',
    'Budget',
    'Accommodation',
    'Activities',
  ];

  final List<String> _statuses = [
    'All',
    'Published',
    'Draft',
  ];

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTips() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement getTravelTips in SupabaseService
      // For now, using mock data
      final tips = await _getMockTips();

      setState(() {
        _tips = tips;
        _filteredTips = tips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tips: $e')),
        );
      }
    }
  }

  Future<List<TravelTip>> _getMockTips() async {
    // Mock data for development
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();

    return [
      TravelTip(
        id: '1',
        title: 'Paris Safety Tips',
        content:
            'Always be aware of your surroundings in tourist areas. Keep your belongings close and avoid displaying expensive items. Use official taxi services or ride-sharing apps.',
        country: 'France',
        city: 'Paris',
        category: 'Safety',
        tags: ['safety', 'paris', 'tourist'],
        isPublished: true,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),
      TravelTip(
        id: '2',
        title: 'Italian Food Culture',
        content:
            'In Italy, dinner is typically served late (8-10 PM). Don\'t ask for parmesan on seafood pasta - it\'s considered rude. Always greet with "Buongiorno" or "Buonasera".',
        country: 'Italy',
        category: 'Food',
        tags: ['food', 'culture', 'italy', 'dining'],
        isPublished: true,
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now,
      ),
      TravelTip(
        id: '3',
        title: 'Budget Travel in Japan',
        content:
            'Use Japan Rail Pass for long-distance travel. Stay in capsule hotels or business hotels to save money. Eat at convenience stores and local restaurants.',
        country: 'Japan',
        category: 'Budget',
        tags: ['budget', 'japan', 'transport', 'accommodation'],
        isPublished: false,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now,
      ),
      TravelTip(
        id: '4',
        title: 'Spanish Transportation',
        content:
            'RENFE trains are efficient for city-to-city travel. Metro systems in major cities are clean and reliable. Consider walking in historic centers.',
        country: 'Spain',
        category: 'Transport',
        tags: ['transport', 'spain', 'trains', 'metro'],
        isPublished: true,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now,
      ),
    ];
  }

  void _filterTips() {
    setState(() {
      _filteredTips = _tips.where((tip) {
        final matchesSearch = tip.title
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            tip.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            tip.tags.any((tag) =>
                tag.toLowerCase().contains(_searchQuery.toLowerCase()));

        final matchesCountry =
            _selectedCountry == 'All' || tip.country == _selectedCountry;

        final matchesCategory =
            _selectedCategory == 'All' || tip.category == _selectedCategory;

        final matchesStatus = _selectedStatus == 'All' ||
            (_selectedStatus == 'Published' && tip.isPublished) ||
            (_selectedStatus == 'Draft' && !tip.isPublished);

        return matchesSearch &&
            matchesCountry &&
            matchesCategory &&
            matchesStatus;
      }).toList();
    });
  }

  void _createNewTip() {
    // TODO: Navigate to tip creation screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tip creation coming soon!')),
    );
  }

  void _editTip(TravelTip tip) {
    // TODO: Navigate to tip editing screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing ${tip.title} coming soon!')),
    );
  }

  void _togglePublishStatus(TravelTip tip) {
    // TODO: Implement publish/unpublish functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${tip.isPublished ? 'Unpublishing' : 'Publishing'} ${tip.title} coming soon!'),
      ),
    );
  }

  void _deleteTip(TravelTip tip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tip'),
        content: Text(
            'Are you sure you want to delete "${tip.title}"? This action cannot be undone.'),
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
                SnackBar(content: Text('Deleting ${tip.title} coming soon!')),
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
        title: const Text('Travel Tips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewTip,
            tooltip: 'Create New Tip',
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
                    hintText: 'Search tips...',
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
                    _filterTips();
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
                          _filterTips();
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
                          _filterTips();
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
                          _filterTips();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tips List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTips.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.tips_and_updates,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tips found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your first travel tip to get started',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredTips.length,
                        itemBuilder: (context, index) {
                          final tip = _filteredTips[index];
                          return _TipCard(
                            tip: tip,
                            onEdit: () => _editTip(tip),
                            onTogglePublish: () => _togglePublishStatus(tip),
                            onDelete: () => _deleteTip(tip),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final TravelTip tip;
  final VoidCallback onEdit;
  final VoidCallback onTogglePublish;
  final VoidCallback onDelete;

  const _TipCard({
    required this.tip,
    required this.onEdit,
    required this.onTogglePublish,
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
      child: Padding(
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tip.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: tip.isPublished
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tip.isPublished ? 'Published' : 'Draft',
                              style: TextStyle(
                                fontSize: 12,
                                color: tip.isPublished
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              tip.category,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor:
                                AppTheme.primaryTeal.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tip.city != null
                                ? '${tip.city}, ${tip.country}'
                                : tip.country,
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
                      case 'publish':
                        onTogglePublish();
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
                          Text('Edit Tip'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'publish',
                      child: Row(
                        children: [
                          Icon(tip.isPublished
                              ? Icons.visibility_off
                              : Icons.publish),
                          const SizedBox(width: 8),
                          Text(tip.isPublished ? 'Unpublish' : 'Publish'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Content Preview
            Text(
              tip.content.length > 150
                  ? '${tip.content.substring(0, 150)}...'
                  : tip.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            // Tags
            if (tip.tags.isNotEmpty)
              Wrap(
                spacing: 4,
                children: tip.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[700],
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
                    onPressed: onTogglePublish,
                    icon: Icon(
                      tip.isPublished ? Icons.visibility_off : Icons.publish,
                      size: 18,
                    ),
                    label: Text(tip.isPublished ? 'Unpublish' : 'Publish'),
                    style: FilledButton.styleFrom(
                      backgroundColor: tip.isPublished
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
    );
  }
}
