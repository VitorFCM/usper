import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usper/modules/home/screen/home_screen.dart';
import 'package:usper/modules/ride_creation/controller/ride_creation_controller.dart';
import 'package:usper/modules/ride_creation/screen/ride_creation_screen.dart';
import 'package:usper/modules/waiting_room/screen/waiting_room_screen.dart';

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
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomeScreen(),
        '/ride_creation': (context) => BlocProvider(
            create: (_) => RideCreationController(),
            child: const RideCreationScreen()),
        '/waiting_room': (context) => WaitingRoomScreen(),
      },
    );
  }
}
