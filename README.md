# Consultas de posgrado

Búsqueda y exportación (CSV) de alumnos de posgrado de CIMAV. Producción: `consultas.posgrado.cimav.edu.mx`.

## Stack

Rails 7 (MySQL, base `sapos_production` en `fermi`), React + TanStack Table, Tailwind v4, esbuild (`jsbundling-rails`), login con Google (solo `@cimav.edu.mx`, usuario activo en la tabla `users`).

## Estructura

- `app/models/student.rb`: filtros (`by_name`, `by_advisor`, `by_program`, `by_area`, `by_status`, `by_campus`, `filtered_by_term_bounds`), `Student.filtered(params)` y `Student.to_csv`.
- `app/controllers/api/`: `students#search` (JSON paginado), `students#export` (CSV) y `filters#index`.
- `app/blueprints/`: serialización JSON.
- `app/frontend/`: componentes React. El entrypoint es `app/javascript/application.jsx`.

## Desarrollo

Variables de entorno necesarias: `FERMI_DATABASE_PASSWORD`, `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`.

```bash
bin/dev   # rails + esbuild --watch + tailwind --watch (Procfile.dev)
```

Compilar a mano: `yarn build` (JS) y `yarn build:css` (CSS). `app/assets/builds/` no se versiona.

## Deploy (servidor `iconvenios`, usuario `appscimav`, `~/search_students_ai`)

```bash
git pull --ff-only origin main
yarn build && yarn build:css
RAILS_ENV=production bundle exec rails assets:precompile   # config.assets.compile = false
sh halt.sh && sh run-production.sh                         # puerto 5000
```

`halt.sh` detiene el puma con `tmp/puma.pid`. Si no existe, el proceso sigue vivo con los assets viejos: buscarlo con `ps -eo pid,args | grep puma` y matarlo.

En el servidor, `public/` es un enlace a `/data/consultas.posgrado.cimav.edu.mx/public`; revisar `git status` antes de un pull. Las credenciales viven en `run-production.sh` (no versionado).

## Tests

No hay suite. `database.yml` no define una base de test y la única base configurada es la de producción compartida, así que no hay que correr tests sin crear antes una base aparte.
