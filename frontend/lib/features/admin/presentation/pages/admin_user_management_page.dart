import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/features/admin/presentation/widgets/admin_bottom_nav.dart';

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  State<AdminUserManagementPage> createState() => _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _employees = [];
  List<dynamic> _employers = [];
  bool _loadingEmployees = false;
  bool _loadingEmployers = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadEmployees(),
      _loadEmployers(),
    ]);
  }

  Future<void> _loadEmployees() async {
    setState(() => _loadingEmployees = true);
    try {
      final response = await apiService.get('/api/users/employees/');
      setState(() => _employees = response['data'] ?? []);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar empleados'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      setState(() => _loadingEmployees = false);
    }
  }

  Future<void> _loadEmployers() async {
    setState(() => _loadingEmployers = true);
    try {
      final response = await apiService.get('/api/users/employers/');
      setState(() => _employers = response['data'] ?? []);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar empleadores'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      setState(() => _loadingEmployers = false);
    }
  }

  Future<void> _verifyCompany(int companyId, bool verify) async {
    try {
      await apiService.patch('/api/companies/$companyId/verify/', data: {
        'is_verified': verify,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(verify ? 'Empresa verificada' : 'Verificación removida'),
            backgroundColor: verify ? const Color(0xFF059669) : const Color(0xFFF59E0B),
          ),
        );
      }
      await _loadEmployers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al verificar empresa'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  Future<void> _viewPdf(String pdfUrl) async {
    // Implementar visualización de PDF
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Función PDF en desarrollo')),
      );
    }
  }

  Future<void> _deleteCompany(int companyId) async {
    try {
      await apiService.delete('/api/companies/$companyId/');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Empresa eliminada'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      }
      await _loadEmployers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar empresa'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  Future<void> _deleteUser(int userId, String userType) async {
    try {
      await apiService.delete('/api/users/$userId/');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$userType eliminado'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
      }
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar $userType'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Eliminar', style: TextStyle(color: Color(0xFFDC2626))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFF9FAFB),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF1F2937),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Administrar Usuarios',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelColor: const Color(0xFF1F2937),
                      unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 18),
                              SizedBox(width: 8),
                              Text('Empleados'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.business_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Empleadores'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEmployeesList(),
                  _buildEmployersList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
    );
  }

  Widget _buildEmployeesList() {
    if (_loadingEmployees) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay empleados registrados',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEmployees,
      child: ListView.builder(
        itemCount: _employees.length,
        itemBuilder: (context, index) {
          final employee = _employees[index];
          return _buildEmployeeCard(
            name: '${employee['first_name'] ?? ''} ${employee['last_name'] ?? ''}',
            email: employee['email'] ?? '',
            document: employee['document_number'] ?? '',
            userId: employee['id'],
          );
        },
      ),
    );
  }

  Widget _buildEmployersList() {
    if (_loadingEmployers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_employers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay empleadores registrados',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEmployers,
      child: ListView.builder(
        itemCount: _employers.length,
        itemBuilder: (context, index) {
          final employer = _employers[index];
          final company = employer['company'];
          final isVerified = company?['is_verified'] ?? false;
          final pdfUrl = company?['chamber_of_commerce_file'];
          
          return _buildEmployerCard(
            name: '${employer['first_name'] ?? ''} ${employer['last_name'] ?? ''}',
            email: employer['email'] ?? '',
            document: employer['document_number'] ?? '',
            companyName: company?['name'],
            companyId: company?['id'],
            userId: employer['id'],
            isVerified: isVerified,
            pdfUrl: pdfUrl,
          );
        },
      ),
    );
  }

  Widget _buildEmployeeCard({
    required String name,
    required String email,
    required String document,
    required int userId,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person, color: Color(0xFF059669), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.trim().isEmpty ? 'Sin nombre' : name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                if (document.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'CC: $document',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showDeleteConfirmation(
              'Eliminar Empleado',
              '¿Estás seguro de que deseas eliminar a $name? Esta acción no se puede deshacer.',
              () => _deleteUser(userId, 'Empleado'),
            ),
            icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
            tooltip: 'Eliminar empleado',
          ),
        ],
      ),
    );
  }

  Widget _buildEmployerCard({
    required String name,
    required String email,
    required String document,
    String? companyName,
    int? companyId,
    required int userId,
    required bool isVerified,
    String? pdfUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVerified ? const Color(0xFF059669) : const Color(0xFFE5E7EB),
          width: isVerified ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.business, color: Color(0xFF2563EB), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.trim().isEmpty ? 'Sin nombre' : name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    if (document.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'CC: $document',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isVerified 
                      ? const Color(0xFF059669).withValues(alpha: 0.1)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVerified ? Icons.verified : Icons.pending,
                      color: isVerified ? const Color(0xFF059669) : const Color(0xFFF59E0B),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isVerified ? 'Verificado' : 'Pendiente',
                      style: TextStyle(
                        fontSize: 11,
                        color: isVerified ? const Color(0xFF059669) : const Color(0xFFF59E0B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (companyName != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.store, size: 16, color: Color(0xFF6B7280)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      companyName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF374151),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (pdfUrl != null) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewPdf(pdfUrl),
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('Ver Cámara de Comercio'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFDC2626)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (companyId != null) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _verifyCompany(companyId, !isVerified),
                    icon: Icon(
                      isVerified ? Icons.cancel : Icons.check_circle,
                      size: 18,
                    ),
                    label: Text(isVerified ? 'Rechazar' : 'Verificar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isVerified 
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteConfirmation(
                    'Eliminar Empleador',
                    '¿Estás seguro de que deseas eliminar a $name? Esta acción no se puede deshacer.',
                    () => _deleteUser(userId, 'Empleador'),
                  ),
                  icon: const Icon(Icons.person_remove, size: 18, color: Color(0xFFDC2626)),
                  label: const Text('Eliminar Empleador', style: TextStyle(color: Color(0xFFDC2626))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFDC2626)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (companyId != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteConfirmation(
                      'Eliminar Empresa',
                      '¿Estás seguro de que deseas eliminar esta empresa? Esta acción no se puede deshacer.',
                      () => _deleteCompany(companyId),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                    label: const Text('Eliminar Empresa', style: TextStyle(color: Color(0xFFDC2626))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFDC2626)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
