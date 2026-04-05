import 'package:bdp/models/producto_model.dart';

class Venta {
  int? idVenta;
  String clienteNombre;
  String clienteTelefono;
  DateTime fechaVenta;
  DateTime fechaEntrega;
  int estatus;
  double total;
  String? notas;
  bool notificacionEnviada;

  Venta({
    this.idVenta,
    required this.clienteNombre,
    required this.clienteTelefono,
    required this.fechaVenta,
    required this.fechaEntrega,
    this.estatus = 0,
    this.total = 0.0,
    this.notas,
    this.notificacionEnviada = false,
  });

  String get estatusTexto {
    switch (estatus) {
      case 0: return 'En proceso';
      case 1: return 'Completada';
      case 2: return 'Cancelada';
      default: return 'Desconocido';
    }
  }

  Map<String, dynamic> toMap() => {
        'idVenta': idVenta,
        'clienteNombre': clienteNombre,
        'clienteTelefono': clienteTelefono,
        'fechaVenta': fechaVenta.toIso8601String(),
        'fechaEntrega': fechaEntrega.toIso8601String(),
        'estatus': estatus,
        'total': total,
        'notas': notas ?? '',
        'notificacionEnviada': notificacionEnviada ? 1 : 0,
      };

  factory Venta.fromMap(Map<String, dynamic> map) => Venta(
        idVenta: map['idVenta'],
        clienteNombre: map['clienteNombre'],
        clienteTelefono: map['clienteTelefono'],
        fechaVenta: DateTime.parse(map['fechaVenta']),
        fechaEntrega: DateTime.parse(map['fechaEntrega']),
        estatus: map['estatus'],
        total: (map['total'] as num).toDouble(),
        notas: map['notas'],
        notificacionEnviada: map['notificacionEnviada'] == 1,
      );

  Venta copyWith({
    int? idVenta,
    String? clienteNombre,
    String? clienteTelefono,
    DateTime? fechaVenta,
    DateTime? fechaEntrega,
    int? estatus,
    double? total,
    String? notas,
    bool? notificacionEnviada,
  }) =>
      Venta(
        idVenta: idVenta ?? this.idVenta,
        clienteNombre: clienteNombre ?? this.clienteNombre,
        clienteTelefono: clienteTelefono ?? this.clienteTelefono,
        fechaVenta: fechaVenta ?? this.fechaVenta,
        fechaEntrega: fechaEntrega ?? this.fechaEntrega,
        estatus: estatus ?? this.estatus,
        total: total ?? this.total,
        notas: notas ?? this.notas,
        notificacionEnviada: notificacionEnviada ?? this.notificacionEnviada,
      );
}

class DetalleVenta {
  int? idDetalle;
  int idVenta;
  int idProducto;
  String nombreProducto;
  double precioUnitario;
  int cantidad;
  double subtotal;

  DetalleVenta({
    this.idDetalle,
    required this.idVenta,
    required this.idProducto,
    required this.nombreProducto,
    required this.precioUnitario,
    required this.cantidad,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() => {
        'idDetalle': idDetalle,
        'idVenta': idVenta,
        'idProducto': idProducto,
        'nombreProducto': nombreProducto,
        'precioUnitario': precioUnitario,
        'cantidad': cantidad,
        'subtotal': subtotal,
      };

  factory DetalleVenta.fromMap(Map<String, dynamic> map) => DetalleVenta(
        idDetalle: map['idDetalle'],
        idVenta: map['idVenta'],
        idProducto: map['idProducto'],
        nombreProducto: map['nombreProducto'],
        precioUnitario: (map['precioUnitario'] as num).toDouble(),
        cantidad: map['cantidad'],
        subtotal: (map['subtotal'] as num).toDouble(),
      );
}

class ItemCarrito {
  Producto producto;
  int cantidad;

  ItemCarrito({required this.producto, this.cantidad = 1});

  double get subtotal => producto.precio * cantidad;
}
