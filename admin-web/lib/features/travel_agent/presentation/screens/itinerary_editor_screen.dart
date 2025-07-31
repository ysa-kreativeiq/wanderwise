import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'activity_editor_screen.dart';

class ItineraryActivity {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String
      type; // 'visit', 'meal', 'transport', 'accommodation', 'activity'
  final String? notes;
  final List<String> tags;

  ItineraryActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.notes,
    required this.tags,
  });
}

class ItineraryDay {
  final int dayNumber;
  final String title;
  final String description;
  final List<ItineraryActivity> activities;
  final String? notes;

  ItineraryDay({
    required this.dayNumber,
    required this.title,
    required this.description,
    required this.activities,
    this.notes,
  });
}

class ItineraryEditorScreen extends StatefulWidget {
  final String? itineraryId; // null for new itinerary, ID for editing

  const ItineraryEditorScreen({
    super.key,
    this.itineraryId,
  });

  @override
  State<ItineraryEditorScreen> createState() => _ItineraryEditorScreenState();
}

class _ItineraryEditorScreenState extends State<ItineraryEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Family';
  List<String> _selectedTags = [];
  List<ItineraryDay> _days = [];
  bool _isLoading = false;
  bool _isSaving = false;

  final List<String> _categories = [
    'Family',
    'Luxury',
    'Adventure',
    'Cultural',
    'Romantic',
    'Business',
    'Eco-Friendly',
    'Budget',
    'Solo',
    'Group',
  ];

  final List<String> _availableTags = [
    'family-friendly',
    'luxury',
    'adventure',
    'culture',
    'food',
    'nature',
    'history',
    'shopping',
    'nightlife',
    'relaxation',
    'photography',
    'hiking',
    'beach',
    'mountain',
    'city',
    'rural',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.itineraryId != null) {
      _loadItinerary();
    } else {
      _initializeNewItinerary();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadItinerary() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement getItineraryById in SupabaseService
      // For now, using mock data
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data for editing
      _titleController.text = 'Paris Family Adventure';
      _descriptionController.text =
          'Perfect 5-day family trip to Paris with kid-friendly activities';
      _selectedCategory = 'Family';
      _selectedTags = ['family-friendly', 'culture', 'food'];

      _days = [
        ItineraryDay(
          dayNumber: 1,
          title: 'Arrival & Eiffel Tower',
          description: 'Welcome to Paris! Start with the iconic Eiffel Tower.',
          activities: [
            ItineraryActivity(
              id: '1',
              title: 'Check-in at Hotel',
              description: 'Arrive and settle into your family-friendly hotel',
              location: 'Hotel Le Parisien',
              startTime: DateTime.now().add(const Duration(days: 1, hours: 14)),
              endTime: DateTime.now().add(const Duration(days: 1, hours: 15)),
              type: 'accommodation',
              tags: ['check-in', 'hotel'],
            ),
            ItineraryActivity(
              id: '2',
              title: 'Eiffel Tower Visit',
              description:
                  'Visit the iconic Eiffel Tower with skip-the-line tickets',
              location: 'Eiffel Tower',
              startTime: DateTime.now().add(const Duration(days: 1, hours: 16)),
              endTime: DateTime.now().add(const Duration(days: 1, hours: 18)),
              type: 'visit',
              tags: ['landmark', 'family-friendly'],
            ),
            ItineraryActivity(
              id: '3',
              title: 'Dinner at Local Restaurant',
              description:
                  'Enjoy traditional French cuisine at a family-friendly restaurant',
              location: 'Le Petit Bistrot',
              startTime: DateTime.now().add(const Duration(days: 1, hours: 19)),
              endTime: DateTime.now().add(const Duration(days: 1, hours: 21)),
              type: 'meal',
              tags: ['dinner', 'french-cuisine'],
            ),
          ],
        ),
        ItineraryDay(
          dayNumber: 2,
          title: 'Louvre & Seine Cruise',
          description:
              'Explore the world\'s largest art museum and enjoy a river cruise.',
          activities: [
            ItineraryActivity(
              id: '4',
              title: 'Louvre Museum',
              description: 'Visit the Louvre with guided tour for families',
              location: 'Louvre Museum',
              startTime: DateTime.now().add(const Duration(days: 2, hours: 9)),
              endTime: DateTime.now().add(const Duration(days: 2, hours: 12)),
              type: 'visit',
              tags: ['museum', 'art', 'family-friendly'],
            ),
            ItineraryActivity(
              id: '5',
              title: 'Lunch Break',
              description: 'Quick lunch at museum café',
              location: 'Louvre Café',
              startTime: DateTime.now().add(const Duration(days: 2, hours: 12)),
              endTime: DateTime.now().add(const Duration(days: 2, hours: 13)),
              type: 'meal',
              tags: ['lunch', 'quick-meal'],
            ),
            ItineraryActivity(
              id: '6',
              title: 'Seine River Cruise',
              description: 'Relaxing cruise along the Seine River',
              location: 'Seine River',
              startTime: DateTime.now().add(const Duration(days: 2, hours: 14)),
              endTime: DateTime.now()
                  .add(const Duration(days: 2, hours: 15, minutes: 30)),
              type: 'activity',
              tags: ['cruise', 'river', 'relaxation'],
            ),
          ],
        ),
      ];

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading itinerary: $e')),
        );
      }
    }
  }

  void _initializeNewItinerary() {
    _titleController.text = '';
    _descriptionController.text = '';
    _selectedCategory = 'Family';
    _selectedTags = [];
    _days = [
      ItineraryDay(
        dayNumber: 1,
        title: 'Day 1',
        description: 'Start your journey',
        activities: [],
      ),
    ];
  }

  void _addDay() {
    setState(() {
      _days.add(ItineraryDay(
        dayNumber: _days.length + 1,
        title: 'Day ${_days.length + 1}',
        description: 'Add your activities for this day',
        activities: [],
      ));
    });
  }

  void _removeDay(int dayIndex) {
    if (_days.length > 1) {
      setState(() {
        _days.removeAt(dayIndex);
        // Reorder day numbers
        for (int i = 0; i < _days.length; i++) {
          _days[i] = ItineraryDay(
            dayNumber: i + 1,
            title: _days[i].title,
            description: _days[i].description,
            activities: _days[i].activities,
            notes: _days[i].notes,
          );
        }
      });
    }
  }

  void _addActivity(int dayIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityEditorScreen(
          onSave: (activity) {
            setState(() {
              _days[dayIndex].activities.add(activity);
            });
          },
        ),
      ),
    );
  }

  void _editActivity(int dayIndex, int activityIndex) {
    final activity = _days[dayIndex].activities[activityIndex];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityEditorScreen(
          activity: activity,
          onSave: (updatedActivity) {
            setState(() {
              _days[dayIndex].activities[activityIndex] = updatedActivity;
            });
          },
        ),
      ),
    );
  }

  void _removeActivity(int dayIndex, int activityIndex) {
    setState(() {
      _days[dayIndex].activities.removeAt(activityIndex);
    });
  }

  Future<void> _saveItinerary() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // TODO: Implement saveItinerary in SupabaseService
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.itineraryId != null
                ? 'Itinerary updated successfully!'
                : 'Itinerary created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving itinerary: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.itineraryId != null ? 'Edit Itinerary' : 'Create Itinerary'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          TextButton(
            onPressed: _isSaving ? null : _saveItinerary,
            child: Text(
              widget.itineraryId != null ? 'Update' : 'Save',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Basic Information',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Itinerary Title',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a title';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a description';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedCategory,
                                    decoration: const InputDecoration(
                                      labelText: 'Category',
                                      border: OutlineInputBorder(),
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
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tags',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: _availableTags.map((tag) {
                                final isSelected = _selectedTags.contains(tag);
                                return FilterChip(
                                  label: Text(tag),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedTags.add(tag);
                                      } else {
                                        _selectedTags.remove(tag);
                                      }
                                    });
                                  },
                                  backgroundColor: Colors.grey[100],
                                  selectedColor:
                                      AppTheme.primaryTeal.withOpacity(0.2),
                                  checkmarkColor: AppTheme.primaryTeal,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Days Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Itinerary Days',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: _addDay,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Day'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Days List
                    ..._days.asMap().entries.map((entry) {
                      final dayIndex = entry.key;
                      final day = entry.value;
                      return _DayCard(
                        day: day,
                        onAddActivity: () => _addActivity(dayIndex),
                        onEditActivity: (activityIndex) =>
                            _editActivity(dayIndex, activityIndex),
                        onRemoveActivity: (activityIndex) =>
                            _removeActivity(dayIndex, activityIndex),
                        onRemoveDay: () => _removeDay(dayIndex),
                        canRemoveDay: _days.length > 1,
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final ItineraryDay day;
  final VoidCallback onAddActivity;
  final Function(int) onEditActivity;
  final Function(int) onRemoveActivity;
  final VoidCallback onRemoveDay;
  final bool canRemoveDay;

  const _DayCard({
    required this.day,
    required this.onAddActivity,
    required this.onEditActivity,
    required this.onRemoveActivity,
    required this.onRemoveDay,
    required this.canRemoveDay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Day ${day.dayNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (day.description.isNotEmpty)
                        Text(
                          day.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                if (canRemoveDay)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onRemoveDay,
                    tooltip: 'Remove Day',
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Activities
            if (day.activities.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No activities planned',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add activities to plan your day',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: day.activities.asMap().entries.map((entry) {
                  final activityIndex = entry.key;
                  final activity = entry.value;
                  return _ActivityCard(
                    activity: activity,
                    onEdit: () => onEditActivity(activityIndex),
                    onRemove: () => onRemoveActivity(activityIndex),
                  );
                }).toList(),
              ),

            const SizedBox(height: 16),

            // Add Activity Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddActivity,
                icon: const Icon(Icons.add),
                label: const Text('Add Activity'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryTeal,
                  side: BorderSide(color: AppTheme.primaryTeal),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ItineraryActivity activity;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _ActivityCard({
    required this.activity,
    required this.onEdit,
    required this.onRemove,
  });

  Color _getActivityTypeColor(String type) {
    switch (type) {
      case 'visit':
        return Colors.blue;
      case 'meal':
        return Colors.orange;
      case 'transport':
        return Colors.green;
      case 'accommodation':
        return Colors.purple;
      case 'activity':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityTypeIcon(String type) {
    switch (type) {
      case 'visit':
        return Icons.place;
      case 'meal':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'accommodation':
        return Icons.hotel;
      case 'activity':
        return Icons.sports_soccer;
      default:
        return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = _getActivityTypeColor(activity.type);
    final typeIcon = _getActivityTypeIcon(activity.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                typeIcon,
                color: typeColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity.location,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatTime(activity.startTime)} - ${_formatTime(activity.endTime)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: onEdit,
                  tooltip: 'Edit Activity',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: onRemove,
                  tooltip: 'Remove Activity',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
