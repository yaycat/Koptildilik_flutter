import 'package:flutter/material.dart';

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ThirdScreen extends StatelessWidget {
  const ThirdScreen({super.key});
  final Map<String, String> topics = const {
    "career": "👨‍💻 Мансап",
    "communication": "🤝 Адамдармен сөйлесу",
    "education": "📚 Білімі",
    "general": "📖 Жалпы",
    "self": "🧍 Өзі",
    "travel": "🌍 Саяхат",
  };

  Future<void> _saveTopic(String topic) async {
    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString('login');

    await prefs.setString('selected_topic', topic);
    await prefs.setInt('user_level', 1); // начальный уровень

    if (login != null) {
      final dbRef = FirebaseDatabase.instance.ref();
      await dbRef.child('Accounts/$login/topic').set(topic);
      await dbRef.child('Accounts/$login/level').set(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Тақырыпты таңдау")),
      body: ListView(
        children: topics.entries.map((entry) {
          final key = entry.key;
          final display = entry.value;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(display),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                await _saveTopic(key);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Тақырып таңдалды: $display")),
                );
                Navigator.pushNamed(context, '/main');
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
