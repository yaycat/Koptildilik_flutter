import 'package:flutter/material.dart';

import 'screens/common/first_screen.dart';
import 'screens/home/main_screen.dart';
import 'screens/home/choose_screen.dart';
import 'screens/common/second_screen.dart';
import 'screens/common/third_screen.dart';
import 'screens/pin/create_pin_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/login_with_pin_screen.dart';
import 'screens/words/word_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/progress/progress_screen.dart';
import 'screens/about/about_screen.dart';
import 'screens/search/search_screen.dart';




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
        '/search': (context) => const SearchScreen(),

      },
      debugShowCheckedModeBanner: false,
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
}