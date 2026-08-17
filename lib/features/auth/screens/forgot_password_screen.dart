import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

// ---------------------------------------------------------------------------
// PHASE 03 — Authentication Foundation
// ---------------------------------------------------------------------------
// Self-service password reset is NOT available per FINAL v3 spec.
// Accounts are NGO-provisioned. Password resets are done by the NGO Admin.
// This screen exists only as a graceful informational page.
// ---------------------------------------------------------------------------

/// Contact NGO screen — shown when the user tries to reset their password.
/// No email, OTP, or self-service reset. Leader must contact their NGO coordinator.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= AppConstants.mobileBreakpoint;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Need Help?'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? AppConstants.loginCardMaxWidth : double.infinity,
            ),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusXl),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          size: 40,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Contact Your NGO Coordinator',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'All accounts are created and managed by your NGO coordinator.\n\n'
                      'If you have forgotten your password or need access, please contact them directly. '
                      'They will reset your credentials.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    OutlinedButton.icon(
                      onPressed: () => context.goNamed('login'),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Back to Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
