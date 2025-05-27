#!/usr/bin/env dart

import 'package:args/args.dart';
import 'package:backend_generator/generator.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Muestra ayuda')
    ..addOption('output', abbr: 'o', defaultsTo: '.', help: 'Directorio de salida')
    ..addMultiOption('features', abbr: 'f', help: 'Features a generar (ej: users,auth)');

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool || results['features'].isEmpty) {
      print(parser.usage);
      return;
    }

    final generator = BackendGenerator(
      outputDir: results['output'] as String,
      features: (results['features'] as List).cast<String>(),
    );

    await generator.generate();
    print('✅ Estructura generada exitosamente!');
  } catch (e) {
    print('❌ Error: $e');
  }
}