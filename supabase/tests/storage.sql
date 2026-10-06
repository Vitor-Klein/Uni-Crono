-- Testes do bucket de certificados. Rodam numa transação desfeita no fim.
begin;

do $$
begin
  if not exists (
    select 1 from storage.buckets
    where id = 'certificates' and not public
      and file_size_limit = 10485760
      and allowed_mime_types = array['application/pdf']
  ) then
    raise exception 'CA-12: o bucket certificates não é privado, de PDF até 10 MB';
  end if;
end $$;

-- Um arquivo do aluno B, gravado como o leitor grava.
insert into storage.objects (bucket_id, name)
values ('certificates',
        '00000000-0000-4000-8000-00000000000b/b.pdf');

set local role authenticated;
set local request.jwt.claims =
  '{"sub":"00000000-0000-4000-8000-00000000000a","role":"authenticated"}';

-- CA-12: o aluno A envia para a própria pasta.
insert into storage.objects (bucket_id, name)
values ('certificates', '00000000-0000-4000-8000-00000000000a/a.pdf');

-- CA-12: o aluno A não envia para a pasta de B.
do $$
begin
  begin
    insert into storage.objects (bucket_id, name)
    values ('certificates', '00000000-0000-4000-8000-00000000000b/x.pdf');
    raise exception 'CA-12: o aluno A enviou para a pasta de B';
  exception when insufficient_privilege then null;
  end;
end $$;

-- CA-12: o aluno A vê só os próprios arquivos e não apaga os de B.
do $$
begin
  if (select count(*) from storage.objects where bucket_id = 'certificates') <> 1
  then
    raise exception 'CA-12: o aluno A vê arquivos de outra pasta';
  end if;
  delete from storage.objects
  where name = '00000000-0000-4000-8000-00000000000b/b.pdf';
end $$;

reset role;
do $$
begin
  if not exists (select 1 from storage.objects
                 where name = '00000000-0000-4000-8000-00000000000b/b.pdf') then
    raise exception 'CA-12: o aluno A apagou um arquivo de B';
  end if;
end $$;

-- CA-04c: o aluno A apaga o próprio arquivo (o app apaga ao cancelar).
set local role authenticated;
set local request.jwt.claims =
  '{"sub":"00000000-0000-4000-8000-00000000000a","role":"authenticated"}';
delete from storage.objects
where name = '00000000-0000-4000-8000-00000000000a/a.pdf';
reset role;
do $$
begin
  if exists (select 1 from storage.objects
             where name = '00000000-0000-4000-8000-00000000000a/a.pdf') then
    raise exception 'CA-04c: o aluno A não apagou o próprio arquivo';
  end if;
end $$;

select 'storage ok' as result;
rollback;
