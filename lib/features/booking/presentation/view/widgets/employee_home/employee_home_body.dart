import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booking/core/localization/app_language.dart';
import 'package:booking/core/widgets/erp_card.dart';
import 'package:booking/core/widgets/error_retry_view.dart';
import '../../../manager/booking_cubit/booking_cubit.dart';
import 'employee_home_content.dart';

class EmployeeHomeBody extends StatelessWidget {
  const EmployeeHomeBody({super.key, required this.onCalendar});
  final VoidCallback onCalendar;

  @override
  Widget build(BuildContext context) => BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          if (state is BookingError) {
            return ErpPanel(
              child: ErrorRetryView(
                message: AppLanguage.text(
                    context, 'تعذّر تحميل الحجوزات', 'Unable to load bookings'),
                onRetry: () => context.read<BookingCubit>().getActiveBookings(),
              ),
            );
          }
          if (state is! BookingLoaded ||
              state.filter != BookingViewFilter.active) {
            return const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()));
          }
          return EmployeeHomeContent(
              bookings: state.bookings, onCalendar: onCalendar);
        },
      );
}
