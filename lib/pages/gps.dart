// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class GPSandMapPage extends StatefulWidget {
  const GPSandMapPage({super.key});

  @override
  State<GPSandMapPage> createState() => _GPSandMapPageState();
}

class _GPSandMapPageState extends State<GPSandMapPage> {
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  LatLng latLng = const LatLng(16.246825669508297, 103.25199289277295);
  MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('GPS and Map'),
        ),
        body: Center(
          child: Column(
            children: [
              FilledButton(
                  onPressed: () async {
                    var position = await _determinePosition();
                    debugPrint('${position.latitude} ${position.longitude}');
                    setState(() {
                      latLng = LatLng(position.latitude, position.longitude);
                      mapController.move(latLng, 15);
                    });
                  },
                  child: const Text('Get Location')),
              Expanded(
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: latLng,
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      // Display map tiles from any source
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
                      userAgentPackageName: 'com.example.app',
                      maxNativeZoom:
                          19, // Scale tiles when the server doesn't support higher zoom levels
                      // And many more recommended properties!
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                            point: latLng,
                            width: 40,
                            height: 40,
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: Container(
                                color: Colors.amber,
                              ),
                            ),
                            alignment: Alignment.center),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
