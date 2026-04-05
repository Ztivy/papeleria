import 'package:bdp/models/venta_model.dart';
import 'package:bdp/providers/carrito_provider.dart';
import 'package:bdp/utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        actions: [
          if (carrito.items.isNotEmpty)
            TextButton(
              onPressed: () => _confirmarVaciar(context, carrito),
              child: const Text('Vaciar',
                  style: TextStyle(color: Colors.white70)),
            ),
        ],
      ),
      body: carrito.items.isEmpty
          ? _buildEmpty(context)
          : Column(children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) {
                            final item = carrito.items[i];
                            return _CarritoItem(
                              item: item,
                              onAdd:    () => carrito.agregar(item.producto),
                              onRemove: () => carrito.reducir(item.producto),
                              onDelete: () => carrito.eliminar(item.producto),
                            );
                          },
                          childCount: carrito.items.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildSummary(context, carrito),
            ]),
    );
  }

  Widget _buildEmpty(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
      const SizedBox(height: 16),
      Text('El carrito está vacío',
          style: TextStyle(fontSize: 18, color: Colors.grey.shade400,
              fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text('Agrega productos desde el catálogo',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.storefront_rounded),
        label: const Text('Ir al catálogo'),
      ),
    ]),
  );

  Widget _buildSummary(BuildContext context, CarritoProvider carrito) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06),
              blurRadius: 10, offset: const Offset(0, -3))
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(children: [
          Row(children: [
            const Text('Total de productos:',
                style: TextStyle(color: AppTheme.textMid, fontSize: 13)),
            const Spacer(),
            Text('${carrito.totalItems} items',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Text('Total a pagar:',
                style: TextStyle(fontWeight: FontWeight.w700,
                    fontSize: 16, color: AppTheme.textDark)),
            const Spacer(),
            Text('\$${carrito.totalPrecio.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w700,
                    fontSize: 22, color: AppTheme.primary)),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/nueva-venta'),
              icon: const Icon(Icons.shopping_cart_checkout_rounded),
              label: const Text('Registrar Venta'),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
        ]),
      ),
    );
  }

  void _confirmarVaciar(BuildContext context, CarritoProvider carrito) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vaciar carrito'),
        content: const Text('¿Deseas eliminar todos los productos?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusCancelada),
            onPressed: () { carrito.limpiar(); Navigator.pop(ctx); },
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
  }
}

class _CarritoItem extends StatelessWidget {
  final ItemCarrito item;
  final VoidCallback onAdd, onRemove, onDelete;
  const _CarritoItem({
    required this.item,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_rounded, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.producto.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w700,
                      fontSize: 14, color: AppTheme.textDark)),
              const SizedBox(height: 4),
              Text('\$${item.producto.precio.toStringAsFixed(2)} c/u',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMid)),
              const SizedBox(height: 6),
              LinearPercentIndicator(
                padding: EdgeInsets.zero,
                lineHeight: 4,
                percent: (item.cantidad / 10).clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade200,
                progressColor: AppTheme.primary,
                barRadius: const Radius.circular(2),
              ),
            ],
          )),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('\$${item.subtotal.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w700,
                    color: AppTheme.primary, fontSize: 14)),
            const SizedBox(height: 6),
            Row(mainAxisSize: MainAxisSize.min, children: [
              _SmallBtn(icon: Icons.remove_rounded,
                  color: AppTheme.statusCancelada, onTap: onRemove),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('${item.cantidad}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
              _SmallBtn(icon: Icons.add_rounded,
                  color: AppTheme.statusEnProceso, onTap: onAdd),
            ]),
            const SizedBox(height: 4),
            InkWell(
              onTap: onDelete,
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.delete_outline_rounded,
                    size: 14, color: AppTheme.statusCancelada),
                SizedBox(width: 2),
                Text('Eliminar',
                    style: TextStyle(fontSize: 10, color: AppTheme.statusCancelada)),
              ]),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final IconData icon; final Color color; final VoidCallback onTap;
  const _SmallBtn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 16),
    ),
  );
}
