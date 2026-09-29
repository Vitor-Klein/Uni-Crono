---
id: 005
status: implementada
depende_de: [002]
---

# Oferecer a escolha de idioma nas configurações

> `status`: `rascunho` → `aprovada` → `implementada` (ou `descartada`). Uma spec
> só vira `aprovada` quando **Perguntas em aberto** estiver vazia. Ao fechar,
> `/destilar NNN` leva para `docs/architecture.md` e `docs/conventions.md` só o
> que ela virou estado; a spec fica aqui como histórico.

## Objetivo

O app abre em pt e aceita en/es por preferência salva, mas não tem onde escolher:
as traduções são inalcançáveis. Esta spec põe a escolha no modal de
configurações, usando a folha de idioma que o `next_widgets_service` já traz.

## Requisitos funcionais

- **RF-01:** O modal de configurações tem um item de idioma que mostra o idioma
  em uso.
- **RF-02:** O item abre uma folha com Português, English e Español — cada um no
  próprio idioma —, com o atual marcado. Não há opção "Sistema": sem escolha, o
  app é pt.
- **RF-03:** Escolher um idioma troca o app para ele na hora e salva a escolha.

## Critérios de aceite

- **CA-01:** Sem escolha salva, o modal de configurações mostra o item "IDIOMA"
  com o subtítulo "Português".
- **CA-02:** A folha de idioma lista "Português", "English" e "Español" — e nada
  de "Sistema" —, com só o idioma atual marcado.
- **CA-03:** Escolher "English" deixa o app em en e salva `en` como preferência.
- **CA-04:** Com en salvo, escolher "Português" volta o app para pt e salva `pt`.

## Fora de escopo

- Idiomas além de pt, en e es.

## Regras de negócio e invariantes

- Os nomes dos idiomas na folha não são traduzidos: cada um aparece no próprio
  idioma, para que quem não lê o idioma atual reconheça o seu.

## Contratos

- Item no `showSettingsModal`: título `settingsLanguageTitle` (pt "IDIOMA", en
  "LANGUAGE", es "IDIOMA"), ícone `Icons.language_outlined`, subtítulo com o
  nome do idioma atual.
- Folha: `showLanguageSheet(context:, semanticsLabel:, options:)` do
  `next_widgets_service`, com `LanguageOption` para pt (🇧🇷), en (🇺🇸) e es (🇪🇸).
  Rótulo de acessibilidade `settingsLanguageSemantics`.
- Troca: `LocaleCubit.setLocale(Locale(code))`.

## Dependências e impacto

- `lib/features/settings/presentation/settings_modal.dart`.
- `lib/l10n/app_{pt,en,es}.arb` e os gerados.

## Decisões durante a implementação

- `next_core_service` e `next_widgets_service` exportam cada um um
  `LanguageOption`; o `settings_modal.dart` importa o `next_core_service` com
  `hide LanguageOption` — o da folha é o do `next_widgets_service`.
- O item de idioma entrou entre Notificações e Acessibilidade.
- **Verificação manual (web, 390×844):** as bandeiras renderizam; escolher
  English troca o app inteiro na hora ("SETTINGS", "LANGUAGE · English").

## Perguntas em aberto
