import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../domain/foodflow_models.dart';
import '../theme/foodflow_theme.dart';

final _currency = NumberFormat.simpleCurrency();

class ScreenShell extends StatelessWidget {
  const ScreenShell({
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 28),
    this.bottomNavigationIndex,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final int? bottomNavigationIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: FoodFlowColors.night,
      body: AuroraBackground(
        child: SafeArea(
          child: Padding(padding: padding, child: child),
        ),
      ),
      bottomNavigationBar: bottomNavigationIndex == null
          ? null
          : PremiumBottomNavigation(currentIndex: bottomNavigationIndex!),
    );
  }
}

class AuroraBackground extends StatefulWidget {
  const AuroraBackground({required this.child, super.key});

  final Widget child;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return DecoratedBox(
          decoration: const BoxDecoration(gradient: FoodFlowGradients.luxury),
          child: CustomPaint(
            painter: _AuroraPainter(progress: _controller.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _AuroraPainter extends CustomPainter {
  const _AuroraPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 56);
    final orbs = [
      (
        FoodFlowColors.orange,
        Offset(size.width * (.2 + progress * .12), size.height * .12),
        size.width * .34,
      ),
      (
        FoodFlowColors.purple,
        Offset(size.width * (.86 - progress * .14), size.height * .22),
        size.width * .42,
      ),
      (
        FoodFlowColors.emerald,
        Offset(size.width * (.18 + progress * .08), size.height * .72),
        size.width * .38,
      ),
      (
        FoodFlowColors.pink,
        Offset(size.width * (.78 - progress * .1), size.height * .86),
        size.width * .30,
      ),
    ];
    for (final orb in orbs) {
      paint.color = orb.$1.withValues(alpha: .30);
      canvas.drawCircle(orb.$2, orb.$3, paint);
    }

    final ribbonPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var i = 0; i < 4; i++) {
      final y =
          size.height * (.2 + i * .18) +
          math.sin(progress * math.pi * 2 + i) * 18;
      final path = Path()
        ..moveTo(-40, y)
        ..cubicTo(
          size.width * .2,
          y - 60,
          size.width * .55,
          y + 60,
          size.width + 40,
          y - 24,
        );
      canvas.drawPath(path, ribbonPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = FoodFlowRadii.lg,
    this.onTap,
    this.gradient,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final VoidCallback? onTap;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? FoodFlowColors.glass : null,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withValues(alpha: .14)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .28),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
    if (onTap == null) {
      return card;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      child: card,
    );
  }
}

class GradientButton extends StatefulWidget {
  const GradientButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    this.gradient = FoodFlowGradients.sunset,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final Gradient gradient;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedScale(
      scale: _pressed ? .96 : 1,
      duration: const Duration(milliseconds: 140),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: FoodFlowColors.orange.withValues(alpha: .38),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
              ],
              Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );

    return GestureDetector(
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: widget.onPressed == null
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            },
      child: Opacity(
        opacity: widget.onPressed == null ? .55 : 1,
        child: content,
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class PremiumSearchBar extends StatelessWidget {
  const PremiumSearchBar({
    required this.hint,
    required this.onChanged,
    this.initialValue,
    super.key,
  });

  final String hint;
  final String? initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      radius: 24,
      child: TextField(
        controller: initialValue == null
            ? null
            : TextEditingController(text: initialValue),
        onChanged: onChanged,
        style: const TextStyle(color: FoodFlowColors.text),
        decoration: InputDecoration(
          icon: const Icon(Icons.search_rounded, color: FoodFlowColors.orange),
          hintText: hint,
          filled: false,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          gradient: selected ? FoodFlowGradients.sunset : null,
          color: selected ? null : FoodFlowColors.glass,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withValues(alpha: selected ? .0 : .12),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? Colors.white : FoodFlowColors.muted,
          ),
        ),
      ),
    );
  }
}

class FoodOrb extends StatefulWidget {
  const FoodOrb({
    required this.colors,
    this.icon = Icons.restaurant_rounded,
    this.size = 92,
    super.key,
  });

  final List<int> colors;
  final IconData icon;
  final double size;

  @override
  State<FoodOrb> createState() => _FoodOrbState();
}

class _FoodOrbState extends State<FoodOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors.map(Color.new).toList();
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, math.sin(_controller.value * math.pi) * -8),
          child: Transform.rotate(
            angle: math.sin(_controller.value * math.pi * 2) * .05,
            child: child,
          ),
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: colors),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: .35),
              blurRadius: 32,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Icon(widget.icon, size: widget.size * .42, color: Colors.white),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    required this.restaurant,
    this.compact = false,
    super.key,
  });

  final Restaurant restaurant;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: restaurant.accentColors.map(Color.new).toList(),
    );
    return GlassCard(
      onTap: () => context.push('/restaurant/${restaurant.id}'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: compact ? 104 : 150,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(FoodFlowRadii.lg),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 18,
                  bottom: -6,
                  child: FoodOrb(
                    colors: restaurant.accentColors,
                    size: compact ? 74 : 104,
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 16,
                  child: _Pill(label: restaurant.promo),
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: Icon(
                    restaurant.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  restaurant.description,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Metric(
                      icon: Icons.star_rounded,
                      label: restaurant.rating.toStringAsFixed(1),
                    ),
                    _Metric(
                      icon: Icons.timer_rounded,
                      label: '${restaurant.deliveryMinutes} min',
                    ),
                    _Metric(
                      icon: Icons.payments_rounded,
                      label: restaurant.priceTier,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  const FoodCard({
    required this.item,
    this.onAdd,
    this.compact = false,
    super.key,
  });

  final MenuItem item;
  final VoidCallback? onAdd;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => context.push('/food/${item.id}'),
      child: Row(
        children: [
          Hero(
            tag: 'food-${item.id}',
            child: FoodOrb(
              colors: item.accentColors,
              size: compact ? 72 : 86,
              icon: Icons.lunch_dining_rounded,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      _currency.format(item.price),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    _Metric(
                      icon: Icons.star_rounded,
                      label: item.rating.toStringAsFixed(2),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: FoodFlowGradients.sunset,
            ),
            child: IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class PromotionBanner extends StatelessWidget {
  const PromotionBanner({required this.promotion, this.onApply, super.key});

  final Promotion promotion;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: promotion.accentColors.map(Color.new).toList(),
      ),
      child: Row(
        children: [
          const FoodOrb(
            colors: [0xFFFFFFFF, 0xAAFFFFFF],
            icon: Icons.local_offer_rounded,
            size: 70,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promotion.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  promotion.subtitle,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                _Pill(label: promotion.code),
              ],
            ),
          ),
          if (onApply != null)
            TextButton(
              onPressed: onApply,
              child: const Text('Apply', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}

class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    required this.value,
    this.prefix = '',
    this.suffix = '',
    super.key,
  });

  final double value;
  final String prefix;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        return Text(
          '$prefix${animated.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}$suffix',
          style: Theme.of(context).textTheme.headlineMedium,
        );
      },
    );
  }
}

class DeliveryProgressCard extends StatelessWidget {
  const DeliveryProgressCard({required this.tracking, super.key});

  final OrderTracking tracking;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: FoodFlowColors.amber),
              const SizedBox(width: 8),
              Text(
                'Live ETA ${tracking.etaMinutes} min',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text('${(tracking.progress * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: tracking.progress,
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: .12),
              valueColor: const AlwaysStoppedAnimation(FoodFlowColors.emerald),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            tracking.routeLabel,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class LiveTrackingWidget extends StatelessWidget {
  const LiveTrackingWidget({required this.tracking, super.key});

  final OrderTracking tracking;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 260,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _MapPainter(progress: tracking.progress),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              left: 24 + tracking.driverOffset * 220,
              top: 172 - math.sin(tracking.driverOffset * math.pi) * 78,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: FoodFlowGradients.sunset,
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.delivery_dining_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: GlassCard(
                radius: 22,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: FoodFlowColors.purple,
                      child: Icon(Icons.person_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tracking.driver.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${tracking.driver.vehicle} • ${tracking.driver.rating} rating',
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.call_rounded),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chat_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  const _MapPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: .06)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 42) {
      canvas.drawLine(Offset(x, 0), Offset(x + 80, size.height), gridPaint);
    }
    for (var y = 20.0; y < size.height; y += 42) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 30), gridPaint);
    }

    final route = Path()
      ..moveTo(40, size.height - 70)
      ..cubicTo(
        size.width * .28,
        size.height * .18,
        size.width * .62,
        size.height * .72,
        size.width - 44,
        52,
      );
    canvas.drawPath(
      route,
      Paint()
        ..color = Colors.white.withValues(alpha: .18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      route,
      Paint()
        ..shader = FoodFlowGradients.sunset.createShader(Offset.zero & size)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class RewardCard extends StatelessWidget {
  const RewardCard({required this.reward, super.key});

  final Reward reward;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      gradient: FoodFlowGradients.electric,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(reward.tier, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedCounter(value: reward.points.toDouble(), suffix: ' pts'),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: reward.progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
            valueColor: const AlwaysStoppedAnimation(FoodFlowColors.lime),
          ),
          const SizedBox(height: 8),
          Text(
            reward.nextRewardLabel,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class SuccessBurst extends StatefulWidget {
  const SuccessBurst({super.key});

  @override
  State<SuccessBurst> createState() => _SuccessBurstState();
}

class _SuccessBurstState extends State<SuccessBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(220, 220),
          painter: _BurstPainter(
            progress: Curves.easeOut.transform(_controller.value),
          ),
          child: const SizedBox(
            width: 220,
            height: 220,
            child: Icon(Icons.check_rounded, size: 94),
          ),
        );
      },
    );
  }
}

class _BurstPainter extends CustomPainter {
  const _BurstPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()..strokeWidth = 4;
    for (var i = 0; i < 18; i++) {
      final angle = (math.pi * 2 / 18) * i;
      final inner = 58 + progress * 18;
      final outer = 58 + progress * 86;
      paint.color = [
        FoodFlowColors.orange,
        FoodFlowColors.emerald,
        FoodFlowColors.pink,
      ][i % 3].withValues(alpha: 1 - progress);
      canvas.drawLine(
        center + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
        center + Offset(math.cos(angle) * outer, math.sin(angle) * outer),
        paint,
      );
    }
    canvas.drawCircle(
      center,
      60 + progress * 4,
      Paint()
        ..shader = FoodFlowGradients.fresh.createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class PremiumBottomNavigation extends StatelessWidget {
  const PremiumBottomNavigation({required this.currentIndex, super.key});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final destinations = [
      ('/home', Icons.home_rounded, 'Home'),
      ('/discover', Icons.travel_explore_rounded, 'Discover'),
      ('/orders', Icons.receipt_long_rounded, 'Orders'),
      ('/profile', Icons.person_rounded, 'Profile'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        radius: 28,
        child: Row(
          children: [
            for (var i = 0; i < destinations.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => context.go(destinations[i].$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: currentIndex == i
                          ? FoodFlowGradients.sunset
                          : null,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(destinations[i].$2, size: 22, color: Colors.white),
                        const SizedBox(height: 2),
                        Text(
                          destinations[i].$3,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: .08),
      highlightColor: Colors.white.withValues(alpha: .22),
      child: Column(
        children: List.generate(
          4,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              height: 118,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(FoodFlowRadii.lg),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: FoodFlowColors.amber),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: FoodFlowColors.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .20),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: .18)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
