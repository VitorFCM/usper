import 'package:flutter/material.dart';
import 'package:usper/modules/home/screen/home_screen.dart';
import 'package:usper/modules/ride_creation/screen/ride_creation_screen.dart';

void main() {
  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomeScreen(),
        '/ride_creation': (context) => const RideCreationScreen(),
      },
    );
  }
}
