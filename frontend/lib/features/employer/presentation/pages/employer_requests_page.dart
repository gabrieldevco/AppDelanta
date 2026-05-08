import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_popup.dart';
import '../../../advances/data/models/advance_model.dart';
import '../../../advances/presentation/providers/advance_provider.dart';
import '../widgets/employer_bottom_nav.dart';
import '../widgets/employer_header.dart';
import '../widgets/employer_notifications_drawer.dart';

class EmployerRequestsPage extends StatefulWidget {
  const EmployerRequestsPage({super.key});

  @override
  State<EmployerRequestsPage> createState() => _EmployerRequestsPageState();
}

class _EmployerRequestsPageState extends State<EmployerRequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await context.read<AdvanceProvider>().loadMyAdvances();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      endDrawer: const EmployerNotificationsDrawer(),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            const EmployerHeader(currentIndex: 1),
            Expanded(
              child: Consumer<AdvanceProvider>(
                builder: (context, provider, _) {
                  final pending = provider.advances
                      .where((a) => a.isPending)
                      .toList();
                  final approved = provider.advances
                      .where(
                        (a) => a.isApproved || a.isDisbursed || a.isRecovered,
                      )
                      .toList();
                  final rejected = provider.advances
                      .where((a) => a.isRejected || a.isCancelled)
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Solicitudes de Adelanto',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Aprueba o rechaza solicitudes',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _buildTabs(
                              pending.length,
                              approved.length,
                              rejected.length,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: provider.isLoading && provider.advances.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildList(pending, Icons.pending_actions),
                                  _buildList(
                                    approved,
                                    Icons.check_circle_outline,
                                  ),
                                  _buildList(rejected, Icons.cancel_outlined),
                                ],
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const EmployerBottomNav(currentIndex: 1),
    );
  }

  Widget _buildTabs(int pending, int approved, int rejected) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        return Container(
          height: 52,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: _requestTabColor(
                  _tabController.index,
                ).withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildStatusTab(
                index: 0,
                label: 'Pendientes',
                count: pending,
                color: const Color(0xFFF59E0B),
                endColor: const Color(0xFFFBBF24),
              ),
              _buildStatusTab(
                index: 1,
                label: 'Aprobadas',
                count: approved,
                color: const Color(0xFF059669),
                endColor: const Color(0xFF10B981),
              ),
              _buildStatusTab(
                index: 2,
                label: 'Rechazadas',
                count: rejected,
                color: const Color(0xFFDC2626),
                endColor: const Color(0xFFEF4444),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusTab({
    required int index,
    required String label,
    required int count,
    required Color color,
    required Color endColor,
  }) {
    final selected = _tabController.index == index;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (_tabController.index != index) {
              _tabController.animateTo(index, duration: Duration.zero);
            }
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: selected
                  ? LinearGradient(colors: [color, endColor])
                  : null,
              color: selected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? Colors.transparent : const Color(0xFFE2E8F0),
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.22),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              '$label $count',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF64748B),
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _requestTabColor(int index) {
    return switch (index) {
      1 => const Color(0xFF059669),
      2 => const Color(0xFFDC2626),
      _ => const Color(0xFFF59E0B),
    };
  }

  Widget _buildList(List<AdvanceModel> advances, IconData emptyIcon) {
    if (advances.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.22),
            Icon(emptyIcon, size: 64, color: const Color(0xFFCBD5E1)),
            const SizedBox(height: 14),
            const Center(
              child: Text(
                'No hay solicitudes en esta categoría',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: advances.length,
        itemBuilder: (context, index) => _buildRequestCard(advances[index]),
      ),
    );
  }

  Widget _buildRequestCard(AdvanceModel advance) {
    final color = _statusColor(advance.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0F2FE)),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  advance.employeeName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              _statusChip(advance.statusDisplay, color),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _miniStat('Monto', _money(advance.amount))),
              const SizedBox(width: 10),
              Expanded(child: _miniStat('Fee', _money(advance.fee))),
              const SizedBox(width: 10),
              Expanded(child: _miniStat('Total', _money(advance.totalAmount))),
            ],
          ),
          if ((advance.reason ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              advance.reason!,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Solicitado el ${_date(advance.requestDate)}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showAuthorizationDocument(advance),
              icon: const Icon(Icons.description_outlined, size: 18),
              label: const Text('Ver documento de autorizacion'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF047857),
                side: const BorderSide(color: Color(0xFFA7F3D0)),
                backgroundColor: const Color(0xFFECFDF5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          if (advance.isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _reject(advance),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Rechazar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFECACA)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approve(advance),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Aprobar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D4ED8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showAuthorizationDocument(AdvanceModel advance) {
    final data = advance.authorizationData;
    if (data == null || data.isEmpty) {
      AppPopup.show(
        context,
        title: 'Documento no disponible',
        message: 'Esta solicitud no tiene una autorizacion digital asociada.',
        type: AppPopupType.warning,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _AdvanceAuthorizationDocumentPage(advance: advance, money: _money),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FAFC), Color(0xFFE0F2FE)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE0F2FE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Future<void> _approve(AdvanceModel advance) async {
    final ok = await context.read<AdvanceProvider>().approveAdvance(advance.id);
    if (!mounted) return;
    await AppPopup.show(
      context,
      title: ok ? 'Solicitud aprobada' : 'No se pudo aprobar',
      message: ok
          ? 'La solicitud fue aprobada correctamente.'
          : 'No se pudo aprobar la solicitud. Intenta nuevamente.',
      type: ok ? AppPopupType.success : AppPopupType.error,
    );
    if (ok) {
      _tabController.animateTo(1);
    }
    await _load();
  }

  Future<void> _reject(AdvanceModel advance) async {
    final provider = context.read<AdvanceProvider>();
    final reason = await showDialog<String>(
      context: context,
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.52),
      builder: (dialogContext) =>
          _RejectAdvanceDialog(advance: advance, money: _money),
    );
    if (reason == null) return;

    final ok = await provider.rejectAdvance(
      advance.id,
      reason: reason.trim().isEmpty ? 'Sin especificar' : reason.trim(),
    );
    if (!mounted) return;
    await AppPopup.show(
      context,
      title: ok ? 'Solicitud rechazada' : 'No se pudo rechazar',
      message: ok
          ? 'La solicitud fue rechazada correctamente.'
          : 'No se pudo rechazar la solicitud. Intenta nuevamente.',
      type: AppPopupType.error,
    );
    if (ok) {
      _tabController.animateTo(2);
    }
    await _load();
  }

  Color _statusColor(String status) {
    return switch (status) {
      'approved' => const Color(0xFF1D4ED8),
      'disbursed' || 'recovered' => const Color(0xFF0891B2),
      'rejected' || 'cancelled' => const Color(0xFFDC2626),
      _ => const Color(0xFFF59E0B),
    };
  }

  String _date(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String _money(num value) {
    final text = value.round().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '\$ $text';
  }
}

class _RejectAdvanceDialog extends StatefulWidget {
  final AdvanceModel advance;
  final String Function(num value) money;

  const _RejectAdvanceDialog({required this.advance, required this.money});

  @override
  State<_RejectAdvanceDialog> createState() => _RejectAdvanceDialogState();
}

class _RejectAdvanceDialogState extends State<_RejectAdvanceDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close(BuildContext context, [String? reason]) {
    try {
      Navigator.maybePop<String>(context, reason).catchError((_) => false);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.fromLTRB(18, 18, 18, 18 + bottomInset),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.22),
                    blurRadius: 34,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 16, 18),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF7F1D1D),
                            Color(0xFFDC2626),
                            Color(0xFFF97316),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.22),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.block_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => _close(context),
                                icon: const Icon(Icons.close_rounded),
                                color: Colors.white,
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Rechazar solicitud',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${widget.advance.employeeName} solicito ${widget.money(widget.advance.amount)}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFFFEDD5),
                              fontSize: 13,
                              height: 1.3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Motivo del rechazo',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _controller,
                            autofocus: true,
                            minLines: 3,
                            maxLines: 4,
                            cursorColor: const Color(0xFFDC2626),
                            decoration: InputDecoration(
                              hintText:
                                  'Ej: datos incompletos, cupo agotado...',
                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 13,
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(bottom: 54),
                                child: Icon(
                                  Icons.edit_note_rounded,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.fromLTRB(
                                14,
                                16,
                                14,
                                16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                  color: Color(0xFFFECACA),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                  color: Color(0xFFDC2626),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFED7AA),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: Color(0xFFEA580C),
                                  size: 19,
                                ),
                                SizedBox(width: 9),
                                Expanded(
                                  child: Text(
                                    'El empleado vera este motivo en su historial de solicitudes.',
                                    style: TextStyle(
                                      color: Color(0xFF9A3412),
                                      fontSize: 12,
                                      height: 1.25,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _close(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF64748B),
                                side: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                                minimumSize: const Size(0, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () =>
                                  _close(context, _controller.text),
                              icon: const Icon(Icons.close_rounded, size: 18),
                              label: const Text('Rechazar'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                textStyle: const TextStyle(
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
          ),
        ),
      ),
    );
  }
}

class _AdvanceAuthorizationDocumentPage extends StatelessWidget {
  final AdvanceModel advance;
  final String Function(num value) money;

  const _AdvanceAuthorizationDocumentPage({
    required this.advance,
    required this.money,
  });

  Map<String, dynamic> get _data => advance.authorizationData ?? {};

  String _text(String key, [String fallback = 'No registrado']) {
    final value = _data[key];
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  List<Offset?> _signaturePoints() {
    final raw = _data['signature_points'];
    if (raw is! List) return const [];

    return raw.map<Offset?>((item) {
      if (item == null) return null;
      if (item is! Map) return null;
      final x = item['x'];
      final y = item['y'];
      final dx = x is num ? x.toDouble() : double.tryParse('$x');
      final dy = y is num ? y.toDouble() : double.tryParse('$y');
      if (dx == null || dy == null) return null;
      return Offset(dx, dy);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final points = _signaturePoints();
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  _summaryHeader(),
                  const SizedBox(height: 14),
                  _section(
                    title: 'Empresa',
                    icon: Icons.apartment_outlined,
                    child: _dataRows([
                      MapEntry(
                        'Nombre',
                        _text('company_name', advance.companyName),
                      ),
                      MapEntry('NIT', _text('company_tax_id')),
                      MapEntry('Direccion', _text('company_address')),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  _section(
                    title: 'Empleado',
                    icon: Icons.badge_outlined,
                    child: _dataRows([
                      MapEntry(
                        'Nombre',
                        _text('employee_name', advance.employeeName),
                      ),
                      MapEntry(
                        'Cedula',
                        _text(
                          'employee_document',
                          advance.employeeDocument ?? 'No registrado',
                        ),
                      ),
                      MapEntry('Cargo', _text('employee_position')),
                      MapEntry(
                        'Telefono',
                        _text(
                          'employee_phone',
                          advance.employeePhone ?? 'No registrado',
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  _section(
                    title: 'Detalle del adelanto',
                    icon: Icons.payments_outlined,
                    child: _dataRows([
                      MapEntry(
                        'Monto solicitado',
                        money(_num('amount', advance.amount)),
                      ),
                      MapEntry('Fee', money(_num('fee', advance.fee))),
                      MapEntry('Interes', money(_num('interest', 0))),
                      MapEntry(
                        'Total a descontar',
                        money(_num('total_amount', advance.totalAmount)),
                      ),
                      MapEntry('Fecha solicitud', _text('request_date')),
                      MapEntry('Fecha descuento', _text('discount_date')),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  _section(
                    title: 'Autorizacion',
                    icon: Icons.verified_user_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yo, ${_text('employee_name', advance.employeeName)}, identificado(a) como aparece al pie de mi firma, en calidad de empleado(a) de ${_text('company_name', advance.companyName)}, autorizo de manera expresa, libre y voluntaria a mi empleador para que realice descuentos de mi salario por concepto de adelantos de nomina solicitados a traves de la plataforma AppDelanta.',
                          style: _bodyStyle,
                        ),
                        const Divider(height: 28),
                        _declaration(
                          'La solicitud del adelanto fue realizada por el empleado de manera voluntaria.',
                        ),
                        _declaration(
                          'El empleado fue informado previamente del valor total a descontar.',
                        ),
                        _declaration(
                          'El empleado autorizo el descuento en nomina en la fecha indicada.',
                        ),
                        _declaration(
                          'El descuento no constituye una sancion ni afecta derechos laborales.',
                        ),
                        _declaration(
                          'En caso de retiro, autorizo descuento de la liquidacion final.',
                        ),
                        const Divider(height: 28),
                        Text(
                          'Autorizacion de tratamiento de datos personales conforme a la politica de privacidad de ${_text('company_name', advance.companyName)} y AppDelanta.',
                          style: _bodyStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _section(
                    title: 'Firma digital',
                    icon: Icons.draw_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 170,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: points.whereType<Offset>().length < 2
                              ? const Center(
                                  child: Text(
                                    'Firma no disponible',
                                    style: TextStyle(color: Color(0xFF94A3B8)),
                                  ),
                                )
                              : CustomPaint(
                                  painter: _AuthorizationSignaturePainter(
                                    points,
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                        ),
                        const SizedBox(height: 12),
                        _dataRows([
                          MapEntry(
                            'Firmado por',
                            _text('employee_name', advance.employeeName),
                          ),
                          MapEntry(
                            'Cedula',
                            _text(
                              'employee_document',
                              advance.employeeDocument ?? 'No registrado',
                            ),
                          ),
                          MapEntry('Fecha firma', _signedAt()),
                        ]),
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

  num _num(String key, num fallback) {
    final value = _data[key];
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _signedAt() {
    final raw = _data['signed_at']?.toString();
    final parsed = raw == null ? null : DateTime.tryParse(raw);
    if (parsed == null) return _text('signed_at', 'No registrado');
    return '${parsed.day}/${parsed.month}/${parsed.year} ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
  }

  Widget _topBar(BuildContext context) {
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
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Documento de autorizacion',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Autorizacion enviada por el empleado',
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

  Widget _summaryHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.description_outlined, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  advance.employeeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Total autorizado ${money(_num('total_amount', advance.totalAmount))}',
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF047857), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
                    width: 128,
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

class _AuthorizationSignaturePainter extends CustomPainter {
  final List<Offset?> points;

  const _AuthorizationSignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final fitted = _fitPoints(size);
    final paint = Paint()
      ..color = const Color(0xFF111827)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.8;

    for (var i = 0; i < fitted.length - 1; i++) {
      final current = fitted[i];
      final next = fitted[i + 1];
      if (current == null || next == null) continue;
      canvas.drawLine(current, next, paint);
    }
  }

  List<Offset?> _fitPoints(Size size) {
    final realPoints = points.whereType<Offset>().toList();
    if (realPoints.isEmpty) return points;

    var minX = realPoints.first.dx;
    var maxX = realPoints.first.dx;
    var minY = realPoints.first.dy;
    var maxY = realPoints.first.dy;

    for (final point in realPoints.skip(1)) {
      if (point.dx < minX) minX = point.dx;
      if (point.dx > maxX) maxX = point.dx;
      if (point.dy < minY) minY = point.dy;
      if (point.dy > maxY) maxY = point.dy;
    }

    const padding = 14.0;
    final width = (maxX - minX).abs();
    final height = (maxY - minY).abs();
    final scaleX = width == 0 ? 1.0 : (size.width - padding * 2) / width;
    final scaleY = height == 0 ? 1.0 : (size.height - padding * 2) / height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    return points.map((point) {
      if (point == null) return null;
      return Offset(
        (point.dx - minX) * scale + padding,
        (point.dy - minY) * scale + padding,
      );
    }).toList();
  }

  @override
  bool shouldRepaint(covariant _AuthorizationSignaturePainter oldDelegate) {
    return true;
  }
}
