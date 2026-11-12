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

## Gate GitHub Windows pour le véritable staging signé (12 novembre 2026)

Le fichier `live-staging-gate.mjs` valide l'empreinte RFC 7638 de la clé privée déjà autorisée par la configuration Cloudflare avant de faire le moindre appel signé. Empreinte publique attendue : `3a98cf5776bf8b243f7c6a423c505015e45a7870d002512c38eed85b8e3a5dbb`. La clé publique est **publique**, la clé **privée ne doit jamais être commitée**.

Le job `live-staging-signed-wss` est **désactivé par défaut** et réservé à la PR #38 du dépôt d'origine. Trois conditions doivent être réunies : le label de PR `aimb-j1h-live-approved`, la variable Actions de dépôt `AIMB_J1H_LIVE_STAGE_READY=true`, et l'environnement GitHub `aimb-j1h-staging` avec secret d'environnement `AIMB_J1H_FIXTURE_PEM_B64` (contenu : Base64 de la clé privée PEM **existante** correspondant à l'empreinte publique). Configurer des reviewers obligatoires sur cet environnement avant d'y ajouter le secret. Ne jamais publier cette valeur dans une PR, un commentaire, un log ou un ticket.

La création/activation de cet environnement et l'ajout du secret nécessitent une intervention humaine dans les paramètres GitHub. Le GO verbal autorise le test, **mais il ne fournit pas la clé privée ni les protections GitHub**. Le CI automatique ne remplace pas cette configuration.

Après approbation de l'environnement, le job :
1. refait le contrôle byte-exact et les 78 tests hors ligne avant chargement de la clé ;
2. charge temporairement le secret dans un fichier du runner, effacé systématiquement ;
3. vérifie l'empreinte RSA, la santé du staging et la connexion WSS signée ;
4. lance **70 secondes réelles**, puis **180 secondes réelles** uniquement si la première session réussit ;
5. publie seulement des compteurs d'événements et des métriques synthétiques, pas les traces brutes ni les nonces.

Cette validation autorise seulement des polls et reçus de jobs **fixture** dans le staging isolé. Elle n'exécute aucune commande Windows réelle, n'écrit aucun fichier utilisateur, ne modifie ni la production V15, ni le déploiement Cloudflare, ni Vercel. Un résultat PASS ne prouve pas à lui seul la cause du poll +5,1 s ni les quotas 24 h D1/DO.
