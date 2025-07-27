import 'package:flutter/material.dart';
import 'dart:convert';

import '../models/destination_model.dart';
import '../services/preferences_service.dart';

class DestinationProvider extends ChangeNotifier {
  List<Destination> _destinations = [];
  List<Destination> _featuredDestinations = [];
  List<Destination> _searchResults = [];
  List<String> _favoriteDestinations = [];

  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<Destination> get destinations => _destinations;
  List<Destination> get featuredDestinations => _featuredDestinations;
  List<Destination> get searchResults => _searchResults;
  List<String> get favoriteDestinations => _favoriteDestinations;

  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  DestinationProvider() {
    _loadMockData();
    _loadFavorites();
  }

  Future<void> _loadMockData() async {
    _setLoading(true);

    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 1500));

      _destinations = _getMockDestinations();
      _featuredDestinations =
          _destinations.take(3).toList(); // First 3 as featured

      _clearError();
    } catch (e) {
      _setError('Failed to load destinations: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchDestinations(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _setSearching(true);

    try {
      // Simulate search delay
      await Future.delayed(const Duration(milliseconds: 800));

      _searchResults = _destinations.where((destination) {
        return destination.name.toLowerCase().contains(query.toLowerCase()) ||
            destination.country.toLowerCase().contains(query.toLowerCase()) ||
            destination.categories.any((category) =>
                category.toLowerCase().contains(query.toLowerCase()));
      }).toList();

      _clearError();
    } catch (e) {
      _setError('Search failed: ${e.toString()}');
    } finally {
      _setSearching(false);
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  Future<void> toggleFavorite(String destinationId) async {
    if (_favoriteDestinations.contains(destinationId)) {
      _favoriteDestinations.remove(destinationId);
    } else {
      _favoriteDestinations.add(destinationId);
    }

    await _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(String destinationId) {
    return _favoriteDestinations.contains(destinationId);
  }

  List<Destination> getFavoriteDestinations() {
    return _destinations
        .where((d) => _favoriteDestinations.contains(d.id))
        .toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSearching(bool searching) {
    _isSearching = searching;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = PreferencesService.instance;
      if (prefs != null) {
        final favoritesJson = prefs.getString('favorite_destinations');
        if (favoritesJson != null) {
          final List<dynamic> favorites = jsonDecode(favoritesJson);
          _favoriteDestinations = favorites.cast<String>();
        }
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = PreferencesService.instance;
      if (prefs != null) {
        await prefs.setString(
            'favorite_destinations', jsonEncode(_favoriteDestinations));
      }
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  List<Destination> _getMockDestinations() {
    final now = DateTime.now();
    return [
      Destination(
        id: '1',
        name: 'Tokyo',
        description:
            'A vibrant metropolis blending ultra-modern and traditional culture.',
        country: 'Japan',
        city: 'Tokyo',
        imageUrl:
            'https://images.pexels.com/photos/2506923/pexels-photo-2506923.jpeg?auto=compress&cs=tinysrgb&w=800',
        rating: 4.8,
        reviewCount: 1247,
        categories: ['City', 'Culture', 'Food'],
        location: {'latitude': 35.6762, 'longitude': 139.6503},
        attractions: ['Senso-ji Temple', 'Tokyo Skytree', 'Shibuya Crossing'],
        weather: {'temperature': 22, 'condition': 'Sunny'},
        estimatedCost: 150,
        currency: 'USD',
        bestTimeToVisit: ['March-May', 'September-November'],
        languages: ['Japanese', 'English'],
        timezone: 'Asia/Tokyo',
        createdAt: now,
        updatedAt: now,
      ),
      Destination(
        id: '2',
        name: 'Paris',
        description:
            'The City of Light captivates with its timeless elegance and world-class museums.',
        country: 'France',
        city: 'Paris',
        imageUrl:
            'https://images.pexels.com/photos/338515/pexels-photo-338515.jpeg?auto=compress&cs=tinysrgb&w=800',
        rating: 4.9,
        reviewCount: 2156,
        categories: ['City', 'Romance', 'Art'],
        location: {'latitude': 48.8566, 'longitude': 2.3522},
        attractions: ['Eiffel Tower', 'Louvre Museum', 'Notre-Dame'],
        weather: {'temperature': 18, 'condition': 'Partly Cloudy'},
        estimatedCost: 200,
        currency: 'USD',
        bestTimeToVisit: ['April-June', 'September-October'],
        languages: ['French', 'English'],
        timezone: 'Europe/Paris',
        createdAt: now,
        updatedAt: now,
      ),
      Destination(
        id: '3',
        name: 'Bali',
        description:
            'A tropical paradise known for its stunning beaches and vibrant culture.',
        country: 'Indonesia',
        city: 'Bali',
        imageUrl:
            'https://images.pexels.com/photos/2474690/pexels-photo-2474690.jpeg?auto=compress&cs=tinysrgb&w=800',
        rating: 4.7,
        reviewCount: 1893,
        categories: ['Beach', 'Nature', 'Spiritual'],
        location: {'latitude': -8.3405, 'longitude': 115.0920},
        attractions: [
          'Uluwatu Temple',
          'Tegallalang Rice Terraces',
          'Kuta Beach'
        ],
        weather: {'temperature': 28, 'condition': 'Sunny'},
        estimatedCost: 80,
        currency: 'USD',
        bestTimeToVisit: ['April-October'],
        languages: ['Indonesian', 'English'],
        timezone: 'Asia/Makassar',
        createdAt: now,
        updatedAt: now,
      ),
      Destination(
        id: '4',
        name: 'New York City',
        description: 'The city that never sleeps offers endless possibilities.',
        country: 'United States',
        city: 'New York',
        imageUrl:
            'https://images.pexels.com/photos/290386/pexels-photo-290386.jpeg?auto=compress&cs=tinysrgb&w=800',
        rating: 4.6,
        reviewCount: 3421,
        categories: ['City', 'Entertainment', 'Shopping'],
        location: {'latitude': 40.7128, 'longitude': -74.0060},
        attractions: ['Statue of Liberty', 'Central Park', 'Times Square'],
        weather: {'temperature': 15, 'condition': 'Cloudy'},
        estimatedCost: 250,
        currency: 'USD',
        bestTimeToVisit: ['April-June', 'September-November'],
        languages: ['English', 'Spanish'],
        timezone: 'America/New_York',
        createdAt: now,
        updatedAt: now,
      ),
      Destination(
        id: '5',
        name: 'Santorini',
        description:
            'A breathtaking Greek island famous for its white-washed buildings.',
        country: 'Greece',
        city: 'Santorini',
        imageUrl:
            'https://images.pexels.com/photos/1010657/pexels-photo-1010657.jpeg?auto=compress&cs=tinysrgb&w=800',
        rating: 4.9,
        reviewCount: 1678,
        categories: ['Island', 'Romance', 'Beach'],
        location: {'latitude': 36.3932, 'longitude': 25.4615},
        attractions: ['Oia Village', 'Red Beach', 'Fira'],
        weather: {'temperature': 25, 'condition': 'Sunny'},
        estimatedCost: 180,
        currency: 'USD',
        bestTimeToVisit: ['June-September'],
        languages: ['Greek', 'English'],
        timezone: 'Europe/Athens',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
