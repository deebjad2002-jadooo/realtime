// import 'dart:convert';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
    );
  }
}

// ===== Splash Screen =====
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // عرض الشاشة 2 ثانية ثم الانتقال للواجهة الرئيسية
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RealChat()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            FlutterLogo(size: 100),
            SizedBox(height: 20),
            Text(
              'Loading...',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== RealTime Chat =====
class RealChat extends StatefulWidget {
  const RealChat({super.key});

  @override
  State<RealChat> createState() => _RealChatState();
}

class _RealChatState extends State<RealChat> {
  late IOWebSocketChannel channel;
  final TextEditingController _controller = TextEditingController();
  final List<String> messages = [];

  @override
  void initState() {
    super.initState();
    // الاتصال بالخادم بعد بناء واجهة المستخدم
    WidgetsBinding.instance.addPostFrameCallback((_) {
      connectWebSocket();
    });
  }

  void connectWebSocket() {
    try {
      // استبدل localhost بـ IP الجهاز المحلي إذا تعمل على الهاتف
      channel = IOWebSocketChannel.connect("ws://192.168.1.12:30000");

      channel.stream.listen((event) {
        try {
          final msg = jsonDecode(event);
          setState(() {
            messages.add("${msg['from'] ?? 'server'}: ${msg['text']}");
          });
        } catch (e) {
          setState(() {
            messages.add(event.toString());
          });
        }
      });
    } catch (e) {
      // في حال فشل الاتصال
      setState(() {
        messages.add("Connection error: $e");
      });
    }
  }

  void sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final data = jsonEncode({
      'type': 'message', 'text': text, 'from': 'App',

      //userid
      //DDDDDDD
    });
    channel.sink.add(data);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RealTime Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(messages[index]),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.grey.shade200,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) => sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    _controller.dispose();
    super.dispose();
  }
}
