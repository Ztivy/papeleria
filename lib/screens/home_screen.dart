import 'package:bdp/providers/carrito_provider.dart';
import 'package:bdp/screens/ventas_list_screen.dart';
import 'package:bdp/utils/app_theme.dart';
import 'package:bdp/utils/notificacion_service.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';
import 'package:bdp/screens/calendario_screen.dart';
import 'package:bdp/screens/categorias_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
 
class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  GlobalKey _ventasKey   = GlobalKey();
  GlobalKey _calendarioKey = GlobalKey();
  GlobalKey _catalogoKey   = GlobalKey();
 
  final List<String> _titles = ['Mis Pedidos', 'Calendario', 'Catálogo'];
 
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.verificarYNotificar();
    });
  }
 
  void _refrescarTodo() {
    setState(() {
      _ventasKey    = GlobalKey();
      _calendarioKey = GlobalKey();
      _catalogoKey   = GlobalKey();
    });
  }
 
  Future<void> _irANuevaVenta() async {
    await Navigator.pushNamed(context, '/nueva-venta');
    _refrescarTodo();
  }
 
  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();
 
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏪 '),
            Text(_titles[_currentIndex]),
          ],
        ),
        actions: [
          badges.Badge(
            position: badges.BadgePosition.topEnd(top: 4, end: 4),
            showBadge: carrito.totalItems > 0,
            badgeContent: Text(
              '${carrito.totalItems}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
            badgeStyle: const badges.BadgeStyle(
              badgeColor: AppTheme.secondary,
              padding: EdgeInsets.all(4),
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_rounded),
              onPressed: _irANuevaVenta,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildCurrentScreen(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _irANuevaVenta,
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: const Text('Nueva Venta',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primary.withOpacity(0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon:
                Icon(Icons.receipt_long_rounded, color: AppTheme.primary),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon:
                Icon(Icons.calendar_month_rounded, color: AppTheme.primary),
            label: 'Calendario',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon:
                Icon(Icons.storefront_rounded, color: AppTheme.primary),
            label: 'Catálogo',
          ),
        ],
      ),
    );
  }
 
  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return VentasListScreen(key: _ventasKey);
      case 1:
        return CalendarioScreen(key: _calendarioKey);
      case 2:
        return CategoriasScreen(key: _catalogoKey);
      default:
        return VentasListScreen(key: _ventasKey);
    }
  }
}