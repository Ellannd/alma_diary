# TODO: Notification Restructure

## 🎯 Objetivo
- NotificationController como única fuente de verdad
- UI completamente desacoplada
- Sistema centralizado y consistente

## 📋 Pasos

- [x] 1. Analizar código existente
- [x] 2. Planificar cambios
- [ ] 3. Eliminar notification_seeder.dart
- [ ] 4. Actualizar dashboard_home.dart
- [ ] 5. Actualizar alma_navbar.dart
- [ ] 6. Actualizar alma_challenges.dart
- [ ] 7. Actualizar notifications_page.dart
- [ ] 8. Actualizar auth_gate.dart
- [ ] 9. Actualizar challenge_controller.dart
- [ ] 10. Actualizar challenges_engine_v2.dart
- [ ] 11. Verificar integración completa

## 🔄 Flujo esperado
UI → NotificationController → AlmaNotificationEngine
