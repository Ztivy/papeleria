import 'package:bdp/models/venta_model.dart';
import 'package:flutter/material.dart';
import 'package:bdp/models/producto_model.dart';

class CarritoProvider extends ChangeNotifier {
  final List<ItemCarrito> _items = [];

  List<ItemCarrito> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, i) => sum + i.cantidad);

  double get totalPrecio => _items.fold(0.0, (sum, i) => sum + i.subtotal);

  void agregar(Producto producto, {int cantidad = 1}) {
    final idx = _items.indexWhere((i) => i.producto.idProducto == producto.idProducto);
    if (idx >= 0) {
      _items[idx].cantidad += cantidad;
    } else {
      _items.add(ItemCarrito(producto: producto, cantidad: cantidad));
    }
    notifyListeners();
  }

  void reducir(Producto producto) {
    final idx = _items.indexWhere((i) => i.producto.idProducto == producto.idProducto);
    if (idx >= 0) {
      if (_items[idx].cantidad > 1) {
        _items[idx].cantidad--;
      } else {
        _items.removeAt(idx);
      }
      notifyListeners();
    }
  }

  void eliminar(Producto producto) {
    _items.removeWhere((i) => i.producto.idProducto == producto.idProducto);
    notifyListeners();
  }

  void limpiar() {
    _items.clear();
    notifyListeners();
  }

  int getCantidad(int idProducto) {
    final idx = _items.indexWhere((i) => i.producto.idProducto == idProducto);
    return idx >= 0 ? _items[idx].cantidad : 0;
  }
}
