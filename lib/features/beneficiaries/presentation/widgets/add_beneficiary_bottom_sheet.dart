import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topup/app/theme/app_theme.dart';
import 'package:topup/features/beneficiaries/presentation/bloc/beneficiaries_bloc.dart';
import 'package:topup/features/beneficiaries/presentation/bloc/beneficiaries_event.dart';
import 'package:topup/features/beneficiaries/presentation/bloc/beneficiaries_state.dart';
import 'package:topup/core/widgets/custom_button.dart';
import 'package:topup/core/widgets/custom_text_field.dart';

class AddBeneficiaryBottomSheet extends StatefulWidget {
  const AddBeneficiaryBottomSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => BlocProvider.value(
          value: context.read<BeneficiariesBloc>(),
          child: const AddBeneficiaryBottomSheet(),
        ),
      );

  @override
  State<AddBeneficiaryBottomSheet> createState() =>
      _AddBeneficiaryBottomSheetState();
}

class _AddBeneficiaryBottomSheetState extends State<AddBeneficiaryBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  int _nicknameLength = 0;

  @override
  void dispose() {
    _nicknameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BeneficiariesBloc, BeneficiariesState>(
      listener: (context, state) {
        if (state is BeneficiariesLoaded) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Beneficiary added successfully'),
            backgroundColor: AppColors.success,
          ));
        } else if (state is BeneficiariesError) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
          ));
        }
      },
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text('Add Beneficiary',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text('Add a UAE phone number to top up',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),

                  // Nickname
                  CustomTextField(
                    controller: _nicknameController,
                    maxLength: 20,
                    labelText: 'Nickname',
                    prefixIcon: const Icon(Icons.person_outline_rounded,
                        color: AppColors.primary),
                    counterText: '$_nicknameLength/20',
                    counterStyle: TextStyle(
                      color: _nicknameLength == 20
                          ? AppColors.error
                          : AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    onChanged: (v) =>
                        setState(() => _nicknameLength = v.length),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter a nickname';
                      }
                      if (v.length > 20) return 'Max 20 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone number
                  CustomTextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))
                    ],
                    labelText: 'UAE Phone Number',
                    hintText: '+9710000000000',
                    prefixIcon: const Icon(Icons.phone_outlined,
                        color: AppColors.primary),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      final regex = RegExp(r'^(\+971|0)(5[0-9])\d{7}$');
                      if (!regex.hasMatch(v)) {
                        return 'Enter a valid UAE number (e.g. +9710000000000)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  BlocBuilder<BeneficiariesBloc, BeneficiariesState>(
                    builder: (context, state) {
                      return CustomButton(
                        onPressed: _submit,
                        isLoading: state is BeneficiaryOperationInProgress,
                        text: 'Add Beneficiary',
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<BeneficiariesBloc>().add(AddBeneficiaryEvent(
            nickname: _nicknameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
          ));
    }
  }
}
