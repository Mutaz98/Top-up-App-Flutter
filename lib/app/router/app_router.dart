import 'package:go_router/go_router.dart';
import 'package:topup/features/beneficiaries/domain/entities/beneficiary.dart';
import 'package:topup/features/beneficiaries/presentation/pages/beneficiaries_page.dart';
import 'package:topup/features/topup/presentation/pages/top_up_page.dart';
import 'package:topup/features/user/domain/entities/user.dart';
import 'package:topup/app/router/app_routes.dart';

GoRouter createAppRouter({
  required Stream<bool> connectivityStream,
  required bool initiallyConnected,
}) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => BeneficiariesPage(
          connectivityStream: connectivityStream,
          initiallyConnected: initiallyConnected,
        ),
      ),
      GoRoute(
        path: AppRoutes.topUp,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra == null) {
            // Handle error case appropriately or fallback
            throw Exception(
                'Required extra parameters not provided for top-up route');
          }
          final beneficiary = extra['beneficiary'] as Beneficiary;
          final user = extra['user'] as User;

          return TopUpPage(
            beneficiary: beneficiary,
            user: user,
          );
        },
      ),
    ],
  );
}
