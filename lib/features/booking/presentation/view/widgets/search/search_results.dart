import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booking/core/constants/colors/app_colors.dart';
import '../../../manager/search_cubit/search_cubit.dart';
import 'search_result_card.dart';

class SearchResults extends StatelessWidget {
  const SearchResults({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.success));
          }
          if (state is SearchError) {
            return Center(
                child: Text(state.message,
                    style: const TextStyle(color: Colors.red, fontSize: 16)));
          }
          if (state is SearchSuccess && state.results.isNotEmpty) {
            return ListView.builder(
                itemCount: state.results.length,
                itemBuilder: (_, index) =>
                    SearchResultCard(booking: state.results[index]));
          }
          final empty = state is SearchSuccess;
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(empty ? Icons.search_off : Icons.manage_search,
                  size: 64, color: empty ? Colors.grey : AppColors.success),
              const SizedBox(height: 16),
              Text(
                  empty
                      ? 'لا توجد نتائج تطابق بحثك'
                      : 'ابدأ بالكتابة للبحث في العروض والحجوزات',
                  style: const TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ));
        },
      );
}
