// lib/src/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Instância singleton para acesso global
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel =
  AndroidNotificationChannel(
    'climapp_notifications',
    'Notificações do Climapp',
    description: 'Notificações recebidas pelo Climapp.',
    importance: Importance.high,
  );

  // Chave global para permitir navegação sem BuildContext
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_channel);
    await androidPlugin?.requestNotificationsPermission();

    // 1. Solicitar permissões (Obrigatório para iOS e Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Permissão concedida pelo usuário.');

      // 2. Obter o FCM Token na inicialização
      String? token = await _fcm.getToken();
      debugPrint('====================================');
      debugPrint('FCM TOKEN DO DISPOSITIVO: $token');
      debugPrint('====================================');

      // Escuta caso o token seja renovado pelo Firebase
      _fcm.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token atualizado: $newToken');
      });

      // 3. Configurar os listeners de eventos
      _setupMessageHandlers();
    } else {
      debugPrint('Permissão negada ou não configurada.');
    }
  }

  void _setupMessageHandlers() {
    // Cenário: Foreground (App aberto na tela)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint(
        'Mensagem recebida em Foreground: ${message.notification?.title}',
      );

      final notification = message.notification;

      if (notification != null) {
        await _localNotifications.show(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: notification.title ?? 'Climapp',
          body: notification.body ?? '',
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    // Cenário: Background (App minimizado e usuário clica na notificação)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Toque na notificação (Background): ${message.data}');
      _handleDeepLink(message);
    });

    // Cenário: Terminated (App fechado e aberto pelo clique na notificação)
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('App inicializado a partir de notificação: ${message.data}');
        _handleDeepLink(message);
      }
    });
  }

  void _handleDeepLink(RemoteMessage message) {
    final city = message.data['city'];
    if (city != null) {
      // Navega diretamente para a tela de clima da cidade
      navigatorKey.currentState?.pushNamed('/weather', arguments: city);
    }
  }
}