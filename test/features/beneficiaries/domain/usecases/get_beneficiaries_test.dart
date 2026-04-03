import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:topup/core/errors/failures.dart';
import 'package:topup/core/usecases/usecase.dart';
import 'package:topup/features/beneficiaries/domain/entities/beneficiary.dart';
import 'package:topup/features/beneficiaries/domain/repositories/i_beneficiary_repository.dart';
import 'package:topup/features/beneficiaries/domain/usecases/get_beneficiaries.dart';

class MockBeneficiaryRepository extends Mock
    implements IBeneficiaryRepository {}

void main() {
  late MockBeneficiaryRepository repository;
  late GetBeneficiaries useCase;

  setUp(() {
    repository = MockBeneficiaryRepository();
    useCase = GetBeneficiaries(repository);
  });

  const tBeneficiaries = [
    Beneficiary(
      id: 'ben_001',
      nickname: 'Mom',
      phoneNumber: '+971501234567',
      monthlyTopUpTotal: 150.0,
    ),
    Beneficiary(
      id: 'ben_002',
      nickname: 'Office',
      phoneNumber: '+971509876543',
      monthlyTopUpTotal: 0.0,
    ),
  ];

  test('returns list of beneficiaries on success', () async {
    when(() => repository.getBeneficiaries())
        .thenAnswer((_) async => const Right(tBeneficiaries));

    final result = await useCase(const NoParams());

    expect(result, const Right(tBeneficiaries));
    verify(() => repository.getBeneficiaries()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns empty list when no beneficiaries exist', () async {
    when(() => repository.getBeneficiaries())
        .thenAnswer((_) async => const Right([]));

    final result = await useCase(const NoParams());

    expect(result, const Right(<Beneficiary>[]));
  });

  test('returns NetworkFailure on network error', () async {
    when(() => repository.getBeneficiaries())
        .thenAnswer((_) async => const Left(NetworkFailure('No connection')));

    final result = await useCase(const NoParams());

    expect(result.isLeft(), true);
    result.fold(
      (f) => expect(f, isA<NetworkFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('returns ServerFailure on server error', () async {
    when(() => repository.getBeneficiaries())
        .thenAnswer((_) async => const Left(ServerFailure('Server error')));

    final result = await useCase(const NoParams());

    expect(result.isLeft(), true);
    result.fold(
      (f) => expect(f, isA<ServerFailure>()),
      (_) => fail('Expected Left'),
    );
  });
}
