import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class EnhancedAnalyticsScreen extends StatefulWidget {
  const EnhancedAnalyticsScreen({super.key});

  @override
  State<EnhancedAnalyticsScreen> createState() =>
      _EnhancedAnalyticsScreenState();
}

class _EnhancedAnalyticsScreenState extends State<EnhancedAnalyticsScreen> {
  String _selectedPeriod = 'Last 30 Days';
  String _selectedMetric = 'All Metrics';
  bool _isLoading = false;

  final List<String> _periods = [
    'Last 7 Days',
    'Last 30 Days',
    'Last 90 Days',
    'Last 6 Months',
    'Last Year',
  ];

  final List<String> _metrics = [
    'All Metrics',
    'User Growth',
    'Content Performance',
    'Revenue',
    'Engagement',
  ];

  // Mock data for analytics
  final Map<String, dynamic> _analyticsData = {
    'userGrowth': {
      'totalUsers': 15420,
      'newUsers': 1247,
      'activeUsers': 8923,
      'growthRate': 12.5,
      'retentionRate': 78.3,
    },
    'contentPerformance': {
      'totalDestinations': 342,
      'totalItineraries': 1567,
      'totalReviews': 8923,
      'avgRating': 4.2,
      'contentViews': 45678,
    },
    'revenue': {
      'totalRevenue': 125430,
      'monthlyRevenue': 15420,
      'avgOrderValue': 89.50,
      'conversionRate': 3.2,
      'revenueGrowth': 18.7,
    },
    'engagement': {
      'totalSessions': 89234,
      'avgSessionDuration': 8.5,
      'bounceRate': 23.4,
      'pageViews': 234567,
      'userEngagement': 67.8,
    },
  };

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement getEnhancedAnalytics in SupabaseService
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            tooltip: 'Refresh Analytics',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Implement export functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Export functionality coming soon!')),
              );
            },
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filters
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedPeriod,
                              decoration: const InputDecoration(
                                labelText: 'Time Period',
                                border: OutlineInputBorder(),
                              ),
                              items: _periods.map((period) {
                                return DropdownMenuItem(
                                  value: period,
                                  child: Text(period),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPeriod = value!;
                                });
                                _loadAnalytics();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedMetric,
                              decoration: const InputDecoration(
                                labelText: 'Metric Focus',
                                border: OutlineInputBorder(),
                              ),
                              items: _metrics.map((metric) {
                                return DropdownMenuItem(
                                  value: metric,
                                  child: Text(metric),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedMetric = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Key Metrics Overview
                  Text(
                    'Key Metrics Overview',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildKeyMetricsGrid(),
                  const SizedBox(height: 24),

                  // User Growth Analytics
                  _buildAnalyticsSection(
                    title: 'User Growth Analytics',
                    icon: Icons.trending_up,
                    children: [
                      _buildMetricCard(
                        title: 'Total Users',
                        value: _analyticsData['userGrowth']['totalUsers']
                            .toString(),
                        subtitle: 'All time registered users',
                        icon: Icons.people,
                        color: Colors.blue,
                      ),
                      _buildMetricCard(
                        title: 'New Users',
                        value:
                            _analyticsData['userGrowth']['newUsers'].toString(),
                        subtitle: 'Users joined this period',
                        icon: Icons.person_add,
                        color: Colors.green,
                      ),
                      _buildMetricCard(
                        title: 'Active Users',
                        value: _analyticsData['userGrowth']['activeUsers']
                            .toString(),
                        subtitle: 'Users active this period',
                        icon: Icons.online_prediction,
                        color: Colors.orange,
                      ),
                      _buildMetricCard(
                        title: 'Growth Rate',
                        value: '${_analyticsData['userGrowth']['growthRate']}%',
                        subtitle: 'Month-over-month growth',
                        icon: Icons.trending_up,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Content Performance
                  _buildAnalyticsSection(
                    title: 'Content Performance',
                    icon: Icons.article,
                    children: [
                      _buildMetricCard(
                        title: 'Total Destinations',
                        value: _analyticsData['contentPerformance']
                                ['totalDestinations']
                            .toString(),
                        subtitle: 'Published destinations',
                        icon: Icons.location_on,
                        color: Colors.indigo,
                      ),
                      _buildMetricCard(
                        title: 'Total Itineraries',
                        value: _analyticsData['contentPerformance']
                                ['totalItineraries']
                            .toString(),
                        subtitle: 'Created itineraries',
                        icon: Icons.map,
                        color: Colors.teal,
                      ),
                      _buildMetricCard(
                        title: 'Total Reviews',
                        value: _analyticsData['contentPerformance']
                                ['totalReviews']
                            .toString(),
                        subtitle: 'User reviews submitted',
                        icon: Icons.rate_review,
                        color: Colors.amber,
                      ),
                      _buildMetricCard(
                        title: 'Average Rating',
                        value: _analyticsData['contentPerformance']['avgRating']
                            .toString(),
                        subtitle: 'Overall platform rating',
                        icon: Icons.star,
                        color: Colors.yellow[700]!,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Revenue Analytics
                  _buildAnalyticsSection(
                    title: 'Revenue Analytics',
                    icon: Icons.attach_money,
                    children: [
                      _buildMetricCard(
                        title: 'Total Revenue',
                        value:
                            '\$${_analyticsData['revenue']['totalRevenue'].toString()}',
                        subtitle: 'All time revenue',
                        icon: Icons.account_balance_wallet,
                        color: Colors.green,
                      ),
                      _buildMetricCard(
                        title: 'Monthly Revenue',
                        value:
                            '\$${_analyticsData['revenue']['monthlyRevenue'].toString()}',
                        subtitle: 'Revenue this month',
                        icon: Icons.monetization_on,
                        color: Colors.lightGreen,
                      ),
                      _buildMetricCard(
                        title: 'Avg Order Value',
                        value:
                            '\$${_analyticsData['revenue']['avgOrderValue'].toString()}',
                        subtitle: 'Average transaction value',
                        icon: Icons.shopping_cart,
                        color: Colors.blue,
                      ),
                      _buildMetricCard(
                        title: 'Conversion Rate',
                        value:
                            '${_analyticsData['revenue']['conversionRate']}%',
                        subtitle: 'Visitor to customer rate',
                        icon: Icons.transform,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Engagement Analytics
                  _buildAnalyticsSection(
                    title: 'Engagement Analytics',
                    icon: Icons.analytics,
                    children: [
                      _buildMetricCard(
                        title: 'Total Sessions',
                        value: _analyticsData['engagement']['totalSessions']
                            .toString(),
                        subtitle: 'User sessions this period',
                        icon: Icons.visibility,
                        color: Colors.cyan,
                      ),
                      _buildMetricCard(
                        title: 'Avg Session Duration',
                        value:
                            '${_analyticsData['engagement']['avgSessionDuration']} min',
                        subtitle: 'Average time on platform',
                        icon: Icons.timer,
                        color: Colors.deepOrange,
                      ),
                      _buildMetricCard(
                        title: 'Bounce Rate',
                        value: '${_analyticsData['engagement']['bounceRate']}%',
                        subtitle: 'Single-page sessions',
                        icon: Icons.exit_to_app,
                        color: Colors.red,
                      ),
                      _buildMetricCard(
                        title: 'User Engagement',
                        value:
                            '${_analyticsData['engagement']['userEngagement']}%',
                        subtitle: 'Engagement score',
                        icon: Icons.psychology,
                        color: Colors.pink,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Top Performing Content
                  _buildAnalyticsSection(
                    title: 'Top Performing Content',
                    icon: Icons.leaderboard,
                    children: [
                      _buildTopContentList(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Activity
                  _buildAnalyticsSection(
                    title: 'Recent Activity',
                    icon: Icons.history,
                    children: [
                      _buildRecentActivityList(),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildKeyMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildKeyMetricCard(
          title: 'Total Revenue',
          value: '\$${_analyticsData['revenue']['totalRevenue']}',
          change: '+${_analyticsData['revenue']['revenueGrowth']}%',
          isPositive: true,
          color: Colors.green,
        ),
        _buildKeyMetricCard(
          title: 'Active Users',
          value: _analyticsData['userGrowth']['activeUsers'].toString(),
          change: '+${_analyticsData['userGrowth']['growthRate']}%',
          isPositive: true,
          color: Colors.blue,
        ),
        _buildKeyMetricCard(
          title: 'Content Views',
          value:
              _analyticsData['contentPerformance']['contentViews'].toString(),
          change: '+15.2%',
          isPositive: true,
          color: Colors.orange,
        ),
        _buildKeyMetricCard(
          title: 'Avg Rating',
          value: _analyticsData['contentPerformance']['avgRating'].toString(),
          change: '+0.3',
          isPositive: true,
          color: Colors.amber,
        ),
      ],
    );
  }

  Widget _buildKeyMetricCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  change,
                  style: TextStyle(
                    fontSize: 12,
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryTeal),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: children,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopContentList() {
    final topContent = [
      {'title': 'Paris Family Adventure', 'views': 2345, 'rating': 4.8},
      {'title': 'Rome Cultural Tour', 'views': 1987, 'rating': 4.7},
      {'title': 'Barcelona Beach Getaway', 'views': 1654, 'rating': 4.6},
      {'title': 'Tokyo Urban Experience', 'views': 1432, 'rating': 4.5},
    ];

    return Column(
      children: topContent.asMap().entries.map((entry) {
        final index = entry.key;
        final content = entry.value;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryTeal,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(content['title'] as String),
          subtitle: Text('${content['views']} views'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(content['rating'].toString()),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivityList() {
    final activities = [
      {
        'action': 'New user registered',
        'user': 'john.doe@email.com',
        'time': '2 minutes ago'
      },
      {
        'action': 'Review submitted',
        'user': 'sarah.smith@email.com',
        'time': '5 minutes ago'
      },
      {
        'action': 'Itinerary created',
        'user': 'mike.chen@email.com',
        'time': '12 minutes ago'
      },
      {
        'action': 'Payment processed',
        'user': 'lisa.brown@email.com',
        'time': '18 minutes ago'
      },
      {
        'action': 'Destination added',
        'user': 'admin@wanderwise.com',
        'time': '25 minutes ago'
      },
    ];

    return Column(
      children: activities.map((activity) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: Icon(Icons.person, color: Colors.grey[600]),
          ),
          title: Text(activity['action'] as String),
          subtitle: Text(activity['user'] as String),
          trailing: Text(
            activity['time'] as String,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        );
      }).toList(),
    );
  }
}
