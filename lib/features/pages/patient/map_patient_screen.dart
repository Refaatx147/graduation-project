// ignore_for_file: unnecessary_type_check

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/features/blocs/map_cubit/map_cubit.dart';
import 'package:grade_pro/features/blocs/map_cubit/map_state.dart';
import 'package:grade_pro/core/utils/blink_event_bus.dart';
import 'package:grade_pro/features/pages/patient/command_control.dart';
import 'dart:async';

class MapPatientScreen extends StatefulWidget {
  final String patientId;

  const MapPatientScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  State<MapPatientScreen> createState() => _MapPatientScreenState();


  initState() {
    MapCubit mapCubit = MapCubit(userId: patientId, isPatient: true);
mapCubit.reloadData();
    // You can initialize any data or state here if needed
  }
}

class _MapPatientScreenState extends State<MapPatientScreen> {
  late final StreamSubscription _blinkSub;
  final RobotFunctions _robot = RobotFunctions();
  bool _blinkControlEnabled = false;
  MapCubit? _mapCubit;

  @override
  void initState() {
    super.initState();
    _blinkSub = BlinkEventBus().stream.listen((_) => _handleBlink());
  }

  void _handleBlink() {
    if (!_blinkControlEnabled) return;
    final current = _mapCubit?.state;
    if (current is MapLoaded) {
      switch (current.activeArrowIndex) {
        case 0:
          _robot.moveForward();
          break;
        case 1:
          _robot.turnRight();
          break;
        case 2:
          _robot.moveBackward();
          break;
        case 3:
          _robot.turnLeft();
          break;
      }
    }
  }

  @override
  void dispose() {
    _blinkSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapCubit(userId: widget.patientId, isPatient: true),
      child: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) {
          _mapCubit ??= context.read<MapCubit>();
          return Scaffold(
            backgroundColor: const Color(0xffFFF9ED),
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 33, 95, 112),
              title: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.location_history
                    , color: Color.fromARGB(255, 33, 95, 112)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      Text(
                        state is MapLoaded ? state.patientName! : '',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // Handle notifications
                  },
                ),
                const SizedBox(width: 8),
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
        child: CircularProgressIndicator(),
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
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              state.error,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<MapCubit>().reloadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 33, 95, 112),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is MapLoaded) {
      return Column(
        children: [
          // Control Panel with Navigation Info
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xffFFF9ED),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Navigation Controls
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color.fromARGB(255, 33, 95, 112).withAlpha(51),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Toggle Control Button
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _blinkControlEnabled = !_blinkControlEnabled;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _blinkControlEnabled ? const Color.fromARGB(255, 199, 52, 52) : const Color.fromARGB(255, 52, 199, 114),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          _blinkControlEnabled ? 'Stop' : 'Start',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Forward Button
                      ElevatedButton(
                        onPressed: () {
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state is MapLoaded && state.activeArrowIndex == 0 
                              ? const Color.fromARGB(255, 52, 199, 114)
                              : const Color(0xff0D343F),
                          iconColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                          minimumSize: const Size(45, 45),
                        ),
                        child: const Icon(Icons.arrow_upward, size: 24),
                      ),
                      const SizedBox(height: 12),
                      // Left, Backward, Right Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Left Button
                          ElevatedButton(
                            onPressed: () {
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: state is MapLoaded && state.activeArrowIndex == 3 
                                  ? const Color.fromARGB(255, 52, 199, 114)
                                  : const Color(0xff0D343F),
                              iconColor: Colors.white,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(12),
                              minimumSize: const Size(45, 45),
                            ),
                            child: const Icon(Icons.arrow_back, size: 24),
                          ),
                          const SizedBox(width: 50),
                          // Right Button
                          ElevatedButton(
                            onPressed: () {
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: state is MapLoaded && state.activeArrowIndex == 1 
                                  ? const Color.fromARGB(255, 52, 199, 114)
                                  : const Color(0xff0D343F),
                              iconColor: Colors.white,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(12),
                              minimumSize: const Size(45, 45),
                            ),
                            child: const Icon(Icons.arrow_forward, size: 24),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Backward Button
                      ElevatedButton(
                        onPressed: () {
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state is MapLoaded && state.activeArrowIndex == 2 
                              ? const Color.fromARGB(255, 52, 199, 114)
                              : const Color(0xff0D343F),
                          iconColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                          minimumSize: const Size(45, 45),
                        ),
                        child: const Icon(Icons.arrow_downward, size: 24),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Navigation Info
                if (state.isNavigating)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color.fromARGB(255, 33, 95, 112).withAlpha(51),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(13),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const  Icon(
                                Icons.directions_walk,
                                size: 30,
                                color:    Color.fromARGB(255, 52, 199, 114),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Navigation Active',
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(255, 52, 199, 114),
                                    ),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 13),
                          if (state.distanceToDestination != null)
                            Row(
                              children: [
                                const Icon(Icons.straighten, color: Color.fromARGB(255, 33, 95, 112), size: 20),
                                const SizedBox(width: 15),
                                Flexible(
                                  child: Text(
                                    'Distance: ${state.distanceToDestination!.toStringAsFixed(2)} km',
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(255, 33, 95, 112),
                                      ),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
          
                          if (state.estimatedArrivalTime != null)
                          const SizedBox(height: 13),
                            Row(
                              children: [
                                const Icon(Icons.timer, color: Color.fromARGB(255, 33, 95, 112), size: 20),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'ETA: ${state.estimatedArrivalTime}',
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(255, 33, 95, 112),
                                      ),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Map Section
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color.fromARGB(255, 33, 95, 112).withAlpha(51),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color.fromARGB(255, 33, 95, 112).withAlpha(26),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: state.currentLocation,
                          initialZoom: 17,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: state.currentLocation,
                    width: 50,
                    height: 50,
                                child: const Icon(Icons.person_pin, color: Color.fromARGB(255, 33, 95, 112), size: 35),
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
                                  color: const Color.fromARGB(255, 33, 95, 112),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                                  color: Colors.black.withAlpha(26),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_searching,
                      size: 16,
                                  color:  Color.fromARGB(255, 33, 95, 112),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Updating location...',
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      color: Color.fromARGB(255, 33, 95, 112),
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
                ),
                ),
              ),
            ),
        ],
      );
    }

    return const Center(
      child: Text('Unable to load map'),
    );
  }
}