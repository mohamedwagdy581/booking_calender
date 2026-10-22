import 'package:booking/core/widgets/sidebar/booking_destination.dart';
import 'package:booking/features/employees/data/employees_service.dart';
import 'package:booking/features/employees/data/models/employee.dart';
import 'package:booking/features/employees/presentation/manager/employees_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEmployeesService implements EmployeesService {
  List<Employee> employees = [];
  EmployeesException? failure;
  final calls = <String>[];

  @override
  Future<List<Employee>> list() async {
    if (failure != null) throw failure!;
    return employees;
  }

  @override
  Future<void> setRole(String userId, String role) async {
    calls.add('role:$userId:$role');
    if (failure != null) throw failure!;
  }

  @override
  Future<void> setDisabled(String userId, bool disabled) async {
    calls.add('disabled:$userId:$disabled');
    if (failure != null) throw failure!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

const _staff = Employee(
    id: 'b', email: 'b@x.com', fullName: '', role: 'staff',
    disabled: false, isSelf: false);

void main() {
  test('Only admins get the Employees destination', () {
    expect(BookingDestination.forRole('admin'),
        contains(BookingDestination.employees));
    for (final role in ['staff', '', 'unknown']) {
      expect(BookingDestination.forRole(role),
          isNot(contains(BookingDestination.employees)));
    }
  });

  test('Employee parses the server payload', () {
    final e = Employee.fromJson(const {
      'id': 'a',
      'email': 'a@x.com',
      'full_name': '',
      'role': 'admin',
      'disabled': true,
      'is_self': true,
      'last_sign_in_at': null,
    });
    expect([e.isAdmin, e.disabled, e.isSelf, e.displayName],
        [true, true, true, 'A']);
    expect(e.lastSignInAt, isNull);
  });

  test('Load failure is reported, not shown as an empty list', () async {
    final service = _FakeEmployeesService()
      ..failure = const EmployeesException('forbidden');
    final cubit = EmployeesCubit(service);
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state, const EmployeesFailure('forbidden'));
  });

  test('Failed update keeps the list and returns the error code', () async {
    final service = _FakeEmployeesService()..employees = [_staff];
    final cubit = EmployeesCubit(service);
    addTearDown(cubit.close);
    await cubit.load();

    service.failure = const EmployeesException('cannot_change_self');
    final code = await cubit.setRole(_staff, 'admin');

    expect(code, 'cannot_change_self');
    expect(service.calls, ['role:b:admin']);
    expect(cubit.state, const EmployeesLoaded([_staff]));
  });

  test('Successful disable reloads the list', () async {
    final service = _FakeEmployeesService()..employees = [_staff];
    final cubit = EmployeesCubit(service);
    addTearDown(cubit.close);
    await cubit.load();

    const disabled = Employee(
        id: 'b', email: 'b@x.com', fullName: '', role: 'staff',
        disabled: true, isSelf: false);
    service.employees = [disabled];
    expect(await cubit.setDisabled(_staff, true), isNull);
    expect(cubit.state, const EmployeesLoaded([disabled]));
  });
}
