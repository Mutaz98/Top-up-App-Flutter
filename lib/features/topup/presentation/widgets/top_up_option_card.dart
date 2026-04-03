import 'package:flutter/material.dart';
import 'package:topup/app/theme/app_theme.dart';

class TopUpOptionCard extends StatelessWidget {
  final double amount;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const TopUpOptionCard({
    super.key,
    required this.amount,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isDisabled
                    ? AppColors.divider.withOpacity(0.4)
                    : AppColors.divider,
            width: isSelected ? 0 : 1,
          ),
        ),
        child: Opacity(
          opacity: isDisabled ? 0.4 : 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'AED',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          isSelected ? Colors.black87 : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                amount.toInt().toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: isSelected ? Colors.black : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
