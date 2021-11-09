class ApplicationRuntimeSettings {
  /// Whether the application is running in interactive mode.
  /// (Interactive mode enables a REST API server for interacting with the
  /// network, instead of just serving the network.)
  final bool interactive;

  ApplicationRuntimeSettings({
    required this.interactive,
  });
}

/// Wraps an [ArgumentsParser] to provide an application-specific API for
/// checking what options were set at the command-line.
ApplicationRuntimeSettings getApplicationRuntimeSettings(
    Map<String, dynamic> settings) {
  return ApplicationRuntimeSettings(
    interactive: settings['interactive'] ?? false,
  );
}
