import 'dart:developer' as log;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isListening = false;
  double voiceLevel = 20.0;
  String recognizedText = "";
  bool isInitialized = false;
  SpeechToText speechToText = SpeechToText();

  void toggleListening() async {
    if (!isListening) {
      setState(() {
        isListening = true;
        recognizedText = "";
      });

      await speechToText.listen(
        partialResults: true,
        listenFor: const Duration(minutes: 2),
        onSoundLevelChange: (level) {
          if (isListening) {
            setState(() {
              voiceLevel = max(20.0, (level + 20) * 3); // Tweak multiplier
            });
          }
        },
        onResult: (result) {
          setState(() {
            recognizedText = result.recognizedWords;
            if (result.finalResult) {
              isListening = false;
              voiceLevel = 20.0;
            }
          });
          log.log('Recognized: $result');
        },
      );
    } else {
      setState(() {
        isListening = false;
        voiceLevel = 20.0;
      });
      await speechToText.stop();
    }
  }

  @override
  void initState() {
    super.initState();
    toggleListening();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                if (isListening) {
                  setState(() {
                    isListening = false;
                    voiceLevel = 20.0;
                  });
                  speechToText.stop();
                } else {
                  setState(() {
                    voiceLevel = 20.0;
                    recognizedText = "";
                  });
                  speechToText.cancel();
                }
              },
              child: CircleAvatar(
                radius: 25,
                backgroundColor: isListening ? Colors.grey : Colors.red,
                child: Icon(
                  isListening ? Icons.pause : Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 40),
            AnimatedContainer(
              padding: EdgeInsets.symmetric(horizontal: 10),
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 100),
              width: 20,
              height: isListening ? voiceLevel * 1.1 : 20.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(150),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            AnimatedContainer(
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(horizontal: 10),
              duration: const Duration(milliseconds: 100),
              width: 20,
              height: isListening ? voiceLevel * 1.2 : 20.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(150),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            AnimatedContainer(
              padding: EdgeInsets.symmetric(horizontal: 10),
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 100),
              width: 20,
              height: isListening ? voiceLevel * 1.3 : 20.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(150),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            AnimatedContainer(
              padding: EdgeInsets.symmetric(horizontal: 10),
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 100),
              width: 20,
              height: isListening ? voiceLevel * 1.1 : 20.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(150),
              ),
            ),
            const SizedBox(width: 40),
            InkWell(
              onTap: toggleListening,
              child: CircleAvatar(
                radius: 25,
                backgroundColor: isListening ? Colors.red : Colors.green,
                child: Icon(
                  isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 1,
        title: const Text(
          "Voice Talk",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.black,
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.info,
                  color: Colors.grey,
                  size: 25,
                ),
              ),
              const SizedBox(height: 80),
              const CircleAvatar(radius: 120),
              const SizedBox(height: 20),
              Text(
                isListening ? "Listening..." : "Tap to Start Speaking",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              // if (recognizedText.isNotEmpty)
              //   Container(
              //     margin: const EdgeInsets.symmetric(horizontal: 20),
              //     padding: const EdgeInsets.all(10),
              //     decoration: BoxDecoration(
              //       color: Colors.grey.shade900,
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: Text(
              //       recognizedText,
              //       style: const TextStyle(
              //         color: Colors.white,
              //         fontSize: 16,
              //       ),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
