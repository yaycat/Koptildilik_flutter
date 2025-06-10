import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';



class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  bool _loading = false;
  String _errorMessage = '';

  Future<void> _savePinCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString('login');

    if (login == null) {
      setState(() {
        _loading = false;
        _errorMessage = "Логин табылмады. Қайта тіркеліңіз.";
      });
      return;
    }

    final pin = _pinController.text.trim();
    final dbRef = FirebaseDatabase.instance.ref().child('Accounts');

    await dbRef.child(login).update({
      "pinCode": pin,
    });

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/choose'); // change to your next screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Пин-код орнату")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "4 таңбалы Пин-код ойлап табыңыз",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Пин-код',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.length != 4 || !RegExp(r'^\d{4}$').hasMatch(val)) {
                    return "Тек 4 цифр енгізіңіз";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              if (_loading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _savePinCode,
                  child: const Text("Сақтау"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
