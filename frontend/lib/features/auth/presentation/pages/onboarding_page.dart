import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _motionController;
  int _currentPage = 0;

  final List<OnboardingData> _pages = const [
    OnboardingData(
      icon: Icons.payments_rounded,
      title: 'Adelanta tu nomina',
      description:
          'Solicita dinero de forma clara, rapida y segura antes de tu fecha de pago.',
      primaryColor: Color(0xFFF97316),
      secondaryColor: Color(0xFFEA580C),
      softColor: Color(0xFFFFF1E6),
      accentIcon: Icons.trending_flat_rounded,
    ),
    OnboardingData(
      icon: Icons.bolt_rounded,
      title: 'Dinero cuando cuenta',
      description:
          'Consulta tu cupo, elige el monto y sigue cada solicitud desde tu celular.',
      primaryColor: Color(0xFF0D9488),
      secondaryColor: Color(0xFF2563EB),
      softColor: Color(0xFFEFF6FF),
      accentIcon: Icons.phone_iphone_rounded,
    ),
    OnboardingData(
      icon: Icons.verified_user_rounded,
      title: 'Todo bajo control',
      description:
          'Empleados, empleadores y administradores trabajan con trazabilidad simple.',
      primaryColor: Color(0xFF7C3AED),
      secondaryColor: Color(0xFFDB2777),
      softColor: Color(0xFFF5F3FF),
      accentIcon: Icons.query_stats_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _motionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _pages[_currentPage];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [current.softColor, const Color(0xFFFFFBF7), Colors.white],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: _AnimatedBackdrop(data: current)),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                    child: Row(
                      children: [
                        _BrandChip(color: current.primaryColor),
                        const Spacer(),
                        TextButton(
                          onPressed: _finish,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF475467),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          child: const Text('Saltar'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) => setState(() {
                        _currentPage = index;
                      }),
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        return AnimatedBuilder(
                          animation: Listenable.merge([
                            _pageController,
                            _motionController,
                          ]),
                          builder: (context, child) {
                            final page = _pageController.hasClients
                                ? _pageController.page ??
                                      _currentPage.toDouble()
                                : _currentPage.toDouble();
                            final delta = (page - index).abs().clamp(0.0, 1.0);
                            final scale = 1 - (delta * 0.06);
                            final opacity = 1 - (delta * 0.28);
                            final lift =
                                math.sin(_motionController.value * math.pi) * 8;

                            return Opacity(
                              opacity: opacity,
                              child: Transform.translate(
                                offset: Offset(0, delta * 20),
                                child: Transform.scale(
                                  scale: scale,
                                  child: _buildPage(_pages[index], lift),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 6, 24, 30),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOut,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 28 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? current.primaryColor
                                    : const Color(0xFFD0D5DD),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _GradientButton(
                          label: _currentPage == _pages.length - 1
                              ? 'Comenzar'
                              : 'Siguiente',
                          icon: _currentPage == _pages.length - 1
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          colors: [
                            current.primaryColor,
                            current.secondaryColor,
                          ],
                          onPressed: _nextPage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data, double lift) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(0, -lift),
            child: Container(
              width: 218,
              height: 218,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(42),
                border: Border.all(color: Colors.white),
                boxShadow: [
                  BoxShadow(
                    color: data.primaryColor.withValues(alpha: 0.14),
                    blurRadius: 38,
                    offset: const Offset(0, 22),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 142,
                    height: 142,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [data.primaryColor, data.secondaryColor],
                      ),
                      borderRadius: BorderRadius.circular(38),
                    ),
                  ),
                  Icon(data.icon, size: 64, color: Colors.white),
                  Positioned(
                    right: 34,
                    bottom: 38,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Icon(
                        data.accentIcon,
                        size: 21,
                        color: data.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 36),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 360),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              data.title,
              key: ValueKey(data.title),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 31,
                height: 1.12,
                fontWeight: FontWeight.w900,
                color: Color(0xFF101828),
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF667085),
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBackdrop extends StatelessWidget {
  final OnboardingData data;

  const _AnimatedBackdrop({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 86,
          left: -70,
          child: _GlowOrb(color: data.primaryColor, size: 180, opacity: 0.12),
        ),
        Positioned(
          top: 190,
          right: -82,
          child: _GlowOrb(color: data.secondaryColor, size: 210, opacity: 0.10),
        ),
        Positioned(
          bottom: 120,
          left: 34,
          child: _MiniShape(color: data.primaryColor),
        ),
        Positioned(
          bottom: 220,
          right: 42,
          child: _MiniShape(color: data.secondaryColor, small: true),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _GlowOrb({
    required this.color,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }
}

class _MiniShape extends StatelessWidget {
  final Color color;
  final bool small;

  const _MiniShape({required this.color, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: small ? -0.25 : 0.35,
      child: Container(
        width: small ? 26 : 34,
        height: small ? 26 : 34,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.10)),
        ),
      ),
    );
  }
}

class _BrandChip extends StatelessWidget {
  final Color color;

  const _BrandChip({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          Icon(Icons.payments_rounded, size: 16, color: color),
          const SizedBox(width: 6),
          const Text(
            'Appdelanta',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF344054),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onPressed;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.colors,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.22),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final Color softColor;
  final IconData accentIcon;

  const OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.softColor,
    required this.accentIcon,
  });
}
