# Nexo Future: plano do app MVP (HOW VIII, Etapa 1)

> Briefing para executar no Claude Code com o VS Code integrado.
> **Prazo da Etapa 1: domingo, 25/10/2026, às 23h59 (horário do servidor do EAD).** Enviem com folga.
> Repositório sugerido: `samuelgomezdev/nexo-future-app` (público).

---

## 1. Por que o app precisa existir já na Etapa 1

Resumo das webconferências de 05/10 e 19/10 (prof. Ewerton):

- A Etapa 1 cobra o **planejamento e o desenvolvimento** do projeto orientado a testes. O app não precisa estar completo, mas "o que vocês entregarem tem que ser em nível de funcionalidades já completas" (MVP).
- **Código no GitHub e APK para download**, de preferência num release do próprio GitHub (um link só).
- **Vídeo de até 3 min:** mostrar o produto, o que ele faz, como está o desenvolvimento e os testes. Incluir um trecho curto do ciclo TDD. Não é para ler o relatório.
- **Testes:** escolher 2 tipos (unitário e integração bastam) e descrevê-los no relatório com imagens, em linguagem para leigo.
- **Seção 4.1.6:** print de cada ferramenta usada (VS Code, GitHub, Actions, Trello) e o link do repositório.

---

## 2. Escopo do MVP da Etapa 1 (pequeno de propósito)

Perfil fixo de demonstração: **aluno "Jovem Demo"**. Não há login nem Firebase nesta etapa; os dados ficam em memória, carregados de um seed local. Login, cadastros e Firebase ficam para a Etapa 2.

| # | Funcionalidade | Requisitos do HOW IV | Pronto quando… |
|---|----------------|----------------------|----------------|
| F1 | Lista e pesquisa de vagas, com filtro por texto e área, em páginas de 15 | RF0006, RNF0002, RNF0003 | A busca filtra e a rolagem carrega a próxima página |
| F2 | Detalhe da vaga: empresa, qualificação exigida, cursos vinculados (oficinas) e situação | RF0004, RF0015, RF0007 | Mostra os cursos aprovados e a situação da vaga |
| F3 | Candidatar-se à vaga | RF0008, RN0005, RF0007 | Só aceita vaga "aguardando ingresso" e no máximo 5 candidaturas por aluno |
| F4 | Minhas candidaturas, com opção de desistir | RF0017 | Desistir libera uma vaga do limite |

**Regras de negócio que viram teste (o coração do TDD):**

- **RN0005:** cada aluno pode ter no máximo **5** candidaturas ativas. A 6ª é recusada com uma mensagem clara.
- **RN0006:** cada vaga aceita no máximo **5** cursos preferenciais vinculados.
- **RF0007 (situação):** a vaga só aceita candidatura quando está em `aguardandoIngresso`, ou seja, quando o recrutador já aprovou pelo menos um curso. Nas situações `aberta` e `lotada`, recusa.
- **RNF0002:** a pesquisa devolve páginas de **15** vagas.
- **RNF0009:** da tela inicial até concluir a candidatura em **até 3 toques** (lista → vaga → "Candidatar-se").

**Fora do MVP da Etapa 1:** login, cadastros de empresa/oficina/aluno, validação por e-mail, alvará (RN0003), avaliação de alunos, aptidão, conclusão de curso/vaga, backend.

---

## 3. Stack e estrutura

- **Flutter (canal stable) + Dart**, um único código para Android e iOS. O APK é gerado para Android.
- **Testes:** `flutter_test` (unitários e de widget) e `integration_test` (fluxo completo). `mocktail` só se precisar.
- **Estado:** `ChangeNotifier` + `provider` (simples de explicar no relatório como MVVM).
- **CI/CD:** GitHub Actions roda `flutter analyze` e `flutter test` a cada push; numa tag `v*`, gera o APK e publica no Release.

```
lib/
  main.dart
  domain/
    models/vaga.dart          # Vaga, SituacaoVaga, Curso, Candidatura
    regras/
      limite_candidaturas.dart  # RN0005
      vinculo_cursos.dart       # RN0006
    erros.dart                  # exceções de regra (LimiteCandidaturasAtingido, VagaNaoDisponivel...)
  data/
    seed_vagas.dart           # ~40 vagas fictícias da região da AMFRI
    vaga_repository.dart      # pesquisar(texto, area, pagina) -> 15 por página
    candidatura_repository.dart
  ui/
    viewmodels/               # VagasViewModel, CandidaturasViewModel
    screens/                  # lista_vagas, detalhe_vaga, minhas_candidaturas
test/
  domain/                     # unitários das regras
  data/                       # paginação e filtro
  ui/                         # testes de widget (mensagem de limite etc.)
integration_test/
  fluxo_candidatura_test.dart # RNF0009 + caminho feliz
docs/
  evidencias/                 # prints do ciclo TDD, testes e cobertura
.github/workflows/ci.yml
```

**Dados do seed:** use empresas e oficinas **fictícias**, sem nomes de empresas reais. Exemplos: "Estaleiro Foz Azul" (laminador, pintor naval, marceneiro náutico), "TransVale Logística" (motorista CNH D, mecânico diesel), "MetalSul Usinagem" (soldador, inspetor de qualidade), e oficinas como "Oficina Escola Mãos do Porto" e "Centro Técnico Itajaí". Cidades: Itajaí, Balneário Camboriú, Navegantes, Itapema, Camboriú.

---

## 4. Ordem de execução (cada passo é um ciclo TDD com commits)

Padrão de commits, que vira evidência para o relatório e para o vídeo:

1. `test: <regra> (vermelho)`: o teste escrito e **falhando**
2. `feat: <regra> (verde)`: o código mínimo para passar
3. `refactor: <o que melhorou>`: só quando houver o que melhorar

> **Importante:** não adicionar o Claude como coautor em nenhum commit, PR ou descrição (sem `Co-Authored-By`, sem "Generated with Claude Code", sem link de sessão).

| Passo | O que fazer | Evidência para guardar |
|-------|-------------|------------------------|
| 0 | `flutter create nexo_future_app --org br.univali.nexofuture --platforms android,ios`, depois o repo no GitHub e o primeiro push | Print do repositório |
| 1 | **CI primeiro:** `.github/workflows/ci.yml` (seção 6) rodando `flutter test` | Print do Actions verde |
| 2 | **TDD RN0005 (teste escolhido nº 1):** limite de 5 candidaturas e desistir libera | **Print do teste vermelho e depois verde** no terminal do VS Code |
| 3 | TDD da situação da vaga: só `aguardandoIngresso` aceita candidatura | Print |
| 4 | TDD RN0006: no máximo 5 cursos por vaga | Print |
| 5 | TDD RNF0002: pesquisa em páginas de 15 e filtro por texto/área | Print |
| 6 | Telas F1 → F4 com viewmodels, ligadas aos repositórios | Prints das telas no emulador |
| 7 | Widget test: no limite, o app mostra a mensagem e o botão "Minhas candidaturas" (UC0007 E1) | Print |
| 8 | **Integration test (teste escolhido nº 2):** abrir app → tocar numa vaga → "Candidatar-se" → confirmação, em até 3 toques | **Print do teste rodando no emulador** |
| 9 | Cobertura: `flutter test --coverage`, com meta de ≥ 80% em `lib/domain` | Print do resumo (lcov ou extensão Coverage Gutters) |
| 10 | Tag `v0.1.0` → Actions gera o APK e publica o Release | Print do Release com o `.apk` |
| 11 | README com descrição, como rodar, como testar, link do APK e prints | – |

### Casos de teste mínimos

**`test/domain/limite_candidaturas_test.dart` (RN0005):**
- aluno com 0 candidaturas consegue se candidatar;
- aluno com 4 consegue a 5ª;
- aluno com 5 **não** consegue a 6ª (lança `LimiteCandidaturasAtingido`);
- aluno com 5 desiste de uma e volta a conseguir;
- candidatar-se duas vezes na mesma vaga é recusado.

**`test/domain/situacao_vaga_test.dart` (RF0007):**
- vaga `aguardandoIngresso` aceita;
- vaga `aberta`, sem curso aprovado, recusa (`VagaNaoDisponivel`);
- vaga `lotada` recusa.

**`test/domain/vinculo_cursos_test.dart` (RN0006):**
- vincula até 5 cursos;
- o 6º é recusado;
- o mesmo curso duas vezes é recusado.

**`test/data/vaga_repository_test.dart` (RNF0002):**
- página 1 com 15 itens, página 2 com o restante;
- filtro por texto ignora maiúsculas e acentos ("solda" encontra "Soldador");
- filtro por área.

**`integration_test/fluxo_candidatura_test.dart` (RNF0009):**
- abre o app, toca na primeira vaga disponível, toca em "Candidatar-se" e vê "Candidatura enviada";
- conta 3 toques.

---

## 5. Os 2 testes para o relatório (orientação do professor)

Escrever para leigo, com imagens. Sugestão:

1. **Teste unitário: "ninguém se candidata a mais de 5 vagas" (RN0005)**
   - A regra em uma frase: *para o jovem focar na formação, o app deixa ele concorrer a no máximo 5 vagas ao mesmo tempo.*
   - O que o teste faz, sem termos técnicos: *simula um jovem que já está em 5 vagas e tenta entrar na 6ª; o certo é o app dizer "não".*
   - Imagens: (a) o teste **vermelho**, antes do código; (b) o teste **verde**, depois do código; (c) a tela do app mostrando a mensagem de limite.
2. **Teste de integração: "candidatar-se em até 3 toques" (RNF0009)**
   - A regra: *o jovem precisa conseguir se candidatar rápido, sem se perder no app.*
   - O teste: *um "robô" abre o app no emulador, toca na vaga e depois em "Candidatar-se", e confere a confirmação.*
   - Imagens: as três telas do fluxo e o resultado do teste.

---

## 6. GitHub Actions: `.github/workflows/ci.yml`

```yaml
name: CI

on:
  push:
    branches: [main]
    tags: ['v*']
  pull_request:

permissions:
  contents: write

jobs:
  testes:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage

  apk:
    if: startsWith(github.ref, 'refs/tags/v')
    needs: testes
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: softprops/action-gh-release@v2
        with:
          files: build/app/outputs/flutter-apk/app-release.apk
```

O template do Flutter assina o build de release com a chave de debug. Para a disciplina isso basta, porque o APK instala normalmente. Para publicar o release: `git tag v0.1.0 && git push origin v0.1.0`.

---

## 7. O que levar do repositório para o relatório (Etapa 1)

- **4.1.5:** os prints do ciclo TDD (vermelho → verde) do RN0005 e o link do Trello. O professor aceita Kanban ou texto descritivo.
- **4.1.6:** prints do VS Code com o projeto aberto, do GitHub (página do repositório), do Actions verde e do Trello, mais o **link do repositório** e o **link do Release com o APK**.
- **4.1.7:** a cobertura alcançada.
- **7.1:** link do vídeo no YouTube (Não listado).
- **Conclusão:** uma frase com o que já funciona no MVP.

Ao terminar, mande para o Claude (no chat do projeto) os links do repositório e do release, e os prints em `docs/evidencias/`. Ele atualiza o relatório da Etapa 1.

---

## 8. Roteiro do vídeo (até 3:00, todos falam)

| Tempo | Quem | O que mostrar |
|-------|------|---------------|
| 0:00–0:15 | Integrante 1 | Apresentação do grupo e do Nexo Future em uma frase |
| 0:15–0:45 | Integrante 2 | O problema: falta de mão de obra qualificada × jovens sem formação (entrevistas e números do questionário) |
| 0:45–1:40 | Integrante 3 | **App rodando no celular ou emulador:** pesquisar vaga → abrir → ver cursos vinculados → candidatar-se → minhas candidaturas → tentar a 6ª e ver a mensagem |
| 1:40–2:30 | Integrante 4 | **TDD na prática:** o teste do limite vermelho, o código, o teste verde; depois o Actions verde no GitHub e o release com o APK |
| 2:30–3:00 | Integrante 1 | Próximos passos (Etapa 2: login, cadastros, Firebase, validação com usuários) e link do repositório |

Gravar com OBS ou a gravação de tela do Windows (Win + Alt + R). Publicar no YouTube como **Não listado** e testar o link numa janela anônima.

---

## 9. Checklist final antes de enviar

- [ ] Repositório público com README e o código do MVP
- [ ] Actions verde (print)
- [ ] Release `v0.1.0` com `app-release.apk` (link testado)
- [ ] Prints do TDD (vermelho/verde) dos 2 testes escolhidos
- [ ] Relatório atualizado com os links e prints (4.1.5, 4.1.6, 4.1.7, 7.1)
- [ ] Vídeo ≤ 3:00 no YouTube como Não listado; link no relatório e no campo do envio
- [ ] Questionário com pelo menos 20 respostas e resultados na Prova de Conceito
- [ ] PDF único enviado na atividade avaliativa, com print do comprovante
