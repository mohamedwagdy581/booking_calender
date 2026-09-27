import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/services/service_locator.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../data/models/booking_model.dart';
import '../manager/search_cubit/search_cubit.dart';
import 'widgets/booking_details_dialog.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  late SearchCubit _searchCubit;

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

  void _onSearchChanged(String query) {
    _searchCubit.searchBookings(query);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'البحث المتقدم',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                // في حالة الديسك توب، لو ضغط رجوع وهو في التابة، بنرجعه للشاشة الرئيسية
                context.go(AppRoutes.home);
              }
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Input Field
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'ابحث باسم العميل، الرقم المرجعي، الجوال، القاعة...',
                  hintTextDirection: TextDirection.rtl,
                  prefixIcon: const Icon(Icons.search, color: AppColors.success),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _searchCubit.clearSearch();
                    },
                  ),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: AppColors.success, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Search Results Builder
              Expanded(
                child: BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    if (state is SearchLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.success),
                      );
                    }

                    if (state is SearchError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      );
                    }

                    if (state is SearchSuccess) {
                      if (state.results.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'لا توجد نتائج تطابق بحثك',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: state.results.length,
                        itemBuilder: (context, index) {
                          final booking = state.results[index];
                          return _buildBookingResultCard(context, booking);
                        },
                      );
                    }

                    // SearchInitial State
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.manage_search, size: 64, color: AppColors.success),
                          SizedBox(height: 16),
                          Text(
                            'ابدأ بالكتابة للبحث في العروض والحجوزات',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingResultCard(BuildContext context, Booking booking) {
    final formattedDate = DateFormat('yyyy/MM/dd', 'ar').format(booking.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => BookingDetailsDialog(booking: booking),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: booking.isArchived
                          ? Colors.orange.withOpacity(0.1)
                          : AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      booking.isArchived ? 'مؤرشف' : 'نشط',
                      style: TextStyle(
                        color: booking.isArchived ? Colors.orange : AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    booking.refNumber ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Text(
                booking.clientName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    booking.title,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.title, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${booking.hallName} - ${booking.artistName}',
                    style: TextStyle(
                      color: AppColors.success.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.success),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                ],
              ),
              if (booking.phoneNumber.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      booking.phoneNumber,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
