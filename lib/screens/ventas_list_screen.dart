import 'package:bdp/database/papeleriadb.dart';
import 'package:bdp/models/venta_model.dart';
import 'package:bdp/screens/detalle_venta_screen.dart';
import 'package:bdp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

class VentasListScreen extends StatefulWidget {
  const VentasListScreen({super.key});
  @override
  State<VentasListScreen> createState() => _VentasListScreenState();
}
 
class _VentasListScreenState extends State<VentasListScreen>
    with AutomaticKeepAliveClientMixin {
  final PapeleriaDB _db = PapeleriaDB();
  List<Venta> _ventas = [];
  int _filtro = -1;
  bool _loading = true;
 
  @override
  bool get wantKeepAlive => true;
 
  @override
  void initState() { super.initState(); _cargarVentas(); }
 
  Future<void> _cargarVentas() async {
    setState(() => _loading = true);
    final ventas = await _db.getVentas(estatus: _filtro == -1 ? null : _filtro);
    setState(() { _ventas = ventas; _loading = false; });
  }
 
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: _cargarVentas,
      color: AppTheme.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildFilterBar()),
          SliverToBoxAdapter(child: _buildStats()),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
            )
          else if (_ventas.isEmpty)
            SliverFillRemaining(child: _buildEmpty())
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: AnimationLimiter(
                child: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => AnimationConfiguration.staggeredList(
                      position: i,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50,
                        child: FadeInAnimation(
                          child: _VentaCard(
                            venta: _ventas[i],
                            onTap: () => _abrirDetalle(_ventas[i]),
                          ),
                        ),
                      ),
                    ),
                    childCount: _ventas.length,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
 
  Widget _buildFilterBar() {
    final filters = [
      (-1, 'Todos',      Icons.list_rounded),
      (0,  'En proceso', Icons.hourglass_empty_rounded),
      (1,  'Completados',Icons.check_circle_rounded),
      (2,  'Cancelados', Icons.cancel_rounded),
    ];
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: filters.map((f) {
            final selected = _filtro == f.$1;
            final chipColor = f.$1 == -1
                ? AppTheme.primary
                : AppTheme.getStatusColor(f.$1);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Icon(f.$3, size: 16,
                    color: selected ? Colors.white : chipColor),
                label: Text(f.$2,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : chipColor)),
                selected: selected,
                onSelected: (_) { setState(() => _filtro = f.$1); _cargarVentas(); },
                backgroundColor: chipColor.withOpacity(0.08),
                selectedColor: chipColor,
                checkmarkColor: Colors.white,
                showCheckmark: false,
                side: BorderSide(
                    color: selected ? Colors.transparent : chipColor, width: 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
 
  Widget _buildStats() {
    final proceso    = _ventas.where((v) => v.estatus == 0).length;
    final completadas = _ventas.where((v) => v.estatus == 1).length;
    final canceladas = _ventas.where((v) => v.estatus == 2).length;
    final total = _ventas.fold(0.0, (s, v) => s + v.total);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(children: [
        _StatChip(proceso,    'Proceso', AppTheme.statusEnProceso),
        const SizedBox(width: 8),
        _StatChip(completadas,'Listas',  AppTheme.statusCompletada),
        const SizedBox(width: 8),
        _StatChip(canceladas, 'Cancel.', AppTheme.statusCancelada),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('\$${total.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                  fontSize: 13)),
        ),
      ]),
    );
  }
 
  Widget _buildEmpty() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.inbox_rounded, size: 80, color: Colors.grey.shade300),
      const SizedBox(height: 16),
      Text('No hay pedidos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
              color: Colors.grey.shade400)),
      const SizedBox(height: 8),
      Text('Crea un nuevo pedido con el botón +',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
    ]),
  );
 
  void _abrirDetalle(Venta venta) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => DetalleVentaScreen(venta: venta)));
    _cargarVentas();
  }
}
 
class _StatChip extends StatelessWidget {
  final int count; final String label; final Color color;
  const _StatChip(this.count, this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text('$count $label',
          style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 11)),
    ]),
  );
}
 
class _VentaCard extends StatelessWidget {
  final Venta venta; final VoidCallback onTap;
  const _VentaCard({required this.venta, required this.onTap});
 
  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.getStatusColor(venta.estatus);
    final statusIcon  = AppTheme.getStatusIcon(venta.estatus);
    final fmt = DateFormat('dd/MM/yyyy');
    final diasRestantes = venta.fechaEntrega.difference(DateTime.now()).inDays;
 
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: statusColor, width: 4)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: statusColor.withOpacity(0.15),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(venta.clienteNombre,
                      style: const TextStyle(fontWeight: FontWeight.w700,
                          fontSize: 15, color: AppTheme.textDark)),
                  Text(venta.clienteTelefono,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMid)),
                ],
              )),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('\$${venta.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700,
                        fontSize: 16, color: AppTheme.primary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(venta.estatusTexto,
                      style: TextStyle(color: statusColor, fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
            ]),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 14, color: AppTheme.textMid),
              const SizedBox(width: 4),
              Text('Entrega: ${fmt.format(venta.fechaEntrega)}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMid)),
              const Spacer(),
              if (venta.estatus == 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: diasRestantes < 0
                        ? Colors.red.shade50
                        : diasRestantes <= 2 ? Colors.orange.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    diasRestantes < 0 ? 'Vencido'
                        : diasRestantes == 0 ? '¡Hoy!'
                        : '$diasRestantes días',
                    style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w600,
                      color: diasRestantes < 0 ? Colors.red
                          : diasRestantes <= 2 ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
            ]),
          ]),
        ),
      ),
    );
  }
}