import 'package:flutter/material.dart';

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';


class WordScreen extends StatefulWidget {
  const WordScreen({super.key});

  @override
  State<WordScreen> createState() => _WordScreenState();
}

class _WordScreenState extends State<WordScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController _answerController = TextEditingController();
  String selectedLanguage = 'en';
  List<Map<String, dynamic>> wordList = [];
  int currentWordIndex = 0;
  int incorrectTries = 0;
  String currentWord = '';
  late ConfettiController _confettiController;
  String correctAnswer = '';
  List<String> options = [];
  String learningMode = 'cards';

  String? selectedLeft;
  String? selectedRight;
  List<Map<String, String>> matchBatch = [];
  List<String> matchedWords = [];
  List<String> rightColumn = [];

  @override
  void initState() {
    super.initState();
    _loadLearningMode();
    _loadWordsFromFirebase();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadLearningMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      learningMode = prefs.getString('learning_mode') ?? 'cards';
    });
  }


  Future<void> _loadWordsFromFirebase() async {
    final prefs = await SharedPreferences.getInstance();
    selectedLanguage = prefs.getString('selected_language') ?? 'en';
    final selectedTopic = prefs.getString('selected_topic') ?? 'career';
    final userLevel = prefs.getInt('user_level') ?? 1;


    final dbRef = FirebaseDatabase.instance.ref();
    final path = 'languages/kazakh/topics/$selectedTopic/level$userLevel';
    final snapshot = await dbRef.child(path).get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);

      final langFieldMap = {
        '🇬🇧 Ағылшын тілі': 'english',
        '🇩🇪 Неміс тілі': 'german',
        '🇷🇺 Орыс тілі': 'russian',
        '🇪🇸 Испан тілі': 'spanish',
        '🇰🇿 Қазақ тілі': 'kazakh',
      };
      final translationKey = langFieldMap[selectedLanguage] ?? 'english';

      wordList = data.entries.map((e) {
        final translations = Map<String, dynamic>.from(e.value);
        return {
          'foreign': translations[translationKey] ?? '',
          'kazakh': translations['kazakh'] ?? '',
        };
      }).toList();

      if (learningMode == 'cards') {
        _loadCurrentWord();
      } else if (learningMode == 'quiz') {
        _loadNextMatchBatch();
      } else if (learningMode == 'write') {
        if (currentWordIndex < wordList.length) {
          final wordData = wordList[currentWordIndex];
          currentWord = wordData['foreign'];
          correctAnswer = wordData['kazakh'];
        } else {
          _showLevelCompleteDialog();
        }
      }
      setState(() {});
    }
  }

  void _loadCurrentWord() {
    if (currentWordIndex < wordList.length) {
      final wordData = wordList[currentWordIndex];
      setState(() {
        currentWord = wordData['foreign'];
        correctAnswer = wordData['kazakh'];
        options = _generateOptions(correctAnswer);
      });
    } else {
      _showLevelCompleteDialog();
    }
  }

  void _loadNextMatchBatch() {
    if (currentWordIndex >= wordList.length) {
      _showLevelCompleteDialog();
      return;
    }
    final remaining = wordList.skip(currentWordIndex).take(4).toList();
    matchBatch = remaining.map((e) => {
      'foreign': e['foreign'].toString(),
      'kazakh': e['kazakh'].toString(),
    }).toList();
    rightColumn = matchBatch.map((e) => e['kazakh']!).toList()..shuffle();
    rightColumn.shuffle();
    matchedWords.clear();
    selectedLeft = null;
    selectedRight = null;
  }

  List<String> _generateOptions(String correct) {
    final allKazakhWords = wordList
        .map((e) => e['kazakh'] as String)
        .where((word) => word != correct)
        .toSet()
        .toList();

    allKazakhWords.shuffle();

    final fakeAnswers = allKazakhWords.take(3).toList()..add(correct);
    fakeAnswers.shuffle();
    return fakeAnswers;
  }

  Future<void> _speak() async {
    final ttsLanguageMap = {
      'en': 'en-US',
      'de': 'de-DE',
      'ru': 'ru-RU',
      'es': 'es-ES',
      'kk': 'kk-KZ',
    };

    final ttsLang = ttsLanguageMap[selectedLanguage] ?? 'en-US';

    await flutterTts.setLanguage(ttsLang);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(1.0);

    if (currentWord.isNotEmpty) {
      await flutterTts.speak(currentWord);
    }
  }

  void _checkAnswer(String answer) {
    final isCorrect = answer == correctAnswer;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isCorrect ? "Дұрыс!" : "Қате"),
        content: Text(isCorrect
            ? "Жарайсың! Бұл дұрыс жауап."
            : "Дұрыс емес"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (isCorrect) {
                setState(() {
                  currentWordIndex++;
                });
                _loadCurrentWord();
              }
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  Future<void> _showLevelCompleteDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString('login') ?? 'guest';
    int currentLevel = prefs.getInt('user_level') ?? 1;
    final nextLevel = currentLevel + 1;

    // Сохраняем новый уровень
    await prefs.setInt('user_level', nextLevel);

    final dbRef = FirebaseDatabase.instance.ref();
    await dbRef.child('Accounts/$login/level').set(nextLevel);

    _confettiController.play(); // Запускаем конфетти

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14 / 2, // Вниз
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.3,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -3.14 / 2, // Вверх
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.3,
            ),
          ),
          AlertDialog(
            title: const Text("🎉 Құттықтаймыз!"),
            content: Text("Сіз $currentLevel-деңгейін аяқтадыңыз! Келесі деңгейге өтіңіз."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    currentWordIndex = 0;
                  });
                  _loadWordsFromFirebase();
                },
                child: const Text("Келесі деңгей"),
              )
            ],
          ),
        ],
      ),
    );
  }


  void _tryMatch() {
    if (selectedLeft != null && selectedRight != null) {
      final match = matchBatch.firstWhere(
            (pair) => pair['foreign'] == selectedLeft && pair['kazakh'] == selectedRight,
        orElse: () => {},
      );

      final correct = match.isNotEmpty;
      if (correct) {
        setState(() {
          matchedWords.add(selectedLeft!);
          selectedLeft = null;
          selectedRight = null;
        });
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("❌ Қате"),
            content: const Text("Бұл сөзге сәйкес емес."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    selectedLeft = null;
                    selectedRight = null;
                  });
                },
                child: const Text("OK"),
              )
            ],
          ),
        );
      }

      if (matchedWords.length >= matchBatch.length) {
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            currentWordIndex += 4;
          });
          _loadNextMatchBatch();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Сөзді таңда")),
      body: wordList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Builder(
        builder: (context) {
          if (learningMode == 'quiz') {
            return _buildMatchingView();
          } else if (learningMode == 'write') {
            return _buildWritingView();
          } else {
            return _buildQuizView();
          }
        },
      ),
    );
  }


  Widget _buildWritingView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 50),
          Center(
            child: IconButton(
              onPressed: () => _speakWordForWriteMode(),
              icon: const Icon(Icons.volume_up, size: 48, color: Colors.teal),
            ),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _answerController,
            decoration: const InputDecoration(
              labelText: 'Сөзді жазыңыз',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _checkTypedAnswer,
            child: const Text('Тексеру'),
          ),
        ],
      ),
    );
  }

  Future<void> _speakWordForWriteMode() async {
    final ttsLanguageMap = {
      'en': 'en-US',
      'de': 'de-DE',
      'ru': 'ru-RU',
      'es': 'es-ES',
      'kk': 'kk-KZ',
    };

    final ttsLang = ttsLanguageMap[selectedLanguage] ?? 'en-US';
    await flutterTts.setLanguage(ttsLang);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(1.0);

    if (currentWordIndex < wordList.length) {
      final word = wordList[currentWordIndex]['foreign'] ?? '';
      if (word.isNotEmpty) {
        await flutterTts.speak(word);
      }
    }
  }

  void _checkTypedAnswer() {
    final typed = _answerController.text.trim().toLowerCase();
    final expected = currentWord.trim().toLowerCase();

    if (typed == expected) {
      incorrectTries = 0;
      _answerController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Дұрыс!")),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          currentWordIndex++;
        });
        _loadCurrentWord();
      });
    } else {
      incorrectTries++;

      if (incorrectTries >= 3) {
        final correct = currentWord;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("❌ Қате"),
            content: Text("Дұрыс жауап: $correct"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  incorrectTries = 0;
                  _answerController.clear();
                  setState(() {
                    currentWordIndex++;
                  });
                  _loadCurrentWord();
                },
                child: const Text("Келесі"),
              )
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Қате (${incorrectTries}/3). Қайта көріңіз.")),
        );
      }
    }
  }



  Widget _buildQuizView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.teal, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              currentWord,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          IconButton(
            onPressed: _speak,
            icon: const Icon(Icons.volume_up, size: 32, color: Colors.teal),
          ),
          const Spacer(),
          ...options.map((option) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.teal,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () => _checkAnswer(option),
              child: Text(option, style: const TextStyle(fontSize: 18)),
            ),
          )),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildMatchingView() {
    final leftWords = matchBatch.map((e) => e['foreign']!).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text("Сөздер мен аудармаларды сәйкестендір", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ListView(
                    children: leftWords.map((word) {
                      final isSelected = selectedLeft == word;
                      final isMatched = matchedWords.contains(word);
                      return GestureDetector(
                        onTap: isMatched
                            ? null
                            : () {
                          setState(() => selectedLeft = word);
                          _tryMatch();
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isMatched
                                ? Colors.green[300]
                                : (isSelected ? Colors.teal[100] : Colors.teal[50]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(word, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black),),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 1,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Expanded(
                  child: ListView(
                    children: rightColumn.map((word) {
                      final matchedEntry = matchBatch.firstWhere(
                            (e) => e['kazakh'] == word,
                        orElse: () => {},
                      );
                      final isMatched = matchedWords.contains(matchedEntry['foreign']);
                      final isSelected = selectedRight == word;
                      return GestureDetector(
                        onTap: isMatched
                            ? null
                            : () {
                          setState(() => selectedRight = word);
                          _tryMatch();
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isMatched
                                ? Colors.green[300]
                                : (isSelected ? Colors.teal[100] : Colors.teal[50]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(word, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
