# NidoU

**Tu techo, cerca de tu escuela.**

App móvil (Flutter) que conecta a estudiantes en **Dolores Hidalgo, Guanajuato** con cuartos, departamentos y estudios en renta cerca de su universidad, con fotografías reales, precio mensual, cálculo automático de distancia a pie al campus, favoritos y contacto directo con el arrendador.

Proyecto Integrador de la asignatura **Desarrollo Móvil Integral** (UTNG).

## Problema que resuelve

Cada inicio de semestre, estudiantes foráneos llegan a Dolores Hidalgo y tienen pocas semanas para encontrar dónde vivir. Hoy dependen de grupos de redes sociales desordenados, sin fotos reales ni forma clara de comparar precios o tiempos de traslado a su institución. NidoU centraliza esa búsqueda con ubicaciones verificadas en mapa y contacto directo.

## Enlaces del proyecto

| Recurso | Enlace |
|---|---|
| Repositorio | https://github.com/Lau1907/NidoU |
| Prototipo en Figma | https://www.figma.com/design/pz7JXHoIt3fMkpy85qjGXq/NidoU |
| Tablero de seguimiento | https://github.com/Lau1907/NidoU/projects |

## Alcance del PMV (entrega: 20 de noviembre de 2026)

Flujo completo: **registro con rol → perfil → publicación/búsqueda con mapa → favoritos → detalle → contacto**.

- [x] Registro e inicio de sesión con roles diferenciados (`estudiante` / `arrendador`)
- [x] Perfil editable con fotografía, biografía y datos académicos / horario de atención
- [x] CRUD completo de propiedades para arrendadores (crear, listar propias, editar y eliminar)
- [x] Carga de fotografías reales desde galería (codificación Base64 optimizada)
- [x] Selección interactiva en mapa (OpenStreetMap) y cálculo automático de minutos caminando hacia las 7 instituciones de Dolores Hidalgo (UTNG, UDHI, Universidad Patria, Universidad de León, UPN Unidad 111, UICEG y CEDHI)
- [x] Búsqueda con filtros por universidad, tipo de inmueble, precio y favoritos
- [x] Vista de detalle con mini-mapa embebido, apertura en Google Maps y contacto directo (WhatsApp / llamada / correo)

**Fuera del alcance del PMV:** pasarela de pagos en línea, reseñas verificadas y tours virtuales 360°.

## Estado actual

- [x] Repositorio y estrategia de ramas (`main`, `develop`, `feature/*`)
- [x] Estructura Flutter con arquitectura MVVM
- [x] Proyecto de Firebase (Authentication y Cloud Firestore) vinculado
- [x] Prototipo de pantallas en Figma
- [x] Login, registro y gestión de perfil con foto
- [x] Publicar, editar, eliminar y buscar propiedades
- [x] Geolocalización por universidades de Dolores Hidalgo y sistema de favoritos
- [x] Detalle de inmueble y contacto directo con arrendador
- [x] Pruebas unitarias y de interfaz (`flutter test` — 29/29 aprobadas) y entrega final en `main`

## Tecnologías

| Categoría | Tecnología |
|---|---|
| App móvil | Flutter + Dart |
| Manejo de estado | Provider |
| Base de datos | Cloud Firestore |
| Autenticación | Firebase Authentication |
| Almacenamiento de imágenes | Base64 comprimido en Firestore (`image_picker`) |
| Mapas y geolocalización | OpenStreetMap (`flutter_map`, `latlong2`, Nominatim API) + Google Maps |
| Pruebas automatizadas | `flutter_test` (Unit tests & Widget tests) |
| Diseño | Figma |
| Control de versiones | Git + GitHub |

## Arquitectura

**MVVM** (Model-View-ViewModel):

```
View  →  ViewModel  →  Repository  →  Firebase
```

```
lib/
├── models/          # User, Property
├── views/           # Login, Registro, Búsqueda, Publicación/Edición, Detalle, Perfil
├── viewmodels/      # Estado y lógica de presentación
├── repositories/    # Acceso a Firebase Auth y Cloud Firestore
├── utils/           # Catálogo de universidades de Dolores Hidalgo y cálculo de distancias
├── widgets/         # Componentes reutilizables (PropertyImage)
├── firebase_options.dart
└── main.dart

test/
├── universities_and_models_test.dart
├── property_test.dart
└── widgets/
└── property_widgets_test.dart
```

## Cómo ejecutar el proyecto

### Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado y en el PATH
- Android Studio (incluye el SDK de Android) con las licencias aceptadas: `flutter doctor --android-licenses`
- Un celular Android con depuración USB activada, o un emulador
- Acceso como Editor al proyecto de Firebase (pídelo a quien lo creó)

### Pasos

```bash
git clone https://github.com/Lau1907/NidoU.git
cd NidoU
git checkout develop
flutter pub get
flutter devices      # tu celular debe aparecer en la lista
flutter run
```

### Ejecutar Pruebas

```bash
dart analyze
flutter test
```

### Configurar Firebase en tu máquina

Si es la primera vez que corres el proyecto, vincula tu entorno al proyecto de Firebase:

```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

Si `flutterfire` no se reconoce, usa `dart pub global run flutterfire_cli:flutterfire configure`.

> No subas a este repositorio llaves, contraseñas ni archivos de credenciales privadas.

## Flujo de trabajo (Git)

- `main`: versión estable para entrega.
- `develop`: integración de funcionalidades terminadas.
- `feature/nombre-funcionalidad`: una rama por issue, creada desde `develop`.

Cada rama se integra a `develop` con un Pull Request revisado por la otra integrante. Los commits mencionan el número de issue, por ejemplo `feat: pantalla de login (#5)`.

## Metodología

Scrum, con sprints de dos semanas y seguimiento en GitHub Projects. La bitácora semanal del equipo está en la carpeta `/bitacora`.

## Equipo

| Integrante | Rol |
|---|---|
| Laura | Product Owner + Dev Team (Frontend / Flutter) |
| Vanesa | Scrum Master + Dev Team (Backend / Firebase) |