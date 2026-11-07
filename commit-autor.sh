#!/usr/bin/env bash
#
# commit-autor.sh — cria o commit baseado nos arquivos em stage e faz o push.
#
# Fluxo de uso:
#   1. git add <arquivos>
#   2. ./commit-autor.sh            (ou bash commit-autor.sh)
#
# O script lê o "git diff --cached", e para cada artigo .md em stage
# descobre se é novo (A), revisado (M) ou deletado (D), monta a mensagem
# no formato "novo: nome_do_artigo", "revisado: nome_do_artigo",
# "deletado: nome_do_artigo" e faz o push.
# Outros arquivos em stage (código, imagens etc.) são ignorados pelo
# script e permanecem em stage.
#
# Opções:
#   -n, --no-push   só faz o commit, não faz o push
#   -h, --help      mostra esta ajuda

set -euo pipefail

DO_PUSH=1
case "${1:-}" in
  -n|--no-push) DO_PUSH=0 ;;
  -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
esac

# ---------------------------------------------------------------- git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERRO: este diretório não é um repositório git." >&2
  exit 1
fi

# ---------------------------------------------------------------- stage
if [ -z "$(git diff --cached --name-only)" ]; then
  echo "Nada em stage. Rode 'git add <arquivos>' antes de executar este script." >&2
  exit 1
fi

# ---------------------------------------------------------------- metadados
# -z => campos separados por NUL ("A\0caminho\0"); funciona com espaços
#       e acentos no nome do arquivo.
declare -A STATUS_OF NAME_OF
NOVOS=(); REVISADOS=(); DELETADOS=()

echo ""
echo "=== Metadados dos arquivos em stage ==="
status=""
while IFS= read -r -d '' campo; do
  if [ -z "$status" ]; then
    status="$campo"                # ex.: A, M, D
    continue
  fi
  path="$campo"                    # caminho do arquivo

  # só artigos .md (ignora outro que esteja em stage; ele fica em stage,
  # para commitar use git commit manualmente)
  if [[ "${path,,}" != *.md ]]; then
    printf '  %-8s %-30s [ignorado: não é .md]\n' "($status)" "$path"
    status=""
    continue
  fi

  # nome do artigo: nome do arquivo, sem extensão
  nome="$(basename "$path")"
  nome="${nome%.*}"

  changes="$(git diff --cached --numstat -- "$path" | awk '{print "+"$1" -"$2}')"
  printf '  %-8s %-30s [%s] %s\n' "($status)" "$path" "${changes:-binário}" "$nome"

  STATUS_OF["$path"]="$status"
  case "$status" in
    A) NOVOS+=("$nome") ;;
    M) REVISADOS+=("$nome") ;;
    D) DELETADOS+=("$nome") ;;
  esac
  status=""
done < <(git diff --cached --name-status -z --no-renames)

if [ ${#NOVOS[@]} -eq 0 ] && [ ${#REVISADOS[@]} -eq 0 ] && [ ${#DELETADOS[@]} -eq 0 ]; then
  echo "Nenhum arquivo em stage identificado." >&2
  exit 1
fi

# ---------------------------------------------------------------- mensagem
join() { local IFS=', '; echo "$*"; }

MSG=""
[ ${#NOVOS[@]} -gt 0 ]      && MSG+="novo: $(join "${NOVOS[@]}")"
[ ${#REVISADOS[@]} -gt 0 ]  && MSG+="${MSG:+$'\n\n'}revisado: $(join "${REVISADOS[@]}")"
[ ${#DELETADOS[@]} -gt 0 ]  && MSG+="${MSG:+$'\n\n'}deletado: $(join "${DELETADOS[@]}")"

# ---------------------------------------------------------------- commit
echo ""
echo "Mensagem do commit:"
echo "----------------------------------------"
echo "$MSG"
echo "----------------------------------------"

git commit -m "$MSG"

# ---------------------------------------------------------------- push
if [ "$DO_PUSH" -eq 1 ]; then
  # Se a branch nunca foi enviada, cria a upstream automaticamente.
  if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
    git push
  else
    branch="$(git rev-parse --abbrev-ref HEAD)"
    echo "Branch '$branch' sem upstream — configurando com origin."
    git push -u origin "$branch"
  fi
  echo ""
  echo "✔ Commit e push concluídos."
else
  echo ""
  echo "✔ Commit concluído (push ignorado: --no-push)."
fi
