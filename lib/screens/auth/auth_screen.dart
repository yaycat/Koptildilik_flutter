import 'dart:async';

import 'package:flutter/material.dart';

import 'dart:math';
import 'dart:async';
import 'dart:convert'; // для utf8 и base64
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:crypto/crypto.dart'; // для sha256
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late StreamSubscription<ConnectivityResult> _subscription;
  bool _isOffline = false;
  bool _buttonsDisabled = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _snackBarController;

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      final hasConnection = result != ConnectivityResult.none;

      if (!hasConnection && !_isOffline) {
        setState(() => _isOffline = true);
        _showOfflineSnackBar();
      } else if (hasConnection && _isOffline) {
        setState(() => _isOffline = false);
        _removeSnackBar();
      }
    });
  }

  void _showOfflineSnackBar() {
    _snackBarController = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Интернетке қосылу жоқ"),
        duration: const Duration(days: 1), // Долго держим
        action: SnackBarAction(
          label: 'Перезапуск',
          onPressed: () {
            // перезапуск экрана
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AuthScreen(),
                transitionDuration: Duration.zero,
              ),
            );
          },
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeSnackBar() {
    _snackBarController?.close();
    _snackBarController = null;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _handleLoginOrRegister() {
    setState(() {
      isGuest = false; // Сбросить значение isGuest
      _buttonsDisabled = false; // Блокируем кнопки
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: const Text("Кіру")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Қалай жалғастырғыңыз келеді?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: _buttonsDisabled ? null : () {
                _handleLoginOrRegister();
                Navigator.pushNamed(context, '/register');
              },
              child: const Text("Тіркелу"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: _buttonsDisabled ? null : () {
                _handleLoginOrRegister();
                Navigator.pushNamed(context, '/login');
              },
              child: const Text("Кіру"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: _buttonsDisabled ? null : () {
                _handleLoginOrRegister();
                Navigator.pushNamed(context, '/login_with_pin');
              },
              child: const Text("Кіру пин-кодпен"),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.teal),
              ),
              onPressed: () {
                isGuest = true;
                Navigator.pushNamed(context, '/choose');
              },
              child: const Text("Гость ретінде кіру", style: TextStyle(color: Colors.teal)),
            ),
          ],
        ),
      ),
    );
  }
}
