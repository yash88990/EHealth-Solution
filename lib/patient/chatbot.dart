import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatBot extends StatefulWidget {
  @override
  _ChatBotState createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final String apiKey = "AIzaSyALyPSqkg46HIvi2SwoiYFGTHzz-nPv_ys"; 
  Future<void> _sendMessage(String message) async {
  setState(() {
    _messages.add({'sender': 'user', 'text': message});
  });
  _controller.clear();

  final response = await http.post(
    Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": message}
          ]
        }
      ]
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print("API Response: ${response.body}"); // Debugging

    if (data.containsKey('candidates') && data['candidates'].isNotEmpty) {
      final reply = data['candidates'][0]['content']['parts'][0]['text'];
      setState(() {
        _messages.add({'sender': 'bot', 'text': reply});
      });
    } else {
      setState(() {
        _messages.add({'sender': 'bot', 'text': 'No response from AI.'});
      });
    }
  } else {
    print("API Error: ${response.statusCode} - ${response.body}"); // Debugging
    setState(() {
      _messages.add({'sender': 'bot', 'text': 'Error: API request failed (${response.statusCode})'});
    });
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('E-Health Solution ')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Align(
                    alignment: message['sender'] == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: message['sender'] == 'user' ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message['text']!,
                        style: TextStyle(
                          color: message['sender'] == 'user' ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask a medical question...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
