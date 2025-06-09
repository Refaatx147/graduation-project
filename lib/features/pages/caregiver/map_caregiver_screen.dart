import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/features/blocs/map_cubit/map_cubit.dart';
import 'package:grade_pro/features/blocs/map_cubit/map_state.dart';

class MapCaregiverScreen extends StatefulWidget {
  final String patientId;

  const MapCaregiverScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  State<MapCaregiverScreen> createState() => _MapCaregiverScreenState();
}

class _MapCaregiverScreenState extends State<MapCaregiverScreen> {
  late final MapCubit _mapCubit;
  final MapController _mapController = MapController();
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _mapCubit = MapCubit(
      userId: widget.patientId,
      isPatient: false,
    );
  _mapCubit.reloadData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _mapCubit,
      child: BlocConsumer<MapCubit, MapState>(
        listener: (context, state) {
          if (state is MapLoaded && _isMapReady) {
            try {
              _mapController.move(state.currentLocation, _mapController.camera.zoom);
            } catch (e) {
              print('Error moving map: $e');
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xff0D343F).withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                state.isPermissionError ? Icons.location_off : Icons.error_outline,
                size: 64,
                color: const Color(0xff0D343F),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              state.error,
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  color: Color(0xff0D343F),
                  fontSize: 16,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<MapCubit>().reloadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0D343F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state is MapLoaded) {
      return Column(
        children: [
          if (state.isNavigating)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xff0D343F).withAlpha(51),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xff0D343F).withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.directions_walk,
                          color: Color(0xff0D343F),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Navigation Active',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Color(0xff0D343F),
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state.distanceToDestination != null)
                    _buildInfoRow(
                      Icons.straighten,
                      'Distance: ${state.distanceToDestination!.toStringAsFixed(2)} km',
                    ),
                  if (state.estimatedArrivalTime != null)
                    _buildInfoRow(
                      Icons.timer,
                      'ETA: ${state.estimatedArrivalTime}',
                    ),
                ],
              ),
            ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xff0D343F).withAlpha(51),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff0D343F).withAlpha(26),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: state.currentLocation,
                        initialZoom: 17,
                        onMapReady: () {
                          _isMapReady = true;
                        },
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
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xff0D343F).withAlpha(26),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person_pin,
                                      color: Color(0xff0D343F),
                                      size: 35,
                                    ),
                                  ),
                                  if (state.patientName != null)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(26),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        state.patientName!,
                                        style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                            fontSize: 10,
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
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withAlpha(26),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.flag,
                                    color: Colors.red,
                                    size: 35,
                                  ),
                                ),
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
                    if (state.isLocationUpdating)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(26),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xff0D343F).withAlpha(26),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Color(0xff0D343F),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Live location',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    color: Color(0xff0D343F),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Center(
      child: Text(
        'Unable to load map',
        style: GoogleFonts.poppins(
          textStyle: const TextStyle(
            color: Color(0xff0D343F),
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xff0D343F).withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xff0D343F),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 16,
                color: Color(0xff0D343F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapCubit.close();
    super.dispose();
  }
}