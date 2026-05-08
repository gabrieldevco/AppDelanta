class EmployeeContractModel {
  final int id;
  final String title;
  final String companyName;
  final String employeeName;
  final String? contractFileUrl;
  final String status;
  final String? signatureImageUrl;
  final DateTime? signedAt;
  final DateTime createdAt;

  EmployeeContractModel({
    required this.id,
    required this.title,
    required this.companyName,
    required this.employeeName,
    required this.contractFileUrl,
    required this.status,
    required this.signatureImageUrl,
    required this.signedAt,
    required this.createdAt,
  });

  factory EmployeeContractModel.fromJson(Map<String, dynamic> json) {
    return EmployeeContractModel(
      id: json['id'],
      title: json['title'] ?? 'Contrato Appdelanta',
      companyName: json['company_name'] ?? '',
      employeeName: json['employee_name'] ?? '',
      contractFileUrl: json['contract_file_url'],
      status: json['status'] ?? 'pending',
      signatureImageUrl: json['signature_image_url'],
      signedAt: json['signed_at'] != null
          ? DateTime.tryParse(json['signed_at'])
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isSigned => status == 'signed';
}
