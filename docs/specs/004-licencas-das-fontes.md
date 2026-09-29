---
id: 004
status: implementada
depende_de: [001]
---

# Registrar as licenças das fontes no app

> `status`: `rascunho` → `aprovada` → `implementada` (ou `descartada`). Uma spec
> só vira `aprovada` quando **Perguntas em aberto** estiver vazia. Ao fechar,
> `/destilar NNN` leva para `docs/architecture.md` e `docs/conventions.md` só o
> que ela virou estado; a spec fica aqui como histórico.

## Objetivo

Montserrat e Inter vão empacotadas no app sob a SIL OFL 1.1, que exige que a
licença acompanhe cada cópia distribuída. Os textos estão em `assets/fonts/`, mas
não entram no bundle nem aparecem na tela de licenças do app.

## Requisitos funcionais

- **RF-01:** A inicialização do app registra no `LicenseRegistry` a licença de
  Montserrat e a de Inter, com o texto completo da OFL de cada uma.

## Critérios de aceite

- **CA-01:** Depois de `AppBootstrap.initialize()`, o `LicenseRegistry` tem uma
  entrada para o pacote `Montserrat` e uma para `Inter`, cada uma com o texto da
  licença do seu arquivo `*-OFL.txt` (contendo "SIL Open Font License").

## Fora de escopo

- Criar um ponto de entrada para a tela de licenças na interface.

## Regras de negócio e invariantes

- Toda fonte empacotada tem sua licença registrada no `LicenseRegistry`.

## Contratos

- `assets/fonts/Montserrat-OFL.txt` e `assets/fonts/Inter-OFL.txt` declarados
  como assets no `pubspec.yaml`.
- Registro por `LicenseRegistry.addLicense`, com `LicenseEntryWithLineBreaks`,
  chamado em `AppBootstrap.initialize()`.

## Dependências e impacto

- `lib/app/app_bootstrap.dart`, `pubspec.yaml`, novo arquivo em `lib/core/`.

## Estratégia de teste específica

`AppBootstrap.initialize()` roda no teste: a falha do Firebase sem plataforma é
capturada pelo próprio bootstrap. `LicenseRegistry.reset()` antes de cada teste.

## Decisões durante a implementação

- O registro mora em `lib/core/theme/font_licenses.dart` (`FontLicenses`), junto
  do resto do tema, e lê as famílias de `AppTypography` — uma família nova em
  `AppTypography` precisa do seu `*-OFL.txt` em `assets/fonts/`.
- Os textos são lidos só quando a tela de licenças pede (o `addLicense` é
  preguiçoso); a inicialização não carrega nada.

## Perguntas em aberto
