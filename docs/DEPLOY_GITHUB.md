# Desplegar en GitHub Pages

Tiempo estimado: **5 minutos** la primera vez.

## 1. Crear el repo en GitHub

1. Entra en [github.com](https://github.com) → arriba a la derecha **+ → New repository**.
2. **Owner**: tu usuario.
3. **Repository name**: `almapena-albaranes`.
4. **Description**: "App interna de gestión de albaranes ECI".
5. **Visibility**: **Public** (para que GitHub Pages funcione gratis). Si necesitas privado, requiere GitHub Pro.
6. NO marques "Add README", "Add .gitignore" ni "Add license" — ya los tienes en local.
7. **Create repository**.

## 2. Subir el código por primera vez

Abre una terminal en tu carpeta `almapena-albaranes` y ejecuta:

```bash
git init
git add .
git commit -m "Versión inicial"
git branch -M main
git remote add origin https://github.com/TU-USUARIO/almapena-albaranes.git
git push -u origin main
```

Si te pide credenciales, usa tu usuario de GitHub y un **Personal Access Token** como contraseña (lo creas en GitHub → Settings → Developer settings → Tokens). O instala [GitHub CLI](https://cli.github.com/) (`gh auth login`).

## 3. Activar GitHub Pages

1. En el repo en GitHub → pestaña **Settings**.
2. Menú izquierdo → **Pages**.
3. **Source**: `Deploy from a branch`.
4. **Branch**: `main` / `/ (root)` → **Save**.
5. Espera 1–2 minutos. Refresca la página de Pages: aparecerá la URL de tu app.

La URL será algo como: `https://tu-usuario.github.io/almapena-albaranes/`

## 4. Volver a Supabase y actualizar las URLs

1. Copia la URL de GitHub Pages.
2. En Supabase → **Authentication** → **URL Configuration**:
   - **Site URL** → pega la URL.
   - **Redirect URLs** → añade la URL.
3. Actualiza también `config.js` en tu repo con `APP_URL: "https://tu-usuario.github.io/almapena-albaranes/"`.

## 5. Hacer cambios en el futuro

Cualquier modificación se despliega automáticamente con un `git push`:

```bash
# editas index.html o lo que sea
git add .
git commit -m "Descripción del cambio"
git push
```

GitHub Pages tarda ~1 minuto en publicar. Refresca la URL y verás los cambios.

## Configurar dominio propio (opcional)

Si quieres que la URL sea algo como `albaranes.almapenya.com` en vez de `tu-usuario.github.io/...`:

1. En tu proveedor de dominio (Strato, GoDaddy, etc.), crea un registro CNAME que apunte `albaranes` a `tu-usuario.github.io`.
2. En el repo → **Settings** → **Pages** → **Custom domain** → escribe `albaranes.almapenya.com` → **Save**.
3. Marca **Enforce HTTPS** una vez se valide el certificado (5–10 minutos).
4. Vuelve a actualizar Supabase con la nueva URL.

## Troubleshooting

- **404 al abrir la URL**: GitHub tarda hasta 5 minutos la primera vez. Refresca la pestaña de Settings → Pages para ver el estado.
- **"Falta configuración" al abrir la app**: no has subido `config.js` o no lo has configurado. Verifica que existe en el repo y que NO está en `.gitignore` cuando quieras subirlo.
- **El magic link redirige a localhost**: olvidaste configurar la Site URL en Supabase (paso 4).
- **Cambios que no aparecen tras git push**: probablemente sea caché del navegador. Ctrl+F5 o abre en incógnito.

## ⚠️ Sobre la seguridad de `config.js`

La anon key de Supabase es **pública por diseño** — viaja al navegador. La seguridad real la garantiza el RLS (Row Level Security) que configuramos en el schema. Aun así, mejor no exponer la URL del proyecto sin necesidad.

Por defecto, `.gitignore` excluye `config.js`. Si tu repo es **público** y quieres que la app funcione sin que cada usuario que clone el repo tenga que configurarla, tienes dos opciones:

- **A)** Quitar `config.js` del `.gitignore` y subirlo. Asume que la URL será visible (no es secreta, pero sí información operativa).
- **B)** Mantener `config.js` privado y servirlo aparte. Más complejo, no merece la pena para este caso.

Recomendación: **opción A** para esta app interna.
