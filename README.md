# briefcase
An experimental peer-to-peer network.

## Compiling
To compile a self-contained executable (a standalone architecture-specific executable file containing the
source code compiled to machine code and a small Dart runtime), use the following command:
```dart
dart compile exe bin/application.dart -o dist/application
```
This will compile an executable file native to your system. On Windows, you may wish to append `.exe` to
the name of the output file. On *nix systems, you can just run the executable with `./dist/application`.

As a fun aside, you can also compile to JavaScript as follows:
```dart
dart compile js bin/application.js -o dist/application.js
```