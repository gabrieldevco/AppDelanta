import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

Future<void> showLogoutConfirmationDialog(BuildContext context) {
  final pageContext = context;

  return showDialog<void>(
    context: pageContext,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.16),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 34,
                    height: 34,
                    child: IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      padding: EdgeInsets.zero,
                      tooltip: 'Cancelar',
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF8FAFC),
                        foregroundColor: const Color(0xFF64748B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ),
                ),
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDC2626).withValues(alpha: 0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFDC2626),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Cerrar sesion',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Se cerrara tu sesion en este dispositivo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF475569),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final navigator = Navigator.of(
                            pageContext,
                            rootNavigator: true,
                          );
                          final authProvider = pageContext.read<AuthProvider>();

                          Navigator.pop(dialogContext);
                          await authProvider.logout();

                          if (navigator.mounted) {
                            navigator.pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: const Text('Si, salir'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
