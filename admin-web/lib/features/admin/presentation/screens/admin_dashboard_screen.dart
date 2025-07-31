import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/widgets/app_logo.dart';
import 'users_management_screen.dart';
import 'analytics_screen.dart';

import '../../../travel_agent/presentation/screens/traveler_management_screen.dart';
import '../../../travel_agent/presentation/screens/itinerary_templates_screen.dart';
import '../../../content/presentation/screens/travel_tips_screen.dart';
import '../../../content/presentation/screens/travel_advisories_screen.dart';
import '../../../content/presentation/screens/destination_management_screen.dart';
import '../../../content/presentation/screens/review_moderation_screen.dart';
import 'system_settings_screen.dart';
import 'enhanced_analytics_screen.dart';
import 'notifications_campaigns_screen.dart';
import 'document_management_screen.dart';
import 'advanced_search_screen.dart';
import 'user_activity_logs_screen.dart';
import 'api_management_screen.dart';
import 'backup_recovery_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String adminEmail;

  const AdminDashboardScreen({
    super.key,
    required this.adminEmail,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  User? _currentUser;
  List<Widget> _screens = [];
  List<Map<String, dynamic>> _navItems = [];
  Set<String> _expandedGroups = <String>{};

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await SupabaseService.getUserById(
          SupabaseService.getCurrentUser()?.id ?? '');
      if (user != null) {
        setState(() {
          _currentUser = user;
          _setupNavigation(user);
        });
      }
    } catch (e) {
      // Error loading current user
    }
  }

  void _setupNavigation(User user) {
    _screens = [const DashboardOverview()];
    _navItems = [
      {
        'icon': Icons.dashboard,
        'title': 'Dashboard',
        'index': 0,
        'type': 'main'
      },
    ];

    // Helper function to check if a navigation group already exists
    bool hasNavGroup(String title) {
      return _navItems.any((item) => item['title'] == title);
    }

    // Helper function to add screens and return their indices
    List<int> addScreens(List<Widget> screens) {
      final startIndex = _screens.length;
      _screens.addAll(screens);
      return List.generate(screens.length, (i) => startIndex + i);
    }

    // Add role-based navigation items with grouping
    if (user.hasRole(UserRole.admin)) {
      // User Management
      final userIndices = addScreens([
        const UsersManagementScreen(),
        const AnalyticsScreen(),
      ]);
      _navItems.addAll([
        {
          'icon': Icons.people,
          'title': 'Users',
          'index': userIndices[0],
          'type': 'main'
        },
        {
          'icon': Icons.analytics,
          'title': 'Analytics',
          'index': userIndices[1],
          'type': 'main'
        },
      ]);

      // System Administration Group
      _screens.addAll([
        const SystemSettingsScreen(),
        const ApiManagementScreen(),
        const BackupRecoveryScreen(),
        const UserActivityLogsScreen(),
      ]);
      _navItems.addAll([
        {
          'icon': Icons.settings,
          'title': 'System Administration',
          'type': 'group',
          'children': [
            {'icon': Icons.settings, 'title': 'System Settings', 'index': 3},
            {'icon': Icons.api, 'title': 'API Management', 'index': 4},
            {'icon': Icons.backup, 'title': 'Backup & Recovery', 'index': 5},
            {'icon': Icons.history, 'title': 'Activity Logs', 'index': 6},
          ]
        },
      ]);

      // Content Management Group
      _screens.addAll([
        const TravelTipsScreen(),
        const TravelAdvisoriesScreen(),
        const DestinationManagementScreen(),
        const ReviewModerationScreen(),
      ]);
      _navItems.addAll([
        {
          'icon': Icons.edit,
          'title': 'Content Management',
          'type': 'group',
          'children': [
            {
              'icon': Icons.tips_and_updates,
              'title': 'Travel Tips',
              'index': 7
            },
            {
              'icon': Icons.warning_amber,
              'title': 'Travel Advisories',
              'index': 8
            },
            {'icon': Icons.location_on, 'title': 'Destinations', 'index': 9},
            {
              'icon': Icons.rate_review,
              'title': 'Review Moderation',
              'index': 10
            },
          ]
        },
      ]);

      // Communications Group
      _screens.addAll([
        const NotificationsCampaignsScreen(),
        const DocumentManagementScreen(),
      ]);
      _navItems.addAll([
        {
          'icon': Icons.campaign,
          'title': 'Communications',
          'type': 'group',
          'children': [
            {
              'icon': Icons.campaign,
              'title': 'Notifications & Campaigns',
              'index': 11
            },
            {'icon': Icons.folder, 'title': 'Document Management', 'index': 12},
          ]
        },
      ]);

      // Enhanced Analytics (separate main item)
      _screens.add(const EnhancedAnalyticsScreen());
      _navItems.add({
        'icon': Icons.insights,
        'title': 'Enhanced Analytics',
        'index': 13,
        'type': 'main'
      });
    }

    // Content management for editors and content editors (only if not admin and not travel agent)
    if ((user.hasRole(UserRole.editor) ||
            user.hasRole(UserRole.contentEditor)) &&
        !user.hasRole(UserRole.admin) &&
        !user.hasRole(UserRole.travelAgent)) {
      if (!hasNavGroup('Content Management')) {
        final contentIndices = addScreens([
          const TravelTipsScreen(),
          const TravelAdvisoriesScreen(),
          const DestinationManagementScreen(),
          const ReviewModerationScreen(),
        ]);
        _navItems.add({
          'icon': Icons.edit,
          'title': 'Content Management',
          'type': 'group',
          'children': [
            {
              'icon': Icons.tips_and_updates,
              'title': 'Travel Tips',
              'index': contentIndices[0]
            },
            {
              'icon': Icons.warning_amber,
              'title': 'Travel Advisories',
              'index': contentIndices[1]
            },
            {
              'icon': Icons.location_on,
              'title': 'Destinations',
              'index': contentIndices[2]
            },
            {
              'icon': Icons.rate_review,
              'title': 'Review Moderation',
              'index': contentIndices[3]
            },
          ]
        });
      }

      if (!hasNavGroup('Communications')) {
        final docIndex = addScreens([const DocumentManagementScreen()])[0];
        _navItems.add({
          'icon': Icons.campaign,
          'title': 'Communications',
          'type': 'group',
          'children': [
            {
              'icon': Icons.folder,
              'title': 'Document Management',
              'index': docIndex
            },
          ]
        });
      }
    }

    // Travel agent specific features (only if not admin)
    if (user.hasRole(UserRole.travelAgent) && !user.hasRole(UserRole.admin)) {
      // 1. Client Management Group (First Priority)
      final clientIndices = addScreens([
        const TravelerManagementScreen(),
        const ItineraryTemplatesScreen(),
      ]);
      _navItems.add({
        'icon': Icons.people_outline,
        'title': 'Client Management',
        'type': 'group',
        'children': [
          {
            'icon': Icons.people_outline,
            'title': 'My Travelers',
            'index': clientIndices[0]
          },
          {
            'icon': Icons.map,
            'title': 'Itinerary Templates',
            'index': clientIndices[1]
          },
        ]
      });

      // 2. Content Management Group (Second Priority)
      if (!hasNavGroup('Content Management')) {
        final contentIndices = addScreens([
          const TravelTipsScreen(),
          const TravelAdvisoriesScreen(),
          const DestinationManagementScreen(),
          const ReviewModerationScreen(),
        ]);
        _navItems.add({
          'icon': Icons.edit,
          'title': 'Content Management',
          'type': 'group',
          'children': [
            {
              'icon': Icons.tips_and_updates,
              'title': 'Travel Tips',
              'index': contentIndices[0]
            },
            {
              'icon': Icons.warning_amber,
              'title': 'Travel Advisories',
              'index': contentIndices[1]
            },
            {
              'icon': Icons.location_on,
              'title': 'Destinations',
              'index': contentIndices[2]
            },
            {
              'icon': Icons.rate_review,
              'title': 'Reviews & Moderation',
              'index': contentIndices[3]
            },
          ]
        });
      }

      // 3. Communications Group (Third Priority) - Complete with both items
      if (!hasNavGroup('Communications')) {
        final commIndices = addScreens([
          const NotificationsCampaignsScreen(),
          const DocumentManagementScreen(),
        ]);
        _navItems.add({
          'icon': Icons.campaign,
          'title': 'Communications',
          'type': 'group',
          'children': [
            {
              'icon': Icons.campaign,
              'title': 'Notifications & Campaigns',
              'index': commIndices[0]
            },
            {
              'icon': Icons.folder,
              'title': 'Document Management',
              'index': commIndices[1]
            },
          ]
        });
      }
    }

    // Add logout to all users
    _navItems.add(
        {'icon': Icons.logout, 'title': 'Logout', 'index': -1, 'type': 'main'});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryTeal,
                        AppTheme.accentBlue,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const AppLogo(
                            size: 40,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'WanderWise',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Admin Panel',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      ..._navItems.map((item) {
                        final type = item['type'] as String;
                        final index = item['index'] as int?;
                        final isLogout = index == -1;

                        if (isLogout) {
                          return Column(
                            children: [
                              const Divider(height: 32),
                              _buildNavItem(
                                icon: item['icon'] as IconData,
                                title: item['title'] as String,
                                index: index ?? -1,
                                onTap: _handleLogout,
                              ),
                            ],
                          );
                        }

                        if (type == 'group') {
                          return _buildGroupedNavItem(item);
                        }

                        return _buildNavItem(
                          icon: item['icon'] as IconData,
                          title: item['title'] as String,
                          index: index ?? 0,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Navigation Bar
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Page Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _navItems.isNotEmpty &&
                                  _selectedIndex < _navItems.length
                              ? _navItems[_selectedIndex]['title'] as String
                              : 'Dashboard',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Search Bar
                      Container(
                        width: 300,
                        height: 40,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search across all content...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon:
                                Icon(Icons.search, color: Colors.grey[500]),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AdvancedSearchScreen(),
                              ),
                            );
                          },
                          readOnly: true,
                        ),
                      ),
                      // Language Selector
                      Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: PopupMenuButton<String>(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.language,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text('EN',
                                    style: TextStyle(color: Colors.grey[600])),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_drop_down,
                                    size: 16, color: Colors.grey[600]),
                              ],
                            ),
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'en', child: Text('English')),
                            const PopupMenuItem(
                                value: 'fr', child: Text('Français')),
                            const PopupMenuItem(
                                value: 'es', child: Text('Español')),
                          ],
                          onSelected: (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Language changed to $value')),
                            );
                          },
                        ),
                      ),
                      // Notifications
                      Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: Stack(
                          children: [
                            IconButton(
                              icon: Icon(Icons.notifications,
                                  color: Colors.grey[600]),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Notifications coming soon!')),
                                );
                              },
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // User Menu
                      Container(
                        margin: const EdgeInsets.only(right: 24),
                        child: PopupMenuButton<String>(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                    AppTheme.primaryTeal.withValues(alpha: 0.1),
                                child: _currentUser?.photoUrl != null
                                    ? ClipOval(
                                        child: Image.network(
                                          _currentUser!.photoUrl!,
                                          width: 32,
                                          height: 32,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(
                                              Icons.person,
                                              color: AppTheme.primaryTeal,
                                              size: 16,
                                            );
                                          },
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        color: AppTheme.primaryTeal,
                                        size: 16,
                                      ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _currentUser?.name ?? 'User',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_drop_down,
                                  color: Colors.grey[600]),
                            ],
                          ),
                          onSelected: (value) {
                            switch (value) {
                              case 'profile':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileScreen(),
                                  ),
                                );
                                break;
                              case 'settings':
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Settings coming soon!'),
                                  ),
                                );
                                break;
                              case 'help':
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Help & support coming soon!'),
                                  ),
                                );
                                break;
                              case 'logout':
                                _handleLogout();
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'profile',
                              child: Row(
                                children: [
                                  Icon(Icons.person,
                                      size: 20, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  const Text('Profile'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'settings',
                              child: Row(
                                children: [
                                  Icon(Icons.settings,
                                      size: 20, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  const Text('Settings'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'help',
                              child: Row(
                                children: [
                                  Icon(Icons.help,
                                      size: 20, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  const Text('Help & Support'),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(Icons.logout,
                                      size: 20, color: Colors.red[600]),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Logout',
                                    style: TextStyle(color: Colors.red[600]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Main Content Area
                Expanded(
                  child: _screens.isNotEmpty && _selectedIndex < _screens.length
                      ? _screens[_selectedIndex]
                      : const Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required int index,
    VoidCallback? onTap,
  }) {
    final isSelected = _selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryTeal : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryTeal : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppTheme.primaryTeal.withValues(alpha: 0.1),
      onTap: onTap ??
          () {
            setState(() {
              _selectedIndex = index;
            });
          },
    );
  }

  Future<void> _handleLogout() async {
    try {
      // Sign out from Supabase
      await SupabaseService.signOut();

      if (mounted) {
        // Navigate back to login screen
        Navigator.of(context).pushReplacementNamed('/');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildGroupedNavItem(Map<String, dynamic> item) {
    final children = item['children'] as List<Map<String, dynamic>>;
    final isExpanded = _expandedGroups.contains(item['title'] as String);

    return ExpansionTile(
      leading: Icon(
        item['icon'] as IconData,
        color: _selectedIndex == -1 ? AppTheme.primaryTeal : Colors.grey[600],
        size: 24,
      ),
      title: Text(
        item['title'] as String,
        style: TextStyle(
          color: _selectedIndex == -1 ? AppTheme.primaryTeal : Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        isExpanded ? Icons.expand_less : Icons.expand_more,
        color: Colors.grey[600],
        size: 20,
      ),
      initiallyExpanded: isExpanded,
      onExpansionChanged: (expanded) {
        setState(() {
          if (expanded) {
            _expandedGroups.add(item['title'] as String);
          } else {
            _expandedGroups.remove(item['title'] as String);
          }
        });
      },
      children: children.map((child) {
        final childIndex = child['index'] as int?;
        if (childIndex == null) return const SizedBox.shrink();

        final isSelected = _selectedIndex == childIndex;

        return Container(
          margin: const EdgeInsets.only(left: 16),
          child: ListTile(
            leading: Icon(
              child['icon'] as IconData,
              color: isSelected ? AppTheme.primaryTeal : Colors.grey[600],
              size: 20,
            ),
            title: Text(
              child['title'] as String,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryTeal : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            selected: isSelected,
            selectedTileColor: AppTheme.primaryTeal.withValues(alpha: 0.1),
            onTap: () {
              setState(() {
                _selectedIndex = childIndex;
              });
            },
          ),
        );
      }).toList(),
    );
  }
}

class DashboardOverview extends StatelessWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
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
                      'Dashboard Overview',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Welcome back! Here\'s what\'s happening with WanderWise.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.primaryTeal,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Today',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Stats Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  title: 'Total Users',
                  value: '1,247',
                  change: '+12%',
                  isPositive: true,
                  icon: Icons.people,
                  color: AppTheme.primaryTeal,
                ),
                _buildStatCard(
                  title: 'Destinations',
                  value: '156',
                  change: '+5%',
                  isPositive: true,
                  icon: Icons.location_on,
                  color: AppTheme.accentBlue,
                ),
                _buildStatCard(
                  title: 'Itineraries',
                  value: '89',
                  change: '+8%',
                  isPositive: true,
                  icon: Icons.map,
                  color: AppTheme.secondaryOrange,
                ),
                _buildStatCard(
                  title: 'Revenue',
                  value: '\$12,450',
                  change: '+15%',
                  isPositive: true,
                  icon: Icons.attach_money,
                  color: AppTheme.successGreen,
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Recent Activity
            Row(
              children: [
                Expanded(
                  child: _buildRecentActivityCard(theme),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildQuickActionsCard(theme),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            icon: Icons.person_add,
            title: 'New user registered',
            subtitle: 'John Doe joined WanderWise',
            time: '2 minutes ago',
            color: AppTheme.primaryTeal,
          ),
          _buildActivityItem(
            icon: Icons.location_on,
            title: 'Destination added',
            subtitle: 'Tokyo was added to destinations',
            time: '15 minutes ago',
            color: AppTheme.accentBlue,
          ),
          _buildActivityItem(
            icon: Icons.map,
            title: 'Itinerary created',
            subtitle: 'Europe trip itinerary created',
            time: '1 hour ago',
            color: AppTheme.secondaryOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActionItem(
            icon: Icons.add_location,
            title: 'Add Destination',
            subtitle: 'Add a new travel destination',
            onTap: () {},
          ),
          _buildQuickActionItem(
            icon: Icons.people,
            title: 'Manage Users',
            subtitle: 'View and manage user accounts',
            onTap: () {},
          ),
          _buildQuickActionItem(
            icon: Icons.analytics,
            title: 'View Analytics',
            subtitle: 'Check platform statistics',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryTeal,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
