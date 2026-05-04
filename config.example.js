// Copia este archivo a `config.js` y rellena con los valores de tu proyecto Supabase
// (Project Settings → API).
//
// IMPORTANTE: Tanto la URL como la anon key son públicas (van al navegador).
// La seguridad real la da el RLS configurado en schema.sql.

window.ALMAPENYA_CONFIG = {
  SUPABASE_URL: "https://TU-PROYECTO.supabase.co",
  SUPABASE_ANON_KEY: "TU_ANON_KEY_AQUI",

  // URL pública donde está desplegada la app (para los magic links de email).
  // Si la pones en GitHub Pages, será algo como: https://tu-usuario.github.io/almapena-albaranes/
  APP_URL: "https://tu-usuario.github.io/almapena-albaranes/",
};
