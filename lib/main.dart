import 'dart:math';
import 'dart:async';
import 'dart:convert'; // для utf8 и base64
import 'user_storage.dart';
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
        '/create_pin': (context) => const CreatePinScreen(),
        '/third': (context) => const ThirdScreen(),
        '/word': (context) => const WordScreen(),
        '/progress': (context) => const ProgressScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/about': (context) => const AboutContent(),
        '/auth': (context) => const AuthScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const FormScreen(),
        '/login_with_pin': (context) => const LoginWithPinScreen(),
        '/choose': (context) => ChooseScreen(
          currentIndex: 0,
          changeTheme: _changeTheme,
          changeLocale: _changeLocale,
        ),
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

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late StreamSubscription<ConnectivityResult> _subscription;
  bool _isOffline = false;
  bool _buttonsDisabled = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _snackBarController;

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      final hasConnection = result != ConnectivityResult.none;

      if (!hasConnection && !_isOffline) {
        setState(() => _isOffline = true);
        _showOfflineSnackBar();
      } else if (hasConnection && _isOffline) {
        setState(() => _isOffline = false);
        _removeSnackBar();
      }
    });
  }

  void _showOfflineSnackBar() {
    _snackBarController = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Интернетке қосылу жоқ"),
        duration: const Duration(days: 1), // Долго держим
        action: SnackBarAction(
          label: 'Перезапуск',
          onPressed: () {
            // перезапуск экрана
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const AuthScreen(),
                transitionDuration: Duration.zero,
              ),
            );
          },
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeSnackBar() {
    _snackBarController?.close();
    _snackBarController = null;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _handleLoginOrRegister() {
    setState(() {
      isGuest = false; // Сбросить значение isGuest
      _buttonsDisabled = false; // Блокируем кнопки
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: _buttonsDisabled ? null : () {
                _handleLoginOrRegister();
                Navigator.pushNamed(context, '/register');
              },
              child: const Text("Тіркелу"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: _buttonsDisabled ? null : () {
                _handleLoginOrRegister();
                Navigator.pushNamed(context, '/login');
              },
              child: const Text("Кіру"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: _buttonsDisabled ? null : () {
                _handleLoginOrRegister();
                Navigator.pushNamed(context, '/login_with_pin');
              },
              child: const Text("Кіру пин-кодпен"),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.teal),
              ),
              onPressed: () {
                isGuest = true;
                Navigator.pushNamed(context, '/choose');
              },
              child: const Text("Гость ретінде кіру", style: TextStyle(color: Colors.teal)),
            ),
          ],
        ),
      ),
    );
  }
}





//LOGIN PAGE---------------------------------------------------------------------------------------------

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

//PINCODE LOGIN PAGE---------------------------------------------------------------------------
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


//ALL CHOOSE SCREEN --------------------------------------------------------------------------
class ChooseScreen extends StatefulWidget {
  final int currentIndex;
  final Function(ThemeMode) changeTheme;
  final Function(Locale) changeLocale;

  const ChooseScreen({
    super.key,
    required this.currentIndex,
    required this.changeTheme,
    required this.changeLocale,
  });

  @override
  State<ChooseScreen> createState() => _ChooseScreenState();
}

class _ChooseScreenState extends State<ChooseScreen> {
  late int _selectedIndex;
  final List<Widget> _screens = [];
  late StreamSubscription<ConnectivityResult> _subscription;
  bool _isOffline = false;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _snackBarController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
    _screens.addAll([
      const SecondScreen(),
      const ThirdScreen(),
    ]);
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      final hasConnection = result != ConnectivityResult.none;
      if (!hasConnection && !_isOffline) {
        setState(() => _isOffline = true);
        _showOfflineSnackBar();
      } else if (hasConnection && _isOffline) {
        setState(() => _isOffline = false);
        _removeSnackBar();
      }
    });
  }

  void _showOfflineSnackBar() {
    _snackBarController = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Интернетке қосылу жоқ"),
        duration: const Duration(days: 1),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeSnackBar() {
    _snackBarController?.close();
    _snackBarController = null;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) => _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.language), label: 'Тілдер'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Мамандық'),
        ],
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
  int _previousIndex = 0;
  final List<Widget> _screens = [];
  late StreamSubscription<ConnectivityResult> _subscription;
  bool _isOffline = false;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _snackBarController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
    _previousIndex = _selectedIndex;
    _screens.addAll([
      const ProgressScreen(),
      const WordScreen(),
      const ProfileScreen(),
      _SettingsContent(
        changeLocale: widget.changeLocale,
        changeTheme: widget.changeTheme,
      )
    ]);
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      final hasConnection = result != ConnectivityResult.none;
      if (!hasConnection && !_isOffline) {
        setState(() => _isOffline = true);
        _showOfflineSnackBar();
      } else if (hasConnection && _isOffline) {
        setState(() => _isOffline = false);
        _removeSnackBar();
      }
    });
  }

  void _showOfflineSnackBar() {
    _snackBarController = ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Интернетке қосылу жоқ"),
        duration: Duration(days: 1),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeSnackBar() {
    _snackBarController?.close();
    _snackBarController = null;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isForward = _selectedIndex >= _previousIndex;

    return Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation, secondaryAnimation) {
          final beginOffset = isForward ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);
          return SlideTransition(
            position: animation.drive(
              Tween<Offset>(begin: beginOffset, end: Offset.zero).chain(CurveTween(curve: Curves.ease)),
            ),
            child: child,
          );
        },
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Прогресс'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Сөздер'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Баптау'),
        ],
      ),
    );
  }
}



//PROGRESS PAGE--------------------------------------------------------------------------
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int currentLevel = 1;
  bool loading = true;
  final int totalLevels = 6;

  @override
  void initState() {
    super.initState();
    _loadUserLevel();
  }

  Future<void> _loadUserLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString('login');
    final dbRef = FirebaseDatabase.instance.ref().child("Accounts/$login/level");

    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      setState(() {
        currentLevel = snapshot.value as int;
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  Widget _buildChessLevelStep(int level) {
    final isReached = level <= currentLevel;
    final alignment = level.isOdd ? Alignment.centerLeft : Alignment.centerRight;

    return Align(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
        level.isOdd ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 24),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isReached ? Colors.teal : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: Text(
              'Деңгей $level',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadLine() {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            painter: RoadPainter(levelCount: totalLevels),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Прогресс")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          _buildRoadLine(),
          ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 40),
            itemCount: totalLevels,
            itemBuilder: (context, index) {
              final level = index + 1;
              return _buildChessLevelStep(level);
            },
          ),
        ],
      ),
    );
  }
}

class RoadPainter extends CustomPainter {
  final int levelCount;

  RoadPainter({required this.levelCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.teal.withOpacity(0.3)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final double verticalSpacing = size.height / (levelCount + 1);
    final path = Path();

    for (int i = 0; i < levelCount - 1; i++) {
      final y1 = verticalSpacing * (i + 1);
      final y2 = verticalSpacing * (i + 2);
      final x1 = i.isEven ? 40.0 : size.width - 40.0;
      final x2 = (i + 1).isEven ? 40.0 : size.width - 40.0;

      path.moveTo(x1, y1);
      path.lineTo(x2, y2);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
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
                Navigator.pushNamed(context, '/main');
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




//REGISTER PAGE---------------------------------------------------------------------------
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


//CREATING PINCODE PAGE--------------------------------------------------------------------------------------------
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



//PROFILE SCREEN--------------------------------------------------------------------------------------------------------------
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
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutContent()),
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
