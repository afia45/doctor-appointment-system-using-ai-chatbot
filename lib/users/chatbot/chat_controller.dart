/*
This controller:
- Manages the chat messages and loading state.
- Handles sending messages to and receiving messages from the WebSocket.
- Processes Rasa’s responses, including quick replies (buttons).
*/
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'websocket_manager.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final List<ChatButton>? buttons;

  ChatMessage({required this.text, required this.isUser, this.buttons});
}

class ChatButton {
  final String title;
  final String payload;

  ChatButton({required this.title, required this.payload});
}

class ChatController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final currentLanguage = 'en'.obs; // Default to English, can change to 'bn' for bangla

  //late final WebSocketManager webSocketManager;
  final String rasaServerUrl = "http://10.0.2.2:5005/webhooks/rest/webhook";
// android emulator – final String rasaServerUrl = "http://10.0.2.2:5005/webhooks/rest/webhook";
// chrome- localhost:5005
// real device - take computer local ip address- 192.168.x.x // 192.168.68.113 (both device and server should be in same Wi-Fi network)

  
  @override
  void onInit() {
    super.onInit();
    //webSocketManager = WebSocketManager('http://0.0.0.0:5005');
    //webSocketManager.messageStream.listen(_handleWebSocketMessage);
    //sendInitialMessage();
  }

  // void sendInitialMessage() {
  //   sendMessage({
  //     //হ্যালো , hi, hello
  //     'message': currentLanguage.value == 'bn' ? 'হ্যালো' : 'Hello',
  //     //'message': 'হ্যালো',
  //     //'customData': {'language': 'bn'},
  //   });
  // }
  // Method to restart the conversation by sending 'reset' and '/restart' messages
  void restartConversation() async {
    // Send reset message
    await sendMessage({
      'message': 'reset',
      'customData': {'language': currentLanguage.value}
    });

    // Send /restart message
    await sendMessage({
      'message': '/restart',
      'customData': {'language': currentLanguage.value}
    });
  } 
  void setLanguage(String language) {
    currentLanguage.value = language;
  }

  Future<void> sendMessage(Map<String, dynamic> message) async {
    message['customData'] = {'language': currentLanguage.value};
    addMessage(ChatMessage(text: message['message'], isUser: true));
    isLoading.value = true;
    //webSocketManager.sendMessage(message);
    try {
      final response = await http.post(
        Uri.parse(rasaServerUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'sender': 'user',
          'message': message['message'],
          'customData': {'language': currentLanguage.value},
        }),
      );

      if (response.statusCode == 200) {
        List<dynamic> messages = jsonDecode(response.body);
        for (var msg in messages) {
          if (msg['text'] != null) {
            addMessage(ChatMessage(
              text: msg['text'],
              isUser: false,
              buttons: (msg['buttons'] as List<dynamic>?)
                  ?.map((button) => ChatButton(
                        title: button['title'],
                        payload: button['payload'],
                      ))
                  .toList(),
            ));
          }
        }
      } else {
        print("Failed to get response from Rasa server: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /*void _handleWebSocketMessage(Map<String, dynamic> message) {
    print("Received message: $message");
    if (message['text'] != null) {
      addMessage(ChatMessage(
        text: message['text'],
        isUser: false,
        buttons: (message['quick_replies'] as List<dynamic>?)
            ?.map((button) => ChatButton(
                title: button['title'],
                payload: button['payload']))
            .toList(),
      ));
    }
    isLoading.value = false;
  }*/

  void addMessage(ChatMessage message) {
    messages.add(message);
  }

  void clearMessages() {
    messages.clear();
  }

  /*@override
  void dispose() {
    //webSocketManager.dispose();
    super.dispose();
  }*/
}

