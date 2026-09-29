---
id: 007
status: aprovada
depende_de: [006]
---

# Entrar com login simulado e manter a sessão

> `status`: `rascunho` → `aprovada` → `implementada` (ou `descartada`). Uma spec
> só vira `aprovada` quando **Perguntas em aberto** estiver vazia. Ao fechar,
> `/destilar NNN` leva para `docs/architecture.md` e `docs/conventions.md` só o
> que ela virou estado; a spec fica aqui como histórico.

## Objetivo

Tela "Login e Instituição" do Figma, com login **simulado**: valida o formato,
não consulta servidor. A sessão fica salva no aparelho até o aluno sair.

## Requisitos funcionais

- **RF-01:** Sem sessão, qualquer rota da casca leva ao login.
- **RF-02:** O login pede instituição, e-mail acadêmico e senha, e só entra com
  os três válidos; cada campo inválido mostra o próprio erro.
- **RF-03:** Entrar salva a sessão e leva ao Dashboard; reabrir o app com
  sessão salva vai direto ao Dashboard.
- **RF-04:** "Esqueci?" e "Solicitar acesso" mostram o aviso "Disponível em
  breve".
- **RF-05:** Sair apaga a sessão e volta ao login (o botão fica no Perfil, 010;
  aqui só o método `signOut`).

## Critérios de aceite

- **CA-01:** Sem sessão salva, terminada a splash, a rota é `/login` e não há
  barra inferior.
- **CA-02:** Tocar em "Entrar" com tudo vazio mostra "Escolha sua instituição",
  "Informe seu e-mail acadêmico" e "Informe sua senha", e continua em `/login`.
- **CA-03:** Com e-mail sem formato válido (ex.: `ana@`), aparece "E-mail
  inválido".
- **CA-04:** Com UTFPR, `ana.souza@alunos.utfpr.edu.br` e senha `x`, "Entrar"
  leva a `/dashboard` e a sessão fica salva com esse e-mail e a instituição.
- **CA-05:** Com sessão salva, terminada a splash, a rota é `/dashboard`.
- **CA-06:** Com sessão, navegar para `/login` leva a `/dashboard`.
- **CA-07:** `signOut()` apaga a sessão e leva a `/login`.
- **CA-08:** "Esqueci?" e "Solicitar acesso" mostram "Disponível em breve".
- **CA-09:** A trava de atualização continua tendo prioridade sobre a sessão:
  bloqueado, vai para `/upgrade-required` com ou sem sessão.

## Fora de escopo

- Autenticação real (o `login_service`/Firebase Auth fica para o produto).
- O botão "Sair" (010).

## Regras de negócio e invariantes

- Ordem do `redirect`: 1) splash passa; 2) trava de atualização;
  3) sem sessão → `/login`; 4) com sessão em `/login` → `/dashboard`.
- A senha nunca é salva nem registrada em log — só e-mail e instituição.

## Contratos

```dart
class Session { final String email; final String institutionId; }

abstract class SessionRepository {
  Future<Session?> load();
  Future<void> save(Session session);
  Future<void> clear();
}
// SharedPrefsSessionRepository: chaves `session_email`, `session_institution`.

class SessionCubit extends Cubit<Session?> {
  Future<void> signIn({required String institutionId, required String email});
  Future<void> signOut();
}
```

- Instituições (fixas): `utfpr` UTFPR, `ufpr` UFPR, `pucpr` PUCPR, `uel` UEL.
- E-mail válido: `^[^@\s]+@[^@\s]+\.[^@\s]+$`.
- O `GoRouter` escuta o `SessionCubit` (`refreshListenable`), junto com a trava
  de atualização.
- Leiaute (Figma "Login e Instituição"): ícone + "Uni Cronos"
  (`headlineSmall`), "Acesse seus recursos acadêmicos." (`bodyLarge`,
  `onSurfaceVariant`); rótulos `labelLarge`; campos com borda `outline`, raio
  `AppRadii.sm`; seletor "Selecione sua universidade…"; placeholder
  "aluno@universidade.edu.br"; senha com olho e "Esqueci?" (`TextButton`);
  botão "Entrar" (`FilledButton`, pílula); rodapé "Novo por aqui? Solicitar
  acesso". O "Entrar na Biblioteca" do Figma é sobra de outro template.
- l10n pt/en/es para todos os textos da tela e os erros.

## Dependências e impacto

- Novo `lib/features/auth/` (`data/`, `domain/`, `presentation/`).
- `lib/app/app_router.dart`, `lib/app/app_providers.dart`, ARBs.
- **SECURITY.md** — ler antes: a spec toca autenticação, mesmo simulada.

## Estratégia de teste específica

`SessionRepository` com `SharedPreferences.setMockInitialValues`; testes de rota
pela casca real (006).

## Decisões durante a implementação

- …

## Perguntas em aberto
