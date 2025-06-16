import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:usper/constants/colors_constants.dart';
import 'package:usper/core/classes/class_chat_message.dart';
import 'package:usper/modules/chat/controller/chat_controller.dart';
import 'package:usper/widgets/user_image.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final textController = TextEditingController();
  final _scrollController = ScrollController();
  final ValueNotifier<List<ChatMessage>> messages = ValueNotifier([]);
  late ChatController _chatController;

  @override
  void dispose() {
    textController.dispose();
    _scrollController.dispose();
    messages.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _chatController = BlocProvider.of<ChatController>(context, listen: false);
    messages.value = List.of(_chatController.messages);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Scaffold(
          backgroundColor: blue,
          resizeToAvoidBottomInset: true,
          body: BlocListener<ChatController, ChatState>(
            listener: (context, state) {
              if (state is NewMessageState) {
                messages.value = [...messages.value, state.chatMessage];

                _scrollToEnd();
              }
            },
            child: CustomScrollView(
              controller: _scrollController,
              shrinkWrap: true,
              slivers: [
                ValueListenableBuilder<List<ChatMessage>>(
                  valueListenable: messages,
                  builder: (context, messageList, _) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == 0 ||
                              messageList[index - 1].userId !=
                                  messageList[index].userId) {
                            return chatRow(messageList[index], true);
                          }
                          return chatRow(messageList[index]);
                        },
                        childCount: messageList.length,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: inputField(context),
        ),
      ),
    );
  }

  Widget chatRow(ChatMessage chatMessage, [bool firstOfBlock = false]) {
    final bool isOwnMessage = chatMessage.userId == _chatController.user.email;

    return Padding(
      padding: EdgeInsets.only(
          top: firstOfBlock ? 10 : 0, bottom: 10, left: 10, right: 10),
      child: Align(
        alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: IntrinsicWidth(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              firstOfBlock && !isOwnMessage
                  ? Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: UserImage(
                        user: _chatController.users[chatMessage.userId]!,
                        radius: 15,
                      ),
                    )
                  : SizedBox(width: 40),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                decoration: BoxDecoration(
                    color: yellow,
                    borderRadius: BorderRadius.only(
                        topLeft: !isOwnMessage && firstOfBlock
                            ? Radius.circular(5)
                            : Radius.circular(15),
                        topRight: isOwnMessage && firstOfBlock
                            ? Radius.circular(5)
                            : Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15))),
                padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isOwnMessage && firstOfBlock) ...[
                      Text(
                        _chatController.users[chatMessage.userId]!.firstName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Text(
                      chatMessage.messageContent,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget inputField(BuildContext context) {
    return Container(
      color: blue,
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 10),
      child: TextField(
        controller: textController,
        cursorColor: Colors.black,
        style: const TextStyle(color: Colors.black),
        minLines: 1,
        maxLines: 3,
        decoration: InputDecoration(
          fillColor: yellow,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 5),
          border: InputBorder.none,
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            borderSide: BorderSide.none,
          ),
          prefixIcon: IconButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                _chatController
                    .add(SendMessage(message: textController.text.trim()));
                textController.clear();
              }
            },
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void _scrollToEnd() async {
    await Future.delayed(Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }
}
