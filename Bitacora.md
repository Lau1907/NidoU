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

- [ ] El código compila sin errores y se ejecuta en emulador o dispositivo real.
- [ ] Se cumplen todos los criterios de aceptación del issue.
- [ ] El Pull Request fue revisado y aprobado por la otra integrante.
- [ ] El código está fusionado en `main` y el issue está cerrado.
- [ ] Se dejó evidencia (captura, video corto o descripción de cómo probarlo).

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
