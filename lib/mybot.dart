import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});
  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  ChatUser myself = ChatUser(id: '1', firstName: 'sajjad');
  ChatUser bot = ChatUser(id: '2', firstName: 'chatbot');

  List<ChatMessage> allMessages = [];
  List<ChatUser> typing = [];

  final ourUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyBndFJAbUcys_EpXkAExV6ZVYxCEpTh-IU';
  final header = {'Content-Type': 'application/json'};

  getData(ChatMessage m) async {
    typing.add(
        bot); // when this function is triggered the typing message will show at the screen.
    allMessages.insert(0,
        m); // inserting message to the ui. message is shown at the ui that is typed by the user.
    setState(() {});

    var data = {
      "contents": [
        {
          "parts": [
            {"text": m.text}
          ]
        }
      ]
    };

    await http // sending http post request. here we pass url, headers and body.
        //headers: metadata about the client making the request. Body: Data that is send by the client to the user
        .post(Uri.parse(ourUrl), headers: header, body: jsonEncode(data))
        .then((value) {
      if (value.statusCode == 200) {
        var result = jsonDecode(value.body);
        // print(result['candidates'][0]['content']['parts'][0]['text']);

        ChatMessage m1 = ChatMessage(
            text: result['candidates'][0]['content']['parts'][0]['text'],
            user: bot,
            createdAt: DateTime.now());

        allMessages.insert(0, m1);
        setState(() {});
      } else {
        // print("Error Occured");
      }
    }).catchError((e) {});
    typing.remove(bot); // after getting the messae typing will be removed.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4, // Adds a shadow to the AppBar
        backgroundColor: Colors.black,
        centerTitle: true, // Center aligns the title
        title: const Text(
          'AI Chatbot',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'FontTitle',
          ),
        ),
      ),
      body: DashChat(
        // 3 property defined in dashchat package: current user, on send, messages
        typingUsers: typing,
        currentUser: myself,
        onSend: (ChatMessage m) {
          getData(m);
        },
        messages: allMessages,
        inputOptions: const InputOptions(
          alwaysShowSend: true,
          cursorStyle: CursorStyle(
            color: Colors.black,
          ),
        ),
        messageOptions: MessageOptions(
          currentUserContainerColor: Colors.black,
          avatarBuilder: yourAvatarBuilder,
        ),
      ),
    );
  }

  Widget yourAvatarBuilder(
      ChatUser user, Function? onAvatarTap, Function? onAvatarLongPress) {
    return Center(
      child: Image.asset(
        'assets/images/logo.png',
        height: 40,
        width: 40,
      ),
    );
  }
}
