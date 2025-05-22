import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/features/authentication/presentation/blocs/map_cubit/map_cubit.dart';
import 'package:grade_pro/features/authentication/presentation/blocs/map_cubit/map_state.dart';

class MapCaregiverScreen extends StatelessWidget {
  final String patientId;

  const MapCaregiverScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapCubit(userId: patientId, isPatient: false),
      child: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 213, 210, 202),
              elevation: 0,
              leading: Row(
                children: [
                  const SizedBox(width: 10),
                  Icon(Icons.person, color: Color.fromARGB(255, 21, 88, 107)),
                  const SizedBox(width: 8),
                  Text(
                    state is MapLoaded ? state.patientName! : '',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 21, 88, 107),
                      ),
                    ),
                  ),
                ],
              ),
              leadingWidth: 200,
              actions: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Color.fromARGB(255, 21, 88, 107)),
                    const SizedBox(width: 8),
                    Text(
                      'Location',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 21, 88, 107),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ],
            ),
            body: _buildMapContent(context, state),
          );
        },
      ),
    );
  }

  Widget _buildMapContent(BuildContext context, MapState state) {
    if (state is MapLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xff0D343F),
        ),
      );
    }

    if (state is MapError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.isPermissionError ? Icons.location_off : Icons.error_outline,
              size: 64,
              color: Color(0xff0D343F),
            ),
            const SizedBox(height: 16),
            Text(
              state.error,
              style: TextStyle(
                color: Color(0xff0D343F),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<MapCubit>().reloadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff0D343F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is MapLoaded) {
      return Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 199, 198, 198).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color.fromARGB(255, 161, 183, 190)),
        ),
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: state.currentLocation,
                initialZoom: 17,
                onTap: (_, point) {
                  context.read<MapCubit>().setDestination(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  tileProvider: NetworkTileProvider(),
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: state.currentLocation,
                      width: 80,
                      height: 80,
                      child: Column(
                        children: [
                          const Icon(Icons.person_pin, color: Colors.blue, size: 35),
                          if (state.patientName != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                state.patientName!,
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff0D343F),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (state.destination != null)
                      Marker(
                        point: state.destination!,
                        width: 50,
                        height: 50,
                        child: const Icon(Icons.flag, color: Colors.red, size: 35),
                      ),
                  ],
                ),
                if (state.destination != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [state.currentLocation, state.destination!],
                        color: const Color(0xff0D343F),
                        strokeWidth: 4,
                      ),
                    ],
                  ),
              ],
            ),
            if (state.isNavigating)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.directions_walk,
                              color: Color(0xff0D343F),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Navigation Active',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  color: Color(0xff0D343F),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (state.distanceToDestination != null)
                          Row(
                            children: [
                              Icon(Icons.straighten, color: Color(0xff0D343F)),
                              const SizedBox(width: 8),
                              Text(
                                'Distance: ${state.distanceToDestination!.toStringAsFixed(2)} km',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        if (state.estimatedArrivalTime != null)
                          Row(
                            children: [
                              Icon(Icons.timer, color: Color(0xff0D343F)),
                              const SizedBox(width: 8),
                              Text(
                                'ETA: ${state.estimatedArrivalTime}',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            if (state.isLocationUpdating)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_searching,
                        size: 16,
                        color: Color(0xff0D343F),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Updating location...',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: Color(0xff0D343F),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return const Center(
      child: Text('Unable to load map'),
    );
  }
} 