import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../domain/foodflow_models.dart';
import '../state/foodflow_state.dart';
import '../theme/foodflow_theme.dart';
import '../widgets/premium_components.dart';

final _currency = NumberFormat.simpleCurrency();

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final promotions = ref.watch(promotionsProvider);
    return ScreenShell(
      child: ListView(
        children: [
          _TitleRow(title: 'Your cart', onBack: () => context.pop()),
          const SizedBox(height: 18),
          if (cart.lines.isEmpty)
            _EmptyCart(onBrowse: () => context.go('/discover'))
          else ...[
            for (final line in cart.lines) ...[
              Dismissible(
                key: ValueKey(line.item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: FoodFlowColors.coral.withValues(alpha: .82),
                    borderRadius: BorderRadius.circular(FoodFlowRadii.lg),
                  ),
                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                ),
                onDismissed: (_) =>
                    ref.read(cartProvider.notifier).remove(line.item.id),
                child: _CartLineCard(line: line),
              ),
              const SizedBox(height: 14),
            ],
            promotions.when(
              data: (items) => PromotionBanner(
                promotion: items.last,
                onApply: () =>
                    ref.read(cartProvider.notifier).applyPromo(items.last),
              ),
              loading: () => const SkeletonLoader(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 18),
            _OrderSummary(cart: cart),
            const SizedBox(height: 22),
            GradientButton(
              label: 'Checkout ${_currency.format(cart.total)}',
              icon: Icons.lock_rounded,
              onPressed: () => context.push('/checkout'),
            ),
          ],
        ],
      ),
    );
  }
}

class _CartLineCard extends ConsumerWidget {
  const _CartLineCard({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      child: Row(
        children: [
          FoodOrb(
            colors: line.item.accentColors,
            size: 72,
            icon: Icons.lunch_dining_rounded,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.item.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  line.selectedAddons
                      .map((addon) => addon.name)
                      .join(', ')
                      .ifEmpty('Chef default'),
                ),
                const SizedBox(height: 8),
                Text(
                  _currency.format(line.lineTotal),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () =>
                    ref.read(cartProvider.notifier).increment(line.item.id),
                icon: const Icon(Icons.add_circle_rounded),
              ),
              AnimatedCounter(value: line.quantity.toDouble()),
              IconButton(
                onPressed: () =>
                    ref.read(cartProvider.notifier).decrement(line.item.id),
                icon: const Icon(Icons.remove_circle_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    return ScreenShell(
      child: ListView(
        children: [
          _TitleRow(title: 'Checkout', onBack: () => context.pop()),
          const SizedBox(height: 18),
          const _CheckoutCard(
            icon: Icons.location_on_rounded,
            title: 'Delivery address',
            body: '742 Aurora Ave, Apt 18B\nLeave at concierge desk',
            action: 'Change',
          ),
          const SizedBox(height: 14),
          const _CheckoutCard(
            icon: Icons.credit_card_rounded,
            title: 'Payment',
            body:
                'Apple Pay selected\nCards, Google Pay, PayPal, and cash available',
            action: 'Edit',
          ),
          const SizedBox(height: 14),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Driver tip',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  children: [
                    for (final tip in [2.0, 3.0, 5.0, 8.0])
                      CategoryChip(
                        label: _currency.format(tip),
                        selected: cart.tip == tip,
                        onTap: () =>
                            ref.read(cartProvider.notifier).setTip(tip),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const _CheckoutCard(
            icon: Icons.notes_rounded,
            title: 'Delivery instructions',
            body: 'Contactless drop-off. Ring once when arriving.',
            action: 'Edit',
          ),
          const SizedBox(height: 18),
          _OrderSummary(cart: cart),
          const SizedBox(height: 22),
          GradientButton(
            label: 'Place order ${_currency.format(cart.total)}',
            icon: Icons.verified_rounded,
            onPressed: cart.lines.isEmpty
                ? null
                : () {
                    context.go('/success');
                  },
          ),
        ],
      ),
    );
  }
}

class CheckoutSuccessScreen extends ConsumerWidget {
  const CheckoutSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenShell(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SuccessBurst(),
          const SizedBox(height: 26),
          Text(
            'Order confirmed',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 12),
          const Text(
            'Your chef accepted the order. FoodFlow will keep the route, ETA, and driver updates alive.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          GradientButton(
            label: 'Track live order',
            icon: Icons.delivery_dining_rounded,
            onPressed: () {
              ref.read(cartProvider.notifier).clear();
              context.go('/tracking');
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text('Back to home'),
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.cart});

  final CartState cart;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: cart.subtotal),
          _SummaryRow(label: 'Delivery', value: cart.deliveryFee),
          _SummaryRow(label: 'Estimated tax', value: cart.taxes),
          if (cart.appliedPromo != null)
            _SummaryRow(label: cart.appliedPromo!.code, value: -cart.discount),
          _SummaryRow(label: 'Driver tip', value: cart.tip),
          const Divider(color: Colors.white24, height: 28),
          Row(
            children: [
              Text('Total', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              AnimatedCounter(value: cart.total, prefix: r'$'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text(
            _currency.format(value),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _CheckoutCard extends StatelessWidget {
  const _CheckoutCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final String action;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Icon(icon, color: FoodFlowColors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(body),
              ],
            ),
          ),
          TextButton(onPressed: () {}, child: Text(action)),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          const FoodOrb(
            colors: [0xFFFF7A1A, 0xFFFF4F6D],
            icon: Icons.shopping_bag_outlined,
            size: 116,
          ),
          const SizedBox(height: 18),
          Text(
            'Your cart is waiting',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          const Text(
            'Add a signature dish, apply a reward, and glide through checkout.',
          ),
          const SizedBox(height: 20),
          GradientButton(label: 'Browse restaurants', onPressed: onBrowse),
        ],
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlassCard(
          onTap: onBack,
          radius: 18,
          padding: const EdgeInsets.all(12),
          child: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 14),
        Text(title, style: Theme.of(context).textTheme.headlineLarge),
      ],
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
