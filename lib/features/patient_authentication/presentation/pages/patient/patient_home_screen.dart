// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:grade_pro/core/utils/user_auth_service.dart';

class HomePatient extends StatelessWidget {
  final UserAuthService authService;


  const HomePatient({super.key, required this.authService,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
     //   backgroundColor: Color.fromARGB(255, 13, 46, 62),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 95.0,top: 24),
              child: Text('Hello, Ahmed!',
              textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),

            IconButton(
            icon: const Icon(Icons.logout,color: Color.fromARGB(255, 20, 55, 54),),
            onPressed: () async {
             // await VoiceAuthService().logout();
             
            },
          ),
            Padding(
              padding: const EdgeInsets.only(left: 90.0),
              child: _buildCircularControl(),
            ),

            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildHealthCard(
                    icon: Icons.favorite,
                    title: 'HEART RATE',
                    value: '120 bpm',
                    color: const Color.fromARGB(255, 13, 51, 61),
                  ),
                  _buildHealthCard(
                    icon: Icons.opacity,
                    title: 'BLOOD PRESSURE',
                    value: '120/80',
                    color: const Color.fromARGB(255, 23, 59, 88),
                  ),
                  _buildHealthCard(
                    icon: Icons.thermostat,
                    title: 'TEMPERATURE',
                    value: '40°C',
                    color: const Color.fromARGB(255, 49, 102, 99),
                  ),
                  _buildHealthCard(
                    icon: Icons.show_chart,
                    title: 'BLOOD LEVEL',
                    value: '98 mg/dL',
                    color: const Color.fromARGB(255, 49, 102, 99),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularControl() {
    return SizedBox(

      width: 200,
      height: 200,
      child: ClipOval(
        child: Container(
         // width: double.infinity,
          decoration: BoxDecoration(

            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.blueGrey.shade100, width: 1),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(

                      child: InkWell(
                        onTap: () {},
                        splashColor: Colors.white.withOpacity(0.2),
                        child: Container(
                          color: const Color.fromARGB(255, 215, 220, 220),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.move_down_sharp, 
                                  color: Color.fromARGB(255, 15, 53, 61), size: 32),
                              SizedBox(height: 8),
                              Text('Navigate',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 15, 53, 61),
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        splashColor: Colors.white.withOpacity(0.2),
                        child: Container(
                          color: const Color(0xff3C768A),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back_sharp,
                                  color: Colors.white, size: 32),
                              SizedBox(height: 8),
                              Text('Back',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Center(
              //   child: Container(
              //     width: 60,
              //     height: 60,
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       shape: BoxShape.circle,
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black.withOpacity(0.1),
              //           blurRadius: 8,
              //           spreadRadius: 2,
              //         )
              //       ],
              //     ),
              //    // child: const Icon(Icons.add, size: 32),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, size: 32, color: color),
            Text(title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                )),
            Text(value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                )),
          ],
        ),
      ),
    );
  }
}