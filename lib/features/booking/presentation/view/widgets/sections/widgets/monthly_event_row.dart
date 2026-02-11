import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../data/models/booking_model.dart';

class MonthlyEventRow extends StatelessWidget {
  const MonthlyEventRow({
    super.key,
    required this.booking,
  });

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            DateFormat('dd/MM  hh:mm a').format(booking.date),
            style: textTheme.bodySmall,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${booking.clientName} - ${booking.hallName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          child: Text(
            booking.artistName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
