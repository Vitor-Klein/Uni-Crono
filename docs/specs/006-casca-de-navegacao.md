---
id: 006
status: implementada
depende_de: [001, 005]
---

# Montar a casca de navegação com as quatro abas

> `status`: `rascunho` → `aprovada` → `implementada` (ou `descartada`). Uma spec
> só vira `aprovada` quando **Perguntas em aberto** estiver vazia. Ao fechar,
> `/destilar NNN` leva para `docs/architecture.md` e `docs/conventions.md` só o
> que ela virou estado; a spec fica aqui como histórico.

## Objetivo

Primeira spec do protótipo navegável (Figma, Page 1). Troca a home do template
pela casca do design: app bar com a marca e o avatar, barra inferior com
Dashboard, Upload, Atividades e Perfil. As telas de cada aba chegam nas specs
008–010; aqui cada aba mostra só o seu título.

Decisões do brainstorming que valem para 006–010: protótipo com dados fictícios
em memória (só a sessão persiste), repositórios com implementação em memória +
Cubits por feature, `StatefulShellRoute.indexedStack`, caminhos em inglês.

## Requisitos funcionais

- **RF-01:** Depois da splash, o app abre na aba Dashboard, dentro da casca.
- **RF-02:** A barra inferior tem Dashboard, Upload, Atividades e Perfil; a aba
  ativa fica destacada, e tocar numa aba mostra a tela dela.
- **RF-03:** Cada aba guarda seu estado ao trocar de aba (rolagem, telas
  empilhadas dentro dela).
- **RF-04:** A app bar mostra "Uni Cronos" e o avatar do aluno; tocar no avatar
  abre o modal "Mais" que a home do template abria (Mensagens, Configurações,
  Compartilhar/Privacidade/Termos quando configurados, nome e versão do app).
- **RF-05:** O estado "notificações ativadas" sai da `HomePage` para um Cubit
  compartilhado, com o mesmo comportamento de hoje (troca otimista, reverte se
  a gravação falhar, aviso de sucesso/erro).
- **RF-06:** A rota `/home` e a `HomePage` do template deixam de existir; o que
  apontava para `/home` (splash, trava de atualização) aponta para
  `/dashboard`.

## Critérios de aceite

- **CA-01:** Terminada a splash, a rota atual é `/dashboard` e a barra inferior
  mostra os quatro destinos com os rótulos em pt: "Dashboard", "Enviar",
  "Atividades", "Perfil" (en: "Upload"; es: "Subir" na segunda aba).
- **CA-02:** Tocar em cada destino da barra leva a `/dashboard`, `/upload`,
  `/activities` e `/profile`, e o destino tocado fica selecionado.
- **CA-03:** Rolar a aba Atividades, ir ao Dashboard e voltar mantém a rolagem
  de Atividades.
- **CA-04:** A app bar mostra "Uni Cronos"; tocar no avatar abre o modal "Mais"
  com "MENSAGENS" e "CONFIGURAÇÕES".
- **CA-05:** Pelo modal "Mais" → Configurações → Notificações, desligar as
  notificações grava `false` no `PushService` e o subtítulo passa a
  "Desativado"; se a gravação falhar, o valor volta e aparece o aviso de erro.
- **CA-06:** Com a trava de atualização liberando, quem estava em
  `/upgrade-required` vai para `/dashboard`.

## Fora de escopo

- Conteúdo das abas (008 Dashboard, 009 Upload, 010 Atividades e Perfil).
- Login e o redirecionamento por sessão (007).

## Regras de negócio e invariantes

- A barra inferior e a app bar só existem dentro da casca: splash, login,
  atualização obrigatória e webview ficam fora.
- Um único dono para o estado de notificações; nenhuma tela guarda cópia.

## Contratos

```dart
abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';            // 007
  static const dashboard = '/dashboard';
  static const upload = '/upload';
  static const uploadReview = '/upload/review'; // 009
  static const activities = '/activities';
  static const profile = '/profile';
  static const upgradeRequired = '/upgrade-required';
  static const webview = '/webview';
}
```

- Casca: `StatefulShellRoute.indexedStack` com um `StatefulShellBranch` por aba;
  widget `AppShell` em `lib/app/shell/` com `NavigationBar` (M3) e a app bar.
- Barra inferior: ícones `Icons.*_outlined` do SDK — `dashboard_outlined`,
  `upload_file_outlined`, `explore_outlined`, `person_outline`; fundo
  `surfaceContainerLowest`, indicador e rótulo ativo em `primary`.
- App bar: marca em `titleLarge` `w700` cor `primary`; avatar circular com as
  iniciais do aluno (`primaryContainer`/`onPrimaryContainer`), sem foto.
- `NotificationsCubit` (`lib/features/notifications/presentation/` ou
  `domain/`), provido no `AppProviders`; estado `bool enabled`; método
  `setEnabled(bool)` com a mesma lógica de hoje em `HomePage`.
- l10n (pt/en/es): `navDashboard`, `navUpload`, `navActivities`, `navProfile`.

## Dependências e impacto

- `lib/app/app_router.dart`, `lib/core/navigation/app_routes.dart`,
  `lib/app/app_providers.dart`.
- Novo `lib/app/shell/`.
- `lib/features/home/` — sai `home_page.dart`; `home_more_modal.dart` fica e é
  aberto pelo avatar.
- `lib/features/splash/`, `lib/features/upgrade/` — destino `/dashboard`.
- `lib/features/notifications/` — novo Cubit.
- Testes que dependem da home do template.

## Estratégia de teste específica

Testes de rota montam o `MyApp` **sem** `debugHome`, com o `AppRouter` real. A
splash ganha a duração injetável (`SplashScreen(duration:)`, padrão 3 s) para
que os testes passem pela splash real sem esperar 3 s.

## Decisões durante a implementação

- **App bar é o `NextAppBar`, não um `AppBar`:** o `custom_lint` do projeto
  (`no_app_bar_widget`) proíbe o `AppBar` do Flutter e manda usar o
  `NextAppBar`; silenciar o lint está fora de questão. Consequência visual: a
  marca fica **centralizada numa barra transparente**, e não alinhada à
  esquerda como no Figma. A cor segue o contrato (`primary`). Alinhar à
  esquerda exigiria suporte no `next_widgets_service` ou uma exceção ao lint
  aprovada. `showLeading: false` explícito — a casca nunca mostra "voltar".
- **Indicador da aba ativa em `primaryContainer`** (amarelo), com ícone
  `onPrimaryContainer`; rótulo ativo em `primary` e inativos em
  `onSurfaceVariant`, como o contrato pede. A cor dos ícones vai por um
  `NavigationBarTheme`, porque o `NavigationBar` não recebe `iconTheme`.
- **A casca usa `pageBuilder` com `AppTransitions.fade`:** com `builder` o
  go_router aplicava a transição da plataforma e ignorava a preferência de
  "reduzir animações". Achado da revisão final.
- **`NotificationsCubit` criado na inicialização (`lazy: false`):** preguiçoso,
  ele só nascia no primeiro toque no avatar e o modal recebia o `true`
  otimista antes do valor salvo. Achado da revisão da tarefa.
- **Remote Config sem Firebase cai nos padrões:** `RemoteConfigService.get`
  lançava exceção sem Firebase (testes, web com inicialização falha), o que
  quebraria o modal "Mais". Correção prévia, fora da lista de impacto.
- **CA-03 verificado por proxy:** as abas ainda só mostram o título, sem
  rolagem; o teste prova que a página da aba deixada continua montada fora do
  palco (mesmo `ScrollableState`), validado por mutação. O teste de rolagem
  real entra com o Hub (spec 010).
- **Testes que nasceram verdes (guardas):** CA-02 "aba já selecionada" e "aba
  aberta pela URL"; CA-01 en/es; CA-06 "fica onde está". O reset da aba ao
  tocar de novo (`initialLocation`) só é testável com rota aninhada — entra na
  spec 009 (`/upload/review`).
- **Teste reescrito:** "setting the current value writes nothing" não podia
  falhar (partia do valor atual); virou "a quick double tap to the same value
  writes once".
- **`kAppName`** (`lib/app/app_info.dart`) e **`DemoStudent`**
  (`lib/features/profile/domain/demo_student.dart`, iniciais do avatar) criados
  aqui; a spec 010 constrói o perfil sobre eles.
- **Avatar com alvo de 48dp** e anunciado só como "Abrir menu".
- **Verificação manual (web, 390×844):** splash → Dashboard, título da aba
  "Uni Cronos", quatro abas, troca de aba, avatar → Mais → Configurações →
  Notificações → "Desativado". No web, em debug, aparece o aviso vermelho
  "Push/Firebase (dev)" ao trocar: o FCM não suporta tópicos no web — comportamento
  que já existia no `PushService`.

## Perguntas em aberto

