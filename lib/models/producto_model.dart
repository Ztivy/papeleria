class Producto {
  int? idProducto;
  String nombre;
  double precio;
  int stock;
  int idCategoria;
  String? descripcion;
  String? imagen;

  Producto({
    this.idProducto,
    required this.nombre,
    required this.precio,
    required this.stock,
    required this.idCategoria,
    this.descripcion,
    this.imagen,
  });

  Map<String, dynamic> toMap() => {
        'idProducto': idProducto,
        'nombre': nombre,
        'precio': precio,
        'stock': stock,
        'idCategoria': idCategoria,
        'descripcion': descripcion ?? '',
        'imagen': imagen ?? '',
      };

  factory Producto.fromMap(Map<String, dynamic> map) => Producto(
        idProducto: map['idProducto'],
        nombre: map['nombre'],
        precio: (map['precio'] as num).toDouble(),
        stock: map['stock'],
        idCategoria: map['idCategoria'],
        descripcion: map['descripcion'],
        imagen: map['imagen'],
      );
}
