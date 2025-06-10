import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/user_storage.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await UserStorage.initFile();
  runApp(const MyApp());
}
