import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petmatch/core/config/supabase_config.dart';
import 'package:petmatch/core/router/app_router.dart';
import 'package:petmatch/theme/theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig().initialize();
  
  // Configure image cache for low-RAM devices
  imageCache.maximumSize = 100; // max 100 images in memory
  imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50MB max
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final router = ref.read(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SoilTrack',
      theme: lightTheme,
      routerConfig: router,
    );
  }
}
