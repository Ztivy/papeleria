import 'package:bdp/database/papeleriadb.dart';
import 'package:bdp/models/categoria_model.dart';
import 'package:bdp/models/producto_model.dart';
import 'package:bdp/models/venta_model.dart';
import 'package:bdp/providers/carrito_provider.dart';
import 'package:bdp/screens/confirmar_venta_screen.dart';
import 'package:bdp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart' as badges;

class NuevaVentaScreen extends StatefulWidget {
  const NuevaVentaScreen({super.key});
  @override
  State<NuevaVentaScreen> createState() => _NuevaVentaScreenState();
}
 
class _NuevaVentaScreenState extends State<NuevaVentaScreen> {
  final _db = PapeleriaDB();
  int _step = 0;
 
  final _conNombre   = TextEditingController();
  final _conTelefono = TextEditingController();
  final _conNotas    = TextEditingController();
  DateTime _fechaEntrega = DateTime.now().add(const Duration(days: 1));
 
  List<Categoria> _categorias = [];
  Categoria? _catSel;
  List<Producto> _productos = [];
 
  static const Map<String, IconData> _iconMap = {
    'candy': Icons.cake_rounded, 'print': Icons.print_rounded,
    'description': Icons.description_rounded, 'cut': Icons.content_cut_rounded,
    'toys': Icons.toys_rounded, 'category': Icons.category_rounded,
    'shopping': Icons.shopping_bag_rounded, 'school': Icons.school_rounded,
    'brush': Icons.brush_rounded, 'star': Icons.star_rounded,
  };
 
  @override
  void initState() { super.initState(); _cargarCategorias(); }
 
  @override
  void dispose() {
    _conNombre.dispose(); _conTelefono.dispose(); _conNotas.dispose();
    super.dispose();
  }
 
  Future<void> _cargarCategorias() async {
    final cats = await _db.getCategorias();
    setState(() => _categorias = cats);
  }
 
  Future<void> _cargarProductos(int idCat) async {
    final prods = await _db.getProductos(idCategoria: idCat);
    setState(() => _productos = prods);
  }
 
  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Venta'),
        actions: [
          badges.Badge(
            showBadge: carrito.totalItems > 0,
            badgeContent: Text('${carrito.totalItems}',
                style: const TextStyle(color: Colors.white, fontSize: 10,
                    fontWeight: FontWeight.bold)),
            badgeStyle: const badges.BadgeStyle(
                badgeColor: AppTheme.secondary, padding: EdgeInsets.all(4)),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_rounded),
              onPressed: carrito.totalItems > 0
                  ? () => _irAConfirmar(carrito)
                  : null,
            ),
          ),
        ],
      ),
      body: Column(children: [
        _StepIndicator(currentStep: _step),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _step == 0 ? _buildCliente()
                : _step == 1 ? _buildCategorias()
                : _buildProductos(),
          ),
        ),
      ]),
      bottomNavigationBar: _buildBottomBar(carrito),
    );
  }
 
 
  Widget _buildCliente() => SingleChildScrollView(
    key: const ValueKey(0),
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Datos del cliente',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
              color: AppTheme.textDark)),
      const SizedBox(height: 20),
      TextFormField(
        controller: _conNombre,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
            labelText: 'Nombre del cliente *',
            prefixIcon: Icon(Icons.person_rounded)),
      ),
      const SizedBox(height: 14),
      TextFormField(
        controller: _conTelefono,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
            labelText: 'Teléfono',
            prefixIcon: Icon(Icons.phone_rounded)),
      ),
      const SizedBox(height: 14),
      InkWell(
        onTap: _seleccionarFecha,
        child: InputDecorator(
          decoration: const InputDecoration(
              labelText: 'Fecha de entrega *',
              prefixIcon: Icon(Icons.calendar_today_rounded)),
          child: Text(DateFormat('dd/MM/yyyy').format(_fechaEntrega),
              style: const TextStyle(fontSize: 15)),
        ),
      ),
      const SizedBox(height: 14),
      TextFormField(
        controller: _conNotas, maxLines: 3,
        decoration: const InputDecoration(
            labelText: 'Notas adicionales',
            prefixIcon: Icon(Icons.notes_rounded),
            alignLabelWithHint: true),
      ),
    ]),
  );
 
 
  Widget _buildCategorias() => Column(
    key: const ValueKey(1),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Text('Selecciona una categoría',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                color: AppTheme.textDark)),
      ),
      Expanded(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 1.2,
              crossAxisSpacing: 12, mainAxisSpacing: 12),
          itemCount: _categorias.length,
          itemBuilder: (ctx, i) {
            final cat   = _categorias[i];
            final color = hexToColor(cat.color);
            final isSel = _catSel?.idCategoria == cat.idCategoria;
            return GestureDetector(
              onTap: () async {
                setState(() => _catSel = cat);
                await _cargarProductos(cat.idCategoria!);
                setState(() => _step = 2);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSel ? color : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isSel ? color : Colors.grey.shade200,
                      width: isSel ? 2 : 1),
                  boxShadow: [BoxShadow(
                      color: color.withOpacity(isSel ? 0.3 : 0.05),
                      blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_iconMap[cat.icono] ?? Icons.category_rounded,
                      size: 36, color: isSel ? Colors.white : color),
                  const SizedBox(height: 8),
                  Text(cat.nombre,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13,
                          color: isSel ? Colors.white : AppTheme.textDark),
                      textAlign: TextAlign.center),
                ]),
              ),
            );
          },
        ),
      ),
    ],
  );
 
  Widget _buildProductos() => Column(
    key: const ValueKey(2),
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(children: [
          InkWell(
            onTap: () => setState(() => _step = 1),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.arrow_back_rounded, size: 16, color: AppTheme.primary),
                SizedBox(width: 4),
                Text('Categorías', style: TextStyle(fontSize: 12,
                    color: AppTheme.primary, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
          const SizedBox(width: 12),
          Text(_catSel?.nombre ?? '',
              style: const TextStyle(fontWeight: FontWeight.w700,
                  fontSize: 16, color: AppTheme.textDark)),
        ]),
      ),
      Expanded(
        child: _productos.isEmpty
            ? const Center(child: Text('No hay productos en esta categoría',
                style: TextStyle(color: AppTheme.textMid)))
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 0.85,
                    crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemCount: _productos.length,
                itemBuilder: (ctx, i) {
                  final prod = _productos[i];
                  return Consumer<CarritoProvider>(
                    builder: (ctx, carrito, _) {
                      final qty = carrito.getCantidad(prod.idProducto!);
                      return Card(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Stack(children: [
                              Container(width: double.infinity,
                                  color: AppTheme.primary.withOpacity(0.08),
                                  child: const Icon(Icons.inventory_2_rounded,
                                      size: 44, color: AppTheme.primary)),
                              if (qty > 0)
                                Positioned(top: 6, right: 6, child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                      color: AppTheme.primary, shape: BoxShape.circle),
                                  child: Text('$qty',
                                      style: const TextStyle(color: Colors.white,
                                          fontSize: 10, fontWeight: FontWeight.w700)),
                                )),
                            ])),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(prod.nombre,
                                      style: const TextStyle(fontWeight: FontWeight.w700,
                                          fontSize: 12, color: AppTheme.textDark),
                                      maxLines: 2, overflow: TextOverflow.ellipsis),
                                  Text('\$${prod.precio.toStringAsFixed(2)}',
                                      style: const TextStyle(color: AppTheme.primary,
                                          fontWeight: FontWeight.w700, fontSize: 12)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                              child: qty == 0
                                  ? SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => carrito.agregar(prod),
                                        style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 4),
                                            textStyle: const TextStyle(fontSize: 11)),
                                        child: const Text('+ Agregar'),
                                      ),
                                    )
                                  : Row(children: [
                                      _CBtn(icon: Icons.remove_rounded,
                                          color: AppTheme.statusCancelada,
                                          onTap: () => carrito.reducir(prod)),
                                      Expanded(child: Center(child: Text('$qty',
                                          style: const TextStyle(fontWeight: FontWeight.w700,
                                              fontSize: 14, color: AppTheme.primary)))),
                                      _CBtn(icon: Icons.add_rounded,
                                          color: AppTheme.statusEnProceso,
                                          onTap: () => carrito.agregar(prod)),
                                    ]),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    ],
  );
 
  Widget _buildBottomBar(CarritoProvider carrito) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
          blurRadius: 10, offset: const Offset(0, -3))],
    ),
    child: SafeArea(
      child: Row(children: [
        if (_step > 0) ...[
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: () => setState(() => _step--),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Atrás'),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () => _siguiente(carrito),
            child: Text(
              _step == 0 ? 'Siguiente →'
              : _step == 1 ? 'Continuar'
              // En paso 2 el botón lleva al resumen/confirmación
              : carrito.totalItems > 0
                  ? 'Ver resumen (${carrito.totalItems} items)'
                  : 'Agrega productos',
            ),
          ),
        ),
      ]),
    ),
  );
 
 
  void _siguiente(CarritoProvider carrito) {
    if (_step == 0) {
      if (_conNombre.text.trim().isEmpty) {
        _snackError('Ingresa el nombre del cliente'); return;
      }
      setState(() => _step = 1);
    } else if (_step == 1) {
      if (_catSel == null) { _snackError('Selecciona una categoría'); return; }
      setState(() => _step = 2);
    } else {
      if (carrito.items.isEmpty) {
        _snackError('Agrega al menos un producto'); return;
      }
      _irAConfirmar(carrito);
    }
  }
 
  void _irAConfirmar(CarritoProvider carrito) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmarVentaScreen(
          clienteNombre:   _conNombre.text.trim(),
          clienteTelefono: _conTelefono.text.trim(),
          fechaEntrega:    _fechaEntrega,
          notas:           _conNotas.text.trim(),
        ),
      ),
    ).then((guardado) {
      if (guardado == true && mounted) {
        Navigator.pop(context);
      }
    });
  }
 
  Future<void> _seleccionarFecha() async {
    final p = await showDatePicker(
      context: context, initialDate: _fechaEntrega,
      firstDate: DateTime.now(), lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.primary)),
        child: child!,
      ),
    );
    if (p != null) setState(() => _fechaEntrega = p);
  }
 
  void _snackError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: AppTheme.statusCancelada,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
  );
}
 
// ── Step indicator ───────────────────────────────────────────────────────────
 
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});
  @override
  Widget build(BuildContext context) {
    final steps = ['Cliente', 'Categoría', 'Productos'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      color: Colors.white,
      child: Row(
        children: List.generate(steps.length, (i) {
          final active = i == currentStep;
          final done   = i < currentStep;
          return Expanded(
            child: Row(children: [
              Expanded(child: Column(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: done ? AppTheme.statusEnProceso
                        : active ? AppTheme.primary : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: done
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                      : Text('${i + 1}', style: TextStyle(
                          color: active ? Colors.white : AppTheme.textMid,
                          fontWeight: FontWeight.w700, fontSize: 13))),
                ),
                const SizedBox(height: 4),
                Text(steps[i], style: TextStyle(
                    fontSize: 10,
                    fontWeight: (active || done) ? FontWeight.w600 : FontWeight.normal,
                    color: (active || done) ? AppTheme.primary : AppTheme.textLight)),
              ])),
              if (i < steps.length - 1)
                Expanded(child: Container(height: 2,
                    margin: const EdgeInsets.only(bottom: 18),
                    color: done ? AppTheme.statusEnProceso : Colors.grey.shade200)),
            ]),
          );
        }),
      ),
    );
  }
}
 
class _CBtn extends StatelessWidget {
  final IconData icon; final Color color; final VoidCallback onTap;
  const _CBtn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(20),
    child: Container(padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: color.withOpacity(0.15), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 14)),
  );
}