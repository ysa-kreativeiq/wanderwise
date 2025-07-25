import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/itinerary_model.dart';
import '../models/destination_model.dart';

class ItineraryProvider extends ChangeNotifier {
  final List<ItineraryModel> _itineraries = [];
  ItineraryModel? _currentItinerary;
  bool _isLoading = false;
  String? _errorMessage;
  
  List<ItineraryModel> get itineraries => _itineraries;
  ItineraryModel? get currentItinerary => _currentItinerary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  final Uuid _uuid = const Uuid();
  
  Future<void> createItinerary({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> destinationIds,
  }) async {
    try {
      _setLoading(true);
      
      final itinerary = ItineraryModel(
        id: _uuid.v4(),
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
        destinationIds: destinationIds,
        days: _generateDays(startDate, endDate),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _itineraries.add(itinerary);
      _currentItinerary = itinerary;
      
      _clearError();
    } catch (e) {
      _setError('Failed to create itinerary: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> updateItinerary(ItineraryModel itinerary) async {
    try {
      _setLoading(true);
      
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
  
  Future<void> addActivityToDay(String itineraryId, int dayIndex, ActivityModel activity) async {
    try {
      final itinerary = _itineraries.firstWhere((i) => i.id == itineraryId);
      final updatedDays = List<DayModel>.from(itinerary.days);
      
      if (dayIndex < updatedDays.length) {
        final day = updatedDays[dayIndex];
        final updatedActivities = List<ActivityModel>.from(day.activities);
        updatedActivities.add(activity);
        
        updatedDays[dayIndex] = day.copyWith(activities: updatedActivities);
        
        final updatedItinerary = itinerary.copyWith(
          days: updatedDays,
          updatedAt: DateTime.now(),
        );
        
        await updateItinerary(updatedItinerary);
      }
    } catch (e) {
      _setError('Failed to add activity: ${e.toString()}');
    }
  }
  
  Future<void> removeActivityFromDay(String itineraryId, int dayIndex, String activityId) async {
    try {
      final itinerary = _itineraries.firstWhere((i) => i.id == itineraryId);
      final updatedDays = List<DayModel>.from(itinerary.days);
      
      if (dayIndex < updatedDays.length) {
        final day = updatedDays[dayIndex];
        final updatedActivities = day.activities.where((a) => a.id != activityId).toList();
        
        updatedDays[dayIndex] = day.copyWith(activities: updatedActivities);
        
        final updatedItinerary = itinerary.copyWith(
          days: updatedDays,
          updatedAt: DateTime.now(),
        );
        
        await updateItinerary(updatedItinerary);
      }
    } catch (e) {
      _setError('Failed to remove activity: ${e.toString()}');
    }
  }
  
  List<DayModel> _generateDays(DateTime startDate, DateTime endDate) {
    final days = <DayModel>[];
    final duration = endDate.difference(startDate).inDays + 1;
    
    for (int i = 0; i < duration; i++) {
      final date = startDate.add(Duration(days: i));
      days.add(DayModel(
        id: _uuid.v4(),
        date: date,
        title: 'Day ${i + 1}',
        activities: [],
      ));
    }
    
    return days;
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
