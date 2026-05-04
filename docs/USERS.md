# Gestión de usuarios

## Cómo funciona la autenticación

1. Cualquier persona puede pedir un magic link en la pantalla de login.
2. Si entra a un email **NO mapeado** en `mapeo_usuarios`, la app le rechaza el acceso (cierra sesión inmediatamente).
3. Solo los emails mapeados pueden ver datos, y cada uno solo ve los suyos según su `centro_id` (o todos, si `es_central = true`).

Esto significa que **no hace falta crear usuarios manualmente en Supabase Auth** — se crean al primer magic link válido. Lo único que tienes que hacer tú es mantener la tabla `mapeo_usuarios`.

## Dar de alta a una nueva dependienta

1. Supabase → Table Editor → **mapeo_usuarios** → **Insert** → **Insert row**.
2. Rellena:
   - **email**: el correo corporativo (mejor en minúsculas).
   - **centro_id**: click en el campo, busca el corner por nombre.
   - **es_central**: dejar en `false`.
   - **nombre**: opcional, ayuda para identificar.
3. **Save**.
4. Avisa a la persona: "ya estás dada de alta, entra en `https://tu-usuario.github.io/almapena-albaranes/` con tu email".

## Cambiar a alguien de centro

Edita su fila en `mapeo_usuarios` y cambia el `centro_id`. La próxima vez que recargue la app verá los datos del centro nuevo.

## Dar acceso a alguien de central

Crear su fila con `es_central = true` y `centro_id` vacío.

## Dar de baja

1. Borra su fila de `mapeo_usuarios` (Supabase → Table Editor → buscar → papelera).
2. Si quieres además invalidarle la sesión activa: Supabase → Authentication → Users → buscar usuario → "Delete user".

## Listar usuarios actuales

Supabase → Table Editor → `mapeo_usuarios`. Puedes filtrar por `es_central = true` para ver el equipo de central, o por `centro_id` para ver los de un corner concreto.

## Email corporativo vs Gmail/personal

La app no fuerza un dominio. Puedes mapear gmail/hotmail si una dependienta no tiene correo corporativo aún. Pero mejor estandarizar: `nombre@almapenya.com`.
