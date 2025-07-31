import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ApiManagementScreen extends StatefulWidget {
  const ApiManagementScreen({super.key});

  @override
  State<ApiManagementScreen> createState() => _ApiManagementScreenState();
}

class _ApiManagementScreenState extends State<ApiManagementScreen> {
  int _selectedTabIndex = 0;

  // Mock data for API keys
  final List<Map<String, dynamic>> _apiKeys = [
    {
      'id': '1',
      'name': 'Mobile App API Key',
      'key': 'sk_live_1234567890abcdef',
      'status': 'active',
      'permissions': ['read', 'write'],
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
      'lastUsed': DateTime.now().subtract(const Duration(hours: 2)),
      'usageCount': 15420,
      'rateLimit': 1000,
      'expiresAt': DateTime.now().add(const Duration(days: 365)),
    },
    {
      'id': '2',
      'name': 'Web App API Key',
      'key': 'sk_live_abcdef1234567890',
      'status': 'active',
      'permissions': ['read', 'write', 'admin'],
      'createdAt': DateTime.now().subtract(const Duration(days: 15)),
      'lastUsed': DateTime.now().subtract(const Duration(minutes: 30)),
      'usageCount': 8920,
      'rateLimit': 5000,
      'expiresAt': DateTime.now().add(const Duration(days: 180)),
    },
    {
      'id': '3',
      'name': 'Third-party Integration',
      'key': 'sk_test_9876543210fedcba',
      'status': 'inactive',
      'permissions': ['read'],
      'createdAt': DateTime.now().subtract(const Duration(days: 7)),
      'lastUsed': DateTime.now().subtract(const Duration(days: 5)),
      'usageCount': 120,
      'rateLimit': 100,
      'expiresAt': DateTime.now().add(const Duration(days: 90)),
    },
  ];

  // Mock data for API endpoints
  final List<Map<String, dynamic>> _endpoints = [
    {
      'path': '/api/v1/users',
      'method': 'GET',
      'description': 'Get all users',
      'status': 'active',
      'rateLimit': 100,
      'responseTime': 150,
      'successRate': 99.8,
      'lastUpdated': DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      'path': '/api/v1/users',
      'method': 'POST',
      'description': 'Create new user',
      'status': 'active',
      'rateLimit': 50,
      'responseTime': 200,
      'successRate': 98.5,
      'lastUpdated': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'path': '/api/v1/destinations',
      'method': 'GET',
      'description': 'Get destinations',
      'status': 'active',
      'rateLimit': 200,
      'responseTime': 120,
      'successRate': 99.9,
      'lastUpdated': DateTime.now().subtract(const Duration(minutes: 30)),
    },
    {
      'path': '/api/v1/itineraries',
      'method': 'POST',
      'description': 'Create itinerary',
      'status': 'maintenance',
      'rateLimit': 25,
      'responseTime': 300,
      'successRate': 95.2,
      'lastUpdated': DateTime.now().subtract(const Duration(hours: 6)),
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
                      'API Management',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Text(
                      'Manage API keys, endpoints, and monitor usage',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: _createNewApiKey,
                  icon: const Icon(Icons.add),
                  label: const Text('New API Key'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Simple tabs
            Row(
              children: [
                _buildSimpleTab('API Keys', 0),
                const SizedBox(width: 8),
                _buildSimpleTab('Endpoints', 1),
                const SizedBox(width: 8),
                _buildSimpleTab('Analytics', 2),
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
        return _buildApiKeysTab();
      case 1:
        return _buildEndpointsTab();
      case 2:
        return _buildAnalyticsTab();
      case 3:
        return _buildSettingsTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildApiKeysTab() {
    return Column(
      children: [
        // Search
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search API keys...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        // API Keys List
        Expanded(
          child: ListView.builder(
            itemCount: _apiKeys.length,
            itemBuilder: (context, index) {
              final apiKey = _apiKeys[index];
              return _buildApiKeyCard(apiKey);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildApiKeyCard(Map<String, dynamic> apiKey) {
    final status = apiKey['status'] as String;
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
        statusText = 'Expired';
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
                        apiKey['name'],
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Key: ${apiKey['key'].substring(0, 12)}...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontFamily: 'monospace',
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
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
                    _handleApiKeyAction(value, apiKey);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'view', child: Text('View Details')),
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'regenerate', child: Text('Regenerate Key')),
                    const PopupMenuItem(value: 'revoke', child: Text('Revoke')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSimpleStat('Usage', '${apiKey['usageCount']} requests'),
                const SizedBox(width: 24),
                _buildSimpleStat('Rate Limit', '${apiKey['rateLimit']}/hour'),
                const SizedBox(width: 24),
                _buildSimpleStat(
                    'Last Used', _formatTimestamp(apiKey['lastUsed'])),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  (apiKey['permissions'] as List<String>).map((permission) {
                return Chip(
                  label: Text(permission),
                  backgroundColor: AppTheme.primaryTeal.withValues(alpha: 0.1),
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

  Widget _buildEndpointsTab() {
    return Column(
      children: [
        Text(
          'API Endpoints',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _endpoints.length,
            itemBuilder: (context, index) {
              final endpoint = _endpoints[index];
              return _buildEndpointCard(endpoint);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEndpointCard(Map<String, dynamic> endpoint) {
    final method = endpoint['method'] as String;
    final status = endpoint['status'] as String;

    Color methodColor;
    switch (method) {
      case 'GET':
        methodColor = Colors.green;
        break;
      case 'POST':
        methodColor = Colors.blue;
        break;
      case 'PUT':
        methodColor = Colors.orange;
        break;
      case 'DELETE':
        methodColor = Colors.red;
        break;
      default:
        methodColor = Colors.grey;
    }

    Color statusColor;
    switch (status) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'maintenance':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: methodColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                method,
                style: TextStyle(
                  color: methodColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    endpoint['path'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontFamily: 'monospace',
                        ),
                  ),
                  Text(
                    endpoint['description'],
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
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${endpoint['responseTime']}ms',
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

  Widget _buildAnalyticsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Usage Analytics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Text(
            'Analytics dashboard coming soon',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'API Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 24),
          _buildSettingCard(
            'Rate Limiting',
            'Configure global rate limits for API endpoints',
            Icons.speed,
            [
              _buildSettingItem('Default Rate Limit', '1000 requests/hour'),
              _buildSettingItem('Burst Limit', '100 requests/minute'),
              _buildSettingItem('Rate Limit Window', '1 hour'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            'Security',
            'API security and authentication settings',
            Icons.security,
            [
              _buildSettingItem('Require API Key', 'Enabled'),
              _buildSettingItem('CORS Origins', '*.wanderwise.com'),
              _buildSettingItem('IP Whitelist', 'Not configured'),
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

  void _createNewApiKey() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New API Key'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'API Key Name',
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
                const SnackBar(content: Text('API key created successfully')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _handleApiKeyAction(String action, Map<String, dynamic> apiKey) {
    switch (action) {
      case 'view':
        _showApiKeyDetails(apiKey);
        break;
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Edit API key functionality coming soon')),
        );
        break;
      case 'regenerate':
        _regenerateApiKey(apiKey);
        break;
      case 'revoke':
        _revokeApiKey(apiKey);
        break;
    }
  }

  void _showApiKeyDetails(Map<String, dynamic> apiKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(apiKey['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('API Key: ${apiKey['key']}'),
            const SizedBox(height: 8),
            Text('Status: ${apiKey['status']}'),
            const SizedBox(height: 8),
            Text('Created: ${_formatDate(apiKey['createdAt'])}'),
            const SizedBox(height: 8),
            Text('Expires: ${_formatDate(apiKey['expiresAt'])}'),
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

  void _regenerateApiKey(Map<String, dynamic> apiKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regenerate API Key'),
        content: const Text(
            'Are you sure you want to regenerate this API key? This will invalidate the current key.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('API key regenerated successfully')),
              );
            },
            child: const Text('Regenerate'),
          ),
        ],
      ),
    );
  }

  void _revokeApiKey(Map<String, dynamic> apiKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke API Key'),
        content: const Text(
            'Are you sure you want to revoke this API key? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('API key revoked successfully')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Revoke'),
          ),
        ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
