class Destination {
  final String id;
  final String name;
  final String description;
  final String country;
  final String city;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final List<String> categories;
  final Map<String, dynamic> location; // latitude, longitude
  final List<String> attractions;
  final Map<String, dynamic> weather; // temperature, condition
  final int estimatedCost;
  final String currency;
  final List<String> bestTimeToVisit;
  final List<String> languages;
  final String timezone;
  final DateTime createdAt;
  final DateTime updatedAt;

  Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.country,
    required this.city,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.categories,
    required this.location,
    required this.attractions,
    required this.weather,
    required this.estimatedCost,
    required this.currency,
    required this.bestTimeToVisit,
    required this.languages,
    required this.timezone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      categories: List<String>.from(json['categories'] ?? []),
      location: json['location'] ?? {},
      attractions: List<String>.from(json['attractions'] ?? []),
      weather: json['weather'] ?? {},
      estimatedCost: json['estimatedCost'] ?? 0,
      currency: json['currency'] ?? 'USD',
      bestTimeToVisit: List<String>.from(json['bestTimeToVisit'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      timezone: json['timezone'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  factory Destination.fromSupabase(Map<String, dynamic> data) {
    return Destination(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      country: data['country'] ?? '',
      city: data['city'] ?? '',
      imageUrl: data['image_url'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['review_count'] ?? 0,
      categories: List<String>.from(data['categories'] ?? []),
      location: data['location'] ?? {},
      attractions: List<String>.from(data['attractions'] ?? []),
      weather: data['weather'] ?? {},
      estimatedCost: data['estimated_cost'] ?? 0,
      currency: data['currency'] ?? 'USD',
      bestTimeToVisit: List<String>.from(data['best_time_to_visit'] ?? []),
      languages: List<String>.from(data['languages'] ?? []),
      timezone: data['timezone'] ?? '',
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: DateTime.parse(data['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'country': country,
      'city': city,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'categories': categories,
      'location': location,
      'attractions': attractions,
      'weather': weather,
      'estimatedCost': estimatedCost,
      'currency': currency,
      'bestTimeToVisit': bestTimeToVisit,
      'languages': languages,
      'timezone': timezone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toSupabase() {
    return {
      'name': name,
      'description': description,
      'country': country,
      'city': city,
      'image_url': imageUrl,
      'rating': rating,
      'review_count': reviewCount,
      'categories': categories,
      'location': location,
      'attractions': attractions,
      'weather': weather,
      'estimated_cost': estimatedCost,
      'currency': currency,
      'best_time_to_visit': bestTimeToVisit,
      'languages': languages,
      'timezone': timezone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Destination copyWith({
    String? id,
    String? name,
    String? description,
    String? country,
    String? city,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    List<String>? categories,
    Map<String, dynamic>? location,
    List<String>? attractions,
    Map<String, dynamic>? weather,
    int? estimatedCost,
    String? currency,
    List<String>? bestTimeToVisit,
    List<String>? languages,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Destination(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      country: country ?? this.country,
      city: city ?? this.city,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      categories: categories ?? this.categories,
      location: location ?? this.location,
      attractions: attractions ?? this.attractions,
      weather: weather ?? this.weather,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      currency: currency ?? this.currency,
      bestTimeToVisit: bestTimeToVisit ?? this.bestTimeToVisit,
      languages: languages ?? this.languages,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Destination(id: $id, name: $name, city: $city, country: $country)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Destination && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
