import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/app_router.dart';
import '../manager/search_cubit/search_cubit.dart';
import 'widgets/search/search_input.dart';
import 'widgets/search/search_results.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});
  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _searchController = TextEditingController();
  late final SearchCubit _searchCubit;

  @override
  void initState() {
    super.initState();
    _searchCubit = sl<SearchCubit>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
        value: _searchCubit,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('البحث المتقدم',
                style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRoutes.home)),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              SearchInput(
                  controller: _searchController,
                  onChanged: _searchCubit.searchBookings,
                  onClear: () {
                    _searchController.clear();
                    _searchCubit.clearSearch();
                  }),
              const SizedBox(height: 16),
              const Expanded(child: SearchResults()),
            ]),
          ),
        ),
      );
}
