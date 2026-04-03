import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:topup/core/errors/failures.dart';
import 'package:topup/core/usecases/usecase.dart';
import 'package:topup/features/topup/domain/entities/top_up_transaction.dart';
import 'package:topup/features/topup/domain/usecases/execute_top_up.dart';
import 'package:topup/features/topup/domain/usecases/get_pending_top_ups.dart';
import 'package:topup/features/topup/domain/usecases/sync_pending_top_ups.dart';
import 'package:topup/features/topup/presentation/bloc/top_up_bloc.dart';
import 'package:topup/features/topup/presentation/bloc/top_up_event.dart';
import 'package:topup/features/topup/presentation/bloc/top_up_state.dart';

class MockExecuteTopUp extends Mock implements ExecuteTopUp {}
class MockGetPendingTopUps extends Mock implements GetPendingTopUps {}
class MockSyncPendingTopUps extends Mock implements SyncPendingTopUps {}

void main() {
  late MockExecuteTopUp mockExecuteTopUp;
  late MockGetPendingTopUps mockGetPendingTopUps;
  late MockSyncPendingTopUps mockSyncPendingTopUps;
  late TopUpBloc bloc;

  final tTransaction = TopUpTransaction(
    transactionId: 'txn_123',
    beneficiaryId: 'ben_001',
    amount: 50,
    fee: 3,
    timestamp: DateTime(2026, 4, 1),
  );

  final tQueuedTransaction = TopUpTransaction(
    transactionId: 'queued_123456',
    beneficiaryId: 'ben_001',
    amount: 50,
    fee: 3,
    timestamp: DateTime(2026, 4, 1),
  );

  setUp(() {
    mockExecuteTopUp = MockExecuteTopUp();
    mockGetPendingTopUps = MockGetPendingTopUps();
    mockSyncPendingTopUps = MockSyncPendingTopUps();
    bloc = TopUpBloc(
      executeTopUp: mockExecuteTopUp,
      getPendingTopUps: mockGetPendingTopUps,
      syncPendingTopUps: mockSyncPendingTopUps,
    );
    registerFallbackValue(
        const ExecuteTopUpParams(beneficiaryId: 'ben_001', amount: 50));
    registerFallbackValue(const NoParams());
  });

  tearDown(() => bloc.close());

  test('initial state is TopUpInitial', () {
    expect(bloc.state, const TopUpInitial());
  });

  blocTest<TopUpBloc, TopUpState>(
    'emits [Loading, Success] when ExecuteTopUpEvent succeeds',
    build: () {
      when(() => mockExecuteTopUp(any()))
          .thenAnswer((_) async => Right(tTransaction));
      return bloc;
    },
    act: (b) => b.add(const ExecuteTopUpEvent(
        beneficiaryId: 'ben_001', amount: 50)),
    expect: () => [
      const TopUpLoading(),
      TopUpSuccess(tTransaction),
    ],
  );

  blocTest<TopUpBloc, TopUpState>(
    'emits [Loading, Queued] when transaction is queued offline',
    build: () {
      when(() => mockExecuteTopUp(any()))
          .thenAnswer((_) async => Right(tQueuedTransaction));
      return bloc;
    },
    act: (b) => b.add(const ExecuteTopUpEvent(
        beneficiaryId: 'ben_001', amount: 50)),
    expect: () => [
      const TopUpLoading(),
      TopUpQueued(tQueuedTransaction),
    ],
  );

  blocTest<TopUpBloc, TopUpState>(
    'emits [Loading, Error] when ExecuteTopUpEvent fails',
    build: () {
      when(() => mockExecuteTopUp(any())).thenAnswer(
          (_) async => const Left(BusinessRuleFailure('Limit exceeded')));
      return bloc;
    },
    act: (b) => b.add(const ExecuteTopUpEvent(
        beneficiaryId: 'ben_001', amount: 50)),
    expect: () => [
      const TopUpLoading(),
      const TopUpError('Limit exceeded'),
    ],
  );

  blocTest<TopUpBloc, TopUpState>(
    'emits [Loading, Synced] when SyncPendingTopUpsEvent succeeds with items in queue',
    build: () {
      when(() => mockGetPendingTopUps(any()))
          .thenAnswer((_) async => Right([tQueuedTransaction]));
      when(() => mockSyncPendingTopUps(any()))
          .thenAnswer((_) async => const Right(null));
      return bloc;
    },
    act: (b) => b.add(const SyncPendingTopUpsEvent()),
    expect: () => [
      const TopUpLoading(),
      const TopUpSynced(),
    ],
  );

  blocTest<TopUpBloc, TopUpState>(
    'emits nothing when SyncPendingTopUpsEvent is added but queue is empty',
    build: () {
      when(() => mockGetPendingTopUps(any()))
          .thenAnswer((_) async => const Right([]));
      return bloc;
    },
    act: (b) => b.add(const SyncPendingTopUpsEvent()),
    expect: () => [],
    verify: (_) {
      verify(() => mockGetPendingTopUps(any())).called(1);
      verifyNever(() => mockSyncPendingTopUps(any()));
    },
  );

  blocTest<TopUpBloc, TopUpState>(
    'emits [Loading, Error] when SyncPendingTopUpsEvent indexing fails',
    build: () {
      when(() => mockGetPendingTopUps(any()))
          .thenAnswer((_) async => Right([tQueuedTransaction]));
      when(() => mockSyncPendingTopUps(any()))
          .thenAnswer((_) async => const Left(NetworkFailure('No internet')));
      return bloc;
    },
    act: (b) => b.add(const SyncPendingTopUpsEvent()),
    expect: () => [
      const TopUpLoading(),
      const TopUpError('No internet'),
    ],
  );

  blocTest<TopUpBloc, TopUpState>(
    'emits [Initial] when ResetTopUpEvent is added',
    build: () => bloc,
    seed: () => TopUpSuccess(tTransaction),
    act: (b) => b.add(const ResetTopUpEvent()),
    expect: () => [const TopUpInitial()],
  );
}
