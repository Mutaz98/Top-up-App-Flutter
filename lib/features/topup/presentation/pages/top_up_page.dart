import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topup/core/constants/app_constants.dart';
import 'package:topup/app/theme/app_theme.dart';
import 'package:topup/features/beneficiaries/domain/entities/beneficiary.dart';
import 'package:topup/features/topup/presentation/bloc/top_up_bloc.dart';
import 'package:topup/features/topup/presentation/bloc/top_up_event.dart';
import 'package:topup/features/topup/presentation/bloc/top_up_state.dart';
import 'package:topup/features/topup/presentation/widgets/top_up_option_card.dart';
import 'package:topup/features/user/domain/entities/user.dart';
import 'package:topup/features/beneficiaries/presentation/bloc/beneficiaries_bloc.dart';
import 'package:topup/features/beneficiaries/presentation/bloc/beneficiaries_event.dart';
import 'package:topup/features/user/presentation/bloc/user_bloc.dart';
import 'package:topup/features/user/presentation/bloc/user_event.dart';
import 'package:topup/core/widgets/custom_button.dart';

class TopUpPage extends StatelessWidget {
  final Beneficiary beneficiary;
  final User user;

  const TopUpPage({
    super.key,
    required this.beneficiary,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<TopUpBloc, TopUpState>(
      listener: _onStateChange,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Top Up ${beneficiary.nickname}'),
          leading: const BackButton(),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: BlocBuilder<TopUpBloc, TopUpState>(
              builder: (context, state) {
                if (state is! TopUpFormReady) {
                  return const Center(child: CircularProgressIndicator());
                }

                final formState = state;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBeneficiaryInfo(context),
                    const SizedBox(height: 20),
                    _buildLimitCard(context, formState),
                    const SizedBox(height: 24),
                    Text('Select Amount',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _buildAmountGrid(context, formState),
                    if (formState.selectedAmount != null) ...[
                      const SizedBox(height: 24),
                      _buildFeeBreakdown(context, formState),
                      const SizedBox(height: 24),
                      _buildConfirmButton(context, formState),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBeneficiaryInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.gradientEnd]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                beneficiary.nickname[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(beneficiary.nickname,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              Text(beneficiary.phoneNumber,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLimitCard(BuildContext context, TopUpFormReady formState) {
    final benProgress =
        (formState.beneficiary.monthlyTopUpTotal / formState.perBenLimit)
            .clamp(0.0, 1.0)
            .toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monthly Limit',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.primary)),
              Row(
                children: [
                  Icon(
                    formState.user.isVerified
                        ? Icons.verified_rounded
                        : Icons.pending_outlined,
                    color: formState.user.isVerified
                        ? AppColors.secondary
                        : AppColors.textMuted,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formState.user.isVerified ? 'Verified' : 'Unverified',
                    style: TextStyle(
                      color: formState.user.isVerified
                          ? AppColors.secondary
                          : AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AED ${formState.beneficiary.monthlyTopUpTotal.toStringAsFixed(0)} used',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 12),
              ),
              Text(
                'AED ${formState.benRemaining.toStringAsFixed(0)} remaining of AED ${formState.perBenLimit.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: benProgress > 0.8
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
              value: benProgress,
              minHeight: 5,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                benProgress > 0.8 ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountGrid(BuildContext context, TopUpFormReady formState) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: AppConstants.topUpAmounts.length,
      itemBuilder: (_, i) {
        final amount = AppConstants.topUpAmounts[i];
        final isDisabled = formState.isAmountDisabled(amount);
        return TopUpOptionCard(
          amount: amount,
          isSelected: formState.selectedAmount == amount,
          isDisabled: isDisabled,
          onTap: () {
            if (!isDisabled) {
              context.read<TopUpBloc>().add(SelectTopUpAmount(amount));
            }
          },
        );
      },
    );
  }

  Widget _buildFeeBreakdown(BuildContext context, TopUpFormReady formState) {
    final amount = formState.selectedAmount!;
    final total = amount + AppConstants.transactionFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _feeRow(context, 'Top-up Amount', 'AED ${amount.toStringAsFixed(0)}',
              false),
          const Divider(height: 20, color: AppColors.divider),
          _feeRow(context, 'Transaction Fee',
              'AED ${AppConstants.transactionFee.toStringAsFixed(0)}', false),
          const Divider(height: 20, color: AppColors.divider),
          _feeRow(context, 'Total Deducted', 'AED ${total.toStringAsFixed(2)}',
              true),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Balance After',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 12)),
              Text(
                'AED ${(formState.user.balance - total).toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _feeRow(
      BuildContext context, String label, String value, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                  color:
                      isBold ? AppColors.textPrimary : AppColors.textSecondary,
                )),
        Text(value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
                  color: isBold ? AppColors.primary : AppColors.textSecondary,
                )),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context, TopUpFormReady formState) {
    return CustomButton(
      onPressed: () {
        if (formState.selectedAmount != null) {
          context.read<TopUpBloc>().add(ExecuteTopUpEvent(
                beneficiaryId: formState.beneficiary.id,
                amount: formState.selectedAmount!,
              ));
        }
      },
      text:
          'Confirm Top Up AED ${(formState.selectedAmount! + AppConstants.transactionFee).toStringAsFixed(2)}',
    );
  }

  void _onStateChange(BuildContext context, TopUpState state) {
    if (state is TopUpSuccess) {
      context.read<UserBloc>().add(const LoadUser());
      context.read<BeneficiariesBloc>().add(const LoadBeneficiaries());
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'AED ${state.transaction.amount.toStringAsFixed(0)} topped up successfully!'),
        backgroundColor: AppColors.success,
      ));
    } else if (state is TopUpQueued) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Offline top-up queued and will sync when reconnected'),
        backgroundColor: AppColors.offline,
      ));
    } else if (state is TopUpError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(state.message),
        backgroundColor: AppColors.error,
      ));
    }
  }
}
