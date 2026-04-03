import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topup/core/constants/app_constants.dart';
import 'package:topup/app/theme/app_theme.dart';
import 'package:topup/core/widgets/connectivity_banner.dart';
import 'package:topup/app/router/app_routes.dart';
import 'package:topup/features/beneficiaries/domain/entities/beneficiary.dart';
import 'package:topup/features/beneficiaries/presentation/bloc/beneficiaries_bloc.dart';
import 'package:topup/features/beneficiaries/presentation/bloc/beneficiaries_event.dart';
import 'package:topup/features/beneficiaries/presentation/bloc/beneficiaries_state.dart';
import 'package:topup/features/beneficiaries/presentation/widgets/add_beneficiary_bottom_sheet.dart';
import 'package:topup/features/beneficiaries/presentation/widgets/beneficiary_card.dart';
import 'package:topup/features/topup/presentation/bloc/top_up_bloc.dart';
import 'package:topup/features/topup/presentation/bloc/top_up_event.dart';
import 'package:topup/features/topup/presentation/bloc/top_up_state.dart';
import 'package:topup/features/user/domain/entities/user.dart';
import 'package:topup/features/user/presentation/bloc/user_bloc.dart';
import 'package:topup/features/user/presentation/bloc/user_event.dart';
import 'package:topup/features/user/presentation/bloc/user_state.dart';

class BeneficiariesPage extends StatefulWidget {
  final Stream<bool> connectivityStream;
  final bool initiallyConnected;

  const BeneficiariesPage({
    super.key,
    required this.connectivityStream,
    required this.initiallyConnected,
  });

  @override
  State<BeneficiariesPage> createState() => _BeneficiariesPageState();
}

class _BeneficiariesPageState extends State<BeneficiariesPage> {
  late final StreamSubscription<bool> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(const LoadUser());
    context.read<BeneficiariesBloc>().add(const LoadBeneficiaries());

    bool wasOffline = !widget.initiallyConnected;
    _connectivitySubscription = widget.connectivityStream.listen((connected) {
      if (connected && wasOffline) {
        if (!mounted) return;
        // Just reconnected! Trigger sync.
        context.read<TopUpBloc>().add(const SyncPendingTopUpsEvent());
        wasOffline = false;
      } else if (!connected) {
        wasOffline = true;
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<TopUpBloc, TopUpState>(
            listener: (context, state) {
              if (state is TopUpSynced) {
                context.read<UserBloc>().add(const LoadUser());
                context
                    .read<BeneficiariesBloc>()
                    .add(const LoadBeneficiaries());
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Pending top-ups synchronized!'),
                  backgroundColor: AppColors.success,
                ));
              } else if (state is TopUpError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Sync failed: ${state.message}'),
                  backgroundColor: AppColors.error,
                ));
              }
            },
          ),
        ],
        child: ConnectivityBanner(
          connectivityStream: widget.connectivityStream,
          initiallyConnected: widget.initiallyConnected,
          child: SafeArea(
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
                final user = userState is UserLoaded ? userState.user : null;
                return NestedScrollView(
                  headerSliverBuilder: (_, __) => [
                    SliverToBoxAdapter(child: _buildHeader(context, user)),
                    if (user != null)
                      SliverToBoxAdapter(
                          child: _buildBalanceCard(context, user)),
                  ],
                  body: BlocBuilder<BeneficiariesBloc, BeneficiariesState>(
                    builder: (context, state) =>
                        _buildBody(context, state, user),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget _buildHeader(BuildContext context, User? user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user != null
                    ? 'Hello, ${user.name.split(' ').first}'
                    : 'Top-Up',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'Manage your top-up beneficiaries',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          if (user != null)
            GestureDetector(
              onTap: () =>
                  context.read<UserBloc>().add(const ToggleVerification()),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: user.isVerified
                      ? AppColors.secondary.withOpacity(0.15)
                      : AppColors.divider,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: user.isVerified
                        ? AppColors.secondary
                        : AppColors.textMuted,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      user.isVerified
                          ? Icons.verified_rounded
                          : Icons.pending_outlined,
                      color: user.isVerified
                          ? AppColors.secondary
                          : AppColors.textMuted,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.isVerified ? 'Verified' : 'Unverified',
                      style: TextStyle(
                        color: user.isVerified
                            ? AppColors.secondary
                            : AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, User user) {
    final monthlyProgress =
        (user.monthlyTopUpTotal / AppConstants.totalMonthlyLimit)
            .clamp(0.0, 1.0)
            .toDouble();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2137), Color(0xFF0A3D2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Available Balance',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.primary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+ AED 3 fee per top-up',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 10, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'AED ${user.balance.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 36,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Total: AED ${user.monthlyTopUpTotal.toStringAsFixed(0)}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 11),
              ),
              Text(
                'Limit: AED ${AppConstants.totalMonthlyLimit.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                      color: monthlyProgress > 0.8
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
              value: monthlyProgress,
              minHeight: 5,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                monthlyProgress > 0.8 ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, BeneficiariesState state, User? user) {
    if (state is BeneficiariesLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    final beneficiaries = switch (state) {
      BeneficiariesLoaded(beneficiaries: final list) => list,
      BeneficiaryOperationInProgress(beneficiaries: final list) => list,
      BeneficiariesError(beneficiaries: final list) => list,
      _ => <Beneficiary>[],
    };

    if (beneficiaries.isEmpty) {
      return _buildEmptyState(context);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Beneficiaries (${beneficiaries.length}/${AppConstants.maxBeneficiaries})',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppColors.textSecondary, fontSize: 13),
              ),
              if (state is BeneficiaryOperationInProgress)
                const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: beneficiaries.length,
              itemBuilder: (ctx, i) {
                final b = beneficiaries[i];
                return BeneficiaryCard(
                  key: ValueKey(b.id),
                  beneficiary: b,
                  user: user ??
                      const User(
                        id: '',
                        name: '',
                        balance: 0,
                        isVerified: false,
                        monthlyTopUpTotal: 0,
                      ),
                  onTopUp: () => _navigateToTopUp(context, b, user),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline_rounded,
                color: AppColors.primary, size: 48),
          ),
          const SizedBox(height: 20),
          Text('No Beneficiaries Yet',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first\nUAE phone number to top up',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return BlocBuilder<BeneficiariesBloc, BeneficiariesState>(
      builder: (context, state) {
        final count = switch (state) {
          BeneficiariesLoaded(beneficiaries: final l) => l.length,
          BeneficiaryOperationInProgress(beneficiaries: final l) => l.length,
          _ => 0,
        };
        final isFull = count >= AppConstants.maxBeneficiaries;

        return FloatingActionButton.extended(
          onPressed: isFull
              ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Maximum 5 beneficiaries reached'),
                  ))
              : () => AddBeneficiaryBottomSheet.show(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add'),
          backgroundColor: isFull ? AppColors.textMuted : AppColors.primary,
          foregroundColor: Colors.black,
        );
      },
    );
  }

  void _navigateToTopUp(
      BuildContext context, Beneficiary beneficiary, User? user) {
    if (user == null) return;

    context.read<TopUpBloc>().add(InitializeTopUpForm(
          user: user,
          beneficiary: beneficiary,
        ));

    context.push(AppRoutes.topUp, extra: {
      'beneficiary': beneficiary,
      'user': user,
    });
  }
}
