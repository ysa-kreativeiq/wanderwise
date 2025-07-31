import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/itinerary_model.dart';

import 'itinerary_editor_screen.dart';

class ItineraryTemplatesScreen extends StatefulWidget {
  const ItineraryTemplatesScreen({super.key});

  @override
  State<ItineraryTemplatesScreen> createState() =>
      _ItineraryTemplatesScreenState();
}

class _ItineraryTemplatesScreenState extends State<ItineraryTemplatesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = false;
  List<Itinerary> _templates = [];
  List<Itinerary> _filteredTemplates = [];

  final List<String> _categories = [
    'All',
    'Family',
    'Luxury',
    'Adventure',
    'Cultural',
    'Romantic',
    'Business',
    'Eco-Friendly'
  ];

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement getItineraryTemplates in SupabaseService
      // For now, using mock data
      final templates = await _getMockTemplates();

      setState(() {
        _templates = templates;
        _filteredTemplates = templates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading templates: $e')),
        );
      }
    }
  }

  Future<List<Itinerary>> _getMockTemplates() async {
    // Mock data for development
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();

    return [
      Itinerary(
        id: '1',
        title: 'Paris Family Adventure',
        description:
            'Perfect 5-day family trip to Paris with kid-friendly activities',
        userId: 'template_user',
        startDate: now.add(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 35)),
        destinationIds: ['paris', 'versailles'],
        days: [],
        status: ItineraryStatus.published,
        tags: ['family', 'culture', 'food'],
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
        metadata: {
          'category': 'Family',
          'isTemplate': true,
          'destinations': ['Paris', 'Versailles'],
        },
      ),
      Itinerary(
        id: '2',
        title: 'Luxury Italian Getaway',
        description: 'Premium 7-day luxury tour of Italy\'s finest cities',
        userId: 'template_user',
        startDate: now.add(const Duration(days: 45)),
        endDate: now.add(const Duration(days: 52)),
        destinationIds: ['rome', 'florence', 'venice'],
        days: [],
        status: ItineraryStatus.published,
        tags: ['luxury', 'culture', 'fine-dining'],
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now,
        metadata: {
          'category': 'Luxury',
          'isTemplate': true,
          'destinations': ['Rome', 'Florence', 'Venice'],
        },
      ),
      Itinerary(
        id: '3',
        title: 'Adventure in New Zealand',
        description:
            'Thrilling 10-day adventure through New Zealand\'s landscapes',
        userId: 'template_user',
        startDate: now.add(const Duration(days: 60)),
        endDate: now.add(const Duration(days: 70)),
        destinationIds: ['auckland', 'queenstown', 'christchurch'],
        days: [],
        status: ItineraryStatus.published,
        tags: ['adventure', 'nature', 'hiking'],
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now,
        metadata: {
          'category': 'Adventure',
          'isTemplate': true,
          'destinations': ['Auckland', 'Queenstown', 'Christchurch'],
        },
      ),
    ];
  }

  void _filterTemplates() {
    setState(() {
      _filteredTemplates = _templates.where((template) {
        final matchesSearch =
            template.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                template.description
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                (template.metadata?['destinations'] as List<dynamic>?)?.any(
                        (dest) => dest
                            .toString()
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase())) ==
                    true;

        final matchesCategory = _selectedCategory == 'All' ||
            template.metadata?['category'] == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _createNewTemplate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ItineraryEditorScreen(),
      ),
    );
  }

  void _editTemplate(Itinerary template) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItineraryEditorScreen(
          itineraryId: template.id,
        ),
      ),
    );
  }

  void _pushToTraveler(Itinerary template) {
    // TODO: Navigate to traveler selection screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Push ${template.title} to traveler coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerary Templates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewTemplate,
            tooltip: 'Create New Template',
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
                    hintText: 'Search templates...',
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
                    _filterTemplates();
                  },
                ),
                const SizedBox(height: 12),
                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                            _filterTemplates();
                          },
                          backgroundColor: Colors.grey[100],
                          selectedColor: AppTheme.primaryTeal.withOpacity(0.2),
                          checkmarkColor: AppTheme.primaryTeal,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Templates List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTemplates.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.travel_explore,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No templates found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your first template to get started',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredTemplates.length,
                        itemBuilder: (context, index) {
                          final template = _filteredTemplates[index];
                          return _TemplateCard(
                            template: template,
                            onEdit: () => _editTemplate(template),
                            onPush: () => _pushToTraveler(template),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final Itinerary template;
  final VoidCallback onEdit;
  final VoidCallback onPush;

  const _TemplateCard({
    required this.template,
    required this.onEdit,
    required this.onPush,
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
                      Text(
                        template.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              template.metadata?['category'] ?? 'Unknown',
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
                            Icons.schedule,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${template.endDate.difference(template.startDate).inDays} days',
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
                      case 'push':
                        onPush();
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
                          Text('Edit Template'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'push',
                      child: Row(
                        children: [
                          Icon(Icons.send),
                          SizedBox(width: 8),
                          Text('Push to Traveler'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              template.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            // Destinations
            Wrap(
              spacing: 8,
              children: (template.metadata?['destinations'] as List<dynamic>?)
                      ?.map((destination) {
                    return Chip(
                      label: Text(
                        destination.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.grey[100],
                    );
                  }).toList() ??
                  [],
            ),
            const SizedBox(height: 12),
            // Tags
            if (template.tags.isNotEmpty)
              Wrap(
                spacing: 4,
                children: template.tags.map((tag) {
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
                    onPressed: onPush,
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Push to Traveler'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
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
