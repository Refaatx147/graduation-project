// ignore_for_file: must_be_immutable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grade_pro/features/blocs/map_cubit/map_cubit.dart';
import 'package:grade_pro/features/blocs/map_cubit/map_state.dart';

class NavigationTest extends StatelessWidget {
   NavigationTest({super.key});
FirebaseAuth auth = FirebaseAuth.instance;
  final String patientId = FirebaseAuth.instance.currentUser?.uid ?? '';
  @override
  Widget build(BuildContext context) {
    return BlocProvider(    
      create: (context) => MapCubit(userId: patientId, isPatient: true),
      child: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) {
          return Container(
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
            // Forward Button
            ElevatedButton(
              onPressed: () {
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    state is MapLoaded && state.activeArrowIndex == 0
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
                    backgroundColor:
                        state is MapLoaded && state.activeArrowIndex == 3
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
                    backgroundColor:
                        state is MapLoaded && state.activeArrowIndex == 1
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
                backgroundColor:
                    state is MapLoaded && state.activeArrowIndex == 2
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
      );
        },
      ),
      );
}
  }