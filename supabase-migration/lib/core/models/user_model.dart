enum UserRole {
  admin,
  travelAgent,
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

  User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.roles,
    required this.isActive,
    required this.createdAt,
    required this.lastLoginAt,
    this.profile = const {},
    this.assignedTravelers,
    this.travelAgentId,
  });

  /// Create User from Supabase data
  factory User.fromSupabase(Map<String, dynamic> data) {
    return User(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photo_url'],
      roles: (data['roles'] as List<dynamic>?)
              ?.map((role) => UserRole.values.firstWhere(
                    (e) => e.toString().split('.').last == role,
                    orElse: () => UserRole.traveler,
                  ))
              .toList() ??
          [UserRole.traveler],
      isActive: data['is_active'] ?? true,
      createdAt: DateTime.parse(data['created_at']),
      lastLoginAt: DateTime.parse(data['last_login_at']),
      profile: data['profile'] ?? {},
      assignedTravelers: (data['assigned_travelers'] as List<dynamic>?)
              ?.map((id) => id.toString())
              .toList() ??
          [],
      travelAgentId: data['travel_agent_id'],
    );
  }

  /// Convert User to Supabase data
  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
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

  /// Create a copy of User with updated fields
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

  /// Check if user has admin role
  bool get isAdmin => roles.contains(UserRole.admin);

  /// Check if user has travel agent role
  bool get isTravelAgent => roles.contains(UserRole.travelAgent);

  /// Check if user has traveler role
  bool get isTraveler => roles.contains(UserRole.traveler);

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, roles: $roles, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
