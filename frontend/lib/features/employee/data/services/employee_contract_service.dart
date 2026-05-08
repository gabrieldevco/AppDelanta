import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../models/employee_contract_model.dart';

class EmployeeContractService {
  final ApiService _apiService;

  EmployeeContractService(this._apiService);

  Future<List<EmployeeContractModel>> getMyContracts() async {
    final response = await _apiService.get(ApiConstants.employeeContracts);
    final results = response is List ? response : (response['results'] ?? []);
    return results
        .map<EmployeeContractModel>(
          (json) => EmployeeContractModel.fromJson(json),
        )
        .toList();
  }

  Future<EmployeeContractModel> signContract({
    required int contractId,
    required Uint8List signatureBytes,
  }) async {
    final formData = FormData.fromMap({
      'signature_image': MultipartFile.fromBytes(
        signatureBytes,
        filename: 'firma_contrato_$contractId.png',
        contentType: MediaType('image', 'png'),
      ),
    });
    final response = await _apiService.post(
      '${ApiConstants.employeeContracts}$contractId/sign/',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return EmployeeContractModel.fromJson(response);
  }
}
