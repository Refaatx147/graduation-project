// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grade_pro/core/utils/firebase_auth.dart';
import 'package:grade_pro/features/authentication/presentation/blocs/auth_bloc/cubit/auth_cubit.dart';
import 'package:grade_pro/features/authentication/presentation/blocs/auth_bloc/cubit/auth_state.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(authService: AuthService()),
      child: Scaffold(
          appBar: AppBar(title: const Text('Welcome Home')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    return ElevatedButton(
                        onPressed: () {
                          context.read<AuthCubit>().signOut();
                          Navigator.pushReplacementNamed(
                              context, '/user-select');
                        },
                        child: Text('logout'));
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Text('Successfully Authenticated!',
                    style: TextStyle(fontSize: 24)),
              ],
            ),
          )),
    );
  }
}
