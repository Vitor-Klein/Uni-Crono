-- O certificado é lido no próprio app: o aluno grava os próprios
-- certificados. Continua sem alterar nem apagar, e os checks da tabela (horas
-- de 1 a 999, source extracted/manual, um PDF por aluno) seguem valendo.

grant insert on public.certificates to authenticated;

create policy "certificates: o aluno grava os próprios"
  on public.certificates for insert to authenticated
  with check (user_id = (select auth.uid()));
