import 'package:flutter/material.dart';

import 'responsive_layout.dart';

/// Shows [child] as a centred dialog on wide screens and as a bottom sheet on
/// phones.
///
/// [sheetHeightFactor] gives the sheet a fixed share of the screen height
/// (for scrolling lists); without it the sheet sizes to its content.
Future<T?> showAdaptivePanel<T>(
  BuildContext context, {
  required Widget child,
  double maxWidth = 420,
  double maxHeight = double.infinity,
  double? sheetHeightFactor,
}) {
  if (MediaQuery.sizeOf(context).width >= kMobileBreakpoint) {
    return showDialog<T>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
          child: child,
        ),
      ),
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
    builder: (_) => sheetHeightFactor == null
        ? SafeArea(child: child)
        : FractionallySizedBox(heightFactor: sheetHeightFactor, child: child),
  );
}
