import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../advances/data/models/advance_model.dart';
import '../../../advances/presentation/providers/advance_provider.dart';
import '../widgets/employee_bottom_nav.dart';
import '../widgets/employee_header.dart';
import '../widgets/employee_notifications_drawer.dart';

class EmployeeHistoryPage extends StatefulWidget {
  const EmployeeHistoryPage({super.key});

  @override
  State<EmployeeHistoryPage> createState() => _EmployeeHistoryPageState();
}

class _EmployeeHistoryPageState extends State<EmployeeHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdvanceProvider>().loadMyAdvances();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdvanceProvider>(
      builder: (context, advanceProvider, child) {
        final advances = [...advanceProvider.advances]
          ..sort((a, b) => b.requestDate.compareTo(a.requestDate));
        final activeAdvances = advances.where((a) => a.isPending).toList();
        final completedAdvances = advances.where((a) => a.isDisbursed).toList();
        final totalAdvanced = advances
            .where((a) => a.isApproved || a.isDisbursed || a.isRecovered)
            .fold<double>(0, (sum, advance) => sum + advance.amount);
        final totalCosts = advances
            .where((a) => a.isApproved || a.isDisbursed || a.isRecovered)
            .fold<double>(0, (sum, advance) => sum + advance.fee);

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FB),
          endDrawer: const EmployeeNotificationsDrawer(),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EmployeeHeader(),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Historial',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Consulta todas tus solicitudes',
                    style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTotalCard(
                          label: 'Total adelantado',
                          value: '\$ ${_formatCurrency(totalAdvanced)}',
                          valueColor: const Color(0xFF00A86B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTotalCard(
                          label: 'Total costos',
                          value: '\$ ${_formatCurrency(totalCosts)}',
                          valueColor: const Color(0xFFEA580C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00A86B).withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00A86B), Color(0xFF22C55E)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF00A86B,
                          ).withValues(alpha: 0.24),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFF64748B),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Todas'),
                      Tab(text: 'Activas'),
                      Tab(text: 'Completadas'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTabContent(advanceProvider, advances),
                      _buildTabContent(advanceProvider, activeAdvances),
                      _buildTabContent(advanceProvider, completedAdvances),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const EmployeeBottomNav(currentIndex: 2),
        );
      },
    );
  }

  Widget _buildTabContent(
    AdvanceProvider advanceProvider,
    List<AdvanceModel> advances,
  ) {
    if (advanceProvider.isLoading && advanceProvider.advances.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFF59E0B)),
      );
    }

    if (advanceProvider.status == AdvanceStatus.error) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFDC2626),
                size: 28,
              ),
              const SizedBox(height: 12),
              Text(
                advanceProvider.errorMessage ?? 'Error al cargar historial',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => advanceProvider.loadMyAdvances(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (advances.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AdvanceProvider>().loadMyAdvances(),
      color: const Color(0xFFF59E0B),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: advances.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildAdvanceCard(advances[index]),
      ),
    );
  }

  Widget _buildAdvanceCard(AdvanceModel advance) {
    final statusStyle = _statusStyle(advance);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusStyle.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusStyle.icon, color: statusStyle.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$ ${_formatCurrency(advance.amount)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(advance.requestDate),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusStyle.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  advance.statusDisplay,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusStyle.color,
                  ),
                ),
              ),
            ],
          ),
          if ((advance.reason ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              advance.reason!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildAmountMeta('Costo', advance.fee)),
              Expanded(child: _buildAmountMeta('Total', advance.totalAmount)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountMeta(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
        ),
        const SizedBox(height: 2),
        Text(
          '\$ ${_formatCurrency(value)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalCard({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Text(
          'No hay solicitudes en esta categoria',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF9CA3AF)),
        ),
      ),
    );
  }

  _AdvanceStatusStyle _statusStyle(AdvanceModel advance) {
    if (advance.isPending) {
      return const _AdvanceStatusStyle(
        icon: Icons.schedule,
        color: Color(0xFFD97706),
        background: Color(0xFFFEF3C7),
      );
    }
    if (advance.isApproved) {
      return const _AdvanceStatusStyle(
        icon: Icons.check_circle_outline,
        color: Color(0xFF00A86B),
        background: Color(0xFFE8FFF2),
      );
    }
    if (advance.isDisbursed || advance.isRecovered) {
      return const _AdvanceStatusStyle(
        icon: Icons.payments_outlined,
        color: Color(0xFF10B981),
        background: Color(0xFFBBF7D0),
      );
    }
    if (advance.isRejected || advance.isCancelled) {
      return const _AdvanceStatusStyle(
        icon: Icons.cancel_outlined,
        color: Color(0xFFDC2626),
        background: Color(0xFFFEE2E2),
      );
    }
    return const _AdvanceStatusStyle(
      icon: Icons.description_outlined,
      color: Color(0xFF64748B),
      background: Color(0xFFF8FAFC),
    );
  }

  String _formatCurrency(double value) {
    final rounded = value.round().toString();
    return rounded.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}

class _AdvanceStatusStyle {
  final IconData icon;
  final Color color;
  final Color background;

  const _AdvanceStatusStyle({
    required this.icon,
    required this.color,
    required this.background,
  });
}
