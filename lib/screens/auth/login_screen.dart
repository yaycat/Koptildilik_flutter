import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert'; // для utf8 и base64
import 'package:firebase_database/firebase_database.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String errorMessage = '';
  bool _loading = false;

  String hashPassword(String password, String saltBase64) {
    final salt = base64.decode(saltBase64);
    final bytes = utf8.encode(password) + salt;  // Конкатенация байтов пароля и соли
    final digest = sha256.convert(bytes);
    return base64.encode(digest.bytes);
  }


  Future<void> _loginUser() async {
    setState(() {
      errorMessage = '';
      _loading = true;
    });

    final enteredLogin = _loginController.text.trim();
    final enteredPassword = _passwordController.text.trim();

    final dbRef = FirebaseDatabase.instance.ref();
    final snapshot = await dbRef.child('Accounts').get();

    if (!snapshot.exists) {
      setState(() {
        errorMessage = "Қате: база бос.";
        _loading = false;
      });
      return;
    }

    Map? user;
    String? userKey;

    final accounts = snapshot.value as Map;
    for (var entry in accounts.entries) {
      final value = entry.value as Map;
      if (value['login'] == enteredLogin) {
        user = value;
        userKey = entry.key;
        break;
      }
    }

    if (user == null || userKey == null) {
      setState(() {
        errorMessage = "Пайдаланушы табылмады.";
        _loading = false;
      });
      return;
    }

    final salt = user['salt'];
    final storedHash = user['passwordHash'];

    if (salt == null || storedHash == null) {
      setState(() {
        errorMessage = "⚠️ Қолданушыда пароль немесе тұз (salt) табылмады.";
        _loading = false;
      });
      return;
    }

    final enteredHash = hashPassword(enteredPassword, salt);

    if (enteredHash == storedHash) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('login', user['login']);
      await prefs.setString('selected_language', user['language']);
      await prefs.setString('selected_topic', user['topic']);
      await prefs.setInt('user_level', user['level'] ?? 1);
      final now = DateTime.now().toIso8601String();
      await dbRef.child('Accounts/$userKey/lastLoginAt').set(now);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } else {
      setState(() {
        errorMessage = "Құпия сөз дұрыс емес.";
        _loading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Кіру")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _loginController,
                decoration: const InputDecoration(labelText: "Логин"),
                validator: (val) => val == null || val.isEmpty ? "Логин енгізіңіз" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Құпия сөз"),
                obscureText: true,
                validator: (val) => val == null || val.isEmpty ? "Құпия сөз енгізіңіз" : null,
              ),
              const SizedBox(height: 20),
              if (errorMessage.isNotEmpty)
                Text(errorMessage, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _loginUser();
                  }
                },
                child: const Text("Кіру"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}