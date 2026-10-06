-- Perfil de cada aluno e os certificados que somam as horas dele.

create type public.hour_category as enum ('complementary', 'extension');

create table public.profiles (
  id uuid primary key references auth.users on delete cascade,
  full_name text not null check (char_length(full_name) between 1 and 120),
  institution_id text not null
    check (institution_id in ('utfpr', 'ufpr', 'pucpr', 'uel')),
  course text not null check (char_length(course) between 1 and 120),
  term smallint not null check (term between 1 and 12),
  created_at timestamptz not null default now()
);

create table public.certificates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users on delete cascade,
  title text not null check (char_length(title) between 1 and 200),
  issuer text,
  category public.hour_category not null,
  hours int not null check (hours between 1 and 999),
  file_path text not null,
  file_sha256 text not null,
  source text not null check (source in ('extracted', 'manual')),
  approved_at timestamptz not null default now(),
  unique (user_id, file_sha256)
);

create index certificates_user_approved_idx
  on public.certificates (user_id, approved_at desc);

-- Só leitura, só das próprias linhas. Quem escreve certificado é o leitor,
-- com a service_role; o perfil nasce do cadastro e não tem edição.
alter table public.profiles enable row level security;
alter table public.certificates enable row level security;

revoke all on public.profiles from anon, authenticated;
revoke all on public.certificates from anon, authenticated;
grant select on public.profiles to authenticated;
grant select on public.certificates to authenticated;

create policy "profiles: o aluno lê o próprio"
  on public.profiles for select to authenticated
  using (id = (select auth.uid()));

create policy "certificates: o aluno lê os próprios"
  on public.certificates for select to authenticated
  using (user_id = (select auth.uid()));

-- O perfil nasce dos metadados do cadastro. Dado inválido faz o cadastro
-- falhar pelos checks da tabela: a validação vale no servidor.
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, institution_id, course, term)
  values (
    new.id,
    trim(new.raw_user_meta_data ->> 'full_name'),
    new.raw_user_meta_data ->> 'institution_id',
    trim(new.raw_user_meta_data ->> 'course'),
    (new.raw_user_meta_data ->> 'term')::smallint
  );
  return new;
end;
$$;

revoke execute on function public.handle_new_user() from public, anon, authenticated;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
