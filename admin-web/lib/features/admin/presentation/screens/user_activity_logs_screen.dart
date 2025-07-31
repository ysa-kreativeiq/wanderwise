import 'package:flutter/material.dart';

class UserActivityLogsScreen extends StatefulWidget {
  const UserActivityLogsScreen({super.key});

  @override
  State<UserActivityLogsScreen> createState() => _UserActivityLogsScreenState();
}

class _UserActivityLogsScreenState extends State<UserActivityLogsScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';

  // Mock data for activity logs
  final List<Map<String, dynamic>> _activityLogs = [
    {
      'id': '1',
      'user': 'John Doe',
      'userEmail': 'john.doe@example.com',
      'action': 'User Login',
      'description': 'Successfully logged into admin panel',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'ipAddress': '192.168.1.100',
      'userAgent': 'Chrome/120.0.0.0',
      'status': 'success',
      'category': 'authentication',
    },
    {
      'id': '2',
      'user': 'Jane Smith',
      'userEmail': 'jane.smith@example.com',
      'action': 'User Created',
      'description': 'Created new user account for travel agent',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'ipAddress': '192.168.1.101',
      'userAgent': 'Firefox/119.0.0.0',
      'status': 'success',
      'category': 'user_management',
    },
    {
      'id': '3',
      'user': 'Admin User',
      'userEmail': 'admin@wanderwise.com',
      'action': 'Destination Updated',
      'description': 'Updated destination details for Paris',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'ipAddress': '192.168.1.102',
      'userAgent': 'Safari/17.0.0.0',
      'status': 'success',
      'category': 'content_management',
    },
    {
      'id': '4',
      'user': 'System',
      'userEmail': 'system@wanderwise.com',
      'action': 'Backup Completed',
      'description': 'Daily database backup completed successfully',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'ipAddress': '192.168.1.103',
      'userAgent': 'System/1.0.0.0',
      'status': 'success',
      'category': 'system',
    },
    {
      'id': '5',
      'user': 'John Doe',
      'userEmail': 'john.doe@example.com',
      'action': 'Failed Login Attempt',
      'description': 'Invalid password provided',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      'ipAddress': '192.168.1.100',
      'userAgent': 'Chrome/120.0.0.0',
      'status': 'failed',
      'category': 'authentication',
    },
  ];

  List<Map<String, dynamic>> get _filteredLogs {
    return _activityLogs.where((log) {
      if (_selectedFilter != 'all' && log['category'] != _selectedFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return log['user'].toString().toLowerCase().contains(query) ||
            log['action'].toString().toLowerCase().contains(query) ||
            log['description'].toString().toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Activity Logs',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Text(
                      'Track user actions and system events',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Exporting logs...')),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Export'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {});
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Filters
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: _selectedFilter,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'all', child: Text('All Categories')),
                      DropdownMenuItem(
                          value: 'authentication',
                          child: Text('Authentication')),
                      DropdownMenuItem(
                          value: 'user_management',
                          child: Text('User Management')),
                      DropdownMenuItem(
                          value: 'content_management',
                          child: Text('Content Management')),
                      DropdownMenuItem(value: 'system', child: Text('System')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search logs...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Logs List
            Expanded(
              child: _filteredLogs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No activity logs found',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredLogs.length,
                      itemBuilder: (context, index) {
                        final log = _filteredLogs[index];
                        return _buildLogCard(log);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard(Map<String, dynamic> log) {
    final status = log['status'] as String;
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'success':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'failed':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  log['action'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(log['timestamp']),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              log['description'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  log['user'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(width: 16),
                Text(
                  'IP: ${log['ipAddress']}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
