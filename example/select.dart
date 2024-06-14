import 'dart:io';

import 'package:commander_ui/commander_ui.dart';

final class Item {
  final String name;
  final int value;

  Item(this.name, this.value);
}

Future<void> main() async {
  StdinBuffer.initialize();

  final List<Item> items = List.generate(
      20, (index) => Item('${index + 1}. Hello World', index + 1));

  String formatSelectedLine(String line) =>
      '${AsciiColors.green('❯')} ${AsciiColors.lightCyan(line)}';

  final select = Select(
      answer: "Please select your best hello",
      options: items,
      placeholder: 'Type to filter',
      selectedLineStyle: formatSelectedLine,
      unselectedLineStyle: (line) => '  $line',
      onDisplay: (item) => item.name);

  final selected = switch (await select.handle()) {
    Ok(:final value) => 'My value is ${value.value}',
    Err(:final error) => Exception('Error: $error'),
    _ => 'Unknown',
  };

  print(selected);

  exit(0);
}
