-- PDFs dos certificados: bucket privado, cada aluno só na própria pasta
-- (<uid>/<uuid>.pdf). O leitor lê e apaga com a service_role.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('certificates', 'certificates', false, 10485760, array['application/pdf']);

create policy "certificates: o aluno envia para a própria pasta"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'certificates'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "certificates: o aluno lê a própria pasta"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'certificates'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "certificates: o aluno apaga da própria pasta"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'certificates'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
