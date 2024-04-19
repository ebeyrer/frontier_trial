import 'package:flutter/widgets.dart';
import 'package:frontier_trial/auth.dart';
import 'package:frontier_trial/homepage.dart';
import 'package:frontier_trial/login_register_page.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder(
          stream: Auth().authStateChanges,
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasData) {
              return const HomePage();
            } else {
              return const LoginPage();
            }
          }),
    );
  }
}
