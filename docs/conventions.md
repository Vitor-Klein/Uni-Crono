# Convenções — Uni-Crono

As convenções que o código segue **hoje**. Descreve estado, não intenção: se algo
aqui ficar defasado do código, virou ficção — corrija junto com a mudança que o
defasou.

## Código e nomeação

…

## Anti-padrões

Os erros que este projeto já cometeu e não quer repetir — um por linha, sempre com
a correção ao lado, para virar item de revisão em vez de prosa:

- ❌ … → ✅ …

Esta lista nasce vazia e cresce por acúmulo: um item entra quando o mesmo erro
aparece pela segunda vez, não na primeira. Se um item aqui for verificável por
lint ou teste, a regra pertence ao gate, não a esta lista.

## Testes

Localização e nomeação dos arquivos de teste: …

O nome de cada teste carrega o ID do critério de aceite (`CA-NN: …`). É isso que
faz `grep -r "CA-03"` responder "isto está implementado?" em um segundo.

Teste de tema lê o tema **que a tela vê**: monta `MyApp` com `debugHome` dentro de
`AppProviders` e lê `Theme.of(context)` — nunca o `ThemeData` do
`AppThemeFactory` isolado, que não tem o que o `builder` do `MaterialApp`
acrescenta. Preferências salvas entram por
`SharedPreferences.setMockInitialValues`. Contraste é calculado com
`Color.computeLuminance()`. O helper `pumpApp` de `test/app_theme_test.dart` já
faz isso.

Teste de navegação e de tela dentro da casca passa pelo app real — splash,
router e casca — com `pumpRoutedApp` de `test/app_harness.dart`: sem
`debugHome`, splash com `Duration.zero`, preferências salvas por `prefs` e
notificações por um `FakeNotificationsPreference` (que registra as gravações e
pode falhar sob comando). O app entra **com sessão** por padrão (um
`FakeAuthGateway` com `demoSession`); teste do login passa `signedIn: false`,
ou um `FakeAuthGateway` próprio em `auth`. O caminho atual sai de
`currentPath()`; os rótulos da barra inferior, de `navLabel()`.

Nada de Firebase nem de Supabase em teste de widget: o que depende deles entra
por uma interface com versão falsa — `FakeAuthGateway`, `FakeHoursRepository`
(com `demoCertificates()`), `FakeCertificatePicker`/`FakeCertificateLauncher`,
`FakeOpportunityRepository`, `FakeProfileRepository`, `FakeLinkOpener` — que
pode falhar sob comando. O `pdfrx` usa o PDFium nativo, que não roda em
`flutter test`: o `PdfTextExtractor` entra falso, entregando um texto, e a
leitura real é conferida à mão no aparelho. Os adaptadores do Supabase são testados com um
`SupabaseClient` sobre o `MockClient` do `http`; toda resposta simulada leva a
`request` de origem, que o SDK lê de volta.

Testes de banco: `supabase/tests/*.sql`, rodados contra o projeto numa
transação com `rollback`, trocando de papel com `set local role` e
`request.jwt.claims`.

Toque em widget que pode estar fora da tela padrão do teste (800×600) — ou de
uma tela reduzida no próprio teste — vem depois de `tester.ensureVisible`: um
toque que não acerta só gera aviso e deixa o teste passar sem testar nada. Numa
lista preguiçosa (`ListView`), o item longe da tela nem é construído e o
`ensureVisible` não o encontra. Nesse caso, role como o usuário faria, com
`tester.scrollUntilVisible(..., scrollable: <o Scrollable da página>)`. A saída
do `flutter test` não pode ter linhas `Warning:`.

Tela nova ganha teste de layout em tela estreita e texto grande (ex.: 320dp a
1,0× e 360dp a 1,5×, com `tester.view.physicalSize` e
`textScaleFactorTestValue`), afirmando `tester.takeException()` nulo — a
verificação manual em 390dp com texto normal não pega estouro de layout.
O `takeException()` também não pega palavra quebrada no meio, porque isso não
é estouro. Teste que mede largura de texto carrega a fonte real do estilo
(`FontLoader` com o TTF de `assets/fonts/`): com a fonte padrão dos testes, as
larguras não têm relação com as do app. Para afirmar que uma palavra ficou numa
linha só, todas as caixas de `RenderParagraph.getBoxesForSelection` sobre ela
têm o mesmo `top`.

## Commits

- **Conventional Commits.** Tipos: `feat`, `fix`, `refactor`, `test`, `docs`,
  `style`, `chore`, `build`.
- **Pequenos e coerentes.** Não misturar no mesmo commit: feature, refatoração,
  correção, formatação, dependências, documentação. Tarefa com etapas distintas
  rende mais de um commit.
- A mensagem explica **o resultado entregue**, não a lista de arquivos alterados.
- Documentação ou spec pode vir **antes** do código quando define a regra que a
  implementação vai seguir.
- O commit de código inclui os testes relacionados — nunca em commits separados.
- **Sem trailer de co-autoria.** Nenhum `Co-Authored-By` de ferramenta ou agente de
  IA em mensagem de commit — nunca, em nenhum commit. O autor é quem assina.

## Branches

…

## Artefatos que andam juntos

Pares em que mexer num obriga a atualizar os outros **no mesmo ciclo** — é a lista
que impede o repo de acumular arquivo gerado defasado:

- migração em `supabase/migrations/` → teste em `supabase/tests/` e a seção
  **Supabase** de `docs/architecture.md`
- `lib/l10n/app_pt.arb` → `app_en.arb` e `app_es.arb` (mesmas chaves) e os
  `app_localizations*.dart` gerados (`flutter gen-l10n`)
- regras de `certificate_reading.dart` → os casos de
  `test/certificate_reading_test.dart` e a seção **Leitura do certificado** de
  `docs/architecture.md`

Um par típico: schema → migration, cliente gerado, e o documento que descreve o
modelo de dados. O gerado nunca se edita à mão; regenera-se.
