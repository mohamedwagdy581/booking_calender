# Code structure

Aim for roughly 100 formatted lines per Dart file. Split by responsibility,
not by arbitrary line ranges. Constructors and complete data models may need
more space; do not compress formatting to meet a line count.

## Presentation

- Views compose widgets, own screen lifecycle, and connect existing BLoCs.
- `widgets/employee_home/` contains welcome, toolbar, summary cards, booking
  lists, and the employee dashboard layout.
- `widgets/performance/` contains employee performance calculations, filters,
  summary widgets, and the performance report layout.
- `widgets/search/` contains search input, result states, result cards, and
  reusable result detail rows.
- `widgets/forms/` connects add/edit form controllers to the existing bodies.
- `widgets/helpers/booking_form_controller.dart` owns form state and controller
  lifecycle. `booking_amounts.dart` owns VAT and remaining-payment calculations.
- `show_booking_details.dart` shares the existing details dialog and BLoC scope.

## Services and shared UI

- `SupabaseService` preserves its existing API and delegates profile queries,
  booking queries, and messages to focused classes in `core/services/supabase/`.
  Permissions, query filters, and error fallbacks remain with these services.
- `core/services/pdf/` owns report generation and quotation file export.
- `core/widgets/sidebar/` contains destination definitions, brand, destination
  tiles, and profile entry. `AppSidebar` composes these pieces.
- `core/theme/app_text_theme.dart` separates typography from theme configuration.

Keep reusable calculations independently testable. Keep subscriptions and
controller disposal with their owners. Preserve existing public entry points
when moving code. Do not introduce database migrations for presentation cleanup.

Some older PDF layouts, model declarations, and form body widgets still exceed
the guideline. Their remaining extraction should preserve document layout and
form validation rather than force an arbitrary size limit.
