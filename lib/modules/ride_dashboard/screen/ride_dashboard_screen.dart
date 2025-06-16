import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/modules/chat/controller/chat_controller.dart';
import 'package:usper/modules/chat/screen/chat_screen.dart';
import 'package:usper/modules/home/controller/home_controller.dart';
import 'package:usper/modules/ride_dashboard/controller/ride_dashboard_controller.dart';
import 'package:usper/widgets/base_screen.dart';
import 'package:usper/widgets/changing_text_widget.dart';
import 'package:usper/widgets/expandable_map_widget.dart';
import 'package:usper/widgets/loading_widget.dart';
import 'package:usper/widgets/page_title.dart';
import 'package:usper/widgets/ride_info_card.dart';
import 'package:usper/widgets/user_image.dart';

class RideDashboardScreen extends StatefulWidget {
  @override
  State<RideDashboardScreen> createState() => _RideDashboardScreenState();
}

class _RideDashboardScreenState extends State<RideDashboardScreen> {
  late RideDashboardController _rideDashboardController;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _rideDashboardController =
          BlocProvider.of<RideDashboardController>(context);
      BlocProvider.of<ChatController>(context)
          .add(SetRideForChat(ride: _rideDashboardController.ride));
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    double titleOcupation = MediaQuery.of(context).size.width * 0.68;

    return BaseScreen(
        child: BlocConsumer<RideDashboardController, RideDashboardState>(
      listener: (context, state) {
        if (state is RideFinishedState) {
          BlocProvider.of<HomeController>(context)
              .add(DisassociateUserAndRide());
          Navigator.popUntil(context, ModalRoute.withName('/home'));
        }
      },
      builder: (context, state) {
        if (state is LoadingState) {
          return LoadingWidget(
            infoSection: ChangingTextWidget(texts: const [
              "Chegando ao destino",
              "Desligando o veículo",
              "Dando tchau",
              "Finalizando carona"
            ]),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: titleOcupation),
              child: PageTitle(title: "Carona iniciada"),
            ),
            const SizedBox(height: 20),
            RideInfoCard(rideData: _rideDashboardController.ride),
            const SizedBox(height: 20),
            ExpandableMapWidget(
              origin: _rideDashboardController.ride.originCoord,
              destination: _rideDashboardController.ride.destCoord,
              routePoints: _rideDashboardController.ride.route ?? [],
            ),
            const SizedBox(height: 20),
            chatSection(context),
            const SizedBox(height: 20),
            buttonSection(context),
          ],
        );
      },
    ));
  }

  Widget chatSection(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => ChatScreen(),
        );
      },
      child: Container(
        height: 65,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          color: lighterBlue,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: [
            const Text(
              "Chat",
              style: TextStyle(color: white, fontSize: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  color: yellow,
                ),
                padding: const EdgeInsets.all(5),
                child: BlocBuilder<ChatController, ChatState>(
                  buildWhen: (previous, current) {
                    return current is NewMessageState;
                  },
                  builder: (context, state) {
                    if (state is NewMessageState) {
                      return Row(
                        children: [
                          UserImage(
                            user: state.user,
                            radius: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              state.chatMessage.messageContent,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      );
                    } else {
                      return Container(
                        height: 40,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Sem mensagens ainda"),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buttonSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Align(
        alignment: Alignment.center,
        child: _rideDashboardController.isDriver
            ? button(
                "Finalizar",
                white,
                MediaQuery.of(context).size.width * 0.8,
                () => _rideDashboardController.add(FinishRide()),
                Colors.black)
            : button(
                "Desistir",
                white,
                MediaQuery.of(context).size.width * 0.8,
                () => _rideDashboardController.add(PassengerGiveUp()),
                Colors.black),
      ),
    );
  }

  TextButton button(String title, Color textColor, double minWidth,
      VoidCallback onPressedFunction, Color backgroundColor) {
    return TextButton(
      onPressed: onPressedFunction,
      style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          backgroundColor: backgroundColor,
          minimumSize: Size(minWidth, 30)),
      child: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w400),
      ),
    );
  }
}
