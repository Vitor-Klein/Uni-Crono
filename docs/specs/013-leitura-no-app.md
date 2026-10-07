---
id: 013
status: implementada
depende_de: [009, 012]
---

# Ler o certificado no próprio app, sem servidor Python

> `status`: `rascunho` → `aprovada` → `implementada` (ou `descartada`). Uma spec
> só vira `aprovada` quando **Perguntas em aberto** estiver vazia. Ao fechar,
> `/destilar NNN` leva para `docs/architecture.md` e `docs/conventions.md` só o
> que ela virou estado; a spec fica aqui como histórico.

## Objetivo

O leitor em Python (009) precisa de um servidor no ar (Vercel), e o usuário
decidiu não ter servidor: a leitura do PDF passa a ser feita no próprio app,
em Dart, com as mesmas regras. O app passa a gravar os certificados do próprio
aluno. Decisão do usuário, com a brecha conhecida: quem chamar a API direto
pode lançar horas que não leu de PDF nenhum.

## Requisitos funcionais

- **RF-01:** O app extrai o texto do PDF escolhido (até 10 páginas) e aplica
  as regras de horas, categoria, título e emissor da 009, sem mudança.
- **RF-02:** Lido com horas: o app sobe o PDF para
  `certificates/<uid>/<uuid>.pdf` e grava o certificado com
  `source = 'extracted'`. Sem texto ou sem horas: nada sobe e abre o
  formulário manual; "Lançar" sobe o PDF e grava com `source = 'manual'`.
- **RF-03:** O mesmo PDF (SHA-256) já lançado pelo aluno: "Este certificado já
  foi lançado", sem subir nada.
- **RF-04:** Sem rede, ou o servidor recusando: "Não foi possível ler o
  certificado. Tente de novo." e nada fica pela metade (se o PDF subiu e a
  gravação falhou, o PDF é apagado).
- **RF-05:** O serviço `services/certificate_reader/` e os gates de Python
  saem do repositório.

## Critérios de aceite

- **CA-01 (banco):** o aluno insere certificado próprio (`user_id =
  auth.uid()`), e o banco ainda recusa horas fora de 1 a 999 e `source` fora
  de `extracted`/`manual`. O aluno não insere certificado de outro aluno nem
  altera ou apaga nenhum.
- **CA-02:** as regras de leitura em Dart dão os mesmos resultados dos casos de
  teste da 009 (CA-08 a CA-11): "carga horária de 20 horas" → 20, "das 8h às
  12h, com carga horária total de 4 horas" → 4, "1200 horas" → nada,
  "extensionista" → extensão, título entre aspas depois de "evento", título do
  nome do arquivo.
- **CA-03:** um PDF lido com 260 h de extensão sobe para a pasta do aluno e
  grava `{hours: 260, category: extension, source: extracted, file_sha256}`.
- **CA-04:** um PDF sem texto, ou sem horas, não sobe nada e vira `Unreadable`;
  lançado à mão com 12 h, sobe e grava `source = 'manual'`.
- **CA-05:** um PDF cujo SHA-256 o aluno já tem é `Duplicate`, sem upload.
- **CA-06:** upload ou gravação falhando é `ReaderUnavailable`; se o PDF já
  tinha subido, é apagado.

## Fora de escopo

- OCR (PDF digitalizado continua indo para o formulário manual).
- Impedir horas forjadas pela API (aceito pelo usuário).

## Regras de negócio e invariantes

- O aluno só grava, lê e apaga na própria pasta e só grava certificados com o
  próprio `user_id`; ninguém altera nem apaga certificado.
- Um PDF só vira certificado uma vez por aluno (`unique (user_id,
  file_sha256)`).

## Contratos

```dart
abstract class PdfTextExtractor { Future<String> extract(Uint8List bytes); }
// PdfrxTextExtractor (pdfrx 2.4.8, MIT): "" quando não há texto ou não abre.

class CertificateReading { int? hours; HourCategory category; String title; String? issuer; }
CertificateReading readCertificate(String text, {required String fileName, required String institution});

class UnreadableCertificate { PickedFile file; }   // antes: o caminho no Storage
```

```sql
create policy "certificates: o aluno grava os próprios"
  on public.certificates for insert to authenticated
  with check (user_id = (select auth.uid()));
grant insert on public.certificates to authenticated;
```

## Dependências e impacto

- `lib/features/upload/` (launcher, regras novas), `pubspec.yaml` (+ `pdfrx`).
- Migração nova em `supabase/migrations/`; `supabase/tests/rls.sql`.
- Remove `services/certificate_reader/`; `CLAUDE.md` (gates e decisão
  travada); `docs/architecture.md`.

## Estratégia de teste específica

- O `pdfrx` usa o PDFium nativo, que não roda em `flutter test`: o extrator
  entra por interface e os testes usam um falso. A leitura real é verificada à
  mão, no aparelho, com uma declaração de verdade.

## Decisões durante a implementação

- **`pdfrx` 2.4.7**, não 2.4.8: o `pdfrx_engine` das versões novas pede
  `meta ^1.18`, e o Flutter 3.41.5 trava o `meta` em 1.17.0.
- **Duplicado conferido antes do upload** (consulta pelo SHA-256), e de novo
  pela violação do único na gravação, com o PDF apagado.
- **`discard` saiu do `CertificateLauncher`:** nada sobe antes do lançamento,
  então desistir do formulário não tem o que apagar.
- **O título pendente vem da leitura** (que cai no nome do arquivo quando o
  texto não traz título).
- **Emissor é o nome da instituição da conta** (metadados), e nada quando ela
  falta: um padrão de palavra vazio casaria com qualquer texto.
- **`foldForSearch` virou `foldText` em `lib/core/utils/`:** o Hub e a leitura
  usam a mesma função, sem uma feature importar a outra.
- **`rls.sql` conta só os perfis do próprio teste:** o banco já tem conta de
  verdade.
- **Verificação no aparelho:** o APK com `pdfrx` compilou e subiu no Android
  (Supabase iniciado, sem exceção); o envio de uma declaração real fica para o
  usuário conferir.

## Perguntas em aberto
