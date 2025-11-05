import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/login/data/repositories/auth_repository_impl.dart';
import '../../features/auth/login/domain/repositories/auth_repository.dart';
import '../../features/auth/login/presentation/manager/auth_cubit/auth_cubit.dart';
import '../../features/booking/data/repositories/booking_repository_impl.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/booking/presentation/manager/booking_cubit/booking_cubit.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // Supabase
  sl.registerSingleton<SupabaseClient>(Supabase.instance.client);

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(supabaseClient: sl()),
  );
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(supabaseClient: sl()),
  );

  // Cubits
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(sl()));
  sl.registerFactory<BookingCubit>(
    () => BookingCubit(sl()),
  );
}
