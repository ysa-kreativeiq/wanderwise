class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final List<String> favoriteDestinations;
  final UserPreferences preferences;
  
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.favoriteDestinations = const [],
    required this.preferences,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt'] as String) 
          : null,
      favoriteDestinations: List<String>.from(json['favoriteDestinations'] ?? []),
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'favoriteDestinations': favoriteDestinations,
      'preferences': preferences.toJson(),
    };
  }
  
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    List<String>? favoriteDestinations,
    UserPreferences? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      favoriteDestinations: favoriteDestinations ?? this.favoriteDestinations,
      preferences: preferences ?? this.preferences,
    );
  }
}

class UserPreferences {
  final String currency;
  final String language;
  final String units; // metric or imperial
  final bool notificationsEnabled;
  final bool locationEnabled;
  final TravelStyle travelStyle;
  
  const UserPreferences({
    this.currency = 'USD',
    this.language = 'en',
    this.units = 'metric',
    this.notificationsEnabled = true,
    this.locationEnabled = true,
    this.travelStyle = TravelStyle.balanced,
  });
  
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      currency: json['currency'] as String? ?? 'USD',
      language: json['language'] as String? ?? 'en',
      units: json['units'] as String? ?? 'metric',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      locationEnabled: json['locationEnabled'] as bool? ?? true,
      travelStyle: TravelStyle.values.firstWhere(
        (e) => e.name == json['travelStyle'],
        orElse: () => TravelStyle.balanced,
      ),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'language': language,
      'units': units,
      'notificationsEnabled': notificationsEnabled,
      'locationEnabled': locationEnabled,
      'travelStyle': travelStyle.name,
    };
  }
  
  UserPreferences copyWith({
    String? currency,
    String? language,
    String? units,
    bool? notificationsEnabled,
    bool? locationEnabled,
    TravelStyle? travelStyle,
  }) {
    return UserPreferences(
      currency: currency ?? this.currency,
      language: language ?? this.language,
      units: units ?? this.units,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      travelStyle: travelStyle ?? this.travelStyle,
    );
  }
}

enum TravelStyle {
  budget,
  balanced,
  luxury,
  adventure,
  cultural,
  relaxation,
}
