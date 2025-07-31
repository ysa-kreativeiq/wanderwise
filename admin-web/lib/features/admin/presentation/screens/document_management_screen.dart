import 'package:flutter/material.dart';

import 'document_upload_screen.dart';

enum DocumentType {
  itinerary,
  travelGuide,
  policy,
  contract,
  brochure,
  map,
  other,
}

enum DocumentStatus {
  draft,
  published,
  archived,
  expired,
}

class Document {
  final String id;
  final String title;
  final String description;
  final String fileName;
  final String fileUrl;
  final DocumentType type;
  final DocumentStatus status;
  final String uploadedBy;
  final DateTime uploadedAt;
  final DateTime? expiresAt;
  final int fileSize; // in bytes
  final List<String> tags;
  final String? attachedTo; // ID of content this document is attached to
  final String? attachedType; // Type of content (itinerary, destination, etc.)

  Document({
    required this.id,
    required this.title,
    required this.description,
    required this.fileName,
    required this.fileUrl,
    required this.type,
    required this.status,
    required this.uploadedBy,
    required this.uploadedAt,
    this.expiresAt,
    required this.fileSize,
    required this.tags,
    this.attachedTo,
    this.attachedType,
  });

  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize B';
    }
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isExpiringSoon =>
      expiresAt != null &&
      DateTime.now().isBefore(expiresAt!) &&
      expiresAt!.difference(DateTime.now()).inDays <= 7;
}

class DocumentManagementScreen extends StatefulWidget {
  const DocumentManagementScreen({super.key});

  @override
  State<DocumentManagementScreen> createState() =>
      _DocumentManagementScreenState();
}

class _DocumentManagementScreenState extends State<DocumentManagementScreen> {
  bool _isLoading = false;

  String _searchQuery = '';
  String _selectedType = 'All';
  String _selectedStatus = 'All';
  String _selectedSortBy = 'Upload Date';
  List<Document> _documents = [];
  List<Document> _filteredDocuments = [];
  Set<String> _selectedDocumentIds = {};

  final List<String> _types = [
    'All',
    'Itinerary',
    'Travel Guide',
    'Policy',
    'Contract',
    'Brochure',
    'Map',
    'Other',
  ];

  final List<String> _statuses = [
    'All',
    'Draft',
    'Published',
    'Archived',
    'Expired',
  ];

  final List<String> _sortOptions = [
    'Upload Date',
    'Name',
    'Size',
    'Type',
    'Status',
  ];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement getDocuments in SupabaseService
      await Future.delayed(const Duration(milliseconds: 600));

      // Mock data
      _documents = [
        Document(
          id: '1',
          title: 'Paris Family Adventure Itinerary',
          description:
              'Complete 7-day family itinerary for Paris with activities and recommendations.',
          fileName: 'paris_family_itinerary.pdf',
          fileUrl: 'https://example.com/documents/paris_family_itinerary.pdf',
          type: DocumentType.itinerary,
          status: DocumentStatus.published,
          uploadedBy: 'admin@wanderwise.com',
          uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
          fileSize: 2048576, // 2MB
          tags: ['family', 'paris', '7-days', 'cultural'],
          attachedTo: 'itinerary_123',
          attachedType: 'itinerary',
        ),
        Document(
          id: '2',
          title: 'Travel Insurance Policy',
          description:
              'Comprehensive travel insurance policy document for all travelers.',
          fileName: 'travel_insurance_policy.pdf',
          fileUrl: 'https://example.com/documents/travel_insurance_policy.pdf',
          type: DocumentType.policy,
          status: DocumentStatus.published,
          uploadedBy: 'admin@wanderwise.com',
          uploadedAt: DateTime.now().subtract(const Duration(days: 30)),
          expiresAt: DateTime.now().add(const Duration(days: 5)),
          fileSize: 1048576, // 1MB
          tags: ['insurance', 'policy', 'legal'],
        ),
        Document(
          id: '3',
          title: 'Rome City Map',
          description:
              'Detailed map of Rome with major attractions and transportation.',
          fileName: 'rome_city_map.pdf',
          fileUrl: 'https://example.com/documents/rome_city_map.pdf',
          type: DocumentType.map,
          status: DocumentStatus.published,
          uploadedBy: 'editor@wanderwise.com',
          uploadedAt: DateTime.now().subtract(const Duration(days: 15)),
          fileSize: 512000, // 500KB
          tags: ['rome', 'map', 'transportation'],
          attachedTo: 'destination_rome',
          attachedType: 'destination',
        ),
        Document(
          id: '4',
          title: 'Travel Agent Contract Template',
          description:
              'Standard contract template for travel agent partnerships.',
          fileName: 'travel_agent_contract_template.pdf',
          fileUrl:
              'https://example.com/documents/travel_agent_contract_template.pdf',
          type: DocumentType.contract,
          status: DocumentStatus.draft,
          uploadedBy: 'admin@wanderwise.com',
          uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
          fileSize: 1536000, // 1.5MB
          tags: ['contract', 'template', 'legal'],
        ),
      ];

      _filterDocuments();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading documents: $e')),
        );
      }
    }
  }

  void _filterDocuments() {
    _filteredDocuments = _documents.where((document) {
      final matchesType = _selectedType == 'All' ||
          document.type.name.toLowerCase() == _selectedType.toLowerCase();
      final matchesStatus = _selectedStatus == 'All' ||
          document.status.name.toLowerCase() == _selectedStatus.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          document.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          document.description
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          document.fileName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          document.tags.any(
              (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));

      return matchesType && matchesStatus && matchesSearch;
    }).toList();

    // Sort documents
    switch (_selectedSortBy) {
      case 'Upload Date':
        _filteredDocuments.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
        break;
      case 'Name':
        _filteredDocuments.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Size':
        _filteredDocuments.sort((a, b) => b.fileSize.compareTo(a.fileSize));
        break;
      case 'Type':
        _filteredDocuments.sort((a, b) => a.type.name.compareTo(b.type.name));
        break;
      case 'Status':
        _filteredDocuments
            .sort((a, b) => a.status.name.compareTo(b.status.name));
        break;
    }
  }

  void _uploadNewDocument() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DocumentUploadScreen(),
      ),
    ).then((_) {
      _loadDocuments(); // Refresh the list when returning
    });
  }

  void _toggleDocumentSelection(String documentId) {
    setState(() {
      if (_selectedDocumentIds.contains(documentId)) {
        _selectedDocumentIds.remove(documentId);
      } else {
        _selectedDocumentIds.add(documentId);
      }
    });
  }

  void _selectAllDocuments() {
    setState(() {
      if (_selectedDocumentIds.length == _filteredDocuments.length) {
        _selectedDocumentIds.clear();
      } else {
        _selectedDocumentIds = _filteredDocuments.map((doc) => doc.id).toSet();
      }
    });
  }

  void _deleteSelectedDocuments() {
    if (_selectedDocumentIds.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Documents'),
        content: Text(
            'Are you sure you want to delete ${_selectedDocumentIds.length} document(s)? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete functionality
              setState(() {
                _documents.removeWhere(
                    (doc) => _selectedDocumentIds.contains(doc.id));
                _selectedDocumentIds.clear();
                _filterDocuments();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Documents deleted successfully!')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.draft:
        return Colors.grey;
      case DocumentStatus.published:
        return Colors.green;
      case DocumentStatus.archived:
        return Colors.orange;
      case DocumentStatus.expired:
        return Colors.red;
    }
  }

  IconData _getTypeIcon(DocumentType type) {
    switch (type) {
      case DocumentType.itinerary:
        return Icons.map;
      case DocumentType.travelGuide:
        return Icons.book;
      case DocumentType.policy:
        return Icons.policy;
      case DocumentType.contract:
        return Icons.description;
      case DocumentType.brochure:
        return Icons.article;
      case DocumentType.map:
        return Icons.location_on;
      case DocumentType.other:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Management'),
        actions: [
          if (_selectedDocumentIds.isNotEmpty) ...[
            TextButton(
              onPressed: _deleteSelectedDocuments,
              child: const Text('Delete Selected',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocuments,
            tooltip: 'Refresh',
          ),
          FilledButton.icon(
            onPressed: _uploadNewDocument,
            icon: const Icon(Icons.upload),
            label: const Text('Upload'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filters and Actions
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Search Documents',
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                    _filterDocuments();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedType,
                                decoration: const InputDecoration(
                                  labelText: 'Type',
                                  border: OutlineInputBorder(),
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
                                    _filterDocuments();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedStatus,
                                decoration: const InputDecoration(
                                  labelText: 'Status',
                                  border: OutlineInputBorder(),
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
                                    _filterDocuments();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedSortBy,
                                decoration: const InputDecoration(
                                  labelText: 'Sort By',
                                  border: OutlineInputBorder(),
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
                                    _filterDocuments();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        if (_filteredDocuments.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Checkbox(
                                value: _selectedDocumentIds.length ==
                                    _filteredDocuments.length,
                                onChanged: (value) => _selectAllDocuments(),
                              ),
                              const Text('Select All'),
                              const SizedBox(width: 16),
                              Text(
                                  '${_selectedDocumentIds.length} of ${_filteredDocuments.length} selected'),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Documents List
                Expanded(
                  child: _filteredDocuments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_open,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No documents found',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Upload your first document to get started',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: _uploadNewDocument,
                                icon: const Icon(Icons.upload),
                                label: const Text('Upload Document'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredDocuments.length,
                          itemBuilder: (context, index) {
                            final document = _filteredDocuments[index];
                            final isSelected =
                                _selectedDocumentIds.contains(document.id);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (value) =>
                                          _toggleDocumentSelection(document.id),
                                    ),
                                    const SizedBox(width: 8),
                                    CircleAvatar(
                                      backgroundColor:
                                          _getStatusColor(document.status)
                                              .withValues(alpha: 0.1),
                                      child: Icon(
                                        _getTypeIcon(document.type),
                                        color: _getStatusColor(document.status),
                                      ),
                                    ),
                                  ],
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        document.title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    if (document.isExpired)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.red.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'EXPIRED',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    if (document.isExpiringSoon &&
                                        !document.isExpired)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'EXPIRING SOON',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(document.description),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                _getStatusColor(document.status)
                                                    .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            document.status.name.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: _getStatusColor(
                                                  document.status),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${document.type.name} • ${document.fileSizeFormatted}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (document.tags.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 4,
                                        children: document.tags.map((tag) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              tag,
                                              style:
                                                  const TextStyle(fontSize: 10),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
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
                                      value: 'download',
                                      child: Row(
                                        children: [
                                          Icon(Icons.download),
                                          SizedBox(width: 8),
                                          Text('Download'),
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
                                    const PopupMenuItem(
                                      value: 'archive',
                                      child: Row(
                                        children: [
                                          Icon(Icons.archive),
                                          SizedBox(width: 8),
                                          Text('Archive'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Delete',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    _handleDocumentAction(document, value);
                                  },
                                ),
                                onTap: () => _showDocumentDetails(document),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadNewDocument,
        child: const Icon(Icons.upload),
      ),
    );
  }

  void _handleDocumentAction(Document document, String action) {
    switch (action) {
      case 'view':
        _showDocumentDetails(document);
        break;
      case 'download':
        // TODO: Implement download functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download functionality coming soon!')),
        );
        break;
      case 'edit':
        // TODO: Implement edit functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit functionality coming soon!')),
        );
        break;
      case 'duplicate':
        // TODO: Implement duplicate functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Duplicate functionality coming soon!')),
        );
        break;
      case 'archive':
        // TODO: Implement archive functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Archive functionality coming soon!')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(document);
        break;
    }
  }

  void _showDeleteConfirmation(Document document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text(
            'Are you sure you want to delete "${document.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _documents.removeWhere((doc) => doc.id == document.id);
                _selectedDocumentIds.remove(document.id);
                _filterDocuments();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Document deleted successfully!')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDocumentDetails(Document document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(document.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                document.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('File Name', document.fileName),
              _buildDetailRow('File Size', document.fileSizeFormatted),
              _buildDetailRow('Type', document.type.name),
              _buildDetailRow('Status', document.status.name),
              _buildDetailRow('Uploaded By', document.uploadedBy),
              _buildDetailRow(
                  'Upload Date', _formatDateTime(document.uploadedAt)),
              if (document.expiresAt != null)
                _buildDetailRow(
                    'Expires', _formatDateTime(document.expiresAt!)),
              if (document.attachedTo != null) ...[
                _buildDetailRow('Attached To', document.attachedTo!),
                _buildDetailRow('Attachment Type', document.attachedType!),
              ],
              if (document.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Tags:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: document.tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      backgroundColor: Colors.grey[200],
                    );
                  }).toList(),
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
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
