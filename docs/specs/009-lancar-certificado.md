---
id: 009
status: aprovada
depende_de: [008]
---

# Lançar certificado com extração simulada e confirmação

> `status`: `rascunho` → `aprovada` → `implementada` (ou `descartada`). Uma spec
> só vira `aprovada` quando **Perguntas em aberto** estiver vazia. Ao fechar,
> `/destilar NNN` leva para `docs/architecture.md` e `docs/conventions.md` só o
> que ela virou estado; a spec fica aqui como histórico.

## Objetivo

Fecha o fluxo principal do produto: o aluno escolhe o certificado, o sistema
"lê" e preenche os dados, o aluno confere e as horas entram no Dashboard. A
tela de envio é a "Lançar Certificado" do Figma; a de confirmação é nova (opção
B do brainstorming: resumo com destaque e edição por campo). A leitura é
**simulada**: nada do arquivo é interpretado.

## Requisitos funcionais

- **RF-01:** A aba Upload deixa escolher um arquivo PDF, JPG ou PNG de até
  10 MB; fora disso, mostra o erro e não aceita.
- **RF-02:** "Enviar certificado" só fica ativo com um arquivo escolhido; ao
  tocar, mostra "Lendo certificado…" e depois abre a confirmação.
- **RF-03:** A confirmação mostra em destaque "+N h serão somadas a
  <categoria>" e os dados extraídos (atividade, emissor, carga horária,
  categoria), cada um com "Editar".
- **RF-04:** Editar um dado atualiza o destaque na hora (ex.: trocar a
  categoria ou as horas).
- **RF-05:** "Confirmar e lançar" grava o certificado como aprovado no
  repositório de horas, limpa a aba Upload e leva ao Dashboard com o aviso
  "Certificado lançado: +N h".
- **RF-06:** "Cancelar" na confirmação volta à tela de envio com o arquivo ainda
  escolhido; "Cancelar" na tela de envio limpa o arquivo.

## Critérios de aceite

- **CA-01:** Escolher `certificado-game-jam.pdf` de 180 KB mostra o nome e o
  tamanho na área de envio e ativa "Enviar certificado".
- **CA-02:** Escolher um `.docx`, ou um PDF de 11 MB, mostra "Use um PDF, JPG ou
  PNG de até 10 MB" e "Enviar certificado" continua inativo.
- **CA-03:** "Enviar certificado" mostra "Lendo certificado…" e, terminada a
  leitura, a rota é `/upload/review`, com a barra inferior visível.
- **CA-04:** A extração de `certificado-game-jam.pdf`, para um aluno da UTFPR,
  resulta em atividade "Certificado Game Jam", emissor "UTFPR", 10 h, Horas
  Complementares — e a confirmação mostra "+10 h serão somadas a Horas
  Complementares".
- **CA-05:** Editar a carga horária para 12 e a categoria para Horas de Extensão
  muda o destaque para "+12 h serão somadas a Horas de Extensão".
- **CA-06:** Carga horária editada precisa ser um inteiro de 1 a 999; fora
  disso, o campo mostra "Informe as horas (1 a 999)" e não salva.
- **CA-07:** "Confirmar e lançar" adiciona o certificado ao repositório, leva a
  `/dashboard`, mostra "Certificado lançado: +10 h", e a aba Upload volta vazia.
- **CA-08:** "Cancelar" na confirmação volta a `/upload` com o arquivo ainda
  escolhido; "Cancelar" em `/upload` limpa o arquivo.

## Fora de escopo

- Ler o conteúdo do arquivo de verdade (OCR/PDF) e enviar para servidor.
- Certificados pendentes ou reprovados.

## Regras de negócio e invariantes

- A extração simulada é determinística: o mesmo nome de arquivo e a mesma
  instituição geram sempre o mesmo resultado.
- Atividade extraída = nome do arquivo sem extensão, com `-`/`_` trocados por
  espaço e cada palavra com inicial maiúscula (`certificado-game-jam.pdf` →
  "Certificado Game Jam").
- Nenhum certificado entra no repositório sem passar pela confirmação.

## Contratos

```dart
class PickedFile { final String name; final int sizeBytes; }

abstract class CertificatePicker { Future<PickedFile?> pick(); }
// FilePickerCertificatePicker: file_picker 13.1.0 (MIT), extensões pdf/jpg/jpeg/png.

class ExtractedCertificate {
  final String activity; final String issuer; final int hours; final HourCategory category;
}

abstract class CertificateReader {
  Future<ExtractedCertificate> read(PickedFile file, {required String institutionName});
}
// SimulatedCertificateReader: espera 1,5 s (injetável) e aplica as regras acima;
// sempre 10 h e Horas Complementares.
```

- `UploadCubit` (arquivo escolhido, erro, leitura em andamento) e
  `ReviewCubit` (dados editáveis, confirmar), em `lib/features/upload/`.
- Leiaute do envio (Figma "Lançar Certificado"): título "Lançar certificado"
  (`headlineLarge`), subtítulo `bodyLarge`/`onSurfaceVariant`; área tracejada
  (`outlineVariant`, raio `AppRadii.lg`) com ícone, "Escolha o arquivo"
  (`titleLarge`), "PDF, JPG ou PNG (até 10 MB)", "ou", "Procurar arquivos"
  (`OutlinedButton`); rodapé "Cancelar" (`TextButton`) e "Enviar certificado"
  (`FilledButton`).
- Leiaute da confirmação (opção B): título "Confirmar dados", "Encontramos estes
  dados no seu certificado."; card de destaque com "+10 h" (`displayMedium`,
  `primary`) e "serão somadas a Horas Complementares"; card com as linhas
  atividade/emissor/carga horária/categoria (`bodyMedium` `onSurfaceVariant` +
  valor `labelLarge`) e "Editar" (`TextButton`); "Confirmar e lançar"
  (`FilledButton`) e "Cancelar". Editar abre um diálogo com o campo (categoria:
  escolha entre as duas).
- Dependência nova: `file_picker: ^13.1.0`.

## Dependências e impacto

- Novo `lib/features/upload/`; `pubspec.yaml` (+ `file_picker`); ARBs;
  `HoursRepository` (008); a aba Upload da casca e a rota `/upload/review`.
- **SECURITY.md** — ler antes: a spec recebe arquivo do usuário.

## Estratégia de teste específica

`CertificatePicker` e o atraso do `CertificateReader` são injetados: os testes
usam um picker falso (nome/tamanho controlados) e atraso zero — o `file_picker`
real não roda em teste de widget.

## Decisões durante a implementação

- …

## Perguntas em aberto
