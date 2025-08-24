import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> init({required String ip, required int port}) async {
  final connection = await Socket.connect(ip, port);
  print(
    'Conectou no servidor de bate papo na porta remota: ${connection.remotePort}',
  );
  connection.listen((rawData) {
    print(utf8.decode(rawData));
  });

  stdin.transform(utf8.decoder).transform(LineSplitter()).listen((input) {
    connection.write(input);
  });
}
