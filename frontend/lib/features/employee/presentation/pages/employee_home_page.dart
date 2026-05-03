import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/employee_bottom_nav.dart';
import '../widgets/employee_header.dart';
import '../widgets/employee_notifications_drawer.dart';
import 'employee_request_page.dart';

class EmployeeHomePage extends StatefulWidget {
  const EmployeeHomePage({super.key});

  @override
  State<EmployeeHomePage> createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().refreshProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final firstName = user?.firstName.trim().isNotEmpty == true
            ? user!.firstName
            : 'Usuario';
        final salary = user?.employeeProfile?.salary ?? 0.0;
        final availableLimit =
            user?.employeeProfile?.availableAdvanceLimit ?? 0.0;
        final totalAdvanceLimit = salary * 0.5;
        final usedAmount = (totalAdvanceLimit - availableLimit).clamp(
          0,
          double.infinity,
        );
        final usagePercent = totalAdvanceLimit > 0
            ? (usedAmount / totalAdvanceLimit).clamp(0.0, 1.0)
            : 0.0;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FB),
          endDrawer: const EmployeeNotificationsDrawer(),
          body: SafeArea(
            child: Column(
              children: [
                const EmployeeHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGreeting(firstName),
                        const SizedBox(height: 18),
                        _buildHeroCard(
                          availableLimit: availableLimit,
                          usedAmount: usedAmount.toDouble(),
                          usagePercent: usagePercent,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.payments_outlined,
                                iconColor: const Color(0xFF00A86B),
                                bgColor: const Color(0xFFDDFBF3),
                                label: 'Salario',
                                value: '\$ ${_formatCurrency(salary)}',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.savings_outlined,
                                iconColor: const Color(0xFF00A86B),
                                bgColor: const Color(0xFFECFDF5),
                                label: 'Cupo 50%',
                                value:
                                    '\$ ${_formatCurrency(totalAdvanceLimit)}',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildScheduleCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const EmployeeBottomNav(currentIndex: 0),
        );
      },
    );
  }

  Widget _buildGreeting(String firstName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, $firstName',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tu dinero disponible, claro y al alcance.',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard({
    required double availableLimit,
    required double usedAmount,
    required double usagePercent,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF064E3B), Color(0xFF00A86B), Color(0xFF22C55E)],
          stops: [0.0, 0.58, 1.0],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A86B).withValues(alpha: 0.34),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Disponible',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Puedes solicitar hasta',
            style: TextStyle(
              color: Color(0xFFE8FFF2),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '\$ ${_formatCurrency(availableLimit)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                'Usado: \$ ${_formatCurrency(usedAmount)}',
                style: const TextStyle(
                  color: Color(0xFFE8FFF2),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${(usagePercent * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: usagePercent,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.24),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFBBF7D0),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmployeeRequestPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add_card_outlined),
              label: const Text('Solicitar adelanto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF047857),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6ECF3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.access_time_filled, color: Color(0xFFD97706)),
              SizedBox(width: 10),
              Text(
                'Horarios de desembolso',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildTimeRow('06:00 - 12:00', 'Desembolso a las 13:00'),
          const SizedBox(height: 8),
          _buildTimeRow('12:01 - 17:00', 'Desembolso a las 18:00'),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String time, String disbursement) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFFD97706),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          time,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF92400E),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward, size: 14, color: Color(0xFFD97706)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            disbursement,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF92400E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    return value.round().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
}
