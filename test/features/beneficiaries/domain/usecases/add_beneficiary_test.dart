import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:topup/core/constants/app_constants.dart';
import 'package:topup/core/errors/failures.dart';
import 'package:topup/core/usecases/usecase.dart';
import 'package:topup/features/beneficiaries/domain/entities/beneficiary.dart';
import 'package:topup/features/beneficiaries/domain/repositories/i_beneficiary_repository.dart';
import 'package:topup/features/beneficiaries/domain/usecases/add_beneficiary.dart';

class MockBeneficiaryRepository extends Mock
    implements IBeneficiaryRepository {}

void main() {
  late MockBeneficiaryRepository repository;
  late AddBeneficiary useCase;

  const tNickname = 'Mom';
  const tPhone = '+971501234567';
  final tParams =
      const AddBeneficiaryParams(nickname: tNickname, phoneNumber: tPhone);

  const tBeneficiary = Beneficiary(
    id: 'ben_001',
    nickname: tNickname,
    phoneNumber: tPhone,
    monthlyTopUpTotal: 0.0,
  );

  setUp(() {
    repository = MockBeneficiaryRepository();
    useCase = AddBeneficiary(repository);
    registerFallbackValue(tBeneficiary);
    registerFallbackValue(const NoParams());
  });

  void stubEmpty() {
    when(() => repository.getBeneficiaries())
        .thenAnswer((_) async => const Right([]));
  }

  test('returns beneficiary when valid params and under limit', () async {
    stubEmpty();
    when(() => repository.addBeneficiary(any()))
        .thenAnswer((_) async => const Right(tBeneficiary));

    final result = await useCase(tParams);
    expect(result, const Right(tBeneficiary));
  });

  test('returns BusinessRuleFailure when 5 beneficiaries already exist',
      () async {
    final full = List.generate(
        AppConstants.maxBeneficiaries,
        (i) => Beneficiary(
            id: 'id$i',
            nickname: 'N$i',
            phoneNumber: '+97150000000$i',
            monthlyTopUpTotal: 0));
    when(() => repository.getBeneficiaries())
        .thenAnswer((_) async => Right(full));

    final result = await useCase(tParams);
    expect(result.isLeft(), true);
    result.fold((f) => expect(f, isA<BusinessRuleFailure>()), (_) {});
  });

  test('returns BusinessRuleFailure for duplicate phone number', () async {
    when(() => repository.getBeneficiaries())
        .thenAnswer((_) async => const Right([tBeneficiary]));

    final result = await useCase(tParams);
    expect(result.isLeft(), true);
    result.fold((f) => expect(f, isA<BusinessRuleFailure>()), (_) {});
  });
}
