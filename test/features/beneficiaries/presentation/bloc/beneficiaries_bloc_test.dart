import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:topup/core/errors/failures.dart';
import 'package:topup/core/usecases/usecase.dart';
import 'package:topup/features/beneficiaries/domain/entities/beneficiary.dart';
import 'package:topup/features/beneficiaries/domain/usecases/add_beneficiary.dart';
import 'package:topup/features/beneficiaries/domain/usecases/delete_beneficiary.dart';
import 'package:topup/features/beneficiaries/domain/usecases/get_beneficiaries.dart';
import 'package:topup/features/beneficiaries/presentation/bloc/beneficiaries_bloc.dart';
import 'package:topup/features/beneficiaries/presentation/bloc/beneficiaries_event.dart';
import 'package:topup/features/beneficiaries/presentation/bloc/beneficiaries_state.dart';

class MockGetBeneficiaries extends Mock implements GetBeneficiaries {}
class MockAddBeneficiary extends Mock implements AddBeneficiary {}
class MockDeleteBeneficiary extends Mock implements DeleteBeneficiary {}

void main() {
  late MockGetBeneficiaries mockGet;
  late MockAddBeneficiary mockAdd;
  late MockDeleteBeneficiary mockDelete;
  late BeneficiariesBloc bloc;

  const tBeneficiary = Beneficiary(
    id: 'ben_001',
    nickname: 'Mom',
    phoneNumber: '+971501234567',
    monthlyTopUpTotal: 0.0,
  );

  setUp(() {
    mockGet = MockGetBeneficiaries();
    mockAdd = MockAddBeneficiary();
    mockDelete = MockDeleteBeneficiary();
    bloc = BeneficiariesBloc(
      getBeneficiaries: mockGet,
      addBeneficiary: mockAdd,
      deleteBeneficiary: mockDelete,
    );
    registerFallbackValue(const NoParams());
    registerFallbackValue(const AddBeneficiaryParams(nickname: 'X', phoneNumber: '+971501234567'));
    registerFallbackValue(const DeleteBeneficiaryParams('id'));
  });

  tearDown(() => bloc.close());

  blocTest<BeneficiariesBloc, BeneficiariesState>(
    'emits [Loading, Loaded] on successful load',
    build: () {
      when(() => mockGet(any()))
          .thenAnswer((_) async => const Right([tBeneficiary]));
      return bloc;
    },
    act: (b) => b.add(const LoadBeneficiaries()),
    expect: () => [
      const BeneficiariesLoading(),
      const BeneficiariesLoaded([tBeneficiary]),
    ],
  );

  blocTest<BeneficiariesBloc, BeneficiariesState>(
    'emits [Loading, Error] on failed load',
    build: () {
      when(() => mockGet(any()))
          .thenAnswer((_) async => const Left(NetworkFailure('Error')));
      return bloc;
    },
    act: (b) => b.add(const LoadBeneficiaries()),
    expect: () => [
      const BeneficiariesLoading(),
      const BeneficiariesError('Error'),
    ],
  );

  blocTest<BeneficiariesBloc, BeneficiariesState>(
    'emits updated list when Add succeeds',
    build: () {
      when(() => mockAdd(any()))
          .thenAnswer((_) async => const Right(tBeneficiary));
      return bloc;
    },
    seed: () => const BeneficiariesLoaded([]),
    act: (b) => b.add(const AddBeneficiaryEvent(
        nickname: 'Mom', phoneNumber: '+971501234567')),
    expect: () => [
      const BeneficiaryOperationInProgress([]),
      const BeneficiariesLoaded([tBeneficiary]),
    ],
  );

  blocTest<BeneficiariesBloc, BeneficiariesState>(
    'emits error with existing list when Add fails',
    build: () {
      when(() => mockAdd(any())).thenAnswer(
          (_) async => const Left(BusinessRuleFailure('Max reached')));
      return bloc;
    },
    seed: () => const BeneficiariesLoaded([tBeneficiary]),
    act: (b) => b.add(const AddBeneficiaryEvent(
        nickname: 'X', phoneNumber: '+971509999999')),
    expect: () => [
      const BeneficiaryOperationInProgress([tBeneficiary]),
      const BeneficiariesError('Max reached', beneficiaries: [tBeneficiary]),
    ],
  );

  blocTest<BeneficiariesBloc, BeneficiariesState>(
    'removes beneficiary from list when Delete succeeds',
    build: () {
      when(() => mockDelete(any()))
          .thenAnswer((_) async => const Right(null));
      return bloc;
    },
    seed: () => const BeneficiariesLoaded([tBeneficiary]),
    act: (b) => b.add(const DeleteBeneficiaryEvent('ben_001')),
    expect: () => [
      const BeneficiaryOperationInProgress([tBeneficiary]),
      const BeneficiariesLoaded([]),
    ],
  );
}
