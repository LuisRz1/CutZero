import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/app_theme.dart';

final class CutZeroApp extends StatelessWidget {
  const CutZeroApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'CutZero',
    debugShowCheckedModeBanner: false,
    theme: CutZeroTheme.light,
    routerConfig: appRouter,
  );
}
