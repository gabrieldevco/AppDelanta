import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../advances/data/models/advance_model.dart';
import '../../../advances/presentation/providers/advance_provider.dart';
import '../../../companies/presentation/providers/company_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../widgets/employer_bottom_nav.dart';
import '../widgets/employer_header.dart';
import '../widgets/employer_notifications_drawer.dart';
import 'employer_requests_page.dart';

class EmployerMainPage extends StatefulWidget {
  const EmployerMainPage({super.key});

  @override
  State<EmployerMainPage> createState() => _EmployerMainPageState();
}

class _EmployerMainPageState extends State<EmployerMainPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final companyProvider = context.read<CompanyProvider>();
    final advanceProvider = context.read<AdvanceProvider>();
    final notificationProvider = context.read<NotificationProvider>();
    await companyProvider.loadMyCompany();
    await Future.wait([
      companyProvider.loadEmployees(active: true),
      companyProvider.loadSummary(),
      advanceProvider.loadMyAdvances(),
    ]);
    await notificationProvider.refreshUnreadCount();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      endDrawer: const EmployerNotificationsDrawer(),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            const EmployerHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: Consumer2<CompanyProvider, AdvanceProvider>(
                  builder: (context, companyProvider, advanceProvider, _) {
                    final advances = [...advanceProvider.advances]
                      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                    final employees = companyProvider.activeEmployees;
                    final isLoading =
                        companyProvider.isLoading || advanceProvider.isLoading;

                    if (isLoading && advances.isEmpty && employees.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final totalAdvanced = advances
                        .where(_countsForTotalAdvanced)
                        .fold<double>(0, (sum, a) => sum + a.amount);
                    final pendingDiscount = advances
                        .where(_countsAsPendingDiscount)
                        .fold<double>(0, (sum, a) => sum + a.amount);

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                      children: [
                        _buildHeroHeader(
                          employeeCount: employees.length,
                          pendingDiscount: pendingDiscount,
                        ),
                        const SizedBox(height: 18),
                        _buildMetricsCards(
                          employeeCount: employees.length,
                          totalAdvanced: totalAdvanced,
                          pendingDiscount: pendingDiscount,
                          requestCount: advances.length,
                        ),
                        const SizedBox(height: 22),
                        _buildRecentRequests(advances.take(3).toList()),
                        const SizedBox(height: 22),
                        _buildImportantInfo(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const EmployerBottomNav(currentIndex: 0),
    );
  }

  Widget _buildHeroHeader({
    required int employeeCount,
    required double pendingDiscount,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1D4ED8), Color(0xFF06B6D4)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.24),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
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
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.business_center, color: Colors.white),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$employeeCount empleados',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Panel de Control',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Gestiona solicitudes, desembolsos y descuentos con claridad.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFFE0F2FE),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Pendiente por descontar',
                    style: TextStyle(
                      color: Color(0xFFE0F2FE),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  _money(pendingDiscount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsCards({
    required int employeeCount,
    required double totalAdvanced,
    required double pendingDiscount,
    required int requestCount,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Empleados',
                value: employeeCount.toString(),
                icon: Icons.people,
                bgColor: const Color(0xFF1D4ED8),
                textColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Adelantado',
                value: _money(totalAdvanced),
                icon: Icons.attach_money,
                bgColor: const Color(0xFF0891B2),
                textColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Pendiente descuento',
                value: _money(pendingDiscount),
                icon: Icons.trending_up,
                bgColor: const Color(0xFFE0F2FE),
                iconColor: const Color(0xFF0284C7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Total solicitudes',
                value: requestCount.toString(),
                icon: Icons.receipt_long,
                bgColor: const Color(0xFFECFEFF),
                iconColor: const Color(0xFF0891B2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color bgColor,
    Color? textColor,
    Color? iconColor,
  }) {
    final titleColor = textColor ?? const Color(0xFF4B5563);
    final valueColor = textColor ?? const Color(0xFF111827);
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(minHeight: 104),
      decoration: BoxDecoration(
        gradient: textColor != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [bgColor, Color.lerp(bgColor, Colors.black, 0.16)!],
              )
            : null,
        color: textColor == null ? bgColor : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: textColor != null ? 0.18 : 0.1),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: iconColor ?? textColor ?? Colors.white, size: 23),
          Text(title, style: TextStyle(fontSize: 12, color: titleColor)),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRequests(List<AdvanceModel> advances) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Solicitudes recientes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmployerRequestsPage(),
                    ),
                  );
                },
                child: const Text('Ver todas'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (advances.isEmpty)
            _buildEmptyLine('Aún no hay solicitudes registradas')
          else
            ...advances.map(_buildRequestCard),
        ],
      ),
    );
  }

  Widget _buildRequestCard(AdvanceModel advance) {
    final color = _statusColor(advance.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  advance.employeeName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _shortDate(advance.requestDate),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  advance.statusDisplay.toLowerCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _money(advance.amount),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLine(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildImportantInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Text(
        'El empleador actúa como intermediario operativo y responsable del descuento en nómina. Fee e interés pertenecen a la plataforma.',
        style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF), height: 1.4),
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'approved' => const Color(0xFF1D4ED8),
      'disbursed' || 'recovered' => const Color(0xFF0891B2),
      'rejected' || 'cancelled' => const Color(0xFFDC2626),
      _ => const Color(0xFFF59E0B),
    };
  }

  bool _countsForTotalAdvanced(AdvanceModel advance) {
    return advance.isApproved || advance.isDisbursed || advance.isRecovered;
  }

  bool _countsAsPendingDiscount(AdvanceModel advance) {
    return advance.isApproved || advance.isDisbursed;
  }

  String _shortDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String _money(num value) {
    final text = value.round().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '\$ $text';
  }
}
