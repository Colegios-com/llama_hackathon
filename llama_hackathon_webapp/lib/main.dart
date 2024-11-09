import 'package:flutter/material.dart';
import 'dart:html' as html;

// Packages
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

// Models
import 'app_provider.dart';

// Routes
import 'splashscreen.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppProvider>(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'Llama Hackathon WebApp',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.grey[50],
        ),
        home: SplashScreen(
          hostname: html.window.location.hostname as String,
          pathname: html.window.location.pathname as String,
        ),
      ),
    );
  }
}
