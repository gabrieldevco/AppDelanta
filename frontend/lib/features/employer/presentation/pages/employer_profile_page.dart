import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_popup.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../companies/presentation/providers/company_provider.dart';
import '../widgets/employer_header.dart';
import '../widgets/employer_notifications_drawer.dart';

class EmployerProfilePage extends StatefulWidget {
  const EmployerProfilePage({super.key});

  @override
  State<EmployerProfilePage> createState() => _EmployerProfilePageState();
}

class _EmployerProfilePageState extends State<EmployerProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;
  bool _saving = false;

  static const _ink = Color(0xFF172033);
  static const _muted = Color(0xFF718096);
  static const _warmLine = Color(0xFFE8EDF5);
  static const _softSurface = Color(0xFFFFFCF8);

  final _razonSocialController = TextEditingController();
  final _nombreComercialController = TextEditingController();
  final _emailController = TextEditingController();
  final _nitController = TextEditingController();
  final _phoneController = TextEditingController();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final provider = context.read<CompanyProvider>();
    await provider.loadMyCompany();
    final company = provider.myCompany;
    if (company == null || !mounted) return;
    setState(() {
      _razonSocialController.text = company.legalName ?? '';
      _nombreComercialController.text = company.name;
      _emailController.text = company.email ?? '';
      _nitController.text = company.taxId ?? '';
      _phoneController.text = company.phone ?? '';
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _razonSocialController.dispose();
    _nombreComercialController.dispose();
    _emailController.dispose();
    _nitController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      endDrawer: const EmployerNotificationsDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const EmployerHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mi Perfil',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: _ink,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildTabs(),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildCompanyTab(), _buildSecurityTab()],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        backgroundColor: const Color(0xFF1D4ED8),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        label: const Text(
          'Volver',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _softSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _warmLine),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172033).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF06B6D4)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0284C7).withValues(alpha: 0.24),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: _muted,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        tabs: const [
          Tab(text: 'Datos de Empresa'),
          Tab(text: 'Seguridad'),
        ],
      ),
    );
  }

  Widget _buildCompanyTab() {
    return Consumer<CompanyProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.myCompany == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              _section(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Información',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: _ink,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _saving
                              ? null
                              : () {
                                  if (_isEditing) {
                                    _saveCompany();
                                  } else {
                                    setState(() => _isEditing = true);
                                  }
                                },
                          icon: Icon(
                            _isEditing ? Icons.check_rounded : Icons.edit,
                            size: 17,
                          ),
                          label: Text(_isEditing ? 'Guardar' : 'Editar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _field('Razón Social', _razonSocialController),
                    _field('Nombre Comercial', _nombreComercialController),
                    _field(
                      'Email',
                      _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _field(
                      'Teléfono',
                      _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    _field('NIT', _nitController, enabled: false),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _infoBox(
                icon: Icons.info,
                title: 'Información importante:',
                text:
                    'Mantén los datos de contacto actualizados para operar adelantos y recibir notificaciones. El NIT es obligatorio y solo puede modificarlo soporte.',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSecurityTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        _section(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cambiar contraseña',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: _ink,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 14),
              _passwordField('Contraseña actual', _currentPasswordController),
              _passwordField('Nueva contraseña', _newPasswordController),
              _passwordField(
                'Confirmar contraseña',
                _confirmPasswordController,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _changePassword,
                  icon: const Icon(Icons.key, size: 18),
                  label: const Text('Actualizar contraseña'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06172E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _infoBox(
          icon: Icons.lock,
          title: 'Seguridad de tu cuenta:',
          text:
              'Usa una contraseña única y no la compartas. El cambio se aplica inmediatamente en el backend.',
          color: const Color(0xFFFFFBEB),
          borderColor: const Color(0xFFFEF3C7),
          textColor: const Color(0xFF92400E),
        ),
      ],
    );
  }

  Widget _section({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _softSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _warmLine),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172033).withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    final active = enabled && _isEditing;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4A5568),
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 5),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: active ? 1 : 0.56,
            child: TextField(
              controller: controller,
              enabled: active,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                filled: true,
                fillColor: active
                    ? const Color(0xFFFFFFFF)
                    : const Color(0xFFF3F6FA),
                hintStyle: const TextStyle(color: Color(0xFFA0AEC0)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _warmLine),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFDDE6F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF38BDF8),
                    width: 1.3,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
              ),
              style: const TextStyle(
                color: _ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField(String label, TextEditingController controller) {
    return _ProfilePasswordField(label: label, controller: controller);
  }

  Widget _infoBox({
    required IconData icon,
    required String title,
    required String text,
    Color color = const Color(0xFFDBEAFE),
    Color borderColor = const Color(0xFFBFDBFE),
    Color textColor = const Color(0xFF1E40AF),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCompany() async {
    setState(() => _saving = true);
    final ok = await context.read<CompanyProvider>().updateCompany(
      name: _nombreComercialController.text.trim(),
      legalName: _razonSocialController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (ok) _isEditing = false;
    });
    await AppPopup.show(
      context,
      title: ok ? 'Perfil actualizado' : 'No se pudo actualizar',
      message: ok
          ? 'Los datos de tu empresa quedaron guardados correctamente.'
          : 'Revisa la informacion e intenta nuevamente.',
      type: ok ? AppPopupType.success : AppPopupType.error,
    );
    if (!mounted) return;
    if (ok) await context.read<AuthProvider>().refreshProfile();
  }

  Future<void> _changePassword() async {
    final newPassword = _newPasswordController.text;
    if (newPassword.length < 6 ||
        newPassword != _confirmPasswordController.text) {
      await AppPopup.show(
        context,
        title: 'Verifica la contrasena',
        message:
            'La nueva contrasena debe tener al menos 6 caracteres y coincidir con la confirmacion.',
        type: AppPopupType.warning,
      );
      return;
    }
    setState(() => _saving = true);
    final ok = await context.read<AuthProvider>().changePassword(
      oldPassword: _currentPasswordController.text,
      newPassword: newPassword,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }
    await AppPopup.show(
      context,
      title: ok ? 'Contrasena actualizada' : 'No se pudo actualizar',
      message: ok
          ? 'Tu contrasena fue cambiada correctamente.'
          : 'La contrasena actual no coincide o hubo un problema al actualizar.',
      type: ok ? AppPopupType.success : AppPopupType.error,
    );
  }
}

class _ProfilePasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;

  const _ProfilePasswordField({required this.label, required this.controller});

  @override
  State<_ProfilePasswordField> createState() => _ProfilePasswordFieldState();
}

class _ProfilePasswordFieldState extends State<_ProfilePasswordField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final showPasswordHint =
        _focusNode.hasFocus && widget.controller.text.isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        focusNode: _focusNode,
        controller: widget.controller,
        obscureText: true,
        obscuringCharacter: '*',
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
          color: _EmployerProfilePageState._ink,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        decoration: InputDecoration(
          hintText: showPasswordHint ? '********' : widget.label,
          hintStyle: TextStyle(
            color: showPasswordHint
                ? const Color(0xFFA0AEC0)
                : _EmployerProfilePageState._muted,
            fontWeight: FontWeight.w700,
            letterSpacing: showPasswordHint ? 1.4 : 0,
          ),
          filled: true,
          fillColor: const Color(0xFFF7F9FC),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: _EmployerProfilePageState._warmLine,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.3),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          suffixIcon: const Icon(Icons.visibility_off, size: 18),
        ),
      ),
    );
  }
}
