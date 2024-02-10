import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _controller = Completer();
  MapType _mapType = MapType.normal;

  static const CameraPosition _kGoogle = CameraPosition(
    target: LatLng(41.299496, 69.240073),
    zoom: 14,
  );

  final Set<Marker> _markers = {};
  final Set<Polyline> _polyline = {};

  static const LatLng toshket = LatLng(41.299496, 69.240073);
  static const LatLng samarqand = LatLng(39.627012, 66.974973);
  List list = [toshket, samarqand];
  List<LatLng> polylineCoordinates = [];

  Future<Position> getUserCurrentLocation() async {
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
    Position position = await Geolocator.getCurrentPosition();
    return position;
  }

  void getPolyPints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyBgGLZNT-Pa1sDz6N62YOEB7llXSVvA8M0",
      PointLatLng(
        toshket.latitude,
        toshket.longitude,
      ),
      PointLatLng(
        samarqand.latitude,
        samarqand.longitude,
      ),
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getPolyPints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F9D58),
        title: const Text("Toshkentdan Samarqandga"),
        actions: [
          IconButton(
              onPressed: () {
                _mapType = _mapType == MapType.normal
                    ? MapType.hybrid
                    : MapType.normal;
                setState(() {});
              },
              icon: const Icon(Icons.map)),
          const SizedBox(
            width: 15,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getUserCurrentLocation().then((value) async {
            _markers.add(
              Marker(
                markerId: MarkerId("2".toString()),
                position: LatLng(value.latitude, value.longitude),
                infoWindow: const InfoWindow(
                  title: 'Men Shottman',
                ),
                icon: BitmapDescriptor.defaultMarker,
              ),
            );
            CameraPosition cameraPosition = CameraPosition(
              target: LatLng(value.latitude, value.longitude),
              zoom: 14,
            );

            final GoogleMapController controller = await _controller.future;

            controller
                .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            setState(() {});
          });
        },
        child: const Icon(Icons.local_activity),
      ),
      body: SafeArea(
        child: GoogleMap(
          /// boshlangich location
          initialCameraPosition: _kGoogle,
          mapType: _mapType,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          compassEnabled: true,
          markers: {
            const Marker(
              markerId: MarkerId("source"),
              position: toshket,
            ),
            const Marker(
              markerId: MarkerId("destination"),
              position: samarqand,
            )
          },
          polylines: {
            Polyline(
                polylineId: PolylineId("route"),
                points: polylineCoordinates,
                color: Colors.red,
                width: 6)
          },
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
    );
  }
}
