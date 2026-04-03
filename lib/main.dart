import 'package:flutter/material.dart';
import 'package:topup/app/app.dart';
import 'package:topup/core/cache/hive_initializer.dart';
import 'package:topup/core/network/connectivity_service.dart';
import 'package:topup/app/di/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topup/app/bloc/app_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await HiveInitializer.init();

  // Initialize DI
  await initDependencies();

  // Check initial connectivity
  final connectivityService = sl<ConnectivityService>();
  final initiallyConnected = await connectivityService.isConnected;

  // Set Global Bloc Observer
  Bloc.observer = AppBlocObserver();

  runApp(App(
    connectivityStream: connectivityService.connectivityStream,
    initiallyConnected: initiallyConnected,
  ));
}
