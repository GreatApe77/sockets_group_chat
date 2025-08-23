import 'dart:io';

import 'package:args/args.dart';
import 'package:server/server.dart' as server;

const ipOption = "ip";
const portOption = "port";
void main(List<String> args) {
  final argParser = ArgParser();
  argParser.addOption(ipOption, defaultsTo: InternetAddress.loopbackIPv4.address);
  argParser.addOption(portOption, defaultsTo: "3000");
  final argResult = argParser.parse(args);
  final ip = argResult.option(ipOption);
  final port = argResult.option(portOption);
  server.init(ip: ip!, port: int.parse(port!));
}
