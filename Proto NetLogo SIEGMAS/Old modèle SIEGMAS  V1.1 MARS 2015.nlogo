; les variables globales
globals [
  colorsList           ; numeroted list of colors used by peasants
  plotsList            ; numeroted list of plots counts of peasants
  xList                ; numeroted list of x coordinates peasants
  yList                ; numeroted list of y coordinates of peasants
  average
  uses
  benefits
  investments
  lifes
  taxes
  sanctions
  totalUse
  totalGain
  totalLife
  totalSanction
  totalMoney
  ]

; -------------------------------------------------------------------------------

; les parties prenantes à la gouvernance des ressources naturelles
breed [governments government]
breed [internationalOrganizations internationalOrganization]
breed [internationalGovernments internationalGovernment]
breed [ministryOfEnvironments ministryOfEnvironment]
breed [ministryOfAgricultures ministryOfAgriculture]
breed [othersMinistries otherMinistry]
breed [ONFs ONF]                               ;Office Nationale des Forêts 
breed [regionalAuthorities regionalAuthority] ; Direction régionale de l'Economie (DRE), 
                                                ;Direction Régionale du BUdget (DRB),
                                                ;Direction Régionale des Traveau Publics (DRTP)
breed [DirectionDel'Environnements DirectionDel'Environnement]                               ; DIREN ou DEAL          
breed [townships township]
breed [localCommunities localCommunity]
breed [firms firm]
breed [citizens citizen]
breed [peasants peasant]
breed [deviants deviant]
breed [exploitations exploitation]
; -------------------------------------------------------------------------------

patches-own [
  isForest             ; Boolean - 1 if the patch is a forest else 0
  isOwned              ; Boolean - 1 if terran is officially owned by a peasant
  deteriorationLevel   ; Integer - percentage of level of deterioration
  isProtected          ; Boolean - determines if this patch (normaly non exploited patch) is protected by a law
  ]


; adding custom turtles variables

peasants-own [
  plots                ; Integer - number of owned patch
  money                ; Float - available money in euros
]
deviants-own [
  plots                ; Integer - number of owned patch
  money                ; Float - available money in euros
]

exploitations-own [
  bio                  ; Float - percentage of bio agriculture
  con                  ; Float - percentage of conventional agriculture
  snb                  ; Float - percentage of slash and burn agriculture
  owner                ; Integer - identificator of the owner
]

; -------------------------------------------------------------------------------
to init 
  clear-all 
  resize-world 0 41 0 43 
  set-patch-size pSize
  ask patches [
    set pcolor green
    set deteriorationLevel random 100
    ; set color to brown +/- 0.25 (more darker -> more healthy) by default all patches is setted to undefined (ie. not forest and brown)
    set pcolor brown + (deteriorationLevel / 2 - 25) / 100
    set isForest 0  ]
  ; set the given percentage of forest in patches randomly on the word
  ask n-of (count patches * forestPercentage / 100) patches [ 
    ; set color to green +/- 0.25 (more darker -> more healthy)
    set pcolor green + (deteriorationLevel - 50) / 100
    set isForest 1  
  ]
  createGovernments 
  createInternationalOrganizations
  createInternationalGovernments
  createMinistryOfEnvironments
  createMinistryOfAgricultures
  createOtherMinistries
  createONFs                             
  createRegionalAuthorities 
  createDirectionDel'Environnement                     
  createTownships
  createLocalCommunity
  createFirms
  createCitizens
  createPeasants
  createDeviants
  createExploitations
  reset-ticks
end


; -------------------------------------------------------------------------------

to createGovernments  
   create-governments nbGovernments
    ask governments [
    set xcor random-pxcor
    set ycor random-pycor
    set shape "person soldier"
    set color green
    ]
end

to createinternationalOrganizations
   create-internationalOrganizations nbInternationalOrganizations
    ask internationalOrganizations [
    set xcor random-pxcor
    set ycor random-pycor
    set shape "person service"
    set color gray
    ]
  end

to createInternationalGovernments
  create-internationalGovernments nbInternationalGovernments
    ask internationalGovernments [
    set xcor random-pxcor
    set ycor random-pycor
    set shape "person"
    set color pink
    ]
  end

to  createMinistryOfEnvironments 
  create-ministryOfEnvironments nbMinistryOfEnvironments
   ask  ministryOfEnvironments [
    set xcor random-pxcor
    set ycor random-pycor
    set shape "person police"
    set color lime 
    ]
  end

to createMinistryOfAgricultures 
  create-ministryOfAgricultures nbMinistryOfAgricultures
   ask ministryOfAgricultures [
    set xcor random-pxcor
    set ycor random-pycor
    set shape "person police"
    set color orange
    ]
   
   end

to createOtherMinistries
  create-othersMinistries nbOtherMinistries
   ask othersMinistries [
   set xcor random-pxcor
   set ycor random-pycor
   set shape "person police"
   set color magenta 
    ]
   
 end

to createONFs
  create-ONFs nbONFs   
   ask othersMinistries [
    set xcor random-pxcor
    set ycor random-pycor
    set shape "person police"
    set color blue
    ]
end 
                           
  to createRegionalAuthorities  
   create-regionalAuthorities nbRegionalAuthorities 
   ask othersMinistries [
    set xcor random-pxcor
    set ycor random-pycor
    set shape "person police"
    set color turquoise
    ]
 end

to  createDirectionDel'Environnements
  create-DirectionDel'Environnements nbDirectionDel'Environnements
   ask othersMinistries [
    set xcor random-pxcor
    set ycor random-pycor
    set shape "person police"
    set color 67
    ]
  end

to createTownships
  create-townships nbTownships
   ask othersMinistries [
    set xcor random-pxcor
    set ycor random-pycor
    set shape "person police"
    set color violet
    ]
 end

to createLocalCommunity
  create-localCommunities nbLocalCommunities
   ask othersMinistries [
    set xcor random-pxcor
    set ycor random-pycor
    set shape "person lumberjack"
    set color white
    ]
  end

end 
    to createFirms
   create-firms nbFirm
   ask othersMinistries [
    set xcor random-pxcor
    set ycor random-pycor
    set shape "person business"
    set color blue
    ]
    end 
    
   to createCitizens 
   create-citizens nbCitizens
   ask othersMinistries [
    set xcor random-pxcor
    set ycor random-pycor
    set shape "person"
    set color blue
    ]
   end 
   
   to createPeasants
   create-peasants nbPeasants
   ask othersMinistries [
    set xcor random-pxcor
    set ycor random-pycor
    set shape "person farmer"
    set color 92 ; blue
    ]
   end 
   
   to createDeviants
   create-deviants nbdeviants
   ask othersMinistries [
    set xcor random-pxcor
    set ycor random-pycor
    set shape "person construction"
    set color blue
    ]
   end 
   
  to createExploitations
   create-exploitations nbExploitations
   ask othersMinistries [
    set xcor random-pxcor
    set ycor random-pycor
    set shape "square 2"
    set color black
    ]
   
end 

; -------------------------------------------------------------------------------
; Iteration
; -------------------------------------------------------------------------------

to iterate
  iterateOperator
  iterateExternalHelp 
  iterateManagers
  
end

-------------------------

; CONTRATS 
; 1) état de la nature : aversion pour le risque, utilité espérée, contrat implicites, biens contingents, 
; 2) négociation bilatérale 
; 3) coût de transactions 
; 4) rationalité limitée 

-------------------------

; MARCHÉ DU TRAVAIL 
; 1) Offre de travail et chômage (taux naturel, déséquilibre)
; 2) contrats (mandats et mandataires)
; 3) valeur du travail (exploitation, salaire (= w), rentes temporaires immédiates = Vn = a1(1+i) ^(n-1) + ... + ap(1+i) ^(n-p)+ ... + an et rente anticipée = Ve =Vo (1+i)^(e)
 
 
 -------------------------
 
; THÉORIE DES JEUX 
; 1) jeux évolutionnistes (cf. jeu de société, de bourse ou le sport)

; 2) stratégie mixte 
; Aucune réponse ne s’impose. Comment s’en sortir ?

Une première réponse possible est de jouer au hasard, avec une probabilité égale pour tous les coups possibles, sans se préoccuper des gains. Cela n’apparaît pas optimum, il y a certainement mieux à faire.

Une seconde stratégie est de tenter d’attribuer a priori une probabilité aux actions de l’adversaire, et d’opter pour la meilleure réponse adaptée. Ainsi, si (2) attribue une probabilité 50/50 aux options de (1), il doit jouer aussi à 50/50 (B) et (C). Mais l’adversaire n’est pas un dé qui se comporte au hasard : lui aussi va anticiper. Si c’est (1) qui réfléchit, il voit bien qu’il est absurde de supposer que (2) va jouer (A) dans un tiers des cas. Là encore il y a certainement mieux à faire.
; 3) stratégie : forme de startégie
; 3.1) ensemble d'information (jeu séquentielet arbre de jeu)
; 3.2) stratégie conditionnelle 
; 3.3) forme extensive (de la stratégie) : concept de solution via des connaissances communes 
; 3.3.1. information incomplète 
;                   1. Etat de la nature : réalisation possible d'une variable aléatoire en statistique, chacune de ces réalisations est affectée d'une probabilité
;                    2. règle de Bayes :modification de la probabilité de réaalisation d'un évenement en tenant compte des observations qui ont pu être faites de phénéomène sne liaison avec cet évenement)
;                     La règle de Bayes fait apspser d'une probabilité a priori (avant l'observation) attribuée à un évenemnet à sa probébilité a posteriori (après les obsrvations). 
; 3.3.2. information complète  
;                  1. jeu à somme nulle (théorème de Von Neuman) minimax = On considère deux firmes A et B, en concurrence sur le marché d’un produit dont le coût de production unitaire est de 1 euro. Lorsque le produit est proposé sur le marché à 2 euros, il y a 100 clients prêts à l’acheter ; si le prix proposé est de 3 euros, il ne reste plus que 50 acheteurs qui accepteront de payer ce prix.

Chaque firme choisit indépendamment et dans l’ignorance du choix de son concurrent de fixer son prix de vente à 2 ou 3 euros. Si les deux firmes choisissent le même prix de vente, elles se partagent le marché par moitié (leurs produits étant supposés indiscernables) ; en revanche si l’une choisit de vendre à 2 euros tandis que sa concurrente tente le prix élevé, elle obtient la totalité du marché.

La situation est donc la suivante :

si A et B vendent à 2 euros, chacun fait un bénéfice de 50 euros (1 euro de bénéfice fois 50 acheteurs) ;
si A vend à 2 euros et B à 3 euros, c’est A qui emporte le marché et gagne 100 euros, tandis que B ne gagne rien ;
si A vend à 3 euros et B à 2 euros, la situation est symétrique ;
si A et B vendent à 3 euros, chacun fait un bénéfice de 50 euros (2 euros de bénéfice fois 25 acheteurs).
;                  2. stratégie dominante ( dillemme du prisonnier cf. infra) 
;                  3. équilibre de Nash : Théorème de Nash — Soit g :S_1\times\ldots\times S_m \to \R^m un jeu discret où m est le nombre de joueurs et S_i est l'ensemble des possibilités pour le joueur i, et soit \bar g l'extension de g aux stratégies mixtes. Alors le jeu \bar g admet au moins un point d'équilibre.
;                  3. A) équilibre parfait : En théorie des jeux, un équilibre parfait par sous-jeux (ou équilibre de Nash parfait par sous-jeux) est un raffinement conceptuel d'un équilibre de Nash utilisé dans les jeux dynamiques. Une stratégie est un équilibre parfait par sous-jeux, si elle représente un équilibre de Nash de tout sous-jeu du jeu de départ. Intuitivement, cela signifie que si (1) les joueurs jouent à un jeu plus restreint qui consiste en seulement une partie du premier et (2) leur comportement correspond à un équilibre de Nash de ce jeu plus restreint, alors leur comportement est un équilibre parfait par sous-jeux du jeu d'origine.
; Il est établi que chaque jeu extensif fini a un équilibre parfait par sous-jeux, 
;                  3. B) récurence à rebours : La méthode utilisée pour trouver la solution consiste à raisonner à partir de la fin, en commençant par déterminer les 
;                 choix à chaque noeud de celui qui joue avant lui et ainsi de suite. Sur l'arbe du jeu (arbre de Kuhn), cette méthode conduit à élaguer progressivement
;                les branches, jusqu'à ce qu'il ne reste plus que le noeud initial.        

;                  4. jeu répété est un jeu ordinaire ou constituant réitéré plusieurs fois de suite. Un jeu ordinaire est défini comme un jeu statique dans lequel les joueurs choisissent simultanément. 
                   théorème de folk:  toute solution individuellement rationnelle (donnant aux joueurs un gain supérieur à leur minimum garanti) peut être obtenue par 
                   un équilibre de Nash dans un jeu infiniment répété. L'équilibre parfait en jeu répété Q = { s(0), s(1), ..., s(t), ...} = { s(t) }
                    avec t allant de 0 à infini s = sentier d'équilibre : qéquence de profils d'action dans le jeu complet  (séquence de déplacement)
                    
;                  5.  2 à 4 donnent dilleme du prisonnier répété : la répétition pet inciter les joueurs à coopérer au premier jeu afin de coopérer dans 
;                  chacun des tours suivants. 
; 
-------------------------

; INDIVIDU 
; rationnel (dilleme du prisonnierà
; valeur
; holisme 
; rationalité limitée; 
; conventions (éconmie des conventions)

-------------------------

; FONCTION DE PRODUCTION ET CROISSANCE 
; court terme Y = alpha f(L) avec L travail
; long terme  Y = F( K, L) avec L = travail et K = capital
; fonction de production Cobb Douglas avec Y = K^(alpha) L^(Béta) avec 0>alpha>1 er 0>béta>1
; Progrès technique : constant ou 

-------------------------

; MONNAIE 
; numéraire
; effet d'encaissements réels
; double coïncidence des besoins 
; générations imbriquées
; inflation (illusion monétaire, courbe de philipps : nouveaux classiques :: Nairu)
; Keynes (poste-kéynsien et préférences pour la liquidité) 
; théorie quantitative ( A) monétarisme (Friedman) B) Demande de monaie (Freidman) et A) et B) donnent ménanisme de transmission) 
; demande de monanie et préférences pour la liquidité donnent  modèle IS-LM (Investissement, Epargne, Travail, monnaie)

-------------------------
; MACROÉCONOMIE 
; Keynes : épargne = revenu - consommation 
; Holisme : Doctrine philosophique selon laquelle un énoncé scientifique doit prendre en considération l'environnement dans lequel il apparaît$
; accélérateur : (oscillateur de samuelson)
; consommation (comptabilité nationale) : consommation finale (ou imcompressible) et consommation intermédiaire
; monnaie inflation : définir un taux pour chaque économie cf. compatybiliyé nationale 
; agrégation (agent, fonction de production)

-------------------------
; MICROÉCONOMIE
; consommateur (ménage, paysan): cf. agent infra 
; producteur (entreprise) : cf. agent infra 

-------------------------
; ÉQUILIBRE 
; stabilité : de l'économie 
; point fixe : A) équilibre général  calculable (construction d'une maquette de l'économie d'un pays en partant d'un modèle d'équilibre général avec des agents maximisateurs dont on cherche à préciser kes oaramètre sà partir de données disponibles sur un pays). 
;              B) équilibre général (approche qui consite à prendre en compte l'ensemble des interdépendances qui résultent des choix des individus oud es groupent d'individus) 
;              C) équilibre partiel (Alfred Marshall, approche qui consiste à raisonner sur l'offre et la demande d'un bien quelconque sans tenir compte de ce qui se passe avec les autres biens. "toutes choses égales par ailleurs"
;               calcul de l'équilibre partiel : Soit le marche d'un bien donne, de prix p. La demande agregee pour le bien est notee xg(p) = ensemble (xh(p)) avec 
; xh(p)  lim vers H et h=1
; et l'ore agregee pour le bien yg(p) =yf (p): avec yf (p):lim vers PF et lim vers f=1 





 -----------------------
  -------------------------
  

 
to Operators  
  
  ; ces 5 volets sont valables pour ce volet concerne les paysans, les autres citoyens et les entreprises 
  
  
  ; il y aurait deux infos supplémentaires chez les citoyens (niveau de connaissances des lois et niveau de respect de l'environnement)
  ; à chaque sensibilisation, ces deux informations sont sensiblement augmenter
  ; nb d'itérations pour chaque action (exemple : indiquer si les campagnes de sensibilisation sont trimestrielles)
  ; mettre les fonctions à utiliser 
  
  
  ; 1. LE GOUVERNEMENT
  ; toutes les instructions que le gouvernement effectue en un tour
  
  ; 1 / MARCHÉ interne et international:
  ; achats = achats de Matières premières ou de services + composantes (B et S pour le fonctionnement)
  ; et ventes de biens et services = bénéfice = Recettes - coûts 
  
  ; 2) BIENS COLLECTIFS 
  ; dilemme du prisonnier : 
  ; les biens collectifes gain 0 et tout pour les autres = recettes = 100% du bénéfice 
  ; les biens collectifs gain Tout et 0 pour les autres = recettes = 100 % du bénéfice 
  ; les biens collectifs 50 % pour une partie - 50 % pour une autre partie = 1/2 bénéfice pour chacun 
  ; passager clandestin (de M.Olsen) 100% de gains pour un citoyen qui utilise les biens publics dans payer ou sans s'acquitter d'impôts
  
  les biens collectifs 50 - 50 pour chaque personne participant au jeu
  ; 3) UTILITÉ COLLECTIVE
  ; investissement (paradoxe de condorcet) : 
  ; investissement brut = (capital physique/fixe de l’entreprise = Machines)
  ; investissement net = Investissement brut - amortissement (= perte de la valeur annuelle de capital fixe)
  ; l'Etat fait des choix cohérents mais les autres acteurs font des choix incohérents (investissements) en fonctiond e leur préférences individuelles 
  ; A préfère x > z > y 
  ; B préfère y > x > z
  ; C préfère z > y > x (..)
  
  ; 4) EXTERNALITÉS (positives et négatives)
   ; recolte des paiements des taxes/impôts et application des peines
   ; taxe = %tage de 0% à 50% en fonction des parties prenantes 
   ; impôts = (Revenu net impsosable * taux d'impostition) - (salaire * Nombre de parts) 
   ici salaire = w / revenu net imposable = R 
   ;  dons et  subventions
   ; dons et suventions = somme (pourcentage du budget alloué à chaque partie prenante)
   
  ; 5) PUBLIC CHOICE 
  ; politique et stratégie environnementales (législations, campagne de diffusion, sensibilisation, ...)
  ; coût du contrôle = budget alloués 
  ; productivité = 
  ; coût de la réalisation des lois et de son application = budget alloués
  ; politique et stratégie de gouvernance 
 
  
  
  -------------------------
  ; RENTES
  ; rente temporaire immédiate 
  ; valeur acquise de la rente immédiate = Vn =a1(1+i)^(n-1) + a2(1+i)^(n-2) +...+ap(1+i)^(n-p) +... + an
  ; valeur actuelle de la rente immédiate = Vo =a1(1+i)^(-1) + a2 (1+i)^(-2)+...+ap(1+i)^(-p) + an (1=i) ^(-n)
  ; La rente anticipée d’une fractione de période a pour valeur actuelle = Ve = Vo (1+i)e
  ; rente temporaire immédiate à terme constant =  Vn =a(1+i)^(n-1) + a(1+i)^(n-2) +... + a   ou  Vo = (a (1-(1+i)^-n) / i
  ; rente immédiate : Vo = a/i (1-(1+i)^-n))
  ; rente perpétuelle anticipée : V’o = (a/i) * (1+i)^k
  ; rente perpétuelle différée : V’’o = (a/i) * (1+i)^(-k)
  ; rente escomptée : 
  
  -------------------------
  ; Taux de croissance 
  ; TCAM = Taux de Croissance Annuel Moyen = ( (n√ valeur finale / valeur initiale) - 1) * 100 
  ; taux d'accroissement total : TAT = (valeur finale - valeur initiale) / valeur initiale 
  
end  


 -----------------------
  -------------------------
  
  
  
to ExternalHelp 
  
  ; ces 5 volets sont valables pour les gouvernements étrangers et bailleurs de fonds et associations
  ; l'économie est ouverte selon le modèle IS-LM  et le modèle néoclassique
 
  ; 1. LE GOUVERNEMENT
  ; toutes les instructions que le gouvernement effectue en un tour
  
  ; 1 / MARCHÉ international:
  ; achats = achats de Matières premières ou de services + composantes (B et S pour le fonctionnement) cf.  facteurs de production et frontières de production
  ; et ventes de biens et services = bénéfice = Recettes - coûts  et avantage comparatif (AC) de Ricardo = on produit les B et S pour lesquels on a un AC et on achète (importation) des produits trop cher ou plus coûteux à produire;
  
  ; 2) BIENS COLLECTIFS 
  ; dilemme du prisonnier : 
  ; les biens collectifes gain 0 et tout pour les autres = recettes = 100% du bénéfice 
  ; les biens collectifs gain Tout et 0 pour les autres = recettes = 100 % du bénéfice 
  ; les biens collectifs 50 % pour une partie - 50 % pour une autre partie = 1/2 bénéfice pour chacun 
  ; passager clandestin (de M.Olsen) 100% de gains pour un citoyen qui utilise les biens publics dans payer ou sans s'acquitter d'impôts
  
  les biens collectifs 50 - 50 pour chaque personne participant au jeu
  ; ; 3) UTILITÉ COLLECTIVE
  ; investissement (paradoxe de condorcet) : 
  ; investissement brut = (capital physique/fixe de l’entreprise = Machines)
  ; investissement net = Investissement brut - amortissement (= perte de la valeur annuelle de capital fixe)
  ; l'Etat fait des choix cohérents mais les autres acteurs font des choix incohérents (investissements) en fonctiond e leur préférences individuelles 
  ; A préfère x > z > y 
  ; B préfère y > x > z
  ; C préfère z > y > x (..)
  
  ; 4) EXTERNALITÉS (positives et négatives)
   ; recolte des paiements des taxes/impôts et application des peines
   ; taxe = taxes à l'importation et à l'exportation %tage dépend des produits
   ; impôts = (Revenu net impsosable * taux d'impostition) - (salaire * Nombre de parts) 
   ici salaire = w / revenu net imposable = R 
   ;  dons et  subventions 
   ; dons et suventions = somme (pourcentage du budget alloué à chaque partie prenante)
   
  ; 5) PUBLIC CHOICE 
  ; politique et stratégie environnementales (législations, campagne de diffusion, sensibilisation, ...)
  ; coût du contrôle = budget alloués 
  ; productivité = 
  ; coût de la réalisation des lois et de son application = budget alloués
  ; politique et stratégie de gouvernance =somme (aides nationales, bailleurs de fonds, groupements comme UE, capital humain et physique)
  ; coopération internationale = somme (aides nationales, bailleurs de fonds, groupements comme UE, capital humain et physique)
  
end  



 -----------------------
  -------------------------
  
  
  to Public Manager 
    
    ; le gouvernement, les ministères et autorités décentralisées (communes, Directions de l'Environnement, conseil Général, Région , ...)
 
 
  ; 1 / MARCHÉ interne et international:
  ; achats = achats de Matières premières ou de services + composantes (B et S pour le fonctionnement)
  ; et ventes de biens et services = bénéfice = Recettes - coûts 
  
  ; 2) BIENS COLLECTIFS 
  ; dilemme du prisonnier : 
  ; les biens collectifes gain 0 et tout pour les autres = recettes = 100% du bénéfice 
  ; les biens collectifs gain Tout et 0 pour les autres = recettes = 100 % du bénéfice 
  ; les biens collectifs 50 % pour une partie - 50 % pour une autre partie = 1/2 bénéfice pour chacun 
  ; passager clandestin (de M.Olsen) 100% de gains pour un citoyen qui utilise les biens publics dans payer ou sans s'acquitter d'impôts
  
  les biens collectifs 50 - 50 pour chaque personne participant au jeu
  ; 3) UTILITÉ COLLECTIVE
  ; investissement (paradoxe de condorcet) : 
  ; investissement brut = (capital physique/fixe de l’entreprise = Machines)
  ; investissement net = Investissement brut - amortissement (= perte de la valeur annuelle de capital fixe)
  ; l'Etat fait des choix cohérents mais les autres acteurs font des choix incohérents (investissements) en fonctiond e leur préférences individuelles 
  ; A préfère x > z > y 
  ; B préfère y > x > z
  ; C préfère z > y > x (..)
  
  ; 4) EXTERNALITÉS (positives et négatives)
   ; paiement des paiements des taxes/impôts et application des peines
   ; taxe = %tage de 0% à 50% en fonction des parties prenantes 
   ; impôts = (Revenu net impsosable * taux d'impostition) - (salaire * Nombre de parts) 
   ici salaire = w / revenu net imposable = R 
   ;  dons et  subventions
   ; dons et suventions = somme (pourcentage du budget alloué à chaque partie prenante)
   
 -------------------

  ; PRODUCTEUR (Offre de production) : activité agricole, forestière ou autres ressources naturelles
  ;           paysan 
    ; 1/ exploitent les terres agricoles Production, profil, maximise son utilité (quotidiennenement)
  ; A) fonction de production qui maximise l'utilité 
; Y = F(L, K) ou ; court terme Y = alpha f(L) avec L travail
; long terme  Y = F( K, L) avec L = travail et K = capital
; fonction de production Cobb Douglas avec Y = K^(alpha) L^(Béta) avec 0>alpha>1 er 0>béta>1

  ; B) profit (q) = p.Q - C(Q) avec p = prix de vente; Q = quantité; C(Q) : coûts de production
  
  ; C) bénéfice = Recettes - dépenses 
  
  ; 2/ respectent ou transgressent l'environnement (quotidiennenement)
  ; A) pratique une agriculture conventionnelle
  ; B) pratique une agriculture bio 
  ; C)pratique une agriculture sur brûlis 
  
  ; 3/ reçoivent des subventions ou payent des sanctions (quotidiennenement, mensuellement, annuellement)
  ; A) reçoivent des subventions : en fonction de la taille de leur exploitation et de leur besoin et du type de culture
  ; B) payent des amendes et des sanctions:  respectent l'environnement et payent les amendes, sanctions : pourcentage du revenu ponctionné en fonction
  ; de la gravité du délit.
  
    
  ;             citoyen
  ; A) communiquent avec les entreprises achat : Pourcentage du budget. 
  ; B) communiquent les paysans : achat de biens et services : pourcentage du budget 
  ; C) communiquent les autres organismes :  respectent l'environnement et payent les amendes, sanctions : pourcentage du revenu ponctionné en fonction
  ; de la gravité du délit.
   

  ;             entreprise 
    ; 1/ exploitent les terres agricoles et les autres ressources 
     Production, profil, maximise son utilité (quotidiennenement)
  ; A) fonction de production qui maximise l'utilité 
; Y = F(L, K) ou ; court terme Y = alpha f(L) avec L travail
; long terme  Y = F( K, L) avec L = travail et K = capital
; fonction de production Cobb Douglas avec Y = K^(alpha) L^(Béta) avec 0>alpha>1 er 0>béta>1
  ; B) profit (q) = p.Q - C(Q) avec p = prix de vente; Q = quantité; C(Q) : coûts de production
  ; C) bénéfice = Recettes - dépenses 
  
   ; 2/ respectent ou transgressent l'environnement (quotidiennenement)
  ; A) pratique une agriculture conventionnelle
  ; B) pratique une agriculture bio 
  ; C)pratique une agriculture sur brûlis 
  
  ; 3/ reçoivent des subventions ou payent des sanctions (quotidiennenement, mensuellement, annuellement)
  ; A) reçoivent des subventions : en fonction de la taille de leur exploitation et de leur besoin et du type de culture
  ; B) payent des amendes et des sanctions:  respectent l'environnement et payent les amendes, sanctions : pourcentage du revenu ponctionné en fonction
  ; de la gravité du délit.
  
  -------------------------
  
  ; CONSOMMATEUR (demande de consommation)
  
  ; dotation initiale : revenu du consommateur
  
  
  ; fonction d'utilité on a : 
  ; A préfère x > z > y 
  ; B préfère y > x > z
  ; C préfère z > y > x (..)
  
  
  -------------------------------
  
 ; Fonction de consommation : 
   
 ; C = cR + Co avec C : consommation; c: propension marginal à consommer; Co : consommation incompressible ou consommation autonome; R : revenu global
 
; c: propension marginal à consommer = part d'une unité supplémentaire de revenu consacré à la consommation c = dérivée C / dérivée de R et 0>c>1
;Co : consommation incompressible ou consommation autonome : consommation destinée aux besoins élementaires/ physiologique (consommer même si le revenu est nul)
; revenu global : w (salaire)+ rentes + pensions + gains (théorie des jeux via les stratégies : dons, subventions) / quid des gains illégaux ? 


"La loi psychologique fondamentale sur laquelle nous pouvons nous appuyer en toute sécurité, à la fois a priori en raison de notre connaissance de la nature humaine, et a posteriori en raison des renseignements détaillés d'une expérience, c'est qu'en moyenne, et la plupart du temps, les hommes tendent à accroître leur consommation à mesure que leur revenu croît mais non d'une quantité aussi grande que l'accroissement du revenu."

La deuxième partie de la loi psychologique fondamentale est que la Pmc < 1, de plus elle reste toujours stable.
   -------------------------------
  
 ; concurrence parfaite 
 ; 1) choix du consommateur : demande concurrentielle (surplus et utilité indirecte (effet revenu/effet substitution)), demande
 ; 2) concurrence parfaite : choix intemporel, valeur actuelle = , richesse, capital humain, revenu permanent, cycle de vie)
  
   -------------------------------
   
   ;           paysan / Citoyen /entreprise
    ; 1/ achats pour exploiter les terres agricoles selon les trois modes d'agriculture Production, profil, maximise son utilité (quotidiennenement)
  ; A) achat de matières premières : pourcentage du budget
  ; B) achat de produit semi-finis : pourcentage du budget
  ; C) Achat de Biens et services : pourcentage du budget (autres que ce produits)
  ; D) dons : attribuer une valeur monétaire à rajouter aux revenus 
  ; E) sanction achat illégaux ou exploitation illégale : pourcentage du revenu 
  
 
  
  
  
  end 
  
  

to start
  repeat nbIterate [
    iterate
    tick
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
0
0
724
779
-1
-1
17.0
1
10
1
1
1
0
1
1
1
0
41
0
43
0
0
1
0
1
ticks

SLIDER
36
24
208
57
NbPeasants
NbPeasants
0
100
50
1
1
NIL
HORIZONTAL

BUTTON
51
84
114
117
Init
init
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
61
135
150
168
Start
start
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
18
244
195
277
nbdeviants
nbdeviants
0
100
0
1
1
%
HORIZONTAL

SLIDER
18
277
195
310
forestPercentage
forestPercentage
0
100
43
1
1
%
HORIZONTAL

SLIDER
20
310
196
343
nbGovernments
nbGovernments
0
100
50
1
1
NIL
HORIZONTAL

SLIDER
20
344
196
377
nbInternationalOrganizations
nbInternationalOrganizations
0
100
60
1
1
NIL
HORIZONTAL

SLIDER
19
377
197
410
nbMinistryOfEnvironments
nbMinistryOfEnvironments
0
100
64
1
1
NIL
HORIZONTAL

SLIDER
18
409
197
442
nbMinistryOfAgricultures
nbMinistryOfAgricultures
0
100
49
1
1
NIL
HORIZONTAL

SLIDER
18
442
198
475
nbOtherMinistries
nbOtherMinistries
0
100
50
1
1
NIL
HORIZONTAL

SLIDER
18
474
198
507
nbONEFs
nbONEFs
0
100
65
1
1
NIL
HORIZONTAL

SLIDER
18
506
198
539
nbRegionalAuthorities
nbRegionalAuthorities
0
100
40
1
1
NIL
HORIZONTAL

SLIDER
18
539
197
572
nbDREFs
nbDREFs
0
100
72
1
1
NIL
HORIZONTAL

SLIDER
18
570
198
603
nbTownships
nbTownships
0
100
50
1
1
NIL
HORIZONTAL

SLIDER
18
603
198
636
nbLocalCommunities
nbLocalCommunities
0
100
50
1
1
NIL
HORIZONTAL

SLIDER
18
636
197
669
nbFokontany
nbFokontany
0
100
50
1
1
NIL
HORIZONTAL

SLIDER
18
669
197
702
nbFokonolona
nbFokonolona
0
100
56
1
1
NIL
HORIZONTAL

SLIDER
19
703
198
736
nbFirm
nbFirm
0
100
50
1
1
NIL
HORIZONTAL

SLIDER
19
737
198
770
nbCitizens
nbCitizens
0
100
50
1
1
NIL
HORIZONTAL

SLIDER
19
770
199
803
nbPeasants
nbPeasants
0
100
50
1
1
NIL
HORIZONTAL

SLIDER
20
801
199
834
nbExploitations
nbExploitations
0
100
49
1
1
NIL
HORIZONTAL

SLIDER
21
836
252
869
nbInternationalGovernments
nbInternationalGovernments
0
100
50
1
1
NIL
HORIZONTAL

SLIDER
26
190
198
223
pSize
pSize
0
100
17
1
1
px
HORIZONTAL

INPUTBOX
1015
29
1170
89
nbIterate
0
1
0
Number

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

person construction
false
0
Rectangle -7500403 true true 123 76 176 95
Polygon -1 true false 105 90 60 195 90 210 115 162 184 163 210 210 240 195 195 90
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Circle -7500403 true true 110 5 80
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -955883 true false 180 90 195 90 195 165 195 195 150 195 150 120 180 90
Polygon -955883 true false 120 90 105 90 105 165 105 195 150 195 150 120 120 90
Rectangle -16777216 true false 135 114 150 120
Rectangle -16777216 true false 135 144 150 150
Rectangle -16777216 true false 135 174 150 180
Polygon -955883 true false 105 42 111 16 128 2 149 0 178 6 190 18 192 28 220 29 216 34 201 39 167 35
Polygon -6459832 true false 54 253 54 238 219 73 227 78
Polygon -16777216 true false 15 285 15 255 30 225 45 225 75 255 75 270 45 285

person doctor
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -13345367 true false 135 90 150 105 135 135 150 150 165 135 150 105 165 90
Polygon -7500403 true true 105 90 60 195 90 210 135 105
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -1 true false 105 90 60 195 90 210 114 156 120 195 90 270 210 270 180 195 186 155 210 210 240 195 195 90 165 90 150 150 135 90
Line -16777216 false 150 148 150 270
Line -16777216 false 196 90 151 149
Line -16777216 false 104 90 149 149
Circle -1 true false 180 0 30
Line -16777216 false 180 15 120 15
Line -16777216 false 150 195 165 195
Line -16777216 false 150 240 165 240
Line -16777216 false 150 150 165 150

person farmer
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 60 195 90 210 114 154 120 195 180 195 187 157 210 210 240 195 195 90 165 90 150 105 150 150 135 90 105 90
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -13345367 true false 120 90 120 180 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90 172 89 165 135 135 135 127 90
Polygon -6459832 true false 116 4 113 21 71 33 71 40 109 48 117 34 144 27 180 26 188 36 224 23 222 14 178 16 167 0
Line -16777216 false 225 90 270 90
Line -16777216 false 225 15 225 90
Line -16777216 false 270 15 270 90
Line -16777216 false 247 15 247 90
Rectangle -6459832 true false 240 90 255 300

person graduate
false
0
Circle -16777216 false false 39 183 20
Polygon -1 true false 50 203 85 213 118 227 119 207 89 204 52 185
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -8630108 true false 90 19 150 37 210 19 195 4 105 4
Polygon -8630108 true false 120 90 105 90 60 195 90 210 120 165 90 285 105 300 195 300 210 285 180 165 210 210 240 195 195 90
Polygon -1184463 true false 135 90 120 90 150 135 180 90 165 90 150 105
Line -2674135 false 195 90 150 135
Line -2674135 false 105 90 150 135
Polygon -1 true false 135 90 150 105 165 90
Circle -1 true false 104 205 20
Circle -1 true false 41 184 20
Circle -16777216 false false 106 206 18
Line -2674135 false 208 22 208 57

person lumberjack
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -2674135 true false 60 196 90 211 114 155 120 196 180 196 187 158 210 211 240 196 195 91 165 91 150 106 150 135 135 91 105 91
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -6459832 true false 174 90 181 90 180 195 165 195
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -6459832 true false 126 90 119 90 120 195 135 195
Rectangle -6459832 true false 45 180 255 195
Polygon -16777216 true false 255 165 255 195 240 225 255 240 285 240 300 225 285 195 285 165
Line -16777216 false 135 165 165 165
Line -16777216 false 135 135 165 135
Line -16777216 false 90 135 120 135
Line -16777216 false 105 120 120 120
Line -16777216 false 180 120 195 120
Line -16777216 false 180 135 210 135
Line -16777216 false 90 150 105 165
Line -16777216 false 225 165 210 180
Line -16777216 false 75 165 90 180
Line -16777216 false 210 150 195 165
Line -16777216 false 180 105 210 180
Line -16777216 false 120 105 90 180
Line -16777216 false 150 135 150 165
Polygon -2674135 true false 100 30 104 44 189 24 185 10 173 10 166 1 138 -1 111 3 109 28

person police
false
0
Polygon -1 true false 124 91 150 165 178 91
Polygon -13345367 true false 134 91 149 106 134 181 149 196 164 181 149 106 164 91
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -13345367 true false 120 90 105 90 60 195 90 210 116 158 120 195 180 195 184 158 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Polygon -13345367 true false 150 26 110 41 97 29 137 -1 158 6 185 0 201 6 196 23 204 34 180 33
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Rectangle -16777216 true false 109 183 124 227
Rectangle -16777216 true false 176 183 195 205
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Polygon -1184463 true false 172 112 191 112 185 133 179 133
Polygon -1184463 true false 175 6 194 6 189 21 180 21
Line -1184463 false 149 24 197 24
Rectangle -16777216 true false 101 177 122 187
Rectangle -16777216 true false 179 164 183 186

person service
false
0
Polygon -7500403 true true 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -1 true false 120 90 105 90 60 195 90 210 120 150 120 195 180 195 180 150 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Polygon -1 true false 123 90 149 141 177 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -2674135 true false 180 90 195 90 183 160 180 195 150 195 150 135 180 90
Polygon -2674135 true false 120 90 105 90 114 161 120 195 150 195 150 135 120 90
Polygon -2674135 true false 155 91 128 77 128 101
Rectangle -16777216 true false 118 129 141 140
Polygon -2674135 true false 145 91 172 77 172 101

person soldier
false
0
Rectangle -7500403 true true 127 79 172 94
Polygon -10899396 true false 105 90 60 195 90 210 135 105
Polygon -10899396 true false 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Polygon -10899396 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -6459832 true false 120 90 105 90 180 195 180 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Rectangle -6459832 true false 120 193 180 201
Polygon -6459832 true false 122 4 107 16 102 39 105 53 148 34 192 27 189 17 172 2 145 0
Polygon -16777216 true false 183 90 240 15 247 22 193 90
Rectangle -6459832 true false 114 187 128 208
Rectangle -6459832 true false 177 187 191 208

person student
false
0
Polygon -13791810 true false 135 90 150 105 135 165 150 180 165 165 150 105 165 90
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 100 210 130 225 145 165 85 135 63 189
Polygon -13791810 true false 90 210 120 225 135 165 67 130 53 189
Polygon -1 true false 120 224 131 225 124 210
Line -16777216 false 139 168 126 225
Line -16777216 false 140 167 76 136
Polygon -7500403 true true 105 90 60 195 90 210 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 3D 4.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
