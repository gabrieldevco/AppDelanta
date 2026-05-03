import 'package:flutter/material.dart';
import '../widgets/employer_header.dart';
import '../widgets/employer_notifications_drawer.dart';

class EmployerHelpPage extends StatefulWidget {
  const EmployerHelpPage({super.key});

  @override
  State<EmployerHelpPage> createState() => _EmployerHelpPageState();
}

class _EmployerHelpPageState extends State<EmployerHelpPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<FaqCategory> _faqCategories = [
    FaqCategory(
      title: 'Adelantos',
      questionCount: 4,
      faqs: [
        FaqItem(
          question: '¿Cuánto dinero pueden solicitar mis empleados?',
          answer:
              'Los empleados pueden solicitar hasta el 50% de su salario acumulado en el mes actual. El límite exacto depende de su salario y los días trabajados.',
        ),
        FaqItem(
          question: '¿Cuánto tiempo tarda en llegar el dinero?',
          answer:
              'El dinero se transfiere a la cuenta bancaria del empleado en menos de 24 horas hábiles después de aprobar la solicitud.',
        ),
        FaqItem(
          question: '¿Puede tener más de un adelanto activo?',
          answer:
              'No, cada empleado solo puede tener un adelanto activo a la vez. Debe pagar el adelanto actual antes de solicitar uno nuevo.',
        ),
        FaqItem(
          question: '¿Por cuántos días pueden solicitar un adelanto?',
          answer:
              'Los empleados pueden solicitar adelantos en cualquier momento del mes. No hay restricción de días específicos.',
        ),
      ],
    ),
    FaqCategory(
      title: 'Costos',
      questionCount: 3,
      faqs: [
        FaqItem(
          question: '¿Cuánto cuesta un adelanto para mi empresa?',
          answer:
              'Para el empleador es completamente gratuito. El empleador NO paga ningún fee ni interés.',
        ),
        FaqItem(
          question: '¿Cómo se calcula el interés?',
          answer:
              'El interés es calculado sobre el monto adelantado y es pagado por el empleado. La tasa es competitiva y se muestra antes de confirmar la solicitud.',
        ),
        FaqItem(
          question: '¿Pueden pagar antes de tiempo?',
          answer:
              'Sí, los empleados pueden realizar pagos anticipados en cualquier momento sin penalización.',
        ),
      ],
    ),
    FaqCategory(
      title: 'Proceso',
      questionCount: 3,
      faqs: [
        FaqItem(
          question: '¿Cómo solicitan un adelanto mis empleados?',
          answer:
              'Los empleados descargan la app de Appdelanta, se registran con su documento y el código de tu empresa, y solicitan el adelanto desde la app.',
        ),
        FaqItem(
          question: '¿Qué pasa si rechazo una solicitud?',
          answer:
              'El empleado recibe una notificación con el rechazo. Puede volver a solicitar cuando cumpla con los requisitos.',
        ),
        FaqItem(
          question: '¿Cómo se descuenta el adelanto de la nómina?',
          answer:
              'Tú como empleador recibes un reporte mensual con los descuentos a realizar. El descuento se hace directamente en la nómina del empleado.',
        ),
      ],
    ),
    FaqCategory(
      title: 'Cuenta',
      questionCount: 3,
      faqs: [
        FaqItem(
          question: '¿Cómo actualizo la información de mi empresa?',
          answer:
              'Ve a "Mi Perfil" > "Datos de la Empresa" y podrás actualizar la información bancaria y de contacto.',
        ),
        FaqItem(
          question: '¿Cómo cambio mi contraseña?',
          answer:
              'En "Mi Perfil" > "Seguridad" puedes cambiar tu contraseña. Se requiere la contraseña actual para confirmar.',
        ),
        FaqItem(
          question: '¿Qué hago si olvidé mi contraseña?',
          answer:
              'En la pantalla de login, presiona "¿Olvidaste tu contraseña?" y te enviaremos un enlace de recuperación a tu email.',
        ),
      ],
    ),
    FaqCategory(
      title: 'Seguridad',
      questionCount: 3,
      faqs: [
        FaqItem(
          question: '¿Es seguro usar Appdelanta?',
          answer:
              'Sí, utilizamos encriptación de nivel bancario (256-bit SSL) y cumplimos con todas las normativas de protección de datos.',
        ),
        FaqItem(
          question: '¿Quién puede ver la información de mis empleados?',
          answer:
              'Solo tú como empleador tienes acceso a la información básica. Los datos bancarios son encriptados y solo se usan para transferencias.',
        ),
        FaqItem(
          question: '¿Qué hago si veo actividad sospechosa?',
          answer:
              'Contacta inmediatamente a nuestro equipo de soporte al +57 (1) 234-5678 o soporte@Appdelanta.com y bloquearemos temporalmente la cuenta.',
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
      endDrawer: const EmployerNotificationsDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const EmployerHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
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
                      'Encuentra respuestas a tus preguntas',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF64748B),
                      ),
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
        backgroundColor: const Color(0xFF1D4ED8),
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
        border: Border.all(color: const Color(0xFFBFDBFE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.10),
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
          prefixIcon: const Icon(Icons.search, color: Color(0xFF0284C7)),
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
          colors: [Color(0xFF0F172A), Color(0xFF1D4ED8), Color(0xFF06B6D4)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.22),
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
            child: const Icon(Icons.support_agent, color: Colors.white),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Soporte para tu empresa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Resuelve dudas de adelantos, nomina, costos y seguridad.',
                  style: TextStyle(
                    color: Color(0xFFE0F2FE),
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
        border: Border.all(color: const Color(0xFFE0F2FE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.07),
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
                    colors: [Color(0xFF1D4ED8), Color(0xFF06B6D4)],
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
          colors: [Color(0xFF0F172A), Color(0xFF1D4ED8), Color(0xFF06B6D4)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.24),
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
            'Contacta a nuestro equipo de soporte',
            style: TextStyle(fontSize: 14, color: Color(0xFFE0F2FE)),
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
            style: TextStyle(fontSize: 13, color: Color(0xFFE0F2FE)),
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
          Icon(icon, color: const Color(0xFF0284C7), size: 20),
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
