class Employer {
  final String id;
  final String name;
  final String email;
  final String companyName;
  final String nit;
  final List<Employee> employees;
  final double totalAdvanced;
  final double pendingDiscount;
  final int totalRequests;

  Employer({
    required this.id,
    required this.name,
    required this.email,
    required this.companyName,
    required this.nit,
    required this.employees,
    this.totalAdvanced = 0,
    this.pendingDiscount = 0,
    this.totalRequests = 0,
  });
}

class Employee {
  final String id;
  final String name;
  final String documentType;
  final String documentNumber;
  final String email;
  final double salary;
  final double availableAdvance;

  Employee({
    required this.id,
    required this.name,
    required this.documentType,
    required this.documentNumber,
    required this.email,
    required this.salary,
    this.availableAdvance = 0,
  });
}

class AdvanceRequest {
  final String id;
  final String employeeId;
  final String employeeName;
  final String documentNumber;
  final DateTime date;
  final double amount;
  final String status; // 'pendiente', 'aprobado', 'descontado', 'rechazado'

  AdvanceRequest({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.documentNumber,
    required this.date,
    required this.amount,
    required this.status,
  });
}
