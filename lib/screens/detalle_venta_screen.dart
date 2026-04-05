import 'package:bdp/database/papeleriadb.dart';
import 'package:bdp/models/venta_model.dart';
import 'package:bdp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetalleVentaScreen extends StatefulWidget {
  final Venta venta;
  const DetalleVentaScreen({super.key, required this.venta});
  @override
  State<DetalleVentaScreen> createState() => _DetalleVentaScreenState();
}
 
class _DetalleVentaScreenState extends State<DetalleVentaScreen> {
  final _db = PapeleriaDB();
  late Venta _venta;
  List<DetalleVenta> _detalles = [];
  bool _loading = true;
  bool _editMode = false;
 
  late TextEditingController _conNombre;
  late TextEditingController _conTelefono;
  late TextEditingController _conNotas;
  late DateTime _fechaEntrega;
 
  @override
  void initState() {
    super.initState();
    _venta = widget.venta;
    _conNombre   = TextEditingController(text: _venta.clienteNombre);
    _conTelefono = TextEditingController(text: _venta.clienteTelefono);
    _conNotas    = TextEditingController(text: _venta.notas ?? '');
    _fechaEntrega = _venta.fechaEntrega;
    _cargarDetalles();
  }
 
  @override
  void dispose() {
    _conNombre.dispose();
    _conTelefono.dispose();
    _conNotas.dispose();
    super.dispose();
  }
 
  Future<void> _cargarDetalles() async {
    setState(() => _loading = true);
    final d = await _db.getDetallesPorVenta(_venta.idVenta!);
    setState(() { _detalles = d; _loading = false; });
  }
 
  @override
  Widget build(BuildContext context) {
    final sc  = AppTheme.getStatusColor(_venta.estatus);
    final si  = AppTheme.getStatusIcon(_venta.estatus);
    final fmt = DateFormat('dd/MM/yyyy');
 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Venta'),
        actions: [
          IconButton(
            icon: Icon(_editMode ? Icons.close_rounded : Icons.edit_rounded),
            onPressed: () => setState(() => _editMode = !_editMode),
          ),
        ],
      ),
      body: CustomScrollView(slivers: [
 
        // Header status
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [sc.withOpacity(0.15), sc.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sc.withOpacity(0.3)),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: sc.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(si, color: sc, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_venta.clienteNombre,
                      style: const TextStyle(fontWeight: FontWeight.w700,
                          fontSize: 18, color: AppTheme.textDark)),
                  const SizedBox(height: 4),
                  Text(_venta.clienteTelefono,
                      style: const TextStyle(color: AppTheme.textMid, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: sc, borderRadius: BorderRadius.circular(20)),
                    child: Text(_venta.estatusTexto,
                        style: const TextStyle(color: Colors.white,
                            fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                ],
              )),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('\$${_venta.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700,
                        fontSize: 22, color: AppTheme.primary)),
                const Text('Total',
                    style: TextStyle(color: AppTheme.textMid, fontSize: 11)),
              ]),
            ]),
          ),
        ),
 
        // Fechas
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Expanded(child: _InfoTile(
                icon: Icons.calendar_today_rounded, label: 'Fecha venta',
                value: fmt.format(_venta.fechaVenta), color: AppTheme.primary)),
              const SizedBox(width: 12),
              Expanded(child: _InfoTile(
                icon: Icons.event_rounded, label: 'Fecha entrega',
                value: fmt.format(_venta.fechaEntrega), color: sc)),
            ]),
          ),
        ),
 
        // Formulario edición
        if (_editMode)
          SliverToBoxAdapter(child: _buildEditForm()),
 
        // Cambio de estatus
        if (!_editMode)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Cambiar estatus',
                    style: TextStyle(fontWeight: FontWeight.w700,
                        fontSize: 15, color: AppTheme.textDark)),
                const SizedBox(height: 10),
                Row(children: [
                  _StatusBtn(label: 'En proceso', color: AppTheme.statusEnProceso,
                      icon: Icons.hourglass_empty_rounded,
                      selected: _venta.estatus == 0, onTap: () => _cambiarEstatus(0)),
                  const SizedBox(width: 8),
                  _StatusBtn(label: 'Completada', color: AppTheme.statusCompletada,
                      icon: Icons.check_circle_rounded,
                      selected: _venta.estatus == 1, onTap: () => _cambiarEstatus(1)),
                  const SizedBox(width: 8),
                  _StatusBtn(label: 'Cancelada', color: AppTheme.statusCancelada,
                      icon: Icons.cancel_rounded,
                      selected: _venta.estatus == 2, onTap: () => _cambiarEstatus(2)),
                ]),
              ]),
            ),
          ),
 
        // Notas
        if (!_editMode && _venta.notas != null && _venta.notas!.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.notes_rounded, color: AppTheme.textMid, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_venta.notas!,
                        style: const TextStyle(color: AppTheme.textMid, fontSize: 13))),
                  ]),
                ),
              ),
            ),
          ),
 
        // Productos título
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          sliver: SliverToBoxAdapter(
            child: const Text('Productos',
                style: TextStyle(fontWeight: FontWeight.w700,
                    fontSize: 15, color: AppTheme.textDark)),
          ),
        ),
 
        // Detalles
        if (_loading)
          const SliverToBoxAdapter(
            child: Center(
              child: Padding(padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: AppTheme.primary))),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _DetalleItem(detalle: _detalles[i]),
                childCount: _detalles.length,
              ),
            ),
          ),
 
        // Eliminar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: _confirmarEliminar,
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppTheme.statusCancelada),
              label: const Text('Eliminar venta',
                  style: TextStyle(color: AppTheme.statusCancelada)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.statusCancelada),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
 
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ]),
    );
  }
 
  Widget _buildEditForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Editar datos',
                style: TextStyle(fontWeight: FontWeight.w700,
                    fontSize: 15, color: AppTheme.textDark)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _conNombre,
              decoration: const InputDecoration(
                  labelText: 'Nombre', prefixIcon: Icon(Icons.person_rounded)),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _conTelefono,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                  labelText: 'Teléfono', prefixIcon: Icon(Icons.phone_rounded)),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                final p = await showDatePicker(
                  context: context,
                  initialDate: _fechaEntrega,
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                        colorScheme: const ColorScheme.light(
                            primary: AppTheme.primary)),
                    child: child!,
                  ),
                );
                if (p != null) setState(() => _fechaEntrega = p);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'Fecha entrega',
                    prefixIcon: Icon(Icons.calendar_today_rounded)),
                child: Text(DateFormat('dd/MM/yyyy').format(_fechaEntrega)),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _conNotas,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'Notas', prefixIcon: Icon(Icons.notes_rounded),
                  alignLabelWithHint: true),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardarEdicion,
                child: const Text('Guardar cambios'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
 
  Future<void> _guardarEdicion() async {
    final updated = _venta.copyWith(
      clienteNombre: _conNombre.text.trim(),
      clienteTelefono: _conTelefono.text.trim(),
      fechaEntrega: _fechaEntrega,
      notas: _conNotas.text.trim(),
    );
    await _db.updateVenta(updated);
    setState(() { _venta = updated; _editMode = false; });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Venta actualizada'),
        backgroundColor: AppTheme.statusEnProceso,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
 
  Future<void> _cambiarEstatus(int estatus) async {
    final updated = _venta.copyWith(estatus: estatus);
    await _db.updateVenta(updated);
    setState(() => _venta = updated);
  }
 
  void _confirmarEliminar() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar venta'),
        content: const Text('¿Deseas eliminar esta venta permanentemente?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusCancelada),
            onPressed: () async {
              await _db.deleteVenta(_venta.idVenta!);
              if (mounted) { Navigator.pop(ctx); Navigator.pop(context); }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
 
// ── Widgets auxiliares ───────────────────────────────────────────────────────
 
class _InfoTile extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  const _InfoTile({required this.icon, required this.label,
      required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(12),
      child: Row(children: [
        Icon(icon, color: color, size: 18), const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMid)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600,
              fontSize: 12, color: AppTheme.textDark)),
        ])),
      ]),
    ),
  );
}
 
class _StatusBtn extends StatelessWidget {
  final String label; final Color color; final IconData icon;
  final bool selected; final VoidCallback onTap;
  const _StatusBtn({required this.label, required this.color,
      required this.icon, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? color : Colors.transparent),
        ),
        child: Column(children: [
          Icon(icon, color: selected ? Colors.white : color, size: 18),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(color: selected ? Colors.white : color,
                  fontSize: 10, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
        ]),
      ),
    ),
  );
}
 
class _DetalleItem extends StatelessWidget {
  final DetalleVenta detalle;
  const _DetalleItem({required this.detalle});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: Padding(padding: const EdgeInsets.all(12),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.inventory_2_rounded,
              color: AppTheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(detalle.nombreProducto,
              style: const TextStyle(fontWeight: FontWeight.w600,
                  fontSize: 13, color: AppTheme.textDark)),
          Text('${detalle.cantidad} x \$${detalle.precioUnitario.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 11, color: AppTheme.textMid)),
        ])),
        Text('\$${detalle.subtotal.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w700,
                color: AppTheme.primary, fontSize: 14)),
      ]),
    ),
  );
}