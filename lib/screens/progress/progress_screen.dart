import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
