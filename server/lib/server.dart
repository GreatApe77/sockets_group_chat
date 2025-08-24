import 'dart:convert';
import 'dart:io';

List<Client> clients = [];

const groupChatName = 'GRUPO IRADO';
Future<void> init({required String ip, required int port}) async {
  final socketServer = await ServerSocket.bind(InternetAddress(ip), port);
  print('Servidor aguardando conexões em: ${socketServer.address.address}:${socketServer.port}');

  socketServer.listen((clientSocket) async {
    print('Nova conexão. IP: ${clientSocket.address.address} oriunda de porta remota: ${clientSocket.remotePort}');
    clientSocket.write('Bem vindo ao $groupChatName! Digite como quer ser chamado no bate-papo:');

    clientSocket.listen(
      (rawData) {
        final decodedData = utf8.decode(rawData);
        if (!isSocketAlreadyClient(clientSocket)) {
          final connectingClient = Client(socket: clientSocket, username: decodedData);
          final idx = clients.indexWhere((element) => element.username == connectingClient.username);
          if (idx != -1) {
            clientSocket.write(
              'O nome de usuário ${connectingClient.username} já está sendo utilizado. Escolha outro e envie novamente!',
            );
            return;
          }
          clients.add(connectingClient);
          print('${connectingClient.username} Entrou no servidor!');
          clientSocket.write(
            buildWelcomeMessage(
              amountOfConnectedChatMembers: clients.length,
              usernames: clients.map((client) => client.username).toList(),
              groupChatTitle: groupChatName,
              enteringUsername: connectingClient.username,
            ),
          );
          broadcastMessage(
            agent: clientSocket,
            message: '${getClientFromSocket(clientSocket).username} Entrou no chat!',
          );
        } else {
          final currentClient = getClientFromSocket(clientSocket);
          final message = ChatMessage(
            username: currentClient.username,
            fromIp: currentClient.socket.address.address,
            content: decodedData,
          );
          broadcastMessage(agent: currentClient.socket, message: message.toString());
        }
      },
      onDone: () {
        print('Cliente de IP: ${clientSocket.address.address} encerrou a conexão!');
        if (isSocketAlreadyClient(clientSocket)) {
          broadcastMessage(agent: clientSocket, message: '${getClientFromSocket(clientSocket).username} Left the chat');
          clients.removeWhere((element) => element.socket == clientSocket);
        }
      },
      cancelOnError: true,
    );
  });
}

class ChatMessage {
  final String username;
  final String fromIp;
  final String content;
  ChatMessage({required this.username, required this.fromIp, required this.content});

  @override
  String toString() {
    return '$username em $fromIp disse: $content';
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
  Olá, $enteringUsername!
  Bem vindo ao $groupChatTitle!  
  Esse bate-papo possui ${usernames.length} membros connectados!
  membros: ${usernames.toString()}
  ${'=' * 20}
''';
}

void broadcastMessage({required Socket agent, required Object message}) {
  for (var client in clients) {
    if (agent != client.socket) {
      client.socket.write(message);
    }
  }
}
