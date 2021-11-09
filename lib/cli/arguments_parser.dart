import 'dart:io';

String _regexpCharacterRangeExcept(String character) {
  int codeUnit = character.codeUnitAt(0);

  // If it's a lowercase letter, make it uppercase and
  // handle it as though it were uppercase.
  if (codeUnit >= 97 && codeUnit <= 122) {
    codeUnit = character.toUpperCase().codeUnitAt(0);
  }

  // Now create the range for an uppercase letter.
  late String range;
  if (codeUnit >= 65 && codeUnit <= 90) {
    switch (codeUnit) {
      case 65:
        range = 'B-Z';
        break;
      case 66:
        range = 'AC-Z';
        break;
      case 89:
        range = 'A-XZ';
        break;
      case 90:
        range = 'A-Y';
        break;
      default:
        range =
            'A-${String.fromCharCode(codeUnit - 1)}${String.fromCharCode(codeUnit + 1)}-Z';
        break;
    }
  }

  // If the original character was lowercase, make the range lowercase again.
  if (character.codeUnitAt(0) >= 97 && character.codeUnitAt(0) <= 122) {
    range = range.toLowerCase();
  }

  return range;
}

/// Represents an individual option that may be set on an [ArgumentsParser].
/// This is also how options set on the [ArgumentsParserBuilder] are stored
/// internally.
class ArgumentsParserOption<T> {
  /// The single character used to represent the argument.
  final String character;

  /// The full name of the argument.
  final String name;

  /// Optionally, a description of the argument and what it changes.
  final String? description;

  /// The default value of the argument. If specified, will be used when the
  /// option is not set.
  final T? defaultValue;

  ArgumentsParserOption({
    required this.character,
    required this.name,
    this.description,
    this.defaultValue,
  });

  /// The regular expression that represents the character of this option, but
  /// one that will match even if the character is combined with others in
  /// a group.
  /// e.g., '-agh' will still match, if this character was 'h'.
  String get characterArgumentRegExp =>
      '-[${_regexpCharacterRangeExcept(character)}]*$character';

  /// Whether this current option is specified by any of the [arguments] in the
  /// specified list of arguments.
  bool hasMatch(List<String> arguments) {
    return RegExp(characterArgumentRegExp, caseSensitive: false)
            .hasMatch(arguments.join(' ')) ||
        arguments.contains("--$name");
  }
}

/// Provides a clean, readable builder-style API for initializing an
/// [ArgumentsParser] with the options specified on the builder.
class ArgumentsParserBuilder {
  final List<ArgumentsParserOption> _optionsList = [];

  ArgumentsParserBuilder addOption<T>({
    required String character,
    required String name,
    String? description,
    T? defaultValue,
  }) {
    _optionsList.add(ArgumentsParserOption(
      character: character,
      name: name,
      description: description,
      defaultValue: defaultValue,
    ));
    return this;
  }

  ArgumentsParser build() {
    return ArgumentsParser._construct(optionsList: _optionsList);
  }
}

/// Parses command-line arguments. Typically, one of these would be initialized
/// with a [ArgumentsParserBuilder] which would set the options accepted by the
/// parser.
class ArgumentsParser {
  /// The raw, unmodified, options list as it was passed into the parser.
  final List<ArgumentsParserOption> _rawOptionsList;

  ArgumentsParser._construct({
    required List<ArgumentsParserOption> optionsList,
  }) : _rawOptionsList = optionsList;

  /// The options list, with built-in options injected.
  List<ArgumentsParserOption> get options => List.unmodifiable([
        ..._rawOptionsList,
        // This is inserted for display purposes only.
        ArgumentsParserOption<bool>(
          character: 'h',
          name: 'help',
          description: "Displays this help menu.",
        )
      ]);

  /// Parses a given list of arguments into a map of settings based on the
  /// possible options set on the parser.
  Map<String, dynamic> parse(List<String> arguments) {
    // If help is included, print the help information, and exit early.
    if (options
        .firstWhere((option) => option.name == 'help')
        .hasMatch(arguments)) {
      printHelp();
      exit(0);
    }

    /// The runtime settings evaluated by parsing the arguments based on the
    /// specified options for arguments.
    Map<String, dynamic> settings = {};

    for (var option in options) {
      // Currently, this only supports boolean options. (i.e., "is the option
      // specified?")
      // At some point this will be expanded for all options.
      if (option.hasMatch(arguments)) {
        settings[option.name] = true;
      } else {
        settings[option.name] = false;
      }
    }

    return settings;
  }

  /// Prints general help information. This is automatically called if -h or
  /// --help is provided.
  printHelp() {
    print("");

    var optionsInfo = options.map((option) {
      String commandName = '-${option.character},\t--${option.name}';
      return {'name': commandName, 'option': option};
    });

    var longestCommandNameLength = (optionsInfo.reduce((value, element) =>
            (value['name'] as String).length >
                    (element['name'] as String).length
                ? value
                : element)['name'] as String)
        .length;

    for (var entry in optionsInfo) {
      String commandName = entry['name'] as String;
      ArgumentsParserOption option = entry['option'] as ArgumentsParserOption;

      int nameDifference = longestCommandNameLength - commandName.length;

      String defaultNote = option.defaultValue != null
          ? '(default: ${option.defaultValue}) '
          : '';

      print(
        '\t$commandName${' ' * nameDifference}\t\t$defaultNote${option.description}'
            .replaceAll('\t', ' ' * 2),
      );
    }
  }
}
