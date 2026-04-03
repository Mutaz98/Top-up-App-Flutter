import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topup/app/theme/app_theme.dart';
import 'package:topup/features/beneficiaries/domain/entities/beneficiary.dart';
import 'package:topup/features/beneficiaries/presentation/bloc/beneficiaries_bloc.dart';
import 'package:topup/features/beneficiaries/presentation/bloc/beneficiaries_event.dart';
import 'package:topup/features/user/domain/entities/user.dart';
import 'package:topup/core/widgets/custom_text_button.dart';

class BeneficiaryCard extends StatelessWidget {
  final Beneficiary beneficiary;
  final User user;
  final VoidCallback onTopUp;

  const BeneficiaryCard({
    super.key,
    required this.beneficiary,
    required this.user,
    required this.onTopUp,
  });

  @override
  Widget build(BuildContext context) {
    final limit = user.isVerified ? 1000.0 : 500.0;
    final progress =
        (beneficiary.monthlyTopUpTotal / limit).clamp(0.0, 1.0).toDouble();
    final remaining = limit - beneficiary.monthlyTopUpTotal;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.gradientEnd],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      beneficiary.nickname[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        beneficiary.nickname,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        beneficiary.phoneNumber,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                // Top-up button
                GestureDetector(
                  onTap: onTopUp,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded,
                            color: Colors.black, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Top Up',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: Colors.black, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete button
                GestureDetector(
                  onTap: () => _confirmDelete(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.error, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Progress bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly: AED ${beneficiary.monthlyTopUpTotal.toStringAsFixed(0)}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 11),
                ),
                Text(
                  'AED ${remaining.toStringAsFixed(0)} left of AED ${limit.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                        color: progress > 0.8
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 0.8 ? AppColors.error : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove ${beneficiary.nickname}?',
            style: const TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'This beneficiary will be removed from your list.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          CustomTextButton(
            onPressed: () => ctx.pop(),
            text: 'Cancel',
            textStyle: const TextStyle(color: AppColors.textSecondary),
          ),
          CustomTextButton(
            onPressed: () {
              ctx.pop();
              context
                  .read<BeneficiariesBloc>()
                  .add(DeleteBeneficiaryEvent(beneficiary.id));
            },
            text: 'Remove',
            textStyle: const TextStyle(color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
