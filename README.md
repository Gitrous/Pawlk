# Pawlk — puesta en marcha en Cloudflare Pages + Supabase (gratis)

La web son archivos estáticos (`index.html`, `config.js`). Los datos, las cuentas y las fotos viven en **Supabase**.
Tardarás unos 10 minutos.

## 1. Crear el proyecto en Supabase
1. Entra en https://supabase.com, crea una cuenta y pulsa **New project** (plan gratuito; elige una región de la UE).
2. Cuando esté listo, abre **SQL Editor → New query**, pega el contenido de `supabase-setup.sql`,
   **cambia `TU_CORREO` por tu correo** (el de administrador) y pulsa **Run**.

## 2. Configurar el acceso
En **Authentication → URL Configuration**:
- **Site URL**: la dirección de tu web en Cloudflare (por ejemplo `https://pawlk.pages.dev`).
- **Redirect URLs**: añade la misma dirección (con `/**` al final).

Acceso por correo (enlace mágico) ya viene activado. Ojo: el envío de correos gratuito de Supabase tiene un límite muy bajo
(unos pocos por hora). Para uso real hay dos salidas:
- **Google**: *Authentication → Providers → Google* (necesita un ID de cliente de Google Cloud) y pon `GOOGLE: true` en `config.js`.
- **SMTP propio** (Resend, Brevo…): *Authentication → SMTP Settings*.

## 3. Conectar la web con Supabase
En **Project Settings → API** copia:
- **Project URL**
- **anon public key** (nunca la `service_role`)

Pégalas en `config.js` (puedes editarlo en GitHub: lápiz → *Commit changes*). Son datos públicos por diseño;
la seguridad está en las reglas de `supabase-setup.sql`.

## 4. Cloudflare Pages
*Workers & Pages → Create → Pages → Connect to Git* → elige el repo.
Framework: **None** · Build command: *(vacío)* · Output directory: **/** . Cada cambio en GitHub se publica solo.

## 5. Comprobar
Abre tu web, entra con tu correo y revisa que puedes subir un perro. Con el correo del paso 1 verás en 👤 el panel de moderación
y el botón «Marcar como verificado» en los perfiles.

## 5b. Datos legales (obligatorio antes de abrirla al público)
En `config.js`, bloque `LEGAL`, rellena: `NAME`, `NIF`, `ADDRESS`, `CITY`, `EMAIL` y `RETENTION`.
Mientras falte alguno, los textos muestran «COMPLETAR …» resaltado y un aviso de borrador.
Los textos (Términos, Privacidad, Normas, Consejos de seguridad) están en la app y en `legal.html` (enlázalo desde tu dominio).
**Son un borrador orientativo: que los revise un abogado** (RGPD/LOPDGDD, servicios de la sociedad de la información, consumo,
fiscalidad, responsabilidad civil y seguro). Cuando los revise, pon `REVIEWED: true` para quitar el aviso.

Si ya habías ejecutado `supabase-setup.sql`, **vuelve a ejecutarlo entero** (es seguro repetirlo): añade el registro de
consentimientos y la función «Borrar mi cuenta».

## Qué protege cada cosa
- Cada persona solo puede escribir en sus propios datos (perros, ofertas, chats, perfil…) — lo impone la base de datos.
- Chats, fechas, precios, partes y datos de emergencia van **cifrados de extremo a extremo** (clave por navegador).
- Solo los administradores (tabla `admins`) pueden verificar perfiles, moderar y leer denuncias y consentimientos.
- Cada persona puede exportar sus datos y borrar su cuenta desde su perfil (👤). Al entrar por primera vez debe aceptar los términos y confirmar que tiene 14 años o más; se guarda versión y fecha.
- Las fotos y vídeos se guardan en el bucket público `pawlk` (cualquiera con el enlace puede verlas).

## Límites conocidos
- Sin notificaciones push con la web cerrada (haría falta un servicio de push).
- Quien pierda su clave (borrando el espacio privado) no podrá leer sus chats antiguos.
