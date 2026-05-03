import 'package:flutter/material.dart';
import '../widgets/admin_header.dart';
import '../widgets/admin_notifications_drawer.dart';

class AdminHelpPage extends StatefulWidget {
  const AdminHelpPage({super.key});

  @override
  State<AdminHelpPage> createState() => _AdminHelpPageState();
}

class _AdminHelpPageState extends State<AdminHelpPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<FaqCategory> _faqCategories = [
    FaqCategory(
      title: 'Gestión de Adelantos',
      questionCount: 4,
      faqs: [
        FaqItem(
          question: '¿Cómo apruebo un adelanto?',
          answer:
              'Ve a la sección "Desembolsos" > "Pendientes", selecciona la solicitud y presiona "Aprobar". El dinero se transferirá en menos de 24 horas.',
        ),
        FaqItem(
          question: '¿Cuánto tiempo tarda un desembolso?',
          answer:
              'Los desembolsos aprobados se procesan en menos de 24 horas hábiles y se transfieren directamente a la cuenta del empleado.',
        ),
        FaqItem(
          question: '¿Puedo rechazar una solicitud?',
          answer:
              'Sí, en la sección de desembolsos pendientes puedes rechazar una solicitud. El empleado recibirá una notificación con el motivo.',
        ),
        FaqItem(
          question: '¿Cómo reviso el historial de desembolsos?',
          answer:
              'En la sección "Desembolsos" > "Completados" encontrarás todo el historial con fechas, montos y estados de cada transacción.',
        ),
      ],
    ),
    FaqCategory(
      title: 'Reportes y Estadísticas',
      questionCount: 3,
      faqs: [
        FaqItem(
          question: '¿Cómo genero un reporte?',
          answer:
              'Ve a "Reportes", selecciona el rango de fechas, el empleador (opcional) y presiona "Generar Reporte". Puedes exportar en Excel o PDF.',
        ),
        FaqItem(
          question: '¿Qué información incluyen los reportes?',
          answer:
              'Los reportes incluyen: total desembolsado, cantidad de transacciones, promedio por empleado, estado de desembolsos y desglose por empleador.',
        ),
        FaqItem(
          question: '¿Puedo exportar los datos?',
          answer:
              'Sí, todos los reportes se pueden exportar en formato Excel (verde) o PDF (rojo) usando los botones correspondientes.',
        ),
      ],
    ),
    FaqCategory(
      title: 'Configuración del Sistema',
      questionCount: 3,
      faqs: [
        FaqItem(
          question: '¿Cómo configuro los fees e intereses?',
          answer:
              'Ve a "Configuración" > "Fees e Intereses". Allí puedes definir los rangos de montos y las tasas de interés aplicables.',
        ),
        FaqItem(
          question: '¿Qué son los límites de operación?',
          answer:
              'Son los parámetros que definen: porcentaje máximo de salario disponible, días mínimos/máximos para solicitar, y franjas horarias de desembolso.',
        ),
        FaqItem(
          question: '¿Cómo cambio las franjas de desembolso?',
          answer:
              'En "Configuración" > "Operación" > "Franjas de Desembolso" puedes definir los horarios en que se procesarán las transferencias.',
        ),
      ],
    ),
    FaqCategory(
      title: 'Gestión de Empleadores',
      questionCount: 3,
      faqs: [
        FaqItem(
          question: '¿Cómo veo los empleadores registrados?',
          answer:
              'En el panel principal se muestra el resumen de empleadores activos. Para más detalles, revisa los reportes por empleador.',
        ),
        FaqItem(
          question: '¿Cómo contacto a un empleador?',
          answer:
              'Usa la información de contacto proporcionada en los reportes detallados o en la sección de desembolsos.',
        ),
        FaqItem(
          question: '¿Puedo desactivar un empleador?',
          answer:
              'La desactivación de empleadores requiere contactar al equipo de soporte técnico para verificar que no haya desembolsos pendientes.',
        ),
      ],
    ),
    FaqCategory(
      title: 'Seguridad',
      questionCount: 3,
      faqs: [
        FaqItem(
          question: '¿Es seguro usar la plataforma?',
          answer:
              'Sí, utilizamos encriptación de nivel bancario (256-bit SSL) y cumplimos con todas las normativas de protección de datos.',
        ),
        FaqItem(
          question: '¿Quién puede ver la información?',
          answer:
              'Solo los administradores autorizados tienen acceso a la información. Los datos están protegidos con autenticación de dos factores.',
        ),
        FaqItem(
          question: '¿Qué hago si veo actividad sospechosa?',
          answer:
              'Contacta inmediatamente a soporte al +57 (1) 234-5678 o soporte@Appdelanta.com y bloquearemos temporalmente la cuenta.',
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      endDrawer: const AdminNotificationsDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const AdminHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    const Text(
                      'Centro de Ayuda',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Encuentra respuestas a tus preguntas sobre la plataforma',
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 20),
                    // Búsqueda
                    _buildHelpHero(),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    // FAQ Categories
                    ..._faqCategories.map(
                      (category) => _buildFaqCategory(category),
                    ),
                    const SizedBox(height: 20),
                    // Contacto
                    _buildContactSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: const Color(0xFF7C3AED),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        label: const Text(
          'Volver',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDD6FE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar en preguntas frecuentes...',
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF7C3AED)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildHelpHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF312E81), Color(0xFF7C3AED), Color(0xFFEC4899)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: const Icon(Icons.admin_panel_settings, color: Colors.white),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Soporte operativo admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Gestiona dudas de desembolsos, reportes, usuarios y configuracion.',
                  style: TextStyle(
                    color: Color(0xFFF5F3FF),
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCategory(FaqCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9D5FF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.07),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Text(
              '${category.questionCount} preguntas',
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(height: 16),
          ...category.faqs.map((faq) => _buildFaqItem(faq)),
        ],
      ),
    );
  }

  Widget _buildFaqItem(FaqItem faq) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 12),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      title: Text(
        faq.question,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF374151),
        ),
      ),
      trailing: const Icon(Icons.expand_more, color: Color(0xFF9CA3AF)),
      children: [
        Text(
          faq.answer,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF312E81), Color(0xFF7C3AED), Color(0xFFEC4899)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿No encuentras lo que buscas?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Contacta a nuestro equipo de soporte técnico',
            style: TextStyle(fontSize: 14, color: Color(0xFFEDE9FE)),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.email_outlined,
            title: 'Email',
            value: 'soporte@Appdelanta.com',
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            icon: Icons.phone_outlined,
            title: 'Teléfono',
            value: '+57 (1) 234-5678',
          ),
          const SizedBox(height: 16),
          const Text(
            'Horario de atención: Lunes a Viernes 8:00 - 18:00',
            style: TextStyle(fontSize: 13, color: Color(0xFFEDE9FE)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7C3AED), size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FaqCategory {
  final String title;
  final int questionCount;
  final List<FaqItem> faqs;

  FaqCategory({
    required this.title,
    required this.questionCount,
    required this.faqs,
  });
}

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}
