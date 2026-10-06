---
id: 009
status: aprovada
depende_de: [008, 012]
---

# Lançar certificado em PDF com leitura automática das horas

> `status`: `rascunho` → `aprovada` → `implementada` (ou `descartada`). Uma spec
> só vira `aprovada` quando **Perguntas em aberto** estiver vazia. Ao fechar,
> `/destilar NNN` leva para `docs/architecture.md` e `docs/conventions.md` só o
> que ela virou estado; a spec fica aqui como histórico.

## Objetivo

Fecha o fluxo principal do produto: o aluno escolhe o PDF do certificado, um
leitor em Python extrai o texto, descobre quantas horas são e se contam como
extensão ou complementares, e as horas **entram direto** na conta do aluno, sem
tela de confirmação. A tela de envio é a "Lançar Certificado" do Figma.

Esta versão substitui a de leitura simulada com confirmação, aprovada antes e
nunca implementada. O que mudou por decisão do usuário: a leitura é de verdade,
num servidor Python no Vercel, e as horas entram sem conferência. O
histórico está no git.

## Requisitos funcionais

- **RF-01:** A aba Upload deixa escolher um PDF de até 10 MB. Qualquer outra
  coisa mostra "Use um PDF de até 10 MB" e não é aceita.
- **RF-02:** "Enviar certificado" só fica ativo com um arquivo escolhido. Ao
  tocar, mostra "Lendo certificado…": o app sobe o PDF para o Storage, na pasta
  do aluno, e chama o leitor com o caminho.
- **RF-03:** O leitor confere o token do aluno, baixa o PDF, extrai o texto,
  acha as horas, a categoria e o título, e grava o certificado. O app limpa a
  aba Upload, vai ao Dashboard e mostra "Certificado lançado: +N h em
  <categoria>". O Dashboard já mostra as horas novas.
- **RF-04:** Se o PDF não tem texto (digitalizado) ou o leitor não acha a carga
  horária, nada entra ainda e o app abre o formulário "Informe os dados do
  certificado" (`/upload/manual`), com o título já preenchido pela regra do
  nome do arquivo, horas (1 a 999) e categoria. "Lançar" manda os dados ao
  leitor, que lê o PDF de novo: só grava se a leitura continuar falhando, e
  grava com `source = 'manual'`. "Cancelar" apaga o PDF do Storage e volta ao
  envio, com o arquivo ainda escolhido.
- **RF-05:** O mesmo PDF (mesmo SHA-256) enviado de novo pelo mesmo aluno
  mostra "Este certificado já foi lançado" e não soma nada.
- **RF-06:** "Cancelar" limpa o arquivo escolhido. Durante a leitura, os botões
  ficam inativos.
- **RF-07:** O leitor recusa: sem token válido (401); caminho fora da pasta do
  aluno (403); arquivo que não é PDF, pelos bytes `%PDF-` e não pela extensão
  (415); mais de 10 MB (413).

### Regras do leitor (Python)

- **Horas:** procura, sem diferenciar maiúsculas e acentos, nesta ordem:
  1. número logo depois de "carga horária" (até 40 caracteres entre os dois);
  2. a primeira ocorrência de `N h`, `Nh`, `NhMM`, `N horas`, `N hrs`, `N
     (por extenso) horas`.

  Vale de 1 a 999 h; fora disso, "não achou". Minutos são descartados (`10h30`
  dá 10). Ignora o que parece hora do relógio: `às 14h`, `das 8h às 12h`.
- **Categoria:** extensão se o texto contém "extensão" ou "extensionista";
  senão, complementares.
- **Título:** o trecho depois de "participou d(o|a)", "concluiu o curso" ou
  "evento", entre aspas, ou até a próxima vírgula ou ponto, com no máximo 120
  caracteres. Se nada disso aparece, vale o nome do arquivo sem extensão, com
  `-`/`_` trocados por espaço e cada palavra com inicial maiúscula.
- **Emissor:** a sigla da instituição do aluno, se aparece no texto; senão,
  vazio.

## Critérios de aceite

App:

- **CA-01:** Escolher `certificado-game-jam.pdf` de 180 KB mostra o nome e o
  tamanho na área de envio e ativa "Enviar certificado".
- **CA-02:** Escolher um `.docx`, um `.png` ou um PDF de 11 MB mostra "Use um
  PDF de até 10 MB" e "Enviar certificado" continua inativo.
- **CA-03:** Com o leitor respondendo 10 h complementares, "Enviar certificado"
  mostra "Lendo certificado…", depois a rota é `/dashboard`, aparece
  "Certificado lançado: +10 h em Horas Complementares" e a aba Upload volta
  vazia.
- **CA-04:** Com o leitor respondendo "sem horas", a rota vira
  `/upload/manual`, com "Não encontramos as horas neste certificado. Informe os
  dados." e o título "Certificado Game Jam" preenchido. Nada entra no
  Dashboard ainda.
- **CA-04a:** No formulário, horas vazias, 0 ou 1000 mostram "Informe as horas
  (1 a 999)" e não lançam.
- **CA-04b:** Com 12 h e Horas de Extensão, "Lançar" leva a `/dashboard` com
  "Certificado lançado: +12 h em Horas de Extensão".
- **CA-04c:** "Cancelar" no formulário apaga o PDF enviado e volta a `/upload`
  com o arquivo ainda escolhido.
- **CA-05:** Com o leitor respondendo "duplicado", aparece "Este certificado já
  foi lançado".
- **CA-06:** Sem rede, ou com o leitor fora do ar, aparece "Não foi possível
  ler o certificado. Tente de novo." e o arquivo continua escolhido.
- **CA-07:** "Cancelar" em `/upload` limpa o arquivo.

Leitor (pytest, funções puras):

- **CA-08:** "carga horária de 20 horas" → 20; "Carga Horaria: 10h00" → 10;
  "com duração de 8h" → 8; "40 (quarenta) horas" → 40.
- **CA-09:** "das 8h às 12h, com carga horária total de 4 horas" → 4.
  "realizado em 12/03/2026" → não achou. "1200 horas" → não achou.
- **CA-10:** "participou do projeto de Extensão Horta Comunitária" → extensão;
  "ação extensionista" → extensão; "participou da Semana Acadêmica" →
  complementares.
- **CA-11:** `participou do evento "Semana Acadêmica de Computação", com…` →
  título "Semana Acadêmica de Computação". Texto sem marcador, em
  `certificado-game-jam.pdf` → "Certificado Game Jam".

Leitor (pytest, HTTP, com Supabase falso):

- **CA-12:** Sem `Authorization`, ou com token inválido → 401. Caminho
  `outro-uid/x.pdf` → 403. Bytes que não começam com `%PDF-` → 415.
- **CA-13:** Um PDF de exemplo com texto (gerado no teste) → 201 com `{title,
  issuer, category, hours}`, e o certificado gravado com o SHA-256 do arquivo
  e `source = 'extracted'`. O mesmo PDF de novo → 409. PDF sem texto → 422
  `no_text`, e o arquivo continua no Storage.
- **CA-14:** `/manual` com um PDF sem texto e 12 h de extensão → 201, gravado
  com `source = 'manual'`. `/manual` com um PDF em que o leitor acha as horas
  → 409 `readable`, e nada é gravado. Horas 0 ou 1000, ou título vazio → 422
  `invalid`.

## Fora de escopo

- JPG, PNG e PDF digitalizado (precisariam de OCR).
- Conferir ou editar os dados que o leitor achou antes de lançar; apagar ou
  editar um certificado já lançado.
- Arrastar e soltar (o "Drag & drop" do Figma): só "Procurar arquivos".
- Detectar certificado falso.

## Regras de negócio e invariantes

- Só o leitor, com a `service_role`, grava em `certificates`. Num PDF que o
  leitor consegue ler, as horas que entram são sempre as que **ele** extraiu.
  Um número mandado pelo app só entra (`source = 'manual'`) quando o leitor,
  ao ler de novo o mesmo PDF, continua sem achar texto ou horas.
- Um PDF só vira certificado uma vez por aluno (`unique (user_id,
  file_sha256)`).
- O PDF fica em `certificates/{auth.uid()}/{uuid}.pdf`, num bucket privado, e
  só o dono lê.
- A resposta de erro do leitor nunca traz texto do PDF, caminho interno nem
  stack trace.

## Contratos

```text
POST {CERTIFICATE_READER_URL}/api/certificates/read
Authorization: Bearer <access_token do Supabase>
Content-Type: application/json
{ "path": "<uid>/<uuid>.pdf", "file_name": "certificado-game-jam.pdf" }

201 { "title": "Certificado Game Jam", "issuer": "UTFPR",
      "category": "complementary", "hours": 10 }
401 | 403 | 413 | 415 { "error": "unauthorized" | "forbidden" | "too_large" | "not_pdf" }
409 { "error": "duplicate" }
422 { "error": "no_text" | "no_hours" }

POST {CERTIFICATE_READER_URL}/api/certificates/manual
Authorization: Bearer <access_token do Supabase>
{ "path": "<uid>/<uuid>.pdf", "title": "...", "category": "extension", "hours": 12 }

201 { "title": "...", "issuer": null, "category": "extension", "hours": 12 }
409 { "error": "duplicate" | "readable" }
422 { "error": "invalid" }
```

```dart
class PickedFile { final String name; final int sizeBytes; final Uint8List bytes; }
abstract class CertificatePicker { Future<PickedFile?> pick(); }   // file_picker, só pdf

class LaunchedCertificate { final String title; final HourCategory category; final int hours; }
abstract class CertificateLauncher {          // SupabaseCertificateLauncher em produção
  Future<LaunchedCertificate> launch(PickedFile file);
  Future<LaunchedCertificate> launchManual(UnreadableCertificate pending,
      {required String title, required HourCategory category, required int hours});
  Future<void> discard(UnreadableCertificate pending);   // apaga o PDF enviado
}
// Erros tipados: Unreadable(UnreadableCertificate pending), Duplicate,
// ReaderUnavailable. UnreadableCertificate guarda o caminho no Storage e o
// nome do arquivo.
```

- `UploadCubit` (arquivo, erro, enviando) e `ManualEntryCubit` (campos,
  validação, lançando), em `lib/features/upload/`. Rota `/upload/manual` dentro
  da aba Upload, com a barra inferior visível.
- Storage: bucket `certificates` privado, `file_size_limit` de 10 MB,
  `allowed_mime_types = {application/pdf}`. Política: o aluno faz `insert`,
  `select` e `delete` só onde `(storage.foldername(name))[1] = auth.uid()::text`.
- Leitor: `services/certificate_reader/` com FastAPI e `pypdf` (versões lidas
  do PyPI na hora de instalar), `reader/` (funções puras), `api/index.py`
  (rota), `tests/`, `requirements.txt` e `vercel.json`. Variáveis no Vercel:
  `SUPABASE_URL` e `SUPABASE_SERVICE_ROLE_KEY`. O CORS aceita só as origens
  do app web.
- Leiaute (Figma "Lançar Certificado"): título "Lançar certificado"
  (`headlineLarge`); subtítulo `bodyLarge`/`onSurfaceVariant`; área tracejada
  (`outlineVariant`, raio `AppRadii.lg`) com ícone, "Escolha o arquivo"
  (`titleLarge`), "PDF (até 10 MB)", "ou" e "Procurar arquivos"
  (`OutlinedButton`); rodapé "Cancelar" (`TextButton`) e "Enviar certificado"
  (`FilledButton`).
- Dependência nova no app: `file_picker`, versão lida do pub.dev.

## Dependências e impacto

- Novo `lib/features/upload/`; `pubspec.yaml`; ARBs; `HoursRepository` (012); a
  aba Upload da casca.
- Novo `services/certificate_reader/`; migração do bucket em
  `supabase/migrations/`; projeto no Vercel.
- `CLAUDE.md` `<quality_gates>`: entram `pytest` e `ruff check` do leitor
  (aprovado pelo usuário).
- **SECURITY.md** — ler antes: arquivo do usuário, segredo no servidor, auth
  num canal fora do app.

## Estratégia de teste específica

- No app, `CertificatePicker` e `CertificateLauncher` são falsos: nada de
  `file_picker` nem de rede em `flutter test`.
- No leitor, os PDFs de teste são gerados no próprio teste, e o Supabase
  (auth, storage, insert) entra por uma interface com versão falsa. Nenhum
  certificado real vai para o repositório.

## Decisões durante a implementação

- …

## Perguntas em aberto

