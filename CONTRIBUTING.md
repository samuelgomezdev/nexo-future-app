# Como contribuir com o Nexo Future

> [!IMPORTANT]
> **A branch `main` é protegida.** Ninguém faz push direto nela. Toda mudança entra por um **Pull Request** e só é aceita depois da aprovação do Samuel (`@samuelgomezdev`).

## Passo a passo

1. **Atualize a sua `main` local**
   ```bash
   git checkout main
   git pull
   ```
2. **Crie uma branch para a tarefa**
   ```bash
   git checkout -b feature/nome-da-tarefa
   ```
   Use `feature/` para funcionalidade nova, `fix/` para correção e `docs/` para documentação.
3. **Faça os commits na sua branch**, seguindo as regras do [Guia do projeto](GUIA_DO_PROJETO.md) (TDD, mensagens em português, `flutter analyze` e `flutter test` sem erros).
4. **Envie a branch para o GitHub**
   ```bash
   git push -u origin feature/nome-da-tarefa
   ```
5. **Abra um Pull Request** da sua branch para a `main`. O GitHub pede a revisão do Samuel automaticamente.
6. **Aguarde a revisão.** Se vier um pedido de ajuste (*Request changes*), corrija na mesma branch e faça push de novo. O PR se atualiza sozinho.
7. **Merge.** Com a aprovação, o merge é liberado.

> [!WARNING]
> Se você enviar um commit novo depois da aprovação, ela é cancelada e o PR precisa ser aprovado de novo. Isso garante que nada entra na `main` sem ter sido revisado.

## O que cada um pode fazer

| Ação | Colaboradores | Samuel (admin) |
| --- | --- | --- |
| Criar branches e fazer push nelas | Sim | Sim |
| Abrir PRs, comentar, usar issues | Sim | Sim |
| Colocar código na `main` | Só com aprovação do Samuel | Sim |
| Apagar a `main` ou reescrever o histórico (force push) | Não | Só em emergência |
| Alterar as configurações do repositório | Não | Sim |

## Como a proteção está configurada

A proteção foi configurada em 11/11/2026 e tem duas partes:

- **[`.github/CODEOWNERS`](.github/CODEOWNERS)** define o Samuel como dono de todo o código. Por isso a aprovação de um PR tem que ser dele, e um colaborador não pode aprovar o PR do outro.
- **Ruleset `proteger-main`** (Settings → Rules → Rulesets), aplicado à branch padrão (`main`):
  - **Restrict deletions:** ninguém apaga a `main`.
  - **Block force pushes:** ninguém reescreve o histórico.
  - **Require a pull request before merging:** 1 aprovação, obrigatoriamente de um *Code Owner*. A aprovação cai se chegar commit novo, e o último push precisa ser aprovado por outra pessoa.
  - **Bypass list:** só o *Repository admin*.

Você pode ver a regra em [Rulesets](https://github.com/samuelgomezdev/nexo-future-app/rules).

## Dúvidas

Abra uma issue ou fale com o Samuel antes de começar algo grande, para combinar o caminho.
