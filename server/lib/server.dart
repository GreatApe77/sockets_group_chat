// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

List<Client> clients = [];

const groupChatName = "CHAT DA GALERA!";
Future<void> init({required String ip, required int port}) async {
  final socketServer = await ServerSocket.bind(InternetAddress(ip), port);
  print('Server listening on: ${socketServer.address.address}:${socketServer.port}');

  socketServer.listen((clientSocket) async {
    print('new connection with IP: ${clientSocket.address.address} from remote port ${clientSocket.remotePort}');
    clientSocket.write('Welcome to $groupChatName! Please enter your username to proceed: ');
    //print(clients);
    clientSocket.listen(
      (rawData) {
        final decodedData = utf8.decode(rawData);
        if (!isSocketAlreadyClient(clientSocket)) {
          final connectingClient = Client(socket: clientSocket, username: decodedData);
          //if (clients.we(element)) clients.add(client);
          clients.add(connectingClient);
          print('${connectingClient.username} Joined the chat!');
          clientSocket.write(
            buildWelcomeMessage(
              amountOfConnectedChatMembers: clients.length,
              usernames: clients.map((client) => client.username).toList(),
              groupChatTitle: groupChatName,
              enteringUsername: connectingClient.username,
            ),
          );
        } else {
          final currentClient = getClientFromSocket(clientSocket);
          final message = ChatMessage(
            username: currentClient.username,
            fromIp: currentClient.socket.address.address,
            content: decodedData,
          );
          for (var client in clients) {
            if (currentClient.socket != client.socket) {
              client.socket.write(message.toString());
            }
          }
        }
      },

      onDone: () {
        print('Client Socket with IP: ${clientSocket.address.address} ended the connection!');
        clients.removeWhere((element) => element.socket == clientSocket);
      },
      cancelOnError: true,
    );
  });
  /* socketServer.listen(
    (clientSocket) async {
      print('Client connected!!');
      print('Address: ${clientSocket.address.address}');
      print('Remote Address: ${clientSocket.remoteAddress.address}');
      print('Port: ${clientSocket.port}');
      print('Remote Port: ${clientSocket.remotePort}');
      clientSocket.write('Bem vindo!');
      clientSocket.listen(
        (event) {
          clientSocket.write('Sua mensagem chegou! voce disse : ${utf8.decode(event).toUpperCase()}');
        },
        onDone: () {
          print("ONDONE");
        },
        onError: (err) {
          print("ONERROR");
        },
      );
    },
    onDone: () {
      print('Connection closed!!');
    },
    onError: (err) {
      print('Unknown error!!');
    },
  ); */
}

class ChatMessage {
  final String username;
  final String fromIp;
  final String content;
  ChatMessage({required this.username, required this.fromIp, required this.content});

  @override
  String toString() {
    return '$username at $fromIp says: $content';
  }
}

class Client {
  final Socket socket;
  final String username;

  Client({required this.socket, required this.username});

  @override
  String toString() => 'Client(socket: $socket, username: $username)';

  @override
  bool operator ==(covariant Client other) {
    if (identical(this, other)) return true;

    return other.socket == socket && other.username == username;
  }

  @override
  int get hashCode => socket.hashCode ^ username.hashCode;
}

bool isSocketAlreadyClient(Socket socket) {
  final idx = clients.indexWhere((element) => element.socket == socket);
  return idx != -1;
}

Client getClientFromSocket(Socket socket) {
  return clients.firstWhere((element) => element.socket == socket);
}

String buildWelcomeMessage({
  required int amountOfConnectedChatMembers,
  required List<String> usernames,
  required String groupChatTitle,
  required String enteringUsername,
}) {
  return '''
  ${'=' * 20}
  Hello, $enteringUsername!
  WELCOME TO $groupChatTitle group chat!  
  There are ${usernames.length} members connected!
  Members: ${usernames.toString()}
  ${'=' * 20}
''';
}
