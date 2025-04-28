import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'user_storage.dart';



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
            const Text("Koptildilik", style: TextStyle(fontSize: 28, color: Colors.green)),
            const SizedBox(height: 10),
            Text( "Қош келдіңіз!" ,style: const TextStyle(fontSize: 20, color: Colors.blue),
            ),
            const Spacer(flex: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => Navigator.pushReplacementNamed(context, '/main'),
                child: const Text("Бастау",
                    style: TextStyle(color: Colors.white)),
              ),
              ),
            const Spacer(flex: 3),
          ],
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
      const FormScreen(),
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

  Future<void> _saveSelectedLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', code);
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
            return ElevatedButton(
              onPressed: () {
                _saveSelectedLanguage(lang["code"]!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${lang["name"]} тілі таңдалды")),
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
  final List<String> professions = const [
    "Программист", "Дизайнер", "Мұғалім", "Дәрігер", "Инженер", "Аудармашы",
    "Журналист", "Маркетолог", "Фотограф", "Құрылысшы", "Техник", "Космонавт"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Мамандық таңдау")),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: professions.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Қызығушылығыңызға сай мамандықты таңдаңыз:",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            );
          }
          final profession = professions[index - 1];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(profession),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          );
        },
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
  String selectedLanguage = "en";
  String word = "";
  List<String> options = [];
  String correctAnswer = "";

  @override
  void initState() {
    super.initState();
    _loadLanguageAndWord();
  }

  Future<void> _loadLanguageAndWord() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('selected_language') ?? 'kk';
    setState(() {
      selectedLanguage = langCode;
    });

    if (langCode == "en") {
      word = "Apple";
      options = ["Алма", "Банан", "Апельсин", "алмұрт"];
      correctAnswer = "Алма";
    } else if (langCode == "ru") {
      word = "Яблоко";
      options = ["Алма", "Банан", "Апельсин", "алмұрт"];
      correctAnswer = "Алма";
    } else if (langCode == "de") {
      word = "Apfel";
      options = ["Алма", "Банан", "Апельсин", "алмұрт"];
      correctAnswer = "Алма";
    } else if (langCode == "es") {
      word = "Manzana";
      options = ["Алма", "Банан", "Апельсин", "алмұрт"];
      correctAnswer = "Алма";
    }
    setState(() {});
  }

  Future<void> _speak() async {
    await flutterTts.setLanguage(selectedLanguage == "en" ? "en-US" : "ru-RU");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(word);
  }

  void _checkAnswer(String answer) {
    final isCorrect = answer == correctAnswer;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isCorrect ? "Дұрыс!" : "Қате"),
        content: Text(isCorrect
            ? "Жарайсың! Бұл дұрыс жауап."
            : "Дұрыс жауап: $correctAnswer"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Сөзді таңда")),
      body: Padding(
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
                word,
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

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('login', _loginController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('password', _passwordController.text);

    final newUser = User(
      id: await UserStorage.getNextUserId(),
      name: _loginController.text,
      email: _emailController.text,
    );
    await UserStorage.addUser(newUser);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Сақтау сәтті өтті"),
        content: const Text("Деректер сәтті сақталды."),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Профиль")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _loginController, decoration: const InputDecoration(labelText: 'Логин'),
                  validator: (value) => value == null || value.isEmpty ? 'Логинді енгізіңіз' : null),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Электрондық пошта'),
                  validator: (value) => value == null || value.isEmpty ? 'Email енгізіңіз' : null),
              TextFormField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Құпия сөз'),
                  obscureText: true,
                  validator: (value) => value == null || value.isEmpty ? 'Құпия сөзді енгізіңіз' : null),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) _saveData();
                },
                child: const Text('Сақтау'),
              ),
            ],
          ),
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SwitchListTile(
                title: const Text('Қараңғы тема'),
                value: _darkMode,
                onChanged: (value) {
                  setState(() => _darkMode = value);
                  widget.changeTheme(value ? ThemeMode.dark : ThemeMode.light);
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedLang,
                items: const [
                  DropdownMenuItem(value: 'kk', child: Text('Қазақша')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ru', child: Text('Русский')),
                ],
                onChanged: (value) {
                  setState(() => _selectedLang = value!);
                  widget.changeLocale(Locale(value!));
                },
                decoration: const InputDecoration(
                  labelText: 'Тілді таңдаңыз',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/about'),
                  child: Text('About app'),
              ),
            ],
          ),
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
