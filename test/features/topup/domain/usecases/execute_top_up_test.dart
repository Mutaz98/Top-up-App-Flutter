import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:topup/core/constants/app_constants.dart';
import 'package:topup/core/errors/failures.dart';
import 'package:topup/core/usecases/usecase.dart';
import 'package:topup/features/beneficiaries/domain/entities/beneficiary.dart';
import 'package:topup/features/beneficiaries/domain/repositories/i_beneficiary_repository.dart';
import 'package:topup/features/topup/domain/entities/top_up_transaction.dart';
import 'package:topup/features/topup/domain/repositories/i_top_up_repository.dart';
import 'package:topup/features/topup/domain/usecases/execute_top_up.dart';
import 'package:topup/features/user/domain/entities/user.dart';
import 'package:topup/features/user/domain/repositories/i_user_repository.dart';

class MockUserRepository extends Mock implements IUserRepository {}

class MockBeneficiaryRepository extends Mock
    implements IBeneficiaryRepository {}

class MockTopUpRepository extends Mock implements ITopUpRepository {}

void main() {
  late MockUserRepository userRepository;
  late MockBeneficiaryRepository beneficiaryRepository;
  late MockTopUpRepository topUpRepository;
  late ExecuteTopUp useCase;

  const tBeneficiary = Beneficiary(
    id: 'ben_001',
    nickname: 'Mom',
    phoneNumber: '+971501234567',
    monthlyTopUpTotal: 0.0,
  );

  const tUnverifiedUser = User(
    id: 'user_001',
    name: 'Ahmed',
    balance: 2500.0,
    isVerified: false,
    monthlyTopUpTotal: 0.0,
  );

  const tVerifiedUser = User(
    id: 'user_001',
    name: 'Ahmed',
    balance: 2500.0,
    isVerified: true,
    monthlyTopUpTotal: 0.0,
  );

  final tTransaction = TopUpTransaction(
    transactionId: 'txn_1',
    beneficiaryId: 'ben_001',
    amount: 50,
    fee: AppConstants.transactionFee,
    timestamp: DateTime.now(),
  );

  setUp(() {
    userRepository = MockUserRepository();
    beneficiaryRepository = MockBeneficiaryRepository();
    topUpRepository = MockTopUpRepository();
    useCase = ExecuteTopUp(
      topUpRepository: topUpRepository,
      userRepository: userRepository,
      beneficiaryRepository: beneficiaryRepository,
    );
    registerFallbackValue(const NoParams());
  });

  void stubSuccess(
      {User user = tUnverifiedUser, Beneficiary ben = tBeneficiary}) {
    when(() => userRepository.getUser()).thenAnswer((_) async => Right(user));
    when(() => beneficiaryRepository.getBeneficiaryById('ben_001'))
        .thenAnswer((_) async => Right(ben));
    when(() => topUpRepository.executeTopUp(
          beneficiaryId: any(named: 'beneficiaryId'),
          amount: any(named: 'amount'),
        )).thenAnswer((_) async => Right(tTransaction));
  }

  test('succeeds for valid top-up', () async {
    stubSuccess();
    final result = await useCase(
        const ExecuteTopUpParams(beneficiaryId: 'ben_001', amount: 50));
    expect(result, Right(tTransaction));
  });

  test('fails with ValidationFailure for invalid amount', () async {
    final result = await useCase(
        const ExecuteTopUpParams(beneficiaryId: 'ben_001', amount: 999));
    result.fold(
        (f) => expect(f, isA<ValidationFailure>()), (_) => fail('should fail'));
  });

  test('fails with BusinessRuleFailure when balance insufficient', () async {
    const poorUser = User(
        id: 'u',
        name: 'T',
        balance: 2.0,
        isVerified: false,
        monthlyTopUpTotal: 0);
    when(() => userRepository.getUser())
        .thenAnswer((_) async => const Right(poorUser));

    final result = await useCase(
        const ExecuteTopUpParams(beneficiaryId: 'ben_001', amount: 50));
    result.fold((f) => expect(f, isA<BusinessRuleFailure>()),
        (_) => fail('should fail'));
  });

  test('fails when unverified monthly limit per beneficiary exceeded',
      () async {
    const nearLimitBen = Beneficiary(
        id: 'ben_001',
        nickname: 'Mom',
        phoneNumber: '+971501234567',
        monthlyTopUpTotal: 480);
    when(() => userRepository.getUser())
        .thenAnswer((_) async => const Right(tUnverifiedUser));
    when(() => beneficiaryRepository.getBeneficiaryById('ben_001'))
        .thenAnswer((_) async => const Right(nearLimitBen));

    // Trying to add AED 50 would exceed AED 500 (480 + 50 = 530)
    final result = await useCase(
        const ExecuteTopUpParams(beneficiaryId: 'ben_001', amount: 50));
    result.fold((f) => expect(f, isA<BusinessRuleFailure>()),
        (_) => fail('should fail'));
  });

  test('succeeds for verified user up to AED 1000 limit', () async {
    const nearLimitBen = Beneficiary(
        id: 'ben_001',
        nickname: 'Mom',
        phoneNumber: '+971501234567',
        monthlyTopUpTotal: 480);
    stubSuccess(user: tVerifiedUser, ben: nearLimitBen);

    // AED 50 — verified limit is 1000, so 480+50=530 is fine
    final result = await useCase(
        const ExecuteTopUpParams(beneficiaryId: 'ben_001', amount: 50));
    expect(result.isRight(), true);
  });

  test('fails when total monthly limit of AED 3000 exceeded', () async {
    const heavyUser = User(
        id: 'u',
        name: 'T',
        balance: 5000,
        isVerified: true,
        monthlyTopUpTotal: 2990);
    when(() => userRepository.getUser())
        .thenAnswer((_) async => const Right(heavyUser));
    when(() => beneficiaryRepository.getBeneficiaryById('ben_001'))
        .thenAnswer((_) async => const Right(tBeneficiary));

    // Adding AED 20 would put total at 3010 > 3000
    final result = await useCase(
        const ExecuteTopUpParams(beneficiaryId: 'ben_001', amount: 20));
    result.fold((f) => expect(f, isA<BusinessRuleFailure>()),
        (_) => fail('should fail'));
  });
}
