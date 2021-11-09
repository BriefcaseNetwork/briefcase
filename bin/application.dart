import 'package:briefcase/application/runtime_settings.dart';
import 'package:briefcase/cli/arguments_parser.dart';
import 'package:briefcase/server/server.dart';

Future<void> main(List<String> arguments) async {
  var settings = getApplicationRuntimeSettings(
    ArgumentsParserBuilder()
        .addOption<bool>(
          character: 'i',
          name: 'interactive',
          description:
              "Enables a REST API server for interacting with the network, instead of just serving the network.",
          defaultValue: false,
        )
        .build()
        .parse(arguments),
  );

  BriefcaseServer server = await BriefcaseServer.start();
  print("Listening for traffic...");
}
