// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';
import 'package:grade_pro/features/headset_connection/server_connection.dart';
import 'package:grade_pro/features/pages/patient/navigation_control.dart';
import 'package:grade_pro/core/utils/blink_event_bus.dart';

class ConnectedHeadset extends StatefulWidget {
  const ConnectedHeadset({
    super.key, 
    required this.title,
   required this.initialTab // Add this parameter
  });
  
  final String title;
  final int initialTab; // 0 for headset, 1 for robot control

  @override
  State<ConnectedHeadset> createState() => ConnectedHeadsetState();
}

class ConnectedHeadsetState extends State<ConnectedHeadset>
    with TickerProviderStateMixin { // Changed from SingleTickerProviderStateMixin
  late TabController _tabController;
  
  bool _isServerRunning = false;
  int _doubleBlinkCount = 0;
  bool _isBlinking = false;
  int numberOfDBlinks = 0;
  final FlutterTts _flutterTts = FlutterTts();
  DateTime? _lastBlinkTime;
  Timer? _periodicChecker;
  Timer? _disconnectTimer;
  Timer? _squareTimer;
  final Duration _disconnectTimeout = const Duration(seconds: 15);

  int _activeSquare = 1;
  int _selectedSquare = 0;

  late final AnimationController _blinkAnimationController;
  Timer? _autoDisconnectTimer;
  bool _isTestRunning = false; // Indicates if square selection test is active
  // Key to access robot control page state
  final GlobalKey<ConnectionPageState> _robotKey = GlobalKey<ConnectionPageState>();
  bool _pendingRobotConnect = false;
  bool _pendingRobotDisconnect = false;

  @override

  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2, 
      vsync: this,
      initialIndex: widget.initialTab, // Set initial tab
    );
    _initializeAnimations();
    // Remove _startServer() from here
    _configureTts();

     _tabController.addListener(() {
       // When the tab index is changing we only handle UI concerns
       if (_tabController.indexIsChanging) {
         // Stop square test when leaving headset tab
         if (_isTestRunning) {
           setState(() {
             _isTestRunning = false;
             _squareTimer?.cancel();
             _selectedSquare = 0;
           });
         }
       } else {
         // Tab change completed – act on pending robot actions
         if (_tabController.index == 1) {
           if (_pendingRobotConnect) {
             _pendingRobotConnect = false;
             _robotKey.currentState?.connectRobotExternal();
           } else if (_pendingRobotDisconnect) {
             _pendingRobotDisconnect = false;
             _robotKey.currentState?.disconnectRobotExternal();
           }
         }
       }
     });
  }

  void _initializeAnimations() {
    _blinkAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  Future<void> _configureTts() async {
    await _flutterTts.setLanguage('ar');
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String message) async {
    await _flutterTts.speak(message);
  }

  void _startSquareRotation() {
    if (!_isTestRunning) return; // Only rotate squares during the test
    _squareTimer?.cancel();
    _squareTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isServerRunning || !_isTestRunning) return; // Guard against premature calls
      setState(() {
        int newSquare;
        do {
          newSquare = Random().nextInt(4) + 1;
        } while (newSquare == _activeSquare);
        _activeSquare = newSquare;

        if (!_isBlinking) {
          _selectedSquare = 0;
        }

        _blinkAnimationController.forward().then((_) {
          _blinkAnimationController.reverse();
        });
      });
    });
  }

  void _restartDisconnectTimer() {
    _disconnectTimer?.cancel();
    _disconnectTimer = Timer(_disconnectTimeout, () {
      setState(() {
        _isServerRunning = false;
        _isBlinking = false;
      });
      _speak("Connection lost with the headset");
    });
  }

  void _startMonitoringConnection() {
    _periodicChecker?.cancel();
    _periodicChecker = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_lastBlinkTime == null) return;

      final difference = DateTime.now().difference(_lastBlinkTime!);
      if (difference > _disconnectTimeout) {
        if (_isServerRunning) {
          setState(() {
            _isServerRunning = false;
            _isBlinking = false;
          });
          _speak("Connection lost with the headset");
        }
      }
    });
  }

  void _resetAutoDisconnectTimer() {
    _autoDisconnectTimer?.cancel();
    _autoDisconnectTimer = Timer(const Duration(seconds: 35), () {
      if (_isServerRunning) {
        _stopServer();
        _speak("No blink detected for 20 seconds. Disconnected from headset.");
      }
    });
  }

  void _startServer() async {
    final blinkCompleter = Completer<bool>();
    bool blinkReceived = false;
    try {
      await stopBlinkServer(); // ensure previous server closed
      await startBlinkServer((isIntentional) {
        if (isIntentional == true) {
          _resetAutoDisconnectTimer(); // Reset timer on every blink
          if (!blinkReceived) {
            blinkReceived = true;
            blinkCompleter.complete(true);
          }
          setState(() {
            _doubleBlinkCount += 2;
            numberOfDBlinks += 2;
            _isBlinking = true;
            _isServerRunning = true;
            if (_isTestRunning) {
              _selectedSquare = _activeSquare;
            }
          });
          _lastBlinkTime = DateTime.now();
          _blinkAnimationController.forward().then((_) {
            _blinkAnimationController.reverse();
          });
          // Notify other parts of the app about a successful double blink
          BlinkEventBus().emit();
          if (_selectedSquare > 0 && _isTestRunning) {
            _speak("Square $_selectedSquare selected successfully");
          }
        }
      });

      // Wait for the first blink or timeout
      final connected = await blinkCompleter.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );

      if (connected) {
        setState(() {
          _isServerRunning = true;
        });
        _speak("Headset connected successfully");
        _lastBlinkTime = DateTime.now();
        _startMonitoringConnection();
        if (_isTestRunning) {
          _startSquareRotation();
        }
        _resetAutoDisconnectTimer();
      } else {
        setState(() {
          _isServerRunning = false;
        });
        _speak("Can't connect to the headset");
      }
    } catch (e) {
      setState(() {
        _isServerRunning = false;
      });
      _speak("Can't connect to the headset");
    }
  }

  void _stopServer() {
    stopBlinkServer(); // close shelf server
    setState(() {
      _isServerRunning = false;
      _isBlinking = false;
      _selectedSquare = 0;
    });
    _disconnectTimer?.cancel();
    _periodicChecker?.cancel();
    _squareTimer?.cancel();
    _autoDisconnectTimer?.cancel();
    _speak("Headset disconnected");
    _isTestRunning = false; // Reset test mode when server stops
  }

  @override
  void didUpdateWidget(ConnectedHeadset oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _tabController.animateTo(widget.initialTab);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    _blinkAnimationController.dispose();
    _disconnectTimer?.cancel();
    _periodicChecker?.cancel();
    _squareTimer?.cancel();
    _autoDisconnectTimer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF9ED),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 33, 95, 112),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.headset_mic_outlined, color: Color.fromARGB(255, 33, 95, 112)),
            ),
            const SizedBox(width: 55),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device Control',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          unselectedLabelStyle: const TextStyle(
            color: Color.fromARGB(255, 175, 173, 173),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          dividerColor: Colors.grey,
          controller: _tabController,
          indicatorColor: const  Color.fromARGB(255, 138, 246, 141),
          indicatorWeight:3,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.poppins(
            color: const Color.fromARGB(255, 247, 244, 244),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.headset),
              text: 'Headset Control',
            ),
            Tab(
              icon: Icon(Icons.navigation),
              text: 'Robot Control',
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
      body: TabBarView(
        controller: _tabController,
        children: [
          // First tab - Headset Control
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top:5,left: 16, right: 16),
                  child: _buildConnectionCard(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5,left: 16, right: 16),
                  child: _buildBlinkTestCard(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top:10, left: 16,right: 16,bottom: 15),
                    child: _buildSquareSelectionGame(),
                  ),
                ),
              ],
            ),
          ),
          // Second tab - Robot Control
          ConnectionPage(key: _robotKey),
        ],
      ),
    );
  }

  Widget _buildSquareSelectionGame() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(29),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff0D343F).withOpacity(0.1),
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
              Text(
                'Square Selection Test',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff0D343F),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _isTestRunning
                    ? () {
                        setState(() {
                          _isTestRunning = false;
                          _squareTimer?.cancel();
                          _selectedSquare = 0;
                        });
                      }
                    : () {
                        setState(() {
                          _isTestRunning = true;
                          _selectedSquare = 0;
                          _activeSquare = 1;
                          _doubleBlinkCount = 0;
                        });
                        if (_isServerRunning) {
                          _startSquareRotation();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0D343F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isTestRunning ? 'Stop' : 'Start',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.only(left: 80, right: 80, top: 15),
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 50,
              children: List.generate(4, (index) {
                final number = index + 1;
                final isActive = _isTestRunning && number == _activeSquare;
                final isSelected = _isTestRunning && number == _selectedSquare;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    
                    color:
                        isActive ? const Color(0xff34C772) : const Color(0xff0D343F),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.amber
                          : isActive
                              ? const Color(0xff34C772)
                              : const Color(0xff0D343F),
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: [
                      if (isActive)
                        BoxShadow(
                          color: const Color(0xff34C772).withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          if (_isTestRunning && _selectedSquare > 0) ...[
            const SizedBox(height: 16),
            _buildSelectedIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildBlinkIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isBlinking
            ? Colors.green.withOpacity(0.2)
            : const Color(0xff0D343F).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isBlinking ? Colors.green : const Color(0xff0D343F),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.remove_red_eye,
            size: 16,
            color: _isBlinking ? Colors.green : const Color(0xff0D343F),
          ),
          const SizedBox(width: 6),
          Text(
            '$_doubleBlinkCount/2',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _isBlinking ? Colors.green : const Color(0xff0D343F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xff34C772).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xff34C772).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xff34C772),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Selected: $_selectedSquare',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xff34C772),
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildConnectionCard() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xff0D343F).withOpacity(0.1),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xff0D343F).withOpacity(0.1),
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
              _isServerRunning ? Icons.headset : Icons.headset_off,
              color: _isServerRunning ? Colors.green : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
             Text(
              _isServerRunning ? 'Connected' : 'Not Connected',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _isServerRunning ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xff0D343F).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Port: 5000',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff0D343F),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 40),
        if (!_isServerRunning)
          ElevatedButton(
            onPressed: _startServer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff0D343F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.power_settings_new, size: 17, color: Color.fromARGB(255, 138, 246, 141)),
                const SizedBox(width: 8),
                Text(
                  'Start Server',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isServerRunning)
            ElevatedButton(
              onPressed: _stopServer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0D343F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.power_settings_new, size: 17, color: Color.fromARGB(255, 138, 246, 141)),
                  const SizedBox(width: 8),
                  Text(
                    'Stop Server',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

      ],
    ),
  );
}


  
Widget _buildBlinkTestCard() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xff0D343F).withOpacity(0.1),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xff0D343F).withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.remove_red_eye,
              color: _isBlinking ? Colors.green : const Color(0xff0D343F),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Blink Test',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff0D343F),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 24),
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _isBlinking 
                    ? Colors.green.withOpacity(0.2) 
                    : const Color(0xff0D343F).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isBlinking ? Colors.green : const Color(0xff0D343F),
                  width: 2,
                ),
                boxShadow: [
                  if (_isBlinking)
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_doubleBlinkCount/2',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _isBlinking 
                              ? Colors.green 
                              : const Color(0xff0D343F),
                        ),
                      ),
                    ),
                    Text(
                      'Blinks',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 8,
                          color: _isBlinking 
                              ? Colors.green 
                              : const Color(0xff0D343F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isBlinking)
              AnimatedBuilder(
                animation: _blinkAnimationController,
                builder: (context, child) {
                  return Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green.withOpacity(
                          0.5 * (1 - _blinkAnimationController.value),
                        ),
                        width: 3,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    ),
  );
}

  //================ External control helpers =================
  void startServerExternal() {
    if (!_isServerRunning) {
      _startServer();
    }
  }

  void stopServerExternal() {
    if (_isServerRunning) {
      _stopServer();
    }
  }

  void startTestExternal() {
    if (!_isTestRunning) {
      setState(() {
        _isTestRunning = true;
        _selectedSquare = 0;
        _activeSquare = 1;
        _doubleBlinkCount = 0;
      });
      if (_isServerRunning) {
        _startSquareRotation();
      }
    }
  }

  void stopTestExternal() {
    if (_isTestRunning) {
      setState(() {
        _isTestRunning = false;
        _squareTimer?.cancel();
        _selectedSquare = 0;
      });
    }
  }

  // ===== Robot connection helpers =====
  void connectRobotExternal() {
    if (_tabController.index == 1 && _robotKey.currentState != null) {
      _robotKey.currentState!.connectRobotExternal();
      return;
    }
    _pendingRobotDisconnect = false;
    _pendingRobotConnect = true;
    _tabController.animateTo(1);
  }

  void disconnectRobotExternal() {
    if (_tabController.index == 1 && _robotKey.currentState != null) {
      _robotKey.currentState!.disconnectRobotExternal();
      return;
    }
    _pendingRobotConnect = false;
    _pendingRobotDisconnect = true;
    _tabController.animateTo(1);
  }
}
