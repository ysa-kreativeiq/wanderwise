import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'notifications_campaigns_screen.dart';

class CampaignCreationScreen extends StatefulWidget {
  const CampaignCreationScreen({super.key});

  @override
  State<CampaignCreationScreen> createState() => _CampaignCreationScreenState();
}

class _CampaignCreationScreenState extends State<CampaignCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _customTargetsController = TextEditingController();

  NotificationType _selectedType = NotificationType.push;
  TargetAudience _selectedAudience = TargetAudience.allUsers;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;

  bool _isSaving = false;

  final List<String> _customTargets = <String>[];

  final List<String> _availableTags = [
    'urgent',
    'promotional',
    'informational',
    'reminder',
    'welcome',
    'update',
  ];

  final List<String> _selectedTags = <String>[];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _customTargetsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _scheduledDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _scheduledDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _scheduledTime = picked;
      });
    }
  }

  void _addCustomTarget() {
    final target = _customTargetsController.text.trim();
    if (target.isNotEmpty && !_customTargets.contains(target)) {
      setState(() {
        _customTargets.add(target);
        _customTargetsController.clear();
      });
    }
  }

  void _removeCustomTarget(String target) {
    setState(() {
      _customTargets.remove(target);
    });
  }

  Future<void> _saveCampaign() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // TODO: Implement saveCampaign in SupabaseService
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Campaign created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating campaign: $e'),
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

  void _saveAsDraft() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // TODO: Implement saveDraft in SupabaseService
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Draft saved successfully!'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving draft: $e'),
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

  void _previewCampaign() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Campaign Preview'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${_titleController.text}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Message: ${_messageController.text}'),
            const SizedBox(height: 8),
            Text('Type: ${_selectedType.name}'),
            Text('Target: ${_selectedAudience.name}'),
            if (_scheduledDate != null)
              Text(
                  'Scheduled: ${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year} ${_scheduledTime?.format(context) ?? ''}'),
            if (_selectedTags.isNotEmpty)
              Text('Tags: ${_selectedTags.join(', ')}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
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
        title: const Text('Create Campaign'),
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
            onPressed: _isSaving ? null : _previewCampaign,
            child: const Text('Preview', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: _isSaving ? null : _saveAsDraft,
            child:
                const Text('Save Draft', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: _isSaving ? null : _saveCampaign,
            child: const Text('Send', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Campaign Details',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Campaign Title',
                          border: OutlineInputBorder(),
                          hintText:
                              'Enter a compelling title for your campaign',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a campaign title';
                          }
                          if (value.length > 100) {
                            return 'Title must be less than 100 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          labelText: 'Message',
                          border: OutlineInputBorder(),
                          hintText: 'Enter your message content',
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a message';
                          }
                          if (value.length > 500) {
                            return 'Message must be less than 500 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Campaign Type
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Campaign Type',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: NotificationType.values.map((type) {
                          final isSelected = _selectedType == type;
                          return FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getTypeIcon(type),
                                  size: 16,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.primaryTeal,
                                ),
                                const SizedBox(width: 4),
                                Text(type.name.toUpperCase()),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedType = type;
                              });
                            },
                            backgroundColor: Colors.grey[100],
                            selectedColor: AppTheme.primaryTeal,
                            checkmarkColor: Colors.white,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Target Audience
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target Audience',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<TargetAudience>(
                        value: _selectedAudience,
                        decoration: const InputDecoration(
                          labelText: 'Select Target Audience',
                          border: OutlineInputBorder(),
                        ),
                        items: TargetAudience.values.map((audience) {
                          return DropdownMenuItem(
                            value: audience,
                            child: Text(audience.name
                                .replaceAll(RegExp(r'([A-Z])'), ' \$1')
                                .trim()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAudience = value!;
                          });
                        },
                      ),
                      if (_selectedAudience == TargetAudience.custom) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _customTargetsController,
                                decoration: const InputDecoration(
                                  labelText: 'Add Custom Target',
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter email or user ID',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _addCustomTarget,
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                        if (_customTargets.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: _customTargets.map((target) {
                              return Chip(
                                label: Text(target),
                                onDeleted: () => _removeCustomTarget(target),
                                deleteIcon: const Icon(Icons.close, size: 18),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Scheduling
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scheduling',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              leading: const Icon(Icons.calendar_today),
                              title: const Text('Date'),
                              subtitle: Text(
                                _scheduledDate != null
                                    ? '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'
                                    : 'Select date',
                              ),
                              onTap: _selectDate,
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              leading: const Icon(Icons.access_time),
                              title: const Text('Time'),
                              subtitle: Text(
                                _scheduledTime?.format(context) ??
                                    'Select time',
                              ),
                              onTap: _selectTime,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _scheduledDate != null && _scheduledTime != null
                                    ? 'Campaign will be sent on ${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year} at ${_scheduledTime!.format(context)}'
                                    : 'Leave empty to send immediately',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tags
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tags',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add tags to help categorize and track your campaign',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
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
                                AppTheme.primaryTeal.withValues(alpha: 0.2),
                            checkmarkColor: AppTheme.primaryTeal,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : _saveAsDraft,
                      child: const Text('Save Draft'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSaving ? null : _saveCampaign,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Send Campaign'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.push:
        return Icons.notifications;
      case NotificationType.email:
        return Icons.email;
      case NotificationType.sms:
        return Icons.sms;
      case NotificationType.inApp:
        return Icons.message;
    }
  }
}
