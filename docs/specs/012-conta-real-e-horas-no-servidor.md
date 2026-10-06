---
id: 012
status: aprovada
depende_de: [007, 008]
---

# Entrar com conta real e guardar as horas de cada aluno no servidor

> `status`: `rascunho` → `aprovada` → `implementada` (ou `descartada`). Uma spec
> só vira `aprovada` quando **Perguntas em aberto** estiver vazia. Ao fechar,
> `/destilar NNN` leva para `docs/architecture.md` e `docs/conventions.md` só o
> que ela virou estado; a spec fica aqui como histórico.

## Objetivo

O login simulado (007) e as horas em memória (008) não servem para um hub de
verdade: fechar o app apaga tudo e qualquer e-mail entra. Esta spec troca os
dois pelo Supabase, num projeto novo, `uni-cronos`, da org KleinOS (plano free,
`sa-east-1`). O aluno cria a conta, entra com e-mail e senha, e as horas dele
ficam no banco, que só ele lê. É a base que o upload com leitura de PDF (009) e
o Hub (010) usam.

## Requisitos funcionais

- **RF-01:** "Entrar" autentica e-mail e senha no Supabase Auth. Com as
  credenciais erradas, mostra "E-mail ou senha incorretos" e continua no login.
- **RF-02:** "Solicitar acesso" vira "Criar conta" e abre `/signup`, que pede
  nome, instituição, curso, período (1 a 12), e-mail e senha (8 caracteres ou
  mais). Cada campo inválido mostra o próprio erro. Criar a conta grava o perfil
  e entra.
- **RF-03:** A sessão é a do Supabase, renovada pelo SDK e guardada por ele.
  Reabrir o app com a sessão válida leva ao Dashboard; com a sessão vencida e
  sem renovação, leva ao login.
- **RF-04:** O Dashboard lê as horas da tabela `certificates` do aluno, com as
  mesmas regras de hoje (metas de 200 h e 100 h, percentual arredondado para
  baixo, barra que para em 1,0).
- **RF-05:** Sem rede, ou com o servidor falhando, o login mostra "Sem conexão.
  Tente de novo." e o Dashboard mostra o erro com "Tentar de novo".
- **RF-06:** `signOut()` encerra a sessão no Supabase e volta ao login.
- **RF-07:** Ninguém lê, cria ou altera certificado ou perfil de outro aluno.
  Nem o próprio aluno cria certificado direto pela API: só o leitor de
  certificados (009), no servidor, faz isso.

## Critérios de aceite

- **CA-01:** Com UTFPR, `ana.souza@alunos.utfpr.edu.br` e a senha certa,
  "Entrar" leva a `/dashboard`. A sessão traz o id do usuário, o e-mail e a
  instituição do perfil.
- **CA-02:** Com a senha errada, aparece "E-mail ou senha incorretos", a rota
  continua `/login` e a senha não fica salva em lugar nenhum.
- **CA-03:** Com a autenticação sem rede, aparece "Sem conexão. Tente de novo."
- **CA-04:** Em `/signup`, "Criar conta" com tudo vazio mostra o erro de cada
  campo. Senha com 7 caracteres mostra "Use 8 caracteres ou mais". Período 0 ou
  13 mostra "Informe um período de 1 a 12".
- **CA-05:** Com os dados válidos, "Criar conta" grava o perfil (nome,
  instituição, curso, período) e leva a `/dashboard`.
- **CA-06:** Com um e-mail que já tem conta, aparece "Este e-mail já tem conta".
- **CA-07:** O Dashboard de um aluno sem certificados mostra "0 de 200 horas",
  "0 de 100 horas" e "Nenhum certificado ainda".
- **CA-08:** Com dois certificados no servidor (10 h complementares, 15 h de
  extensão), o Dashboard mostra 10 de 200 e 15 de 100, os dois em "Aprovados
  recentemente", do mais novo ao mais antigo.
- **CA-09:** Se a busca das horas falha, o Dashboard mostra "Não foi possível
  carregar suas horas" e "Tentar de novo"; tocar nele busca de novo.
- **CA-10:** Sem sessão, `/signup` abre. Com sessão, `/signup` vai para
  `/dashboard`.
- **CA-11:** `signOut()` encerra a sessão no Supabase e leva a `/login`.
- **CA-12 (banco):** Com RLS, o aluno A não lê o perfil nem os certificados do
  aluno B. O papel `anon` não lê nenhum dos dois. O papel `authenticated` não
  insere, altera nem apaga em `certificates`.

## Fora de escopo

- "Esqueci?" (recuperar senha): continua "Disponível em breve". O SMTP padrão
  do Supabase manda poucos e-mails por hora.
- Login social, troca de e-mail ou senha, apagar a conta.
- Validar que o e-mail pertence à instituição.
- Confirmação de e-mail: fica desligada no Supabase Auth (decisão do usuário:
  o SMTP padrão manda poucos e-mails por hora). O risco aceito é alguém criar
  conta com e-mail que não é seu.
- Horas anteriores ao app: o total é só a soma dos certificados lançados nele.
- Uso offline: sem rede, o app mostra o erro e não guarda cópia das horas.

## Regras de negócio e invariantes

- O app só conhece a chave **publicável** do Supabase. A `service_role` mora só
  no servidor do leitor (009), no cofre de variáveis do Vercel.
- RLS ligada em todas as tabelas de `public`. Toda política compara
  `auth.uid()` com o dono da linha.
- A senha nunca sai do campo: vai para o SDK do Supabase e para mais nenhum
  lugar (nada de log nem de armazenamento próprio).
- Aluno novo começa com 0 h nas duas categorias. As horas-base e os
  certificados fictícios saem do app.
- Ordem do `redirect`: 1) a splash passa; 2) trava de atualização; 3) sem
  sessão, toda rota que não é `/login` nem `/signup` vai para `/login`; 4) com
  sessão, `/login` e `/signup` vão para `/dashboard`.

## Contratos

```sql
create type hour_category as enum ('complementary', 'extension');

create table public.profiles (
  id uuid primary key references auth.users on delete cascade,
  full_name text not null check (char_length(full_name) between 1 and 120),
  institution_id text not null check (institution_id in ('utfpr','ufpr','pucpr','uel')),
  course text not null check (char_length(course) between 1 and 120),
  term smallint not null check (term between 1 and 12),
  created_at timestamptz not null default now()
);
-- RLS: select/update só onde id = auth.uid(). Criado por trigger em auth.users
-- a partir de raw_user_meta_data (full_name, institution_id, course, term).

create table public.certificates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users on delete cascade,
  title text not null check (char_length(title) between 1 and 200),
  issuer text,
  category hour_category not null,
  hours int not null check (hours between 1 and 999),
  file_path text not null,
  file_sha256 text not null,
  source text not null check (source in ('extracted', 'manual')),
  approved_at timestamptz not null default now(),
  unique (user_id, file_sha256)
);
-- RLS: só select, onde user_id = auth.uid(). Nenhuma política de
-- insert/update/delete para authenticated: só a service_role escreve.
```

```dart
class Session { final String userId; final String email; final String institutionId; }

abstract class AuthGateway {               // SupabaseAuthGateway em produção
  Session? get current;
  Stream<Session?> changes();
  Future<Session> signIn({required String email, required String password});
  Future<Session> signUp(SignUpData data);
  Future<void> signOut();
}
// Erros tipados: InvalidCredentials, EmailAlreadyRegistered, NetworkFailure.

class SignUpData {
  final String fullName; final String institutionId; final String course;
  final int term; final String email; final String password;
}

class SupabaseHoursRepository implements HoursRepository { /* lê certificates */ }
```

- Pacote novo: `supabase_flutter`, na versão lida do pub.dev na hora de
  instalar, com o nome conferido caractere a caractere (SECURITY.md).
- Configuração por `--dart-define-from-file=config/app.json` (no
  `.gitignore`), com `SUPABASE_URL` e `SUPABASE_PUBLISHABLE_KEY`. Um
  `config/app.example.json` versionado mostra o formato.
- Leiaute de `/signup`: igual ao do login (marca, campos com borda `outline` e
  raio `AppRadii.sm`, `FilledButton` em pílula), título "Criar conta" e rodapé
  "Já tem conta? Entrar".

## Dependências e impacto

- Supabase: criar o projeto `uni-cronos` (KleinOS) e as migrações em
  `supabase/migrations/`.
- `lib/features/auth/` (`SessionRepository` sai e entra o `AuthGateway`; a
  `LoginPage` muda, nasce a `SignUpPage`), `lib/app/app_bootstrap.dart`
  (`Supabase.initialize` antes do `runApp`), `app_router.dart`,
  `app_providers.dart`.
- `lib/features/hours/data/` (o repositório em memória sai de produção e fica
  só como fake de teste), `dashboard_page.dart` (estados vazio e de erro).
- Testes que usam as horas-base (175 h etc.) mudam de dados.
- ARBs pt/en/es. **SECURITY.md** — ler antes: autenticação e dado pessoal.

## Estratégia de teste específica

- O app nunca fala com o Supabase em `flutter test`. `AuthGateway` e
  `HoursRepository` entram por interface, com fakes que podem falhar sob
  comando.
- As políticas RLS (CA-12) são testadas em `supabase/tests/rls.sql`, rodado
  contra o banco com `set role` e `request.jwt.claims` de dois usuários: cada
  asserção que falha levanta exceção.

## Decisões durante a implementação

- …

## Perguntas em aberto

