# Roteiro dos testes da v0.2.x com usuários e aparelhos reais

Guia para conduzir, passo a passo, a sessão de teste da Release [v0.2.1](https://github.com/samuelgomezdev/nexo-future-app/releases/tag/v0.2.1) (Etapa 2) com uma pessoa, em um aparelho real e com o Firebase de produção.

## Como usar este roteiro

- Leia em voz alta só o que está em **💬 Diga**. Fale com as suas palavras se ficar mais natural.
- **Não mostre onde tocar.** O teste é do app, não da pessoa: se ela não achar o caminho, isso é um achado.
- Se a pessoa ficar travada por **mais de 1 minuto**, use a dica de **🆘 Se travar** e marque "com ajuda" na folha.
- Anote na hora, na **folha de anotação** do fim do roteiro (imprima uma por pessoa).
- Cada sessão leva de **30 a 40 minutos**.

Legenda: 💬 Diga · ✅ Deu certo se · 👀 Observe · 🆘 Se travar · ⏱️ Meça

## Parte 1. Antes de a pessoa chegar

- [ ] Ter à mão o arquivo **privado** de contas e senhas (`docs/privado/CONTAS_TESTE.md`, que não vai para o GitHub). Ele diz qual conta usar em cada tarefa.
- [ ] No aparelho do teste, **desinstalar** a v0.1.0, a v0.2.0 ou qualquer outra versão do Nexo Future. A assinatura é diferente e o Android não instala uma por cima da outra.
- [ ] Baixar e instalar a v0.2.1 pelo [link direto](https://github.com/samuelgomezdev/nexo-future-app/releases/download/v0.2.1/app-release.apk), permitindo "Instalar apps desconhecidos" se o Android pedir. Abrir o app uma vez para conferir.
- [ ] Ligar o **Não perturbe** no aparelho, para notificações pessoais não aparecerem durante o teste.
- [ ] Separar um **segundo celular** com o cronômetro e o Gmail de testes aberto (para confirmar e-mails, se a pessoa não usar o próprio).
- [ ] Combinar o e-mail que a pessoa vai usar no cadastro: o **dela** (mais realista) ou um apelido do Gmail de testes (`+p01`, `+p02`...), se ela preferir não usar o próprio. Veja o arquivo privado.
- [ ] **Espaçar as sessões** em alguns minutos: o Firebase limita os e-mails de confirmação enviados em sequência.

## Parte 2. Abertura (2 minutos)

💬 **Diga:**
> "Obrigado por participar. O Nexo Future é um app que liga jovens a cursos e a vagas de emprego da região. Hoje eu quero ver se ele é fácil de usar. **Quem está sendo testado é o app, não você**: não existe resposta errada, e se algo for difícil, a culpa é do app.
> Vou pedir algumas tarefas. Tente fazer sozinho e, se puder, **fale em voz alta o que está pensando** ("estou procurando...", "achei que aqui ia..."). Eu não vou ajudar logo de cara, porque quero ver onde o app confunde.
> Vou só anotar o que acontecer, sem gravar nada. Não vou anotar seu nome, só um código. Você pode parar quando quiser. Tudo bem?"

Anote o código da pessoa (P01, P02...). **Não grave a tela** de quem testa.

## Parte 3. Tarefas

### Tarefa 1. Encontrar uma vaga (visitante, sem conta)

Antes: **desligue o Wi-Fi** do aparelho (teste em 4G) e deixe o app fechado.

💬 **Diga:**
> "Imagine que você procura emprego na área de solda. Abra o app e encontre uma vaga de solda. Depois, me diga em que empresa ela é e qual curso prepara para ela."

⏱️ **Meça (RNF0001 e RNF0008, meta < 5 s):** com o cronômetro do segundo celular, conte do toque no ícone do app até a lista de vagas aparecer. Depois, do fim da digitação na pesquisa até a lista filtrada aparecer.

✅ **Deu certo se** a pessoa usou a pesquisa ou o filtro de área, abriu uma vaga e leu a empresa e os cursos vinculados.

👀 **Observe:** ela entendeu os filtros de área (Naval, Metalurgia...)? Entendeu a etiqueta "Aceitando candidaturas"?

🆘 **Se travar:** "Tem um campo de pesquisa no alto da tela."

### Tarefa 2. Tentar se candidatar sem conta

💬 **Diga:**
> "Gostou dessa vaga? Então se candidate a ela."

✅ **Deu certo se** o app pediu para entrar ou criar uma conta.

👀 **Observe:** a pessoa entendeu por que precisa de conta? Escolheu "Entrar" ou "Criar conta"?

### Tarefa 3. Criar a conta e confirmar o e-mail

💬 **Diga:**
> "Crie a sua conta de jovem e entre no app."

✅ **Deu certo se** a pessoa escolheu o perfil de jovem, preencheu o cadastro, aceitou a Política de Privacidade, recebeu o e-mail, tocou no link e conseguiu entrar.

👀 **Observe:**
- Algum campo confundiu (data de nascimento, cidade, senha)?
- Quanto tempo o e-mail levou para chegar? Caiu no spam?
- Ela entendeu a tela "Confirme seu e-mail"?

🆘 **Se travar:**
- E-mail não chegou: "Confira o spam." Se não estiver lá, espere 1 ou 2 minutos e peça para tocar em **Reenviar e-mail**. Antes disso, o Firebase recusa o reenvio e o app pede para esperar; isso é esperado.
- Usou o apelido do Gmail de testes: abra o link de confirmação no segundo celular. O link funciona em qualquer aparelho.
- **Não** criar outra conta com o mesmo e-mail.

### Tarefa 4. Candidatar-se e acompanhar a candidatura

Antes: volte à **lista de vagas**, já com a conta aberta.

💬 **Diga:**
> "Agora se candidate a uma vaga que você gostaria. Depois, me mostre onde você vê as suas candidaturas."

⏱️ **Conte os toques (RNF0009, meta ≤ 3):** da lista de vagas até a mensagem "Você se candidatou à vaga...".

✅ **Deu certo se** a mensagem apareceu, o botão virou "Candidatura enviada" e a vaga aparece em "Minhas candidaturas" (ícone no alto da lista de vagas).

🆘 **Se travar** em achar as candidaturas: "Tem um ícone no alto da tela de vagas."

### Tarefa 5. Ver uma vaga lotar

💬 **Diga:**
> "Se candidate também à vaga de Inspetor de Qualidade, da MetalSul."

Ela tem **1 posição**. Se já estiver lotada, use outra vaga de 1 posição do arquivo privado.

✅ **Deu certo se** o detalhe da vaga e a lista passaram a mostrar **"Lotada"** logo depois da candidatura.

👀 **Observe:** a pessoa entendeu o que "Lotada" quer dizer?

### Tarefa 6. Limite de 5 candidaturas

💬 **Diga:**
> "Continue se candidatando a outras vagas até o app não deixar mais."

Dica para quem conduz: pesquisar "auxiliar" mostra várias vagas com posições sobrando.

✅ **Deu certo se**, na 6ª candidatura, apareceu o aviso **"Limite de candidaturas"** com o botão "Minhas candidaturas", e, depois de desistir de uma, a 6ª foi aceita.

👀 **Observe:** a pessoa entendeu o aviso? Achou como desistir de uma candidatura?

🆘 **Se travar:** "Abra as suas candidaturas pelo botão do aviso."

### Tarefa 7. Errar a senha 5 vezes

💬 **Diga:**
> "Saia da sua conta. Agora finja que esqueceu a senha e tente entrar com senhas erradas até o app reagir."

✅ **Deu certo se** a cada erro o app avisou quantas tentativas restam e, na 5ª, bloqueou o login por **15 minutos** com contagem regressiva.

👀 **Observe:** os avisos foram claros?

ℹ️ O bloqueio vale enquanto o app estiver aberto. Para seguir, feche o app pela lista de apps recentes e abra de novo.

### Troca de papel: empresa e oficina

💬 **Diga:**
> "Agora você vai ver o outro lado do app: o da empresa que publica vagas e o da oficina que oferece cursos. Eu vou entrar com contas de teste para você."

Quem conduz entra com as contas do arquivo privado. A pessoa não precisa ver as senhas.

### Tarefa 8. Empresa publica uma vaga

Entre com a conta da **empresa** (Estaleiro Foz Azul).

💬 **Diga:**
> "Você é recrutador do Estaleiro Foz Azul. Antes de preencher, toque em Publicar vaga para ver o que o app pede. Depois, publique uma vaga de **Ajudante naval**, com **2 posições**, em **Itajaí**. Na qualificação, escreva **'Vaga de teste P01'**, com o seu código."

✅ **Deu certo se:**
- com tudo vazio, cada campo mostrou o erro **inteiro**, inclusive "Informe as posições.";
- depois de preenchida, a vaga apareceu no painel e na pesquisa como **"Aguardando cursos"**.

👀 **Observe:** os erros eram fáceis de entender? A pessoa entendeu o que são os "cursos preferenciais"?

### Tarefa 9. Oficina sem alvará tenta publicar um curso

Saia e entre com a **oficina sem alvará** (Oficina Escola Barra Sul).

💬 **Diga:**
> "Agora você cuida da Oficina Escola Barra Sul. Cadastre um curso de **'Solda básica'**, de **40 horas** e **15 vagas na turma**, para a vaga de Ajudante naval que você acabou de publicar."

✅ **Deu certo se** o app avisou que falta o **alvará de ensino** e o curso só pôde ser salvo como **rascunho**.

👀 **Observe:** a pessoa entendeu por que não pôde publicar?

### Tarefa 10. Oficina com alvará envia o curso e a empresa aprova

Saia e entre com a **oficina com alvará** (Oficina Escola Porto Novo).

💬 **Diga:**
> "Esta outra oficina tem o alvará em dia. Cadastre o mesmo curso para a vaga de Ajudante naval e publique."

Depois, saia e entre de novo com a **empresa** (Estaleiro Foz Azul).

💬 **Diga:**
> "Você é o recrutador de novo. Uma oficina mandou um curso para a sua vaga. Decida se aprova."

✅ **Deu certo se:**
- o painel mostrou "1 curso aguarda sua aprovação";
- a pessoa abriu o curso e tocou em **"Aprovar curso"**;
- na pesquisa, a vaga de Ajudante naval passou a **"Aceitando candidaturas"**.

👀 **Observe:** ela achou os cursos para aprovar? Entendeu o efeito da aprovação na vaga?

## Parte 4. Encerramento (5 minutos)

💬 **Diga:**
> "Acabaram as tarefas. Para fechar, três perguntas rápidas:
> 1. O que foi mais fácil?
> 2. O que foi mais difícil ou confuso?
> 3. Você usaria esse app ou indicaria para alguém? O que mudaria?"

Depois:
- [ ] Na conta de jovem da pessoa, **desistir das candidaturas** em "Minhas candidaturas", para liberar as vagas para quem vier depois. Em seguida, tocar em **Sair**.
- [ ] Se a pessoa usou o próprio e-mail e quiser apagar a conta, anotar o pedido. A exclusão é feita pelo console do Firebase.
- [ ] Agradecer.

---

## Folha de anotação (uma por pessoa)

### Pessoa e aparelho

| Campo | Anotação |
|---|---|
| Código da pessoa (P01, P02...) | |
| Data e hora | |
| Modelo do aparelho | |
| Versão do Android | |
| Tamanho da fonte do sistema | ☐ Padrão ☐ Grande ☐ Outro: |
| Rede | ☐ 4G ☐ Wi-Fi ☐ Outra: |
| Sinal (barras) | |

### Tarefas

| # | Tarefa | Resultado | Observações |
|---|---|---|---|
| 1 | Encontrar uma vaga | ☐ Sozinho ☐ Com ajuda ☐ Não conseguiu | |
| 2 | Candidatar-se sem conta | ☐ Sozinho ☐ Com ajuda ☐ Não conseguiu | |
| 3 | Criar a conta e confirmar o e-mail | ☐ Sozinho ☐ Com ajuda ☐ Não conseguiu | E-mail chegou em ___ min ☐ Spam ☐ Precisou reenviar |
| 4 | Candidatar-se e ver "Minhas candidaturas" | ☐ Sozinho ☐ Com ajuda ☐ Não conseguiu | |
| 5 | Ver a vaga lotar | ☐ Sozinho ☐ Com ajuda ☐ Não conseguiu | |
| 6 | Limite de 5 candidaturas | ☐ Sozinho ☐ Com ajuda ☐ Não conseguiu | |
| 7 | Errar a senha 5 vezes | ☐ Sozinho ☐ Com ajuda ☐ Não conseguiu | |
| 8 | Empresa publica vaga | ☐ Sozinho ☐ Com ajuda ☐ Não conseguiu | |
| 9 | Oficina sem alvará | ☐ Sozinho ☐ Com ajuda ☐ Não conseguiu | |
| 10 | Oficina envia e empresa aprova o curso | ☐ Sozinho ☐ Com ajuda ☐ Não conseguiu | |

### Medições

| Medição | 1ª | 2ª | 3ª | Média | Meta |
|---|---|---|---|---|---|
| Abrir o app até a lista de vagas (4G) | | | | | < 5 s ☐ Sim ☐ Não |
| Pesquisa por texto até o resultado (4G) | | | | | < 5 s ☐ Sim ☐ Não |
| Toques da lista até a candidatura enviada | | — | — | — | ≤ 3 ☐ Sim ☐ Não |

### Problemas encontrados

| # | Tarefa | O que aconteceu | Como repetir | Gravidade (alta, média, baixa) |
|---|---|---|---|---|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |
| 5 | | | | |

### Comentários da pessoa

- Mais fácil:
- Mais difícil ou confuso:
- Usaria ou indicaria? O que mudaria?
