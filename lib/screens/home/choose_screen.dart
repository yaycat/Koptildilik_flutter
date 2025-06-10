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

import '../common/second_screen.dart';
import '../common/third_screen.dart';


class ChooseScreen extends StatefulWidget {
  final int currentIndex;
  final Function(ThemeMode) changeTheme;
  final Function(Locale) changeLocale;

  const ChooseScreen({
    super.key,
    required this.currentIndex,
    required this.changeTheme,
    required this.changeLocale,
  });

  @override
  State<ChooseScreen> createState() => _ChooseScreenState();
}

class _ChooseScreenState extends State<ChooseScreen> {
  late int _selectedIndex;
  final List<Widget> _screens = [];
  late StreamSubscription<ConnectivityResult> _subscription;
  bool _isOffline = false;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _snackBarController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
    _screens.addAll([
      const SecondScreen(),
      const ThirdScreen(),
    ]);
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
        duration: const Duration(days: 1),
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


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) => _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.language), label: 'Тілдер'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Мамандық'),
        ],
      ),
    );
  }
}
