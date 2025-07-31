import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

enum AdvisorySeverity {
  info,
  warning,
  critical,
}

class TravelAdvisory {
  final String id;
  final String title;
  final String content;
  final String country;
  final String? region;
  final AdvisorySeverity severity;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final List<String> affectedTravelers;
  final DateTime createdAt;
  final DateTime updatedAt;

  TravelAdvisory({
    required this.id,
    required this.title,
    required this.content,
    required this.country,
    this.region,
    required this.severity,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
    required this.affectedTravelers,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isExpired => DateTime.now().isAfter(validUntil);
  bool get isActiveNow =>
      isActive && !isExpired && DateTime.now().isAfter(validFrom);
}

class TravelAdvisoriesScreen extends StatefulWidget {
  const TravelAdvisoriesScreen({super.key});

  @override
  State<TravelAdvisoriesScreen> createState() => _TravelAdvisoriesScreenState();
}

class _TravelAdvisoriesScreenState extends State<TravelAdvisoriesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCountry = 'All';
  String _selectedSeverity = 'All';
  String _selectedStatus = 'All';
  bool _isLoading = false;
  List<TravelAdvisory> _advisories = [];
  List<TravelAdvisory> _filteredAdvisories = [];

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

  final List<String> _severities = [
    'All',
    'Info',
    'Warning',
    'Critical',
  ];

  final List<String> _statuses = [
    'All',
    'Active',
    'Inactive',
    'Expired',
  ];

  @override
  void initState() {
    super.initState();
    _loadAdvisories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAdvisories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement getTravelAdvisories in SupabaseService
      // For now, using mock data
      final advisories = await _getMockAdvisories();

      setState(() {
        _advisories = advisories;
        _filteredAdvisories = advisories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading advisories: $e')),
        );
      }
    }
  }

  Future<List<TravelAdvisory>> _getMockAdvisories() async {
    // Mock data for development
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();

    return [
      TravelAdvisory(
        id: '1',
        title: 'Weather Alert - Heavy Rainfall',
        content:
            'Heavy rainfall expected in Paris region. Possible flooding in low-lying areas. Avoid travel to affected regions if possible.',
        country: 'France',
        region: 'Paris',
        severity: AdvisorySeverity.warning,
        validFrom: now.subtract(const Duration(days: 1)),
        validUntil: now.add(const Duration(days: 3)),
        isActive: true,
        affectedTravelers: ['traveler_1', 'traveler_2'],
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
      ),
      TravelAdvisory(
        id: '2',
        title: 'Transportation Strike',
        content:
            'Public transportation workers on strike in Rome. Limited metro and bus services. Plan alternative transportation.',
        country: 'Italy',
        region: 'Rome',
        severity: AdvisorySeverity.info,
        validFrom: now.subtract(const Duration(hours: 6)),
        validUntil: now.add(const Duration(days: 2)),
        isActive: true,
        affectedTravelers: ['traveler_3'],
        createdAt: now.subtract(const Duration(hours: 8)),
        updatedAt: now,
      ),
      TravelAdvisory(
        id: '3',
        title: 'Security Alert - Avoid Area',
        content:
            'Security incident reported in downtown area. Authorities advise avoiding the region until further notice.',
        country: 'Spain',
        region: 'Barcelona',
        severity: AdvisorySeverity.critical,
        validFrom: now.subtract(const Duration(hours: 2)),
        validUntil: now.add(const Duration(days: 1)),
        isActive: true,
        affectedTravelers: ['traveler_4', 'traveler_5', 'traveler_6'],
        createdAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now,
      ),
      TravelAdvisory(
        id: '4',
        title: 'COVID-19 Restrictions Updated',
        content:
            'New COVID-19 restrictions implemented. Masks required in all indoor public spaces. Check local guidelines.',
        country: 'Japan',
        severity: AdvisorySeverity.info,
        validFrom: now.subtract(const Duration(days: 5)),
        validUntil: now.add(const Duration(days: 30)),
        isActive: true,
        affectedTravelers: ['traveler_7', 'traveler_8'],
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now,
      ),
      TravelAdvisory(
        id: '5',
        title: 'Expired Advisory - Previous Weather Warning',
        content: 'This advisory has expired and is no longer active.',
        country: 'United States',
        region: 'Florida',
        severity: AdvisorySeverity.warning,
        validFrom: now.subtract(const Duration(days: 10)),
        validUntil: now.subtract(const Duration(days: 2)),
        isActive: false,
        affectedTravelers: [],
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  void _filterAdvisories() {
    setState(() {
      _filteredAdvisories = _advisories.where((advisory) {
        final matchesSearch = advisory.title
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            advisory.content.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesCountry =
            _selectedCountry == 'All' || advisory.country == _selectedCountry;

        final matchesSeverity = _selectedSeverity == 'All' ||
            advisory.severity.name.toUpperCase() ==
                _selectedSeverity.toUpperCase();

        bool matchesStatus = false;
        switch (_selectedStatus) {
          case 'All':
            matchesStatus = true;
            break;
          case 'Active':
            matchesStatus = advisory.isActiveNow;
            break;
          case 'Inactive':
            matchesStatus = !advisory.isActive;
            break;
          case 'Expired':
            matchesStatus = advisory.isExpired;
            break;
        }

        return matchesSearch &&
            matchesCountry &&
            matchesSeverity &&
            matchesStatus;
      }).toList();
    });
  }

  void _createNewAdvisory() {
    // TODO: Navigate to advisory creation screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Advisory creation coming soon!')),
    );
  }

  void _editAdvisory(TravelAdvisory advisory) {
    // TODO: Navigate to advisory editing screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing ${advisory.title} coming soon!')),
    );
  }

  void _toggleActiveStatus(TravelAdvisory advisory) {
    // TODO: Implement toggle functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${advisory.isActive ? 'Deactivating' : 'Activating'} ${advisory.title} coming soon!'),
      ),
    );
  }

  void _deleteAdvisory(TravelAdvisory advisory) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Advisory'),
        content: Text(
            'Are you sure you want to delete "${advisory.title}"? This action cannot be undone.'),
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
                    content: Text('Deleting ${advisory.title} coming soon!')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(AdvisorySeverity severity) {
    switch (severity) {
      case AdvisorySeverity.info:
        return Colors.blue;
      case AdvisorySeverity.warning:
        return Colors.orange;
      case AdvisorySeverity.critical:
        return Colors.red;
    }
  }

  IconData _getSeverityIcon(AdvisorySeverity severity) {
    switch (severity) {
      case AdvisorySeverity.info:
        return Icons.info;
      case AdvisorySeverity.warning:
        return Icons.warning;
      case AdvisorySeverity.critical:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Advisories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewAdvisory,
            tooltip: 'Create New Advisory',
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
                    hintText: 'Search advisories...',
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
                    _filterAdvisories();
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
                          _filterAdvisories();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSeverity,
                        decoration: InputDecoration(
                          labelText: 'Severity',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _severities.map((severity) {
                          return DropdownMenuItem(
                            value: severity,
                            child: Text(severity),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSeverity = value!;
                          });
                          _filterAdvisories();
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
                          _filterAdvisories();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Advisories List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAdvisories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.warning_amber,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No advisories found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your first travel advisory to get started',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredAdvisories.length,
                        itemBuilder: (context, index) {
                          final advisory = _filteredAdvisories[index];
                          return _AdvisoryCard(
                            advisory: advisory,
                            onEdit: () => _editAdvisory(advisory),
                            onToggleActive: () => _toggleActiveStatus(advisory),
                            onDelete: () => _deleteAdvisory(advisory),
                            getSeverityColor: _getSeverityColor,
                            getSeverityIcon: _getSeverityIcon,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _AdvisoryCard extends StatelessWidget {
  final TravelAdvisory advisory;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;
  final Color Function(AdvisorySeverity) getSeverityColor;
  final IconData Function(AdvisorySeverity) getSeverityIcon;

  const _AdvisoryCard({
    required this.advisory,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
    required this.getSeverityColor,
    required this.getSeverityIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severityColor = getSeverityColor(advisory.severity);
    final severityIcon = getSeverityIcon(advisory.severity);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: severityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    severityIcon,
                    color: severityColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              advisory.title,
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
                              color: advisory.isActiveNow
                                  ? Colors.green.withOpacity(0.1)
                                  : advisory.isExpired
                                      ? Colors.grey.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              advisory.isActiveNow
                                  ? 'Active'
                                  : advisory.isExpired
                                      ? 'Expired'
                                      : 'Inactive',
                              style: TextStyle(
                                fontSize: 12,
                                color: advisory.isActiveNow
                                    ? Colors.green[700]
                                    : advisory.isExpired
                                        ? Colors.grey[700]
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: severityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              advisory.severity.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: severityColor,
                                fontWeight: FontWeight.w500,
                              ),
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
                            advisory.region != null
                                ? '${advisory.region}, ${advisory.country}'
                                : advisory.country,
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
                          Text('Edit Advisory'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(advisory.isActive
                              ? Icons.visibility_off
                              : Icons.visibility),
                          const SizedBox(width: 8),
                          Text(advisory.isActive ? 'Deactivate' : 'Activate'),
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
            // Content
            Text(
              advisory.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            // Validity Period
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Valid Period',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '${_formatDate(advisory.validFrom)} - ${_formatDate(advisory.validUntil)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (advisory.affectedTravelers.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${advisory.affectedTravelers.length} travelers',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
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
                      advisory.isActive
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 18,
                    ),
                    label: Text(advisory.isActive ? 'Deactivate' : 'Activate'),
                    style: FilledButton.styleFrom(
                      backgroundColor: advisory.isActive
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
