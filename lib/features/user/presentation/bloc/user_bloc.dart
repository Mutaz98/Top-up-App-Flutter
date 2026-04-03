import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topup/core/usecases/usecase.dart';
import 'package:topup/features/user/domain/usecases/get_user.dart';
import 'package:topup/features/user/presentation/bloc/user_event.dart';
import 'package:topup/features/user/presentation/bloc/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUser getUser;

  UserBloc({required this.getUser}) : super(const UserInitial()) {
    on<LoadUser>(_onLoadUser);
    on<ToggleVerification>(_onToggleVerification);
  }

  Future<void> _onLoadUser(LoadUser event, Emitter<UserState> emit) async {
    emit(const UserLoading());
    final result = await getUser(const NoParams());
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (user) => emit(UserLoaded(user)),
    );
  }

  Future<void> _onToggleVerification(
      ToggleVerification event, Emitter<UserState> emit) async {
    final current = state;
    if (current is UserLoaded) {
      final updated = current.user.copyWith(
        isVerified: !current.user.isVerified,
      );
      emit(UserLoaded(updated));
    }
  }
}
