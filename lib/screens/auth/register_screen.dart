import 'package:flutter/material.dart';

import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:crypto/crypto.dart'; // для sha256
import 'package:shared_preferences/shared_preferences.dart';


class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String _errorMessage = '';

  String generateSalt() {
    final rand = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return base64Encode(saltBytes);
  }

  String hashPassword(String password, String saltBase64) {
    final salt = base64.decode(saltBase64);
    final bytes = utf8.encode(password) + salt;  // Конкатенация байтов пароля и соли
    final digest = sha256.convert(bytes);
    return base64.encode(digest.bytes);
  }



  Future<void> _registerUser() async {
    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    final login = _loginController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final dbRef = FirebaseDatabase.instance.ref().child('Accounts');
    final now = DateTime.now().toIso8601String(); // 🔥 Уақытты алу

    final snapshot = await dbRef.child(login).get();
    if (snapshot.exists) {
      setState(() {
        _loading = false;
        _errorMessage = "Бұл логинмен қолданушы бар.";
      });
      return;
    }

    final salt = generateSalt();
    final passwordHash = hashPassword(password, salt);

    final defaultLang = "Қазақ тілі";
    final defaultTopic = "Мансап";
    final defaultLevel = 1;

    await dbRef.child(login).set({
      "login": login,
      "email": email,
      "passwordHash": passwordHash,
      "salt": salt,
      "language": defaultLang,
      "topic": defaultTopic,
      "level": defaultLevel,
      "registeredAt": now,
      "lastLoginAt": now,
      "l_login": login,
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('login', login);
    await prefs.setString('selected_language', defaultLang);
    await prefs.setString('selected_topic', defaultTopic);
    await prefs.setInt('user_level', defaultLevel);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/create_pin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Тіркелу")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _loginController,
                decoration: const InputDecoration(labelText: 'Логин'),
                validator: (val) => val == null || val.isEmpty ? "Логин енгізіңіз" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (val) => val == null || val.isEmpty ? "Email енгізіңіз" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Құпия сөз'),
                validator: (val) => val == null || val.length < 6
                    ? "Кемінде 6 символ енгізіңіз"
                    : null,
              ),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              if (_loading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _registerUser();
                    }
                  },
                  child: const Text("Тіркелу"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
