# 1. Visão e requisitos

Este documento descreve o problema que o Uni Cronos resolve, o público a que se
destina, os requisitos funcionais e não funcionais e o que fica fora do escopo
desta versão.

## 1.1 Problema

Os cursos de graduação exigem que o estudante cumpra uma carga mínima de **horas
complementares** e de **horas de extensão** para concluir o curso. Na UTFPR, por
exemplo, são 35 h complementares e 200 h de extensão. Os comprovantes dessas
atividades são certificados em PDF emitidos por instituições diferentes, cada um
em um formato. Em geral, o estudante não tem um lugar único para reunir os
certificados e acompanhar quanto já cumpriu e quanto ainda falta. Esse controle
costuma ser feito à mão, em planilhas ou pastas, e está sujeito a erro.

## 1.2 Proposta

O Uni Cronos é um aplicativo móvel em que o estudante envia o PDF de cada
certificado. O próprio aplicativo lê o documento, identifica a carga horária e a
categoria (complementar ou extensão) e soma as horas no painel de progresso.
Quando o PDF não permite a leitura automática, o estudante informa os dados em um
formulário. O aplicativo oferece também um **Hub de Oportunidades**, um catálogo
de cursos e eventos que podem gerar novos certificados.

## 1.3 Público-alvo

- **Usuário principal:** estudantes de graduação que precisam comprovar horas
  complementares e de extensão.
- **Instituições disponíveis no cadastro:** UTFPR, UFPR, PUCPR e UEL.
- **Equipe mantenedora:** publica as oportunidades do Hub pelo painel do
  servidor. Não há perfil de administrador dentro do aplicativo.

## 1.4 Requisitos funcionais

Cada requisito traz um critério de aceitação objetivo, verificável no aplicativo
em execução.

### RF01 — Criar conta

O estudante cria uma conta informando nome, instituição, curso, período, e-mail
e senha. Esses dados formam o perfil do estudante.

**Critério de aceitação:** com período fora do intervalo de 1 a 12, o campo
mostra "Informe um período de 1 a 12"; com senha de menos de 8 caracteres, mostra
"Use 8 caracteres ou mais". Em ambos os casos, nenhuma conta é criada. Com dados
válidos, a conta é criada, e o Perfil exibe o mesmo nome, instituição, curso e
período informados.

### RF02 — Entrar na conta

O estudante entra com instituição, e-mail e senha. A conta precisa pertencer à
instituição escolhida.

**Critério de aceitação:** com senha incorreta, o aplicativo mostra "E-mail ou
senha incorretos" e permanece no login. Com uma conta da UTFPR e a instituição
UFPR selecionada, mostra "Esta conta é de outra instituição", e nenhuma sessão
fica aberta. Com os dados corretos, abre o Dashboard.

### RF03 — Manter a sessão e proteger as telas

Sem sessão, nenhuma tela interna fica acessível. Com sessão, o estudante não
precisa entrar de novo ao reabrir o aplicativo.

**Critério de aceitação:** sem sessão, qualquer rota interna (por exemplo,
`/dashboard`) leva ao login. Depois de entrar, fechar e reabrir o aplicativo leva
direto ao Dashboard, sem pedir a senha.

### RF04 — Sair da conta

O estudante encerra a sessão pelo Perfil.

**Critério de aceitação:** "Sair" abre a confirmação "Sair da conta?". Ao
confirmar, o aplicativo volta ao login. Se outro estudante entrar em seguida no
mesmo aparelho, o Dashboard não mostra as horas do anterior.

### RF05 — Acompanhar o progresso de horas

O Dashboard mostra, por categoria, as horas acumuladas, a meta (35 h
complementares e 200 h de extensão), uma barra de progresso e o percentual da
meta.

**Critério de aceitação:** com 130 h complementares e 45 h de extensão, o
Dashboard mostra "130 de 35 h" com a barra cheia e "100%", e "45 de 200 h" com
"22%". O percentual é arredondado para baixo e nunca passa de 100%. Um estudante
sem certificados vê 0 h nas duas categorias e 0% da meta.

### RF06 — Listar os certificados lançados

O Dashboard lista os certificados aprovados, do mais recente ao mais antigo.

**Critério de aceitação:** depois de lançar dois certificados em sequência, o
segundo aparece no topo da lista. Sem certificados, a seção mostra um estado
vazio.

### RF07 — Escolher o PDF do certificado

Na aba Enviar, o estudante escolhe um arquivo do aparelho. Só são aceitos PDFs de
até 10 MB.

**Critério de aceitação:** um arquivo que não é PDF (por exemplo, uma imagem
PNG), ou um PDF maior que 10 MB, é recusado com a mensagem "Use um PDF de até 10
MB", e nada é enviado ao servidor.

### RF08 — Ler o certificado automaticamente

O aplicativo extrai o texto do PDF no próprio aparelho, identifica a carga
horária e a categoria e lança as horas sem etapa de conferência.

**Critério de aceitação:** um PDF com o texto "Carga Horária Total: 260 horas"
que menciona "projeto de extensão" é lançado como 260 h em Horas de Extensão. O
aplicativo mostra "Certificado lançado: +260 h em Horas de Extensão", e o total
do Dashboard aumenta em 260 h.

### RF09 — Lançar o certificado manualmente

Quando o PDF não tem texto (documento digitalizado) ou não traz a carga horária,
o estudante informa título, horas e categoria em um formulário.

**Critério de aceitação:** um PDF sem texto abre o formulário manual com o
título sugerido. Horas iguais a 0 ou maiores que 999 são recusadas com "Informe
as horas (1 a 999)". Com valores válidos, o certificado é lançado e aparece no
Dashboard.

### RF10 — Impedir lançamento duplicado

O mesmo arquivo não pode ser contado duas vezes para o mesmo estudante. A
comparação usa a impressão digital SHA-256 do arquivo.

**Critério de aceitação:** enviar o mesmo PDF uma segunda vez mostra "Este
certificado já foi lançado", e o total de horas do Dashboard não se altera.

### RF11 — Consultar o Hub de Oportunidades

O Hub lista os cursos e eventos publicados, com busca por texto e os filtros
Todas, Cursos, Eventos, Extensão e Complementares.

**Critério de aceitação:** o filtro "Eventos" mostra apenas eventos. A busca por
"extensao" (sem acento) encontra uma oportunidade cujo título contém "Extensão".
Uma busca sem resultado mostra "Nenhuma oportunidade encontrada".

### RF12 — Acessar a inscrição de uma oportunidade

"Inscrever-se" abre o link da oportunidade no navegador do sistema.

**Critério de aceitação:** em uma oportunidade com link `https`, o botão abre o
navegador nesse endereço. Uma oportunidade sem link, ou com link que não seja
`https`, não exibe o botão.

### RF13 — Consultar o perfil

O Perfil mostra os dados do estudante e um resumo: horas lançadas, número de
certificados e percentual da meta.

**Critério de aceitação:** com 175 h lançadas em 5 certificados, o resumo do
Perfil mostra "175 h", "5" e "74%". Esses valores são os mesmos do Dashboard.

### RF14 — Ajustar as preferências

O estudante escolhe o idioma (português, inglês ou espanhol), as opções de
acessibilidade e se quer receber notificações.

**Critério de aceitação:** em um aparelho configurado em inglês, o aplicativo
abre em português. Depois de escolher "English", os textos passam para o inglês,
e a escolha se mantém ao reabrir o aplicativo.

## 1.5 Requisitos não funcionais

### Plataformas

- **RNF01:** o aplicativo é construído em Flutter 3.41 (Dart 3.11), com uma única
  base de código.
- **RNF02:** a plataforma-alvo desta versão é **Android**. É nela que o
  aplicativo foi compilado e verificado em aparelho. O projeto também está
  configurado para iOS (12.0 ou superior) e para web, sem verificação em aparelho
  nesta versão.
- **RNF03:** as telas funcionam a partir de 320 dp de largura e com o texto
  ampliado em até 1,5×, sem estouro de layout. Isso é verificado por testes
  automatizados.

### Rede

- **RNF04:** entrar, criar conta, carregar horas, enviar certificados e
  consultar o Hub exigem conexão com a internet. A leitura do PDF acontece no
  aparelho e não depende da rede.
- **RNF05:** sem conexão, ou com falha do servidor, cada tela mostra uma
  mensagem de erro e a ação "Tentar de novo", em vez de travar ou ficar em
  branco. No login, a mensagem é "Sem conexão. Tente de novo.".
- **RNF06:** o envio de um certificado é atômico do ponto de vista do estudante:
  se o registro falhar depois do upload do PDF, o arquivo enviado é apagado.
- **RNF07:** as fontes ficam empacotadas no aplicativo, que não baixa nenhum
  recurso visual em tempo de execução.

### Permissões

- **RNF08:** no Android, o aplicativo declara apenas `INTERNET` e
  `FOREGROUND_SERVICE`. Esta última é usada pelas notificações.
- **RNF09:** a permissão de notificações é solicitada ao sistema na
  inicialização (Android 13 ou superior e iOS). Recusá-la não impede o uso do
  aplicativo.
- **RNF10:** a escolha do PDF usa o seletor de arquivos do sistema, sem
  permissão de acesso ao armazenamento. O aplicativo não usa câmera, localização,
  contatos nem microfone.

### Acessibilidade

- **RNF11:** todos os elementos interativos têm rótulo para leitores de tela
  (TalkBack e VoiceOver). As barras de progresso são anunciadas como "N de M
  horas".
- **RNF12:** os alvos de toque têm no mínimo 48 × 48 dp.
- **RNF13:** todo par de texto e fundo do tema tem contraste de pelo menos 4,5:1,
  nos temas claro e escuro (WCAG 2.1, nível AA).
- **RNF14:** o menu de acessibilidade oferece tamanho de texto, tema (Sistema,
  Claro ou Escuro), filtro para daltonismo e redução de animações. As escolhas
  são salvas no aparelho.

### Privacidade e LGPD

- **RNF15 — Minimização:** o aplicativo coleta apenas o necessário para contar as
  horas: nome, e-mail, instituição, curso, período e os certificados enviados (o
  PDF e os dados lidos dele).
- **RNF16 — Acesso restrito:** os dados ficam no Supabase, na região
  `sa-east-1` (São Paulo). Regras de acesso por linha (RLS) garantem que cada
  estudante leia e grave somente os próprios dados. Visitantes sem login não leem
  nada. Os PDFs ficam em um bucket privado, em uma pasta por estudante.
- **RNF17 — Credenciais:** a senha é enviada apenas ao serviço de autenticação.
  O aplicativo não a salva nem a registra em log. O aplicativo conhece somente a
  chave pública do servidor, e nenhuma chave secreta fica no código.
- **RNF18 — Registros:** os logs de erro registram apenas o tipo do erro, nunca
  dados pessoais.
- **RNF19 — Aparelho compartilhado:** ao sair da conta, os dados do estudante
  são removidos da memória do aplicativo.
- **RNF20 — Exclusão:** ao excluir um usuário no servidor, o perfil e os
  certificados dele são apagados em cascata. A exclusão ainda não pode ser pedida
  pelo próprio aplicativo (ver 1.6).

## 1.6 Fora do escopo

Os itens abaixo não fazem parte desta versão:

- **Reconhecimento de texto em imagem (OCR):** um PDF digitalizado sempre leva ao
  lançamento manual.
- **Metas por instituição ou por curso:** as metas da UTFPR valem para todas as
  instituições.
- **Validação da autenticidade do certificado** junto ao emissor, e
  **aprovação por coordenação de curso**. As horas lançadas valem como registro
  pessoal do estudante.
- **Edição ou exclusão de um certificado já lançado.**
- **Recuperação de senha** e **lista completa de certificados**. Os botões
  existem e mostram "Disponível em breve".
- **Exclusão da conta pelo próprio aplicativo** e **política de privacidade
  publicada.** Ambas são necessárias para o atendimento completo à LGPD em uma
  versão pública e estão previstas no planejamento.
- **Inscrição em oportunidades dentro do aplicativo:** a inscrição acontece no
  site de quem oferece.
- **Servidor próprio:** todo o back-end usa os serviços gerenciados do Supabase.
