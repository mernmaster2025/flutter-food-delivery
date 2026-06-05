import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/foodflow_theme.dart';
import '../widgets/premium_components.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _phoneMode = false;
  bool _otpSent = false;

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      child: ListView(
        children: [
          const SizedBox(height: 24),
          const FoodOrb(
            colors: [0xFFFF7A1A, 0xFFFF4F6D, 0xFF8D5CFF],
            icon: Icons.lock_open_rounded,
            size: 116,
          ),
          const SizedBox(height: 28),
          Text(
            'Welcome back to FoodFlow',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 10),
          const Text(
            'Sign in for rewards, priority delivery, saved favorites, and one-tap reorders.',
          ),
          const SizedBox(height: 26),
          GlassCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CategoryChip(
                        label: 'Email',
                        selected: !_phoneMode,
                        onTap: () => setState(() => _phoneMode = false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CategoryChip(
                        label: 'Phone',
                        selected: _phoneMode,
                        onTap: () => setState(() => _phoneMode = true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  keyboardType: _phoneMode
                      ? TextInputType.phone
                      : TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: _phoneMode ? 'Phone number' : 'Email address',
                    prefixIcon: Icon(
                      _phoneMode ? Icons.phone_rounded : Icons.mail_rounded,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: _phoneMode
                      ? TextField(
                          key: ValueKey(_otpSent),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: _otpSent
                                ? 'Enter 6-digit OTP'
                                : 'OTP verification',
                            prefixIcon: const Icon(Icons.pin_rounded),
                            hintText: _otpSent
                                ? '123456'
                                : 'Tap continue to send OTP',
                          ),
                        )
                      : const TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.password_rounded),
                          ),
                        ),
                ),
                const SizedBox(height: 18),
                GradientButton(
                  label: _phoneMode && !_otpSent
                      ? 'Send OTP'
                      : 'Enter FoodFlow',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    if (_phoneMode && !_otpSent) {
                      setState(() => _otpSent = true);
                      return;
                    }
                    context.go('/home');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _AuthTile(
                  label: 'Google',
                  icon: Icons.g_mobiledata_rounded,
                  onTap: () => context.go('/home'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AuthTile(
                  label: 'Apple',
                  icon: Icons.apple_rounded,
                  onTap: () => context.go('/home'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AuthTile(
                  label: 'Face ID',
                  icon: Icons.face_rounded,
                  onTap: () => context.go('/home'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AuthTile(
                  label: 'Fingerprint',
                  icon: Icons.fingerprint_rounded,
                  onTap: () => context.go('/home'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text('Continue as guest'),
          ),
        ],
      ),
    );
  }
}

class _AuthTile extends StatelessWidget {
  const _AuthTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      radius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        children: [
          Icon(icon, color: FoodFlowColors.text),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
