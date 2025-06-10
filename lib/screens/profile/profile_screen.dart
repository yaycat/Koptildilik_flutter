import 'package:flutter/material.dart';

import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:crypto/crypto.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String login = '';
  String language = '';
  String email = '';
  String topic = '';
  String registeredAt = '';
  String lastLoginAt = '';
  int level = 1;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String formatDateTime(String dateTimeString) {
    try {
      final dt = DateTime.parse(dateTimeString);
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year.toString();
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      final second = dt.second.toString().padLeft(2, '0');
      return "$day-$month-$year. $hour:$minute:$second";
    } catch (e) {
      return dateTimeString; // если формат не распарсился, вернуть оригинал
    }
  }

  String generateSalt() {
    final rand = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return base64Encode(saltBytes);
  }

  // Получить хэш пароля по алгоритму из твоей базы
  String hashPassword(String password, String saltBase64) {
    final salt = base64.decode(saltBase64);
    final bytes = utf8.encode(password) + salt;
    final digest = sha256.convert(bytes);
    return base64.encode(digest.bytes);
  }


  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final dbRef = FirebaseDatabase.instance.ref();
    final currentLogin = prefs.getString('login') ?? '';

    if (currentLogin.isNotEmpty) {
      final snapshot = await dbRef.child('Accounts/$currentLogin').get();
      final user = snapshot.value as Map?;

      setState(() {
        login = user?['login'] ?? currentLogin;
        email = user?['email'] ?? '';
        language = prefs.getString('selected_language') ?? 'Қазақ тілі';
        topic = prefs.getString('selected_topic') ?? 'Байланыс';
        level = prefs.getInt('user_level') ?? 1;
        registeredAt = formatDateTime(user?['registeredAt'] ?? '');
        lastLoginAt = formatDateTime(user?['lastLoginAt'] ?? '');
      });
    }
  }


  Future<void> _showEditEmailDialog() async {
    final controller = TextEditingController(text: email);
    String newEmail = email;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Поштаны өзгерту'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Жаңа почта'),
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          onChanged: (value) => newEmail = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Бас тарту'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newEmail.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email енгізіңіз')),
                );
                return;
              }
              if (newEmail == email) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email өзгертілмеген')),
                );
                return;
              }
              final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
              if (!emailRegex.hasMatch(newEmail)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email дұрыс емес')),
                );
                return;
              }

              final dbRef = FirebaseDatabase.instance.ref();
              await dbRef.child('Accounts/$login').update({
                'email': newEmail,
              });

              setState(() {
                email = newEmail;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email сәтті жаңартылды!')),
              );
              Navigator.pop(context);
            },
            child: const Text('Сақтау'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditLoginDialog() async {
    final controller = TextEditingController(text: login);
    String newLogin = login;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Логинді өзгерту'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Жаңа логин'),
          onChanged: (value) => newLogin = value.trim(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Бас тарту'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newLogin.isEmpty || newLogin == login) return;

              final dbRef = FirebaseDatabase.instance.ref();
              final exists = (await dbRef.child('Accounts/$newLogin').get()).exists;
              if (exists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Бұл логин бос емес')),
                );
                return;
              }

              final oldData = (await dbRef.child('Accounts/$login').get()).value as Map?;
              if (oldData != null) {
                await dbRef.child('Accounts/$newLogin').set({
                  ...oldData,
                  'login': newLogin,
                });
                await dbRef.child('Accounts/$login').remove();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('login', newLogin);

                setState(() => login = newLogin);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Логин сәтті өзгертілді')),
                );
              }

              Navigator.pop(context);
            },
            child: const Text('Сақтау'),
          ),
        ],
      ),
    );
  }


  // Диалог для изменения пароля
  Future<void> _showChangePasswordDialog() async {
    String oldPassword = '';
    String newPassword = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Құпиясөзді өзгерту'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Ескі құпиясөз'),
              onChanged: (value) => oldPassword = value,
            ),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Жаңа құпиясөз'),
              onChanged: (value) => newPassword = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Бас тарту'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (oldPassword.isEmpty || newPassword.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Барлық өрістерді толтырыңыз')),
                );
                return;
              }
              if (oldPassword == newPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Жаңа құпиясөз ескіден өзгеше болу керек')),
                );
                return;
              }

              final dbRef = FirebaseDatabase.instance.ref();
              final snapshot = await dbRef.child('Accounts/$login').get();
              final user = snapshot.value as Map?;
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Пайдаланушы табылмады')),
                );
                return;
              }

              final savedSalt = user['salt'] as String? ?? '';
              final savedHash = user['passwordHash'] as String? ?? '';

              final oldHash = hashPassword(oldPassword, savedSalt);

              if (oldHash != savedHash) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ескі құпиясөз дұрыс емес')),
                );
                return;
              }

              // Генерация новой соли
              final newSalt = generateSalt(); // используй свою функцию
              final newHash = hashPassword(newPassword, newSalt);

              await dbRef.child('Accounts/$login').update({
                'passwordHash': newHash,
                'salt': newSalt,
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Құпиясөз сәтті ауыстырылды!')),
              );
              Navigator.pop(context);
            },
            child: const Text('Сақтау'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (isGuest) {
      return Scaffold(
        appBar: AppBar(title: const Text("Профиль")),
        body: const Center(
          child: Text(
            "Гостевой режимде профиль бөлімі қолжетімсіз.",
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Профиль")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.email),
                const SizedBox(width: 12),
                Expanded(child: Text("Почта: $email")),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Поштаны өзгерту',
                  onPressed: _showEditEmailDialog,
                ),
              ],
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text("Логин: $login"),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Логинді өзгерту',
                onPressed: _showEditLoginDialog,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text("Тіл: $language"),
            ),
            ListTile(
              leading: const Icon(Icons.topic),
              title: Text("Тақырып: $topic"),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: Text("Деңгей: $level"),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text("Тіркелген күні: $registeredAt"),
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: Text("Соңғы кіру: $lastLoginAt"),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.lock),
              label: const Text('Құпиясөзді өзгерту'),
              onPressed: _showChangePasswordDialog,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
