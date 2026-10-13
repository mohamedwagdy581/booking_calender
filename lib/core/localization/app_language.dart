import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppLanguageCubit extends Cubit<bool> {
  AppLanguageCubit() : super(true);

  void toggle() => emit(!state);
}

/// Keeps the new ERP shell bilingual without changing legacy screen strings.
class AppLanguage extends InheritedWidget {
  const AppLanguage({
    super.key,
    required this.isArabic,
    required super.child,
  });

  final bool isArabic;

  static bool arabicOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppLanguage>()?.isArabic ??
      true;

  static String text(BuildContext context, String arabic, String english) =>
      arabicOf(context) ? arabic : english;

  static String localeOf(BuildContext context) =>
      arabicOf(context) ? 'ar' : 'en';

  @override
  bool updateShouldNotify(AppLanguage oldWidget) =>
      oldWidget.isArabic != isArabic;
}

class AppLanguageButton extends StatelessWidget {
  const AppLanguageButton(
      {super.key, this.foregroundColor, this.compact = false});

  final Color? foregroundColor;
  final bool compact;

  @override
  Widget build(BuildContext context) => compact
      ? IconButton(
          tooltip: AppLanguage.arabicOf(context) ? 'English' : 'العربية',
          onPressed: () => context.read<AppLanguageCubit>().toggle(),
          icon: const Icon(Icons.language),
          color: foregroundColor,
        )
      : TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: foregroundColor),
          onPressed: () => context.read<AppLanguageCubit>().toggle(),
          icon: const Icon(Icons.language, size: 18),
          label: Text(AppLanguage.arabicOf(context) ? 'English' : 'العربية'),
        );
}
