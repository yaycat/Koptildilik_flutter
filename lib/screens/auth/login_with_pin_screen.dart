import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginWithPinScreen extends StatefulWidget {
  const LoginWithPinScreen({super.key});

  @override
  State<LoginWithPinScreen> createState() => _LoginWithPinScreenState();
}

class _LoginWithPinScreenState extends State<LoginWithPinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _pinController = TextEditingController();
  bool _loading = false;
  String _errorMessage = '';

  Future<void> _loginWithPin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    final enteredLogin = _loginController.text.trim();
    final enteredPin = _pinController.text.trim();

    final dbRef = FirebaseDatabase.instance.ref();
    final snapshot = await dbRef.child('Accounts').get();

    if (!snapshot.exists) {
      setState(() {
        _loading = false;
        _errorMessage = "Қате: база бос.";
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
        _loading = false;
        _errorMessage = "Пайдаланушы табылмады.";
      });
      return;
    }

    if (user['pinCode'] == null) {
      setState(() {
        _loading = false;
        _errorMessage = "Бұл қолданушыда пин-код орнатылмаған.";
      });
      return;
    }

    if (user['pinCode'] == enteredPin) {
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
        _loading = false;
        _errorMessage = "Пин-код дұрыс емес.";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Пин-кодпен кіру")),
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
                controller: _pinController,
                decoration: const InputDecoration(labelText: "Пин-код"),
                maxLength: 4,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) =>
                val == null || val.length != 4 ? "4 таңбалы пин-код енгізіңіз" : null,
              ),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _loginWithPin,
                child: const Text("Кіру"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
