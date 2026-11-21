// Rellena estos dos valores (Supabase → Project Settings → API). Son públicos por diseño:
// la seguridad está en las reglas de la base de datos (supabase-setup.sql), no en ocultarlos.
window.PAWLK_CONFIG = {
  SUPABASE_URL: '',        // ej. https://abcdefgh.supabase.co
  SUPABASE_ANON_KEY: '',   // la clave «anon / public» (NO la service_role)
  GOOGLE: false            // pon true si activas el acceso con Google en Supabase
};
