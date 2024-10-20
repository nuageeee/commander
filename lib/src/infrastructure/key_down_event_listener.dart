import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:commander_ui/src/commons/ansi_character.dart';
import 'package:commander_ui/src/commons/terminal.dart';
import 'package:commander_ui/src/infrastructure/key_down_listener.dart';
import 'package:commander_ui/src/infrastructure/models/key_down.dart';
import 'package:commander_ui/src/infrastructure/stdin_buffer.dart';

/// Listens to key down events and executes the corresponding callbacks.
class KeyDownEventListener with TerminalTools {
  StreamSubscription? sigintSubscription;
  late StreamSubscription<List<int>>? subscription;
  final List<KeyDownListener> listeners = [];
  FutureOr<void> Function(String, void Function())? fallback;

  /// Creates a new instance of [KeyDownEventListener] and starts listening to key down events.
  KeyDownEventListener() {
    enableRawMode();

    subscription = stdinStream.listen((List<int> input) {
      KeyDown key = KeyDown.fromInput(input);

      return switch (key) {
        KeyDown.ctrlC => onExit((_) => dispose),
        _ => print(key),
      };
    });

    // subscription = StdinBuffer.stream.transform(utf8.decoder).listen((data) {
    //   final listener = listeners.firstWhereOrNull((listener) => listener.key.matches(data));
    //   if (listener case KeyDownListener listener) {
    //     listener.callback(data, dispose);
    //     return;
    //   }
    //
    //   if (fallback != null) {
    //     fallback!(data, dispose);
    //   }
    // });
  }

  /// Adds a new listener for the specified [key].
  /// When the [key] is pressed, the [callback] is executed.
  void match(AnsiCharacter key, void Function(String, void Function() dispose) callback) {
    listeners.add(KeyDownListener(key, callback));
  }

  /// Sets a fallback listener that is called when a key is pressed that does not have a specific listener.
  void catchAll(FutureOr<void> Function(String, void Function() dispose) callback) {
    fallback = callback;
  }

  /// Sets a listener that is called when the application is about to exit.
  onExit(Function(void Function() dispose) callback) {
    sigintSubscription = ProcessSignal.sigint.watch().listen((event) {
      callback(dispose);
      disableRawMode();
    });
  }

  /// Disposes the listener, stopping it from listening to key down events.
  void dispose() {
    subscription?.cancel();
    subscription = null;

    sigintSubscription?.cancel();
    sigintSubscription = null;
  }
}
