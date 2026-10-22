import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/booking_model.dart';
import '../../../domain/repositories/booking_repository.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final BookingRepository _bookingRepository;
  int _request = 0;

  SearchCubit(this._bookingRepository) : super(SearchInitial());

  Future<void> searchBookings(String query) async {
    if (isClosed) return;
    final request = ++_request;
    if (query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      final results = await _bookingRepository.searchBookings(query);
      if (isClosed || request != _request) return;
      emit(SearchSuccess(results, query));
    } catch (e) {
      if (isClosed || request != _request) return;
      emit(SearchError('حدث خطأ أثناء البحث: $e'));
    }
  }

  void clearSearch() {
    ++_request;
    if (isClosed) return;
    emit(SearchInitial());
  }
}
