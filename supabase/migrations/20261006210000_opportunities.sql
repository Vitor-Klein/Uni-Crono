-- Catálogo de cursos e eventos em que o aluno ganha certificado de horas.
-- O app só lê o que está publicado; o catálogo entra por migração ou painel.

create type public.opportunity_kind as enum ('course', 'event');

create table public.opportunities (
  id uuid primary key default gen_random_uuid(),
  kind public.opportunity_kind not null,
  hour_category public.hour_category not null,
  title text not null check (char_length(title) between 1 and 200),
  description text not null check (char_length(description) between 1 and 1000),
  provider text not null check (char_length(provider) between 1 and 120),
  modality text not null check (modality in ('online', 'presencial', 'hibrido')),
  hours int not null check (hours between 1 and 999),
  starts_at date,
  url text check (url is null or url ~ '^https://'),
  featured boolean not null default false,
  published boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.opportunities enable row level security;
revoke all on public.opportunities from anon, authenticated;
grant select on public.opportunities to authenticated;

create policy "opportunities: o aluno lê as publicadas"
  on public.opportunities for select to authenticated
  using (published);

-- Exemplos fictícios para o catálogo começar com conteúdo: quem oferece é
-- marcado "(exemplo)" e os links apontam para example.com (domínio
-- reservado). Nenhum imita um evento real de uma instituição.
insert into public.opportunities
  (kind, hour_category, title, description, provider, modality, hours,
   starts_at, url, featured)
values
  ('event', 'complementary', 'Semana Acadêmica de Computação',
   'Palestras, minicursos e uma feira de projetos ao longo de cinco dias.',
   'Centro Acadêmico (exemplo)', 'presencial', 20, '2026-11-09',
   'https://example.com/semana-academica', true),
  ('course', 'complementary', 'Introdução ao Python para Dados',
   'Curso online sobre análise de dados com Python, do zero aos gráficos.',
   'Escola Aberta de Dados (exemplo)', 'online', 40, '2026-10-20',
   'https://example.com/python-dados', false),
  ('event', 'extension', 'Projeto de Extensão Horta Comunitária',
   'Ajude a manter a horta do bairro: plantio, colheita e compostagem.',
   'Núcleo de Extensão (exemplo)', 'presencial', 30, '2026-10-25',
   null, false),
  ('course', 'extension', 'Oficina de Robótica nas Escolas',
   'Leve robótica básica para alunos do ensino fundamental da rede pública.',
   'Núcleo de Extensão (exemplo)', 'presencial', 16, '2026-11-03',
   'https://example.com/robotica', false),
  ('event', 'complementary', 'Maratona de Programação',
   'Resolva problemas de algoritmos em equipe, em uma prova de cinco horas.',
   'Clube de Programação (exemplo)', 'hibrido', 10, '2026-11-15',
   'https://example.com/maratona', false),
  ('course', 'extension', 'Mentoria de Tecnologia Comunitária',
   'Ensine programação básica a estudantes do ensino médio, uma vez por semana.',
   'Comunidade Tech (exemplo)', 'online', 24, '2026-10-30',
   'https://example.com/mentoria', false);
