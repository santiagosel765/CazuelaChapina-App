# CazuelaApp Frontend Technical Documentation

## Estructura de carpetas
- `lib/`
  - `main.dart`: punto de entrada de la aplicación y configuración inicial.
  - `models/`: define las entidades de dominio utilizadas en la app (usuarios, ventas, inventario, etc.).
  - `screens/`: conjunto de pantallas principales, cada una representa una vista específica de la aplicación.
  - `services/`: capa de comunicación con el backend y otros servicios locales como notificaciones.
  - `widgets/`: widgets reutilizables como botones y menús.
  - `theme_notifier.dart`: manejador del tema claro/oscuro con persistencia local.
- Directorios de plataforma (`android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`) contienen la configuración específica de cada sistema.

## Componentes clave
### Pantallas
Las pantallas se ubican en `lib/screens` e incluyen flujos como autenticación, dashboard, inventario, ventas y chat.

### Widgets personalizados
En `lib/widgets` se encuentran componentes reutilizables como `AppDrawer` y `ChatButton` que encapsulan lógica UI compartida.

### Servicios
La carpeta `lib/services` implementa la comunicación con la API y otras funcionalidades auxiliares. Por ejemplo:
```dart
class NotificationService {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    // ... configuración de permisos y canales
  }
}
```

## Manejo de estado
La aplicación utiliza **Provider** con `ChangeNotifier` para el manejo global del estado (por ejemplo, el tema de la app) y `setState` en widgets individuales para actualizaciones locales.

```dart
runApp(
  ChangeNotifierProvider<ThemeNotifier>.value(
    value: themeNotifier,
    child: const MyApp(),
  ),
);
```

## Notificaciones push y permisos
Se emplean `firebase_messaging` para recibir mensajes push y `flutter_local_notifications` para mostrarlos en primer plano. Los permisos se solicitan al inicializar `NotificationService` y se registra el token FCM con el backend.

## Reconocimiento de voz (desactivado temporalmente)
El paquete `speech_to_text` fue removido debido a problemas de compatibilidad en Windows.
TODO: reevaluar e incorporar nuevamente cuando exista soporte estable multiplataforma.

## Compatibilidad
El enfoque actual es **Android**; otros directorios de plataforma se mantienen para pruebas futuras, pero la entrega oficial se realiza en dispositivos Android.

## Recomendaciones para desarrollo y pruebas locales
1. Instalar dependencias:
   ```bash
   flutter pub get
   ```
2. Limpiar artefactos previos:
   ```bash
   flutter clean
   ```
3. Ejecutar la aplicación en un emulador o dispositivo conectado:
   ```bash
   flutter run
   ```

## Notas técnicas
- Verificar el archivo `pubspec.yaml` antes de agregar nuevas dependencias.
- Mantener consistentes los modelos y endpoints del backend.
- Revisar los TODOs existentes (por ejemplo, soporte de reconocimiento de voz) antes de comenzar nuevas funcionalidades.

## Documentation
Further architectural details, component responsibilities and development guidelines are documented in * ***

## Author
Selvin Santiago Pu Chiguil  
Full‑stack web developer based in Guatemala  
Selvin.san90@gmail.com

## License
This project is licensed under the MIT License.
