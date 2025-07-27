enum UserRole {
  admin,
  travelAgent,
  editor,
  contentEditor,
  traveler,
}

class User {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final List<UserRole> roles;
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final Map<String, dynamic> profile;
  final List<String>? assignedTravelers;
  final String? travelAgentId;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.roles = const [UserRole.traveler],
    this.isActive = true,
    required this.createdAt,
    required this.lastLoginAt,
    this.profile = const {},
    this.assignedTravelers,
    this.travelAgentId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((role) => UserRole.values.firstWhere(
                (e) => e.toString().split('.').last == role,
                orElse: () => UserRole.traveler,
              ))
          .toList(),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      profile: json['profile'] ?? {},
      assignedTravelers: json['assignedTravelers'] != null
          ? List<String>.from(json['assignedTravelers'])
          : null,
      travelAgentId: json['travelAgentId'],
    );
  }

  factory User.fromSupabase(Map<String, dynamic> data) {
    return User(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photo_url'],
      roles: (data['roles'] as List<dynamic>? ?? [])
          .map((role) => UserRole.values.firstWhere(
                (e) => e.toString().split('.').last == role,
                orElse: () => UserRole.traveler,
              ))
          .toList(),
      isActive: data['is_active'] ?? true,
      createdAt: DateTime.parse(data['created_at']),
      lastLoginAt: DateTime.parse(data['last_login_at']),
      profile: data['profile'],
      assignedTravelers: data['assigned_travelers'] != null
          ? List<String>.from(data['assigned_travelers'])
          : null,
      travelAgentId: data['travel_agent_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'roles': roles.map((role) => role.toString().split('.').last).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'profile': profile,
      'assignedTravelers': assignedTravelers,
      'travelAgentId': travelAgentId,
    };
  }

  Map<String, dynamic> toSupabase() {
    return {
      'email': email,
      'name': name,
      'photo_url': photoUrl,
      'roles': roles.map((role) => role.toString().split('.').last).toList(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt.toIso8601String(),
      'profile': profile,
      'assigned_travelers': assignedTravelers,
      'travel_agent_id': travelAgentId,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    List<UserRole>? roles,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? profile,
    List<String>? assignedTravelers,
    String? travelAgentId,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      roles: roles ?? this.roles,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      profile: profile ?? this.profile,
      assignedTravelers: assignedTravelers ?? this.assignedTravelers,
      travelAgentId: travelAgentId ?? this.travelAgentId,
    );
  }
}
