import 'dart:io';

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 30000);

  final List<WebSocket> clients = [];

  print("WebSocket server running on ws://${server.address.address}:30000");

  await for (HttpRequest req in server) {
    // تحقق هل الطلب WebSocket
    if (WebSocketTransformer.isUpgradeRequest(req)) {
      final socket = await WebSocketTransformer.upgrade(req);
      handleWebSocket(socket, clients);
    } else {
      req.response
        ..statusCode = HttpStatus.forbidden
        ..write("WebSocket connections only")
        ..close();
    }
  }
}

void handleWebSocket(WebSocket socket, List<WebSocket> clients) {
  print("Client connected");
  clients.add(socket);

  // استقبال الرسائل من العميل
  socket.listen(
    (message) {
      print("Message received: $message");

      // إرسال الرسالة لكل المستخدمين
      for (var client in clients) {
        if (client.readyState == WebSocket.open) {
          client.add(message);
        }
      }
    },
    onDone: () {
      print("Client disconnected");
      clients.remove(socket);
    },
    onError: (error) {
      print("Error: $error");
      clients.remove(socket);
    },
  );
}
