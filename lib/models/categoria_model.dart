// lib/models/categoria_model.dart
class Categoria {
  int? idCategoria;
  String nombre;
  String icono;
  String color;

  Categoria({
    this.idCategoria,
    required this.nombre,
    required this.icono,
    required this.color,
  });

  Map<String, dynamic> toMap() => {
        'idCategoria': idCategoria,
        'nombre': nombre,
        'icono': icono,
        'color': color,
      };

  factory Categoria.fromMap(Map<String, dynamic> map) => Categoria(
        idCategoria: map['idCategoria'],
        nombre: map['nombre'],
        icono: map['icono'],
        color: map['color'],
      );
}
