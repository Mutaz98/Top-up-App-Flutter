import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:topup/app/theme/app_theme.dart';
import 'package:topup/features/beneficiaries/presentation/bloc/beneficiaries_bloc.dart';
import 'package:topup/features/topup/presentation/bloc/top_up_bloc.dart';
import 'package:topup/features/user/presentation/bloc/user_bloc.dart';
import 'package:topup/app/di/injection_container.dart';
import 'package:topup/app/router/app_router.dart';

class App extends StatelessWidget {
  final Stream<bool> connectivityStream;
  final bool initiallyConnected;

  const App({
    super.key,
    required this.connectivityStream,
    required this.initiallyConnected,
  });

  @override
  Widget build(BuildContext context) {
    final router = createAppRouter(
      connectivityStream: connectivityStream,
      initiallyConnected: initiallyConnected,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(create: (_) => sl<UserBloc>()),
        BlocProvider<BeneficiariesBloc>(create: (_) => sl<BeneficiariesBloc>()),
        BlocProvider<TopUpBloc>(create: (_) => sl<TopUpBloc>()),
      ],
      child: MaterialApp.router(
        title: 'UAE Top-Up',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: router,
      ),
    );
  }
}
