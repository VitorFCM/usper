import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/modules/home/screen/home_screen.dart';
import 'package:usper/modules/login/controller/login_controller.dart';
import 'package:usper/modules/login/screen/login_screen.dart';
import 'package:usper/modules/ride_creation/ride_creation_controller/ride_creation_controller.dart';
import 'package:usper/modules/passengers_selection/passengers_sel_screen.dart';
import 'package:usper/modules/ride_creation/screen/ride_creation_screen.dart';
import 'package:usper/modules/ride_creation/vehicle_configuration_controller/vehicle_configuration_controller.dart';
import 'package:usper/modules/waiting_room/screen/waiting_room_screen.dart';
import 'package:usper/services/google_auth_supabase_service.dart';
import 'package:usper/services/supabase_service.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['ANON_KEY']!,
  );

  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => LoginController(
                  googleAuth: GoogleAuthSupabaseService(),
                  repositoryService: SupabaseService())),
          BlocProvider(
              create: (context) =>
                  RideCreationController(repositoryService: SupabaseService())),
          BlocProvider(
              create: (context) => VehicleConfigurationController(
                  rideCreationController:
                      BlocProvider.of<RideCreationController>(context),
                  repositoryService: SupabaseService()))
        ],
        child: MaterialApp(
          title: 'Usper',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: yellow),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: '/login',
          routes: {
            '/login': (context) => LoginScreen(),
            '/home': (context) => HomeScreen(),
            '/ride_creation': (context) => RideCreationScreen(),
            /*'/ride_creation': (context) => BlocProvider(
                create: (_) => RideCreationController(),
                child: RideCreationScreen()),*/
            '/waiting_room': (context) => WaitingRoomScreen(),
            '/passengers_selection': (context) => PassengersSelScreen()
          },
        ));
  }
}
