class ItineraryModel {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> destinationIds;
  final List<DayModel> days;
  final double? totalBudget;
  final String? notes;
  final List<String> sharedWith;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const ItineraryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.destinationIds,
    required this.days,
    this.totalBudget,
    this.notes,
    this.sharedWith = const [],
    this.isPublic = false,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory ItineraryModel.fromJson(Map<String, dynamic> json) {
    return ItineraryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      destinationIds: List<String>.from(json['destinationIds'] ?? []),
      days: (json['days'] as List<dynamic>? ?? [])
          .map((e) => DayModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalBudget: json['totalBudget'] as double?,
      notes: json['notes'] as String?,
      sharedWith: List<String>.from(json['sharedWith'] ?? []),
      isPublic: json['isPublic'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'destinationIds': destinationIds,
      'days': days.map((e) => e.toJson()).toList(),
      'totalBudget': totalBudget,
      'notes': notes,
      'sharedWith': sharedWith,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  ItineraryModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? destinationIds,
    List<DayModel>? days,
    double? totalBudget,
    String? notes,
    List<String>? sharedWith,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ItineraryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      destinationIds: destinationIds ?? this.destinationIds,
      days: days ?? this.days,
      totalBudget: totalBudget ?? this.totalBudget,
      notes: notes ?? this.notes,
      sharedWith: sharedWith ?? this.sharedWith,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  int get durationInDays => endDate.difference(startDate).inDays + 1;
  
  double get totalEstimatedCost {
    return days.fold(0.0, (sum, day) => 
        sum + day.activities.fold(0.0, (daySum, activity) => 
            daySum + (activity.estimatedCost ?? 0.0)));
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
