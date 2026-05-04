-- ============================================================
-- Alma en Peña — Albaranes ECI
-- Esquema completo para Supabase (PostgreSQL)
--
-- Cómo usar:
--   1. Crea un proyecto nuevo en supabase.com
--   2. Ve a SQL Editor → New query
--   3. Pega TODO este archivo y dale a Run
--   4. Después ejecuta seed.sql para datos iniciales
-- ============================================================

-- ---------- Tabla: centros ----------
create table public.centros (
  id           uuid primary key default gen_random_uuid(),
  codigo       text unique not null,
  nombre       text unique not null,
  ciudad       text,
  direccion    text,
  responsable  text,
  email        text,
  telefono     text,
  activo       boolean not null default true,
  created_at   timestamptz default now()
);

-- ---------- Tabla: mapeo_usuarios ----------
-- Asocia cada email de usuario a un centro (o lo marca como central)
create table public.mapeo_usuarios (
  id          uuid primary key default gen_random_uuid(),
  email       text unique not null,
  centro_id   uuid references public.centros(id) on delete set null,
  es_central  boolean not null default false,
  nombre      text,
  created_at  timestamptz default now()
);

create index idx_mapeo_email on public.mapeo_usuarios (lower(email));

-- ---------- Tabla: albaranes ----------
create table public.albaranes (
  id                  uuid primary key default gen_random_uuid(),
  num_albaran         text unique not null,
  tipo                text not null check (tipo in ('ENVIO', 'TRASPASO')),
  fecha_envio         date not null,
  centro_origen_id    uuid references public.centros(id),  -- null para envío desde almacén
  centro_destino_id   uuid not null references public.centros(id),
  fecha_recepcion     date,
  incidencia          text,
  estado              text not null default 'PENDIENTE'
                      check (estado in ('PENDIENTE', 'CONFIRMADO')),
  recepcionado_por    text,         -- email del usuario que confirma
  created_at          timestamptz default now(),
  updated_at          timestamptz default now()
);

create index idx_alb_destino on public.albaranes (centro_destino_id);
create index idx_alb_estado  on public.albaranes (estado);
create index idx_alb_fecha   on public.albaranes (fecha_envio desc);

-- ---------- Tabla: lineas_albaran ----------
create table public.lineas_albaran (
  id           uuid primary key default gen_random_uuid(),
  albaran_id   uuid not null references public.albaranes(id) on delete cascade,
  ean          text not null,
  referencia   text,
  cantidad     integer not null check (cantidad > 0),
  created_at   timestamptz default now()
);

create index idx_lin_albaran on public.lineas_albaran (albaran_id);

-- ---------- Tabla: devoluciones ----------
create table public.devoluciones (
  id              uuid primary key default gen_random_uuid(),
  num_devolucion  text unique not null,
  centro_id       uuid not null references public.centros(id),
  fecha           date not null default current_date,
  estado          text not null default 'PENDIENTE_ALMACEN'
                  check (estado in ('PENDIENTE_ALMACEN', 'ENVIADO_ALMACEN')),
  observaciones   text,
  creado_por      text,           -- email del usuario que la prepara
  created_at      timestamptz default now()
);

create index idx_dev_centro on public.devoluciones (centro_id);
create index idx_dev_estado on public.devoluciones (estado);

-- ---------- Tabla: lineas_devolucion ----------
create table public.lineas_devolucion (
  id              uuid primary key default gen_random_uuid(),
  devolucion_id   uuid not null references public.devoluciones(id) on delete cascade,
  ean             text not null,
  cantidad        integer not null check (cantidad > 0),
  created_at      timestamptz default now()
);

create index idx_lin_dev on public.lineas_devolucion (devolucion_id);

-- ============================================================
-- VISTA: albaranes_con_total (cabecera + total uds)
-- ============================================================
create or replace view public.albaranes_con_total as
select
  a.*,
  co.nombre  as centro_origen,
  cd.nombre  as centro_destino,
  coalesce((select sum(cantidad) from public.lineas_albaran l where l.albaran_id = a.id), 0) as total_uds,
  coalesce((select count(*) from public.lineas_albaran l where l.albaran_id = a.id), 0)      as total_lineas
from public.albaranes a
left join public.centros co on co.id = a.centro_origen_id
left join public.centros cd on cd.id = a.centro_destino_id;

-- ============================================================
-- TRIGGER: actualizar updated_at en albaranes
-- ============================================================
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger trg_albaranes_touch
before update on public.albaranes
for each row execute function public.touch_updated_at();

-- ============================================================
-- FUNCIONES DE AYUDA
-- ============================================================

-- Devuelve el id del centro del usuario logueado (o null si es central / no mapeado)
create or replace function public.mi_centro_id() returns uuid language sql stable as $$
  select centro_id from public.mapeo_usuarios
   where lower(email) = lower(auth.jwt() ->> 'email')
   limit 1;
$$;

-- True si el usuario logueado es central
create or replace function public.es_central() returns boolean language sql stable as $$
  select coalesce(es_central, false) from public.mapeo_usuarios
   where lower(email) = lower(auth.jwt() ->> 'email')
   limit 1;
$$;

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================
-- Idea: los usuarios "centro" solo ven/modifican filas relacionadas con SU centro.
-- Los usuarios "central" ven y modifican todo. Los no autenticados no ven nada.

alter table public.centros           enable row level security;
alter table public.mapeo_usuarios    enable row level security;
alter table public.albaranes         enable row level security;
alter table public.lineas_albaran    enable row level security;
alter table public.devoluciones      enable row level security;
alter table public.lineas_devolucion enable row level security;

-- ----- centros -----
-- Todos los autenticados pueden leer (necesario para los selects/dropdowns)
create policy "centros_select_auth"
  on public.centros for select to authenticated using (true);

-- Solo central puede insertar/modificar centros
create policy "centros_write_central"
  on public.centros for all to authenticated
  using (public.es_central()) with check (public.es_central());

-- ----- mapeo_usuarios -----
-- Cada usuario ve su propio mapeo; central ve todos
create policy "mapeo_select_propio"
  on public.mapeo_usuarios for select to authenticated
  using (lower(email) = lower(auth.jwt() ->> 'email') or public.es_central());

create policy "mapeo_write_central"
  on public.mapeo_usuarios for all to authenticated
  using (public.es_central()) with check (public.es_central());

-- ----- albaranes -----
-- SELECT: central ve todo; centro ve solo los suyos (origen o destino)
create policy "alb_select"
  on public.albaranes for select to authenticated
  using (
    public.es_central()
    or centro_destino_id = public.mi_centro_id()
    or centro_origen_id  = public.mi_centro_id()
  );

-- INSERT/UPDATE: central full; centro puede crear traspasos desde su centro y actualizar (recepcionar) los suyos
create policy "alb_insert_central"
  on public.albaranes for insert to authenticated with check (public.es_central());

create policy "alb_insert_traspaso_centro"
  on public.albaranes for insert to authenticated with check (
    not public.es_central()
    and tipo = 'TRASPASO'
    and centro_origen_id = public.mi_centro_id()
  );

create policy "alb_update"
  on public.albaranes for update to authenticated using (
    public.es_central()
    or centro_destino_id = public.mi_centro_id()   -- recepción
    or centro_origen_id  = public.mi_centro_id()
  );

create policy "alb_delete_central"
  on public.albaranes for delete to authenticated using (public.es_central());

-- ----- lineas_albaran -----
create policy "lin_select"
  on public.lineas_albaran for select to authenticated using (
    exists (select 1 from public.albaranes a where a.id = albaran_id and (
      public.es_central()
      or a.centro_destino_id = public.mi_centro_id()
      or a.centro_origen_id  = public.mi_centro_id()
    ))
  );

create policy "lin_insert"
  on public.lineas_albaran for insert to authenticated with check (
    exists (select 1 from public.albaranes a where a.id = albaran_id and (
      public.es_central() or a.centro_origen_id = public.mi_centro_id()
    ))
  );

create policy "lin_delete_central"
  on public.lineas_albaran for delete to authenticated using (public.es_central());

-- ----- devoluciones -----
create policy "dev_select"
  on public.devoluciones for select to authenticated using (
    public.es_central() or centro_id = public.mi_centro_id()
  );

create policy "dev_insert_centro"
  on public.devoluciones for insert to authenticated with check (
    centro_id = public.mi_centro_id()
  );

create policy "dev_update_central"
  on public.devoluciones for update to authenticated using (public.es_central());

-- ----- lineas_devolucion -----
create policy "lin_dev_select"
  on public.lineas_devolucion for select to authenticated using (
    exists (select 1 from public.devoluciones d where d.id = devolucion_id and (
      public.es_central() or d.centro_id = public.mi_centro_id()
    ))
  );

create policy "lin_dev_insert"
  on public.lineas_devolucion for insert to authenticated with check (
    exists (select 1 from public.devoluciones d where d.id = devolucion_id and d.centro_id = public.mi_centro_id())
  );

-- ============================================================
-- FIN DEL ESQUEMA
-- ============================================================
