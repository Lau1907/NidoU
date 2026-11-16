# NidoU

**Tu techo, cerca de tu escuela.**

App móvil (Flutter) que conecta a estudiantes foráneos con cuartos, departamentos y casas en renta cerca de su universidad, con fotos reales, precio, distancia al campus y contacto directo con el arrendador.

Proyecto Integrador de la asignatura Desarrollo Móvil Integral.

## Problema que resuelve

Cada inicio de semestre, estudiantes foráneos llegan a ciudades que no conocen y tienen pocas semanas para encontrar dónde vivir. Hoy dependen de grupos de Facebook desordenados, sin fotos reales ni forma de comparar precios o distancia al campus, con riesgo de fraudes. NidoU centraliza esa búsqueda en un solo lugar.

## Enlaces del proyecto

| Recurso | Enlace |
|---|---|
| Repositorio | https://github.com/Lau1907/NidoU |
| Prototipo en Figma | https://www.figma.com/design/pz7JXHoIt3fMkpy85qjGXq/NidoU |
| Tablero de seguimiento | [pega aquí el link de GitHub Projects] |

## Alcance del PMV (entrega: 20 de noviembre de 2026)

Flujo completo: **registro → búsqueda → detalle → contacto**.

- [ ] Registro e inicio de sesión (estudiante / arrendador)
- [ ] Publicar propiedad con fotos, precio y ubicación
- [ ] Buscar propiedades con filtros de precio y distancia
- [ ] Ver detalle de propiedad con ubicación en Google Maps
- [ ] Contacto directo con el arrendador

**Fuera del PMV por ahora:** favoritos, reseñas, pagos, tours virtuales, recomendaciones.

## Estado actual

- [x] Repositorio y estrategia de ramas
- [x] Estructura Flutter con arquitectura MVVM
- [x] Proyecto de Firebase y Firestore creados y vinculados
- [x] Prototipo de tres pantallas en Figma
- [ ] Login y registro
- [ ] Publicar y buscar propiedades
- [ ] Detalle y contacto

## Tecnologías

| Categoría | Tecnología |
|---|---|
| App móvil | Flutter + Dart |
| Manejo de estado | Provider |
| Base de datos | Cloud Firestore |
| Autenticación | Firebase Authentication |
| Almacenamiento de fotos | Firebase Storage |
| Mapas | Enlace a Google Maps |
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
├── views/           # Pantallas
├── viewmodels/      # Estado y lógica de presentación
├── repositories/    # Acceso a Firebase
├── firebase_options.dart
└── main.dart
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