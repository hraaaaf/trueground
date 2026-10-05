# LOT11-H H1 — Participant Information & Informed Participation

Date: 2026-10-05
Status: TEMPLATE — NOT VALID FOR USE UNTIL PRE-SESSION FIELDS ARE COMPLETED

This template is for supervised TrueGround product-alpha sessions only. It is not a clinical consent form and does not make H1 a clinical trial.

Before use, the facilitator must complete:
- Session jurisdiction: `<REQUIRED>`
- Exact TrueGround SHA/build: `<REQUIRED>`
- Session environment/build identifier: `<REQUIRED>`
- External provider: `Groq / openai-gpt-oss-120b` unless separately approved
- Groq ZDR confirmed on actual organization/project: `YES / NO — REQUIRED YES`
- Structured-note retention approved: `<REQUIRED>`
- Human incident/escalation contact/process: `<REQUIRED>`
- Product Owner H1 execution authorization reference: `<REQUIRED>`

If any required field is blank or ZDR is not confirmed, do not run the participant session.

---

## ENGLISH

### What is this session?

You are being invited to take part in a supervised product test of TrueGround.

The purpose is to observe whether the product is understandable, bounded and safe enough for a small controlled alpha. We are testing the product, not testing you.

This is not a clinical trial, diagnosis, therapy, treatment, autonomous ERP session, medication service, emergency service, or proof of therapeutic efficacy.

In particular, this is **not**:
- a clinical trial;
- a diagnosis;
- therapy or treatment;
- an autonomous ERP session;
- medication advice;
- an emergency service;
- proof that TrueGround improves OCD or any other condition.

You do not need a formal OCD diagnosis to participate.

### What will happen?

The session should take about 25–35 minutes.

A facilitator will:
1. explain the product boundaries and privacy plan;
2. show you how to start and stop the companion;
3. observe a short, bounded period of use;
4. ask a few questions about clarity, safety and usability.

The supervised-use phase is limited to:
- at most 8 participant messages;
- at most 6 provider-eligible model calls;
- no automatic retry or “try another answer” loop.

You will not be asked to deliberately trigger severe symptoms, perform repeated checking, confess sensitive details, carry out an exposure hierarchy, change medication, or ignore professional care.

If you prefer not to use a personal example, you may use a low-stakes fictional scenario.

### What are the possible risks?

The product may:
- give an unhelpful, awkward or incorrect response;
- say something that feels too reassuring, moralizing, repetitive or confusing;
- accidentally encourage more checking, analysis or repeated questioning;
- fail or become unavailable.

If any safety STOP condition occurs, the facilitator will end the product interaction.

If you need urgent or emergency help, this session is not the right service. The facilitator will stop the product test and use the separate human/local procedure prepared for the session. TrueGround itself does not contact emergency services, a clinician, a friend or another person unless a real external action has actually been taken.

### Is there a guaranteed benefit?

No.

You should not expect a therapeutic or clinical benefit from taking part. The session is designed to evaluate product behavior and usability.

### What information is processed?

By default:
- no name, email, phone number, diagnosis or medication list is entered into the H1 observation record;
- you receive a random session code;
- no audio/video recording is made;
- no screenshot containing your free text is taken;
- the facilitator records structured product observations, not verbatim sensitive content;
- TrueGround does not persist raw chat by default.

For provider-eligible turns, the minimum message/context needed to generate a response may be sent to the external model provider named above.

The session may proceed only after the team has verified the actual provider account/configuration required by the H1 privacy preflight, including Zero Data Retention for the inference path.

Current public Groq documentation states that inference customer data is not retained by default except for limited reliability/abuse circumstances and that ZDR can be enabled. It also states that retained customer data, when retention applies, is located in U.S. GCP buckets. The team must confirm the actual TrueGround account setting before your session.

### What is recorded after the session?

The H1 record should contain only:
- your random session code;
- build/SHA;
- language;
- structured safety/product outcome codes;
- short paraphrased usability notes.

No raw confession, obsession, crisis text, prompt or generated answer should be copied into GitHub, Notion, CI logs or routine analytics.

The approved retention period is shown in the pre-session fields above. You may use your session code to request deletion while the structured H1 record is retained.

### Is participation voluntary?

Yes.

You may:
- decline to participate;
- skip a question;
- stop the session at any time;
- ask for the product interaction to end without giving a reason.

Stopping will not be treated as a failure.

### Questions before starting

Before you choose, you may ask:
- what TrueGround can and cannot do;
- what data is sent to the provider;
- where structured notes are stored;
- how long notes are kept;
- how to request deletion;
- what happens if a safety issue occurs.

### Informed participation confirmation

Please confirm each statement:

- [ ] I am 18 or older.
- [ ] I understand this is a supervised product test, not treatment, diagnosis or emergency care.
- [ ] I understand there is no promised clinical benefit.
- [ ] I understand I can stop at any time.
- [ ] I understand that provider-eligible text may be processed by the external model provider under the disclosed H1 data flow.
- [ ] I understand the team will record structured product observations rather than raw sensitive conversation text.
- [ ] I had the opportunity to ask questions.
- [ ] I voluntarily agree to participate.

Participant session code: `<CODE>`

Participant confirmation: `<SIGNATURE / APPROVED ELECTRONIC CONFIRMATION>`

Date/time: `<REQUIRED>`

Facilitator confirmation: `<REQUIRED>`

---

## FRANÇAIS

### Qu’est-ce que cette session ?

Vous êtes invité(e) à participer à un test produit supervisé de TrueGround.

L’objectif est d’observer si le produit est compréhensible, borné et suffisamment sûr pour une petite alpha contrôlée. Nous évaluons le produit, pas vous.

Ce test n’est pas un essai clinique, un diagnostic, une thérapie, un traitement, une séance d’ERP autonome, un service médicamenteux, un service d’urgence ni une preuve d’efficacité thérapeutique.

En particulier, ce test n’est **pas** :
- un essai clinique ;
- un diagnostic ;
- une thérapie ou un traitement ;
- une séance d’ERP autonome ;
- un conseil médicamenteux ;
- un service d’urgence ;
- une preuve que TrueGround améliore le TOC ou une autre condition.

Il n’est pas nécessaire d’avoir un diagnostic formel de TOC pour participer.

### Que va-t-il se passer ?

La session devrait durer environ 25 à 35 minutes.

Un facilitateur va :
1. expliquer les limites du produit et le plan de confidentialité ;
2. montrer comment ouvrir et quitter le compagnon ;
3. observer une courte utilisation bornée ;
4. poser quelques questions sur la clarté, la sécurité et l’utilisabilité.

La phase d’utilisation supervisée est limitée à :
- 8 messages participant au maximum ;
- 6 appels modèle éligibles au maximum ;
- aucun retry automatique ni boucle « donne-moi une autre réponse ».

On ne vous demandera pas de provoquer volontairement des symptômes importants, de répéter des vérifications, d’avouer des détails sensibles, de réaliser une hiérarchie d’exposition, de modifier un traitement médicamenteux ou d’ignorer un professionnel de santé.

Si vous préférez ne pas utiliser d’exemple personnel, vous pouvez utiliser un scénario fictif à faible intensité.

### Quels sont les risques possibles ?

Le produit peut :
- donner une réponse peu utile, maladroite ou incorrecte ;
- utiliser une formulation trop rassurante, moralisatrice, répétitive ou confuse ;
- encourager par erreur davantage de vérification, d’analyse ou de questions répétées ;
- échouer ou devenir indisponible.

Si un critère STOP de sécurité survient, le facilitateur arrêtera l’interaction produit.

Si vous avez besoin d’une aide urgente ou d’urgence, cette session n’est pas le bon service. Le facilitateur arrêtera le test produit et utilisera la procédure humaine/locale préparée pour la session. TrueGround ne contacte pas de service d’urgence, clinicien, proche ou autre personne sauf si une action réelle a effectivement été réalisée en dehors de TrueGround.

### Y a-t-il un bénéfice garanti ?

Non.

Vous ne devez pas attendre de bénéfice thérapeutique ou clinique de votre participation. La session sert à évaluer le comportement du produit et son utilisabilité.

### Quelles informations sont traitées ?

Par défaut :
- aucun nom, e-mail, numéro de téléphone, diagnostic ou liste de médicaments n’est saisi dans le dossier d’observation H1 ;
- un code de session aléatoire vous est attribué ;
- aucun enregistrement audio/vidéo n’est réalisé ;
- aucune capture contenant votre texte libre n’est prise ;
- le facilitateur note des observations produit structurées, pas du contenu sensible mot à mot ;
- TrueGround ne conserve pas le chat brut par défaut.

Pour les tours éligibles au fournisseur, le minimum de message/contexte nécessaire à la génération peut être envoyé au fournisseur de modèle externe indiqué ci-dessus.

La session ne peut avoir lieu qu’après vérification réelle du compte et de la configuration fournisseur exigés par le préflight confidentialité H1, notamment l’activation du Zero Data Retention pour le chemin d’inférence.

La documentation publique actuelle de Groq indique que les données client des requêtes d’inférence ne sont pas conservées par défaut, sauf cas limités de fiabilité/abus, et que le ZDR peut être activé. Elle indique également que les données client conservées, lorsqu’une rétention s’applique, sont situées dans des buckets GCP aux États-Unis. L’équipe doit confirmer le réglage réel du compte TrueGround avant votre session.

### Qu’est-ce qui est enregistré après la session ?

Le dossier H1 doit contenir uniquement :
- votre code de session aléatoire ;
- le build/SHA ;
- la langue ;
- des codes structurés de résultats produit/safety ;
- de courtes notes d’utilisabilité reformulées.

Aucun contenu brut de confession, obsession, crise, prompt ou réponse générée ne doit être copié dans GitHub, Notion, les logs CI ou les analytics habituels.

La durée de conservation approuvée est indiquée dans les champs pré-session ci-dessus. Vous pouvez utiliser votre code de session pour demander la suppression tant que le dossier H1 structuré est conservé.

### La participation est-elle volontaire ?

Oui.

Vous pouvez :
- refuser de participer ;
- ne pas répondre à une question ;
- arrêter la session à tout moment ;
- demander l’arrêt de l’interaction produit sans donner de raison.

L’arrêt n’est pas considéré comme un échec.

### Questions avant de commencer

Avant de décider, vous pouvez demander :
- ce que TrueGround peut et ne peut pas faire ;
- quelles données sont envoyées au fournisseur ;
- où les notes structurées sont conservées ;
- combien de temps elles sont conservées ;
- comment demander leur suppression ;
- ce qui se passe en cas de problème de sécurité.

### Confirmation de participation éclairée

Merci de confirmer chaque point :

- [ ] J’ai 18 ans ou plus.
- [ ] Je comprends qu’il s’agit d’un test produit supervisé, pas d’un traitement, diagnostic ou service d’urgence.
- [ ] Je comprends qu’aucun bénéfice clinique n’est promis.
- [ ] Je comprends que je peux arrêter à tout moment.
- [ ] Je comprends que du texte éligible au fournisseur peut être traité par le fournisseur de modèle externe selon le flux de données H1 présenté.
- [ ] Je comprends que l’équipe enregistrera des observations produit structurées plutôt que le contenu sensible brut de la conversation.
- [ ] J’ai eu la possibilité de poser mes questions.
- [ ] J’accepte volontairement de participer.

Code de session participant : `<CODE>`

Confirmation du participant : `<SIGNATURE / CONFIRMATION ÉLECTRONIQUE APPROUVÉE>`

Date/heure : `<REQUIRED>`

Confirmation du facilitateur : `<REQUIRED>`
