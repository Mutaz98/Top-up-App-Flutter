import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topup/core/usecases/usecase.dart';
import 'package:topup/features/beneficiaries/domain/entities/beneficiary.dart';
import 'package:topup/features/beneficiaries/domain/usecases/add_beneficiary.dart';
import 'package:topup/features/beneficiaries/domain/usecases/delete_beneficiary.dart';
import 'package:topup/features/beneficiaries/domain/usecases/get_beneficiaries.dart';
import 'package:topup/features/beneficiaries/presentation/bloc/beneficiaries_event.dart';
import 'package:topup/features/beneficiaries/presentation/bloc/beneficiaries_state.dart';

class BeneficiariesBloc extends Bloc<BeneficiariesEvent, BeneficiariesState> {
  final GetBeneficiaries getBeneficiaries;
  final AddBeneficiary addBeneficiary;
  final DeleteBeneficiary deleteBeneficiary;

  BeneficiariesBloc({
    required this.getBeneficiaries,
    required this.addBeneficiary,
    required this.deleteBeneficiary,
  }) : super(const BeneficiariesInitial()) {
    on<LoadBeneficiaries>(_onLoad);
    on<AddBeneficiaryEvent>(_onAdd);
    on<DeleteBeneficiaryEvent>(_onDelete);
  }

  Future<void> _onLoad(
      LoadBeneficiaries event, Emitter<BeneficiariesState> emit) async {
    emit(const BeneficiariesLoading());
    final result = await getBeneficiaries(const NoParams());
    result.fold(
      (failure) => emit(BeneficiariesError(failure.message)),
      (list) => emit(BeneficiariesLoaded(list)),
    );
  }

  Future<void> _onAdd(
      AddBeneficiaryEvent event, Emitter<BeneficiariesState> emit) async {
    final current = _currentList;
    emit(BeneficiaryOperationInProgress(current));

    final result = await addBeneficiary(AddBeneficiaryParams(
      nickname: event.nickname,
      phoneNumber: event.phoneNumber,
    ));

    result.fold(
      (failure) => emit(BeneficiariesError(failure.message,
          beneficiaries: current)),
      (beneficiary) => emit(BeneficiariesLoaded([...current, beneficiary])),
    );
  }

  Future<void> _onDelete(
      DeleteBeneficiaryEvent event, Emitter<BeneficiariesState> emit) async {
    final current = _currentList;
    emit(BeneficiaryOperationInProgress(current));

    final result =
        await deleteBeneficiary(DeleteBeneficiaryParams(event.id));

    result.fold(
      (failure) => emit(BeneficiariesError(failure.message,
          beneficiaries: current)),
      (_) => emit(BeneficiariesLoaded(
          current.where((b) => b.id != event.id).toList())),
    );
  }

  List<Beneficiary> get _currentList {
    final s = state;
    if (s is BeneficiariesLoaded) return s.beneficiaries;
    if (s is BeneficiaryOperationInProgress) return s.beneficiaries;
    if (s is BeneficiariesError) return s.beneficiaries;
    return const <Beneficiary>[];
  }
}
