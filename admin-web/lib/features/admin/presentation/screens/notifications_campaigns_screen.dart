import 'package:flutter/material.dart';

import 'campaign_creation_screen.dart';

enum NotificationType {
  push,
  email,
  sms,
  inApp,
}

enum CampaignStatus {
  draft,
  scheduled,
  active,
  completed,
  paused,
  cancelled,
}

enum TargetAudience {
  allUsers,
  travelers,
  travelAgents,
  editors,
  admins,
  custom,
}

class NotificationCampaign {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final CampaignStatus status;
  final TargetAudience targetAudience;
  final List<String>? customTargets;
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final int totalRecipients;
  final int deliveredCount;
  final int openedCount;
  final int clickedCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationCampaign({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.status,
    required this.targetAudience,
    this.customTargets,
    this.scheduledAt,
    this.sentAt,
    required this.totalRecipients,
    required this.deliveredCount,
    required this.openedCount,
    required this.clickedCount,
    required this.createdAt,
    required this.updatedAt,
  });

  double get deliveryRate =>
      totalRecipients > 0 ? (deliveredCount / totalRecipients) * 100 : 0;
  double get openRate =>
      deliveredCount > 0 ? (openedCount / deliveredCount) * 100 : 0;
  double get clickRate =>
      openedCount > 0 ? (clickedCount / openedCount) * 100 : 0;
}

class NotificationsCampaignsScreen extends StatefulWidget {
  const NotificationsCampaignsScreen({super.key});

  @override
  State<NotificationsCampaignsScreen> createState() =>
      _NotificationsCampaignsScreenState();
}

class _NotificationsCampaignsScreenState
    extends State<NotificationsCampaignsScreen> {
  bool _isLoading = false;

  String _selectedStatus = 'All';
  String _selectedType = 'All';
  String _searchQuery = '';
  List<NotificationCampaign> _campaigns = [];
  List<NotificationCampaign> _filteredCampaigns = [];

  final List<String> _statuses = [
    'All',
    'Draft',
    'Scheduled',
    'Active',
    'Completed',
    'Paused',
    'Cancelled',
  ];

  final List<String> _types = [
    'All',
    'Push',
    'Email',
    'SMS',
    'In-App',
  ];

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement getNotificationCampaigns in SupabaseService
      await Future.delayed(const Duration(milliseconds: 600));

      // Mock data
      _campaigns = [
        NotificationCampaign(
          id: '1',
          title: 'New Paris Adventure Available!',
          message:
              'Discover the magic of Paris with our new family-friendly itinerary.',
          type: NotificationType.push,
          status: CampaignStatus.completed,
          targetAudience: TargetAudience.travelers,
          scheduledAt: DateTime.now().subtract(const Duration(days: 2)),
          sentAt: DateTime.now().subtract(const Duration(days: 1)),
          totalRecipients: 1250,
          deliveredCount: 1180,
          openedCount: 890,
          clickedCount: 234,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        NotificationCampaign(
          id: '2',
          title: 'Summer Travel Deals',
          message:
              'Get 20% off on all summer destinations. Limited time offer!',
          type: NotificationType.email,
          status: CampaignStatus.active,
          targetAudience: TargetAudience.allUsers,
          scheduledAt: DateTime.now().add(const Duration(hours: 2)),
          totalRecipients: 3200,
          deliveredCount: 0,
          openedCount: 0,
          clickedCount: 0,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        NotificationCampaign(
          id: '3',
          title: 'System Maintenance Notice',
          message:
              'Scheduled maintenance on Sunday 2-4 AM. Service may be temporarily unavailable.',
          type: NotificationType.inApp,
          status: CampaignStatus.scheduled,
          targetAudience: TargetAudience.allUsers,
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          totalRecipients: 0,
          deliveredCount: 0,
          openedCount: 0,
          clickedCount: 0,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ];

      _filterCampaigns();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading campaigns: $e')),
        );
      }
    }
  }

  void _filterCampaigns() {
    _filteredCampaigns = _campaigns.where((campaign) {
      final matchesStatus = _selectedStatus == 'All' ||
          campaign.status.name.toLowerCase() == _selectedStatus.toLowerCase();
      final matchesType = _selectedType == 'All' ||
          campaign.type.name.toLowerCase() == _selectedType.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          campaign.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          campaign.message.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesStatus && matchesType && matchesSearch;
    }).toList();
  }

  void _createNewCampaign() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CampaignCreationScreen(),
      ),
    ).then((_) {
      _loadCampaigns(); // Refresh the list when returning
    });
  }

  Color _getStatusColor(CampaignStatus status) {
    switch (status) {
      case CampaignStatus.draft:
        return Colors.grey;
      case CampaignStatus.scheduled:
        return Colors.blue;
      case CampaignStatus.active:
        return Colors.green;
      case CampaignStatus.completed:
        return Colors.purple;
      case CampaignStatus.paused:
        return Colors.orange;
      case CampaignStatus.cancelled:
        return Colors.red;
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications & Campaigns'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCampaigns,
            tooltip: 'Refresh',
          ),
          FilledButton.icon(
            onPressed: _createNewCampaign,
            icon: const Icon(Icons.add),
            label: const Text('New Campaign'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filters
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Search Campaigns',
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                    _filterCampaigns();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedStatus,
                                decoration: const InputDecoration(
                                  labelText: 'Status',
                                  border: OutlineInputBorder(),
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
                                    _filterCampaigns();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedType,
                                decoration: const InputDecoration(
                                  labelText: 'Type',
                                  border: OutlineInputBorder(),
                                ),
                                items: _types.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedType = value!;
                                    _filterCampaigns();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Campaigns List
                Expanded(
                  child: _filteredCampaigns.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.campaign_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No campaigns found',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create your first campaign to get started',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: _createNewCampaign,
                                icon: const Icon(Icons.add),
                                label: const Text('Create Campaign'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredCampaigns.length,
                          itemBuilder: (context, index) {
                            final campaign = _filteredCampaigns[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      _getStatusColor(campaign.status)
                                          .withValues(alpha: 0.1),
                                  child: Icon(
                                    _getTypeIcon(campaign.type),
                                    color: _getStatusColor(campaign.status),
                                  ),
                                ),
                                title: Text(
                                  campaign.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(campaign.message),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                _getStatusColor(campaign.status)
                                                    .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            campaign.status.name.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: _getStatusColor(
                                                  campaign.status),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${campaign.type.name} • ${campaign.targetAudience.name}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
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
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'duplicate',
                                      child: Row(
                                        children: [
                                          Icon(Icons.copy),
                                          SizedBox(width: 8),
                                          Text('Duplicate'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'pause',
                                      child: Row(
                                        children: [
                                          Icon(Icons.pause),
                                          SizedBox(width: 8),
                                          Text('Pause'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'cancel',
                                      child: Row(
                                        children: [
                                          Icon(Icons.cancel),
                                          SizedBox(width: 8),
                                          Text('Cancel'),
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
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    _handleCampaignAction(campaign, value);
                                  },
                                ),
                                onTap: () => _showCampaignDetails(campaign),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewCampaign,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _handleCampaignAction(NotificationCampaign campaign, String action) {
    switch (action) {
      case 'view':
        _showCampaignDetails(campaign);
        break;
      case 'edit':
        // TODO: Implement edit functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit functionality coming soon!')),
        );
        break;
      case 'duplicate':
        // TODO: Implement duplicate functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Duplicate functionality coming soon!')),
        );
        break;
      case 'pause':
        // TODO: Implement pause functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pause functionality coming soon!')),
        );
        break;
      case 'cancel':
        // TODO: Implement cancel functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cancel functionality coming soon!')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(campaign);
        break;
    }
  }

  void _showDeleteConfirmation(NotificationCampaign campaign) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Campaign'),
        content: Text(
            'Are you sure you want to delete "${campaign.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Delete functionality coming soon!')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCampaignDetails(NotificationCampaign campaign) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(campaign.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                campaign.message,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Type', campaign.type.name),
              _buildDetailRow('Status', campaign.status.name),
              _buildDetailRow('Target Audience', campaign.targetAudience.name),
              if (campaign.scheduledAt != null)
                _buildDetailRow(
                    'Scheduled', _formatDateTime(campaign.scheduledAt!)),
              if (campaign.sentAt != null)
                _buildDetailRow('Sent', _formatDateTime(campaign.sentAt!)),
              const SizedBox(height: 16),
              const Text(
                'Performance Metrics',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                  'Total Recipients', campaign.totalRecipients.toString()),
              _buildDetailRow('Delivered',
                  '${campaign.deliveredCount} (${campaign.deliveryRate.toStringAsFixed(1)}%)'),
              _buildDetailRow('Opened',
                  '${campaign.openedCount} (${campaign.openRate.toStringAsFixed(1)}%)'),
              _buildDetailRow('Clicked',
                  '${campaign.clickedCount} (${campaign.clickRate.toStringAsFixed(1)}%)'),
            ],
          ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
