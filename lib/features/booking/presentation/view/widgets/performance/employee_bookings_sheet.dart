import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/constants/colors/app_colors.dart';
import '../../../../../../core/widgets/adaptive_panel.dart';
import '../../../../data/models/booking_model.dart';
import '../../../manager/booking_cubit/booking_cubit.dart';
import '../employee_home/booking_summary_tile.dart';
import '../helpers/show_booking_details.dart';
import 'performance_calculator.dart';

enum _Filter { all, confirmed, pending }

/// Shows one employee's bookings for the month behind the report numbers.
Future<void> showEmployeeBookings(
  BuildContext context, {
  required Map<String, dynamic> employee,
  required double commission,
  required DateTime month,
}) {
  // The sheet is a new route, so hand it the page's BookingCubit explicitly.
  final bookingCubit = context.read<BookingCubit>();
  final content = BlocProvider.value(
    value: bookingCubit,
    child: _EmployeeBookings(
        employee: employee, commission: commission, month: month),
  );
  return showAdaptivePanel(context,
      child: content, maxWidth: 640, maxHeight: 720, sheetHeightFactor: 0.9);
}

class _EmployeeBookings extends StatefulWidget {
  const _EmployeeBookings(
      {required this.employee, required this.commission, required this.month});
  final Map<String, dynamic> employee;
  final double commission;
  final DateTime month;

  @override
  State<_EmployeeBookings> createState() => _EmployeeBookingsState();
}

class _EmployeeBookingsState extends State<_EmployeeBookings> {
  _Filter _filter = _Filter.all;

  static List<Booking> _parse(Object? rows) => [
        for (final row in rows as List? ?? const [])
          Booking.fromJson(Map<String, dynamic>.from(row as Map)),
      ];

  // Added this month (activity).
  late final List<Booking> _bookings = _parse(widget.employee['bookings'])
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  // Confirmed, not archived, event this month (commission), possibly added
  // in an earlier month.
  late final List<Booking> _confirmed =
      _parse(widget.employee['confirmed_bookings'])
        ..sort((a, b) => a.date.compareTo(b.date));

  // Commission is due only once the event day is over.
  bool _completed(Booking b) =>
      bookingEventCompleted({'date': b.date.toIso8601String()}, DateTime.now());

  @override
  Widget build(BuildContext context) {
    final confirmed = _confirmed;
    final pending = _bookings.where((b) => !b.isConfirmed).toList();
    final all = [
      ..._bookings,
      ...confirmed.where((c) => _bookings.every((b) => b.id != c.id)),
    ];
    final shown = switch (_filter) {
      _Filter.all => all,
      _Filter.confirmed => confirmed,
      _Filter.pending => pending,
    };
    final earned = confirmed.where(_completed).length;
    final expected = confirmed.length - earned;
    final bonus = earned * widget.commission;

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.employee['name'].toString(),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                  'شهر ${DateFormat('MMMM yyyy', 'ar').format(widget.month)}',
                  style: const TextStyle(color: AppColors.greyDark)),
            ]),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          _Stat('الحجوزات المضافة', '${_bookings.length}',
              Icons.event_note_outlined, AppColors.primary),
          const SizedBox(width: 8),
          _Stat('مؤكدة لحفلات الشهر', '${confirmed.length}',
              Icons.verified_outlined, AppColors.success),
          const SizedBox(width: 8),
          _Stat('العمولة المستحقة', '${bonus.toStringAsFixed(0)} ر.س',
              Icons.payments_outlined, AppColors.warning),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'العمولة المستحقة = $earned حفل مؤكد انتهى موعده × '
          '${widget.commission.toStringAsFixed(0)} ر.س'
          '${expected > 0 ? ' • متوقعة: $expected حفل لم يتم بعد (${(expected * widget.commission).toStringAsFixed(0)} ر.س)' : ''}'
          ' • الحجوزات الملغاة (المؤرشفة) لا تستحق عمولة',
          style: const TextStyle(fontSize: 12, color: AppColors.greyDark),
        ),
      ),
      const SizedBox(height: 12),
      SegmentedButton<_Filter>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
              value: _Filter.all, label: Text('الكل (${all.length})')),
          ButtonSegment(
              value: _Filter.confirmed,
              label: Text('مؤكد (${confirmed.length})')),
          ButtonSegment(
              value: _Filter.pending,
              label: Text('بانتظار التأكيد (${pending.length})')),
        ],
        selected: {_filter},
        onSelectionChanged: (s) => setState(() => _filter = s.first),
      ),
      const Divider(height: 24),
      Expanded(
        child: shown.isEmpty
            ? const Center(child: Text('لا توجد حجوزات'))
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: shown.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final booking = shown[index];
                  final tile = BookingSummaryTile(
                    booking: booking,
                    onTap: () => showBookingDetails(context, booking),
                  );
                  if (_filter != _Filter.confirmed) return tile;
                  final done = _completed(booking);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      tile,
                      Text(
                          done
                              ? 'انتهى الحفل — العمولة مستحقة'
                              : 'الحفل لم يتم بعد — العمولة متوقعة',
                          style: TextStyle(
                              fontSize: 11,
                              color: done
                                  ? AppColors.success
                                  : AppColors.pending)),
                      const SizedBox(height: 6),
                    ],
                  );
                },
              ),
      ),
    ]);
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ),
            Text(label,
                maxLines: 2,
                style: const TextStyle(fontSize: 11, color: AppColors.greyDark)),
          ]),
        ),
      );
}
