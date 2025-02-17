import 'package:flutter/material.dart';

class PatientScreen extends StatelessWidget {
  const PatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Page'),
      ),
      body: Center(
        child: Text('Welcome, Patient!'),
      ),
    );
  }
}