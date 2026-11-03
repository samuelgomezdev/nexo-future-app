# Roteiro dos testes da v0.2.0 com usuários e aparelhos reais

Testes da Release [v0.2.0](https://github.com/samuelgomezdev/nexo-future-app/releases/tag/v0.2.0) (Etapa 2), em aparelhos reais e com o Firebase de produção. Use **uma cópia deste roteiro por aparelho** e anote tudo, inclusive o que funcionou.

## Antes de começar

- [ ] Explicar ao participante o objetivo do teste e pedir autorização para anotar e, se for o caso, gravar a tela (LGPD). Não gravar dados pessoais que apareçam no celular (notificações, contatos, fotos).
- [ ] Desinstalar a v0.1.0 ou qualquer outra versão do Nexo Future. A assinatura é diferente e o Android não instala uma por cima da outra.
- [ ] Baixar e instalar a v0.2.0 pelo [link direto](https://github.com/samuelgomezdev/nexo-future-app/releases/download/v0.2.0/app-release.apk), permitindo "Instalar apps desconhecidos" se o Android pedir.
- [ ] Ter à mão as contas de teste da **empresa** (Estaleiro Foz Azul), da **oficina sem alvará** (Oficina Escola Barra Sul) e da **oficina com alvará** (Oficina Escola Porto Novo). As senhas ficam com o responsável pelo teste e não vão para o repositório.
- [ ] **Espaçar os cadastros** entre os participantes: o plano gratuito do Firebase limita os e-mails de confirmação enviados em sequência. O app ainda não tem botão de reenviar o e-mail: se ele não chegar em alguns minutos (confira o spam), anotar no fluxo 3 e chamar o responsável pelo teste, sem criar outra conta com o mesmo e-mail.

## Aparelho

| Campo | Anotação |
|---|---|
| Participante (só as iniciais ou um código) | |
| Data e hora | |
| Modelo do aparelho | |
| Versão do Android | |
| Tamanho da fonte do sistema (padrão, grande...) | |
| Rede | ☐ 4G ☐ Wi-Fi ☐ Outra: |
| Intensidade do sinal (barras) | |

## Fluxos

Para cada fluxo, marque o resultado e anote o que o participante disse ou onde hesitou.

| # | Fluxo | Passos | Resultado esperado | Resultado | Observações |
|---|---|---|---|---|---|
| 1 | Visitante pesquisa vaga e vê o detalhe | Sem entrar, digitar "solda" na pesquisa, filtrar por uma área e abrir uma vaga | Lista com as vagas encontradas; o detalhe mostra a empresa, a cidade, a qualificação e os cursos vinculados | ☐ OK ☐ Falhou | |
| 2 | Visitante tenta se candidatar | No detalhe, tocar em "Candidatar-se" | O app pede para entrar ou criar a conta | ☐ OK ☐ Falhou | |
| 3 | Cadastro do jovem com confirmação do e-mail | "Criar conta" → Jovem; preencher nome, e-mail, senha, cidade e data de nascimento; aceitar a Política de Privacidade; confirmar o e-mail pelo link; entrar | O e-mail de confirmação chega; antes de confirmar, o app não deixa entrar; depois, entra e volta para a vaga | ☐ OK ☐ Falhou | Tempo até o e-mail chegar: |
| 4 | Candidatura e "Minhas candidaturas" | Na vaga, tocar em "Candidatar-se"; abrir "Minhas candidaturas" | Mensagem de candidatura enviada; o botão vira "Candidatura enviada"; a vaga aparece em "Minhas candidaturas" | ☐ OK ☐ Falhou | |
| 5 | Vaga lotada | Candidatar-se a uma vaga com 1 posição livre (ex.: Inspetor de Qualidade) | O detalhe e a lista passam a mostrar "Lotada" logo depois | ☐ OK ☐ Falhou | |
| 6 | Limite de 5 candidaturas | Candidatar-se a 5 vagas e tentar a 6ª | Aviso "Limite de candidaturas" com atalho para "Minhas candidaturas"; desistindo de uma, a 6ª é aceita | ☐ OK ☐ Falhou | |
| 7 | Bloqueio após 5 senhas erradas | Sair; tentar entrar 5 vezes com a senha errada | O login fica bloqueado por 15 minutos, com contagem regressiva | ☐ OK ☐ Falhou | |
| 8 | Empresa publica vaga | Entrar com a conta da empresa; "Nova vaga"; tocar em "Publicar" com os campos vazios; depois preencher e publicar | Os erros aparecem inteiros em cada campo (inclusive "Informe as posições."); a vaga publicada aparece no painel e na pesquisa como "Aguardando cursos" | ☐ OK ☐ Falhou | |
| 9 | Oficina sem alvará fica só com rascunho | Entrar com a oficina sem alvará; criar um curso para a vaga do fluxo 8 | O app avisa que falta o alvará e o curso fica salvo só como rascunho | ☐ OK ☐ Falhou | |
| 10 | Recrutador aprova o curso | Com a oficina com alvará, enviar um curso para a vaga do fluxo 8; entrar com a empresa e aprovar | O curso é vinculado à vaga, que passa a "Aceitando candidaturas" na pesquisa | ☐ OK ☐ Falhou | |

## Medições

### Tempo da pesquisa em 4G (RNF0001 e RNF0008, meta < 5 s)

Com o Wi-Fi desligado, abrir o app e medir com o cronômetro de outro celular, do toque no ícone até a lista de vagas aparecer. Depois, medir do fim da digitação na pesquisa até a lista filtrada aparecer.

| Medição | 1ª | 2ª | 3ª | Média | Meta < 5 s |
|---|---|---|---|---|---|
| Abrir o app até a lista de vagas | | | | | ☐ Sim ☐ Não |
| Pesquisa por texto até o resultado | | | | | ☐ Sim ☐ Não |
| Puxar a lista para atualizar | | | | | ☐ Sim ☐ Não |

### Toques até a candidatura (RNF0009, meta ≤ 3)

Com o jovem já logado, contar os toques da lista de vagas até a mensagem de candidatura enviada.

| Medição | Toques | Meta ≤ 3 |
|---|---|---|
| Lista → detalhe → candidatura enviada | | ☐ Sim ☐ Não |

## Problemas encontrados

| # | Fluxo | O que aconteceu | Passos para repetir | Gravidade (alta, média, baixa) | Print ou vídeo |
|---|---|---|---|---|---|
| 1 | | | | | |
| 2 | | | | | |
| 3 | | | | | |
| 4 | | | | | |
| 5 | | | | | |

## Comentários do participante

- O que achou mais fácil:
- O que achou mais difícil ou confuso:
- Sugestões:
