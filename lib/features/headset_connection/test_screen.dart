import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  final int blinkCount;
  final VoidCallback onContinue;

  const TestScreen({
    super.key,
    required this.blinkCount,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Blink Test Result'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            Text(
              'Double Blink Detected!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Total Double Blinks: $blinkCount',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('Continue Testing'),
            ),
          ],
        ),
      ),
    );
  }
} 