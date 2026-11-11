# AI Machine Bridge — J1-H V0.7.4 / GitHub Actions

**Projet indépendant de TrueGround**. Les sources sont hébergées temporairement dans `engineering/aimb-j1h/src/` sur une **branche de PR en brouillon**. Ne pas connecter ces fichiers au build ou au déploiement de TrueGround.

## Validations automatisées

- SHA-256 exact du patch `patch-v074.diff` : `c5a3080d35793afe8f5b7e6d5b09d9e65e9103f6d857b07fadd1f681744b0a82`.
- SHA-256 exact **des huit modules V074** dans `source-integrity.test.mjs` ; code clé : superviseur `fbc0674f592880f8b3f91bbfe80cad7dd19f8a276fb9329bdd67a027aea9d136`, runner `c2d9662d388be15b31d8360999e07c4d2a44d5885d1a9599975938e56b7ca0c7`.
- Suite native **78 tests Node** dans `src/` sans accès réseau ni secret.
- Matrice Linux Ubuntu + Windows Server hébergé GitHub, Node.js 22 et 24.
- `.gitattributes` force LF pour préserver les empreintes sur Windows.
- Workflow en **lecture seule** GitHub : pas de Cloudflare, Vercel, tâches planifiées, fixture ou fusion automatique.

## Ce que la matrice GitHub ne prouve pas

La validation GitHub n'établit **ni** la session WSS 180 secondes sur le vrai PC Windows, **ni** la cause du poll +5,1 s. Elle n'établit pas non plus les quotas D1/DO de 24h ou la qualification humaine d'intégration. Le projet utilise une clé privée de fixture locale pour les requêtes signées ; **ne pas stocker cette clé dans ce dépôt public ni dans les logs GitHub Actions**.

## Exécution Windows réelle — uniquement sur le PC autorisé

Le fichier [windows-gate.ps1](./windows-gate.ps1) est un **script offline-first**. Il ne se lance jamais automatiquement via GitHub Actions et ne modifie ni tâche planifiée ni service Windows.

Depuis Codex sur le PC Windows, après revue humaine du script, le récupérer dans une copie locale GitHub, puis :

```powershell
# Par défaut : SHA + 78 tests, aucun accès réseau staging
powershell -NoProfile -File .\engineering\aimb-j1h\windows-gate.ps1

# Seulement après vérification de staging V7 et clé fixture privée locale :
powershell -NoProfile -File .\engineering\aimb-j1h\windows-gate.ps1 -RunStaging
```

Le paramètre `-RunStaging` exige `AIMB_J1H_PRIVATE_KEY_PATH` défini dans l'environnement local et produit les fichiers de preuve sous `%TEMP%/AIMB_J1H_V074_GATE_...`. Aucune clé privée n'est copiée dans le dépôt, ni affichée.

Si le PC est hors ligne ou si la clé locale manque, le résultat est **NO-GO pour le test réseau** : il ne doit pas être remplacé par un résultat GitHub Actions hébergé.

## Gates restants pour clôture humaine J1-H

1. CI offline 78/78 et SHA parfait sur les quatre combinaisons.
2. Sur PC Windows local : diagnostic V074 70 secondes, `STAGE_BOOT`, `supervisor_started`, `websocket_connected` ou erreur de connect explicitement bornée 12 secondes ; consigner et traiter toute erreur.
3. Si connexion réelle confirmée : session 180 secondes avec preuves de `poll_started/poll_finished`, distinction wakeup/fallback/retry, preuve de l'origine ou de l'indétermination du poll +5,1 s.
4. D1 staging, Durable Objects/quotas 24 heures et sécurité par revue indépendante, avant GO de production explicite.
5. PR en brouillon : **aucun merge sans approbation humaine**, et **aucun déploiement Vercel ou Cloudflare**.

[Référence du patch exact dans Notion](https://app.notion.com/p/41577c663362810c9d98faee098fb947).

**Roadmap initiale** : J1-H 76 %, J1-Q 55 %, J1-I 40 %, J1-J 15 %.
