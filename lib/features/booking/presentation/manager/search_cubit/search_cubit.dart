import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/booking_model.dart';
import '../../../domain/repositories/booking_repository.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final BookingRepository _bookingRepository;

  SearchCubit(this._bookingRepository) : super(SearchInitial());

  Future<void> searchBookings(String query) async {
    if (query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      final results = await _bookingRepository.searchBookings(query);
      emit(SearchSuccess(results, query));
    } catch (e) {
      emit(SearchError('حدث خطأ أثناء البحث: $e'));
    }
  }

  void clearSearch() {
    emit(SearchInitial());
  }
}
