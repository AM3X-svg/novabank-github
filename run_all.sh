#!/usr/bin/env bash
# Script unique : refait tout le projet NovaBank, de l'installation aux tests.
#   1. installe et sécurise PostgreSQL   (scripts/01_install_postgres.sh)
#   2. supprime et recrée la base        (scripts/reset_all.sh : tables, données, droits, vues, index, triggers, procédures)
#   3. lance les tests                   (scripts/run_tests.sh)
#   4. sauvegarde et restaure            (scripts/backup_restore.sh)
# Usage : ./run_all.sh [--yes]     (--yes = pas de demande de confirmation)
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

echo "=== 1/4 Installation de PostgreSQL ==="
sudo ./scripts/01_install_postgres.sh

echo; echo "=== 2/4 Reconstruction de la base ==="
./scripts/reset_all.sh "${1:-}"

echo; echo "=== 3/4 Tests ==="
./scripts/run_tests.sh

echo; echo "=== 4/4 Sauvegarde et restauration ==="
./scripts/backup_restore.sh

echo; echo "=== TERMINÉ : tout a été refait et vérifié ==="
