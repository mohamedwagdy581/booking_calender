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
            'الرقم المرجعي',
            booking.refNumber!,
          ),
        _buildDetailRow(context, 'اسم العميل', booking.clientName),
        _buildDetailRow(context, 'التاريخ', DateFormat('yyyy-MM-dd').format(booking.date)),
        _buildDetailRow(context, 'الوقت', DateFormat.jm().format(booking.date)),
        _buildDetailRow(context, 'الموقع', booking.location),
        _buildDetailRow(context, 'القاعة', booking.hallName),
        _buildDetailRow(context, 'عدد الساعات', booking.hours),
        const Divider(height: 20),
        _buildDetailRow(
          context,
          'المبلغ الإجمالي',
          _moneyWidget(booking.totalAmount),
        ),
        _buildDetailRow(
          context,
          'الدفعة الأولى',
          _moneyWidget(booking.firstPayment),
        ),
        _buildDetailRow(
          context,
          'الدفعة الأخيرة',
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
                  'ملاحظات',
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
          const SizedBox(width: 8),
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
