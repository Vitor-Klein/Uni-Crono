-- Testes das políticas de acesso. Rodam numa transação desfeita no fim: nada
-- fica no banco. Cada asserção que falha levanta exceção com o nome do caso.
begin;

-- Dois alunos, criados como o Auth cria: o perfil nasce pelo gatilho.
insert into auth.users (id, aud, role, email, raw_user_meta_data)
values
  ('00000000-0000-4000-8000-00000000000a', 'authenticated', 'authenticated',
   'a@teste.dev',
   '{"full_name":"Aluno A","institution_id":"utfpr","course":"Eng. de Software","term":5}'),
  ('00000000-0000-4000-8000-00000000000b', 'authenticated', 'authenticated',
   'b@teste.dev',
   '{"full_name":"Aluno B","institution_id":"ufpr","course":"Computação","term":2}');

-- Certificados gravados como o leitor grava (papel com privilégio total).
insert into public.certificates
  (user_id, title, category, hours, file_path, file_sha256, source)
values
  ('00000000-0000-4000-8000-00000000000a', 'Cert A', 'complementary', 10,
   '00000000-0000-4000-8000-00000000000a/a.pdf', 'sha-a', 'extracted'),
  ('00000000-0000-4000-8000-00000000000b', 'Cert B', 'extension', 15,
   '00000000-0000-4000-8000-00000000000b/b.pdf', 'sha-b', 'extracted');

-- CA-12: o gatilho cria o perfil a partir dos metadados do cadastro.
do $$
begin
  if (select count(*) from public.profiles) <> 2 then
    raise exception 'CA-12: o cadastro não criou os perfis';
  end if;
  if (select term from public.profiles
      where id = '00000000-0000-4000-8000-00000000000a') <> 5 then
    raise exception 'CA-12: o perfil não guardou o período do cadastro';
  end if;
end $$;

-- CA-12: metadados inválidos no cadastro são recusados no servidor.
do $$
begin
  begin
    insert into auth.users (id, aud, role, email, raw_user_meta_data)
    values ('00000000-0000-4000-8000-00000000000c', 'authenticated',
            'authenticated', 'c@teste.dev',
            '{"full_name":"C","institution_id":"xpto","course":"X","term":5}');
    raise exception 'CA-12: aceitou instituição fora da lista';
  exception when check_violation then null;
  end;
  begin
    insert into auth.users (id, aud, role, email, raw_user_meta_data)
    values ('00000000-0000-4000-8000-00000000000d', 'authenticated',
            'authenticated', 'd@teste.dev',
            '{"full_name":"D","institution_id":"utfpr","course":"X","term":13}');
    raise exception 'CA-12: aceitou período 13';
  exception when check_violation then null;
  end;
end $$;

-- Daqui em diante, como o aluno A.
set local role authenticated;
set local request.jwt.claims =
  '{"sub":"00000000-0000-4000-8000-00000000000a","role":"authenticated"}';

do $$
begin
  if (select count(*) from public.profiles) <> 1
     or (select full_name from public.profiles) <> 'Aluno A' then
    raise exception 'CA-12: o aluno A não vê só o próprio perfil';
  end if;
  if (select count(*) from public.certificates) <> 1
     or (select title from public.certificates) <> 'Cert A' then
    raise exception 'CA-12: o aluno A não vê só os próprios certificados';
  end if;
end $$;

-- CA-12: o aluno não cria certificado direto pela API, nem para si.
do $$
begin
  begin
    insert into public.certificates
      (user_id, title, category, hours, file_path, file_sha256, source)
    values ('00000000-0000-4000-8000-00000000000a', 'Forjado', 'extension',
            999, 'x.pdf', 'sha-x', 'manual');
    raise exception 'CA-12: o aluno inseriu um certificado';
  exception when insufficient_privilege then null;
  end;
end $$;

-- CA-12: o aluno não altera nem apaga certificado, nem o próprio.
do $$
begin
  begin
    update public.certificates set hours = 999;
    raise exception 'CA-12: o aluno alterou um certificado';
  exception when insufficient_privilege then null;
  end;
  begin
    delete from public.certificates;
    raise exception 'CA-12: o aluno apagou um certificado';
  exception when insufficient_privilege then null;
  end;
end $$;

-- CA-12: o aluno não altera o perfil de outro (nem o próprio: não há edição).
do $$
begin
  begin
    update public.profiles set full_name = 'Invadido';
    raise exception 'CA-12: o aluno alterou um perfil';
  exception when insufficient_privilege then null;
  end;
end $$;

-- Como anônimo.
reset role;
set local role anon;
set local request.jwt.claims = '{"role":"anon"}';

do $$
declare
  seen int;
begin
  begin
    select count(*) into seen from public.profiles;
    if seen <> 0 then
      raise exception 'CA-12: o anônimo lê perfis';
    end if;
  exception when insufficient_privilege then null;
  end;
  begin
    select count(*) into seen from public.certificates;
    if seen <> 0 then
      raise exception 'CA-12: o anônimo lê certificados';
    end if;
  exception when insufficient_privilege then null;
  end;
end $$;

reset role;
select 'rls ok' as result;

rollback;
