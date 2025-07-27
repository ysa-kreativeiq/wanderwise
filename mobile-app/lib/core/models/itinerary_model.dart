class Itinerary {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final bool isPublic;
  final double? totalBudget;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Itinerary({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.startDate,
    this.endDate,
    this.status = 'draft',
    this.isPublic = false,
    this.totalBudget,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      status: json['status'] as String? ?? 'draft',
      isPublic: json['isPublic'] as bool? ?? false,
      totalBudget: json['totalBudget'] as double?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  factory Itinerary.fromSupabase(Map<String, dynamic> data) {
    return Itinerary(
      id: data['id'] ?? '',
      userId: data['user_id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startDate: data['start_date'] != null
          ? DateTime.parse(data['start_date'])
          : null,
      endDate:
          data['end_date'] != null ? DateTime.parse(data['end_date']) : null,
      status: data['status'] ?? 'draft',
      isPublic: data['is_public'] ?? false,
      totalBudget: data['total_budget']?.toDouble(),
      notes: data['notes'],
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: DateTime.parse(data['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status,
      'isPublic': isPublic,
      'totalBudget': totalBudget,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toSupabase() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status,
      'is_public': isPublic,
      'total_budget': totalBudget,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Itinerary copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    bool? isPublic,
    double? totalBudget,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Itinerary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      isPublic: isPublic ?? this.isPublic,
      totalBudget: totalBudget ?? this.totalBudget,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get durationInDays {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays + 1;
  }
}

class DayModel {
  final String id;
  final DateTime date;
  final String title;
  final List<ActivityModel> activities;
  final String? notes;

  const DayModel({
    required this.id,
    required this.date,
    required this.title,
    required this.activities,
    this.notes,
  });

  factory DayModel.fromJson(Map<String, dynamic> json) {
    return DayModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String,
      activities: (json['activities'] as List<dynamic>? ?? [])
          .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'activities': activities.map((e) => e.toJson()).toList(),
      'notes': notes,
    };
  }

  DayModel copyWith({
    String? id,
    DateTime? date,
    String? title,
    List<ActivityModel>? activities,
    String? notes,
  }) {
    return DayModel(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      activities: activities ?? this.activities,
      notes: notes ?? this.notes,
    );
  }
}

class ActivityModel {
  final String id;
  final String title;
  final String description;
  final ActivityType type;
  final DateTime startTime;
  final DateTime? endTime;
  final double? latitude;
  final double? longitude;
  final String? address;
  final double? estimatedCost;
  final String? website;
  final String? phoneNumber;
  final List<String> tags;
  final String? notes;
  final bool isCompleted;

  const ActivityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.startTime,
    this.endTime,
    this.latitude,
    this.longitude,
    this.address,
    this.estimatedCost,
    this.website,
    this.phoneNumber,
    this.tags = const [],
    this.notes,
    this.isCompleted = false,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.sightseeing,
      ),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      address: json['address'] as String?,
      estimatedCost: json['estimatedCost'] as double?,
      website: json['website'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      tags: List<String>.from(json['tags'] ?? []),
      notes: json['notes'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'estimatedCost': estimatedCost,
      'website': website,
      'phoneNumber': phoneNumber,
      'tags': tags,
      'notes': notes,
      'isCompleted': isCompleted,
    };
  }

  ActivityModel copyWith({
    String? id,
    String? title,
    String? description,
    ActivityType? type,
    DateTime? startTime,
    DateTime? endTime,
    double? latitude,
    double? longitude,
    String? address,
    double? estimatedCost,
    String? website,
    String? phoneNumber,
    List<String>? tags,
    String? notes,
    bool? isCompleted,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      website: website ?? this.website,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

enum ActivityType {
  sightseeing,
  dining,
  shopping,
  entertainment,
  transportation,
  accommodation,
  outdoor,
  cultural,
  relaxation,
  other,
}
