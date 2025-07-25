import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/destination_model.dart';

class DestinationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'destinations';

  // Get all destinations
  static Stream<List<Destination>> getAllDestinations() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Destination.fromFirestore(doc))
            .toList());
  }

  // Get featured destinations
  static Stream<List<Destination>> getFeaturedDestinations() {
    return _firestore
        .collection(_collection)
        .where('rating', isGreaterThanOrEqualTo: 4.0)
        .orderBy('rating', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Destination.fromFirestore(doc))
            .toList());
  }

  // Get destinations by category
  static Stream<List<Destination>> getDestinationsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('categories', arrayContains: category)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Destination.fromFirestore(doc))
            .toList());
  }

  // Get destinations by country
  static Stream<List<Destination>> getDestinationsByCountry(String country) {
    return _firestore
        .collection(_collection)
        .where('country', isEqualTo: country)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Destination.fromFirestore(doc))
            .toList());
  }

  // Search destinations
  static Stream<List<Destination>> searchDestinations(String query) {
    if (query.isEmpty) return Stream.value([]);

    return _firestore
        .collection(_collection)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + '\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Destination.fromFirestore(doc))
            .toList());
  }

  // Get destination by ID
  static Future<Destination?> getDestinationById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Destination.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting destination: $e');
      return null;
    }
  }

  // Add new destination
  static Future<String?> addDestination(Destination destination) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            destination.toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      print('Error adding destination: $e');
      return null;
    }
  }

  // Update destination
  static Future<bool> updateDestination(Destination destination) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(destination.id)
          .update(destination.toFirestore());
      return true;
    } catch (e) {
      print('Error updating destination: $e');
      return false;
    }
  }

  // Delete destination
  static Future<bool> deleteDestination(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting destination: $e');
      return false;
    }
  }

  // Get popular destinations (by review count)
  static Stream<List<Destination>> getPopularDestinations() {
    return _firestore
        .collection(_collection)
        .orderBy('reviewCount', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Destination.fromFirestore(doc))
            .toList());
  }

  // Get budget-friendly destinations
  static Stream<List<Destination>> getBudgetDestinations() {
    return _firestore
        .collection(_collection)
        .where('estimatedCost', isLessThanOrEqualTo: 100)
        .orderBy('estimatedCost', descending: false)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Destination.fromFirestore(doc))
            .toList());
  }

  // Get destinations near a location
  static Stream<List<Destination>> getDestinationsNearLocation(
    double latitude,
    double longitude,
    double radiusInKm,
  ) {
    // This is a simplified version. In a real app, you'd use GeoFirestore
    // or implement proper geospatial queries
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      final destinations =
          snapshot.docs.map((doc) => Destination.fromFirestore(doc)).toList();

      // Filter destinations within radius (simplified calculation)
      return destinations.where((destination) {
        final destLocation = destination.location;
        if (destLocation['latitude'] == null ||
            destLocation['longitude'] == null) {
          return false;
        }

        final destLat = destLocation['latitude'] as double;
        final destLng = destLocation['longitude'] as double;

        final distance = _calculateDistance(
          latitude,
          longitude,
          destLat,
          destLng,
        );

        return distance <= radiusInKm;
      }).toList();
    });
  }

  // Calculate distance between two points (Haversine formula)
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}
