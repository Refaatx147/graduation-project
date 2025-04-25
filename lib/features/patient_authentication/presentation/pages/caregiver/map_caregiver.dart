// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();
  final Location location = Location();
  LocationData? currentLocation;
  List<LatLng> routePoints = [];
  List<Marker> markers = [];
  final String orsApiKey = 'your_api_key';

  List<Map<String, dynamic>> savedLocations = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (await _checkLocationPermissions()) {
      await _getCurrentLocation();
      location.onLocationChanged.listen((newLocation) {
        setState(() => currentLocation = newLocation);
      });
    }
  }

  Future<bool> _checkLocationPermissions() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) serviceEnabled = await location.requestService();

    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
    }

    return serviceEnabled && permission == PermissionStatus.granted;
  }

  Future<void> _getCurrentLocation() async {
    final locationData = await location.getLocation();
    setState(() {
      currentLocation = locationData;
      markers.add(
        Marker(
          point: LatLng(locationData.latitude!, locationData.longitude!),
          width: 50,
          height: 50,
          child: const Icon(Icons.location_searching, color: Colors.blue, size: 25),
        ),
      );
    });
  }

  Future<void> _getRoute(LatLng destination) async {
    if (currentLocation == null) return;

    final start = LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
    final response = await http.get(Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$orsApiKey&start=${start.longitude},${start.latitude}&end=${destination.longitude},${destination.latitude}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coords = data['features'][0]['geometry']['coordinates'];
      setState(() {
        routePoints = coords.map((coord) => LatLng(coord[1], coord[0])).toList();
      });
    }
  }

  Future<void> _handleMapTap(TapPosition tapPosition, LatLng point) async {
    TextEditingController textController = TextEditingController();

    final locationName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(textStyle: TextStyle(fontSize: 16,color: const Color.fromARGB(255, 14, 72, 119),fontWeight: FontWeight.bold)),
        title:  Text('Add Location'),
  
        content: TextField(cursorColor: Colors.grey,
        
          controller: textController,
          decoration: const InputDecoration(hintText: 'Enter location name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child:  Text('Cancel',style: GoogleFonts.poppins(textStyle: TextStyle(fontSize: 15,color: const Color.fromARGB(255, 14, 72, 119)),)),),
          TextButton(onPressed: () => Navigator.pop(context, textController.text), child:  Text('Save',style: GoogleFonts.poppins(textStyle: TextStyle(fontSize: 15,color: const Color.fromARGB(255, 14, 72, 119)),))),
        ],
      ),
    );

    if (locationName != null && locationName.isNotEmpty) {
      setState(() {
        savedLocations.add({
          'name': locationName,
          'position': point,
          'icon': Icons.location_on,
          'color': Colors.red,
        });
        _addDestinationMarker(savedLocations.last);
        _getRoute(point);
      });
    }
  }

  void _addDestinationMarker(Map<String, dynamic> location) {
    setState(() {
      markers.add(
        Marker(
          point: location['position'],
          width: 50,
          height: 50,
          child: Column(
            children: [
              Icon(location['icon'], color: location['color'], size: 20),
              Text(
                location['name'],
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 251, 243),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 252, 246),
        title: const Text('Map'),
        titleTextStyle: GoogleFonts.raleway(textStyle: const TextStyle(color: Color(0xff093034), fontSize: 25)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _initializeLocation, color: const Color(0xff093034)),
        ],
      ),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: 40,),
                _buildCircularControl(),
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child:
                
                        Padding(padding: EdgeInsets.only(left: 10,top: 150,bottom: 20),
                     child:     FlutterMap(
                          mapController: mapController,
                          options: MapOptions(
                            initialCenter: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                            initialZoom: 15,
                            onTap: _handleMapTap,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: const ['a', 'b', 'c'],
                            ),
                            MarkerLayer(markers: markers),
                            PolylineLayer(
                              polylines: [
                                if (routePoints.isNotEmpty)
                                  Polyline(points: routePoints, color: Colors.blue.withOpacity(0.7), strokeWidth: 4),
                              ],
                            ),
                          ],
                        ),
                        ),




                      ),
                      Expanded(
                        flex: 1,
                        child:                        Padding(padding: EdgeInsets.only(left: 10,top: 150,bottom: 20),
child:  _buildSavedLocationsPanel(),
                      ),
                   ) ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => mapController.move(LatLng(currentLocation!.latitude!, currentLocation!.longitude!), 15),
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildSavedLocationsPanel() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: const Color.fromARGB(255, 255, 251, 243),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Container ( decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Color(0xff3C768A)),padding: EdgeInsets.all(5),child: Text( textAlign: TextAlign.center,'Saved Locations', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color: Colors.white))),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: savedLocations.length,
              itemBuilder: (context, index) {
                final location = savedLocations[index];
                return Container(
                                margin: EdgeInsets.only(bottom: 13),
                                padding: EdgeInsets.all(13),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),           color: Color(0xffFFFFFF),
),
                  child: InkWell( onTap:() {
                                  () {
                                      _getRoute(location['position']);
                                      mapController.move(location['position'], 15);
                                    };
                                } ,
child: 
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                   Text(location['name'],style: GoogleFonts.poppins(textStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)),textWidthBasis: TextWidthBasis.parent,),
                                  // location['distance'] != null
                                                                      SizedBox(width: 8,),
                                                                    Icon(size: 15,
    location['icon'], color: location['color']),

                                //  Text('Distance: ${location['distance'].toString()} km')
                               
                                  ]
                                  
                                  
                    ))  );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularControl() {
    return SizedBox(
      width: 150,
      height: 150,
      child: ClipOval(
        child: Container(
          color: Colors.blueGrey.shade100,
          child: Center(
            child: Text('Control', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
