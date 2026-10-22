# NovaBank Core

Base de données d'une banque en ligne : PostgreSQL 18 sur une VM Ubuntu Server 26.04, sans Docker.
Projet du module « SQL avancé & administration PostgreSQL » (Bachelor 2).

La base rend impossibles les 3 problèmes du prototype :

- **Fuite d'emails** : 4 profils avec le minimum de droits, vues qui masquent les données, l'application n'a aucun droit sur les tables.
- **Solde négatif** : `CHECK balance >= 0`, trigger de solde, procédure `sp_transfer` en une seule transaction avec verrous dans l'ordre.
- **Historique lent** : index `(account_id, created_at DESC)`, 22 ms → 0,1 ms sur 1 000 000 d'écritures.

## Déclaration d'usage de l'IA

Projet réalisé avec l'aide de **Claude (Anthropic)** : scripts Bash, fichiers SQL, tests, création de la VM et exécution des commandes.
Les commentaires des fichiers expliquent le « pourquoi » de chaque choix.

## Tout refaire

La VM : Ubuntu Server, deux cartes réseau (NAT + host-only 192.168.31.10), SSH par clé, utilisateur `nova`.
Depuis le dossier du dépôt sur la VM :

```bash
./run_all.sh
```

Ce script unique enchaîne :

1. `scripts/01_install_postgres.sh` : installe PostgreSQL, règle `pg_hba.conf` et le pare-feu `ufw` ;
2. `scripts/reset_all.sh` : supprime la base et les rôles (demande confirmation), puis rejoue `sql/00_` à `sql/07_` ;
3. `scripts/run_tests.sh` : 80 tests SQL, test de concurrence, connexions réelles par profil ;
4. `scripts/backup_restore.sh` : `pg_dump -Fc`, restauration dans une base temporaire, comparaison des `count(*)`.

`./run_all.sh --yes` ne demande pas de confirmation. Les mots de passe PostgreSQL sont générés au hasard dans `~/.pgpass` : il n'y a aucun mot de passe dans Git.

## Fichiers

| Dossier / fichier | Contenu |
|---|---|
| `run_all.sh` | script unique qui refait tout |
| `scripts/` | installation, reconstruction (`reset_all.sh`), tests, sauvegarde |
| `sql/00_` à `07_` | rôles et base, tables, données, droits, vues, index, triggers, procédures |
| `tests/` | `run_tests.sql` (80 tests), `concurrency.sh`, `login_audit.sh` |
| `results/` | sortie réelle de chaque étape |
| `screenshots/` | captures de chaque étape |
| `NovaBank_Rapport.docx` | document avec les captures |

## Tables

`core.customers` 1 → N `core.accounts` 1 → N `core.transactions` N ← `core.transfers` (un virement = 2 écritures), puis `core.fraud_alerts` et `audit.audit_log`.

## Droits

| Compte | Droits | Connexion |
|---|---|---|
| `u_analyste` | lit les écritures et des vues sans IBAN ni email | réseau 192.168.31.0/24 |
| `u_support` | lit des vues masquées, change le statut d'un compte (jamais `CLOSED`) | réseau 192.168.31.0/24 |
| `u_app` | aucun droit sur les tables, appelle seulement les 3 procédures | 127.0.0.1 |
| `u_auditeur` | lecture seule : audit, alertes, écritures | réseau 192.168.31.0/24 |
| `bank_owner` | propriétaire de la base | 127.0.0.1 |

Tout le reste est refusé par `pg_hba.conf`.

## Bonus

Aucun bonus n'a été réalisé.
