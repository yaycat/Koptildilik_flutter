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

import '../profile/profile_screen.dart';
import '../progress/progress_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';
import '../words/word_screen.dart';


class MainScreen extends StatefulWidget {
  final int currentIndex;
  final Function(ThemeMode) changeTheme;
  final Function(Locale) changeLocale;

  const MainScreen({
    super.key,
    required this.currentIndex,
    required this.changeLocale,
    required this.changeTheme,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  int _previousIndex = 0;
  final List<Widget> _screens = [];
  late StreamSubscription<ConnectivityResult> _subscription;
  bool _isOffline = false;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _snackBarController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
    _previousIndex = _selectedIndex;
    _screens.addAll([
      const ProgressScreen(),
      const SearchScreen(),
      const WordScreen(),
      const ProfileScreen(),
      SettingsScreen(
        changeLocale: widget.changeLocale,
        changeTheme: widget.changeTheme,
      )
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
      const SnackBar(
        content: Text("Интернетке қосылу жоқ"),
        duration: Duration(days: 1),
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
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isForward = _selectedIndex >= _previousIndex;

    return Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation, secondaryAnimation) {
          final beginOffset = isForward ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);
          return SlideTransition(
            position: animation.drive(
              Tween<Offset>(begin: beginOffset, end: Offset.zero).chain(CurveTween(curve: Curves.ease)),
            ),
            child: child,
          );
        },
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Прогресс'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Іздеу'), // Новый пункт
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Сөздер'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Баптау'),
        ],
      ),
    );
  }
}
