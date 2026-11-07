# RULES.md — Ciclo de Produção do Ruminante Olvidado

Este documento define o ciclo de produção do blog **Ruminante Olvidado**.
Toda sessão de trabalho segue estas regras, sem exceção.

---

## 1. Ciclo de produção

Toda task segue, sempre, o mesmo ciclo fechado:

```
escrever/revisar artigo  →  git add  →  commit-autor.sh  →  commit  →  push
```

1. **Produção** — o artigo é escrito ou revisado em `src/content/blog/`.
2. **Stage** — `git add` do que foi produzido.
3. **Automatização** — `bash commit-autor.sh` classifica o artigo
   (novo, revisado ou deletado), monta a mensagem com os metadados
   e conclui sozinho o commit e o push. O fixer manual é a exceção,
   não a regra.
4. **Fim de task** — nenhum trabalho é considerado terminado sem
   **add, commit e push** feitos. Task sem push é task pendente.

---

## 2. Convenções de commit

A mensagem é gerada a partir do nome do artigo (sem extensão),
na língua do projeto, sempre uma destas três formas:

| Status | Formato |
|---|---|
| Artigo novo | `novo: nome_do_artigo` |
| Artigo revisado | `revisado: nome_do_artigo` |
| Artigo deletado | `deletado: nome_do_artigo` |

Vários artigos de status diferentes no mesmo stage geram um commit
com um bloco por status. Arquivos que não são `.md` não entram no
commit automático do script.

Identidade de commit fixa: `guilhermeferrao-cs <guilherminhoferrao@gmail.com>`,
remote `origin` em
`https://github.com/guilhermeferrao-cs/ruminante-olvidado.git`, branch `master`.

---

## 3. Princípios

### Coesão

Uma mudança, um propósito. O commit de um artigo carrega **apenas**
aquele artigo — e o filtro do `commit-autor.sh` garante que código,
imagens e afins não se misturam ao commit dos textos. Ciclos pequenos
e frequentes mantêm o histórico coeso e legível: cada commit conta,
por si só, uma história completa do tipo *novo*, *revisado* ou
*deletado*.

### Seguir exatamente o que foi dito

O combinado é executado como foi combinado — nem mais, nem menos.
O que define o commit e o push:

- **novo**: o artigo não existia e agora existe.
- **revisado**: o artigo existia e foi alterado.
- **deletado**: o artigo existia e foi removido.

O script não interpreta, não expande, não improvisa: lê os metadados
do `git diff --cached` e age exatamente sobre eles. Qualquer exceção
nova só existe quando registrada nesta regra primeiro, nunca na hora.

### Commit e push sempre

O par `commit + push` encerra toda task, obrigatoriamente:

- commit sem push → trabalho inacabado;
- push sem commit → impossível, não acontece;
- `--no-push` do script é ferramenta de teste, não de fluxo.

---

## 4. Resumo operacional

```bash
# fluxo padrão de qualquer task
git add .
bash commit-autor.sh      # commit "novo|revisado|deletado: nome" + push
```

Feito isso, a task está encerrada.
