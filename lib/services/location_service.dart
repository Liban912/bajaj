import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class LocationData {
  final double latitude;
  final double longitude;

  LocationData({
    required this.latitude,
    required this.longitude,
  });

  factory LocationData.fromMap(Map<dynamic, dynamic> map) {
    return LocationData(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }
}

class LocationService extends ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  DatabaseReference? _locationRef;
  Stream<DatabaseEvent>? _locationStream;

  LocationData? _currentLocation;
  bool _isTracking = false;

  LocationData? get currentLocation => _currentLocation;
  bool get isTracking => _isTracking;

  void startTracking() {
    if (_isTracking) return;

    _isTracking = true;
    _locationRef = _database.child('location');
    _locationStream = _locationRef!.onValue;

    _locationStream!.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        _currentLocation = LocationData.fromMap(data);
        notifyListeners();
      }
    });

    notifyListeners();
  }

  void stopTracking() {
    if (!_isTracking) return;

    _isTracking = false;
    _locationStream = null;
    _locationRef = null;
    notifyListeners();
  }

  Future<void> updateLocation(double latitude, double longitude) async {
    try {
      await _database.child('location').set({
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating location: $e');
      }
    }
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
