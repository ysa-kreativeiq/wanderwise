import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class BackupRecoveryScreen extends StatefulWidget {
  const BackupRecoveryScreen({super.key});

  @override
  State<BackupRecoveryScreen> createState() => _BackupRecoveryScreenState();
}

class _BackupRecoveryScreenState extends State<BackupRecoveryScreen> {
  int _selectedTabIndex = 0;

  // Mock data for backups
  final List<Map<String, dynamic>> _backups = [
    {
      'id': '1',
      'name': 'Full System Backup',
      'type': 'full',
      'status': 'completed',
      'size': '2.4 GB',
      'createdAt': DateTime.now().subtract(const Duration(hours: 6)),
      'duration': '15 minutes',
      'tables': ['users', 'destinations', 'itineraries', 'reviews'],
      'compression': 'gzip',
      'encryption': 'AES-256',
    },
    {
      'id': '2',
      'name': 'Daily Incremental Backup',
      'type': 'incremental',
      'status': 'completed',
      'size': '156 MB',
      'createdAt': DateTime.now().subtract(const Duration(hours: 24)),
      'duration': '3 minutes',
      'tables': ['users', 'destinations'],
      'compression': 'gzip',
      'encryption': 'AES-256',
    },
    {
      'id': '3',
      'name': 'Weekly Full Backup',
      'type': 'full',
      'status': 'completed',
      'size': '2.1 GB',
      'createdAt': DateTime.now().subtract(const Duration(days: 7)),
      'duration': '12 minutes',
      'tables': ['users', 'destinations', 'itineraries', 'reviews'],
      'compression': 'gzip',
      'encryption': 'AES-256',
    },
    {
      'id': '4',
      'name': 'Emergency Backup',
      'type': 'full',
      'status': 'in_progress',
      'size': '0 MB',
      'createdAt': DateTime.now().subtract(const Duration(minutes: 5)),
      'duration': '0 minutes',
      'tables': ['users', 'destinations', 'itineraries', 'reviews'],
      'compression': 'gzip',
      'encryption': 'AES-256',
    },
  ];

  // Mock data for recovery points
  final List<Map<String, dynamic>> _recoveryPoints = [
    {
      'id': '1',
      'name': 'Before System Update',
      'backupId': '1',
      'createdAt': DateTime.now().subtract(const Duration(hours: 6)),
      'description': 'System backup before major update',
      'status': 'available',
      'size': '2.4 GB',
    },
    {
      'id': '2',
      'name': 'Before User Migration',
      'backupId': '2',
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      'description': 'Backup before user data migration',
      'status': 'available',
      'size': '156 MB',
    },
    {
      'id': '3',
      'name': 'Weekly Recovery Point',
      'backupId': '3',
      'createdAt': DateTime.now().subtract(const Duration(days: 7)),
      'description': 'Weekly scheduled recovery point',
      'status': 'available',
      'size': '2.1 GB',
    },
  ];

  // Mock data for backup schedules
  final List<Map<String, dynamic>> _schedules = [
    {
      'id': '1',
      'name': 'Daily Incremental',
      'type': 'incremental',
      'frequency': 'daily',
      'time': '02:00',
      'status': 'active',
      'retention': '30 days',
      'tables': ['users', 'destinations'],
      'lastRun': DateTime.now().subtract(const Duration(hours: 24)),
      'nextRun': DateTime.now().add(const Duration(hours: 2)),
    },
    {
      'id': '2',
      'name': 'Weekly Full Backup',
      'type': 'full',
      'frequency': 'weekly',
      'day': 'Sunday',
      'time': '03:00',
      'status': 'active',
      'retention': '90 days',
      'tables': ['users', 'destinations', 'itineraries', 'reviews'],
      'lastRun': DateTime.now().subtract(const Duration(days: 7)),
      'nextRun': DateTime.now().add(const Duration(days: 6, hours: 3)),
    },
    {
      'id': '3',
      'name': 'Monthly Archive',
      'type': 'full',
      'frequency': 'monthly',
      'day': '1st',
      'time': '04:00',
      'status': 'inactive',
      'retention': '1 year',
      'tables': ['users', 'destinations', 'itineraries', 'reviews'],
      'lastRun': DateTime.now().subtract(const Duration(days: 30)),
      'nextRun': DateTime.now().add(const Duration(days: 30)),
    },
  ];

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
                      'Backup & Recovery',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Text(
                      'Manage system backups and data recovery',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _createManualBackup,
                      icon: const Icon(Icons.backup),
                      label: const Text('Manual Backup'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _createRecoveryPoint,
                      icon: const Icon(Icons.restore),
                      label: const Text('Create Recovery Point'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Simple tabs
            Row(
              children: [
                _buildSimpleTab('Backups', 0),
                const SizedBox(width: 8),
                _buildSimpleTab('Recovery', 1),
                const SizedBox(width: 8),
                _buildSimpleTab('Schedules', 2),
                const SizedBox(width: 8),
                _buildSimpleTab('Settings', 3),
              ],
            ),
            const SizedBox(height: 24),
            // Content
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryTeal : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildBackupsTab();
      case 1:
        return _buildRecoveryTab();
      case 2:
        return _buildSchedulesTab();
      case 3:
        return _buildSettingsTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBackupsTab() {
    return Column(
      children: [
        // Stats
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Backups',
                _backups.length.toString(),
                Icons.backup,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Total Size',
                '4.7 GB',
                Icons.storage,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Last Backup',
                '6 hours ago',
                Icons.schedule,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Backups list
        Expanded(
          child: ListView.builder(
            itemCount: _backups.length,
            itemBuilder: (context, index) {
              final backup = _backups[index];
              return _buildBackupCard(backup);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupCard(Map<String, dynamic> backup) {
    final status = backup['status'] as String;
    final type = backup['type'] as String;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Completed';
        statusIcon = Icons.check_circle;
        break;
      case 'in_progress':
        statusColor = Colors.orange;
        statusText = 'In Progress';
        statusIcon = Icons.pending;
        break;
      case 'failed':
        statusColor = Colors.red;
        statusText = 'Failed';
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
        statusIcon = Icons.help;
    }

    Color typeColor;
    switch (type) {
      case 'full':
        typeColor = Colors.blue;
        break;
      case 'incremental':
        typeColor = Colors.green;
        break;
      default:
        typeColor = Colors.grey;
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        backup['name'],
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created: ${_formatTimestamp(backup['createdAt'])}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    _handleBackupAction(value, backup);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'view', child: Text('View Details')),
                    const PopupMenuItem(
                        value: 'download', child: Text('Download')),
                    const PopupMenuItem(
                        value: 'restore', child: Text('Restore')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSimpleStat('Size', backup['size']),
                const SizedBox(width: 24),
                _buildSimpleStat('Duration', backup['duration']),
                const SizedBox(width: 24),
                _buildSimpleStat('Compression', backup['compression']),
                const SizedBox(width: 24),
                _buildSimpleStat('Encryption', backup['encryption']),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: (backup['tables'] as List<String>).map((table) {
                return Chip(
                  label: Text(table),
                  backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: AppTheme.primaryTeal,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryTab() {
    return Column(
      children: [
        Text(
          'Recovery Points',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _recoveryPoints.length,
            itemBuilder: (context, index) {
              final recoveryPoint = _recoveryPoints[index];
              return _buildRecoveryPointCard(recoveryPoint);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecoveryPointCard(Map<String, dynamic> recoveryPoint) {
    final status = recoveryPoint['status'] as String;
    Color statusColor;
    String statusText;

    switch (status) {
      case 'available':
        statusColor = Colors.green;
        statusText = 'Available';
        break;
      case 'restoring':
        statusColor = Colors.orange;
        statusText = 'Restoring';
        break;
      default:
        statusColor = Colors.red;
        statusText = 'Unavailable';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recoveryPoint['name'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recoveryPoint['description'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Created: ${_formatTimestamp(recoveryPoint['createdAt'])}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recoveryPoint['size'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            FilledButton(
              onPressed: status == 'available'
                  ? () => _restoreFromPoint(recoveryPoint)
                  : null,
              child: const Text('Restore'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedulesTab() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Backup Schedules',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            FilledButton.icon(
              onPressed: _createSchedule,
              icon: const Icon(Icons.add),
              label: const Text('New Schedule'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _schedules.length,
            itemBuilder: (context, index) {
              final schedule = _schedules[index];
              return _buildScheduleCard(schedule);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    final status = schedule['status'] as String;
    final type = schedule['type'] as String;

    Color statusColor;
    String statusText;

    switch (status) {
      case 'active':
        statusColor = Colors.green;
        statusText = 'Active';
        break;
      case 'inactive':
        statusColor = Colors.grey;
        statusText = 'Inactive';
        break;
      default:
        statusColor = Colors.red;
        statusText = 'Error';
    }

    Color typeColor;
    switch (type) {
      case 'full':
        typeColor = Colors.blue;
        break;
      case 'incremental':
        typeColor = Colors.green;
        break;
      default:
        typeColor = Colors.grey;
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule['name'],
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${schedule['frequency']} $type backup',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    _handleScheduleAction(value, schedule);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'toggle', child: Text('Toggle')),
                    const PopupMenuItem(
                        value: 'run_now', child: Text('Run Now')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSimpleStat(
                    'Next Run', _formatTimestamp(schedule['nextRun'])),
                const SizedBox(width: 24),
                _buildSimpleStat('Retention', schedule['retention']),
                const SizedBox(width: 24),
                _buildSimpleStat(
                    'Last Run', _formatTimestamp(schedule['lastRun'])),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: (schedule['tables'] as List<String>).map((table) {
                return Chip(
                  label: Text(table),
                  backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: AppTheme.primaryTeal,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Backup Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 24),
          _buildSettingCard(
            'Storage',
            'Backup storage configuration',
            Icons.storage,
            [
              _buildSettingItem('Storage Location', 'Local Disk'),
              _buildSettingItem('Backup Path', '/backups/wanderwise'),
              _buildSettingItem('Max Storage', '50 GB'),
              _buildSettingItem('Compression', 'Enabled (gzip)'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            'Security',
            'Backup security and encryption',
            Icons.security,
            [
              _buildSettingItem('Encryption', 'Enabled (AES-256)'),
              _buildSettingItem('Encryption Key', 'Auto-generated'),
              _buildSettingItem('Key Rotation', '90 days'),
              _buildSettingItem('Access Control', 'Admin only'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            'Retention',
            'Backup retention policies',
            Icons.auto_delete,
            [
              _buildSettingItem('Daily Backups', '30 days'),
              _buildSettingItem('Weekly Backups', '90 days'),
              _buildSettingItem('Monthly Backups', '1 year'),
              _buildSettingItem('Auto Cleanup', 'Enabled'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(
      String title, String description, IconData icon, List<Widget> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryTeal, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  void _createManualBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Manual Backup'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Backup Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Manual backup started')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createRecoveryPoint() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recovery point created successfully')),
    );
  }

  void _handleBackupAction(String action, Map<String, dynamic> backup) {
    switch (action) {
      case 'view':
        _showBackupDetails(backup);
        break;
      case 'download':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download started')),
        );
        break;
      case 'restore':
        _restoreBackup(backup);
        break;
      case 'delete':
        _deleteBackup(backup);
        break;
    }
  }

  void _showBackupDetails(Map<String, dynamic> backup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(backup['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${backup['type']}'),
            const SizedBox(height: 8),
            Text('Size: ${backup['size']}'),
            const SizedBox(height: 8),
            Text('Duration: ${backup['duration']}'),
            const SizedBox(height: 8),
            Text('Created: ${_formatTimestamp(backup['createdAt'])}'),
            const SizedBox(height: 8),
            Text('Compression: ${backup['compression']}'),
            const SizedBox(height: 8),
            Text('Encryption: ${backup['encryption']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _restoreBackup(Map<String, dynamic> backup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: Text(
            'Are you sure you want to restore from "${backup['name']}"? This will overwrite current data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup restoration started')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _deleteBackup(Map<String, dynamic> backup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup'),
        content: Text(
            'Are you sure you want to delete "${backup['name']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup deleted successfully')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _restoreFromPoint(Map<String, dynamic> recoveryPoint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore from Recovery Point'),
        content: Text(
            'Are you sure you want to restore from "${recoveryPoint['name']}"? This will overwrite current data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recovery restoration started')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _createSchedule() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Create schedule functionality coming soon')),
    );
  }

  void _handleScheduleAction(String action, Map<String, dynamic> schedule) {
    switch (action) {
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Edit schedule functionality coming soon')),
        );
        break;
      case 'toggle':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule toggled')),
        );
        break;
      case 'run_now':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule executed now')),
        );
        break;
      case 'delete':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule deleted')),
        );
        break;
    }
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
