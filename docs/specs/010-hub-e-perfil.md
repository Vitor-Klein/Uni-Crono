---
id: 010
status: implementada
depende_de: [007, 008, 012]
---

# Mostrar o Hub de Oportunidades do servidor e o Perfil do aluno

> `status`: `rascunho` → `aprovada` → `implementada` (ou `descartada`). Uma spec
> só vira `aprovada` quando **Perguntas em aberto** estiver vazia. Ao fechar,
> `/destilar NNN` leva para `docs/architecture.md` e `docs/conventions.md` só o
> que ela virou estado; a spec fica aqui como histórico.

## Objetivo

As duas abas que faltam. Atividades é o "Hub de Oportunidades" do Figma: uma
lista de **cursos e eventos** em que o aluno ganha certificado de horas, lida
da tabela `opportunities` do Supabase (012). Perfil é tela nova (carteirinha,
resumo e ajustes), com os dados reais do perfil.

Esta versão substitui a de vitrine com cinco atividades fixas no código,
aprovada antes e nunca implementada. O que mudou: o catálogo vem do servidor, os
tipos são curso/evento e "Inscrever-se" abre o link da oportunidade.

## Requisitos funcionais

- **RF-01:** O Hub lista as oportunidades publicadas, com tipo (curso ou
  evento), categoria de horas, título, quem oferece, data, modalidade,
  descrição e horas. A que tem `featured` vem primeiro, como destaque (card
  grande com bloco ilustrado). As outras vêm por data de início.
- **RF-02:** Os filtros Todas / Cursos / Eventos / Extensão / Complementares
  (um por vez) e a busca por título, descrição e quem oferece funcionam juntos.
  Sem resultado, aparece "Nenhuma oportunidade encontrada".
- **RF-03:** "Inscrever-se" abre o link da oportunidade fora do app. Só abre
  link `https`; sem link, o botão não aparece.
- **RF-04:** Carregando, o Hub mostra um indicador. Com erro, mostra "Não foi
  possível carregar as oportunidades" e "Tentar de novo". Puxar para baixo
  recarrega.
- **RF-05:** O Perfil mostra a carteirinha (iniciais, nome, e-mail, instituição
  · curso · período) lida do perfil do aluno, e o resumo (horas lançadas,
  certificados, % da meta) calculado do `HoursRepository`.
- **RF-06:** Em "Preferências", Notificações, Idioma e Acessibilidade abrem as
  mesmas folhas que o modal de configurações abre.
- **RF-07:** "Sair" pede confirmação ("Sair da conta?") e, confirmado, chama
  `signOut()` (012).

## Critérios de aceite

- **CA-01:** Com o repositório falso devolvendo as 6 oportunidades iniciais, o
  Hub mostra o destaque "Semana Acadêmica de Computação" primeiro.
- **CA-02:** O filtro "Cursos" deixa só os cursos; "Extensão" deixa só os de
  horas de extensão.
- **CA-03:** Buscar "python" deixa só "Introdução ao Python para Dados".
  Buscar "zzz" mostra "Nenhuma oportunidade encontrada". A busca ignora
  maiúsculas e acentos ("extensao" acha "Extensão").
- **CA-04:** "Inscrever-se" chama o lançador de link com a URL `https` da
  oportunidade. Oportunidade sem URL não tem o botão.
- **CA-05:** Com o repositório falhando, aparecem a mensagem de erro e "Tentar
  de novo"; tocar nele carrega de novo.
- **CA-06:** O Perfil mostra "Ana Souza", o e-mail da sessão, "UTFPR ·
  Engenharia de Software · 5º período", e o resumo calculado das horas do
  repositório falso.
- **CA-07:** Depois de um certificado novo de 10 h entrar no repositório, o
  resumo do Perfil soma 10 h e 1 certificado, sem recarregar a tela.
- **CA-08:** No Perfil, Idioma abre a folha de idiomas e escolher English troca
  o app; Acessibilidade abre a folha com Tema; Notificações abre a folha de
  notificações.
- **CA-09:** "Sair", e "Sair" de novo no diálogo, leva a `/login`. "Cancelar"
  no diálogo mantém no Perfil.
- **CA-10 (banco):** `authenticated` lê só as oportunidades com `published =
  true` e não insere, altera nem apaga nenhuma. `anon` não lê nada.

## Fora de escopo

- Inscrição dentro do app, detalhe da oportunidade, favoritos, aviso de
  oportunidade nova.
- Tela de administração para cadastrar oportunidades: o catálogo entra por
  migração ou pelo painel do Supabase.
- Editar o perfil e a foto.
- As fotos do Figma (sala de aula, laboratório, avatares "+5"): foram geradas
  pelo Stitch, com origem e licença desconhecidas, e não entram no app.

## Regras de negócio e invariantes

- Filtro e busca combinam (E); a busca ignora maiúsculas e acentos.
- O resumo do Perfil e o Dashboard leem o mesmo `HoursRepository`: nunca
  divergem.
- Todo link aberto pelo Hub é `https` e vem do banco, nunca montado com texto
  do usuário.
- As oportunidades iniciais são exemplos fictícios, marcados assim no seed:
  nenhuma imita um evento real de uma instituição.

## Contratos

```sql
create type opportunity_kind as enum ('course', 'event');

create table public.opportunities (
  id uuid primary key default gen_random_uuid(),
  kind opportunity_kind not null,
  hour_category hour_category not null,
  title text not null,
  description text not null,
  provider text not null,
  modality text not null check (modality in ('online','presencial','hibrido')),
  hours int not null check (hours between 1 and 999),
  starts_at date,
  url text check (url is null or url ~ '^https://'),
  featured boolean not null default false,
  published boolean not null default true,
  created_at timestamptz not null default now()
);
-- RLS: select para authenticated onde published. Sem escrita para o app.
```

```dart
enum OpportunityKind { course, event }

class Opportunity {
  final String id; final OpportunityKind kind; final HourCategory category;
  final String title; final String description; final String provider;
  final String modality; final int hours; final DateTime? startsAt;
  final Uri? url; final bool featured;
}

abstract class OpportunityRepository { Future<List<Opportunity>> list(); }
// SupabaseOpportunityRepository em produção.

class StudentProfile {
  final String fullName; final String email; final String institutionId;
  final String course; final int term;
}
abstract class ProfileRepository { Future<StudentProfile> current(); }
```

- Seed (6, fictícios): Semana Acadêmica de Computação (evento, complementares,
  20 h, destaque); Introdução ao Python para Dados (curso online,
  complementares, 40 h); Projeto de Extensão Horta Comunitária (evento,
  extensão, 30 h); Oficina de Robótica nas Escolas (curso, extensão, 16 h);
  Maratona de Programação (evento, complementares, 10 h); Mentoria de
  Tecnologia Comunitária (curso, extensão, 24 h).
- Leiaute do Hub (Figma): título "Hub de Oportunidades" (`displayMedium`);
  apoio `bodyLarge`; busca "Buscar oportunidades…"; chips (o selecionado em
  `primaryContainer`); card destaque com bloco ilustrado (ícone do tipo sobre
  `surfaceContainer`, no lugar da foto), tag `labelSmall` em caixa alta, título
  `headlineMedium`, horas, descrição e "Inscrever-se"; cards comuns com tag,
  ícone, título `titleLarge`, descrição `bodyMedium`, linha com quem oferece,
  data e modalidade, horas com ícone e botão.
- Leiaute do Perfil: carteirinha amarela (`primaryContainer`), três números
  (`titleLarge` em `primary`), seções "PREFERÊNCIAS" e "CONTA" (`labelSmall`),
  linhas com ícone, título e subtítulo; "Sair" em `error`.
- As folhas de Idioma e Acessibilidade saem do `settings_modal.dart` para
  funções reutilizáveis, chamadas pelo modal e pelo Perfil.
- `DemoStudent` (iniciais do avatar da casca) passa a vir do perfil real.

## Dependências e impacto

- Novos `lib/features/opportunities/` e `lib/features/profile/`; migração de
  `opportunities` + seed em `supabase/migrations/`.
- `lib/features/settings/presentation/settings_modal.dart` (extrair as folhas),
  `lib/app/shell/shell_app_bar.dart` (iniciais do perfil).
- `AuthGateway` (012), `HoursRepository` (012), `NotificationsCubit` (006),
  `url_utils.dart`.

## Decisões durante a implementação

- **A busca procura também em quem oferece:** "extensao" acha a Horta (título)
  e a Robótica ("Núcleo de Extensão (exemplo)").
- **Linha malformada do catálogo é pulada; link que não é `https` é
  descartado:** o resto do catálogo continua aparecendo.
- **`ProfileCubit` na casca, ao lado do `UploadCubit`:** a app bar usa as
  iniciais do perfil. O `DemoStudent` saiu; antes do perfil chegar, o avatar
  mostra um ícone de pessoa.
- **Falha ao carregar o perfil mostra mensagem e "Tentar de novo"** (não estava
  na spec; mesmo padrão do Dashboard e do Hub).
- **`TabPlaceholderPage` removido:** nenhuma aba é provisória. O teste CA-03 da
  casca (aba viva fora do palco) passou a achar a `OpportunitiesPage`.
- **Seed com "(exemplo)" em quem oferece e links em `example.com`** (domínio
  reservado), para nenhum exemplo imitar evento real.
- **"Sair da conta?" usa o `AlertDialog` do Flutter:** o `next_widgets_service`
  não tem diálogo de confirmação e nenhum lint pede outro.
- **Testes de banco** (`supabase/tests/opportunities.sql`) rodados pelo MCP:
  `opportunities ok`.

## Perguntas em aberto

