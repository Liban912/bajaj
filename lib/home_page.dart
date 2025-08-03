import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'auth/auth_service.dart';
import 'services/location_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  mp.MapboxMap? mapboxMap;
  mp.CircleAnnotation? circleAnnotation;
  mp.CircleAnnotationManager? circleAnnotationManager;
  mp.CircleAnnotation? currentAnnotation;
  double latitude = 0;
  double longitude = 0;
  List customeStyle = [
    "mapbox://styles/mapbox/standard",
    "mapbox://styles/mapbox/standard-satellite",
    "mapbox://styles/mapbox/dark-v11",
    "mapbox://styles/mapbox/light-v11",
    "mapbox://styles/mapbox/streets-v12",
    "mapbox://styles/mapbox/outdoors-v12",
    "mapbox://styles/mapbox/satellite-v9",
    "mapbox://styles/mapbox/satellite-streets-v12",
  ];
  int currentStyleIndex = 0;

  void changeStyle() {
    setState(() {
      currentStyleIndex = (currentStyleIndex + 1) % customeStyle.length;
      print("currentStyleIndex: $currentStyleIndex");
    });
    print(
        "customeStyle[currentStyleIndex]: ${customeStyle[currentStyleIndex]}");
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationService =
          Provider.of<LocationService>(context, listen: false);
      locationService.startTracking();
    });
    _listenToLocationUpdates();
  }

  @override
  void dispose() {
    final locationService =
        Provider.of<LocationService>(context, listen: false);
    locationService.stopTracking();
    super.dispose();
  }

  void createOneAnnotation() {
    final locationService =
        Provider.of<LocationService>(context, listen: false);
    final currentLocation = locationService.currentLocation;

    if (currentLocation != null) {
      // Remove existing annotation if any
      if (currentAnnotation != null) {
        circleAnnotationManager?.delete(currentAnnotation!);
      }

      // Create new annotation
      circleAnnotationManager
          ?.create(mp.CircleAnnotationOptions(
        geometry: mp.Point(
          coordinates:
              mp.Position(currentLocation.longitude, currentLocation.latitude),
        ),
        circleColor: const Color.fromARGB(255, 7, 21, 225).value,
        circleRadius: 8.0,
        isDraggable: true,
      ))
          .then((annotation) {
        // Store the annotation object for future removal
        currentAnnotation = annotation;
      });
    }
  }

  void _onMapCreated(mp.MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    // Create the PointAnnotationManager for custom markers
    mapboxMap.annotations.createCircleAnnotationManager().then((value) {
      circleAnnotationManager = value;
      // Only create annotation if we have location data
      final locationService =
          Provider.of<LocationService>(context, listen: false);
      if (locationService.currentLocation != null) {
        createOneAnnotation();
      }
    });

    print("Map created and PointAnnotationManager initialized");
  }

  void _updateLocationOnMap(LocationData location) async {
    if (mapboxMap == null) return;

    print(
        "Updating location on map: ${location.latitude}, ${location.longitude}");

    // Animate camera to new location
    await mapboxMap!.flyTo(
      mp.CameraOptions(
        center: mp.Point(
            coordinates: mp.Position(location.longitude, location.latitude)),
        zoom: 15.0,
      ),
      mp.MapAnimationOptions(duration: 1000),
    );

    // Add or update the location marker with custom icon
    createOneAnnotation();
  }

  void _listenToLocationUpdates() {
    final locationService =
        Provider.of<LocationService>(context, listen: false);
    locationService.addListener(() {
      final location = locationService.currentLocation;
      print(
          "Location update received - Location: $location, Tracking: ${locationService.isTracking}");

      if (location != null && locationService.isTracking) {
        setState(() {
          latitude = location.latitude;
          longitude = location.longitude;
        });
        // Update map location and annotations only when tracking is active
        print(
            "Updating map with location: ${location.latitude}, ${location.longitude}");
        _updateLocationOnMap(location);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final locationService = Provider.of<LocationService>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Bajaj GPS Tracking'),
          backgroundColor: const Color(0xFF93032E), // Burgundy
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(
                locationService.isTracking
                    ? Icons.location_on
                    : Icons.location_off,
                color: locationService.isTracking ? Colors.green : Colors.white,
              ),
              onPressed: () {
                if (locationService.isTracking) {
                  locationService.stopTracking();
                } else {
                  locationService.startTracking();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                try {
                  await authService.signOut();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: $e')),
                  );
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Location Info Panel
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    locationService.isTracking
                        ? Icons.location_on
                        : Icons.location_off,
                    color:
                        locationService.isTracking ? Colors.green : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locationService.isTracking
                              ? 'Tracking Active'
                              : 'Tracking Inactive',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (locationService.currentLocation != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Latitude: ${locationService.currentLocation!.latitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            'Longitude: ${locationService.currentLocation!.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ] else ...[
                          const SizedBox(height: 4),
                          const Text(
                            'Waiting for location data...',
                            style:
                                TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (locationService.currentLocation != null)
                    IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.white),
                      onPressed: () {
                        _updateLocationOnMap(locationService.currentLocation!);
                      },
                    ),
                ],
              ),
            ),

            // Map
            Expanded(
              child: Stack(
                children: [
                  mp.MapWidget(
                    key: ValueKey("mapWidget_$currentStyleIndex"),
                    styleUri: customeStyle[currentStyleIndex],
                    cameraOptions: mp.CameraOptions(
                      center: mp.Point(
                          coordinates: mp.Position(
                              longitude, latitude)), // Default to Mogadishu
                      zoom: 15.0,
                    ),
                    onMapCreated: _onMapCreated,
                  ),
                  // Tracking status indicator
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: locationService.isTracking
                              ? Colors.green
                              : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            locationService.isTracking
                                ? Icons.location_on
                                : Icons.location_off,
                            color: locationService.isTracking
                                ? Colors.green
                                : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            locationService.isTracking ? 'LIVE' : 'OFF',
                            style: TextStyle(
                              color: locationService.isTracking
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    if (locationService.currentLocation != null) {
                      _updateLocationOnMap(locationService.currentLocation!);
                    }
                  },
                  backgroundColor: const Color(0xFF93032E),
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
                const SizedBox(
                  height: 10,
                ),
                FloatingActionButton(
                  onPressed: () {
                    changeStyle();
                  },
                  backgroundColor: const Color(0xFF93032E),
                  child: const Icon(Icons.swap_horiz, color: Colors.white),
                ),
              ],
            )));
  }
}
