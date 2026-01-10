import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'utils/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/couple_setup_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  // Run app in error zone to catch all errors
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase
    // Note: You'll need to add firebase_options.dart using FlutterFire CLI
    // Run: flutterfire configure
    try {
      await Firebase.initializeApp();
      
      // Initialize Crashlytics
      await _initializeCrashlytics();
      
      // Initialize Performance Monitoring
      await _initializePerformanceMonitoring();
      
      print('✅ Firebase services initialized successfully');
    } catch (e, stackTrace) {
      print('❌ Firebase initialization error: $e');
      // Log to Crashlytics if available
      try {
        FirebaseCrashlytics.instance.recordError(e, stackTrace);
      } catch (_) {}
    }

    runApp(const MyApp());
  }, (error, stack) {
    // Catch all errors in the app and log to Crashlytics
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

/// Initialize Firebase Crashlytics
Future<void> _initializeCrashlytics() async {
  // Pass all uncaught Flutter errors to Crashlytics
  FlutterError.onError = (FlutterErrorDetails details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  // Pass all uncaught asynchronous errors to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Enable crash collection in release mode
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  print('✅ Crashlytics initialized');
}

/// Initialize Firebase Performance Monitoring
Future<void> _initializePerformanceMonitoring() async {
  final performance = FirebasePerformance.instance;
  
  // Enable performance monitoring
  await performance.setPerformanceCollectionEnabled(true);
  
  print('✅ Performance Monitoring initialized');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Couple Tasks',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/couple-setup': (context) => const CoupleSetupScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is signed in
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // User is not signed in
        return const OnboardingScreen();
      },
    );
  }
}
