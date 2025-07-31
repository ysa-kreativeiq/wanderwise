import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/providers/destination_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/widgets/destination_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    // Auto-focus the search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search destinations, cities, countries...',
              hintStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey[600],
                size: 20,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        Provider.of<DestinationProvider>(context, listen: false)
                            .clearSearch();
                        setState(() {});
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            onChanged: (value) {
              setState(() {});
              if (value.isNotEmpty) {
                Provider.of<DestinationProvider>(context, listen: false)
                    .searchDestinations(value);
              } else {
                Provider.of<DestinationProvider>(context, listen: false)
                    .clearSearch();
              }
            },
          ),
        ).animate().slideX(delay: 200.ms, duration: 400.ms),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
      ),
      body: Consumer<DestinationProvider>(
        builder: (context, destinationProvider, child) {
          if (_searchController.text.isEmpty) {
            return _buildEmptySearchState(theme);
          }
          
          if (destinationProvider.isSearching) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (destinationProvider.searchResults.isEmpty) {
            return _buildNoResultsState(theme);
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: destinationProvider.searchResults.length,
            itemBuilder: (context, index) {
              final destination = destinationProvider.searchResults[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DestinationCard(
                  destination: destination,
                  onTap: () {
                    // Navigate to destination details
                  },
                ).animate().slideX(
                  delay: Duration(milliseconds: index * 100),
                  duration: 400.ms,
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildEmptySearchState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey[300],
          ).animate().scale(delay: 200.ms, duration: 600.ms),
          const SizedBox(height: 24),
          Text(
            'Search for destinations',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
          const SizedBox(height: 8),
          Text(
            'Discover amazing places around the world',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
          const SizedBox(height: 32),
          // Popular searches
          Text(
            'Popular searches',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Tokyo',
              'Paris',
              'Bali',
              'New York',
              'Santorini',
              'London',
            ].asMap().entries.map((entry) {
              final index = entry.key;
              final tag = entry.value;
              return Material(
                color: AppTheme.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () {
                    _searchController.text = tag;
                    Provider.of<DestinationProvider>(context, listen: false)
                        .searchDestinations(tag);
                    setState(() {});
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      tag,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ).animate().scale(
                delay: Duration(milliseconds: 1000 + (index * 100)),
                duration: 400.ms,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoResultsState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[300],
          ).animate().scale(delay: 200.ms, duration: 600.ms),
          const SizedBox(height: 24),
          Text(
            'No results found',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
        ],
      ),
    );
  }
  
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Filter Destinations',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Filter options will be implemented in future iterations
                Expanded(
                  child: Center(
                    child: Text(
                      'Filter options coming soon!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
