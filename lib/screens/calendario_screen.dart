import 'package:bdp/database/papeleriadb.dart';
import 'package:bdp/models/venta_model.dart';
import 'package:bdp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});
  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}
 
class _CalendarioScreenState extends State<CalendarioScreen> {
  final PapeleriaDB _db     = PapeleriaDB();
  Map<DateTime, List<Venta>> _eventos = {};
  DateTime _focusedDay      = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _format    = CalendarFormat.month;
 
  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }
 
  Future<void> _cargarEventos() async {
    final eventos = await _db.getVentasParaCalendario();
    if (mounted) setState(() => _eventos = eventos);
  }
 
  List<Venta> _getEventos(DateTime day) =>
      _eventos[DateTime(day.year, day.month, day.day)] ?? [];
 
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _cargarEventos,
      color: AppTheme.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: TableCalendar<Venta>(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay:  DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                calendarFormat: _format,
                onFormatChanged: (f) => setState(() => _format = f),
                eventLoader: _getEventos,
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay  = focused;
                  });
                  final ev = _getEventos(selected);
                  if (ev.isNotEmpty) _mostrarModal(selected, ev);
                },
                onPageChanged: (f) => setState(() => _focusedDay = f),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.3),
                      shape: BoxShape.circle),
                  selectedDecoration: const BoxDecoration(
                      color: AppTheme.primary, shape: BoxShape.circle),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonDecoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  formatButtonTextStyle:
                      TextStyle(color: Colors.white, fontSize: 12),
                  titleCentered: true,
                  titleTextStyle:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (ctx, date, events) {
                    if (events.isEmpty) return const SizedBox();
                    return Positioned(
                      bottom: 1,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: events.take(4).map((e) => Container(
                          width: 6, height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.getStatusColor(e.estatus),
                            shape: BoxShape.circle,
                          ),
                        )).toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
 
          // Leyenda
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                _LegendDot(color: AppTheme.statusEnProceso,  label: 'En proceso'),
                SizedBox(width: 16),
                _LegendDot(color: AppTheme.statusCancelada,  label: 'Cancelado'),
                SizedBox(width: 16),
                _LegendDot(color: AppTheme.statusCompletada, label: 'Completado'),
              ]),
            ),
          ),
 
          // Preview día seleccionado
          if (_selectedDay != null && _getEventos(_selectedDay!).isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(DateFormat('dd/MM/yyyy').format(_selectedDay!),
                        style: const TextStyle(fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textMid)),
                    Text('${_getEventos(_selectedDay!).length} pedido(s)',
                        style: const TextStyle(fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark)),
                  ]),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () =>
                        _mostrarModal(_selectedDay!, _getEventos(_selectedDay!)),
                    icon: const Icon(Icons.visibility_rounded, size: 16),
                    label: const Text('Ver todos'),
                  ),
                ]),
              ),
            ),
 
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
 
  void _mostrarModal(DateTime dia, List<Venta> ventas) {
    final fmt = DateFormat('dd/MM/yyyy');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(fmt.format(dia),
                      style: const TextStyle(fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMid)),
                  Text('${ventas.length} pedido(s)',
                      style: const TextStyle(fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark)),
                ]),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.all(16),
                itemCount: ventas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final v  = ventas[i];
                  final sc = AppTheme.getStatusColor(v.estatus);
                  return Card(
                    child: Padding(padding: const EdgeInsets.all(14),
                      child: Row(children: [
                        Container(width: 5, height: 56,
                            decoration: BoxDecoration(color: sc,
                                borderRadius: BorderRadius.circular(3))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v.clienteNombre,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 15)),
                            Row(children: [
                              const Icon(Icons.phone_rounded,
                                  size: 12, color: AppTheme.textMid),
                              const SizedBox(width: 4),
                              Text(v.clienteTelefono,
                                  style: const TextStyle(
                                      fontSize: 12, color: AppTheme.textMid)),
                            ]),
                            if (v.notas != null && v.notas!.isNotEmpty)
                              Text(v.notas!,
                                  style: const TextStyle(
                                      fontSize: 11, color: AppTheme.textLight),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                          ],
                        )),
                        Column(crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                          Text('\$${v.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15, color: AppTheme.primary)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: sc.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(v.estatusTexto,
                                style: TextStyle(color: sc, fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ]),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
 
class _LegendDot extends StatelessWidget {
  final Color color; final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMid)),
    ],
  );
}