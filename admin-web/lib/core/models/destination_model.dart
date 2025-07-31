// Removed Firebase import - using Supabase only

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

  // Removed Firebase-specific factory method - using Supabase only

  // Removed Firebase-specific method - using Supabase only

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
