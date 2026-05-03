import 'package:flutter/material.dart';
import '../widgets/employee_header.dart';
import '../widgets/employee_notifications_drawer.dart';

class EmployeeHelpPage extends StatefulWidget {
  const EmployeeHelpPage({super.key});

  @override
  State<EmployeeHelpPage> createState() => _EmployeeHelpPageState();
}

class _EmployeeHelpPageState extends State<EmployeeHelpPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
    });
  }

  final List<FaqCategory> _categories = [
    FaqCategory(
      title: 'Adelantos',
      questionCount: 4,
      faqs: [
        FaqItem(
          question: '¿Cuánto dinero puedo solicitar?',
          answer:
              'Puedes solicitar hasta el 50% de tu salario mensual disponible, dependiendo de tu historial y el tiempo que lleves con tu empleador.',
        ),
        FaqItem(
          question: '¿Cuánto tiempo tarda en llegar el dinero?',
          answer:
              'El dinero llega a tu cuenta bancaria en máximo 24 horas hábiles después de que tu empleador apruebe la solicitud.',
        ),
        FaqItem(
          question: '¿Puedo tener más de un adelanto activo?',
          answer:
              'No, solo puedes tener un adelanto activo a la vez. Debes pagar el adelanto actual antes de solicitar uno nuevo.',
        ),
        FaqItem(
          question: '¿Por cuántos días puedo solicitar un adelanto?',
          answer:
              'Puedes solicitar adelantos por periodos de 7, 14, 21 o 30 días. Entre más días, menor es la tasa de interés.',
        ),
      ],
    ),
    FaqCategory(
      title: 'Costos',
      questionCount: 3,
      faqs: [
        FaqItem(
          question: '¿Cuánto me cuesta un adelanto?',
          answer:
              'El costo incluye una tasa de interés que varía según los días solicitados (1% - 2.5%) más una tarifa de servicio.',
        ),
        FaqItem(
          question: '¿Cómo se calcula el interés?',
          answer:
              'El interés se calcula sobre el monto solicitado multiplicado por la tasa diaria y el número de días.',
        ),
        FaqItem(
          question: '¿Puedo pagar antes de tiempo?',
          answer:
              'Sí, puedes pagar antes del vencimiento sin penalización. Solo pagarás los intereses correspondientes a los días transcurridos.',
        ),
      ],
    ),
    FaqCategory(
      title: 'Proceso',
      questionCount: 3,
      faqs: [
        FaqItem(
          question: '¿Cómo solicito un adelanto?',
          answer:
              'Ve a la pestaña "Solicitar", elige el monto y los días, revisa el costo total y confirma tu solicitud.',
        ),
        FaqItem(
          question: '¿Qué pasa si mi empleador rechaza mi solicitud?',
          answer:
              'Tu empleador puede rechazar la solicitud si no cumples con los requisitos. Podrás volver a intentarlo después de 15 días.',
        ),
        FaqItem(
          question: '¿Cómo se descuenta el adelanto?',
          answer:
              'El adelanto se descuenta automáticamente de tu nómina en la fecha acordada. Tu empleador realizará el descuento.',
        ),
      ],
    ),
    FaqCategory(
      title: 'Cuenta',
      questionCount: 3,
      faqs: [
        FaqItem(
          question: '¿Cómo actualizo mi información bancaria?',
          answer:
              'Ve a "Mi Perfil" > "Datos Personales" y edita tu información bancaria. Recuerda verificar que los datos sean correctos.',
        ),
        FaqItem(
          question: '¿Cómo cambio mi contraseña?',
          answer:
              'En "Mi Perfil" > "Seguridad" puedes cambiar tu contraseña. Debes ingresar tu contraseña actual y la nueva.',
        ),
        FaqItem(
          question: '¿Qué hago si olvidé mi contraseña?',
          answer:
              'En la pantalla de login, presiona "¿Olvidaste tu contraseña?" y sigue las instrucciones para restablecerla.',
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
              'Sí, usamos encriptación de nivel bancario para proteger tu información y todas las transacciones son seguras.',
        ),
        FaqItem(
          question: '¿Quién puede ver mi información?',
          answer:
              'Solo tú, tu empleador autorizado y nuestro equipo de soporte (bajo solicitud) pueden acceder a tu información.',
        ),
        FaqItem(
          question: '¿Qué hago si veo actividad sospechosa?',
          answer:
              'Cambia tu contraseña inmediatamente y contacta a soporte. Revisa tu historial de transacciones en la app.',
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FaqCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) {
      return _categories;
    }

    return _categories.where((category) {
      // Buscar en título de categoría
      if (category.title.toLowerCase().contains(_searchQuery)) {
        return true;
      }
      // Buscar en preguntas y respuestas
      return category.faqs.any((faq) {
        return faq.question.toLowerCase().contains(_searchQuery) ||
            faq.answer.toLowerCase().contains(_searchQuery);
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      endDrawer: const EmployeeNotificationsDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            const EmployeeHeader(),
            // Contenido scrollable
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
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Encuentra respuestas a tus preguntas',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Search bar
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    // Categorías de FAQ
                    if (_filteredCategories.isEmpty)
                      _buildEmptySearch()
                    else
                      ..._filteredCategories.map(
                        (category) => _buildFaqCategory(category),
                      ),
                    const SizedBox(height: 16),
                    // Card de contacto
                    _buildContactCard(),
                    const SizedBox(height: 20),
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
        backgroundColor: const Color(0xFF00A86B),
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
        border: Border.all(color: const Color(0xFF86EFAC)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A86B).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Buscar en preguntas frecuentes...',
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF00A86B)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFaqCategory(FaqCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header de categoría
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE9FFF2), Colors.white],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FFF2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    color: Color(0xFF00A86B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${category.questionCount} preguntas',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Lista de FAQs
          ...category.faqs.map((faq) => _buildFaqItem(faq)),
        ],
      ),
    );
  }

  Widget _buildFaqItem(FaqItem faq) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111827),
          ),
        ),
        trailing: const Icon(
          Icons.keyboard_arrow_down,
          color: Color(0xFF9CA3AF),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq.answer,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.search_off_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No se encontraron resultados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otras palabras clave',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00A86B), Color(0xFF22C55E)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A86B).withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿No encuentras lo que buscas?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Contacta a nuestro equipo de soporte',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFFE0F2FE),
            ),
          ),
          const SizedBox(height: 16),
          // Email
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  color: const Color(0xFF00A86B),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      'soporte@Appdelanta.com',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Teléfono
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  color: const Color(0xFF00A86B),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Teléfono',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      '+57 (1) 234-5678',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
