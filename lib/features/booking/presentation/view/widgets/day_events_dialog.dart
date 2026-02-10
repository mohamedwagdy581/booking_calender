import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../data/models/booking_model.dart';
import '../../manager/booking_cubit/booking_cubit.dart';
import 'booking_details_dialog.dart';

class DayEventsDialog extends StatelessWidget {
  final DateTime day;
  final List<Booking> events;

  const DayEventsDialog({super.key, required this.day, required this.events});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Bookings for ${DateFormat.yMMMd().format(day)}'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: events.length,
          itemBuilder: (context, index) {
            final booking = events[index];
            return ListTile(
              title: Text(booking.title), // Use booking.title here
              subtitle: Text('${DateFormat.jm().format(booking.date)} - ${booking.hallName}'),
              onTap: () {
                final parentContext = context;
                Navigator.of(parentContext).pop(); // Close this dialog
                showDialog(
                  context: parentContext,
                  builder: (_) => BlocProvider.value(
                    value: parentContext.read<BookingCubit>(),
                    child: BookingDetailsDialog(booking: booking),
                  ),
                ); // Show the detailed one
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
