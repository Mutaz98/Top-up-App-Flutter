import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:topup/core/errors/failures.dart';
import 'package:topup/core/usecases/usecase.dart';
import 'package:topup/features/user/domain/entities/user.dart';
import 'package:topup/features/user/domain/usecases/get_user.dart';
import 'package:topup/features/user/presentation/bloc/user_bloc.dart';
import 'package:topup/features/user/presentation/bloc/user_event.dart';
import 'package:topup/features/user/presentation/bloc/user_state.dart';

class MockGetUser extends Mock implements GetUser {}

void main() {
  late MockGetUser mockGetUser;
  late UserBloc bloc;

  const tUser = User(
    id: 'user_001',
    name: 'Ahmed',
    balance: 2500.0,
    isVerified: false,
    monthlyTopUpTotal: 0.0,
  );

  setUp(() {
    mockGetUser = MockGetUser();
    bloc = UserBloc(getUser: mockGetUser);
    registerFallbackValue(const NoParams());
  });

  tearDown(() => bloc.close());

  test('initial state is UserInitial', () {
    expect(bloc.state, const UserInitial());
  });

  blocTest<UserBloc, UserState>(
    'emits [Loading, Loaded] when LoadUser succeeds',
    build: () {
      when(() => mockGetUser(any()))
          .thenAnswer((_) async => const Right(tUser));
      return bloc;
    },
    act: (b) => b.add(const LoadUser()),
    expect: () => [const UserLoading(), const UserLoaded(tUser)],
  );

  blocTest<UserBloc, UserState>(
    'emits [Loading, Error] when LoadUser fails',
    build: () {
      when(() => mockGetUser(any()))
          .thenAnswer((_) async => const Left(NetworkFailure('No connection')));
      return bloc;
    },
    act: (b) => b.add(const LoadUser()),
    expect: () => [
      const UserLoading(),
      const UserError('No connection'),
    ],
  );

  blocTest<UserBloc, UserState>(
    'emits toggled verification status when ToggleVerification is added',
    build: () => bloc,
    seed: () => const UserLoaded(tUser),
    act: (b) => b.add(const ToggleVerification()),
    expect: () => [
      UserLoaded(tUser.copyWith(isVerified: true)),
    ],
  );
}
