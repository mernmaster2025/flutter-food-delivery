import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../routes/app_router.dart';
import '../theme/foodflow_theme.dart';

class FoodFlowApp extends ConsumerWidget {
  const FoodFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'FoodFlow',
      debugShowCheckedModeBanner: false,
      theme: FoodFlowTheme.dark(),
      routerConfig: router,
    );
  }
}
