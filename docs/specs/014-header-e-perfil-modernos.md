---
id: 014
status: implementada
depende_de: [006, 010]
---

# Modernizar o header, o Perfil, o Dashboard e o menu "Mais"

> `status`: `rascunho` → `aprovada` → `implementada` (ou `descartada`). Uma spec
> só vira `aprovada` quando **Perguntas em aberto** estiver vazia. Ao fechar,
> `/destilar NNN` leva para `docs/architecture.md` e `docs/conventions.md` só o
> que ela virou estado; a spec fica aqui como histórico.

## Objetivo

O header da casca ("Uni Cronos" centralizado em negrito + círculo amarelo), o
Perfil (carteirinha amarela chapada, números soltos, `ListTile`s crus), o
Dashboard e o menu "Mais" pareciam brutos. Esta spec troca o visual dos quatro
por um mais limpo e moderno, sem mudar o que eles fazem. O amarelo deixa de ser
fundo de cartão e vira acento.

O visual se afasta da Page 1 do Figma **de propósito**: quem cuida do produto
atualiza o Figma depois para refletir o app. Cores, fontes, espaçamentos e
raios continuam vindo de `lib/core/theme/`.

## Requisitos funcionais

### Header (`ShellAppBar`)

- **RF-01:** À esquerda, um selo redondo amarelo com o chapéu de formatura
  **preenchido** em marrom-escuro, e a marca: "Uni" em marrom-escuro e "Cronos" em
  dourado.
- **RF-02:** À direita, o botão "mais" (três pontos num círculo branco), no
  lugar do avatar com as iniciais. Continua alvo de 48dp, anunciado como
  "Abrir menu", abrindo o modal "Mais".
- **RF-03:** O header é igual em Dashboard, Enviar e Atividades, com a mesma
  altura, e sem botão de voltar. Sem saudação.
- **RF-04:** O Perfil não tem header: a página começa no cartão do aluno, logo
  abaixo da barra de status. O menu "Mais" continua nas outras três abas.

### Perfil

- **RF-05:** Um cartão branco com o avatar grande (sem anel), nome, e-mail e a
  pílula "instituição · curso · período"; abaixo de uma divisória, o resumo
  (horas lançadas, certificados, % da meta), cada número com seu ícone.
- **RF-06:** Preferências (Notificações, Idioma, Acessibilidade) num cartão
  branco, com ícone em selo dourado suave, título, subtítulo e seta; abrem as
  mesmas folhas de antes.
- **RF-07:** "Sair" num cartão próprio, em `error`, sem seta; mantém o diálogo
  de confirmação.
- **RF-08:** Carregando, um indicador fica no lugar da identidade; com erro, a
  mensagem e "Tentar de novo" ficam dentro do cartão.

### Dashboard

- **RF-09:** Todo o conteúdo fica (título, cartões por categoria, barras, horas
  e meta, "Aprovados recentemente", "Ver todos", vazio, carregando e erro),
  em cartões brancos mais arredondados; cada cartão de categoria mostra a % da
  meta num selo.

### Menu "Mais"

- **RF-10:** O menu "Mais" (e o modal de Configurações, que usa o mesmo
  componente) ganha o visual do app: folha clara, itens agrupados num cartão
  branco, selos de ícone dourados, seta, rodapé discreto com nome e versão.

## Critérios de aceite

- **CA-01:** No Dashboard, o header mostra o chapéu preenchido
  (`Icons.school`) e "Uni Cronos", e nenhuma saudação.
- **CA-04:** Em Enviar e Atividades, o header mostra o chapéu e "Uni Cronos",
  com a mesma altura do Dashboard. No Perfil não há header.
- **CA-05:** O botão do menu do header é alvo de 48dp, anunciado só como
  "Abrir menu", e abre o modal "Mais"; o header não tem botão de voltar.
- **CA-06:** O header cabe em 320dp a 1,5x de texto sem estourar.
- **CA-07:** O Perfil mostra "Ana Souza", o e-mail, "UTFPR · Engenharia de
  Software · 5º período", e as iniciais "AS" no avatar grande.
- **CA-08:** Cada número do resumo do Perfil tem seu ícone (`schedule_outlined`,
  `description_outlined`, `flag_outlined`) centrado acima do valor.
- **CA-09:** Notificações, Idioma e Acessibilidade mostram a seta
  (`chevron_right_outlined`); "Sair" não tem seta.
- **CA-10:** O Perfil cabe em 320dp a 1x e 360dp a 1,5x de texto sem estourar.
- **CA-11:** O chapéu do header é pintado em `tertiary` (marrom-escuro).
- **CA-12:** Cada cartão de categoria do Dashboard mostra a % da meta ("65%",
  "45%"); acima da meta, mostra "100%".
- **CA-13:** Nenhum cartão do Perfil usa `primaryContainer` como fundo.
- **CA-14:** O menu "Mais" mostra Mensagens e Configurações, termina com o nome
  e a versão do app, e Configurações abre o modal de configurações.
- **CA-15:** A marca do header é "Uni" em `tertiary` e "Cronos" em
  `primaryFixedDim`.
- **CA-16:** A marca do header usa o tamanho de `headlineSmall`, em Bold (700).
- **CA-17:** O botão do canto superior direito é o ícone
  `more_vert_outlined`, e o header não mostra as iniciais do aluno.

## Fora de escopo

- Foto de perfil, editar o perfil.
- Esconder o header ao rolar.
- Tema escuro (decisão travada: só o claro).
- Atualizar o Figma: fica com quem cuida do produto, depois desta spec.
- Mudar a barra inferior, a aba Enviar ou a aba Atividades.

## Regras de negócio e invariantes

- Nenhuma cor literal nos widgets: todas vêm de papéis do `ColorScheme`, que
  passam pelo filtro de daltonismo exatamente uma vez.
- O amarelo de fundo (`primaryContainer`) é acento: selos e indicador da aba —
  nunca fundo de cartão no Perfil.
- `primaryFixedDim` (dourado) e `tertiary` (marrom-escuro) são cores da marca, só
  no logotipo do header; não servem para texto corrido.
- Todo alvo tocável do header e do Perfil tem pelo menos 48dp.

## Contratos

```dart
// lib/core/theme/app_tokens.dart — AppColorRoles
static const primaryContainer = Color(0xFFFECB29);   // sem mudança
static const onPrimaryContainer = Color(0xFF6F5600); // sem mudança
static const primaryFixedDim = Color(0xFFF0B400);    // novo: "Cronos"
static const tertiary = Color(0xFF4E3B00);           // novo: chapéu e "Uni"

// AppRadii
static const double xl = 20;                         // novo: cartões grandes

// lib/app/shell/shell_app_bar.dart
class ShellAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ShellAppBar({super.key});
  static const double height = 72;
}
```

```json
// lib/l10n/app_*.arb
"dashboardGoalPercent": "{percent}%"
```

## Dependências e impacto

- `lib/app/shell/shell_app_bar.dart` (reescrito), `lib/app/shell/app_shell.dart`
  (sem header no Perfil).
- `lib/features/profile/presentation/profile_page.dart`,
  `lib/features/hours/presentation/dashboard_page.dart`,
  `lib/core/widgets/app_modal.dart` (novo leiaute).
- `lib/core/theme/app_tokens.dart` (`primaryFixedDim`, `tertiary`, `AppRadii.xl`).
- `lib/l10n/app_pt.arb`, `app_en.arb`, `app_es.arb` + gerados.
- Testes: `test/shell_header_test.dart` e `test/visual_refresh_test.dart`
  (novos); `test/app_shell_test.dart` e `test/app_theme_test.dart` (ajustados,
  ver Decisões).
- `docs/architecture.md`.

## Estratégia de teste específica

- O visual (cores exatas na tela, sombras, raios) não tem teste de imagem: o
  projeto não usa golden tests. Os testes garantem conteúdo, ícones, cores dos
  papéis, toques, acessibilidade e que nada estoura; a aparência é conferida à
  mão, no aparelho.

## Decisões durante a implementação

- **Escopo ampliado a pedido**, sem nova rodada de aprovação: além do header e
  do Perfil, o Dashboard e o menu "Mais" entraram (RF-09, RF-10).
- **Saudação removida.** A primeira versão tinha "Olá, Ana" no header do
  Dashboard (com `StudentProfile.firstName` e as strings `shellGreeting*`); foi
  implementada e depois retirada a pedido. Os CAs de saudação (CA-02, CA-03 e
  a parte de saudação de CA-01/CA-06) saíram com ela; `firstName` e as strings
  foram apagados.
- **Chapéu preenchido** (`Icons.school`), exceção pedida à regra de ícones
  `*_outlined`: é a marca, não um ícone de interface.
- **Duas cores de marca novas.** "Cronos" pediu um dourado mais escuro que o
  amarelo de fundo; tentar escurecer o próprio `primaryContainer` deixou o selo
  e o indicador da aba escuros demais. Ficou: `primaryContainer` como antes
  (fundos) e `primaryFixedDim` `#F0B400` para o texto — o ouro da imagem de
  referência, depois de testar `#FECB29`, `#E06C00`, `#D97400` e `#FFB300`.
  O tom do chapéu e do "Uni" entrou como `tertiary` (primeiro azul-escuro
  `#1E3A6E`, depois, a pedido, marrom-escuro `#4E3B00`, um tom abaixo do
  `primary` da barra de progresso), substituindo o do
  factory, que o design não usava.
- **Marca maior** (`headlineSmall`, 28px, em vez de `titleLarge`), num
  `FittedBox` que a encolhe em vez de cortá-la em tela estreita. O peso fica no
  Bold (700), o mais pesado da Montserrat empacotada; um ExtraBold (800) pede
  um arquivo de fonte novo em `assets/fonts/`.
- **Selo do chapéu redondo**, como na imagem de referência.
- **Sem capa no Perfil.** A capa em gradiente dourado do plano foi trocada por
  um cartão branco (o amarelo de fundo foi considerado bruto); o anel do avatar
  grande também saiu.
- **Depois, também a pedido:** o "mais" virou a grade de 9 pontos
  (`apps_outlined`), e o **Perfil voltou a ter o header**, igual às outras abas
  (RF-04 e a parte "No Perfil não há header" de CA-04 deixam de valer; o teste
  de CA-04 passou a pedir o header no Perfil).
- **Botão "mais" no lugar do avatar**, a pedido, depois do primeiro commit. As
  iniciais saíram do header (o Perfil ainda as mostra no cartão); os testes da
  006 que tocavam em "AS" para abrir o menu passaram a tocar no botão pelo
  rótulo "Abrir menu", e o teste da 010 sobre as iniciais "da app bar" foi
  renomeado para o que ele de fato verifica: as iniciais no cartão do Perfil.
- **Header no `Scaffold.appBar`.** Uma versão intermediária o pôs no fluxo da
  página para crescer com a saudação em duas linhas; isso fez a barreira de
  acessibilidade da navegação das abas esconder o header do leitor de tela.
  Sem a saudação, a marca cabe numa linha em 72dp, e ele voltou ao `appBar`.
- **Testes antigos ajustados**, sem mudar o que verificam:
  - `app_shell_test.dart` (CA-04 da 006): procuravam a marca e o botão de
    voltar dentro de `AppBar`; agora dentro de `ShellAppBar`. Do jeito antigo, o
    teste do botão de voltar passaria sem verificar nada.
  - `app_theme_test.dart`: a tabela de papéis ganhou `primaryFixedDim` e
    `tertiary`, também na lista dos que passam pelo filtro.
- **`app_modal.dart` passou a usar os tokens** (antes tinha raios e cores
  literais herdados do template).

## Perguntas em aberto

