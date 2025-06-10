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


class SettingsScreen extends StatelessWidget {
  final Function(ThemeMode) changeTheme;
  final Function(Locale) changeLocale;

  const SettingsScreen({
    super.key,
    required this.changeTheme,
    required this.changeLocale,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: TabBarView(
          children: [
            _SettingsContent(
              changeTheme: changeTheme,
              changeLocale: changeLocale,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsContent extends StatefulWidget {
  final Function(ThemeMode) changeTheme;
  final Function(Locale) changeLocale;

  const _SettingsContent({
    required this.changeTheme,
    required this.changeLocale,
  });

  @override
  State<_SettingsContent> createState() => __SettingsContentState();
}

class __SettingsContentState extends State<_SettingsContent> {
  bool _darkMode = false;
  String _selectedLang = 'kk';
  String _learningMode = 'cards';
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLang = prefs.getString('language_code') ?? 'kk';
      _learningMode = prefs.getString('learning_mode') ?? 'cards';
      _darkMode = prefs.getBool('is_dark_mode') ?? false;
    });
  }

  Future<void> _changeThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _themeMode = mode);
    await prefs.setString('theme_mode', mode.name);
    widget.changeTheme(mode);
  }

  Future<void> _resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString('login');
    await prefs.setInt('user_level', 1);

    if (login != null) {
      final dbRef = FirebaseDatabase.instance.ref();
      await dbRef.child('Accounts/$login/level').set(1);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Прогресс сәтті жаңартылды.")),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  Future<void> _choose() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/choose');
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isGuest) {
      return Scaffold(
        appBar: AppBar(title: const Text("Баптау")),
        body: const Center(
          child: Text(
            "Гостевой режимде баптау бөлімі қолжетімсіз.",
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Баптау"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Ақпарат жаңартылды.")),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("\n"),
            const Text("🎨 Тема режимі", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<ThemeMode>(
              value: _themeMode,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: ThemeMode.light, child: Text("Ақшыл")),
                DropdownMenuItem(value: ThemeMode.dark, child: Text("Қараңғы")),
              ],
              onChanged: (mode) {
                if (mode != null) _changeThemeMode(mode);
              },
            ),
            const SizedBox(height: 20),
            const Text("🌐 Интерфейс тілі", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedLang,
              items: const [
                DropdownMenuItem(value: 'kk', child: Text('Қазақша')),
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'ru', child: Text('Русский')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedLang = val);
                  widget.changeLocale(Locale(val));
                }
              },
              decoration: const InputDecoration(
                labelText: 'Тілді таңдаңыз',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text("🧠 Оқу режимі", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _learningMode,
              items: const [
                DropdownMenuItem(value: 'cards', child: Text('Карточкалар')),
                DropdownMenuItem(value: 'quiz', child: Text('Викторина')),
                DropdownMenuItem(value: 'write', child: Text('Сөз жаз')),
              ],
              onChanged: (val) async {
                if (val != null) {
                  setState(() => _learningMode = val);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('learning_mode', val);
                }},
              decoration: const InputDecoration(
                labelText: 'Режимді таңдаңыз',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _resetProgress,
              icon: const Icon(Icons.refresh),
              label: const Text("Прогресті жаңарту"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                '/about',
              ),
              icon: const Icon(Icons.privacy_tip),
              label: const Text("Құпиялық саясаты"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _choose,
              icon: const Icon(Icons.abc),
              label: const Text("Тіл мен тақырыпты таңдаңыз"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text("Шығу"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}