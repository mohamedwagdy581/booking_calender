import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/localization/app_language.dart';
import '../../../../../core/services/service_locator.dart';
import '../../../../../core/services/supabase/employee_names_service.dart';
import '../../../../../core/services/supabase_service.dart';
import '../../../data/models/booking_model.dart';
import '../../manager/booking_cubit/booking_cubit.dart';

/// "Added by" line in the booking details. Admins can change the employee the
/// booking is credited to (the database rejects this for everyone else).
class BookingCreatorRow extends StatefulWidget {
  const BookingCreatorRow({super.key, required this.booking});
  final Booking booking;

  @override
  State<BookingCreatorRow> createState() => _BookingCreatorRowState();
}

class _BookingCreatorRowState extends State<BookingCreatorRow> {
  late final Future<String> _role = sl<SupabaseService>().getCurrentUserRole();
  final _names = sl<EmployeeNamesService>()..ensureLoaded();

  String _t(String arabic, String english) =>
      AppLanguage.text(context, arabic, english);

  Future<void> _change() async {
    final cubit = context.read<BookingCubit>();
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => ValueListenableBuilder<Map<String, String>>(
        valueListenable: _names.names,
        builder: (dialogContext, names, _) {
          final entries = names.entries.toList()
            ..sort((a, b) => a.value.compareTo(b.value));
          return SimpleDialog(
            title: Text(_t('اختر الموظف الذي أضاف الحجز',
                'Choose the employee who added this booking')),
            children: [
              if (entries.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              for (final entry in entries)
                SimpleDialogOption(
                  onPressed: () => Navigator.of(dialogContext).pop(entry.key),
                  child: Row(children: [
                    Icon(
                      entry.key == widget.booking.createdBy
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(entry.value),
                  ]),
                ),
            ],
          );
        },
      ),
    );
    if (selected == null || selected == widget.booking.createdBy) return;
    if (!mounted) return;
    Navigator.of(context).pop(); // close details; the list reloads
    await cubit.assignCreator(widget.booking, selected);
  }

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<Map<String, String>>(
        valueListenable: _names.names,
        builder: (context, names, _) {
          final createdBy = widget.booking.createdBy;
          final missing = createdBy == null;
          final label = missing
              ? _t('غير مسجل', 'Not recorded')
              : names[createdBy] ?? '…';
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (missing ? Colors.orange : AppColors.primary)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              Icon(Icons.person_outline,
                  size: 18, color: missing ? Colors.orange : AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text('${_t('أضافه', 'Added by')}: $label')),
              FutureBuilder<String>(
                future: _role,
                builder: (context, role) => role.data == 'admin'
                    ? TextButton(
                        onPressed: _change,
                        child: Text(missing
                            ? _t('تعيين موظف', 'Assign employee')
                            : _t('تغيير', 'Change')),
                      )
                    : const SizedBox.shrink(),
              ),
            ]),
          );
        },
      );
}
