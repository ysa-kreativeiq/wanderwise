import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/itinerary_model.dart';

class ItineraryPushScreen extends StatefulWidget {
  final User traveler;

  const ItineraryPushScreen({super.key, required this.traveler});

  @override
  State<ItineraryPushScreen> createState() => _ItineraryPushScreenState();
}

class _ItineraryPushScreenState extends State<ItineraryPushScreen> {
  Itinerary? _selectedItinerary;
  List<Itinerary> _availableItineraries = [];
  List<PlatformFile> _attachedFiles = [];
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableItineraries();
  }

  Future<void> _loadAvailableItineraries() async {
    setState(() => _isLoading = true);
    // TODO: Load itineraries from ItineraryProvider
    // Mock data for now
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      // _availableItineraries = await itineraryProvider.getItineraries();
    });
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
      );

      if (result != null) {
        setState(() {
          _attachedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: $e')),
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
  }

  Future<void> _sendItinerary() async {
    if (_selectedItinerary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an itinerary')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      // TODO: Implement sending logic
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Itinerary sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending itinerary: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Push Itinerary to ${widget.traveler.name}'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Traveler Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: widget.traveler.photoUrl != null
                                ? NetworkImage(widget.traveler.photoUrl!)
                                : null,
                            child: widget.traveler.photoUrl == null
                                ? Text(widget.traveler.name[0].toUpperCase())
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.traveler.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(widget.traveler.email,
                                    style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Itinerary Selection
                  const Text(
                    'Select Itinerary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (_availableItineraries.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.map_outlined,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No itineraries available',
                                  style: TextStyle(color: Colors.grey)),
                              SizedBox(height: 8),
                              Text('Create an itinerary first',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ..._availableItineraries.map((itinerary) => ItineraryCard(
                          itinerary: itinerary,
                          isSelected: _selectedItinerary?.id == itinerary.id,
                          onTap: () =>
                              setState(() => _selectedItinerary = itinerary),
                        )),

                  const SizedBox(height: 24),

                  // Notes Section
                  const Text(
                    'Notes for Traveler',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          'Add any notes or instructions for the traveler...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // File Attachments
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Attachments',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: _pickFiles,
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Add Files'),
                      ),
                    ],
                  ),

                  if (_attachedFiles.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ..._attachedFiles.asMap().entries.map((entry) {
                      final index = entry.key;
                      final file = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(file.name),
                          subtitle: Text(
                              '${(file.size / 1024).toStringAsFixed(1)} KB'),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => _removeFile(index),
                          ),
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 32),

                  // Send Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _sendItinerary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSending
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Sending...'),
                              ],
                            )
                          : const Text('Send Itinerary to Traveler'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class ItineraryCard extends StatelessWidget {
  final Itinerary itinerary;
  final bool isSelected;
  final VoidCallback onTap;

  const ItineraryCard({
    super.key,
    required this.itinerary,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? Colors.blue[50] : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      itinerary.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: Colors.blue[600]),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                itinerary.description,
                style: TextStyle(color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${itinerary.startDate.toString().split(' ')[0]} - ${itinerary.endDate.toString().split(' ')[0]}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${itinerary.destinationIds.length} destinations',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
