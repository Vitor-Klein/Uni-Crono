---
id: 017
status: implementada
depende_de: []
---

# Abrir a splash com um zoom

> `status`: `rascunho` → `aprovada` → `implementada` (ou `descartada`). Uma spec
> só vira `aprovada` quando **Perguntas em aberto** estiver vazia. Ao fechar,
> `/destilar NNN` leva para `docs/architecture.md` e `docs/conventions.md` só o
> que ela virou estado; a spec fica aqui como histórico.

## Objetivo

A splash aparece parada. Ela passa a abrir com um zoom: a imagem cresce e
aparece aos poucos, e só depois o app segue para a tela inicial.

## Requisitos funcionais

- **RF-01:** Ao abrir, a imagem da splash começa em 85% do tamanho e
  transparente, e chega a 100% e opaca em 1,2 s, desacelerando no fim.
- **RF-02:** Com animações reduzidas (no menu de acessibilidade do app, ou no
  sistema quando o app segue o sistema), a imagem aparece já inteira, sem zoom.
- **RF-03:** O tempo da splash e a ida para a tela inicial não mudam.

## Critérios de aceite

- **CA-01:** No primeiro quadro, a imagem está em 85% e transparente; depois de
  1,2 s, em 100% e opaca.
- **CA-02:** Com o sistema pedindo animações reduzidas, a imagem já está em 100%
  e opaca no primeiro quadro.
- **CA-03:** Depois do tempo da splash, o app continua indo para o Dashboard
  (com sessão) ou para o login (sem sessão).

## Fora de escopo

- Trocar a imagem da splash (é a que estiver em `SplashScreen`).
- Animar a passagem da splash para o Dashboard além do fade que já existe.

## Regras de negócio e invariantes

- Toda animação passa por `isAnimationDisabled(context)` (`next_core_service`).

## Dependências e impacto

- `lib/features/splash/presentation/splash_screen.dart`.
- `test/app_harness.dart` (`pumpRoutedApp` aceita o tempo da splash e não
  esperar o fim); `test/splash_zoom_test.dart` (novo).
- `docs/architecture.md`.

## Decisões durante a implementação

- O zoom é um `TweenAnimationBuilder` sobre a imagem que já estava na splash
  (`splash_uni_cronos.png`, a splash real do app), sem tocar na imagem.
- O teste lê a escala do eixo x da matriz (`entry(0, 0)`):
  `getMaxScaleOnAxis()` devolve 1,0 porque `Transform.scale` não mexe no eixo z.

## Perguntas em aberto

