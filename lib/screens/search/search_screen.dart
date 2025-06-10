import 'package:flutter/material.dart';

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, String>> allWords = [];
  List<Map<String, String>> filteredWords = [];
  bool isLoading = true;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchWordsFromFirebase();
  }

  Future<void> fetchWordsFromFirebase() async {
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref('languages');
    final DataSnapshot snapshot = await dbRef.get();

    if (snapshot.exists) {
      final Map data = snapshot.value as Map;
      List<Map<String, String>> tempWords = [];

      for (var languageKey in data.keys) {
        final languageData = data[languageKey];
        final topics = languageData['topics'] ?? {};

        for (var topicKey in topics.keys) {
          final levels = topics[topicKey];

          for (var levelKey in levels.keys) {
            final words = levels[levelKey];

            for (var wordKey in words.keys) {
              final translations = Map<String, String>.from(words[wordKey]);
              tempWords.add(translations);
            }
          }
        }
      }

      setState(() {
        allWords = tempWords;
        filteredWords = tempWords;
        isLoading = false;
      });
    }
  }

  void _filterWords(String query) {
    final lowerQuery = query.toLowerCase();
    final results = allWords.where((wordMap) {
      return wordMap.values.any(
              (translation) => translation.toLowerCase().contains(lowerQuery));
    }).toList();

    setState(() {
      filteredWords = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Words'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              onChanged: _filterWords,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredWords.length,
              itemBuilder: (context, index) {
                final wordMap = filteredWords[index];
                return ListTile(
                  title: Text(wordMap.entries
                      .map((e) => '${e.key}: ${e.value}')
                      .join(', ')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
