import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('controlled project text contains no emoji literals', () async {
    final roots = [
      Directory('lib'),
      Directory('test'),
      Directory('docs'),
      Directory('.github'),
    ];
    final files = <File>[
      File('README.md'),
      File('pubspec.yaml'),
      for (final root in roots)
        await for (final entity in root.list(recursive: true))
          if (entity is File && _isControlledText(entity.path)) entity,
    ];
    final emoji = RegExp(
      r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}]',
      unicode: true,
    );
    final violations = <String>[];
    for (final file in files) {
      final content = await file.readAsString();
      if (emoji.hasMatch(content)) violations.add(file.path);
    }

    expect(
      violations,
      isEmpty,
      reason: 'Remove emoji literals from: ${violations.join(', ')}',
    );
  });

  test(
    'domain application and presentation avoid infrastructure imports',
    () async {
      final violations = <String>[];
      await for (final entity in Directory(
        'lib/features',
      ).list(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final protectedLayer =
            normalized.contains('/domain/') ||
            normalized.contains('/application/') ||
            normalized.contains('/presentation/');
        if (!protectedLayer) continue;
        final content = await entity.readAsString();
        if (content.contains('/infrastructure/') ||
            content.contains('../infrastructure')) {
          violations.add(entity.path);
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Move infrastructure dependencies out of: ${violations.join(', ')}',
      );
    },
  );
}

bool _isControlledText(String path) {
  const extensions = {
    '.dart',
    '.md',
    '.yaml',
    '.yml',
    '.json',
    '.xml',
    '.plist',
    '.kts',
  };
  return extensions.any(path.endsWith);
}
