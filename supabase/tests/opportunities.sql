-- Testes do catálogo de oportunidades. Rodam numa transação desfeita no fim.
begin;

-- Uma oportunidade ainda não publicada, gravada como o painel grava.
insert into public.opportunities
  (kind, hour_category, title, description, provider, modality, hours, published)
values ('event', 'extension', 'Rascunho', 'Ainda não publicado', 'Teste',
        'online', 5, false);

set local role authenticated;
set local request.jwt.claims =
  '{"sub":"00000000-0000-4000-8000-00000000000a","role":"authenticated"}';

-- CA-10: o aluno lê só as publicadas (as 6 do seed).
do $$
begin
  if (select count(*) from public.opportunities) <> 6 then
    raise exception 'CA-10: o aluno não vê exatamente as 6 publicadas';
  end if;
  if exists (select 1 from public.opportunities where title = 'Rascunho') then
    raise exception 'CA-10: o aluno vê uma oportunidade não publicada';
  end if;
  if (select count(*) from public.opportunities where featured) <> 1 then
    raise exception 'CA-10: o seed não tem exatamente um destaque';
  end if;
end $$;

-- CA-10: o aluno não escreve no catálogo.
do $$
begin
  begin
    insert into public.opportunities
      (kind, hour_category, title, description, provider, modality, hours)
    values ('event', 'extension', 'Forjada', 'x', 'x', 'online', 999);
    raise exception 'CA-10: o aluno inseriu uma oportunidade';
  exception when insufficient_privilege then null;
  end;
  begin
    update public.opportunities set hours = 999;
    raise exception 'CA-10: o aluno alterou uma oportunidade';
  exception when insufficient_privilege then null;
  end;
end $$;

reset role;
set local role anon;
set local request.jwt.claims = '{"role":"anon"}';

-- CA-10: o anônimo não lê o catálogo.
do $$
declare
  seen int;
begin
  begin
    select count(*) into seen from public.opportunities;
    if seen <> 0 then
      raise exception 'CA-10: o anônimo lê oportunidades';
    end if;
  exception when insufficient_privilege then null;
  end;
end $$;

reset role;
select 'opportunities ok' as result;
rollback;
