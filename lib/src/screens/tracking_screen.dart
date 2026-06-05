import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/foodflow_models.dart';
import '../state/foodflow_state.dart';
import '../theme/foodflow_theme.dart';
import '../widgets/premium_components.dart';

class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracking = ref.watch(liveTrackingProvider);
    return ScreenShell(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: tracking.when(
        data: (value) => ListView(
          children: [
            Row(
              children: [
                GlassCard(
                  onTap: () => context.go('/home'),
                  radius: 18,
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.close_rounded),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Live tracking',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LiveTrackingWidget(tracking: value),
            const SizedBox(height: 18),
            DeliveryProgressCard(tracking: value),
            const SizedBox(height: 18),
            _StageTimeline(stage: value.stage),
            const SizedBox(height: 18),
            GlassCard(
              child: Row(
                children: [
                  const FoodOrb(
                    colors: [0xFFFF7A1A, 0xFFFFC857],
                    icon: Icons.restaurant_rounded,
                    size: 70,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Velvet Taco Lab',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Text('Order FF-1092 • Priority delivery'),
                      ],
                    ),
                  ),
                  Text('${value.etaMinutes}m'),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 42),
                const SizedBox(height: 12),
                Text(
                  'Tracking reconnecting',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StageTimeline extends StatelessWidget {
  const _StageTimeline({required this.stage});

  final OrderStage stage;

  @override
  Widget build(BuildContext context) {
    final stages = [
      (OrderStage.confirmed, 'Confirmed', Icons.verified_rounded),
      (OrderStage.preparing, 'Preparing', Icons.soup_kitchen_rounded),
      (OrderStage.pickedUp, 'Picked up', Icons.delivery_dining_rounded),
      (OrderStage.nearby, 'Nearby', Icons.location_on_rounded),
      (OrderStage.delivered, 'Delivered', Icons.check_circle_rounded),
    ];
    final current = stages.indexWhere((item) => item.$1 == stage);
    return GlassCard(
      child: Column(
        children: [
          for (var i = 0; i < stages.length; i++) ...[
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: i <= current ? FoodFlowGradients.sunset : null,
                    color: i <= current
                        ? null
                        : Colors.white.withValues(alpha: .12),
                  ),
                  child: Icon(stages[i].$3, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    stages[i].$2,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: i <= current
                          ? FoodFlowColors.text
                          : FoodFlowColors.subtle,
                    ),
                  ),
                ),
                if (i == current)
                  const Text(
                    'Now',
                    style: TextStyle(
                      color: FoodFlowColors.emerald,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ),
            if (i != stages.length - 1)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 2,
                  height: 24,
                  margin: const EdgeInsets.only(left: 20),
                  color: i < current
                      ? FoodFlowColors.orange
                      : Colors.white.withValues(alpha: .12),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
