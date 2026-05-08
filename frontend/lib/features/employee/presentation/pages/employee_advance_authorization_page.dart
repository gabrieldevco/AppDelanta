import 'package:flutter/material.dart';

import '../../../../core/widgets/app_popup.dart';
import '../../../auth/data/models/user_model.dart';

class EmployeeAdvanceAuthorizationPage extends StatefulWidget {
  final UserModel? user;
  final double amount;
  final double fee;
  final double interest;
  final double total;
  final int days;

  const EmployeeAdvanceAuthorizationPage({
    super.key,
    required this.user,
    required this.amount,
    required this.fee,
    required this.interest,
    required this.total,
    required this.days,
  });

  @override
  State<EmployeeAdvanceAuthorizationPage> createState() =>
      _EmployeeAdvanceAuthorizationPageState();
}

class _EmployeeAdvanceAuthorizationPageState
    extends State<EmployeeAdvanceAuthorizationPage> {
  final _positionController = TextEditingController();
  late final TextEditingController _phoneController;
  final List<Offset?> _signaturePoints = [];

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(
      text: widget.user?.phone?.trim() ?? '',
    );
  }

  @override
  void dispose() {
    _positionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  EmployeeProfile? get _profile => widget.user?.employeeProfile;

  bool get _hasSignature => _signaturePoints.whereType<Offset>().length >= 2;

  String _formatCurrency(double value) {
    String result = value.toStringAsFixed(0);
    result = result.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return result;
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  String _textOrPending(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? 'No registrado' : text;
  }

  String get _requestDate => _formatDate(DateTime.now());

  String get _discountDate =>
      _formatDate(DateTime.now().add(Duration(days: widget.days)));

  String get _companyName => _textOrPending(_profile?.companyName);

  String get _companyNit {
    final value = _profile?.companyTaxId?.trim() ?? '';
    return value.isEmpty ? 'No registrado' : value;
  }

  String get _companyAddress {
    final value = _profile?.companyAddress?.trim() ?? '';
    return value.isEmpty ? 'No registrado' : value;
  }

  String get _employeeName => _textOrPending(widget.user?.fullName);

  String get _documentNumber => _textOrPending(widget.user?.documentNumber);

  bool _isMissing(String value) {
    final text = value.trim();
    return text.isEmpty || text == 'No registrado';
  }

  Future<void> _showMessage(String title, String message) {
    FocusScope.of(context).unfocus();
    return AppPopup.show(
      context,
      title: title,
      message: message,
      type: AppPopupType.warning,
    );
  }

  Future<void> _authorize() async {
    final companyTaxId = _companyNit;
    final companyAddress = _companyAddress;
    final position = _positionController.text.trim();
    final phone = _phoneController.text.trim();

    if (_isMissing(_companyName) ||
        _isMissing(companyTaxId) ||
        _isMissing(companyAddress)) {
      await _showMessage(
        'Datos de empresa incompletos',
        'Faltan datos de la empresa vinculada. Pide al empleador completar nombre, NIT y direccion.',
      );
      return;
    }
    if (_isMissing(_employeeName) || _isMissing(_documentNumber)) {
      await _showMessage(
        'Datos del empleado incompletos',
        'Faltan tus datos de identificacion. Actualiza tu perfil antes de solicitar.',
      );
      return;
    }
    if (_positionController.text.trim().isEmpty) {
      await _showMessage(
        'Cargo requerido',
        'Ingresa tu cargo para completar la autorizacion.',
      );
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      await _showMessage(
        'Telefono requerido',
        'Ingresa tu telefono para completar la autorizacion.',
      );
      return;
    }
    if (!_hasSignature) {
      await _showMessage(
        'Firma requerida',
        'Firma digitalmente la autorizacion antes de continuar.',
      );
      return;
    }

    Navigator.pop(context, {
      'company_name': _companyName,
      'company_tax_id': companyTaxId,
      'company_address': companyAddress,
      'employee_name': _employeeName,
      'employee_document': _documentNumber,
      'employee_position': position,
      'employee_phone': phone,
      'amount': widget.amount,
      'fee': widget.fee,
      'interest': widget.interest,
      'total_amount': widget.total,
      'request_date': _requestDate,
      'discount_date': _discountDate,
      'signed_at': DateTime.now().toIso8601String(),
      'signature_points': _signaturePoints
          .map((point) => point == null ? null : {'x': point.dx, 'y': point.dy})
          .toList(),
      'accepted_declarations': true,
      'accepted_data_processing': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  _buildSummaryBand(),
                  const SizedBox(height: 14),
                  _buildContract(),
                  const SizedBox(height: 14),
                  _buildSignaturePad(),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: _authorize,
                      icon: const Icon(Icons.verified_user_outlined),
                      label: const Text('Autorizar y solicitar adelanto'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF00A86B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
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
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 14, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            color: const Color(0xFF0F172A),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Autorizacion de descuento',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Revisa el contrato y firma digitalmente',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
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

  Widget _buildSummaryBand() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.payments_outlined, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total a descontar',
                  style: TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '\$ ${_formatCurrency(widget.total)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _discountDate,
            style: const TextStyle(
              color: Color(0xFFA7F3D0),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContract() {
    return _section(
      title: 'Contrato de autorizacion',
      icon: Icons.description_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dataRows([
            MapEntry('Empresa', _companyName),
            MapEntry('NIT', _companyNit),
            MapEntry('Direccion', _companyAddress),
          ]),
          const Divider(height: 28),
          _dataRows([
            MapEntry('Empleado', _employeeName),
            MapEntry('Cedula', _documentNumber),
          ]),
          const SizedBox(height: 12),
          _input(
            label: 'Cargo',
            controller: _positionController,
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 12),
          _input(
            label: 'Telefono',
            controller: _phoneController,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const Divider(height: 28),
          Text(
            'Yo, $_employeeName, identificado(a) como aparece al pie de mi firma, en calidad de empleado(a) de $_companyName, autorizo de manera expresa, libre y voluntaria a mi empleador para que realice descuentos de mi salario por concepto de adelantos de nomina solicitados a traves de la plataforma AppDelanta.',
            style: _bodyStyle,
          ),
          const SizedBox(height: 16),
          _dataRows([
            MapEntry(
              'Monto solicitado',
              '\$ ${_formatCurrency(widget.amount)}',
            ),
            MapEntry('Fecha de solicitud', _requestDate),
            MapEntry('Fecha de descuento', _discountDate),
            MapEntry(
              'Valor total a descontar',
              '\$ ${_formatCurrency(widget.total)}',
            ),
          ]),
          const SizedBox(height: 8),
          const Text(
            'Incluye capital + costos asociados informados previamente.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          const Divider(height: 28),
          _declaration(
            'La solicitud del adelanto fue realizada por mi de manera voluntaria.',
          ),
          _declaration(
            'Fui informado previamente del valor total a descontar.',
          ),
          _declaration(
            'Autorizo el descuento en mi nomina en la fecha indicada.',
          ),
          _declaration(
            'Entiendo que este descuento no constituye una sancion ni afecta mis derechos laborales.',
          ),
          _declaration(
            'En caso de retiro de la empresa antes del descuento, autorizo que el valor sea descontado de mi liquidacion final.',
          ),
          const Divider(height: 28),
          Text(
            'Autorizo el tratamiento de mis datos personales conforme a la politica de privacidad de $_companyName y AppDelanta, en cumplimiento de la normativa vigente en Colombia.',
            style: _bodyStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildSignaturePad() {
    return _section(
      title: 'Firma digital',
      icon: Icons.draw_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Firma dentro del recuadro. El trazo queda asociado a esta autorizacion.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 260,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _hasSignature
                    ? const Color(0xFF00A86B)
                    : const Color(0xFFCBD5E1),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) {
                  setState(() => _signaturePoints.add(details.localPosition));
                },
                onPanUpdate: (details) {
                  setState(() => _signaturePoints.add(details.localPosition));
                },
                onPanEnd: (_) => setState(() => _signaturePoints.add(null)),
                child: CustomPaint(
                  painter: _SignaturePainter(_signaturePoints),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  _hasSignature
                      ? 'Firma registrada para $_employeeName'
                      : 'Pendiente de firma',
                  style: TextStyle(
                    color: _hasSignature
                        ? const Color(0xFF047857)
                        : const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _signaturePoints.clear()),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Limpiar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF00A86B), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _dataRows(List<MapEntry<String, String>> rows) {
    return Column(
      children: rows
          .map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 132,
                    child: Text(
                      row.key,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.value,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF00A86B)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _declaration(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF00A86B), size: 17),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: _bodyStyle)),
        ],
      ),
    );
  }

  TextStyle get _bodyStyle => const TextStyle(
    color: Color(0xFF334155),
    fontSize: 13,
    height: 1.45,
    fontWeight: FontWeight.w500,
  );
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  const _SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF111827)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3;

    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      if (current == null || next == null) continue;
      canvas.drawLine(current, next, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return true;
  }
}
