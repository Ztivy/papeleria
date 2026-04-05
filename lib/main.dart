import 'package:bdp/providers/carrito_provider.dart';
import 'package:bdp/screens/calendario_screen.dart';
import 'package:bdp/screens/carrito_screen.dart';
import 'package:bdp/screens/categorias_screen.dart';
import 'package:bdp/screens/home_screen.dart';
import 'package:bdp/screens/nueva_venta_screen.dart';
import 'package:bdp/screens/productos_screen.dart';
import 'package:bdp/screens/ventas_list_screen.dart';
import 'package:bdp/utils/app_theme.dart';
import 'package:bdp/utils/notificacion_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => CarritoProvider(),
      child: const MyApp(),
    ),
  );
}
 
class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Papelería App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/':           (ctx) => const HomeScreen(),
        '/ventas':     (ctx) => const VentasListScreen(),
        '/calendario': (ctx) => const CalendarioScreen(),
        '/categorias': (ctx) => const CategoriasScreen(),
        '/nueva-venta':(ctx) => const NuevaVentaScreen(),
        '/carrito':    (ctx) => const CarritoScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/productos') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ProductosScreen(
              idCategoria:     args['idCategoria'],
              nombreCategoria: args['nombreCategoria'],
            ),
          );
        }
        return null;
      },
    );
  }
}