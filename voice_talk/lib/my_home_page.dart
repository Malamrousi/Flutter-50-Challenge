import 'dart:developer' as log;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:lottie/lottie.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isListening = false;
  bool isSpeaking = false;   
  double voiceLevel = 20.0;
  String recognizedText = "";
  bool isInitialized = false;
  SpeechToText speechToText = SpeechToText();
  FlutterTts flutterTts = FlutterTts();
  int steps = 0;
  String? lastResponse; 

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTts();
    Gemini.init(apiKey: apiKey);
  }

  Future<void> initSpeechToText() async {
    bool available = await speechToText.initialize(
      onStatus: (status) => log.log('Speech status: $status'),
      onError: (error) => log.log('Speech error: $error'),
    );
    if (available) {
      setState(() {
        isInitialized = true;
      });
    } else {
      log.log("Speech recognition not available");
    }
  }

  void startListening() async {
    if (!isInitialized) {
      return;
    }

    setState(() {
      isListening = true;
      recognizedText = "";
    });

    await speechToText.listen(
      partialResults: false,
      listenFor: const Duration(minutes: 2),
      onSoundLevelChange: (level) {
        if (isListening) {
          setState(() {
            voiceLevel = max(20.0, (level + 20) * 3);
          });
        }
      },
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          sendText(result.recognizedWords);
          setState(() {
            recognizedText = result.recognizedWords;
            if (result.finalResult) {
              isListening = false;
              voiceLevel = 20.0;
            }
          });
        }
      },
    );
  }

  void stopListening() async {
    setState(() {
      isListening = false;
      voiceLevel = 20.0;
    });
    await speechToText.stop();
  }

  String apiKey = dotenv.env["GOOGLE_GEMINI_API_KEY"] ?? "";

  Future<void> sendText(String text) async {
    setState(() {
      steps = 1; 
    });
    
    Gemini gemini = Gemini.instance;
    gemini.text(text).then((value) {
      setState(() {
        steps = 2;  
        lastResponse = value?.output.toString() ?? "لم أفهم ذلك";
      });
      speakResponse(lastResponse!);
    }).catchError((error) {
      log.log("Error with Gemini: $error");
      setState(() {
        steps = 0;
      });
      speakResponse("عذراً، حدث خطأ في معالجة طلبك");
    });
  }

  Future<void> initTts() async {
    await flutterTts.awaitSpeakCompletion(true);
    
    flutterTts.setStartHandler(() {
      setState(() {
        isSpeaking = true;
      });
      log.log("TTS started");
    });
    
    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
        if (steps == 2) {
          steps = 0;
        }
      });
      log.log("TTS completed");
    });
    
    flutterTts.setErrorHandler((msg) {
      setState(() {
        isSpeaking = false;
      });
      log.log("TTS error: $msg");
    });
  }

  Future<void> speakResponse(String response) async {
    setState(() {
      isSpeaking = true;
    });
    await flutterTts.speak(response);
  }

  Future<void> pauseSpeech() async {
    if (isSpeaking) {
      setState(() {
        isSpeaking = false;
      });
      await flutterTts.pause();
    }
  }

  Future<void> cancelAll() async {
    await flutterTts.stop();
    await speechToText.stop();
    setState(() {
      steps = 0;
      isListening = false;
      isSpeaking = false;
      voiceLevel = 20.0;
    });
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
                if (steps == 0) {
                  startListening();
                } else if (isListening) {
                  stopListening();
                } else if (steps == 2) {
                  if (isSpeaking) {
                    pauseSpeech(); 
                  } else if (lastResponse != null) {
                    speakResponse(lastResponse!); 
                  }
                }
              },
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey,
                child: Icon(
                  steps == 0
                      ? Icons.mic
                      : isListening
                          ? Icons.pause
                          : isSpeaking
                              ? Icons.pause
                              : Icons.play_arrow,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 40),
            
            
            Expanded(
              child: steps == 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          curve: Curves.easeInOut,
                          duration: const Duration(milliseconds: 100),
                          width: 15,
                          height: isListening ? voiceLevel * 1.1 : 20.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(150),
                          ),
                        ),
                        const SizedBox(width: 5),
                        AnimatedContainer(
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          duration: const Duration(milliseconds: 100),
                          width: 15,
                          height: isListening ? voiceLevel * 1.2 : 20.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(150),
                          ),
                        ),
                        const SizedBox(width: 5),
                        AnimatedContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          curve: Curves.easeInOut,
                          duration: const Duration(milliseconds: 100),
                          width: 15,
                          height: isListening ? voiceLevel * 1.3 : 20.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(150),
                          ),
                        ),
                        const SizedBox(width: 5),
                        AnimatedContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          curve: Curves.easeInOut,
                          duration: const Duration(milliseconds: 100),
                          width: 15,
                          height: isListening ? voiceLevel * 1.1 : 20.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(150),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            
            
            InkWell(
              onTap: () {
                if (steps == 0 && !isListening) {
                  Navigator.pop(context);
                } else {
                  cancelAll();
                }
              },
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.red,
                child: Icon(
                  steps == 0 && !isListening ? Icons.arrow_back : Icons.close,
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
            
              const SizedBox(height: 80),
              if (steps == 0)
                const CircleAvatar(
                  radius: 120,
                  backgroundColor: Color(0XFF13D4FB),
                )
              else if (steps == 1)
                Lottie.asset('assets/chat_gpt.json',
                    width: 330, height: 330, fit: BoxFit.cover)
              else if (steps == 2)
                Lottie.asset('assets/typing.json',
                    width: 330, height: 330, fit: BoxFit.cover),
              const SizedBox(height: 20),
              Text(
                steps == 1
                    ? "جاري التحميل..."
                    : steps == 2
                        ? isSpeaking 
                            ? "جاري الرد..." 
                            : "الرد متوقف، اضغط لإعادة التشغيل"
                        : isListening
                            ? "جاري الاستماع..."
                            : "اضغط على الميكروفون للتحدث",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
