import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Codigo enviado a tu correo'),
        backgroundColor: const Color(0xFFF97316),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFBF6),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFF1E6),
                    Color(0xFFFFF7ED),
                    Color(0xFFFFFBF7),
                    Color(0xFFFFFFFF),
                  ],
                  stops: [0, 0.34, 0.68, 1],
                ),
              ),
            ),
          ),
          Positioned(
            top: -42,
            left: -56,
            right: -56,
            child: Transform.rotate(
              angle: -0.10,
              child: Container(
                height: 245,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFF7A1A).withValues(alpha: 0.26),
                      const Color(0xFFF97316).withValues(alpha: 0.18),
                      const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(36),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Volver al inicio'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF9A3412),
                      padding: EdgeInsets.zero,
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF101828,
                          ).withValues(alpha: 0.10),
                          blurRadius: 34,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF8A3D), Color(0xFFF97316)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFF97316,
                                ).withValues(alpha: 0.20),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mark_email_unread_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Recuperar contraseña',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF101828),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ingresa tu correo y te enviaremos las instrucciones para recuperar el acceso.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: Color(0xFF667085),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Correo electronico',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'correo@empresa.com',
                            prefixIcon: const Icon(
                              Icons.mail_outline_rounded,
                              color: Color(0xFF9A3412),
                              size: 20,
                            ),
                            hintStyle: const TextStyle(
                              color: Color(0xFFA8B3C2),
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFFFFBF7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFF1E4D6),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFF1E4D6),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFF97316),
                                width: 1.4,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFED7AA)),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFFB45309),
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'El codigo sera valido por 15 minutos. Revisa tambien tu carpeta de spam.',
                                  style: TextStyle(
                                    color: Color(0xFF9A3412),
                                    fontSize: 13,
                                    height: 1.35,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _sendCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF97316),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Enviar codigo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
