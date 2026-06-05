import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/foodflow_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FoodFlowBootstrap());
}

class FoodFlowBootstrap extends StatelessWidget {
  const FoodFlowBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: FoodFlowApp());
  }
}
