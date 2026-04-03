import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:topup/core/network/connectivity_service.dart';
import 'package:topup/core/network/http_client.dart';
import 'package:topup/core/network/mock_http_client.dart';
import 'package:topup/features/beneficiaries/data/datasources/beneficiary_local_datasource.dart';
import 'package:topup/features/beneficiaries/data/datasources/beneficiary_remote_datasource.dart';
import 'package:topup/features/beneficiaries/data/repositories/beneficiary_repository.dart';
import 'package:topup/features/beneficiaries/domain/repositories/i_beneficiary_repository.dart';
import 'package:topup/features/beneficiaries/domain/usecases/add_beneficiary.dart';
import 'package:topup/features/beneficiaries/domain/usecases/delete_beneficiary.dart';
import 'package:topup/features/beneficiaries/domain/usecases/get_beneficiaries.dart';
import 'package:topup/features/beneficiaries/presentation/bloc/beneficiaries_bloc.dart';
import 'package:topup/features/topup/data/datasources/top_up_local_datasource.dart';
import 'package:topup/features/topup/data/datasources/top_up_remote_datasource.dart';
import 'package:topup/features/topup/data/repositories/top_up_repository.dart';
import 'package:topup/features/topup/domain/repositories/i_top_up_repository.dart';
import 'package:topup/features/topup/domain/usecases/execute_top_up.dart';
import 'package:topup/features/topup/domain/usecases/get_pending_top_ups.dart';
import 'package:topup/features/topup/domain/usecases/sync_pending_top_ups.dart';
import 'package:topup/features/topup/presentation/bloc/top_up_bloc.dart';
import 'package:topup/features/user/data/datasources/user_local_datasource.dart';
import 'package:topup/features/user/data/datasources/user_remote_datasource.dart';
import 'package:topup/features/user/data/repositories/user_repository.dart';
import 'package:topup/features/user/domain/repositories/i_user_repository.dart';
import 'package:topup/features/user/domain/usecases/get_user.dart';
import 'package:topup/features/user/presentation/bloc/user_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  _initExternal();
  _initDataSources();
  _initRepositories();
  _initUseCases();
  _initBlocs();
}

void _initExternal() {
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<HttpClient>(() => MockHttpClient());
  sl.registerLazySingleton<ConnectivityService>(
      () => ConnectivityService(connectivity: sl()));
}

void _initDataSources() {
  sl.registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<UserLocalDataSource>(
      () => UserLocalDataSourceImpl());

  sl.registerLazySingleton<BeneficiaryRemoteDataSource>(
      () => BeneficiaryRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<BeneficiaryLocalDataSource>(
      () => BeneficiaryLocalDataSourceImpl());

  sl.registerLazySingleton<TopUpRemoteDataSource>(
      () => TopUpRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<TopUpLocalDataSource>(
      () => TopUpLocalDataSourceImpl());
}

void _initRepositories() {
  sl.registerLazySingleton<IUserRepository>(() => UserRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        connectivityService: sl(),
      ));

  sl.registerLazySingleton<IBeneficiaryRepository>(
      () => BeneficiaryRepositoryImpl(
            remoteDataSource: sl(),
            localDataSource: sl(),
            connectivityService: sl(),
          ));

  sl.registerLazySingleton<ITopUpRepository>(() => TopUpRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        connectivityService: sl(),
      ));
}

void _initUseCases() {
  sl.registerLazySingleton(() => GetUser(sl()));
  sl.registerLazySingleton(() => GetBeneficiaries(sl()));
  sl.registerLazySingleton(() => AddBeneficiary(sl()));
  sl.registerLazySingleton(() => DeleteBeneficiary(sl()));
  sl.registerLazySingleton(() => ExecuteTopUp(
        topUpRepository: sl(),
        userRepository: sl(),
        beneficiaryRepository: sl(),
      ));
  sl.registerLazySingleton(() => SyncPendingTopUps(sl()));
  sl.registerLazySingleton(() => GetPendingTopUps(sl()));
}

void _initBlocs() {
  sl.registerLazySingleton(() => UserBloc(getUser: sl()));
  sl.registerLazySingleton(() => BeneficiariesBloc(
        getBeneficiaries: sl(),
        addBeneficiary: sl(),
        deleteBeneficiary: sl(),
      ));
  // TopUpBloc is registered as factory (fresh instance per page)
  sl.registerFactory(() => TopUpBloc(
        executeTopUp: sl(),
        syncPendingTopUps: sl(),
        getPendingTopUps: sl(),
      ));
}
