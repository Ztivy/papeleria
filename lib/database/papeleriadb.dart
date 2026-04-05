import 'dart:io';
import 'package:bdp/models/categoria_model.dart';
import 'package:bdp/models/producto_model.dart';
import 'package:bdp/models/venta_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class PapeleriaDB {
  static const String _nameDB = 'papeleria.db';
  static const int _versionDB = 1;
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory folder = await getApplicationDocumentsDirectory();
    String pathDB = join(folder.path, _nameDB);
    return openDatabase(
      pathDB,
      version: _versionDB,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tblCategoria (
        idCategoria INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre VARCHAR(50) NOT NULL,
        icono VARCHAR(50) NOT NULL DEFAULT 'category',
        color VARCHAR(20) NOT NULL DEFAULT '#FF9800'
      )
    ''');

    await db.execute('''
      CREATE TABLE tblProducto (
        idProducto INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre VARCHAR(100) NOT NULL,
        precio REAL NOT NULL DEFAULT 0.0,
        stock INTEGER NOT NULL DEFAULT 0,
        idCategoria INTEGER NOT NULL,
        descripcion VARCHAR(200),
        imagen VARCHAR(200),
        FOREIGN KEY (idCategoria) REFERENCES tblCategoria(idCategoria)
          ON DELETE RESTRICT ON UPDATE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE tblVenta (
        idVenta INTEGER PRIMARY KEY AUTOINCREMENT,
        clienteNombre VARCHAR(100) NOT NULL,
        clienteTelefono VARCHAR(20),
        fechaVenta TEXT NOT NULL,
        fechaEntrega TEXT NOT NULL,
        estatus INTEGER NOT NULL DEFAULT 0,
        total REAL NOT NULL DEFAULT 0.0,
        notas VARCHAR(500),
        notificacionEnviada INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE tblDetalleVenta (
        idDetalle INTEGER PRIMARY KEY AUTOINCREMENT,
        idVenta INTEGER NOT NULL,
        idProducto INTEGER NOT NULL,
        nombreProducto VARCHAR(100) NOT NULL,
        precioUnitario REAL NOT NULL,
        cantidad INTEGER NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (idVenta) REFERENCES tblVenta(idVenta)
          ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (idProducto) REFERENCES tblProducto(idProducto)
          ON DELETE RESTRICT ON UPDATE CASCADE
      )
    ''');

    // Insert default categories
    await _insertDefaultData(db);
  }

  Future<void> _insertDefaultData(Database db) async {
    final categorias = [
      {'nombre': 'Dulces', 'icono': 'candy', 'color': '#FF4081'},
      {'nombre': 'Copias/Impresiones', 'icono': 'print', 'color': '#2196F3'},
      {'nombre': 'Papelería', 'icono': 'description', 'color': '#FF9800'},
      {'nombre': 'Mercería', 'icono': 'cut', 'color': '#9C27B0'},
      {'nombre': 'Juguetes', 'icono': 'toys', 'color': '#4CAF50'},
    ];

    for (var cat in categorias) {
      await db.insert('tblCategoria', cat);
    }

    // Insert sample products
    final productos = [
      {'nombre': 'Paleta de fresa', 'precio': 5.0, 'stock': 50, 'idCategoria': 1, 'descripcion': 'Paleta sabor fresa'},
      {'nombre': 'Chicles', 'precio': 2.0, 'stock': 100, 'idCategoria': 1, 'descripcion': 'Chicles sabor menta'},
      {'nombre': 'Copia simple', 'precio': 1.5, 'stock': 999, 'idCategoria': 2, 'descripcion': 'Copia en blanco y negro'},
      {'nombre': 'Impresión color', 'precio': 5.0, 'stock': 999, 'idCategoria': 2, 'descripcion': 'Impresión a color'},
      {'nombre': 'Cuaderno 100 hojas', 'precio': 35.0, 'stock': 30, 'idCategoria': 3, 'descripcion': 'Cuaderno universitario'},
      {'nombre': 'Lápiz #2', 'precio': 4.0, 'stock': 80, 'idCategoria': 3, 'descripcion': 'Lápiz de grafito'},
      {'nombre': 'Bolígrafo azul', 'precio': 6.0, 'stock': 60, 'idCategoria': 3, 'descripcion': 'Bolígrafo azul'},
      {'nombre': 'Hilo de coser', 'precio': 12.0, 'stock': 40, 'idCategoria': 4, 'descripcion': 'Hilo 100m'},
      {'nombre': 'Agujas de coser', 'precio': 8.0, 'stock': 25, 'idCategoria': 4, 'descripcion': 'Pack 10 agujas'},
      {'nombre': 'Carros de juguete', 'precio': 45.0, 'stock': 15, 'idCategoria': 5, 'descripcion': 'Mini carros'},
      {'nombre': 'Muñeca', 'precio': 80.0, 'stock': 10, 'idCategoria': 5, 'descripcion': 'Muñeca de trapo'},
    ];

    for (var prod in productos) {
      await db.insert('tblProducto', {...prod, 'imagen': ''});
    }
  }

  // ==================== CATEGORIAS ====================
  Future<int> insertCategoria(Categoria cat) async {
    final db = await database;
    return db.insert('tblCategoria', cat.toMap()..remove('idCategoria'));
  }

  Future<int> updateCategoria(Categoria cat) async {
    final db = await database;
    return db.update('tblCategoria', cat.toMap(),
        where: 'idCategoria=?', whereArgs: [cat.idCategoria]);
  }

  Future<int> deleteCategoria(int id) async {
    // Check if has products
    final db = await database;
    final prods = await db.query('tblProducto',
        where: 'idCategoria=?', whereArgs: [id]);
    if (prods.isNotEmpty) throw Exception('Categoría tiene productos asociados');
    return db.delete('tblCategoria', where: 'idCategoria=?', whereArgs: [id]);
  }

  Future<List<Categoria>> getCategorias() async {
    final db = await database;
    final res = await db.query('tblCategoria', orderBy: 'nombre ASC');
    return res.map((e) => Categoria.fromMap(e)).toList();
  }

  // ==================== PRODUCTOS ====================
  Future<int> insertProducto(Producto prod) async {
    final db = await database;
    return db.insert('tblProducto', prod.toMap()..remove('idProducto'));
  }

  Future<int> updateProducto(Producto prod) async {
    final db = await database;
    return db.update('tblProducto', prod.toMap(),
        where: 'idProducto=?', whereArgs: [prod.idProducto]);
  }

  Future<int> deleteProducto(int id) async {
    final db = await database;
    return db.delete('tblProducto', where: 'idProducto=?', whereArgs: [id]);
  }

  Future<List<Producto>> getProductos({int? idCategoria}) async {
    final db = await database;
    List<Map<String, dynamic>> res;
    if (idCategoria != null) {
      res = await db.query('tblProducto',
          where: 'idCategoria=?',
          whereArgs: [idCategoria],
          orderBy: 'nombre ASC');
    } else {
      res = await db.query('tblProducto', orderBy: 'nombre ASC');
    }
    return res.map((e) => Producto.fromMap(e)).toList();
  }

  // ==================== VENTAS ====================
  Future<int> insertVenta(Venta venta) async {
    final db = await database;
    return db.insert('tblVenta', venta.toMap()..remove('idVenta'));
  }

  Future<int> updateVenta(Venta venta) async {
    final db = await database;
    return db.update('tblVenta', venta.toMap(),
        where: 'idVenta=?', whereArgs: [venta.idVenta]);
  }

  Future<int> deleteVenta(int id) async {
    final db = await database;
    return db.delete('tblVenta', where: 'idVenta=?', whereArgs: [id]);
  }

  Future<List<Venta>> getVentas({int? estatus}) async {
    final db = await database;
    List<Map<String, dynamic>> res;
    if (estatus != null) {
      res = await db.query('tblVenta',
          where: 'estatus=?',
          whereArgs: [estatus],
          orderBy: 'fechaEntrega ASC');
    } else {
      res = await db.query('tblVenta', orderBy: 'fechaEntrega ASC');
    }
    return res.map((e) => Venta.fromMap(e)).toList();
  }

  Future<List<Venta>> getVentasPorFecha(DateTime fecha) async {
    final db = await database;
    final fechaStr = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
    final res = await db.rawQuery(
        "SELECT * FROM tblVenta WHERE fechaEntrega LIKE '$fechaStr%' ORDER BY fechaEntrega ASC");
    return res.map((e) => Venta.fromMap(e)).toList();
  }

  Future<Map<DateTime, List<Venta>>> getVentasParaCalendario() async {
    final db = await database;
    final res = await db.query('tblVenta', orderBy: 'fechaEntrega ASC');
    final ventas = res.map((e) => Venta.fromMap(e)).toList();

    final Map<DateTime, List<Venta>> eventos = {};
    for (var venta in ventas) {
      final key = DateTime(venta.fechaEntrega.year, venta.fechaEntrega.month,
          venta.fechaEntrega.day);
      eventos[key] = (eventos[key] ?? [])..add(venta);
    }
    return eventos;
  }

  Future<Venta?> getVentaById(int id) async {
    final db = await database;
    final res = await db.query('tblVenta', where: 'idVenta=?', whereArgs: [id]);
    if (res.isEmpty) return null;
    return Venta.fromMap(res.first);
  }

  // Ventas pendientes de notificación (2 días antes)
  Future<List<Venta>> getVentasPendientesNotificacion() async {
    final db = await database;
    final ahora = DateTime.now();
    final limite = ahora.add(const Duration(days: 2));
    final res = await db.rawQuery(
        "SELECT * FROM tblVenta WHERE notificacionEnviada=0 AND estatus=0 AND fechaEntrega <= '${limite.toIso8601String()}'");
    return res.map((e) => Venta.fromMap(e)).toList();
  }

  Future<void> marcarNotificacionEnviada(int idVenta) async {
    final db = await database;
    await db.update('tblVenta', {'notificacionEnviada': 1},
        where: 'idVenta=?', whereArgs: [idVenta]);
  }

  // ==================== DETALLE VENTA ====================
  Future<int> insertDetalle(DetalleVenta detalle) async {
    final db = await database;
    return db.insert('tblDetalleVenta', detalle.toMap()..remove('idDetalle'));
  }

  Future<List<DetalleVenta>> getDetallesPorVenta(int idVenta) async {
    final db = await database;
    final res = await db.query('tblDetalleVenta',
        where: 'idVenta=?', whereArgs: [idVenta]);
    return res.map((e) => DetalleVenta.fromMap(e)).toList();
  }

  Future<void> deleteDetallesPorVenta(int idVenta) async {
    final db = await database;
    await db
        .delete('tblDetalleVenta', where: 'idVenta=?', whereArgs: [idVenta]);
  }
}