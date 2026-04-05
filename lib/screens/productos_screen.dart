import 'package:bdp/database/papeleriadb.dart';
import 'package:bdp/models/producto_model.dart';
import 'package:bdp/providers/carrito_provider.dart';
import 'package:bdp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:badges/badges.dart' as badges;

class ProductosScreen extends StatefulWidget {
  final int? idCategoria;
  final String nombreCategoria;
  const ProductosScreen({super.key, this.idCategoria, required this.nombreCategoria});
  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final PapeleriaDB _db = PapeleriaDB();
  List<Producto> _productos = [];
  List<Producto> _filtered  = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargar();
    _searchCtrl.addListener(_filtrar);
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    final prods = await _db.getProductos(idCategoria: widget.idCategoria);
    setState(() { _productos = prods; _filtered = prods; _loading = false; });
  }

  void _filtrar() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _productos.where((p) => p.nombre.toLowerCase().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombreCategoria),
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
              onPressed: () => Navigator.pushNamed(context, '/carrito'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _mostrarForm,
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Buscar producto...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMid),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () { _searchCtrl.clear(); _filtrar(); })
                  : null,
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : _filtered.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.inventory_2_rounded,
                          size: 70, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('Sin productos',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
                      TextButton(onPressed: _mostrarForm,
                          child: const Text('Agregar producto')),
                    ]))
                  : AnimationLimiter(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, childAspectRatio: 0.8,
                            crossAxisSpacing: 10, mainAxisSpacing: 10),
                        itemCount: _filtered.length,
                        itemBuilder: (ctx, i) =>
                            AnimationConfiguration.staggeredGrid(
                              position: i, columnCount: 2,
                              duration: const Duration(milliseconds: 300),
                              child: ScaleAnimation(
                                child: _ProductoCard(
                                  producto: _filtered[i],
                                  cantidadEnCarrito:
                                      carrito.getCantidad(_filtered[i].idProducto!),
                                  onAdd:    () => carrito.agregar(_filtered[i]),
                                  onRemove: () => carrito.reducir(_filtered[i]),
                                  onEdit:   () => _mostrarForm(prod: _filtered[i]),
                                  onDelete: () => _confirmarEliminar(_filtered[i]),
                                ),
                              ),
                            ),
                      ),
                    ),
        ),
      ]),
    );
  }

  void _mostrarForm({Producto? prod}) {
    final conNombre = TextEditingController(text: prod?.nombre ?? '');
    final conPrecio = TextEditingController(
        text: prod?.precio.toStringAsFixed(2) ?? '');
    final conStock  = TextEditingController(text: prod?.stock.toString() ?? '');
    final conDesc   = TextEditingController(text: prod?.descripcion ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(prod == null ? 'Nuevo producto' : 'Editar producto',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(controller: conNombre,
                decoration: const InputDecoration(
                    labelText: 'Nombre', prefixIcon: Icon(Icons.inventory_2_rounded))),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextFormField(
                controller: conPrecio,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Precio \$',
                    prefixIcon: Icon(Icons.attach_money_rounded)),
              )),
              const SizedBox(width: 10),
              Expanded(child: TextFormField(
                controller: conStock,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Stock',
                    prefixIcon: Icon(Icons.format_list_numbered_rounded)),
              )),
            ]),
            const SizedBox(height: 10),
            TextFormField(controller: conDesc, maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.notes_rounded))),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (conNombre.text.isEmpty) return;
              final nuevo = Producto(
                idProducto: prod?.idProducto,
                nombre: conNombre.text.trim(),
                precio: double.tryParse(conPrecio.text) ?? 0.0,
                stock:  int.tryParse(conStock.text) ?? 0,
                idCategoria: widget.idCategoria ?? 1,
                descripcion: conDesc.text.trim(),
              );
              if (prod == null) {
                await _db.insertProducto(nuevo);
              } else {
                await _db.updateProducto(nuevo);
              }
              if (mounted) { Navigator.pop(ctx); _cargar(); }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(Producto prod) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "${prod.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusCancelada),
            onPressed: () async {
              await _db.deleteProducto(prod.idProducto!);
              if (mounted) { Navigator.pop(ctx); _cargar(); }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _ProductoCard extends StatelessWidget {
  final Producto producto;
  final int cantidadEnCarrito;
  final VoidCallback onAdd, onRemove, onEdit, onDelete;
  const _ProductoCard({
    required this.producto, required this.cantidadEnCarrito,
    required this.onAdd, required this.onRemove,
    required this.onEdit, required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final inCart = cantidadEnCarrito > 0;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Stack(children: [
          Container(
            width: double.infinity,
            color: AppTheme.primary.withOpacity(0.08),
            child: const Icon(Icons.inventory_2_rounded,
                size: 50, color: AppTheme.primary),
          ),
          if (inCart)
            Positioned(top: 8, right: 8, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: AppTheme.primary, borderRadius: BorderRadius.circular(20)),
              child: Text('$cantidadEnCarrito',
                  style: const TextStyle(color: Colors.white, fontSize: 11,
                      fontWeight: FontWeight.w700)),
            )),
          Positioned(top: 4, left: 4,
            child: PopupMenuButton<String>(
              iconSize: 18,
              icon: const Icon(Icons.more_vert_rounded,
                  size: 18, color: AppTheme.textMid),
              padding: EdgeInsets.zero,
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit',   child: Text('Editar')),
                PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
              onSelected: (v) {
                if (v == 'edit')   onEdit();
                if (v == 'delete') onDelete();
              },
            ),
          ),
        ])),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(producto.nombre,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                    color: AppTheme.textDark),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Row(children: [
              Text('\$${producto.precio.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w700,
                      color: AppTheme.primary, fontSize: 13)),
              const Spacer(),
              Text('Stock: ${producto.stock}',
                  style: const TextStyle(fontSize: 10, color: AppTheme.textMid)),
            ]),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (inCart) ...[
              _CircleBtn(icon: Icons.remove_rounded,
                  color: AppTheme.statusCancelada, onTap: onRemove),
              const SizedBox(width: 8),
            ],
            Expanded(child: ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  textStyle: const TextStyle(fontSize: 11)),
              child: const Text('+ Agregar'),
            )),
          ]),
        ),
      ]),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon; final Color color; final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(20),
    child: Container(padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: color.withOpacity(0.15), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 16)),
  );
}
