import 'dart:convert';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'user_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert'; // для utf8 и base64
import 'package:crypto/crypto.dart'; // для sha256

bool isGuest = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await UserStorage.initFile();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget  {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('kk');

  void _changeTheme(ThemeMode mode) => setState(() => _themeMode = mode);
  void _changeLocale(Locale locale) => setState(() => _locale = locale);



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Koptildilik',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),

      themeMode: _themeMode,
      locale: _locale,


      routes: {
        '/': (context) => const FirstScreen(),
        '/main': (context) => MainScreen(
          currentIndex: 0,
          changeTheme: _changeTheme,
          changeLocale: _changeLocale,
        ),
        '/second': (context) => const SecondScreen(),
        '/third': (context) => const ThirdScreen(),
        '/word': (context) => const WordScreen(),
        '/form': (context) => const FormScreen(),
        '/about': (context) => const AboutContent(),
        '/auth': (context) => const AuthScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const FormScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
  ThemeData _buildLightTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        color: Colors.teal,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal[800]!,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        color: Colors.teal[800],
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal[800],
          foregroundColor: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.teal[900]!.withOpacity(0.5),
      ),
    );
  }
}




//FIRST PAGE-----------------------------------------------------------------------------------------------------------------
class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});
  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  String? savedLogin;

  @override
  void initState() {
    super.initState();
    _loadSavedLogin();
  }

  Future<void> _loadSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedLogin = prefs.getString('login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            const Text("Koptildilik",
                style: TextStyle(fontSize: 28, color: Colors.green)),
            const SizedBox(height: 10),
            const Text("Қош келдіңіз!",
                style: TextStyle(fontSize: 20, color: Colors.blue)),
            const Spacer(flex: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/auth'),
                child: const Text("Бастау", style: TextStyle(color: Colors.white)),
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}

//AUTH SCREEN------------------------------------------------------------------------------------------------------------

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Кіру")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Қалай жалғастырғыңыз келеді?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => Navigator.pushNamed(context, '/form'),
              child: const Text("Тіркелу"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text("Кіру"),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.teal),
              ),
              onPressed: () {
                isGuest = true;
                Navigator.pushNamed(context, '/main');
              },
              child: const Text("Гость ретінде кіру",
                  style: TextStyle(color: Colors.teal)),
            ),
          ],
        ),
      ),
    );
  }
}




//LOGIN SCREEN---------------------------------------------------------------------------------------------

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String errorMessage = '';
  bool _loading = false;

  String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return base64Encode(digest.bytes);
  }

  Future<void> _loginUser() async {
    setState(() {
      errorMessage = '';
      _loading = true;
    });

    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();


    final dbRef = FirebaseDatabase.instance.ref();
    final snapshot = await dbRef.child('Accounts/$login').get();

    if (!snapshot.exists) {
      setState(() {
        errorMessage = "Пайдаланушы табылмады.";
        _loading = false;
      });
      return;
    }

    final user = snapshot.value as Map;
    final salt = user['salt'];
    final storedHash = user['passwordHash'];

    if (salt == null || storedHash == null) {
      setState(() {
        errorMessage = "⚠️ Қолданушыда пароль немесе тұз (salt) табылмады.";
        _loading = false;
      });
      return;
    }
    final enteredHash = hashPassword(password, salt);

    if (enteredHash == storedHash) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('login', login);
      await prefs.setString('selected_language', user['language']);
      await prefs.setString('selected_topic', user['topic']);
      await prefs.setInt('user_level', user['level'] ?? 1);

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




//MAIN SCREEN --------------------------------------------------------------------------
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
  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
    _screens.addAll([
      const SecondScreen(),
      const ThirdScreen(),
      const WordScreen(),
      const ProfileScreen(),
      _SettingsContent(
        changeLocale: widget.changeLocale,
        changeTheme: widget.changeTheme,
      )
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) => _screens[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.language), label: 'Тілдер'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Мамандық'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Сөздер'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Баптау'),
        ],
      ),
    );
  }
}






// LANGUAGE CHOOSE PAGE-------------------------------------------------------------------
class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});
  final List<Map<String, String>> languages = const [
    {"name": "Ағылшын тілі", "flag": "🇬🇧", "code": "en"},
    {"name": "Орыс тілі", "flag": "🇷🇺", "code": "ru"},
    {"name": "Неміс тілі", "flag": "🇩🇪", "code": "de"},
    {"name": "Испан тілі", "flag": "🇪🇸", "code": "es"},
  ];

  Future<void> _saveSelectedLanguage(String nameWithFlag, String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', code);
    final login = prefs.getString('login');

    if (login != null) {
      final dbRef = FirebaseDatabase.instance.ref();
      await dbRef.child('Accounts/$login/language').set(nameWithFlag);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Тілді таңдау"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: languages.map((lang) {
            final displayName = "${lang["flag"]!} ${lang["name"]!}";
            return ElevatedButton(
              onPressed: () async {
                await _saveSelectedLanguage(displayName, lang["code"]!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${lang["name"]} таңдалды")),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(lang["flag"]!, style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 10),
                  Text(lang["name"]!, textAlign: TextAlign.center),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}




//TOPIC CHOOSE ------------------------------------------------------------------------------
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
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}





// WORD SCREEN PAGE --------------------------------------------------------------------

class WordScreen extends StatefulWidget {
  const WordScreen({super.key});

  @override
  State<WordScreen> createState() => _WordScreenState();
}

class _WordScreenState extends State<WordScreen> {
  final FlutterTts flutterTts = FlutterTts();
  String selectedLanguage = 'en';
  List<Map<String, dynamic>> wordList = [];
  int currentWordIndex = 0;
  String currentWord = '';
  String correctAnswer = '';
  List<String> options = [];

  @override
  void initState() {
    super.initState();
    _loadWordsFromFirebase();
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
        'en': 'english',
        'de': 'german',
        'ru': 'russian',
        'es': 'spanish',
        'kk': 'kazakh',
      };
      final translationKey = langFieldMap[selectedLanguage] ?? 'english';

      wordList = data.entries.map((e) {
        final translations = Map<String, dynamic>.from(e.value);
        return {
          'foreign': translations[translationKey] ?? '',
          'kazakh': translations['kazakh'] ?? '',
        };
      }).toList();

      _loadCurrentWord();
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

  List<String> _generateOptions(String correct) {
    final fakeAnswers = ['жауап 1', 'жауап 2', 'жауап 3', correct];
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
    await flutterTts.speak(currentWord);
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
    await dbRef.child('users/$login/level').set(nextLevel);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Сөзді таңда")),
      body: currentWord.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
      ),
    );
  }
}




//LOGIN AND REGISTER PAGE---------------------------------------------------------------------------
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

  String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return base64Encode(digest.bytes);
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
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('login', login);
    await prefs.setString('selected_language', defaultLang);
    await prefs.setString('selected_topic', defaultTopic);
    await prefs.setInt('user_level', defaultLevel);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/main');
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





//PROFILE SCREEN--------------------------------------------------------------------------------------------------------------


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String login = '';
  String language = '';
  String topic = '';
  int level = 1;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      login = prefs.getString('login') ?? 'Қонақ';
      language = prefs.getString('selected_language') ?? 'Қазақ тілі';
      topic = prefs.getString('selected_topic') ?? 'Байланыс';
      level = prefs.getInt('user_level') ?? 1;
    });
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
            ListTile(
              leading: const Icon(Icons.person),
              title: Text("Логин: $login"),
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
          ],
        ),
      ),
    );
  }
}


//SETTINGS APP PAGE-----------------------------------------------------------------------------------------
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
        appBar: AppBar(
          title: const Text('Баптаулар'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.settings), text: 'Баптаулар'),
              Tab(icon: Icon(Icons.info), text: 'Қолданба туралы'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SettingsContent(
              changeTheme: changeTheme,
              changeLocale: changeLocale,
            ),
            const AboutContent(),
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


  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("🔐 Құпиялық саясаты"),
        content: const Text(
          "Бұл қолданба тек оқу мақсатында жасалған. Жеке мәліметтер Firebase жүйесінде қауіпсіз сақталады.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Жабу"))
        ],
      ),
    );
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
    return SingleChildScrollView(
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
            ],
            onChanged: (val) async {
              if (val != null) {
                setState(() => _learningMode = val);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('learning_mode', val);
              }
            },
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutContent()),
            ),
            icon: const Icon(Icons.privacy_tip),
            label: const Text("Құпиялық саясаты"),
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
    );
  }
}

//ABOUT APP PAGE-----------------------------------------------------------------------------
class AboutContent extends StatelessWidget {
  const AboutContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('about_title'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'about_content',
            //   style: theme.textTheme.bodyLarge,
            // ),
            const SizedBox(height: 20),
            _buildSectionCard(
              context,
              title: 'App',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text("🌱 Koptildilik — бұл көптілді оқуға арналған қосымша.\n",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text("📱 Жобаның мақсаты — қолданушыларға әртүрлі тілдерді меңгеруге көмектесу.", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSectionCard(
              context,
              title: 'developers',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("👨‍💻 Команда:\n", style: TextStyle(fontSize: 16)),
                  Text("Әзірлеуші: Batyrkhan Ya.", style: TextStyle(fontSize: 16)),
                  Text("Дизайнер: Dariga M.", style: TextStyle(fontSize: 16)),
                  Text("Контент авторы: Kamilla M.", style: TextStyle(fontSize: 16)),
                  Text("Firebase console әзірлеуші: Alimzhan G.", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              context,
              title: 'contact',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Email: support@koptildilik.kz",
                      style: theme.textTheme.bodyMedium),
                  Text("Телефон: +7 777 123 45 67",
                      style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context,
      {required String title, required Widget content}) {
    width: double.infinity;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }
}
