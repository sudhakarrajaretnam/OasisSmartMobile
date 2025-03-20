//import 'package:firebase_app_check/firebase_app_check.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:oassis_mart/pages/buy/buy_home.dart';
import 'package:oassis_mart/pages/drawer/all_history.dart';
import 'package:oassis_mart/pages/services/services_home.dart';
import 'package:oassis_mart/pages/welcome/otp_screen.dart';
//import 'package:oassis_mart/pages/welcome/otp_verify.dart';
import 'package:oassis_mart/pages/welcome/welcome_screen.dart';
import 'package:oassis_mart/util/global_variables.dart';

import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  //await FirebaseAppCheck.instance.activate(androidProvider: AndroidProvider.debug);
  final prefs = await SharedPreferences.getInstance();
  //await prefs.clear();
  //userId = prefs.getString("userId") ?? '6787a8fee4c677de8e935f74';
  userId = prefs.getString("userId") ?? '';
  //print("userId===============" + userId);
  mobileNumber = prefs.getString("mobileNumber") ?? '';
  userName = prefs.getString("userName") ?? '';
  debugPrint('Firebase App Check Debug Token initialized');
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyApp();
}

class _MyApp extends ConsumerState<MyApp> {
  //const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: nameTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4CAF50), // Green color for the theme
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
        ).copyWith(
          secondary: const Color(0xFFFDD835), // Yellow for accents
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF), // Light green for background
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black),
          labelLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50), // Matching green buttons
            foregroundColor: Colors.white, // Text color on buttons
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
      initialRoute: userId.isEmpty ? '/otp' : '/welcome',
      routes: {
        '/otp': (context) => const OtpScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/buyhome': (context) => const BuyHome(),
        '/myorders': (context) => const HistoryTabs(),
        '/services': (context) => const ServicesHome(),
      },
      //home: const WelcomeScreen(),
      //home: userId == '' ? const OtpScreen() : const WelcomeScreen(),
      //home: userId == '' ? const OtpVerify() : const WelcomeScreen(),
    );
  }
}
