---
id: 010
status: aprovada
depende_de: [007, 008]
---

# Mostrar o Hub de Oportunidades e o Perfil do aluno

> `status`: `rascunho` → `aprovada` → `implementada` (ou `descartada`). Uma spec
> só vira `aprovada` quando **Perguntas em aberto** estiver vazia. Ao fechar,
> `/destilar NNN` leva para `docs/architecture.md` e `docs/conventions.md` só o
> que ela virou estado; a spec fica aqui como histórico.

## Objetivo

As duas abas que faltam. Atividades é o "Hub de Oportunidades" do Figma, como
vitrine: busca e filtros funcionam, a inscrição ainda não. Perfil é tela nova
(brainstorming: carteirinha + resumo + ajustes na própria tela).

## Requisitos funcionais

- **RF-01:** O Hub lista as atividades com categoria, título, descrição e horas;
  a primeira é o destaque (card grande com bloco ilustrado).
- **RF-02:** Os filtros Todas / Pesquisa / Extensão / Workshops e a busca por
  título e descrição funcionam juntos; sem resultado, aparece o estado vazio.
- **RF-03:** "Inscrever-se"/"Registrar" mostra "Disponível em breve".
- **RF-04:** O Perfil mostra a carteirinha (iniciais, nome, e-mail, instituição
  · curso · período) e o resumo (horas lançadas, certificados, % da meta),
  calculado do repositório de horas.
- **RF-05:** Em "Preferências", Notificações, Idioma e Acessibilidade abrem as
  mesmas folhas que o modal de configurações abre.
- **RF-06:** "Sair" pede confirmação ("Sair da conta?") e, confirmado, apaga a
  sessão e volta ao login.

## Critérios de aceite

- **CA-01:** O Hub mostra as 5 atividades iniciais, a primeira como destaque
  ("Levantamento de Ecologia Costeira", Pesquisa, 12 h).
- **CA-02:** Filtrar "Extensão" deixa só "Mentoria de Tecnologia Comunitária" e
  "Iniciativa Horta do Campus".
- **CA-03:** Buscar "dados" deixa só "Visualização de Dados Avançada"; buscar
  com o filtro "Pesquisa" ativo e sem resultado mostra "Nenhuma atividade
  encontrada".
- **CA-04:** "Inscrever-se" mostra "Disponível em breve".
- **CA-05:** O Perfil mostra o nome, o e-mail da sessão e "UTFPR · Engenharia de
  Software · 5º período", e o resumo "175 h", "3", "58%".
- **CA-06:** Depois de lançar um certificado de 10 h, o resumo do Perfil mostra
  "185 h" e "4".
- **CA-07:** No Perfil, Idioma abre a folha de idiomas e escolher English troca
  o app; Acessibilidade abre a folha com Tema; Notificações abre a folha de
  notificações.
- **CA-08:** "Sair" → "Sair" no diálogo leva a `/login` sem sessão salva;
  "Cancelar" no diálogo mantém no Perfil.

## Fora de escopo

- Inscrição em atividades, detalhe da atividade, edição do perfil, foto.
- As fotos do Figma (sala de aula, laboratório, avatares "+5"): geradas pelo
  Stitch, com origem e licença desconhecidas — não entram no app.

## Regras de negócio e invariantes

- Filtro e busca combinam (E); a busca ignora maiúsculas e acentos.
- O resumo do Perfil e o Dashboard leem o mesmo `HoursRepository`: nunca
  divergem.

## Contratos

```dart
enum ActivityKind { research, extension, workshop }

class Activity {
  final String id; final ActivityKind kind; final String title;
  final String description; final String hoursLabel; // "12 h", "2 h/semana"
  final bool featured;
}

abstract class ActivityRepository { Future<List<Activity>> list(); }

class StudentProfile {
  final String name; final String email; final String institution;
  final String course; final int term;
}
// Perfil fictício: Ana Souza, Engenharia de Software, 5º período; e-mail e
// instituição vêm da sessão (007).
```

- Atividades iniciais (pt): Levantamento de Ecologia Costeira (Pesquisa, 12 h,
  destaque); Mentoria de Tecnologia Comunitária (Extensão, 2 h/semana);
  Visualização de Dados Avançada (Workshop, 4 h); Iniciativa Horta do Campus
  (Extensão, 3 h); Escrita de Projetos 101 (Workshop, 5 h). Descrições
  traduzidas do Figma.
- Leiaute do Hub: título "Hub de Oportunidades" (`displayMedium`), texto de
  apoio `bodyLarge`; busca "Buscar oportunidades…"; chips de filtro
  (selecionado `primaryContainer`); card destaque com bloco ilustrado (ícone
  da categoria sobre `surfaceContainer`, no lugar da foto), tag `labelSmall`
  em caixa alta, título `headlineMedium`, horas, descrição, "Inscrever-se";
  cards comuns com tag, ícone, título `titleLarge`, descrição `bodyMedium`,
  horas com ícone e botão.
- Leiaute do Perfil: como a v2 do brainstorming — carteirinha amarela
  (`primaryContainer`), três números (`titleLarge` `primary`), seções
  "PREFERÊNCIAS" e "CONTA" (`labelSmall`), linhas com ícone, título e
  subtítulo; "Sair" em `error`.
- As folhas de Idioma e Acessibilidade saem do `settings_modal.dart` para
  funções reutilizáveis chamadas pelo modal e pelo Perfil.

## Dependências e impacto

- Novos `lib/features/activities/` e `lib/features/profile/`.
- `lib/features/settings/presentation/settings_modal.dart` (extrair as folhas).
- `SessionCubit` (007), `HoursRepository` (008), `NotificationsCubit` (006).

## Decisões durante a implementação

- …

## Perguntas em aberto

