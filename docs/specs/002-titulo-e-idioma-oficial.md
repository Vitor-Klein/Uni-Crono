---
id: 002
status: implementada
depende_de: []
---

# Corrigir o título do app e travar o idioma oficial em pt

> `status`: `rascunho` → `aprovada` → `implementada` (ou `descartada`). Uma spec
> só vira `aprovada` quando **Perguntas em aberto** estiver vazia. Ao fechar,
> `/destilar NNN` leva para `docs/architecture.md` e `docs/conventions.md` só o
> que ela virou estado; a spec fica aqui como histórico.

## Objetivo

O título do `MaterialApp` ainda é o nome do pacote (`uni_cronos`) — é o que a aba
do navegador e o seletor de apps mostram depois que o app carrega. E o idioma
oficial do Uni Cronos é pt, mas hoje o app segue o idioma do aparelho e cai em
`en` quando ele não é suportado; o ARB de referência também é o `en`.

## Requisitos funcionais

- **RF-01:** O título do app é "Uni Cronos".
- **RF-02:** Sem preferência de idioma salva, o app abre em pt, qualquer que seja
  o idioma do aparelho.
- **RF-03:** Uma preferência salva de en ou es continua valendo — são as
  traduções.
- **RF-04:** O ARB de referência da geração de l10n é o `app_pt.arb`, e pt é o
  primeiro idioma suportado.

## Critérios de aceite

- **CA-01:** O `MaterialApp` tem `title` "Uni Cronos".
- **CA-02:** Sem preferência salva e com o aparelho em en, o app renderiza em pt.
- **CA-03:** Com a preferência salva `en`, o app renderiza em en; com `es`, em es.
- **CA-04:** `AppLocalizations.supportedLocales` começa por pt.

## Fora de escopo

- Seletor de idioma na interface — o app não tem um hoje; en/es só são
  alcançáveis por preferência salva até ele existir.
- Traduzir os textos do `next_widgets_service` que aparecem em inglês.

## Regras de negócio e invariantes

- pt é o idioma do app sempre que não houver escolha explícita de en ou es.

## Contratos

- `l10n.yaml`: `template-arb-file: app_pt.arb` e
  `preferred-supported-locales: [pt]`.
- `MaterialApp.router(locale: <preferência salva> ?? const Locale('pt'))`.
- `LocaleCubit(supported: [pt, en, es])`.

## Dependências e impacto

- `lib/app/app.dart` — `title` e `locale`.
- `lib/app/app_providers.dart` — ordem e comentário do `supported`.
- `l10n.yaml` e `lib/l10n/app_localizations*.dart` (gerados).
- `lib/core/localization/next_widgets_fallback_delegate.dart` — conferir o
  comentário sobre pt.

## Estratégia de teste específica

Mesmo padrão do tema: `MyApp` com `debugHome`, lendo `Localizations.localeOf`.
O idioma do aparelho no teste vem de
`tester.platformDispatcher.localesTestValue`.

## Decisões durante a implementação

- **Leitura de "travar em pt":** pt é o padrão que ignora o idioma do aparelho;
  en/es continuam por preferência salva. Como o app não tem seletor de idioma,
  hoje na prática ele fica sempre em pt.
- **CA-03 nasceu verde:** é o comportamento que já existia e que o CA-02 não
  podia quebrar.
- **Teste existente editado:** o CA-07 da spec 001 navegava pelos rótulos em
  inglês ("ACCESSIBILITY", "Theme", "Dark") porque o app abria em en no ambiente
  de teste. Com pt como padrão, passou a usar os rótulos em pt — o que ele
  verifica não mudou.
- `lib/l10n/app_localizations*.dart` regenerados (só os comentários de doc
  passaram a citar o texto em pt, e a ordem de `supportedLocales`).
- O comentário de `app_providers.dart` sobre o `supported` citava um template
  Mustache que não existe neste repositório; foi reduzido ao que é verdade aqui.

## Perguntas em aberto
