import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../manager/booking_cubit/booking_cubit.dart';
import 'widgets/employee_home/employee_home_header.dart';
import 'widgets/employee_home/employee_home_body.dart';

class EmployeeHomeView extends StatefulWidget {
  const EmployeeHomeView({
    super.key,
    required this.displayName,
    required this.onSearch,
    required this.onCalendar,
    required this.onProfile,
  });

  final String displayName;
  final VoidCallback onSearch;
  final VoidCallback onCalendar;
  final VoidCallback onProfile;

  @override
  State<EmployeeHomeView> createState() => _EmployeeHomeViewState();
}

class _EmployeeHomeViewState extends State<EmployeeHomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<BookingCubit>();
      final state = cubit.state;
      if (state is! BookingLoading &&
          !(state is BookingLoaded &&
              state.filter == BookingViewFilter.active)) {
        cubit.getActiveBookings();
      }
    });
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Padding(
              padding: EdgeInsets.all(
                  MediaQuery.sizeOf(context).width < 600 ? 16 : 24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EmployeeHomeHeader(
                        displayName: widget.displayName,
                        onSearch: widget.onSearch,
                        onProfile: widget.onProfile,
                        onRefresh: () =>
                            context.read<BookingCubit>().getActiveBookings()),
                    const SizedBox(height: 28),
                    EmployeeHomeBody(onCalendar: widget.onCalendar),
                  ]),
            ),
          ),
        ),
      );
}
