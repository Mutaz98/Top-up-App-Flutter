import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:topup/core/errors/failures.dart';
import 'package:topup/features/beneficiaries/domain/repositories/i_beneficiary_repository.dart';
import 'package:topup/features/beneficiaries/domain/usecases/delete_beneficiary.dart';

class MockBeneficiaryRepository extends Mock
    implements IBeneficiaryRepository {}

void main() {
  late MockBeneficiaryRepository repository;
  late DeleteBeneficiary useCase;

  setUp(() {
    repository = MockBeneficiaryRepository();
    useCase = DeleteBeneficiary(repository);
  });

  const tId = 'ben_001';
  final tParams = const DeleteBeneficiaryParams(tId);

  test('calls repository.deleteBeneficiary with the correct id', () async {
    when(() => repository.deleteBeneficiary(tId))
        .thenAnswer((_) async => const Right(null));

    final result = await useCase(tParams);

    expect(result, const Right(null));
    verify(() => repository.deleteBeneficiary(tId)).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns failure when repository throws a ServerFailure', () async {
    when(() => repository.deleteBeneficiary(tId))
        .thenAnswer((_) async => const Left(ServerFailure('Delete failed')));

    final result = await useCase(tParams);

    expect(result.isLeft(), true);
    result.fold(
      (f) => expect(f, isA<ServerFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('returns failure when repository throws a NetworkFailure', () async {
    when(() => repository.deleteBeneficiary(tId))
        .thenAnswer((_) async => const Left(NetworkFailure('No internet')));

    final result = await useCase(tParams);

    expect(result.isLeft(), true);
    result.fold(
      (f) => expect(f, isA<NetworkFailure>()),
      (_) => fail('Expected Left'),
    );
  });
}
