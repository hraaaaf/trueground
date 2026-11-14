# AI Machine Bridge — J4 / Gate A : audit de sécurité et contrat du micro-updater

**Date :** 2026-11-14 · **État :** DESIGN / AUDIT UNIQUEMENT · **Décision :** **NO-GO pour toute activation distante ou mutation des agents Windows**.

> Cette proposition complète la roadmap V2 CANONIQUE dans Notion. Elle ne crée pas de nouveau jalon ni de point d'effort validé. **Pas de code actif, de déploiement, de merge, de nouveau plugin ou de permission Windows accordée par ce document.**

## 1. Fondations et provenance

- Projet et référence : [roadmap V2 AI Machine Bridge](https://app.notion.com/p/41377c6633628166bebe-f6ca16a23102), jalon **J4 Mode DEV exploitable (0/5 PE validé)** ; jalons J1 (4/5) et J2 (2/4) restent distincts.
- P0 existant : [PR #43](https://github.com/hraaaaf/trueground/pull/43) DRAFT, commit exact `86b8361b27dfdc801e82d458ff0728d968ec866b`. CI [#43585477564](https://github.com/hraaaaf/trueground/actions/runs/43585477564) 6/6, tests hors ligne, Windows PowerShell 5.1/7 et Node 22/24.
- Installation P0 **inerte**, rapport Codex, [ODM #44](https://github.com/hraaaaf/trueground/issues/44) clôturé **sur le seul périmètre de copie**. Dossier Windows `%USERPROFILE%\AI_Machine_Bridge_SelfRepair_P0` : `cadence-core.mjs`, `repair-cli.mjs`, `README.md` — aucun MCP ajouté, pas d'auto-démarrage.
- Code audité (lecture de la PR au SHA ci-dessus) : `engineering/aimb-j1h/self-repair/{cadence-core.mjs,repair-cli.mjs,cadence-core.test.mjs,README.md}`.
- Plugin principal : 17 outils existants, notamment état PC, quelques lectures allowlistées, `prepare_workspace_create` / `commit_workspace_create` pour un **nouveau** fichier. **Aucun `commit_agent_patch`, `restart_bridge_task`, `rollback_agent_patch` n'est aujourd'hui exposé**.

## 2. Constats du code P0 et risques de production

| ID | Priorité | Constat prouvé dans le code | Risque / exigence avant activation |
| --- | --- | --- | --- |
| SEC-01 | **BLOQUANT** | `applyCadence` et `rollbackCadence` comparent `approvedPlanId` et `planId` (empreinte du plan), sans preuve d'identité ni approbation signée. README l'admet. | Un planId est connaissable par un lecteur ; **ne jamais l'utiliser comme autorisation distante**. Ajouter jeton propriétaire à usage unique, signé, lié au device, action et plan. |
| SEC-02 | **BLOQUANT** | `targetFile` fait `lstat`, puis `safeRead` fait `readFile` par chemin ; `atomicReplace` fait `rename` ultérieurement. Les liens sont refusés seulement aux moments vérifiés. | **TOCTOU / swap de reparse point, junction, ACL, symlink et fichiers** entre vérifications. Ouvrir/contrôler l'objet via handle et identité de fichier Windows, bloquer les reparse points sur toutes composantes et revérifier immédiatement avant mutation. Faire revue hostile Windows réelle. |
| SEC-03 | **BLOQUANT** | `makeStateRoot` crée des dossiers récursivement avec mode 0700 / les backups mode 0600 ; ces modes POSIX ne démontrent pas des ACL Windows sécurisées. | Exiger propriétaire/SID, DACL non héritée, protections des dossiers, service identity dédiée, pas de stockage privilégié dans arbre utilisateur modifiable. |
| SEC-04 | **BLOQUANT** | `applyCadence` remplace le fichier puis écrit le reçu ; `rollbackCadence` dépend de ce reçu et du backup. Verrou `.lock` purement local non récupéré après crash. | Interruption entre replace et receipt => état modifié sans reçu, verrou orphelin possible. Protocole transactionnel : prepare durable, journal write-ahead, point de commit, récupération déterministe, intervention humaine si preuve insuffisante. |
| SEC-05 | **BLOQUANT** | `repair-cli.mjs` expose des actions locales `apply`/`rollback` mais aucune authentification de provenance ni signature d'enveloppe. | Micro-updater **distinct, non auto-modifiable et signé**, liaison à l'identité du PC, aucun chemin ou script arbitraire, commande non exposée via Worker sans validation locale indépendante. |
| SEC-06 | **HAUT** | Contrôle SHA des fichiers, allowlist des noms, transitions 4→15/15→60/8→60, refus de plusieurs `Start-Sleep`, tests synthétiques. | Ces protections sont utiles **mais ne prouvent pas** que le code PowerShell entier est sain. Ajouter manifeste de versions approuvées, signature du paquet, policy verrouillée et revue du diff complet. |
| SEC-07 | **HAUT** | Aucune action Task Scheduler ni contrôle de process dans P0. Le code peut modifier un fichier sans agir sur le script déjà chargé par PowerShell. | `restart` éventuel doit être séparé, allowlist exact task, autorisation distincte, capture PID/XML avant/après, état de santé + rollback, jamais start/stop implicite. |
| SEC-08 | **HAUT** | Tests P0 synthétiques couvrent 12 scénarios Linux/Windows ; aucun test réel de crash, d'ACL Windows hostile, de substitution junction ou de concurrency service. | Requérir suite de tests spécifiques Win32 et preuve de mise en défaut sûre avant tout MCP d'écriture. |

**Point de contexte :** les scripts Windows actuels sont déjà aux cadences rapportées **Commands 15 s, Files 60 s, Workspace 60 s**. Le P0 n'accepte pas de transition `60→...` pour Files/Workspace. **Ne pas dégrader volontairement ces agents pour créer un test d'application** : tout E2E initial d'écriture se fait sur des **fixtures isolées**, jamais sur les scripts actifs.

## 3. Architecture cible — frontières de confiance

```text
ChatGPT / plugin AI Machine Bridge PRINCIPAL
  |
  | OAuth utilisateur Auth0, read ou prepare uniquement par défaut
  v
Cloudflare Worker MCP (resource server)
  |  - validation issuer, audience, scope, subject, expiration, resource
  |  - refus token passthrough, rate limit, audit de chaque intention
  |  - aucun shell / aucune écriture Windows directe
  v
File/Job queue bornée (D1/DO, idempotence, TTL et ACK)
  | - enveloppe de commande SIGNÉE, device-bound
  | - approbation explicite du propriétaire depuis un canal de confiance
  v
Windows micro-updater SÉPARÉ (service non auto-modifiable)
  | - vérifie approbation/signatures/nonce/expiration + ACL/handle
  | - prepare/validate -> backup durable -> apply -> verify -> receipt
  | - restart strictement séparé et optionnel, après un SECOND gate
  v
Trois scripts allowlistés seulement ou fixtures de tests isolées
```

Les logs d'outil, contenus de fichiers, messages de la queue et réponses du modèle sont **données non fiables** : aucun d'eux ne peut constituer une autorisation d'application. Le moteur de patch doit rester incapable de se modifier lui-même ou d'augmenter ses droits. Les clés privées ne figurent jamais dans le dépôt public `hraaaaf/trueground`, ni dans le plugin, ni dans Notion ou les artefacts CI.

### Droits séparés (refus par défaut)

| Scope candidat (à valider Auth0) | Actions | Écriture autorisée |
| --- | --- | --- |
| `bridge.health.read` | `get_bridge_health`, métriques bornées et états | Aucune |
| `bridge.source.read` | `get_script_fingerprint`, `get_agent_logs` expurgés | Aucune |
| `bridge.patch.prepare` | `prepare_agent_patch`, `validate_agent_patch` en staging | Plan/rapport seulement |
| `bridge.patch.apply` | `commit_agent_patch` **après approbation signée** | Fixture au début, jamais production sans autre GO |
| `bridge.task.restart` | `restart_bridge_task` sur tâche exacte | Action séparée, non autorisée en Gate A |
| `bridge.patch.rollback` | `rollback_agent_patch` avec reçu/approval | Fixture au début, jamais production sans autre GO |

Un accès `read` ne peut pas acquérir `prepare` ou `apply` par défaut. Si les scopes ne sont pas disponibles/valides, retour 403, sans side effect. Auth0 installé doit être **réutilisé**, pas recréé.

### Contrat d'opération v1 (spécification, AUCUNE API exposée)

Toute préparation et approbation portent au minimum ces champs, validés **côté Worker ET localement** :

```json
{
  "version": "aimb-patch-v1",
  "operation_id": "UUIDv4",
  "device_id": "id_pre-enregistre",
  "target": "commands|files|workspace",
  "action": "prepare|apply|verify|restart|rollback",
  "before_sha256": "64_hex",
  "after_sha256": "64_hex",
  "plan_sha256": "64_hex",
  "artifact_sha256": "64_hex",
  "issued_at": "UTC_ISO8601",
  "expires_at": "UTC_ISO8601",
  "nonce": "cryptographically_random",
  "owner_subject": "Auth0_sub"
}
```

- L'enveloppe est canonisée, signée par une clé de service dédiée et vérifiée par une clé publique épinglée côté Windows ; **ne pas inventer de signature dans un champ JSON sans vérification cryptographique**.
- L'**approbation utilisateur séparée et signée** doit inclure `operation_id,device_id,action,target,before_sha256,after_sha256,nonce,expires_at` ; une phrase « GO » dans un texte MCP ou un `planId` nu n'est pas une preuve cryptographique.
- Nonce à usage unique avec journal durable et ACK ; replay/retry n'exécute pas deux fois. Durée courte, dérive d'horloge bornée, refus token expiré, signature invalide, destinataire différent, mauvais scope, unknown device.
- Refus d'une valeur `target` libre, chemin absolu fourni par le client, script libre, URL libre, bash/PowerShell/command arbitraire.
- Le choix d'algorithme de signature et la gestion/rotation/révocation des clés exigent revue indépendante ; ne pas réutiliser le secret OAuth Auth0 comme clé de signature d'actions.

## 4. Machine à états de réparation proposée

`OBSERVED -> PLANNED -> VALIDATED -> OWNER_APPROVED -> PREPARED_DURABLE -> APPLIED -> VERIFIED_FILE -> [RESTART_APPROVED -> RESTARTED -> VERIFIED_RUNTIME] -> CLOSED`.

- `FAILED_PREPARE`, `FAILED_APPLY`, `FAILED_VERIFY`, `STALE/UNAUTHORIZED` => NO-GO, aucun retry aveugle. 
- `ROLLED_BACK` nécessite backup vérifié, identité du fichier, SHA après application attendu et reçu durable. Un fichier modifié par un tiers après apply doit provoquer un STOP, pas un écrasement.
- En cas de crash, la reprise lit le journal de commit et les hashes disque avant toute décision ; **pas de suppression automatique de preuves ou de contournement des protections**.
- Chaque état publie un `operation_id` unique, un horodatage, les hashes et un résultat redigé. Les étapes d'écriture sont auditables mais les secrets ne doivent jamais apparaître dans le log.

## 5. Matrice de tests prérequis — test d'abord, aucun agent réel

| Gate | Tests minimaux | Succès accepté |
| --- | --- | --- |
| G4-A : statique (cette phase) | Threat model + revue API + manifest + boundary docs | Design review documentée, aucun exécutable ajouté |
| G4-B : offline Win32 | Hash mismatch, mauvaise identité de fichier, junction/reparse/symlink, ACL hostile, fichier échangé entre stat et open | 100 % fail-closed, sources actives intactes |
| G4-C : autorisation | Pas d'approval ; planId seul ; JWT mauvaise audience ; scope READ pour APPLY ; signature invalide ; nonce réutilisé ; opération expirée ; mauvais device | 100 % refus sans écriture |
| G4-D : crash recovery | Crash avant et après backup, remplacement, réception du reçu ; lock orphelin ; deux apply concurrents | Reprise déterministe ou STOP manuel, zéro corruption |
| G4-E : changement contrôlé | Fixture signée et épinglée, backup byte-exact, apply, verify, rollback, comparaison ACL/identité/receipt | 100 % sur environnement Windows isolé, jamais scripts actifs |
| G4-F : transport et charge | 3–5 requêtes simultanées, timeout, ACK perdu H2-C, retry, quotas D1/DO en staging | Aucun double apply, TTL adaptés, budgets documentés |
| G4-G : E2E plugin principal | Réelle identité Auth0, lecture/plan seulement depuis ChatGPT iPhone, plus tard fixture apply avec GO séparé | Trace complète sans bypass de permission |
| G4-H : sécurité indépendante | Deuxième reviewer, supply-chain et secrets, journal d'audit, rollback, procédure d'urgence | Rapport avec BLOCKER 0 avant toute activation |

**L'acceptation G4-A ne vaut pas GO pour G4-B/C ni pour l'activation.** Avant chaque gate, obtenir le GO humain correspondant. Chaque test a une preuve reproductible et un SHA exact. Jamais de déploiement Vercel/Cloudflare ni de merge sans GO.

## 6. Relations avec J1-H, J1/J2 et quotas

- L'ancienne boucle Projects traite trop peu de jobs à cadence 60 s avec TTL ~90 s ; les rafales ont déjà produit des expirations. Le mode écriture **ne doit pas dépendre** d'une queue non fiabilisée. Prévoir traitement groupé borné, ACK, idempotence, et suivi de latence avant toute activation.
- Transport signed WSS, H2-C ACK et mesures Cloudflare D1/DO 24h doivent être démontrés **sur la version effectivement utilisée**, pas extrapolés de la CI loopback.
- Le plugin principal est la cible unique pour l'expérience ChatGPT/iPhone. Ne pas reconfigurer Auth0 ni créer une autre app/site pour cacher le problème.
- Contenir les mutations de schéma/Worker derrière un GO explicite et migration/rollback revus ; quotas gratuits et flux write ne sont pas implicitement approuvés.

## 7. Ordre des travaux autorisés et preuves attendues

**Cette passe (GO de l'utilisateur « Go » après proposition d'audit et préparation J4)** : lire les sources, rédiger cette analyse, ouvrir issue/PR docs DRAFT et consigner Notion. **Aucune écriture de code exécutable, ni activation, ni mutation Windows ou cloud.**

**Prochaine autorisation à demander (pas incluse dans ce GO)** :
1. développer sur une branche séparée le schéma `patch-envelope-v1`, le parseur/validateur et tests négatifs *purement offline* ;
2. étudier l'updater Windows signé isolé et la couche OS/ACL/handle, toujours sans installer, sans exposer un outil MCP d'écriture ;
3. faire la contre-revue de sécurité, fournir PR draft, CI Win32, preuves de tests et verdict GO/NO-GO ;
4. seulement ensuite planifier un pilote fixture avec approbation distincte.

**Interdictions maintenues :** pas de Desktop Commander, pas de redémarrage de tâches, pas de patch réel, pas de déploiement Cloudflare/Vercel, pas de merge, pas de changement Auth0/D1/secret, pas de nouvelle capability MCP sur le plugin principal sans GO.

## 8. Statut roadmap (sources Notion)

J0 **3/3**, J1 **4/5**, J2 **2/4**, J3 **4/4**, J4 **0/5**, J5 **0/3** : **13/24 PE = 54,2 %**. Ce livrable Gate A est **préparation non créditée**, les PE ne changent pas.

## 9. Références externes de sécurité

- MCP Authorization Spec (version 2026-07-28), audience, OAuth Resource Metadata, refus token passthrough : https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/docs/specification/2026-07-28/basic/authorization/index.mdx
- MCP authorization security considerations : https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/docs/specification/2026-07-28/basic/authorization/security-considerations.mdx
- OWASP MCP Top 10 (publication vivante/bêta) : https://owasp.github.io/www-project-mcp-top-10/
