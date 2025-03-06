import 'dart:convert';

import 'package:ai_chatbot/message_model.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<MessageModel> msg = [];
  bool isTyping = false;

  void sendMessage() async {
    String text = controller.text.trim();
    String apiKey = dotenv.env["GOOGLE_GEMINI_API_KEY"] ?? "";
    if (text.isEmpty || apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Api key pr text is Empty")));
      return;
    }

    controller.clear();

    setState(() {
      msg.insert(0, MessageModel(true, text));
      isTyping = true;
    });

    scrollController.animateTo(0.0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeOut);

    try {
      final response = await http.post(
        Uri.parse(
          "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$apiKey",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
          
            {
              "contents": [
                {
                  "parts": [
                    {"text": text}
                  ]
                }
              ]
            }
          ,
        ),
      );
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);

        String responseText = json["candidates"][0]["content"]["parts"][0]
                ["text"]
            .toString()
            .trim();
        setState(() {
          isTyping = false;
          msg.insert(0, MessageModel(false, responseText));
        });

        scrollController.animateTo(0.0,
            duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error : ${response.body}")));

        setState(() {
          isTyping = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error occurred : ${e.toString()}")));

      setState(() {
        isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBar(
          title: const Text("Ai Chat Bot"),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: msg.length,
              shrinkWrap: true,
              reverse: true,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: isTyping && index == 0
                      ? Column(
                          children: [
                            BubbleNormal(
                              text: msg[0].message,
                              isSender: true,
                              color: Colors.blue.shade100,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 16, top: 4),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Typing"),
                              ),
                            )
                          ],
                        )
                      : BubbleNormal(
                          text: msg[index].message,
                          isSender: msg[index].isSender,
                          color: msg[index].isSender
                              ? Colors.blue.shade100
                              : Colors.blue.shade200,
                        ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        controller: controller,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (value) {
                          sendMessage();
                        },
                        textInputAction: TextInputAction.send,
                        showCursor: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter Text",
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  sendMessage();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(30)),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                ),
                
              )
            ],
          )
        ],
      ),
    );
  }
}
