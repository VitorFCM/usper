import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/modules/chat/controller/chat_controller.dart';
import 'package:usper/modules/home/controller/home_controller.dart';
import 'package:usper/modules/home/screen/home_screen.dart';
import 'package:usper/modules/login/controller/login_controller.dart';
import 'package:usper/modules/login/screen/login_screen.dart';
import 'package:usper/modules/passengers_selection/controller/passengers_selection_controller.dart';
import 'package:usper/modules/ride_creation/ride_creation_controller/ride_creation_controller.dart';
import 'package:usper/modules/passengers_selection/screen/passengers_sel_screen.dart';
import 'package:usper/modules/ride_creation/screen/ride_creation_screen.dart';
import 'package:usper/modules/ride_creation/vehicle_configuration_controller/vehicle_configuration_controller.dart';
import 'package:usper/modules/ride_dashboard/controller/ride_dashboard_controller.dart';
import 'package:usper/modules/ride_dashboard/screen/ride_dashboard_screen.dart';
import 'package:usper/modules/waiting_room/controller/waiting_room_controller.dart';
import 'package:usper/modules/waiting_room/screen/waiting_room_screen.dart';
import 'package:usper/services/authentication/google_auth_supabase_service.dart';
import 'package:usper/services/cryptography/cryptography_interface.dart';
import 'package:usper/services/cryptography/encrypt_service.dart';
import 'package:usper/services/data_repository/repository_interface.dart';
import 'package:usper/services/data_repository/supabase_service.dart';
import 'package:usper/services/map_service/map_interface.dart';
import 'package:usper/services/map_service/map_service.dart';

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
    final RepositoryInterface repositoryService = SupabaseService();
    final MapInterface mapService = MapService();
    final CryptographyInterface cryptographyService = EncryptService();

    return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => LoginController(
                  googleAuth: GoogleAuthSupabaseService(),
                  repositoryService: repositoryService)),
          BlocProvider(
              create: (context) => RideCreationController(
                  repositoryService: repositoryService,
                  mapService: mapService)),
          BlocProvider(
              create: (context) => VehicleConfigurationController(
                  rideCreationController:
                      BlocProvider.of<RideCreationController>(context),
                  repositoryService: repositoryService)),
          BlocProvider(
              create: (context) => HomeController(
                  repositoryService: repositoryService,
                  user: BlocProvider.of<LoginController>(context).user!)),
          BlocProvider(
              create: (context) => RideDashboardController(
                  repositoryService: repositoryService)),
          BlocProvider(
              create: (context) => WaitingRoomController(
                  cryptographyService: cryptographyService,
                  rideDashboardController:
                      BlocProvider.of<RideDashboardController>(context),
                  repositoryService: repositoryService,
                  user: BlocProvider.of<LoginController>(context).user!,
                  homeController: BlocProvider.of<HomeController>(context))),
          BlocProvider(
              create: (context) => PassengersSelectionController(
                    repositoryService: repositoryService,
                  )),
          BlocProvider(
              create: (context) => ChatController(
                  repositoryService: repositoryService,
                  cryptographyService: cryptographyService,
                  user: BlocProvider.of<LoginController>(context).user!)),
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
            '/passengers_selection': (context) => PassengersSelScreen(),
            '/ride_dashboard': (context) => RideDashboardScreen(),
          },
        ));
  }
}
