# AIMB J1-H — Validation isolée

> **Hors périmètre TrueGround.** Cette zone est réservée aux tests de préproduction de AI Machine Bridge. Ne pas la relier au build, aux dépendances ni au déploiement de TrueGround.

## État

- Patch de référence V074 présent dans `patch-v074.diff`.
- SHA-256 du patch : `c5a3080d35793afe8f5b7e6d5b09d9e65e9103f6d857b07fadd1f681744b0a82`.
- Vérification Windows et Linux via GitHub Actions : **contrôle du patch uniquement**, sans secrets.
- **Non encore inclus** : les sources V073, les sources finales V074, les 78 tests E2E, l'exécution réseau Cloudflare et l'exécution sur Windows personnel. La CI actuelle ne doit jamais être présentée comme preuve d'un E2E.

## Garanties des fichiers à importer pour une deuxième PR/commit sur cette branche

| Fichier | SHA-256 de référence |
|---|---|
| V073 `supervisor-v07.mjs` | `a77b65e8ab5d42f1cd642a9c632ae74fe8b019c7ac41a4c3acf2e3b7d2e4b29f` |
| V073 `e2e-windows-runner.mjs` | `b95c1aba31e41b6a9eae6eb06d7eb2357f49f0b55b09db4f52f1d1206a443b93` |
| V074 `supervisor-v07.mjs` | `fbc0674f592880f8b3f91bbfe80cad7dd19f8a276fb9329bdd67a027aea9d136` |
| V074 `e2e-windows-runner.mjs` | `c2d9662d388be15b31d8360999e07c4d2a44d5885d1a9599975938e56b7ca0c7` |

La référence complète du patch et du test de démarrage est documentée dans [Notion](https://app.notion.com/p/41577c663362810c9d98faee098fb947). Avant d'ajouter des sources à **ce dépôt public**, effectuer une revue de confidentialité et vérifier qu'elles ne contiennent ni clé privée, ni nonce, ni identifiant sensible. Aucun worker en production ou tâche Windows ne doit être activé par cette CI.

## Prochaines étapes

1. Faire passer la validation de référence sur Linux et Windows hébergés GitHub, via la PR.
2. Ajouter les sources et tests revus afin de faire tourner les 78 tests Node dans une étape CI autonome.
3. Conserver un gate Windows physique distinct pour WebSocket sur le vrai PC, suivi de D1/DO 24h et d'une revue indépendante.
4. Ne jamais fusionner, déclencher de déploiement ni modifier Cloudflare sans GO spécifique.

**Roadmap (état de référence)** : J1-H 76 %, J1-Q 55 %, J1-I 40 %, J1-J 15 %.
