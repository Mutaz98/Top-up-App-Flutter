import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    log('Event added: $event', name: 'AppBlocObserver');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log('State changed: ${bloc.runtimeType}\nFrom: ${change.currentState}\nTo: ${change.nextState}',
        name: 'AppBlocObserver');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log('Transition: ${bloc.runtimeType}\nEvent: ${transition.event}\nState: ${transition.nextState}',
        name: 'AppBlocObserver');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log('Error in ${bloc.runtimeType}: $error',
        name: 'AppBlocObserver', error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
