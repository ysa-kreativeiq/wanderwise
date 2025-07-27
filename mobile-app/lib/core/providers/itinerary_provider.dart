import 'package:flutter/material.dart';

import '../models/itinerary_model.dart';
import '../services/supabase_service.dart';

class ItineraryProvider extends ChangeNotifier {
  final List<Itinerary> _itineraries = [];
  Itinerary? _currentItinerary;
  bool _isLoading = false;
  String? _errorMessage;

  List<Itinerary> get itineraries => _itineraries;
  Itinerary? get currentItinerary => _currentItinerary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> createItinerary({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String userId,
  }) async {
    try {
      _setLoading(true);

      final itinerary = await SupabaseService.createItinerary(
        userId: userId,
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
      );

      if (itinerary != null) {
        _itineraries.add(itinerary);
        _currentItinerary = itinerary;
      }

      _clearError();
    } catch (e) {
      _setError('Failed to create itinerary: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateItinerary(Itinerary itinerary) async {
    try {
      _setLoading(true);

      await SupabaseService.updateItinerary(
        itineraryId: itinerary.id,
        updates: {
          'title': itinerary.title,
          'description': itinerary.description,
          'start_date': itinerary.startDate?.toIso8601String(),
          'end_date': itinerary.endDate?.toIso8601String(),
          'status': itinerary.status,
          'is_public': itinerary.isPublic,
          'total_budget': itinerary.totalBudget,
          'notes': itinerary.notes,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      final index = _itineraries.indexWhere((i) => i.id == itinerary.id);
      if (index != -1) {
        _itineraries[index] = itinerary.copyWith(updatedAt: DateTime.now());
        if (_currentItinerary?.id == itinerary.id) {
          _currentItinerary = _itineraries[index];
        }
      }

      _clearError();
    } catch (e) {
      _setError('Failed to update itinerary: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteItinerary(String itineraryId) async {
    try {
      _setLoading(true);

      await SupabaseService.deleteItinerary(itineraryId);

      _itineraries.removeWhere((i) => i.id == itineraryId);
      if (_currentItinerary?.id == itineraryId) {
        _currentItinerary = null;
      }

      _clearError();
    } catch (e) {
      _setError('Failed to delete itinerary: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void setCurrentItinerary(String itineraryId) {
    _currentItinerary = _itineraries.firstWhere(
      (i) => i.id == itineraryId,
      orElse: () => throw Exception('Itinerary not found'),
    );
    notifyListeners();
  }

  Future<void> loadUserItineraries(String userId) async {
    try {
      _setLoading(true);

      final itineraries = await SupabaseService.getUserItineraries(userId);
      _itineraries.clear();
      _itineraries.addAll(itineraries);

      _clearError();
    } catch (e) {
      _setError('Failed to load itineraries: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
