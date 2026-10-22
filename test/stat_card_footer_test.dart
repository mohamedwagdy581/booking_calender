import 'package:booking/core/constants/colors/app_colors.dart';
import 'package:booking/core/widgets/erp_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final filled in [true, false]) {
    testWidgets('Stat card footer (filledFooter: $filled)', (tester) async {
      var taps = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 340,
            child: ErpStatCard(
              title: 'الحجوزات المؤكدة',
              value: '1',
              description: 'حجوزات تم تأكيدها',
              icon: Icons.task_alt,
              color: Colors.orange,
              actionLabel: 'عرض الحجوزات',
              onPressed: () => taps++,
              filledFooter: filled,
            ),
          ),
        ),
      ));

      final footer = find.ancestor(
          of: find.text('عرض الحجوزات'), matching: find.byType(Material));
      final hasPrimaryFooter = tester
          .widgetList<Material>(footer)
          .any((m) => m.color == AppColors.primary);
      expect(hasPrimaryFooter, filled);
      expect(find.byType(TextButton), filled ? findsNothing : findsOneWidget);

      await tester.tap(find.text('عرض الحجوزات'));
      expect(taps, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
