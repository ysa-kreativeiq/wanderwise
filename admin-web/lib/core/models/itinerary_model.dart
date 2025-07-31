// Removed Firebase import - using Supabase only

enum ItineraryStatus {
  draft,
  published,
  archived,
  completed,
}

class Itinerary {
  final String id;
  final String title;
  final String description;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> destinationIds;
  final List<ItineraryDay> days;
  final ItineraryStatus status;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const Itinerary({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.destinationIds,
    required this.days,
    required this.status,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  // Removed Firebase-specific factory method - using Supabase only

  // Removed Firebase-specific method - using Supabase only

  Itinerary copyWith({
    String? id,
    String? title,
    String? description,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? destinationIds,
    List<ItineraryDay>? days,
    ItineraryStatus? status,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Itinerary(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      destinationIds: destinationIds ?? this.destinationIds,
      days: days ?? this.days,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

class ItineraryDay {
  final int dayNumber;
  final String title;
  final String description;
  final List<String> destinationIds;
  final List<ItineraryActivity> activities;
  final Map<String, dynamic>? notes;

  const ItineraryDay({
    required this.dayNumber,
    required this.title,
    required this.description,
    required this.destinationIds,
    required this.activities,
    this.notes,
  });

  factory ItineraryDay.fromMap(Map<String, dynamic> map) {
    return ItineraryDay(
      dayNumber: map['dayNumber'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      destinationIds: List<String>.from(map['destinationIds'] ?? []),
      activities: (map['activities'] as List<dynamic>? ?? [])
          .map((activity) => ItineraryActivity.fromMap(activity))
          .toList(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayNumber': dayNumber,
      'title': title,
      'description': description,
      'destinationIds': destinationIds,
      'activities': activities.map((activity) => activity.toMap()).toList(),
      'notes': notes,
    };
  }
}

class ItineraryActivity {
  final String id;
  final String title;
  final String description;
  final String destinationId;
  final DateTime startTime;
  final DateTime endTime;
  final String type; // 'visit', 'transport', 'meal', 'activity'
  final Map<String, dynamic>? details;

  const ItineraryActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.destinationId,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.details,
  });

  factory ItineraryActivity.fromMap(Map<String, dynamic> map) {
    return ItineraryActivity(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      destinationId: map['destinationId'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      type: map['type'] ?? 'visit',
      details: map['details'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'destinationId': destinationId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'type': type,
      'details': details,
    };
  }
}
