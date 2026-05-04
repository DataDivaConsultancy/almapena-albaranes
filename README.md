# Alma en Peña — Albaranes ECI

App web para gestionar albaranes (envío, recepción, devolución y traspaso) entre el almacén central de Alma en Peña y los corners ECI.

**Stack**

- **Frontend**: HTML + Tailwind (vía CDN) + JavaScript vanilla. Un único archivo `index.html`.
- **Backend**: [Supabase](https://supabase.com) — PostgreSQL + auth + REST API. Plan gratuito.
- **Hosting**: GitHub Pages.
- **Auth**: login por email con magic link.

## Cómo funciona

Hay dos perfiles:

- **Central** (oficina): sube el Excel de envíos, ve todos los albaranes con su trazabilidad (fecha envío + fecha recepción + incidencias), y procesa las devoluciones que llegan de los corners.
- **Centro** (dependienta): solo ve lo de SU corner. Recibe albaranes (multi-selección con fecha de recepción y campo de incidencias), prepara devoluciones escaneando EANs con la pistola, y crea traspasos a otros corners.

El filtrado por centro lo gobierna la tabla `mapeo_usuarios` y se aplica en el backend mediante Row Level Security de PostgreSQL.

## Puesta en marcha (resumen)

1. **Crea el proyecto Supabase** y ejecuta `supabase/schema.sql` y `supabase/seed.sql` → ver [docs/SETUP_SUPABASE.md](docs/SETUP_SUPABASE.md)
2. **Configura `config.js`** con la URL y la anon key de tu proyecto Supabase.
3. **Despliega en GitHub Pages** (1 click) → ver [docs/DEPLOY_GITHUB.md](docs/DEPLOY_GITHUB.md)
4. **Da de alta a los usuarios** en la tabla `mapeo_usuarios` (asignándoles centro).
5. **Comparte la URL** con el equipo. Se loguean con su email y reciben el enlace de acceso.

## Estructura del repo

```
.
├── index.html                  ← La app (todo en uno)
├── config.example.js           ← Plantilla de config; copiar a config.js
├── supabase/
│   ├── schema.sql              ← Esquema completo (tablas + RLS + funciones)
│   └── seed.sql                ← Centros y usuarios iniciales
├── docs/
│   ├── SETUP_SUPABASE.md       ← Cómo crear el proyecto Supabase
│   ├── DEPLOY_GITHUB.md        ← Cómo desplegar en GitHub Pages
│   └── USERS.md                ← Cómo gestionar altas/bajas de usuarios
└── README.md                   ← Este archivo
```

## Mantenimiento

- **Añadir un usuario nuevo**: insertar fila en `mapeo_usuarios` desde el dashboard de Supabase (Table Editor). Ver [docs/USERS.md](docs/USERS.md).
- **Añadir un centro nuevo**: insertar fila en `centros`.
- **Modificar la app**: editar `index.html`, hacer `git push`, GitHub Pages despliega solo en ~1 minuto.

## Coste

- Supabase plan Free: 500 MB de base de datos, 2 GB de transferencia/mes, 50 K usuarios autenticados/mes. Suficiente para una operación de retail con miles de albaranes/mes.
- GitHub Pages: gratis para repos públicos. Si el repo es privado, requiere GitHub Pro.

## Soporte

Generado por Claude (Anthropic) para Horacio Broggi · Mayo 2026.
