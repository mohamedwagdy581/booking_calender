import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/constants/assets/app_assets.dart';
import '../../../../data/models/booking_model.dart';

class BookingDetailsContentSection extends StatelessWidget {
  const BookingDetailsContentSection({
    super.key,
    required this.booking,
  });

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListBody(
      children: [
        if (booking.refNumber != null)
          _buildDetailRow(
            context,
            '\u0627\u0644\u0631\u0642\u0645 \u0627\u0644\u0645\u0631\u062c\u0639\u064a',
            booking.refNumber!,
          ),
        _buildDetailRow(context, '\u0627\u0633\u0645 \u0627\u0644\u0639\u0645\u064a\u0644', booking.clientName),
        _buildDetailRow(context, '\u0627\u0644\u062a\u0627\u0631\u064a\u062e', DateFormat('yyyy-MM-dd').format(booking.date)),
        _buildDetailRow(context, '\u0627\u0644\u0648\u0642\u062a', DateFormat.jm().format(booking.date)),
        _buildDetailRow(context, '\u0627\u0644\u0645\u0648\u0642\u0639', booking.location),
        _buildDetailRow(context, '\u0627\u0644\u0642\u0627\u0639\u0629', booking.hallName),
        _buildDetailRow(context, '\u0639\u062f\u062f \u0627\u0644\u0633\u0627\u0639\u0627\u062a', '${booking.hours}'),
        const Divider(height: 20),
        _buildDetailRow(
          context,
          '\u0627\u0644\u0645\u0628\u0644\u063a \u0627\u0644\u0625\u062c\u0645\u0627\u0644\u064a',
          _moneyWidget(booking.totalAmount),
        ),
        _buildDetailRow(
          context,
          '\u0627\u0644\u062f\u0641\u0639\u0629 \u0627\u0644\u0623\u0648\u0644\u0649',
          _moneyWidget(booking.firstPayment),
        ),
        _buildDetailRow(
          context,
          '\u0627\u0644\u062f\u0641\u0639\u0629 \u0627\u0644\u0627\u062e\u064a\u0631\u0629',
          _moneyWidget(booking.lastPayment),
        ),
        if (booking.notes.isNotEmpty) ...[
          const Divider(height: 20),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF009873), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u0645\u0644\u0627\u062d\u0638\u0627\u062a',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF009873),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  booking.notes,
                  textAlign: TextAlign.right,
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _moneyWidget(double amount) {
    final isUsd = booking.currency == 'USD';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(amount.toStringAsFixed(2)),
        const SizedBox(width: 4),
        isUsd
            ? const Text('\$')
            : Image.asset(AppAssets.sarSymbol, width: 14, height: 14),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String title, dynamic value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (value is Widget)
            value
          else
            Expanded(
              child: Text(
                value.toString(),
                textAlign: TextAlign.left,
                style: textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}
