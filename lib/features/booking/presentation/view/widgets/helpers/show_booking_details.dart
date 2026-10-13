import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booking/features/booking/presentation/manager/booking_cubit/booking_cubit.dart';
import '../../../../data/models/booking_model.dart';
import '../booking_details_dialog.dart';

void showBookingDetails(BuildContext context, Booking booking) {
  final cubit = context.read<BookingCubit>();
  showDialog<void>(
    context: context,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: BookingDetailsDialog(booking: booking),
    ),
  );
}
