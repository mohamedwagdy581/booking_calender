
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../../../../core/constants/constants.dart';
import '../../../../../core/storage/cache_helper.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> checkFirstTime() async {
    emit(SplashLoading());

    final isFirstTime = CacheHelper.getBool(key: 'isFirstTime') ?? true;
    final token = CacheHelper.getString(key: kAccessToken);

    await Future.delayed(const Duration(seconds: 2));

    if (isFirstTime) {
      await CacheHelper.saveBool(key: 'isFirstTime', value: false);
      emit(SplashNavigateToSignin()); // If First Time Go to Onboarding
    } else if (token != null && token.isNotEmpty) {
      emit(SplashNavigateToHome()); // If Logged in Go to Home
    } else {
      emit(SplashNavigateToSignin()); // If Not Logged in and not first time Go to Login
    }
  }
}
