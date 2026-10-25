# Guia do projeto – nexo-future-app

App mobile em Flutter do projeto **Nexo Future** (Hands-On Work VIII, ADS Univali). O app conecta jovens a cursos profissionalizantes ligados a vagas reais de empresas da região da AMFRI (Itajaí/SC). O plano completo está em `docs/PLANO_APP_MVP.md`.

## Regras do projeto

- **Nunca** adicionar o Claude como coautor ou contribuidor: sem `Co-Authored-By: Claude`, sem "Generated with Claude Code" e sem link de sessão em commits, PRs ou descrições. Vale para todo commit.
- **TDD obrigatório:** escrever o teste antes do código. Cada regra segue o ciclo:
  1. `test: <regra> (vermelho)`: o teste falhando, com o commit feito antes do código
  2. `feat: <regra> (verde)`: o código mínimo para passar
  3. `refactor: <descrição>`: só se houver melhoria real
- Antes de cada commit: `flutter analyze` e `flutter test` sem erros, exceto no commit "vermelho".
- Mensagens de commit, nomes de testes, textos da interface e comentários em **português do Brasil**.
- Dados fictícios: não usar nomes de empresas ou pessoas reais no seed.

## Stack

- Flutter stable, Dart com null-safety
- Estado: `provider` + `ChangeNotifier` (camadas `domain` / `data` / `ui`, no estilo MVVM)
- Testes: `flutter_test`, `integration_test`; `mocktail` só se precisar
- CI: `.github/workflows/ci.yml` (analyze + test a cada push; APK no Release quando houver tag `v*`)

## Regras de negócio (do HOW IV)

- **RN0005:** no máximo 5 candidaturas ativas por aluno; desistir libera uma vaga do limite.
- **RN0006:** no máximo 5 cursos preferenciais por vaga.
- **RF0007:** a vaga só aceita candidatura na situação `aguardandoIngresso`.
- **RNF0002:** a pesquisa devolve páginas de 15 vagas.
- **RNF0009:** candidatura em até 3 toques a partir da tela inicial.

## Comandos

```bash
flutter pub get
flutter analyze
flutter test                      # unitários e de widget
flutter test --coverage           # cobertura em coverage/lcov.info
flutter test integration_test     # precisa de emulador ou dispositivo
flutter build apk --release
```

## Evidências

Guardar em `docs/evidencias/` os prints do ciclo vermelho → verde, do Actions verde, da cobertura e do Release com o APK. Eles vão para o relatório e para o vídeo.
