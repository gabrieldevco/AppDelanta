import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/api_service.dart';
import '../../data/models/employee_contract_model.dart';
import '../../data/services/employee_contract_service.dart';

class EmployeeContractSignPage extends StatefulWidget {
  final EmployeeContractModel contract;

  const EmployeeContractSignPage({super.key, required this.contract});

  @override
  State<EmployeeContractSignPage> createState() =>
      _EmployeeContractSignPageState();
}

class _EmployeeContractSignPageState extends State<EmployeeContractSignPage> {
  final _signatureKey = GlobalKey();
  final List<Offset?> _points = [];
  late final EmployeeContractService _service;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _service = EmployeeContractService(apiService);
  }

  bool get _hasSignature => _points.whereType<Offset>().length > 4;

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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _buildContractSummary(),
                  const SizedBox(height: 16),
                  _buildSignaturePad(),
                  const SizedBox(height: 14),
                  _buildNotice(),
                  const SizedBox(height: 18),
                  _buildActions(),
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
      padding: const EdgeInsets.fromLTRB(10, 8, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFBBF7D0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A86B).withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            color: const Color(0xFF0F172A),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF8FAFC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'Firmar contrato',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF064E3B), Color(0xFF00A86B), Color(0xFF22C55E)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.description_outlined, color: Colors.white, size: 30),
          const SizedBox(height: 14),
          Text(
            widget.contract.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.contract.companyName,
            style: const TextStyle(
              color: Color(0xFFE8FFF2),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.contract.contractFileUrl == null
                  ? null
                  : () => launchUrl(
                      Uri.parse(widget.contract.contractFileUrl!),
                      mode: LaunchMode.externalApplication,
                    ),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Ver documento antes de firmar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignaturePad() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD1FAE5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Firma con tu dedo',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : () => setState(() => _points.clear()),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Limpiar'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          RepaintBoundary(
            key: _signatureKey,
            child: GestureDetector(
              onPanStart: (details) => _addPoint(details.localPosition),
              onPanUpdate: (details) => _addPoint(details.localPosition),
              onPanEnd: (_) => setState(() => _points.add(null)),
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBFEFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: CustomPaint(
                  painter: _SignaturePainter(_points),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFFD97706), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Al firmar confirmas que revisaste el documento y autorizas guardar tu firma digital asociada a este contrato.',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return FilledButton.icon(
      onPressed: !_hasSignature || _isSubmitting ? null : _submit,
      icon: _isSubmitting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.verified_rounded),
      label: Text(_isSubmitting ? 'Firmando' : 'Firmar contrato'),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF00A86B),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _addPoint(Offset point) {
    setState(() => _points.add(point));
  }

  Future<Uint8List?> _captureSignature() async {
    final boundary =
        _signatureKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _submit() async {
    final bytes = await _captureSignature();
    if (bytes == null) return;

    setState(() => _isSubmitting = true);
    try {
      await _service.signContract(
        contractId: widget.contract.id,
        signatureBytes: bytes,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo firmar: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    }
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  _SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.2;

    final guidePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(18, size.height - 34),
      Offset(size.width - 18, size.height - 34),
      guidePaint,
    );

    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      if (current != null && next != null) {
        canvas.drawLine(current, next, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
