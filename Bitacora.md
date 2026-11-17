# Bitácora Ágil de Seguimiento — NidoU

> **Cómo usamos esta bitácora:** un solo archivo que se va actualizando cada semana (no por clase). Cada semana se agrega una nueva sección `## Semana N` al final, sin borrar las anteriores — así queda el historial completo del proyecto.
>
> **Ajustes que hicimos a la plantilla original** (equipo de 2 integrantes):
> - Se fusionaron los roles de Redactor(a) y Facilitador(a) en uno solo: "Encargada de la bitácora", que rota cada semana.
> - La autoevaluación de 4 preguntas se redujo a 1 sola: qué tan cerca estuvimos del compromiso.
> - Se agregó una columna de **Link** en la tabla del tablero (al issue o Pull Request directo).
> - Se agregó un **semáforo autoevaluado** (🟢🟡🔴) que el equipo asigna antes de que lo revise el profesor.

## Datos del equipo

| | |
|---|---|
| **Equipo** | NidoU |
| **Nombre de la app** | NidoU — vivienda estudiantil cerca de la universidad |
| **Integrantes** | Laura, Vanesa |
| **Repositorio** | https://github.com/Lau1907/NidoU |
| **Tablero** | GitHub Projects del repositorio (Issues #1–#14) |
| **Meta general** | PMV funcional en vivo el 20 de noviembre de 2026 |

## Definition of Done (DoD)

- [x] El código compila sin errores y se ejecuta en emulador o dispositivo real.
- [x] Se cumplen todos los criterios de aceptación del issue.
- [x] El Pull Request fue revisado y aprobado por la otra integrante.
- [x] El código está fusionado en `main` y el issue está cerrado.
- [x] Se dejó evidencia (captura, video corto o descripción de cómo probarlo).

---

## Semana 1 — 22 de septiembre al 2 de octubre de 2026

| | |
|---|---|
| **Sprint** | Sprint 1 — Cimientos |
| **Encargada de la bitácora esta semana** | Laura |
| **Semáforo del equipo** | 🟡 Avance parcial |

### 1. Objetivo de la semana

> Dejar configurada la base técnica del proyecto (repositorio, ramas, estructura Flutter con MVVM y proyecto de Firebase) para empezar a construir funcionalidades de negocio la próxima semana.

### 2. Estado del tablero

| Issue | Título | Responsable | Estado | Link |
|---|---|---|---|---|
| #1 | Configurar repositorio y estructura de ramas | Vanesa | ✅ Hecho | github.com/Lau1907/NidoU |
| #2 | Configurar proyecto Firebase | Vanesa | 🔄 En progreso | console.firebase.google.com — proyecto `nidou-687d0` creado |
| #3 | Configurar proyecto Flutter con arquitectura MVVM | Laura | 🔄 En progreso | rama `feature/setup-flutter-mvvm` |
| #4 | Diseñar pantallas en Figma | Laura | ⬜ En backlog | — |
| #5 | Registro e inicio de sesión | Vanesa | ⬜ En backlog | — |

| Planeados | Terminados | En progreso | En revisión | Bloqueados |
|---|---|---|---|---|
| 5 | 1 | 2 | 0 | 0 |

### 3. Stand-up por integrante

| Integrante | ¿Qué hice esta semana? | ¿Qué sigue? | ¿Qué me bloquea? |
|---|---|---|---|
| **Laura** | Instalé el SDK de Flutter y resolví problemas de configuración de PATH en Windows. Armé la estructura MVVM del proyecto (`/views`, `/viewmodels`, `/models`, `/repositories`), los modelos base `User` y `Property`, agregué `provider` y los paquetes de Firebase, y dejé una pantalla de prueba de conexión a Firestore. | Terminar de configurar un emulador Android y correr `flutterfire configure` para verificar la conexión real con Firebase (cierra el issue #3). | Nada bloqueante; falta tiempo de configuración de entorno, no hay impedimento externo. |
| **Vanesa** | Creó el proyecto de Firebase (`nidou-687d0`) en Firebase Console y compartió el acceso con el equipo. | Crear la base de datos de Firestore en modo de prueba y generar las credenciales del proyecto. | Ninguno por el momento. |

### 4. Software funcionando

| Pregunta | Respuesta |
|---|---|
| **¿Hay una versión ejecutable?** | No todavía de punta a punta. El proyecto base de Flutter compila localmente; falta correrlo en un emulador y confirmar la conexión con Firestore. |
| **Funcionalidades que ya se pueden demostrar** | Estructura del proyecto (carpetas MVVM) y modelos de datos iniciales. |

### 5. Riesgos e impedimentos

| Riesgo o impedimento | Impacto | Acción y responsable |
|---|---|---|
| Instalación de Flutter SDK y configuración de PATH en Windows tomó más tiempo del esperado | Medio | Resuelto esta semana; documentado el proceso para no repetirlo en otra máquina. |
| Aún no se verifica la conexión real con Firebase | Medio | Laura corre `flutterfire configure` y prueba la pantalla de conexión en cuanto el emulador esté listo. |

### 6. Mini retrospectiva

| Pregunta | Reflexión del equipo |
|---|---|
| **Qué funcionó bien** | Dividir el trabajo por área (Laura: frontend/Flutter, Vanesa: backend/Firebase) permitió avanzar en paralelo desde el primer día. |
| **Qué debemos mejorar** | Calcular mejor el tiempo que toma la configuración inicial de herramientas (SDKs, emuladores) antes de empezar a escribir código de negocio. |
| **Un cambio concreto para la próxima semana** | Empezar la semana confirmando que ambas tengan su entorno 100% funcional antes de tomar una nueva issue, para no descubrir bloqueos de instalación a medio sprint. |

### 7. Compromisos para la próxima semana

| Compromiso | Responsable | Issue # |
|---|---|---|
| Verificar conexión con Firebase y cerrar la issue | Laura | #3 |
| Crear base de datos Firestore y credenciales | Vanesa | #2 |
| Iniciar funcionalidad de registro/login | Vanesa | #5 |
| Iniciar diseño de pantallas en Figma | Laura | #4 |

### 8. Autoevaluación

**¿Qué tan cerca estuvimos de nuestro compromiso esta semana, del 1 al 5?** → **3/5**

*Justificación: la semana se fue casi por completo en configurar el entorno de desarrollo (algo necesario pero no visible como "funcionalidad"); no se alcanzó a verificar la conexión con Firebase, que era la meta original de la semana.*

**Racha de semanas en verde 🟢:** 0 (primera semana del proyecto)

---

## Semana 2 — 5 al 16 de octubre de 2026

| | |
|---|---|
| **Sprint** | Sprint 2 — Autenticación y Publicación |
| **Encargada de la bitácora esta semana** | Vanesa |
| **Semáforo del equipo** | 🟢 Meta cumplida |

### 1. Objetivo de la semana

> Conectar la aplicación con Firebase Authentication y Cloud Firestore, diseñar la identidad visual y completar el flujo de registro/inicio de sesión con roles diferenciados (`estudiante` y `arrendador`), además de iniciar el módulo de publicación de propiedades.

### 2. Estado del tablero

| Issue | Título | Responsable | Estado | Link |
|---|---|---|---|---|
| #2 | Configurar proyecto Firebase | Vanesa | ✅ Hecho | `nidou-687d0` en Firebase Console |
| #3 | Configurar proyecto Flutter con arquitectura MVVM | Laura | ✅ Hecho | PR fusionado a `develop` |
| #4 | Diseñar pantallas en Figma | Laura | ✅ Hecho | Prototipo paleta terracota/arena/salvia |
| #5 | Registro e inicio de sesión | Vanesa | ✅ Hecho | github.com/Lau1907/NidoU/issues/5 |
| #6 | Publicar nueva propiedad (arrendador) | Laura | 🔄 En progreso | rama `feature/publish-property` |

| Planeados | Terminados | En progreso | En revisión | Bloqueados |
|---|---|---|---|---|
| 5 | 4 | 1 | 0 | 0 |

### 3. Stand-up por integrante

| Integrante | ¿Qué hice esta semana? | ¿Qué sigue? | ¿Qué me bloquea? |
|---|---|---|---|
| **Laura** | Finalicé la conexión real de Flutter con Firestore (`flutterfire configure`), diseñé los prototipos en Figma definiendo la paleta institucional (terracota `#B85042`, arena `#E7E8D1`, salvia `#A7BEAE` y texto `#3A2E2A`) y construí el formulario base de `PublishPropertyView`. | Integrar la selección de fotografías desde galería codificadas en Base64 para evitar depender de Firebase Storage (plan Blaze) y cerrar la issue #6. | Ninguno. |
| **Vanesa** | Habilitó Cloud Firestore y Firebase Authentication (Email/Password), implementó `AuthRepository` y `AuthViewModel` con selección de rol (`estudiante` / `arrendador`) y validación de sesión persistente en `main.dart`. | Apoyar en las reglas de seguridad de Firestore y preparar las consultas del catálogo de propiedades para estudiantes. | Ninguno. |

### 4. Software funcionando

| Pregunta | Respuesta |
|---|---|
| **¿Hay una versión ejecutable?** | Sí. La app ya corre en dispositivo físico Android; permite crear cuentas nuevas eligiendo rol, iniciar sesión y navegar según el perfil del usuario. |
| **Funcionalidades que ya se pueden demostrar** | Registro con rol, inicio/cierre de sesión con Firebase Auth, almacenamiento de perfil inicial en colección `users` y estructura visual con la paleta de NidoU. |

### 5. Riesgos e impedimentos

| Riesgo o impedimento | Impacto | Acción y responsable |
|---|---|---|
| Firebase Storage requiere actualizar al plan de pago Blaze para subir imágenes | Alto | Resuelto por Laura: se implementó compresión y codificación de imágenes en Base64 (`image_picker`) guardadas directamente en Firestore. |

### 6. Mini retrospectiva

| Pregunta | Reflexión del equipo |
|---|---|
| **Qué funcionó bien** | Tener el entorno listo desde el inicio de la semana permitió cerrar 4 issues seguidas y ver la app corriendo en teléfono real. |
| **Qué debemos mejorar** | Realizar Pull Requests más pequeños y frecuentes hacia `develop` para evitar conflictos en `pubspec.yaml` y archivos de configuración de Android. |
| **Un cambio concreto para la próxima semana** | Validar cada feature en dispositivo físico antes de hacer merge a `develop`. |

### 7. Compromisos para la próxima semana

| Compromiso | Responsable | Issue # |
|---|---|---|
| Terminar publicación de propiedades con fotos Base64 | Laura | #6 |
| Implementar catálogo de búsqueda y filtros | Laura / Vanesa | #7 |
| Desarrollar vista de detalle de propiedad y contacto | Vanesa | #8 |

### 8. Autoevaluación

**¿Qué tan cerca estuvimos de nuestro compromiso esta semana, del 1 al 5?** → **5/5**

*Justificación: se cumplieron todas las metas pendientes del Sprint 1 y se entregó completo el flujo de autenticación con roles, dejando lista la base para el catálogo.*

**Racha de semanas en verde 🟢:** 1

---

## Semana 3 — 19 de octubre al 6 de noviembre de 2026

| | |
|---|---|
| **Sprint** | Sprint 3 — Búsqueda, Geolocalización y Detalle |
| **Encargada de la bitácora esta semana** | Laura |
| **Semáforo del equipo** | 🟢 Meta cumplida |

### 1. Objetivo de la semana

> Completar el flujo principal de valor de NidoU: publicación con fotos y ubicación en mapa, exploración de alojamientos con filtros para estudiantes, cálculo automático de cercanía a universidades de Dolores Hidalgo, detalle del inmueble con contacto directo y gestión CRUD para arrendadores.

### 2. Estado del tablero

| Issue | Título | Responsable | Estado | Link |
|---|---|---|---|---|
| #6 | Publicar nueva propiedad (arrendador) | Laura | ✅ Hecho | github.com/Lau1907/NidoU/issues/6 |
| #7 | Búsqueda y filtrado de alojamientos | Laura | ✅ Hecho | github.com/Lau1907/NidoU/issues/7 |
| #8 | Vista de detalle y contacto con arrendador | Vanesa | ✅ Hecho | github.com/Lau1907/NidoU/issues/8 |
| #9 | Geolocalización y cercanía a universidades | Laura | ✅ Hecho | github.com/Lau1907/NidoU/issues/9 |
| #10 | Perfil de usuario y favoritos | Laura / Vanesa | 🔄 En progreso | rama `feature/favoritos` |

| Planeados | Terminados | En progreso | En revisión | Bloqueados |
|---|---|---|---|---|
| 5 | 4 | 1 | 0 | 0 |

### 3. Stand-up por integrante

| Integrante | ¿Qué hice esta semana? | ¿Qué sigue? | ¿Qué me bloquea? |
|---|---|---|---|
| **Laura** | Implementé el selector de ubicación interactivo con `flutter_map` (OpenStreetMap) y geocodificación inversa gratuita con Nominatim, el módulo `universities.dart` con las 7 instituciones de Dolores Hidalgo (UTNG, UDHI, Patria, UDL, UPN, UICEG y CEDHI) con cálculo automático de minutos caminando, y la edición/eliminación de propiedades para el arrendador. | Finalizar la pantalla de perfil con foto Base64 y el sistema de favoritos para cerrar la issue #10. | Ninguno. |
| **Vanesa** | Desarrolló `PropertyDetailView` con carrusel de fotografías, visualización de servicios incluidos, apertura de ubicación en Google Maps y modal de contacto directo con el arrendador (oculto automáticamente cuando el dueño visualiza su propia publicación). | Apoyar en la integración de favoritos en Firestore y preparar los casos de prueba unitarios. | Ninguno. |

### 4. Software funcionando

| Pregunta | Respuesta |
|---|---|
| **¿Hay una versión ejecutable?** | Sí. El flujo de punta a punta entre arrendador y estudiante ya funciona en tiempo real sobre Cloud Firestore. |
| **Funcionalidades que ya se pueden demostrar** | Publicación con hasta 3 fotos Base64, selección de punto en mapa OSM con cálculo automático de minutos a la universidad, edición/borrado de propiedades, filtrado por tipo/precio/universidad, vista de detalle con mini-mapa y contacto por WhatsApp/teléfono. |

### 5. Riesgos e impedimentos

| Riesgo o impedimento | Impacto | Acción y responsable |
|---|---|---|
| Conflictos de layout en `FlutterMap` y archivos temporales de `.gradle` al cambiar de rama | Medio | Resuelto por Laura: se establecieron dimensiones explícitas para los mapas, se limpiaron operadores de nulabilidad inseguros y se depuró el seguimiento de archivos compilados. |

### 6. Mini retrospectiva

| Pregunta | Reflexión del equipo |
|---|---|
| **Qué funcionó bien** | Integrar OpenStreetMap + Nominatim permitió ofrecer mapas interactivos y autocompletado de direcciones sin costo de API keys, adaptándolo exactamente a las universidades de Dolores Hidalgo. |
| **Qué debemos mejorar** | Mantener sincronizado el catálogo de universidades y validaciones en todos los formularios antes de probar en dispositivo. |
| **Un cambio concreto para la próxima semana** | Dedicar el último sprint exclusivamente a favoritos/perfil, pruebas automatizadas (`flutter test`) y ensayo del Demo Day. |

### 7. Compromisos para la próxima semana

| Compromiso | Responsable | Issue # |
|---|---|---|
| Cerrar perfil de usuario con foto y sistema de favoritos | Laura / Vanesa | #10 |
| Escribir pruebas unitarias de ViewModels y lógica | Laura | #11 |
| Escribir pruebas de interfaz (widget tests) | Vanesa | #12 |
| Corregir bugs detectados en pruebas y ensayar demo | Laura / Vanesa | #13, #14 |

### 8. Autoevaluación

**¿Qué tan cerca estuvimos de nuestro compromiso esta semana, del 1 al 5?** → **5/5**

*Justificación: se cerraron las 4 issues críticas del núcleo funcional de la aplicación y el producto ya cumple con los escenarios principales de ambos roles.*

**Racha de semanas en verde 🟢:** 2

---

## Semana 4 — 9 al 20 de noviembre de 2026

| | |
|---|---|
| **Sprint** | Sprint 4 — Pulido, Pruebas y Demo Day |
| **Encargada de la bitácora esta semana** | Vanesa |
| **Semáforo del equipo** | 🟢 En cierre hacia Demo Day |

### 1. Objetivo de la semana

> Completar el perfil de usuario con fotografía y sistema de favoritos (Issue `#10`), ejecutar pruebas unitarias y de interfaz (Issues `#11` y `#12`), corregir incidencias detectadas en pruebas (Issue `#13`) y dejar lista la versión estable en `main` para la demostración en vivo del 20 de noviembre (Issue `#14`).

### 2. Estado del tablero

| Issue | Título | Responsable | Estado | Link |
|---|---|---|---|---|
| #10 | Perfil de usuario y favoritos | Laura / Vanesa | ✅ Hecho | github.com/Lau1907/NidoU/issues/10 |
| #11 | Pruebas unitarias de ViewModels | Laura | ✅ Hecho | github.com/Lau1907/NidoU/issues/11 |
| #12 | Pruebas de interfaz (widget tests) | Vanesa | ✅ Hecho | github.com/Lau1907/NidoU/issues/12 |
| #13 | Corrección de bugs detectados en pruebas | Laura / Vanesa | ✅ Hecho | github.com/Lau1907/NidoU/issues/13 |
| #14 | Preparar y ensayar demo en vivo del PMV | Laura / Vanesa | ⬜ Programado (20 nov) | github.com/Lau1907/NidoU/issues/14 |

| Planeados | Terminados | En progreso | En revisión | Bloqueados |
|---|---|---|---|---|
| 5 | 1 | 3 | 0 | 0 |

### 3. Stand-up por integrante

| Integrante | ¿Qué hice esta semana? | ¿Qué sigue? | ¿Qué me bloquea? |
|---|---|---|---|
| **Laura** | Completé `ProfileView` con subida de foto de perfil en Base64, biografía, carrera/semestre (estudiante), horario de atención y contador de inmuebles (arrendador), además del sistema de favoritos sincronizado con Firestore (`FieldValue.arrayUnion`/`arrayRemove`), pulido de tarjetas e iconos de servicios, y limpieza de `dart analyze` (0 errores). | Ejecutar y fusionar las pruebas unitarias y de widgets en la rama `feature/pruebas-unitarias-widgets` y realizar el merge final a `main`. | Ninguno. |
| **Vanesa** | Enriqueció el modal de contacto en `PropertyDetailView` mostrando foto, biografía y horario del arrendador, y actualizó los enlaces de Google Maps para priorizar coordenadas exactas (`latitude, longitude`). | Validar los casos de prueba de interfaz (`widget tests`) y ensayar el guion de demostración en vivo con datos reales. | Ninguno. |

### 4. Software funcionando

| Pregunta | Respuesta |
|---|---|
| **¿Hay una versión ejecutable?** | Sí. La aplicación compila sin errores (`dart analyze` limpio) y corre fluida en dispositivo físico Android. |
| **Funcionalidades que ya se pueden demostrar** | Flujo completo: registro/login por rol, perfil editable con foto Base64, publicación/edición/eliminación de propiedades con mapa OSM y cálculo automático de minutos a las 7 universidades de Dolores Hidalgo, favoritos con filtro dedicado, detalle con mini-mapa y contacto directo con el arrendador. |

### 5. Riesgos e impedimentos

| Riesgo o impedimento | Impacto | Acción y responsable |
|---|---|---|
| Posible latencia o falla de conexión en Nominatim durante la demo en vivo | Bajo | Resuelto: se implementó respaldo automático con coordenadas exactas para que tanto el guardado como la apertura en Google Maps funcionen siempre. |

### 6. Mini retrospectiva

| Pregunta | Reflexión del equipo |
|---|---|
| **Qué funcionó bien** | La división clara de tareas y el uso de ramas por funcionalidad (`feature/favoritos`, `feature/pruebas-unitarias-widgets`) permitió integrar mejoras visuales y funcionales sin romper lo ya probado. |
| **Qué debemos mejorar** | Automatizar desde sprints tempranos los `widget tests` junto con cada nueva pantalla creada. |
| **Un cambio concreto para la próxima semana** | Mantener congelado el alcance funcional 24 horas antes del Demo Day y enfocarse únicamente en estabilidad y ensayo de presentación. |

### 7. Compromisos para la próxima semana

| Compromiso | Responsable | Issue # |
|---|---|---|
| Ejecutar `flutter test` en verde y cerrar issues #11, #12 y #13 | Laura / Vanesa | #11, #12, #13 |
| Fusionar `develop` en `main` y realizar demostración en vivo del PMV | Laura / Vanesa | #14 |

### 8. Autoevaluación

**¿Qué tan cerca estuvimos de nuestro compromiso esta semana, del 1 al 5?** → **5/5**

*Justificación: el PMV está funcional, pulido visualmente y validado en teléfono real; únicamente resta cerrar las pruebas automatizadas y realizar la presentación final del 20 de noviembre.*

**Racha de semanas en verde 🟢:** 3
