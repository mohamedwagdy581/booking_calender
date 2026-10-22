import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/employees_service.dart';
import '../../data/models/employee.dart';

sealed class EmployeesState extends Equatable {
  const EmployeesState();
  @override
  List<Object?> get props => [];
}

class EmployeesLoading extends EmployeesState {
  const EmployeesLoading();
}

class EmployeesFailure extends EmployeesState {
  const EmployeesFailure(this.code);
  final String code;
  @override
  List<Object?> get props => [code];
}

class EmployeesLoaded extends EmployeesState {
  const EmployeesLoaded(this.employees, {this.busyId});
  final List<Employee> employees;

  /// Employee whose row is being updated, to show a spinner on it.
  final String? busyId;
  @override
  List<Object?> get props => [employees, busyId];
}

class EmployeesCubit extends Cubit<EmployeesState> {
  EmployeesCubit(this._service) : super(const EmployeesLoading());
  final EmployeesService _service;

  void _emit(EmployeesState state) {
    if (!isClosed) emit(state);
  }

  Future<void> load() async {
    _emit(const EmployeesLoading());
    try {
      _emit(EmployeesLoaded(await _service.list()));
    } on EmployeesException catch (e) {
      _emit(EmployeesFailure(e.code));
    }
  }

  /// Returns null on success, otherwise an error code for the UI.
  Future<String?> create({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      await _service.create(
          email: email, password: password, fullName: fullName, role: role);
      await _refresh();
      return null;
    } on EmployeesException catch (e) {
      return e.code;
    }
  }

  Future<String?> setRole(Employee employee, String role) =>
      _update(employee, () => _service.setRole(employee.id, role));

  Future<String?> setDisabled(Employee employee, bool disabled) =>
      _update(employee, () => _service.setDisabled(employee.id, disabled));

  Future<String?> _update(
      Employee employee, Future<void> Function() change) async {
    final current = state;
    if (current is! EmployeesLoaded) return 'server_error';
    _emit(EmployeesLoaded(current.employees, busyId: employee.id));
    try {
      await change();
      await _refresh();
      return null;
    } on EmployeesException catch (e) {
      _emit(EmployeesLoaded(current.employees));
      return e.code;
    }
  }

  // Reload without replacing the list with a full-screen spinner.
  Future<void> _refresh() async {
    try {
      _emit(EmployeesLoaded(await _service.list()));
    } on EmployeesException {
      final current = state;
      if (current is EmployeesLoaded) {
        _emit(EmployeesLoaded(current.employees));
      }
    }
  }
}
