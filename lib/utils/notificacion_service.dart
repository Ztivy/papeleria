import 'package:bdp/database/papeleriadb.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
class NotificationService {
  static Future<void> init() async {
    // Notificaciones desactivadas temporalmente
  }

  static Future<void> verificarYNotificar() async {
    // Notificaciones desactivadas temporalmente
  }
}
/*
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  static Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'papeleria_recordatorios',
      'Recordatorios Papelería',
      channelDescription: 'Avisos de pedidos próximos a vencer',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails());
    await _plugin.show(id, title, body, details);
  }

  static Future<void> verificarYNotificar() async {
    try {
      final db     = PapeleriaDB();
      final ventas = await db.getVentasPendientesNotificacion();
      final fmt    = DateFormat('dd/MM/yyyy');

      for (final v in ventas) {
        await show(
          id:    v.idVenta!,
          title: '📦 Recordatorio de pedido',
          body:  'Pedido de ${v.clienteNombre} vence el ${fmt.format(v.fechaEntrega)}',
        );
        await db.marcarNotificacionEnviada(v.idVenta!);
      }
    } catch (_) {
      // Silencioso si no hay permisos aún
    }
  }
}
*/