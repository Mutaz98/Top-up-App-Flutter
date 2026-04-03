import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:topup/core/errors/failures.dart';
import 'package:topup/core/usecases/usecase.dart';
import 'package:topup/features/user/domain/entities/user.dart';
import 'package:topup/features/user/domain/repositories/i_user_repository.dart';
import 'package:topup/features/user/domain/usecases/get_user.dart';

class MockUserRepository extends Mock implements IUserRepository {}

void main() {
  late MockUserRepository repository;
  late GetUser useCase;

  setUp(() {
    repository = MockUserRepository();
    useCase = GetUser(repository);
  });

  const tUser = User(
    id: 'user_001',
    name: 'Ahmed Al Rashid',
    balance: 2500.0,
    isVerified: false,
    monthlyTopUpTotal: 0.0,
  );

  test('returns user on success', () async {
    when(() => repository.getUser())
        .thenAnswer((_) async => const Right(tUser));

    final result = await useCase(const NoParams());

    expect(result, const Right(tUser));
    verify(() => repository.getUser()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('returns verified user correctly', () async {
    const verifiedUser = User(
      id: 'user_001',
      name: 'Ahmed Al Rashid',
      balance: 2500.0,
      isVerified: true,
      monthlyTopUpTotal: 300.0,
    );
    when(() => repository.getUser())
        .thenAnswer((_) async => const Right(verifiedUser));

    final result = await useCase(const NoParams());

    expect(result.isRight(), true);
    result.fold(
      (_) => fail('Expected Right'),
      (user) {
        expect(user.isVerified, true);
        expect(user.monthlyTopUpTotal, 300.0);
      },
    );
  });

  test('returns NetworkFailure on network error', () async {
    when(() => repository.getUser())
        .thenAnswer((_) async => const Left(NetworkFailure('No connection')));

    final result = await useCase(const NoParams());

    expect(result.isLeft(), true);
    result.fold(
      (f) => expect(f, isA<NetworkFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('returns ServerFailure on server error', () async {
    when(() => repository.getUser())
        .thenAnswer((_) async => const Left(ServerFailure('Server error')));

    final result = await useCase(const NoParams());

    expect(result.isLeft(), true);
    result.fold(
      (f) => expect(f, isA<ServerFailure>()),
      (_) => fail('Expected Left'),
    );
  });

  test('returns CacheFailure on cache error', () async {
    when(() => repository.getUser())
        .thenAnswer((_) async => const Left(CacheFailure('Cache error')));

    final result = await useCase(const NoParams());

    expect(result.isLeft(), true);
    result.fold(
      (f) => expect(f, isA<CacheFailure>()),
      (_) => fail('Expected Left'),
    );
  });
}
