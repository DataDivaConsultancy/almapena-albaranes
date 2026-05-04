# Configurar Supabase

Tiempo estimado: **15–20 minutos**.

## 1. Crear cuenta y proyecto

1. Entra en [supabase.com](https://supabase.com) y crea una cuenta (puedes usar tu cuenta GitHub para el login).
2. Click en **New project**.
3. Rellena:
   - **Name**: `almapena-albaranes`
   - **Database Password**: genera una segura y guárdala en tu gestor de contraseñas
   - **Region**: `West EU (Frankfurt)` (latencia más baja desde España)
   - **Pricing plan**: Free
4. Click **Create new project**. Tarda 2–3 minutos en provisionar.

## 2. Cargar el esquema

1. En el menú izquierdo: **SQL Editor** → **+ New query**.
2. Abre `supabase/schema.sql` de este repo, copia todo el contenido y pégalo en el editor.
3. Click **Run** (botón verde abajo a la derecha). Debería tardar < 5 segundos y mostrar "Success. No rows returned".
4. Vuelve al SQL Editor → **+ New query**.
5. Abre `supabase/seed.sql`, **edita los emails** de la sección "MAPEO USUARIOS" para reflejar los emails reales de tu equipo, copia y pega.
6. Click **Run**.

Comprueba que las tablas se han creado: menú izquierdo → **Table Editor**. Deberías ver: `centros`, `mapeo_usuarios`, `albaranes`, `lineas_albaran`, `devoluciones`, `lineas_devolucion`.

## 3. Configurar la autenticación

1. Menú izquierdo → **Authentication** → **Providers**.
2. **Email** debe estar activado por defecto. Click sobre él.
3. Verifica que **Enable Email Provider** está ON.
4. Desactiva **Confirm email** (para que el primer login funcione sin verificación adicional). Si quieres más seguridad, déjalo activo y los usuarios tendrán que confirmar la primera vez.
5. **Authentication** → **URL Configuration**:
   - **Site URL**: `https://TU-USUARIO.github.io/almapena-albaranes/` (lo sabrás después de desplegar en GitHub Pages — vuelve aquí en ese momento).
   - **Redirect URLs**: añade la misma URL.

## 4. Obtener la URL y la anon key

1. Menú izquierdo → **Project Settings** (icono de engranaje, abajo) → **API**.
2. Verás:
   - **Project URL** → algo como `https://abcxyzqwerty.supabase.co`
   - **API keys** → **anon / public** → una cadena larga que empieza por `eyJ...`
3. Copia ambos.

## 5. Configurar la app

1. En tu carpeta del repo, copia `config.example.js` a `config.js`:
   ```bash
   cp config.example.js config.js
   ```
2. Abre `config.js` y rellena con los valores del paso anterior.
3. Sube los cambios a GitHub (ver [DEPLOY_GITHUB.md](DEPLOY_GITHUB.md)).

## 6. Verificar que funciona

1. Abre la URL de GitHub Pages.
2. Pon un email que esté en `mapeo_usuarios` → "Recibir enlace de acceso".
3. Revisa tu correo (puede llegar a Spam la primera vez), click en el enlace.
4. Deberías entrar en la app con tu rol asignado.

## Problemas frecuentes

- **"Tu correo no está dado de alta"**: el email no existe en `mapeo_usuarios`. Añádelo en Supabase → Table Editor → mapeo_usuarios → Insert.
- **No llega el correo del magic link**: revisa Spam. Si no aparece, en Supabase → Authentication → Logs verás el envío. El plan Free limita 4 emails/hora por usuario.
- **Error "Invalid Refresh Token"**: pasa cuando el navegador tiene una sesión vieja. Click en "Salir" o borra cookies del dominio.
- **Las consultas devuelven 0 filas**: el RLS está funcionando "demasiado bien". Verifica que la fila del usuario en `mapeo_usuarios` está bien creada y que `centro_id` apunta a un centro que existe.

## Cómo añadir un nuevo corner ECI

Supabase → Table Editor → `centros` → **Insert** → rellena `codigo`, `nombre`, `ciudad`. El cambio aparece en la app al refrescar.

## Cómo dar de baja a un usuario

Supabase → Table Editor → `mapeo_usuarios` → busca su fila y bórrala (botón papelera al pasar el ratón). Para revocar también la sesión activa: Authentication → Users → busca al usuario y bórralo.
