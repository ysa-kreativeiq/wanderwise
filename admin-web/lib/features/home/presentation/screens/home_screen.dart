import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/destination_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/destination_card.dart';
import '../widgets/featured_destinations_section.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/search_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_showAppBarTitle) {
      setState(() {
        _showAppBarTitle = true;
      });
    } else if (_scrollController.offset <= 100 && _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            title: AnimatedOpacity(
              opacity: _showAppBarTitle ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: const Text('WanderWise'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
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
                                'Hello, ${user?.name?.split(' ').first ?? 'Traveler'}!',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTeal,
                                ),
                              )
                                  .animate()
                                  .fadeIn(delay: 200.ms, duration: 600.ms),
                              const SizedBox(height: 4),
                              Text(
                                'Where would you like to explore today?',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              )
                                  .animate()
                                  .fadeIn(delay: 400.ms, duration: 600.ms),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              AppTheme.primaryTeal.withOpacity(0.1),
                          backgroundImage: user?.photoUrl != null
                              ? NetworkImage(user!.photoUrl!)
                              : null,
                          child: user?.photoUrl == null
                              ? Icon(
                                  Icons.person,
                                  color: AppTheme.primaryTeal,
                                  size: 28,
                                )
                              : null,
                        ).animate().scale(delay: 600.ms, duration: 600.ms),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Search Bar
                  const SearchBarWidget()
                      .animate()
                      .slideX(delay: 800.ms, duration: 600.ms),
                  const SizedBox(height: 24),
                  // Quick Actions
                  const QuickActionsSection()
                      .animate()
                      .fadeIn(delay: 1000.ms, duration: 600.ms),
                  const SizedBox(height: 32),
                  // Featured Destinations
                  const FeaturedDestinationsSection()
                      .animate()
                      .fadeIn(delay: 1200.ms, duration: 600.ms),
                  const SizedBox(height: 32),
                  // Popular Destinations
                  Text(
                    'Popular Destinations',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 1400.ms, duration: 600.ms),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Consumer<DestinationProvider>(
            builder: (context, destinationProvider, child) {
              if (destinationProvider.isLoading) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              if (destinationProvider.errorMessage != null) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Something went wrong',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            destinationProvider.errorMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final destinations = destinationProvider.destinations
                  .skip(3) // Skip first 3 (featured ones)
                  .toList();

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final destination = destinations[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: DestinationCard(
                          destination: destination,
                          onTap: () {
                            // Navigate to destination details
                            // This will be implemented in the next iteration
                          },
                        ).animate().slideX(
                              delay:
                                  Duration(milliseconds: 1600 + (index * 100)),
                              duration: 600.ms,
                            ),
                      );
                    },
                    childCount: destinations.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100), // Bottom padding for navigation bar
          ),
        ],
      ),
    );
  }
}
