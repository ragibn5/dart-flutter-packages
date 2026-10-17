import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:user_provider_android/user_provider_android.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _userProviderAndroidPlugin = UserProviderAndroid();

  UserIdentity? _identity;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadIdentity();
  }

  Future<void> _loadIdentity() async {
    try {
      final identity = await _userProviderAndroidPlugin.getIdentity();
      if (!mounted) return;
      setState(() => _identity = identity);
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() => _error = '${e.code}: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final error = _error;
    if (error != null) return Center(child: Text(error));

    final identity = _identity;
    if (identity == null) return const Center(child: CircularProgressIndicator());

    return ListView(
      children: [
        ListTile(title: const Text('uid'), trailing: Text('${identity.uid}')),
        ListTile(title: const Text('user id'), trailing: Text('${identity.userId}')),
        ListTile(title: const Text('app id'), trailing: Text('${identity.appId}')),
      ],
    );
  }
}
