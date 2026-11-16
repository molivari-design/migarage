# Mi Garage

App web para el seguimiento y el mantenimiento de los autos: kilometraje, service, arreglos pendientes, cargas de combustible, lavados, gastos y manual con asistencia.

- Página estática (sin build): HTML + JS. Se puede subir tal cual a Vercel.
- Datos en **Supabase**, compartidos entre todos los mails autorizados y sincronizados en vivo.
- **Funciona sin conexión** una vez instalada: muestra lo último que tenías y sube los cambios cuando vuelve la señal.
- Se instala en el inicio del celular con su propio ícono.

## 1. Supabase

1. Creá un proyecto nuevo, o usá uno que ya tengas. Conviene uno aparte de los del trabajo.
2. Abrí **SQL Editor**, pegá el contenido de `supabase/schema.sql` y, **antes de correrlo**, reemplazá los dos mails del final por los reales, en minúsculas. Después tocá **Run**.
3. En el mismo editor, pegá `supabase/seed.sql` y tocá **Run**. Esto carga todo lo que ya estaba en la app: la Hilux, el service de 20.000, los lavados, los contactos, etc.
4. Andá a **Authentication → Users → Add user** y creá un usuario para cada uno (mail y contraseña, con *Auto Confirm User* tildado). Los mails tienen que ser los mismos del paso 2.
5. Recomendado: en **Authentication → Sign In / Providers**, desactivá *Allow new users to sign up*, así nadie más puede crear una cuenta.
6. Copiá la **Project URL** y la **anon public key** desde **Project Settings → API** y pegalas en `config.js`.

> La anon key está pensada para ir en el navegador. La protección la dan las políticas RLS de `schema.sql`: solo los mails de `garage_members` pueden leer o escribir.

Para sumar a alguien más adelante:

```sql
insert into public.garage_members (email) values ('nuevo@mail.com');
```

Después creale el usuario en **Authentication → Users**.

## 2. GitHub y Vercel

1. Subí esta carpeta a un repositorio nuevo de GitHub (por ejemplo, `mi-garage`).
2. En Vercel: **Add New → Project**, elegí el repo, *Framework Preset*: **Other**, sin build command ni output directory. Tocá **Deploy**.
3. Si querés, en **Settings → Domains** le asignás un dominio propio.

Cada vez que se hace push al repo, Vercel publica la versión nueva sola.

## 3. Instalarla en el celular

- **iPhone:** abrí la URL en Safari → Compartir → **Agregar a pantalla de inicio**.
- **Android:** abrí la URL en Chrome → menú ⋮ → **Instalar app**.

Ingresá una vez con mail y contraseña. La sesión queda guardada.

## Estructura

```
index.html              la app completa
config.js               URL y anon key de Supabase
sw.js                   service worker (uso sin conexión)
manifest.webmanifest    nombre e íconos para instalarla
vendor/supabase.js      cliente de Supabase (incluido, para que funcione offline)
icons/                  íconos y foto de la Hilux
supabase/schema.sql     tablas, permisos y tiempo real
supabase/seed.sql       datos migrados desde la versión anterior
```

## Notas

- Todo se guarda en una sola tabla, `garage_items`. Cada fila es un vehículo, un registro o una foto, con su contenido en `data` (JSON).
- Si cambiás algo de la app y no aparece en el celular, cerrala y abrila de nuevo: el service worker baja la versión nueva en la siguiente apertura.
