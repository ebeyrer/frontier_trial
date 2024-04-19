import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontier_trial/widget_tree.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Is This a Cow?',
        theme: ThemeData(
          primaryColor: Colors.white, // Set the primary color to white
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  const Color.fromARGB(255, 12, 14, 49)),
            ),
          ),
          useMaterial3: true,
        ),
        home: const WidgetTree());
  }
}
