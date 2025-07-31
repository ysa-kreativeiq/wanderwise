import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

enum ReviewStatus {
  pending,
  approved,
  rejected,
  flagged,
}

enum ReviewType {
  destination,
  itinerary,
  travelAgent,
  general,
}

class Review {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String title;
  final String content;
  final double rating;
  final ReviewType type;
  final String? targetId; // destination ID, itinerary ID, etc.
  final String? targetName; // destination name, itinerary title, etc.
  final ReviewStatus status;
  final List<String> flags; // reasons for flagging
  final DateTime createdAt;
  final DateTime? moderatedAt;
  final String? moderatedBy;
  final String? moderationNotes;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.title,
    required this.content,
    required this.rating,
    required this.type,
    this.targetId,
    this.targetName,
    required this.status,
    required this.flags,
    required this.createdAt,
    this.moderatedAt,
    this.moderatedBy,
    this.moderationNotes,
  });
}

class ReviewModerationScreen extends StatefulWidget {
  const ReviewModerationScreen({super.key});

  @override
  State<ReviewModerationScreen> createState() => _ReviewModerationScreenState();
}

class _ReviewModerationScreenState extends State<ReviewModerationScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'All';
  String _selectedType = 'All';
  String _selectedRating = 'All';
  bool _isLoading = false;
  List<Review> _reviews = [];
  List<Review> _filteredReviews = [];
  Set<String> _selectedReviewIds = {};

  final List<String> _statuses = [
    'All',
    'Pending',
    'Approved',
    'Rejected',
    'Flagged',
  ];

  final List<String> _types = [
    'All',
    'Destination',
    'Itinerary',
    'Travel Agent',
    'General',
  ];

  final List<String> _ratings = [
    'All',
    '5 Stars',
    '4 Stars',
    '3 Stars',
    '2 Stars',
    '1 Star',
  ];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement getReviews in SupabaseService
      // For now, using mock data
      final reviews = await _getMockReviews();

      setState(() {
        _reviews = reviews;
        _filteredReviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reviews: $e')),
        );
      }
    }
  }

  Future<List<Review>> _getMockReviews() async {
    // Mock data for development
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();

    return [
      Review(
        id: '1',
        userId: 'user_1',
        userName: 'Sarah Johnson',
        userEmail: 'sarah.j@email.com',
        title: 'Amazing Paris Experience!',
        content:
            'The Eiffel Tower visit was absolutely incredible. The skip-the-line tickets made it so much easier with kids. Highly recommend this itinerary for families!',
        rating: 5.0,
        type: ReviewType.itinerary,
        targetId: 'itinerary_1',
        targetName: 'Paris Family Adventure',
        status: ReviewStatus.pending,
        flags: [],
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Review(
        id: '2',
        userId: 'user_2',
        userName: 'Mike Chen',
        userEmail: 'mike.chen@email.com',
        title: 'Disappointing Service',
        content:
            'The travel agent was unresponsive and the itinerary was not what we discussed. Very disappointed with the experience.',
        rating: 2.0,
        type: ReviewType.travelAgent,
        targetId: 'agent_1',
        targetName: 'Travel Agent - John Smith',
        status: ReviewStatus.flagged,
        flags: ['negative_feedback', 'service_issue'],
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Review(
        id: '3',
        userId: 'user_3',
        userName: 'Emma Davis',
        userEmail: 'emma.davis@email.com',
        title: 'Beautiful Rome',
        content:
            'Rome is absolutely stunning! The Colosseum tour was informative and the Vatican was breathtaking. Will definitely return!',
        rating: 5.0,
        type: ReviewType.destination,
        targetId: 'destination_1',
        targetName: 'Rome, Italy',
        status: ReviewStatus.approved,
        flags: [],
        createdAt: now.subtract(const Duration(days: 2)),
        moderatedAt: now.subtract(const Duration(days: 1)),
        moderatedBy: 'admin@wanderwise.com',
      ),
      Review(
        id: '4',
        userId: 'user_4',
        userName: 'David Wilson',
        userEmail: 'david.w@email.com',
        title: 'Inappropriate Content',
        content:
            'This review contains inappropriate language and should be removed.',
        rating: 1.0,
        type: ReviewType.general,
        status: ReviewStatus.rejected,
        flags: ['inappropriate_content', 'spam'],
        createdAt: now.subtract(const Duration(days: 3)),
        moderatedAt: now.subtract(const Duration(days: 2)),
        moderatedBy: 'editor@wanderwise.com',
        moderationNotes:
            'Contains inappropriate language and violates community guidelines.',
      ),
      Review(
        id: '5',
        userId: 'user_5',
        userName: 'Lisa Brown',
        userEmail: 'lisa.brown@email.com',
        title: 'Great Barcelona Trip',
        content:
            'Sagrada Familia was amazing! The architecture is incredible and the guided tour was worth every penny.',
        rating: 4.0,
        type: ReviewType.destination,
        targetId: 'destination_2',
        targetName: 'Barcelona, Spain',
        status: ReviewStatus.pending,
        flags: [],
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      Review(
        id: '6',
        userId: 'user_6',
        userName: 'Alex Thompson',
        userEmail: 'alex.t@email.com',
        title: 'Excellent Travel Agent',
        content:
            'Our travel agent was incredibly helpful and responsive. They created a perfect itinerary for our honeymoon!',
        rating: 5.0,
        type: ReviewType.travelAgent,
        targetId: 'agent_2',
        targetName: 'Travel Agent - Maria Garcia',
        status: ReviewStatus.approved,
        flags: [],
        createdAt: now.subtract(const Duration(days: 4)),
        moderatedAt: now.subtract(const Duration(days: 3)),
        moderatedBy: 'admin@wanderwise.com',
      ),
    ];
  }

  void _filterReviews() {
    setState(() {
      _filteredReviews = _reviews.where((review) {
        final matchesSearch = review.title
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            review.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            review.userName.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesStatus = _selectedStatus == 'All' ||
            review.status.name.toUpperCase() == _selectedStatus.toUpperCase();

        final matchesType = _selectedType == 'All' ||
            review.type.name.toUpperCase() == _selectedType.toUpperCase();

        final matchesRating = _selectedRating == 'All' ||
            review.rating.toString() == _selectedRating.split(' ')[0];

        return matchesSearch && matchesStatus && matchesType && matchesRating;
      }).toList();
    });
  }

  void _toggleReviewSelection(String reviewId) {
    setState(() {
      if (_selectedReviewIds.contains(reviewId)) {
        _selectedReviewIds.remove(reviewId);
      } else {
        _selectedReviewIds.add(reviewId);
      }
    });
  }

  void _selectAllReviews() {
    setState(() {
      if (_selectedReviewIds.length == _filteredReviews.length) {
        _selectedReviewIds.clear();
      } else {
        _selectedReviewIds = _filteredReviews.map((r) => r.id).toSet();
      }
    });
  }

  void _approveReviews() {
    if (_selectedReviewIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select reviews to approve')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Reviews'),
        content: Text(
            'Are you sure you want to approve ${_selectedReviewIds.length} review(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement bulk approve functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${_selectedReviewIds.length} review(s) approved successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() {
                _selectedReviewIds.clear();
              });
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectReviews() {
    if (_selectedReviewIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select reviews to reject')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Reviews'),
        content: Text(
            'Are you sure you want to reject ${_selectedReviewIds.length} review(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement bulk reject functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${_selectedReviewIds.length} review(s) rejected successfully!'),
                  backgroundColor: Colors.orange,
                ),
              );
              setState(() {
                _selectedReviewIds.clear();
              });
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _viewReviewDetails(Review review) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(review.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildReviewContent(review),
              const SizedBox(height: 16),
              if (review.moderationNotes != null) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Moderation Notes:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  review.moderationNotes!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (review.status == ReviewStatus.pending) ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _approveSingleReview(review);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: const Text('Approve'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _rejectSingleReview(review);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reject'),
            ),
          ],
        ],
      ),
    );
  }

  void _approveSingleReview(Review review) {
    // TODO: Implement single review approval
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Review approved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectSingleReview(Review review) {
    // TODO: Implement single review rejection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Review rejected successfully!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildReviewContent(Review review) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating
        Row(
          children: [
            ...List.generate(5, (index) {
              return Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20,
              );
            }),
            const SizedBox(width: 8),
            Text(
              '${review.rating}/5',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Content
        Text(
          review.content,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),

        // Metadata
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    review.userName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.email, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    review.userEmail,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    review.type.name.toUpperCase(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (review.targetName != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.link, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      review.targetName!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Submitted: ${_formatDate(review.createdAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (review.flags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: review.flags.map((flag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        flag,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ReviewStatus status) {
    switch (status) {
      case ReviewStatus.pending:
        return Colors.orange;
      case ReviewStatus.approved:
        return Colors.green;
      case ReviewStatus.rejected:
        return Colors.red;
      case ReviewStatus.flagged:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Moderation'),
        actions: [
          if (_selectedReviewIds.isNotEmpty) ...[
            TextButton.icon(
              onPressed: _approveReviews,
              icon: const Icon(Icons.check, color: Colors.white),
              label:
                  const Text('Approve', style: TextStyle(color: Colors.white)),
            ),
            TextButton.icon(
              onPressed: _rejectReviews,
              icon: const Icon(Icons.close, color: Colors.white),
              label:
                  const Text('Reject', style: TextStyle(color: Colors.white)),
            ),
          ],
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
                    hintText: 'Search reviews...',
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
                    _filterReviews();
                  },
                ),
                const SizedBox(height: 12),
                // Filters
                Row(
                  children: [
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
                          _filterReviews();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
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
                          });
                          _filterReviews();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedRating,
                        decoration: InputDecoration(
                          labelText: 'Rating',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: _ratings.map((rating) {
                          return DropdownMenuItem(
                            value: rating,
                            child: Text(rating),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRating = value!;
                          });
                          _filterReviews();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bulk Actions Bar
          if (_selectedReviewIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.primaryTeal.withOpacity(0.1),
              child: Row(
                children: [
                  Text(
                    '${_selectedReviewIds.length} review(s) selected',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _selectAllReviews,
                    child: Text(
                      _selectedReviewIds.length == _filteredReviews.length
                          ? 'Deselect All'
                          : 'Select All',
                    ),
                  ),
                ],
              ),
            ),

          // Reviews List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredReviews.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.rate_review,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No reviews found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Reviews will appear here for moderation',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredReviews.length,
                        itemBuilder: (context, index) {
                          final review = _filteredReviews[index];
                          return _ReviewCard(
                            review: review,
                            isSelected: _selectedReviewIds.contains(review.id),
                            onToggleSelection: () =>
                                _toggleReviewSelection(review.id),
                            onViewDetails: () => _viewReviewDetails(review),
                            getStatusColor: _getStatusColor,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  final bool isSelected;
  final VoidCallback onToggleSelection;
  final VoidCallback onViewDetails;
  final Color Function(ReviewStatus) getStatusColor;

  const _ReviewCard({
    required this.review,
    required this.isSelected,
    required this.onToggleSelection,
    required this.onViewDetails,
    required this.getStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = getStatusColor(review.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onViewDetails,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => onToggleSelection(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                index < review.rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              'by ${review.userName}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      review.status.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Content Preview
              Text(
                review.content.length > 150
                    ? '${review.content.substring(0, 150)}...'
                    : review.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),

              // Metadata
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      review.type.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(review.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (review.flags.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.flag,
                      size: 14,
                      color: Colors.red[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${review.flags.length} flag(s)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
