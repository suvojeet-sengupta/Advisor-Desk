import 'package:flutter/material.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart';

class AiCopilotAnalyzerScreen extends StatelessWidget {
  const AiCopilotAnalyzerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Copilot Analyzer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Analysis',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            // Placeholder for AI analysis UI
            Expanded(
              child: Center(
                child: Text(
                  'AI analysis content will be displayed here.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.aiCopilotRoute);
              },
              child: const Text('Go to AI Copilot Chat'),
            ),
          ],
        ),
      ),
    );
  }
}