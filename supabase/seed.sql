-- ============================================================
-- Datos iniciales para Alma en Peña — Albaranes ECI
-- Ejecutar DESPUÉS de schema.sql
--
-- ⚠️  EDITA los emails de la sección "MAPEO USUARIOS" antes de ejecutar
--     para reflejar los emails reales de tu equipo.
-- ============================================================

-- ---------- CENTROS ----------
insert into public.centros (codigo, nombre, ciudad, direccion, activo) values
  ('ECI-MAD-CAS', 'ECI Castellana - Calzado Mujer', 'Madrid',          'Castellana 85',    true),
  ('ECI-MAD-GOY', 'ECI Goya - Calzado Mujer',       'Madrid',          'Goya 76',          true),
  ('ECI-SEV-DUQ', 'ECI Sevilla Pza. del Duque',     'Sevilla',         'Plaza del Duque',  true),
  ('ECI-SEV-NER', 'ECI Sevilla Nervión',            'Sevilla',         'Nervión',          true),
  ('ECI-MAR-PB',  'ECI Marbella Puerto Banús',      'Marbella',        'Puerto Banús',     true),
  ('ECI-MAL-CEN', 'ECI Málaga Centro',              'Málaga',          'Avda. Andalucía',  true),
  ('ECI-TFE-3MY', 'ECI Tenerife 3 de Mayo',         'S/C de Tenerife', 'Avda. 3 de Mayo',  true),
  ('ECI-VAL-PIN', 'ECI Valencia Pintor Sorolla',    'Valencia',        'Pintor Sorolla',   true),
  ('ECI-BIL-GG',  'ECI Bilbao Gran Vía',            'Bilbao',          'Gran Vía',         true),
  ('ECI-BCN-DIA', 'ECI Barcelona Diagonal',         'Barcelona',       'Avda. Diagonal',   true),
  ('ECI-ZGZ-SAG', 'ECI Zaragoza Sagasta',           'Zaragoza',        'Sagasta',          true),
  ('ECI-COR-COL', 'ECI A Coruña Compostela',        'A Coruña',        'Ramón y Cajal',    true);

-- ---------- MAPEO USUARIOS ----------
-- ⚠️  EDITA estos emails con los reales de tu equipo.
--    Los usuarios deben existir además en Supabase Auth (los crea el primer login con magic link).

insert into public.mapeo_usuarios (email, centro_id, es_central, nombre) values
  -- Central
  ('horacio@almapenya.com', null, true, 'Horacio Broggi'),
  ('central@almapenya.com', null, true, 'Oficina central'),

  -- Dependientas (un mapping por persona; ejemplo)
  ('castellana@almapenya.com', (select id from public.centros where codigo = 'ECI-MAD-CAS'), false, 'Dep. Castellana'),
  ('goya@almapenya.com',       (select id from public.centros where codigo = 'ECI-MAD-GOY'), false, 'Dep. Goya'),
  ('sevilla.duque@almapenya.com', (select id from public.centros where codigo = 'ECI-SEV-DUQ'), false, 'Dep. Sevilla Duque'),
  ('marbella@almapenya.com',   (select id from public.centros where codigo = 'ECI-MAR-PB'),  false, 'Dep. Marbella'),
  ('malaga@almapenya.com',     (select id from public.centros where codigo = 'ECI-MAL-CEN'), false, 'Dep. Málaga'),
  ('tenerife@almapenya.com',   (select id from public.centros where codigo = 'ECI-TFE-3MY'), false, 'Dep. Tenerife')
;

-- ---------- ALBARANES DE EJEMPLO (opcional, para probar la app) ----------
-- Borra esta sección si quieres empezar con la base limpia

with c as (
  select id, nombre from public.centros
)
insert into public.albaranes (num_albaran, tipo, fecha_envio, centro_destino_id, fecha_recepcion, estado)
values
  ('ENV-2026-0048', 'ENVIO', '2026-04-22', (select id from c where nombre = 'ECI Castellana - Calzado Mujer'), '2026-04-23', 'CONFIRMADO'),
  ('ENV-2026-0050', 'ENVIO', '2026-04-28', (select id from c where nombre = 'ECI Castellana - Calzado Mujer'), null, 'PENDIENTE'),
  ('ENV-2026-0052', 'ENVIO', '2026-05-01', (select id from c where nombre = 'ECI Marbella Puerto Banús'), null, 'PENDIENTE'),
  ('ENV-2026-0053', 'ENVIO', '2026-05-02', (select id from c where nombre = 'ECI Sevilla Pza. del Duque'), null, 'PENDIENTE');

-- Líneas para los albaranes anteriores
insert into public.lineas_albaran (albaran_id, ean, referencia, cantidad)
select a.id, '8412345000017', 'AP001-37-NEG', 4 from public.albaranes a where a.num_albaran = 'ENV-2026-0048'
union all
select a.id, '8412345000024', 'AP001-38-NEG', 6 from public.albaranes a where a.num_albaran = 'ENV-2026-0048'
union all
select a.id, '8412345000031', 'AP002-38-CAM', 3 from public.albaranes a where a.num_albaran = 'ENV-2026-0050'
union all
select a.id, '8412345000048', 'AP002-39-CAM', 3 from public.albaranes a where a.num_albaran = 'ENV-2026-0050'
union all
select a.id, '8412345000079', 'AP004-37-BLA', 5 from public.albaranes a where a.num_albaran = 'ENV-2026-0052'
union all
select a.id, '841234500086', 'AP004-38-BLA', 5 from public.albaranes a where a.num_albaran = 'ENV-2026-0052'
union all
select a.id, '8412345000093', 'AP010-U-NEG',  8 from public.albaranes a where a.num_albaran = 'ENV-2026-0053'
union all
select a.id, '8412345000109', 'AP011-85-NEG', 12 from public.albaranes a where a.num_albaran = 'ENV-2026-0053';
