import 'package:flutter/material.dart';

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
