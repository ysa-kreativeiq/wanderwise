import 'package:flutter/material.dart';

enum SearchContentType {
  all,
  users,
  destinations,
  itineraries,
  travelTips,
  travelAdvisories,
  documents,
  reviews,
  campaigns,
}

class SearchResult {
  final String id;
  final String title;
  final String description;
  final SearchContentType type;
  final String? imageUrl;
  final DateTime createdAt;
  final String createdBy;
  final Map<String, dynamic> metadata;
  final double relevanceScore;

  SearchResult({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.imageUrl,
    required this.createdAt,
    required this.createdBy,
    required this.metadata,
    required this.relevanceScore,
  });
}

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  String _searchQuery = '';
  SearchContentType _selectedContentType = SearchContentType.all;
  String _selectedDateRange = 'All Time';
  String _selectedSortBy = 'Relevance';
  bool _isLoading = false;
  bool _showSuggestions = false;
  List<SearchResult> _searchResults = [];
  List<String> _searchSuggestions = [];
  List<String> _recentSearches = [];

  final List<String> _dateRanges = [
    'All Time',
    'Last 24 Hours',
    'Last 7 Days',
    'Last 30 Days',
    'Last 90 Days',
    'Last Year',
  ];

  final List<String> _sortOptions = [
    'Relevance',
    'Date Created',
    'Title',
    'Type',
    'Created By',
  ];

  final List<String> _popularSearches = [
    'Paris itinerary',
    'travel insurance',
    'user registration',
    'destination guide',
    'travel tips',
    'campaign analytics',
    'document upload',
    'review moderation',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _loadSearchSuggestions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    // TODO: Load from SharedPreferences or database
    _recentSearches = [
      'Paris family adventure',
      'travel agent contracts',
      'user analytics',
      'destination management',
    ];
  }

  Future<void> _loadSearchSuggestions() async {
    // TODO: Load from database or API
    _searchSuggestions = [
      'Paris',
      'Rome',
      'Barcelona',
      'Tokyo',
      'New York',
      'London',
      'family',
      'adventure',
      'luxury',
      'budget',
      'cultural',
      'food',
      'history',
      'nature',
      'beach',
      'mountain',
      'city',
      'rural',
    ];
  }

  Future<void> _performSearch() async {
    if (_searchQuery.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _showSuggestions = false;
    });

    try {
      // TODO: Implement search in SupabaseService
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock search results
      _searchResults = [
        SearchResult(
          id: '1',
          title: 'Paris Family Adventure Itinerary',
          description:
              'Complete 7-day family itinerary for Paris with activities and recommendations.',
          type: SearchContentType.itineraries,
          imageUrl: 'https://example.com/paris.jpg',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          createdBy: 'admin@wanderwise.com',
          metadata: {
            'duration': '7 days',
            'category': 'family',
            'rating': 4.8,
          },
          relevanceScore: 0.95,
        ),
        SearchResult(
          id: '2',
          title: 'Paris Travel Guide',
          description:
              'Comprehensive travel guide for Paris including attractions, restaurants, and tips.',
          type: SearchContentType.travelTips,
          imageUrl: 'https://example.com/paris_guide.jpg',
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          createdBy: 'editor@wanderwise.com',
          metadata: {
            'category': 'guide',
            'views': 1250,
          },
          relevanceScore: 0.87,
        ),
        SearchResult(
          id: '3',
          title: 'Paris Destination Information',
          description:
              'Detailed information about Paris as a travel destination.',
          type: SearchContentType.destinations,
          imageUrl: 'https://example.com/paris_dest.jpg',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          createdBy: 'admin@wanderwise.com',
          metadata: {
            'country': 'France',
            'rating': 4.6,
            'reviews': 89,
          },
          relevanceScore: 0.82,
        ),
        SearchResult(
          id: '4',
          title: 'Paris Family Adventure PDF',
          description:
              'PDF document containing the complete Paris family adventure itinerary.',
          type: SearchContentType.documents,
          imageUrl: null,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          createdBy: 'admin@wanderwise.com',
          metadata: {
            'fileSize': '2.1 MB',
            'fileType': 'PDF',
          },
          relevanceScore: 0.78,
        ),
      ];

      // Add to recent searches
      if (!_recentSearches.contains(_searchQuery)) {
        _recentSearches.insert(0, _searchQuery);
        if (_recentSearches.length > 10) {
          _recentSearches.removeLast();
        }
        // TODO: Save to SharedPreferences or database
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error performing search: $e')),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _showSuggestions = query.isNotEmpty;
    });

    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _showSuggestions = false;
      });
    }
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    setState(() {
      _searchQuery = suggestion;
      _showSuggestions = false;
    });
    _performSearch();
  }

  void _selectRecentSearch(String search) {
    _searchController.text = search;
    setState(() {
      _searchQuery = search;
      _showSuggestions = false;
    });
    _performSearch();
  }

  void _selectPopularSearch(String search) {
    _searchController.text = search;
    setState(() {
      _searchQuery = search;
      _showSuggestions = false;
    });
    _performSearch();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchResults.clear();
      _showSuggestions = false;
    });
  }

  Color _getTypeColor(SearchContentType type) {
    switch (type) {
      case SearchContentType.users:
        return Colors.blue;
      case SearchContentType.destinations:
        return Colors.green;
      case SearchContentType.itineraries:
        return Colors.orange;
      case SearchContentType.travelTips:
        return Colors.purple;
      case SearchContentType.travelAdvisories:
        return Colors.red;
      case SearchContentType.documents:
        return Colors.indigo;
      case SearchContentType.reviews:
        return Colors.amber;
      case SearchContentType.campaigns:
        return Colors.teal;
      case SearchContentType.all:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(SearchContentType type) {
    switch (type) {
      case SearchContentType.users:
        return Icons.people;
      case SearchContentType.destinations:
        return Icons.location_on;
      case SearchContentType.itineraries:
        return Icons.map;
      case SearchContentType.travelTips:
        return Icons.tips_and_updates;
      case SearchContentType.travelAdvisories:
        return Icons.warning_amber;
      case SearchContentType.documents:
        return Icons.folder;
      case SearchContentType.reviews:
        return Icons.rate_review;
      case SearchContentType.campaigns:
        return Icons.campaign;
      case SearchContentType.all:
        return Icons.search;
    }
  }

  String _getTypeName(SearchContentType type) {
    switch (type) {
      case SearchContentType.users:
        return 'User';
      case SearchContentType.destinations:
        return 'Destination';
      case SearchContentType.itineraries:
        return 'Itinerary';
      case SearchContentType.travelTips:
        return 'Travel Tip';
      case SearchContentType.travelAdvisories:
        return 'Travel Advisory';
      case SearchContentType.documents:
        return 'Document';
      case SearchContentType.reviews:
        return 'Review';
      case SearchContentType.campaigns:
        return 'Campaign';
      case SearchContentType.all:
        return 'All';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              // TODO: Show advanced filters modal
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Advanced filters coming soon!')),
              );
            },
            tooltip: 'Advanced Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Column(
              children: [
                // Main Search Input
                TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Search across all content...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: _onSearchChanged,
                  onSubmitted: (query) => _performSearch(),
                ),
                const SizedBox(height: 16),

                // Filters Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<SearchContentType>(
                        value: _selectedContentType,
                        decoration: const InputDecoration(
                          labelText: 'Content Type',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: SearchContentType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Row(
                              children: [
                                Icon(_getTypeIcon(type), size: 16),
                                const SizedBox(width: 8),
                                Text(_getTypeName(type)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedContentType = value!;
                          });
                          if (_searchQuery.isNotEmpty) {
                            _performSearch();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDateRange,
                        decoration: const InputDecoration(
                          labelText: 'Date Range',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _dateRanges.map((range) {
                          return DropdownMenuItem(
                            value: range,
                            child: Text(range),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDateRange = value!;
                          });
                          if (_searchQuery.isNotEmpty) {
                            _performSearch();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSortBy,
                        decoration: const InputDecoration(
                          labelText: 'Sort By',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _sortOptions.map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSortBy = value!;
                          });
                          if (_searchQuery.isNotEmpty) {
                            _performSearch();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search Suggestions or Results
          Expanded(
            child: _showSuggestions &&
                    _searchQuery.isNotEmpty &&
                    _searchResults.isEmpty
                ? _buildSearchSuggestions()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            Text(
              'Recent Searches',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _recentSearches.map((search) {
                return ActionChip(
                  label: Text(search),
                  onPressed: () => _selectRecentSearch(search),
                  avatar: const Icon(Icons.history, size: 16),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Popular Searches
          Text(
            'Popular Searches',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _popularSearches.map((search) {
              return ActionChip(
                label: Text(search),
                onPressed: () => _selectPopularSearch(search),
                avatar: const Icon(Icons.trending_up, size: 16),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Search Suggestions
          Text(
            'Suggestions',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _searchSuggestions
                .where((suggestion) => suggestion
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
                .take(10)
                .map((suggestion) {
              return ActionChip(
                label: Text(suggestion),
                onPressed: () => _selectSuggestion(suggestion),
                avatar: const Icon(Icons.search, size: 16),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search terms or filters',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Search across all content',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your search query to find users, destinations, itineraries, and more',
              style: TextStyle(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Results Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Row(
            children: [
              Text(
                '${_searchResults.length} results found',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Sorted by $_selectedSortBy',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // Results List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final result = _searchResults[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        _getTypeColor(result.type).withValues(alpha: 0.1),
                    child: Icon(
                      _getTypeIcon(result.type),
                      color: _getTypeColor(result.type),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          result.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _getTypeColor(result.type).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getTypeName(result.type),
                          style: TextStyle(
                            fontSize: 10,
                            color: _getTypeColor(result.type),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.description),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            result.createdBy,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${result.createdAt.day}/${result.createdAt.month}/${result.createdAt.year}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(result.relevanceScore * 100).toStringAsFixed(0)}% match',
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
                            Text('View'),
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
                    ],
                    onSelected: (value) {
                      // TODO: Implement actions
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('$value functionality coming soon!')),
                      );
                    },
                  ),
                  onTap: () {
                    // TODO: Navigate to detail view
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Viewing ${result.title}')),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
