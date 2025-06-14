// ignore_for_file: library_private_types_in_public_api, avoid_print, deprecated_member_use, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart' as classic;
import 'package:google_fonts/google_fonts.dart';
import 'package:grade_pro/features/pages/patient/command_control.dart';
import 'package:permission_handler/permission_handler.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  ConnectionPageState createState() => ConnectionPageState();
}

class ConnectionPageState extends State<ConnectionPage> {
  final RobotFunctions _robotFunctions = RobotFunctions();
  
  classic.BluetoothConnection? _connection;
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isScanning = false;
  List<classic.BluetoothDevice> _devices = [];
  String _activeDirection = '';
  bool _autoConnectAttempted = false;
  Timer? _autoConnectTimer;

  @override
  void initState() {
    super.initState();
    // If a connection already exists in the singleton, reuse it
    if (_robotFunctions.isConnected) {
      _connection = _robotFunctions.currentConnection;
      _isConnected = true;
    } else {
      requestPermissions().then((_) => _startScanning());
    }
  }

  Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();
  }

  Future<void> _startScanning() async {
    if (!mounted) return;
    setState(() {
      _isScanning = true;
      _devices = [];
    });

    try {
      final bondedDevices = await classic.FlutterBlueClassic().bondedDevices;
      if (!mounted) return;
      setState(() {
        _devices = bondedDevices!;
        _isScanning = false;
      });

      // Auto-connect logic: attempt once when page is shown
      if (!_autoConnectAttempted && !_isConnected && !_isConnecting && !_robotFunctions.isConnected) {
        _autoConnectAttempted = true;
        final hc05 = await _findHC05();
        if (hc05 != null) {
          _autoConnectTimer = Timer(const Duration(seconds: 2), () {
            if (mounted && !_isConnected && !_isConnecting) {
              _connectToDevice(hc05);
            }
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      print('Error scanning: $e');
      setState(() {
        _isScanning = false;
      });
    }
  }


  Future<classic.BluetoothDevice?> _findHC05() async {
  try {
    final bondedDevices = await classic.FlutterBlueClassic().bondedDevices;
    if (bondedDevices != null) {
      return bondedDevices.firstWhere(
        (device) => device.name?.contains('HC-05') ?? false,
        orElse: () => throw Exception('HC-05 not found in paired devices'),
      );
    }
  } catch (e) {
    print('Error finding HC-05: $e');
  }
  return null;
}

void _connectToDevice(classic.BluetoothDevice device) async {
  if (!mounted) return;
  if (_isConnected) return; // already connected
  setState(() {
    _isConnecting = true;
  });

  int retryCount = 0;
  const maxRetries = 3;
  const retryDelay = Duration(seconds: 2);

  while (retryCount < maxRetries) {
    try {
      // Cancel any ongoing discovery
      classic.FlutterBlueClassic().stopScan();
      
      // Close existing connection if any
      if (_connection != null) {
        await _connection!.finish();
        _connection = null;
      }

      print('Attempting to connect to ${device.name} (Attempt ${retryCount + 1})');

      // Connect with timeout
      classic.BluetoothConnection? connection = await classic.FlutterBlueClassic()
          .connect(
            device.address,
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException('Connection timed out'),
          );

      if (connection != null) {
        // Wait for connection to stabilize
        await Future.delayed(const Duration(milliseconds: 500));

        _robotFunctions.setConnection(connection);
        setState(() {
          _connection = connection;
          _isConnected = true;
          _isConnecting = false;
        });

        // Set up connection listener
        _connection!.input?.listen(
          (data) {
            print('Received: ${String.fromCharCodes(data)}');
          },
          onDone: () {
            print('Connection closed');
            if (mounted) {
              setState(() {
                _isConnected = false;
              });
            }
          },
          onError: (error) {
            print('Connection error: $error');
            if (mounted) {
              setState(() {
                _isConnected = false;
              });
            }
          },
          cancelOnError: true,
        );

        print('Successfully connected to ${device.name}');
        return;
      }

      throw Exception('Failed to establish connection');
    } catch (e) {
      print('Connection attempt ${retryCount + 1} failed: $e');
      
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
      }

      retryCount++;
      
      if (retryCount < maxRetries) {
        print('Retrying in ${retryDelay.inSeconds} seconds...');
        await Future.delayed(retryDelay);
      } else {
        if (mounted) {
          setState(() {
            _isConnecting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to connect after $maxRetries attempts. Please try again.',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
}
  void _handleDirection(String direction) {
    setState(() {
      _activeDirection = direction;
    });

    switch (direction) {
      case 'forward':
        _robotFunctions.moveForward();
        break;
      case 'backward':
        _robotFunctions.moveBackward();
        break;
      case 'left':
        _robotFunctions.turnLeft();
        break;
      case 'right':
        _robotFunctions.turnRight();
        break;
      case 'stop':
        _robotFunctions.stop();
        break;
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _activeDirection = '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Available Devices',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff0D343F),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _isScanning ? null : _startScanning,
                          color: const Color(0xff0D343F),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isScanning)
                      const CircularProgressIndicator(color: Color(0xff0D343F))
                    else if (_devices.isEmpty)
                      Text(
                        'No devices found',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      )
                    else
                      SizedBox(
                        height: 130,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _devices.length,
                          itemBuilder: (context, index) {
                            final device = _devices[index];
                            return ListTile(
                              leading: const Icon(Icons.bluetooth, color: Color(0xff0D343F)),
                              title: Text(
                                device.name ?? 'Unknown Device',
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                device.address,
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                              ),
                              trailing:  IconButton(
                                      icon: const Icon(Icons.link),
                                      color: const Color(0xff0D343F),
                                      onPressed: () => _connectToDevice(device),
                                    ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      
          Padding(
            padding: const EdgeInsets.only(right: 16,left: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                        color: _isConnected ? Colors.green : Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isConnected ? 'Connected to HC-05' : 'Not Connected',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _isConnected ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  if (!_isConnected && !_isConnecting)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child:
// Then update the ElevatedButton's onPressed:
ElevatedButton(
  onPressed: () async {
    try {
      final hc05 = await _findHC05();
      if (hc05 != null) {
        _connectToDevice(hc05);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'HC-05 not found. Please make sure it is paired.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error connecting to HC-05: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to connect: ${e.toString()}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xff0D343F),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  ),
  child: Text(
    'Connect to HC-05',
    style: GoogleFonts.poppins(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),
),
                    ),
                ],
              ),
            ),
          ),
          if (true)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildControlButtons(),
              ),
            ),
        ],
      ),
    );
  }

  // Update _buildControlButtons method
  Widget _buildControlButtons() {
    return SingleChildScrollView(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Robot Controls',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff0D343F),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(30),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Stop Button
                    ElevatedButton(
                      onPressed: () => _handleDirection('stop'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _activeDirection == 'stop' ? Colors.green : Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stop_circle_outlined, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Stop',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                         //           const SizedBox(height: 24),
          
                    Flexible(
                      flex: 3,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Forward Button
                          ElevatedButton(
                            onPressed: () => _handleDirection('forward'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _activeDirection == 'forward'
                                  ? const Color.fromARGB(255, 52, 199, 114)
                                  : const Color(0xff0D343F),
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(2),
                              minimumSize: const Size(45, 45),
                            ),
                            child: const Icon(Icons.arrow_upward, size: 24, color: Colors.white),
                          ),
                          const SizedBox(height: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Left Button
                              ElevatedButton(
                                onPressed: () => _handleDirection('left'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _activeDirection == 'left'
                                      ? const Color.fromARGB(255, 52, 199, 114)
                                      : const Color(0xff0D343F),
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(2),
                                  minimumSize: const Size(45, 45),
                                ),
                                child: const Icon(Icons.arrow_back, size: 24, color: Colors.white),
                              ),
                              const SizedBox(width: 50),
                              // Right Button
                              ElevatedButton(
                                onPressed: () => _handleDirection('right'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _activeDirection == 'right'
                                      ? const Color.fromARGB(255, 52, 199, 114)
                                      : const Color(0xff0D343F),
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(2),
                                  minimumSize: const Size(45, 45),
                                ),
                                child: const Icon(Icons.arrow_forward, size: 24, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 1),
                          // Backward Button
                          ElevatedButton(
                            onPressed: () => _handleDirection('backward'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _activeDirection == 'backward'
                                  ? const Color.fromARGB(255, 52, 199, 114)
                                  : const Color(0xff0D343F),
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(2),
                              minimumSize: const Size(45, 45),
                            ),
                            child: const Icon(Icons.arrow_downward, size: 24, color: Colors.white),
                          ),
                          
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }

  // ===== External helpers =====
  Future<void> connectRobotExternal() async {
    if (_isConnected || _isConnecting) return;
    final hc05 = await _findHC05();
    if (hc05 != null) {
      _connectToDevice(hc05);
    }
  }

  Future<void> disconnectRobotExternal() async {
    if (_connection != null) {
      await _connection!.finish();
      _connection = null;
    }
    if (mounted) {
      setState(() {
        _isConnected = false;
      });
    }
    _robotFunctions.stop();
  }

  @override
  void dispose() {
    _autoConnectTimer?.cancel();
    super.dispose();
  }
}
