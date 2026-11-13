# J1-H — Tentative contrôlée du test signé réel (13 novembre 2026)

Objectif : une unique exécution du workflow GitHub **sur la branche protégée** `aimb-j1h-trusted-runner`, après validation de la variable `AIMB_J1H_LIVE_STAGE_READY=true` par le propriétaire, pour le Worker de test existant. Test signé RSA et WSS : 70 secondes puis 180 secondes réelles ; test H2-B de notification et anti-rejeu avec cadence minimale de 15 secondes.

Cette modification ne contient **aucun secret**, ne modifie aucune tâche Windows et ne déploie pas le Worker Cloudflare. Les cinq files D1 isolées étaient vides avant l'essai. Le job H2-C de cinq fixtures/ACK est **hors périmètre** de cet essai ; il requiert désormais un marqueur d'autorisation indépendant qui ne figure pas dans le message du commit de fusion de cette PR.

Le workflow doit rester fail-closed : si la variable, le secret ou l'approbation de l'environnement `aimb-j1h-staging` sont absents, le job est ignoré ou échoue, et aucun succès ne sera annoncé.

Provenance : PR #40 fusionnée au commit `b599594b87c6b2eefc6d451d47ecc6a57fdcc047`, CI précédente 6/6, 80 tests du superviseur, 13 tests D1, 9 tests H2-B. Ce fichier ne constitue **pas** une preuve de test signé réussi.
