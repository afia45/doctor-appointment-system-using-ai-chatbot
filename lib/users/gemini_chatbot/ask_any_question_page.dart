//import 'dart:io';
//import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
//import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class AskAnyQuestionPage extends StatefulWidget {
  const AskAnyQuestionPage({super.key});

  @override
  State<AskAnyQuestionPage> createState() => _AskAnyQuestionPageState();
}

class _AskAnyQuestionPageState extends State<AskAnyQuestionPage> {
  final TextEditingController _userInput = TextEditingController();
  final List<Message> _messages = [];

  static const String apiKey = "AIzaSyBalgHcpzD3YqyuznDEh_z9cC7qePSjSdY";
  final GenerativeModel model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';

  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _introduceChatbot();
  }

  void _introduceChatbot() {
    setState(() {
      _messages.add(Message(
        isUser: false,
        message: "Hello, I am your healthcare assistant! I can answer questions about human diseases, their symptoms, and treatments. How can I assist you today? (বাংলা: আমি আপনার স্বাস্থ্য সহকারী, আমি মানব রোগ, তাদের উপসর্গ এবং চিকিত্সা সম্পর্কে প্রশ্নের উত্তর দিতে পারি। আমি কীভাবে সাহায্য করতে পারি?)",
        date: DateTime.now(),
      ));
    });
  }

  Future<void> _sendMessage() async {
    final String message = _userInput.text.trim();

    if (message.isEmpty) return;

    setState(() {
      _messages.add(Message(isUser: true, message: message, date: DateTime.now()));
    });

    // Check the language of the input
    bool isBangla = RegExp(r'[অ-ঔ,ক-ঙ,চ-ঞ,ট-থ,দ-ধ,প-ফ,ব-ভ]').hasMatch(message);

    if (isBangla) {
      // Send the message to the model in Bangla
      final String medicalContextPrompt =
          "আমি একটি স্বাস্থ্য সহকারী। আমি শুধু মানব রোগ, তাদের উপসর্গ, এবং চিকিত্সা সম্পর্কিত প্রশ্নের উত্তর দেব। ";
      final content = [Content.text(medicalContextPrompt + message)];
      final response = await model.generateContent(content);

      setState(() {
        _messages.add(Message(
          isUser: false,
          message: response.text ?? "দুঃখিত, আমি উত্তর দিতে পারি না।",
          date: DateTime.now(),
        ));
      });
      if (_isListening) {
        await _speak(response.text ?? "দুঃখিত, আমি উত্তর দিতে পারি না।");  // Speak out the response in Bangla
      }
    } else {
      final String medicalContextPrompt =
          "I am a medical assistant. Only answer questions related to human diseases, their symptoms, and treatments. ";
      final content = [Content.text(medicalContextPrompt + message)];
      final response = await model.generateContent(content);

      setState(() {
        _messages.add(Message(
          isUser: false,
          message: response.text ?? "Sorry, I couldn't provide a response.",
          date: DateTime.now(),
        ));
      });
      if (_isListening) {
        await _speak(response.text ?? "Sorry, I couldn't provide a response.");  // Speak out the response in English
      }
    }

    _userInput.clear();
  }

  void _toggleListening() async {
    if (_isListening) {
      setState(() {
        _isListening = false;
      });
      _speechToText.stop();
    } else {
      setState(() {
        _isListening = true;
      });
      bool available = await _speechToText.initialize();
      if (available) {
        _speechToText.listen(onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
            _userInput.text = _recognizedText;  // Update the text input field
          });
        });
      }
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage(_isListening ? "bn-BD" : "en-US"); // Set language to Bangla if listening
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ask Any Health Related Question', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Messages(
                  isUser: message.isUser,
                  message: message.message,
                  date: DateFormat('HH:mm').format(message.date),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _userInput,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter your medical question',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(_isListening ? Icons.stop : Icons.mic),
                  onPressed: _toggleListening,
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;

  Message({required this.isUser, required this.message, required this.date});
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;

  const Messages({
    super.key,
    required this.isUser,
    required this.message,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isUser ? Colors.grey : Colors.red,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: isUser ? Radius.circular(20) : Radius.zero,
            bottomRight: isUser ? Radius.zero : Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              date,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
