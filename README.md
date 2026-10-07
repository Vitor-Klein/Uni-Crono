# Uni Cronos

Aplicativo móvel para estudantes de graduação acompanharem as **horas
complementares** e as **horas de extensão** exigidas pelo curso. O estudante
envia o PDF de cada certificado. O próprio aplicativo lê o documento, identifica
a carga horária e a categoria e soma as horas no painel de progresso. Quando o
PDF não permite a leitura automática, o estudante informa os dados em um
formulário. O aplicativo também oferece um Hub de Oportunidades, com cursos e
eventos que podem gerar novos certificados.

Projeto acadêmico desenvolvido na UTFPR, na disciplina de desenvolvimento
multiplataforma.

## Telas

Telas do protótipo de alta fidelidade feito no Figma, que serviu de base para a
interface ([abrir no Figma](https://www.figma.com/design/vNP3TPcSQFyIJEEPhlqSCE/Untitled?node-id=0-1&t=1HmSgf8XhXO0iEt8-1)).

| Login | Dashboard de horas | Enviar certificado | Hub de Oportunidades |
|:---:|:---:|:---:|:---:|
| <img src="assets/telas/Login%20e%20Institui%C3%A7%C3%A3o%20-%20UTFPR%20Style.png" width="200" alt="Tela de login com escolha da instituição"> | <img src="assets/telas/Dashboard%20de%20Horas%20-%20UTFPR%20Style.png" width="200" alt="Dashboard com o progresso das horas por categoria"> | <img src="assets/telas/Lan%C3%A7ar%20Certificado%20-%20UTFPR%20Style.png" width="200" alt="Tela de envio do PDF do certificado"> | <img src="assets/telas/Hub%20de%20Oportunidades%20-%20UTFPR%20Style.png" width="200" alt="Hub com cursos e eventos"> |

## Funcionalidades

- Cadastro e login com instituição, e-mail e senha (UTFPR, UFPR, PUCPR e UEL).
- Painel com o progresso de cada categoria em relação à meta (35 h
  complementares e 200 h de extensão) e a lista de certificados lançados.
- Envio de certificados em PDF, com leitura automática da carga horária e da
  categoria no próprio aparelho e detecção de arquivos duplicados.
- Lançamento manual quando o PDF não tem texto ou não traz a carga horária.
- Hub de Oportunidades com busca e filtros.
- Perfil com resumo das horas e preferências de idioma (pt, en, es),
  acessibilidade e notificações.
- Tema claro e escuro, suporte a leitor de tela e tamanho de texto ajustável.

## Stack

| Tecnologia | Versão | Uso |
|---|---|---|
| Flutter | 3.41.5 (canal stable) | Framework de interface |
| Dart | 3.11.3 | Linguagem |
| supabase_flutter | 2.18.0 | Autenticação, banco Postgres e armazenamento de arquivos |
| pdfrx | 2.4.7 | Leitura do texto do PDF no aparelho |
| flutter_bloc | 9.1.1 | Gerência de estado (Cubits) |
| go_router | 17.5.0 | Navegação |
| file_picker | 11.0.3 | Escolha do arquivo PDF |
| firebase_messaging / firebase_remote_config | 16.2.2 / 6.5.1 | Notificações push e configuração remota |
| shared_preferences | 2.5.5 | Preferências salvas no aparelho |

A lista completa de bibliotecas, com o papel de cada uma, está em
[docs/02-arquitetura.md](docs/02-arquitetura.md#26-bibliotecas).

## Estrutura de pastas

```text
uni_cronos/
├── lib/
│   ├── app/            # inicialização, rotas e casca com as quatro abas
│   ├── core/           # tema, configuração, navegação, localização e utilitários
│   ├── features/       # uma pasta por funcionalidade (auth, hours, upload,
│   │                   # opportunities, profile...), cada uma com
│   │                   # presentation/, domain/ e data/
│   └── l10n/           # textos em português, inglês e espanhol
├── test/               # testes automatizados (unidade e widget)
├── supabase/
│   ├── migrations/     # estrutura do banco, regras de acesso e bucket
│   └── tests/          # testes das regras de acesso do banco (SQL)
├── assets/             # fontes, ícones, splash e telas do protótipo
├── config/             # modelo do arquivo de configuração (app.example.json)
├── docs/               # documentação do projeto
├── android/ ios/ web/  # projetos de cada plataforma
└── pubspec.yaml        # dependências
```

## Documentação

| Documento | Conteúdo |
|---|---|
| [docs/01-visao-e-requisitos.md](docs/01-visao-e-requisitos.md) | Problema, público, requisitos funcionais com critérios de aceitação, requisitos não funcionais e fora do escopo |
| [docs/02-arquitetura.md](docs/02-arquitetura.md) | Camadas, diagrama de navegação, diagramas de sequência e bibliotecas |
| [docs/03-planejamento.md](docs/03-planejamento.md) | Cronograma, estratégia de branches, convenção de commits e justificativa da licença |
| [docs/architecture.md](docs/architecture.md) | Descrição detalhada de cada módulo, das regras de negócio e do design system |
| [docs/conventions.md](docs/conventions.md) | Convenções de código, testes e commits |

## Como rodar do zero

### Pré-requisitos

| Ferramenta | Versão | Observação |
|---|---|---|
| Git | 2.40 ou superior | — |
| Flutter SDK | 3.41.5 (stable), que inclui o Dart 3.11.3 | [Instalação](https://docs.flutter.dev/get-started/install). Confira com `flutter --version`. |
| Android Studio | versão atual | Fornece o Android SDK (API 36) e o JDK 21 usado pelo Gradle. |
| Emulador ou aparelho Android | Android 7.0 (API 24) ou superior | No aparelho físico, com a depuração USB ativada. |
| Conta no GitHub com acesso à organização `BFAC-Microservices` | — | Ver o passo 2. |
| Conta no [Supabase](https://supabase.com) | plano gratuito | Ver o passo 4. |

Rode `flutter doctor` e confirme que os itens **Flutter** e **Android toolchain**
aparecem sem erros.

### 1. Clonar o repositório

```bash
git clone https://github.com/Vitor-Klein/Uni-Crono.git
cd Uni-Crono
```

### 2. Ter acesso às dependências privadas

O aplicativo usa oito pacotes da organização
[BFAC-Microservices](https://github.com/BFAC-Microservices), que são
**repositórios privados**: `about-us-service`, `login-service`,
`next-core-service`, `next-widgets-service`, `pdf-service`, `rss-feed-service`,
`subscribe-service` e `lints-service`. O `flutter pub get` os baixa pelo Git,
via HTTPS, e falha sem acesso a eles.

1. Peça acesso de leitura à organização a um dos autores (seção
   [Autores](#autores)), informando o seu usuário do GitHub.
2. Configure o Git para autenticar no GitHub. A forma mais simples é a
   [GitHub CLI](https://cli.github.com):

   ```bash
   gh auth login
   gh auth setup-git
   ```

   Para conferir o acesso, este comando deve listar uma referência `HEAD`, e não
   pedir senha nem retornar erro:

   ```bash
   git ls-remote https://github.com/BFAC-Microservices/next-core-service.git HEAD
   ```

### 3. Instalar as dependências

```bash
flutter pub get
```

### 4. Preparar o servidor (Supabase)

O aplicativo precisa de um projeto Supabase com as tabelas, as regras de acesso
e o bucket de certificados. Há duas opções:

- **Usar o projeto da equipe:** peça aos autores a URL e a chave publicável e
  siga para o passo 5.
- **Criar um projeto próprio** (cerca de 5 minutos):
  1. Em [supabase.com/dashboard](https://supabase.com/dashboard), crie um
     projeto novo. A região sugerida é `South America (São Paulo)`.
  2. Em **SQL Editor**, execute o conteúdo de cada arquivo de
     `supabase/migrations/`, **um por vez e nesta ordem**:
     1. `20261006190000_profiles_and_certificates.sql`
     2. `20261006200000_certificates_bucket.sql`
     3. `20261006210000_opportunities.sql`
     4. `20261007120000_students_insert_own_certificates.sql`
  3. Em **Authentication → Sign In / Providers → Email**, desligue
     **Confirm email**, para que a conta criada no aplicativo entre direto.
  4. Copie a **Project URL** (`https://<id-do-projeto>.supabase.co`) e a
     **Publishable key** (começa com `sb_publishable_`). As duas aparecem no
     botão **Connect**, no topo do painel, e em **Project Settings → API Keys**.
     **Não** use a chave `secret` nem a `service_role`.

### 5. Configurar as variáveis de ambiente

O aplicativo não usa um arquivo `.env`. As variáveis são lidas em tempo de
compilação a partir de `config/app.json`, pela opção
`--dart-define-from-file` do Flutter. O arquivo `config/app.example.json` faz o
papel do `.env.example`: lista todas as chaves, sem valores reais. O
`config/app.json` está no `.gitignore` e nunca é versionado.

```bash
cp config/app.example.json config/app.json
```

Preencha `config/app.json` com os valores do passo 4:

| Chave | O que preencher | Exemplo de formato |
|---|---|---|
| `SUPABASE_URL` | Project URL do projeto Supabase | `https://abcdefghijklmnop.supabase.co` |
| `SUPABASE_PUBLISHABLE_KEY` | Publishable key do mesmo projeto | `sb_publishable_...` |

A chave publicável é a chave de cliente do Supabase: ela é feita para ficar
dentro do aplicativo, e os dados são protegidos pelas regras de acesso do banco.
Nenhuma chave secreta é usada pelo aplicativo. Se o aplicativo for executado
sem essas variáveis (por exemplo, sem a opção `--dart-define-from-file`), ele
abre uma tela explicando como configurá-las, em vez de ficar em branco.

As configurações do Firebase (`lib/firebase_options.dart`,
`android/app/google-services.json` e `ios/Runner/GoogleService-Info.plist`) já
estão no repositório. Elas são identificadores públicos de cliente e não exigem
nenhuma ação.

### 6. Executar

Com um emulador aberto ou um aparelho conectado:

```bash
flutter devices                                        # confirma o aparelho
flutter run --dart-define-from-file=config/app.json
```

No VS Code, basta pressionar **F5**: o `.vscode/launch.json` já passa o arquivo
de configuração.

Para testar o fluxo completo, crie uma conta na tela inicial ("Criar conta") e
envie um certificado em PDF pela aba **Enviar**.

### Verificações de qualidade

```bash
flutter analyze                                              # análise estática
dart run custom_lint                                         # lints do projeto
flutter test                                                 # testes automatizados
dart format --output=none --set-exit-if-changed lib test     # formatação
```

Os testes não acessam a rede: o Supabase e o Firebase são substituídos por
versões falsas.

## Autores

- Vitor Hugo Klein
- Murilo Pistore
- Fabiola Malman

## Licença

Distribuído sob a licença MIT. Veja o arquivo [LICENSE](LICENSE). A justificativa
da escolha está em [docs/03-planejamento.md](docs/03-planejamento.md#34-licença).
As fontes Montserrat e Inter seguem a SIL Open Font License 1.1 (textos em
`assets/fonts/`).
