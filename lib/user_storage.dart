import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'user.dart';

class UserStorage {
  static Future<String> _localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> _localFile() async {
    final path = await _localPath();
    return File('$path/users.json');
  }

  static Future<void> initFile() async {
    final file = await _localFile();
    if (!await file.exists()) {
      final data = await rootBundle.loadString('assets/users.json');
      await file.writeAsString(data);
    }
  }

  static Future<List<User>> readUsers() async {
    final file = await _localFile();
    final contents = await file.readAsString();
    final List<dynamic> jsonData = json.decode(contents);
    return jsonData.map((json) => User.fromJson(json)).toList();
  }

  static Future<void> addUser(User user) async {
    final users = await readUsers();
    final newList = [...users, user];
    final file = await _localFile();
    await file.writeAsString(json.encode(newList.map((u) => u.toJson()).toList()));
  }

  static Future<int> getNextUserId() async {
    final users = await readUsers();
    return users.isEmpty ? 1 : users.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1;
  }
}
