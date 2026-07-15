import 'package:alerty/alerty.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AlerterExampleApp());
}

class AlerterExampleApp extends StatelessWidget {
  const AlerterExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alerty Example',
      navigatorKey: _navigatorKey,
      home: const HomePage(),
    );
  }
}

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final alerty = RouterNavigatorAlerty(_navigatorKey);

    return Scaffold(
      appBar: AppBar(title: const Text('Alerty Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => alerty.showTextAlert(
            AlertData.error(
              title: 'Alert Title',
              message: 'This is the alert message body.',
            ),
            <AlertAction<Object?>>[
              CloseAction(title: 'Dismiss'),
              PromptAction(title: 'Confirm', onTap: () => print('Confirmed!')),
            ],
          ),
          child: const Text('Show Alert'),
        ),
      ),
    );
  }
}
