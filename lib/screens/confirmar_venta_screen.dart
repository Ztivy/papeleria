import 'package:bdp/database/papeleriadb.dart';
import 'package:bdp/models/venta_model.dart';
import 'package:bdp/providers/carrito_provider.dart';
import 'package:bdp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ConfirmarVentaScreen extends StatefulWidget {
  final String clienteNombre;
  final String clienteTelefono;
  final DateTime fechaEntrega;
  final String notas;
 
  const ConfirmarVentaScreen({
    super.key,
    required this.clienteNombre,
    required this.clienteTelefono,
    required this.fechaEntrega,
    required this.notas,
  });
 
  @override
  State<ConfirmarVentaScreen> createState() => _ConfirmarVentaScreenState();
}
 
class _ConfirmarVentaScreenState extends State<ConfirmarVentaScreen> {
  final _db = PapeleriaDB();
  bool _guardando = false;
 
  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();
    final fmt = DateFormat('dd/MM/yyyy');
 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Venta'),
      ),
      body: CustomScrollView(
        slivers: [
 
          // ── Datos del cliente ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('Datos del cliente',
                      style: TextStyle(fontWeight: FontWeight.w700,
                          fontSize: 15, color: AppTheme.textDark)),
                ]),
                const SizedBox(height: 12),
                _DatoFila(icono: Icons.person_outline_rounded,
                    label: 'Nombre', valor: widget.clienteNombre),
                const SizedBox(height: 8),
                _DatoFila(icono: Icons.phone_outlined,
                    label: 'Teléfono',
                    valor: widget.clienteTelefono.isEmpty
                        ? 'Sin teléfono' : widget.clienteTelefono),
                const SizedBox(height: 8),
                _DatoFila(icono: Icons.calendar_today_outlined,
                    label: 'Entrega', valor: fmt.format(widget.fechaEntrega)),
                if (widget.notas.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _DatoFila(icono: Icons.notes_rounded,
                      label: 'Notas', valor: widget.notas),
                ],
              ]),
            ),
          ),
 
          // ── Título productos ───────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Row(children: [
                const Text('Productos',
                    style: TextStyle(fontWeight: FontWeight.w700,
                        fontSize: 16, color: AppTheme.textDark)),
                const Spacer(),
                Text('${carrito.totalItems} items',
                    style: const TextStyle(color: AppTheme.textMid, fontSize: 13)),
              ]),
            ),
          ),
 
          // ── Lista de productos ─────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final item = carrito.items[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.inventory_2_rounded,
                              color: AppTheme.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.producto.nombre,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13)),
                            Text('${item.cantidad} x \$${item.producto.precio.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 11, color: AppTheme.textMid)),
                          ],
                        )),
                        Text('\$${item.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w700,
                                color: AppTheme.primary, fontSize: 14)),
                      ]),
                    ),
                  );
                },
                childCount: carrito.items.length,
              ),
            ),
          ),
 
          // ── Total ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
              ),
              child: Row(children: [
                const Text('TOTAL',
                    style: TextStyle(fontWeight: FontWeight.w700,
                        fontSize: 16, color: AppTheme.textDark)),
                const Spacer(),
                Text('\$${carrito.totalPrecio.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700,
                        fontSize: 24, color: AppTheme.primary)),
              ]),
            ),
          ),
 
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
 
      // ── Botón confirmar ────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
              blurRadius: 10, offset: const Offset(0, -3))],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _guardando ? null : () => _confirmarVenta(carrito),
              icon: _guardando
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle_rounded),
              label: Text(_guardando ? 'Guardando...' : 'Confirmar Venta'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.statusEnProceso,
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
 
  Future<void> _confirmarVenta(CarritoProvider carrito) async {
    setState(() => _guardando = true);
 
    try {
      final venta = Venta(
        clienteNombre:   widget.clienteNombre,
        clienteTelefono: widget.clienteTelefono,
        fechaVenta:      DateTime.now(),
        fechaEntrega:    widget.fechaEntrega,
        notas:           widget.notas,
        total:           carrito.totalPrecio,
      );
 
      final idVenta = await _db.insertVenta(venta);
 
      for (final item in carrito.items) {
        await _db.insertDetalle(DetalleVenta(
          idVenta:         idVenta,
          idProducto:      item.producto.idProducto!,
          nombreProducto:  item.producto.nombre,
          precioUnitario:  item.producto.precio,
          cantidad:        item.cantidad,
          subtotal:        item.subtotal,
        ));
      }
 
      carrito.limpiar();
 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('¡Venta registrada exitosamente!'),
          ]),
          backgroundColor: AppTheme.statusEnProceso,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        // Regresamos true para que NuevaVentaScreen sepa que se guardó
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _guardando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: AppTheme.statusCancelada,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
}
 
class _DatoFila extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;
  const _DatoFila({required this.icono, required this.label, required this.valor});
 
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icono, size: 16, color: AppTheme.textMid),
    const SizedBox(width: 8),
    Text('$label: ', style: const TextStyle(
        fontSize: 13, color: AppTheme.textMid)),
    Expanded(child: Text(valor, style: const TextStyle(
        fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
        overflow: TextOverflow.ellipsis)),
  ]);
}