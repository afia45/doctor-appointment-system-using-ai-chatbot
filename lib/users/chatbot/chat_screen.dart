//TODO clear chat for new users!!!!
import 'package:doctor_appointment_app/users/chatbot/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:carousel_slider/carousel_slider.dart';

//import 'package:audioplayers/audioplayers.dart'; // Import AudioPlayer

class ChatScreen extends StatefulWidget {
  ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController chatController = Get.put(ChatController());

  final ScrollController scrollController =
      ScrollController(); 
 // Add ScrollController
  final List<String> tutorialImages = [
    'assets/images/tutorial1.png', // Replace with your image paths
    'assets/images/tutorial2.png',
  ];

  //final CarouselController _carouselController = CarouselController();
  final CarouselSliderController buttonCarouselController =
      CarouselSliderController();

  int _currentIndex = 0;

  //tutorial--------------------------
  void _showTutorial(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      "Chatbot Guideline",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    // Carousel Slider
                    CarouselSlider(
                      items: tutorialImages.map((imagePath) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            // Use the device's width
                            double screenWidth =
                                MediaQuery.of(context).size.width;
                            return Image.asset(
                              imagePath,
                              width:
                                  screenWidth, // Adjust image width to screen size
                              fit: BoxFit
                                  .contain, // Ensure the image is fully visible
                            );
                          },
                        );
                      }).toList(),
                      options: CarouselOptions(
                        height: 300,
                        viewportFraction: 1.0,
                        enableInfiniteScroll: false,
                        onPageChanged: (index, reason) {
                          setState(() => _currentIndex = index);
                        },
                      ),
                      carouselController: buttonCarouselController,
                    ),
                    SizedBox(height: 16),

                    // Custom Indicator (Dots)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        tutorialImages.length,
                        (index) => AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: _currentIndex == index ? 12 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentIndex == index
                                ? Colors.red
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Skip and Next Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: Text('Skip'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_currentIndex < tutorialImages.length - 1) {
                              buttonCarouselController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            } else {
                              Navigator.of(context).pop(); // Close when done
                            }
                          },
                          child: Text(
                            _currentIndex == tutorialImages.length - 1
                                ? 'Done'
                                : 'Next',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.red[100],
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.red,
        title: Text(
          'Doctor Appointment Assistant',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),

        actions: [
          IconButton(
      icon: Icon(Icons.refresh,color: Colors.white), // Icon for the restart button
      onPressed: () {
        // Call the restart function in the controller
        chatController.restartConversation();
      },
      tooltip: "Restart Conversation",
    ),
          // DropdownButton<String>(
          //   value: chatController.currentLanguage.value,
          //   items: [
          //     DropdownMenuItem(value: 'en', child: Text('English')),
          //     DropdownMenuItem(value: 'bn', child: Text('বাংলা')),
          //   ],
          //   onChanged: (value) {
          //     if (value != null) {
          //       chatController.setLanguage(value);
          //     }
          //   },
          // ),

          IconButton(
            icon: Icon(Icons.help_outline,color: Colors.white), // Help Icon
            onPressed: () => _showTutorial(context),
            tooltip: "Tutorial",
          ),
          IconButton(
            icon: Icon(Icons.delete_forever,color: Colors.white),
            onPressed: () {
              // Clear all messages
              chatController.clearMessages();
              //show snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Chat has been cleared.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: "Clear Messages",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (scrollController.hasClients) {
                  scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });
              return ListView.builder(
                controller: scrollController, // Attach ScrollController
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  final message = chatController.messages[index];
                  return ChatBubble(
                      message: message); // Correctly render ChatBubble
                },
              );
            }),
          ),
          Obx(() => chatController.isLoading.value
              ? CircularProgressIndicator()
              : SizedBox.shrink()),
          ChatInput(
              onSendMessage:
                  chatController.sendMessage), // ChatInput remains the same
        ],
      ),
    );
  }
}

//Chat Bubble Class/widget ----------------------------------

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  ChatBubble({required this.message});

  final FlutterTts _flutterTts = FlutterTts();

  Future<void> _initializeTTS() async {
    String language = Get.find<ChatController>().currentLanguage.value == 'bn'
        ? "bn-BD"
        : "en-US";
    
    // Initialize and check if TTS engine is ready
    var isAvailable = await _flutterTts.isLanguageAvailable(language);
    if (!isAvailable) {
      print("TTS engine is not available.");
    } else {
      // Set the language and pitch if TTS engine is available
      await _flutterTts.setLanguage(language);
      await _flutterTts.setPitch(1.0);
    }
  }

  void _speak(String text) async {
    await _initializeTTS();  
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.red : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: message.isUser ? Radius.circular(20) : Radius.zero,
            bottomRight: message.isUser ? Radius.zero : Radius.circular(20),
          ),
        ),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min, // Ensures bubble adapts to text
                children: [
                  Flexible(
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  if (!message.isUser)
                    IconButton(
                      icon: Icon(Icons.volume_up),
                      onPressed: () => _speak(message.text),
                    ),
                ],
              ),
              if (message.buttons != null) ...[
                SizedBox(height: 8),
                ...message.buttons!.map((button) => ElevatedButton(
                      onPressed: () => Get.find<ChatController>().sendMessage({
                        'message': button.payload,
                        'customData': {
                          'language':
                              Get.find<ChatController>().currentLanguage.value
                        },
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Background color
                        foregroundColor: Colors.white, // Text color
                        padding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12), // Padding
                      ),
                      child: Text(
                        button.title,
                        style: TextStyle(
                            //fontSize: 16,
                            //fontWeight: FontWeight.bold
                            ), // Text style
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

//Chat Input Class/widget ----------------------------------

class ChatInput extends StatefulWidget {
  final Function(Map<String, dynamic>) onSendMessage;

  ChatInput({required this.onSendMessage});

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  //final AudioPlayer _audioPlayer = AudioPlayer(); // Player for mic sounds

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      final String currentLocale =
          Get.find<ChatController>().currentLanguage.value == 'bn'
              ? 'bn-BD'
              : 'en-US'; // Use currentLanguage to determine the locale

      bool available = await _speech.initialize(
        onStatus: (status) => print('Speech status: $status'),
        onError: (error) => print('Speech error: $error'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: currentLocale,
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
            });
          },
        );
      } else {
        print("Speech recognition not available on this device.");
      }
    } else if (status.isDenied || status.isPermanentlyDenied) {
      print("Microphone permission denied.");
      // Optionally show a dialog or redirect users to settings
      await openAppSettings();
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
    //_audioPlayer.play(AssetSource('assets/sounds/mic_off.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            onPressed: _isListening ? _stopListening : _startListening,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                //hintText: 'Type a message...'
                hintText: Get.find<ChatController>().currentLanguage.value ==
                        'en'
                    ? 'Type a message (একটি বার্তা লিখুন)...' // English hint
                    : 'একটি বার্তা লিখুন...', // Bangla hint
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                widget.onSendMessage({
                  'message': _controller.text,
                  'customData': {
                    'language': Get.find<ChatController>().currentLanguage.value
                  },
                });
                if (_isListening) {
                  _stopListening();
                }
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
