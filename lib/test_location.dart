import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/location_service.dart';

class TestLocationPage extends StatefulWidget {
  const TestLocationPage({super.key});

  @override
  State<TestLocationPage> createState() => _TestLocationPageState();
}

class _TestLocationPageState extends State<TestLocationPage> {
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationService =
          Provider.of<LocationService>(context, listen: false);
      locationService.startTracking();
    });
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _updateLocation() {
    final locationService =
        Provider.of<LocationService>(context, listen: false);
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);

    if (lat != null && lng != null) {
      locationService.updateLocation(lat, lng);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location updated!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid coordinates')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationService = Provider.of<LocationService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracking Test'),
        backgroundColor: const Color(0xFF93032E),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: Colors.black.withOpacity(0.8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          locationService.isTracking
                              ? Icons.location_on
                              : Icons.location_off,
                          color: locationService.isTracking
                              ? Colors.green
                              : Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          locationService.isTracking
                              ? 'Tracking Active'
                              : 'Tracking Inactive',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (locationService.currentLocation != null) ...[
                      _buildInfoRow(
                          'Latitude',
                          locationService.currentLocation!.latitude
                              .toStringAsFixed(6)),
                      _buildInfoRow(
                          'Longitude',
                          locationService.currentLocation!.longitude
                              .toStringAsFixed(6)),
                    ] else ...[
                      const Text(
                        'No location data available',
                        style: TextStyle(color: Colors.white60),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Manual Update Section
            const Text(
              'Manual Location Update',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _latController,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _lngController,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _updateLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF93032E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Update Location'),
            ),

            const SizedBox(height: 24),

            // Quick Test Buttons
            const Text(
              'Quick Test Locations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickLocationButton('New York', 40.7128, -74.0060),
                _buildQuickLocationButton('London', 51.5074, -0.1278),
                _buildQuickLocationButton('Tokyo', 35.6762, 139.6503),
                _buildQuickLocationButton('Sydney', -33.8688, 151.2093),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLocationButton(String name, double lat, double lng) {
    return ElevatedButton(
      onPressed: () {
        final locationService =
            Provider.of<LocationService>(context, listen: false);
        locationService.updateLocation(lat, lng);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updated to $name')),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF034C3C),
        foregroundColor: Colors.white,
      ),
      child: Text(name),
    );
  }
}
