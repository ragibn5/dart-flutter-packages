import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_provider_android/media_provider_android.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _mediaProviderAndroidPlugin = MediaProviderAndroid();

  List<AndroidMediaItem>? _media;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    // Media permissions aren't requested here; grant them from the app's
    // system settings, otherwise the list is empty.
    try {
      final media = await _mediaProviderAndroidPlugin.getMedia(
        AndroidMediaQuery(
          types: {AndroidMediaType.photo, AndroidMediaType.video},
          volumes: null,
        ),
      );
      if (!mounted) return;
      setState(() => _media = media);
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

    final media = _media;
    if (media == null) return const Center(child: CircularProgressIndicator());
    if (media.isEmpty) return const Center(child: Text('No media found'));

    return ListView.builder(
      itemCount: media.length,
      itemBuilder: (context, index) {
        final item = media[index];
        return ListTile(
          leading: Icon(switch (item.type) {
            AndroidMediaType.photo => Icons.photo,
            AndroidMediaType.video => Icons.videocam,
          }),
          title: Text(item.name ?? item.id),
          subtitle: Text(item.mimeType ?? 'Unknown type'),
        );
      },
    );
  }
}
