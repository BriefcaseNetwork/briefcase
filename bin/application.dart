import 'package:briefcase/server/server.dart';

Future<void> main(List<String> arguments) async {
  BriefcaseServer server = await BriefcaseServer.start();
  print("Listening for traffic...");
}
