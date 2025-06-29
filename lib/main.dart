import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'cubit/product_cubit.dart';
import 'cubit/cart_cubit.dart';
import 'cubit/auth_cubit.dart';
import 'cubit/auth_state.dart';
import 'api_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Suppress FlutterDartVMServicePublisher permission warning
  FlutterError.onError = (FlutterErrorDetails details) {
    if (!details.toString().contains('FlutterDartVMServicePublisher')) {
      FlutterError.presentError(details);
    }
  };
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(ApiService()),
        ),
        BlocProvider<ProductCubit>(
          create: (context) => ProductCubit(ApiService()),
        ),
        BlocProvider<CartCubit>(
          create: (context) => CartCubit(ApiService()),
        ),
      ],
      child: MaterialApp(
        title: 'E-Commerce Store',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const HomeScreen();
            } else if (state is AuthUnauthenticated) {
              return const LoginScreen();
            } else {
              // Show loading screen while checking auth status
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
