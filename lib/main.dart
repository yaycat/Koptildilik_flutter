import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'user.dart';
import 'user_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserStorage.initFile();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Local Users Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const FirstScreen(),
    );
  }
}

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
          children: [
            const Spacer(flex: 3),
            const Text("Koptildilik", style: TextStyle(fontSize: 28, color: Colors.green)),
            const SizedBox(height: 10),
            Text(
              savedLogin != null
                  ? "Қош келдіңіз, $savedLogin!"
                  : "Тілдік қабілеттеріңізді кеңейтіңіз",
              style: const TextStyle(fontSize: 20, color: Colors.blue),
            ),
            const Spacer(flex: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScreen(currentIndex: 0)),
                    );
                  },
                  child: const Text("Бастау", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final int currentIndex;
  const MainScreen({super.key, required this.currentIndex});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  final List<Widget> _screens = [
    const SecondScreen(),
    const ThirdScreen(),
    const FormScreen(),
    const UserListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.language), label: 'Тілдер'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Мамандық'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Пайдаланушылар'),
        ],
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});
  final List<Map<String, String>> languages = const [
    {"name": "Ағылшын тілі", "flag": "🇬🇧"},
    {"name": "Испан тілі", "flag": "🇪🇸"},
    {"name": "Неміс тілі", "flag": "🇩🇪"},
    {"name": "Орыс тілі", "flag": "🇷🇺"},
    {"name": "Француз тілі", "flag": "🇫🇷"},
    {"name": "Итальян тілі", "flag": "🇮🇹"},
  ];

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
              onPressed: () {},
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text("Қызығушылығыңызға сай мамандықты таңдаңыз:",
                style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              itemCount: professions.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(professions[index]),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

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

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Пайдаланушылар")),
      body: FutureBuilder<List<User>>(
        future: UserStorage.readUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Қате: ${snapshot.error}"));
          final users = snapshot.data ?? [];
          return users.isEmpty
              ? const Center(child: Text("Пайдаланушылар табылмады"))
              : ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(users[index].name),
              subtitle: Text(users[index].email),
            ),
          );
        },
      ),
    );
  }
}
