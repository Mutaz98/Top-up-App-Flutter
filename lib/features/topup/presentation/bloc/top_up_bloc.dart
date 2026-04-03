import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topup/features/topup/domain/usecases/execute_top_up.dart';
import 'package:topup/features/topup/domain/usecases/get_pending_top_ups.dart';
import 'package:topup/features/topup/domain/usecases/sync_pending_top_ups.dart';
import 'package:topup/features/topup/presentation/bloc/top_up_event.dart';
import 'package:topup/features/topup/presentation/bloc/top_up_state.dart';
import 'package:topup/core/usecases/usecase.dart';

class TopUpBloc extends Bloc<TopUpEvent, TopUpState> {
  final ExecuteTopUp executeTopUp;
  final SyncPendingTopUps syncPendingTopUps;
  final GetPendingTopUps getPendingTopUps;

  TopUpBloc({
    required this.executeTopUp,
    required this.syncPendingTopUps,
    required this.getPendingTopUps,
  }) : super(const TopUpInitial()) {
    on<InitializeTopUpForm>(_onInitializeForm);
    on<SelectTopUpAmount>(_onSelectAmount);
    on<ExecuteTopUpEvent>(_onExecute);
    on<SyncPendingTopUpsEvent>(_onSync);
    on<ResetTopUpEvent>(_onReset);
  }

  void _onInitializeForm(InitializeTopUpForm event, Emitter<TopUpState> emit) {
    emit(TopUpFormReady(
      user: event.user,
      beneficiary: event.beneficiary,
      selectedAmount: null,
    ));
  }

  void _onSelectAmount(SelectTopUpAmount event, Emitter<TopUpState> emit) {
    if (state is TopUpFormReady) {
      final current = state as TopUpFormReady;
      emit(current.copyWith(selectedAmount: event.amount));
    }
  }

  Future<void> _onExecute(
      ExecuteTopUpEvent event, Emitter<TopUpState> emit) async {
    emit(const TopUpLoading());
    final result = await executeTopUp(ExecuteTopUpParams(
      beneficiaryId: event.beneficiaryId,
      amount: event.amount,
    ));

    result.fold(
      (failure) => emit(TopUpError(failure.message)),
      (txn) {
        if (txn.transactionId.startsWith('queued_')) {
          emit(TopUpQueued(txn));
        } else {
          emit(TopUpSuccess(txn));
        }
      },
    );
  }

  Future<void> _onSync(
      SyncPendingTopUpsEvent event, Emitter<TopUpState> emit) async {
    final pendingResult = await getPendingTopUps(const NoParams());
    final hasPending =
        pendingResult.fold((_) => false, (list) => list.isNotEmpty);

    if (!hasPending) return;

    emit(const TopUpLoading());
    final result = await syncPendingTopUps(const NoParams());
    result.fold(
      (failure) => emit(TopUpError(failure.message)),
      (_) => emit(const TopUpSynced()),
    );
  }

  Future<void> _onReset(ResetTopUpEvent event, Emitter<TopUpState> emit) async {
    emit(const TopUpInitial());
  }
}
