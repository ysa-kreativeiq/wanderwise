// Removed Firebase import - using Supabase only

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
  final Map<String, dynamic>? profile;
  final List<String>? assignedTravelers; // For travel agents
  final String? travelAgentId; // For travelers

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.roles,
    required this.isActive,
    required this.createdAt,
    required this.lastLoginAt,
    this.profile,
    this.assignedTravelers,
    this.travelAgentId,
  });

  // Removed Firebase-specific factory method - using Supabase only

  factory User.fromSupabase(Map<String, dynamic> data) {
    final rolesList = data['roles'] as List<dynamic>? ?? [];

    final parsedRoles = rolesList.map((role) {
      final roleString = role.toString();

      try {
        return UserRole.values.firstWhere(
          (e) => e.toString().split('.').last == roleString,
          orElse: () => UserRole.traveler,
        );
      } catch (e) {
        return UserRole.traveler;
      }
    }).toList();

    return User(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photo_url'],
      roles: parsedRoles,
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

  // Removed Firebase-specific method - using Supabase only

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

  bool hasRole(UserRole role) {
    return roles.contains(role);
  }

  bool get isAdmin => hasRole(UserRole.admin);
  bool get isTravelAgent => hasRole(UserRole.travelAgent);
  bool get isEditor => hasRole(UserRole.editor);
  bool get isContentEditor => hasRole(UserRole.contentEditor);
  bool get isTraveler => hasRole(UserRole.traveler);
}
