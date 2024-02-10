


import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


void main() => runApp(const App());

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PolygoneArt(),
    );
  }
}

class PolygoneArt extends StatefulWidget {
  const PolygoneArt({Key? key}) : super(key: key);

  @override
  State<PolygoneArt> createState() => _PolygoneArtState();
}

class _PolygoneArtState extends State<PolygoneArt> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _marker = {};
  final Set<Polygon> _polygon = HashSet<Polygon>();
  MapType _mapType = MapType.normal;
  final CameraPosition _position = const CameraPosition(
      target: LatLng(40.691, 68.836),
    zoom: 10
  );

  List<LatLng> points = const[
    LatLng(40.743650, 68.694507),
    LatLng(40.631091, 68.723709),
    LatLng(40.608926, 68.900133),
    LatLng(40.540537, 68.979220),
    LatLng(40.541533, 68.976123),
    LatLng(40.570223, 69.005913),
    LatLng(40.598730, 69.038332),
    LatLng(40.583182, 69.055394),
    LatLng(40.607798, 69.077575),
    LatLng(40.622045, 69.048569),
    LatLng(40.644058, 69.043450),
    LatLng(40.649236, 69.026388),
    LatLng(40.642763, 68.990557),
    LatLng(40.667639, 68.995317),
    LatLng(40.671531, 68.944005),
    LatLng(40.682427, 68.957346),
    LatLng(40.711286, 68.939544),
    LatLng(40.720581, 68.909763),
    LatLng(40.792731, 68.833331),
    LatLng(40.782977, 68.806889),
    LatLng(40.782464, 68.794684),
    LatLng(40.770141, 68.787904),
    LatLng(40.755248, 68.764851),
    LatLng(40.744975, 68.764173),
    LatLng(40.746360, 68.757134),
    LatLng(40.736861, 68.743593),
    LatLng(40.724139, 68.734733),
    LatLng(40.727017, 68.740779),
    LatLng(40.722690, 68.735070),
    LatLng(40.734228, 68.708901),
    LatLng(40.731344, 68.703192),
    LatLng(40.736392, 68.702716),
    LatLng(40.739816, 68.697244),
    LatLng(40.739456, 68.691773),
    LatLng(40.740537, 68.688442),
  ];


  Future<Position> getUserCurrentLocation()async{
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


  @override
  void initState() {
    _marker.add(
      /// Location bosganda ustuda chiqadigan Maker
        Marker(
          markerId: MarkerId("1".toString()),
          position: const LatLng(40.708672, 68.844837),
          infoWindow: const InfoWindow(
            title: 'Sardoba',
            snippet: 'Sardoba tumani xududi',
          ),
          icon: BitmapDescriptor.defaultMarker,
        ),
    );

    _polygon.add(
      Polygon(polygonId: const PolygonId("1"),
          points: points,
          fillColor: Colors.red.withOpacity(0.5),
        geodesic: true,
        strokeWidth: 4,
        strokeColor: Colors.red
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sardoba"),
        actions: [
          IconButton(
              onPressed: (){
                _mapType = _mapType == MapType.normal? MapType.hybrid : MapType.normal;
                setState(() {});
              },
              icon: const Icon(Icons.map)
          ),
          const SizedBox(width: 15,)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          getUserCurrentLocation().then((value)async{

            _marker.add(
              Marker(
                markerId: MarkerId("2".toString()),
                position: LatLng(value.latitude,value.longitude),
                infoWindow: const InfoWindow(
                title: 'Men Shottman',
              ),
              icon: BitmapDescriptor.defaultMarker,
            ),
            );

            log("latitude: ${value.latitude}\nlongitude:${value.longitude}");
            CameraPosition cameraPosition = CameraPosition(
              target: LatLng(value.latitude,value.longitude),
              zoom: 14,
            );

            final GoogleMapController controller = await _controller.future;
            
            controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            setState(() {});
          });

        },
        child: const Icon(Icons.local_activity),
      ),
      body: GoogleMap(
        /// #boshlangich joylashuv
        initialCameraPosition: _position,
        /// my location nni kursatmaydi true bulganda
        myLocationEnabled: false,
        /// my location bosilmaydi false bulganda
         myLocationButtonEnabled: true,
        mapType: _mapType,
        polygons: _polygon,
        markers: _marker,
        onMapCreated: (GoogleMapController controller){
          _controller.complete(controller);
        },
      ),
    );
  }
}

