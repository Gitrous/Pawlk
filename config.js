// Rellena estos dos valores (Supabase → Project Settings → API). Son públicos por diseño:
// la seguridad está en las reglas de la base de datos (supabase-setup.sql), no en ocultarlos.
window.PAWLK_CONFIG = {
  SUPABASE_URL: '',        // ej. https://abcdefgh.supabase.co
  SUPABASE_ANON_KEY: '',   // la clave «anon / public» (NO la service_role)
  MIN_AGE: 14,             // edad mínima para usar Pawlk
  MIN_WALK_AGE: 16,        // edad mínima para ofrecerse como paseador (revisa la normativa laboral)
  GOOGLE: false,            // pon true si activas el acceso con Google en Supabase
  // Datos del titular que aparecen en los Términos y la Política de privacidad.
  // Mientras falte alguno, el texto muestra «COMPLETAR …» resaltado.
  LEGAL: {
    NAME: '',              // nombre o razón social del responsable
    NIF: '',               // NIF/CIF
    ADDRESS: '',           // domicilio (calle, CP, ciudad)
    CITY: '',              // ciudad para los tribunales (ej. Palma de Mallorca)
    EMAIL: '',             // correo de contacto/privacidad
    RETENTION: '',         // plazo de copias de seguridad (ej. 30 días)
    REVIEWED: false        // pon true cuando un abogado haya revisado los textos
  }
};
