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

  List<MediaItem>? _media;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  /// The volumes media is searched on: every volume the device reports, or the
  /// primary one alone when the device reports none.
  Future<Set<VolumeSpec>> _volumesToSearch() async {
    final volumes = await _mediaProviderAndroidPlugin.getVolumes();
    final specs = <VolumeSpec>{
      for (final volume in volumes)
        if (volume.identity.uuid != null)
          VolumeSpec.external(uuid: volume.identity.uuid!)
        else if (volume.identity.isPrimary)
          const VolumeSpec.primary(),
    };
    return specs.isEmpty ? {const VolumeSpec.primary()} : specs;
  }

  Future<void> _loadMedia() async {
    // Media permissions aren't requested here; grant them from the app's
    // system settings, otherwise the list is empty.
    try {
      final media = await _mediaProviderAndroidPlugin.getMedia(
        QuerySpec(
          types: {MediaType.photo, MediaType.video},
          volumes: await _volumesToSearch(),
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
            MediaType.photo => Icons.photo,
            MediaType.video => Icons.videocam,
          }),
          title: Text(item.name ?? item.id),
          subtitle: Text(item.mimeType ?? 'Unknown type'),
          trailing: item.volumeIdentity == null
              ? null
              : Text(item.volumeIdentity!.type.name),
        );
      },
    );
  }
}
