import 'package:flutter/material.dart';
import '../widgets/employee_header.dart';
import '../widgets/employee_bottom_nav.dart';
import '../widgets/employee_notifications_drawer.dart';
import 'employee_request_page.dart';

class EmployeeHomePage extends StatelessWidget {
  const EmployeeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      endDrawer: const EmployeeNotificationsDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const EmployeeHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Saludo
                    Row(
                      children: [
                        const Text(
                          'Hola, Juan',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('👋', style: TextStyle(fontSize: 28)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Gestiona tus adelantos de nómina',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Card principal
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Disponible para adelanto',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '\$ 1.000.000',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text(
                                'Usado: \$ 0',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              const Text(
                                '0%',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: 0,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white70),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const EmployeeRequestPage()),
                                );
                              },
                              icon: const Icon(Icons.attach_money, color: Color(0xFF2563EB)),
                              label: const Text(
                                'Solicitar Adelanto',
                                style: TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.trending_up,
                            iconColor: const Color(0xFF059669),
                            bgColor: const Color(0xFFD1FAE5),
                            label: 'Salario',
                            value: '\$ 2.000.000',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.attach_money,
                            iconColor: const Color(0xFF2563EB),
                            bgColor: const Color(0xFFDBEAFE),
                            label: 'Límite 50%',
                            value: '\$ 1.000.000',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Horarios card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: Color(0xFF2563EB)),
                              const SizedBox(width: 8),
                              const Text(
                                'Horarios de desembolso',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E40AF),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTimeRow('06:00 - 12:00', 'Desembolso a las 13:00'),
                          const SizedBox(height: 8),
                          _buildTimeRow('12:01 - 17:00', 'Desembolso a las 18:00'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const EmployeeBottomNav(currentIndex: 0),
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String time, String disbursement) {
    return Row(
      children: [
        Text(
          '• $time',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1E40AF),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward, size: 14, color: Color(0xFF2563EB)),
        const SizedBox(width: 8),
        Text(
          disbursement,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
