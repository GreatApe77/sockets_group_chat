import 'dart:async';
import 'dart:convert';
import 'dart:io';

StreamController<String> messages = StreamController();
Future<void> init({required String ip, required int port}) async {
  final connection = await Socket.connect(ip, port);
  print('connected to Server on port: ${connection.remotePort}');
  connection.listen((rawData) {
    print(utf8.decode(rawData));
  });

  stdin.transform(utf8.decoder).transform(LineSplitter()).listen((input) {
    connection.write(input);
  });
  // while (true) {
  // print('loooop');
  //  final writtenUserMessage = stdin.readLineSync(encoding: Utf8Codec());
  //  connection.write(writtenUserMessage ?? 'ENTER');
  // } */
}

Future<void> sleep(int seconds) async {
  await Future.delayed(Duration(seconds: seconds));
}
