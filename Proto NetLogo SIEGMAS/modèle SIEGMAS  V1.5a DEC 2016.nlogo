; -------------------------------------------------------------------------------
; SIEGMAS
; AN AGENT-BASED SYSTEM FOR STAKEHOLDERS INTERACTIONS IN ENVIRONNEMENTAL GOVERNANCE
;
; V 1.5a dec  2016 : Complete the scenario and the interface with a time line, cleaning a part of the code
; V 1.5  sept 2016 : The scénario are now implemented
; V 1.4c mars 2016 : Damien et daniel : add scenarios interfaces, use extention Pathdir and XW
; V 1.4b 2015      : Add agent knowledge variable
; V 1.4a 2015      : Add expôrt of csv files + Manage a deterioration Level List
; V 1 3c 2015      : Add plots for a list of selected agents
; -------------------------------------------------------------------------------


; -------------------------------------------------------------------------------
; NetLogo's extensions
; -------------------------------------------------------------------------------
;Pathdir by Charles Staelin : An extension for working with files and directories in NetLogo.
;Pathdir provides tools for finding the name of the current model, the current working, user and model directories;
;creating, moving, renaming, identifying and deleting directories; and listing the contents of directories.
;Pathdir also allows one to find the size and modification date of files.
;download https://github.com/cstaelin/Pathdir-Extension/releases

extensions [pathdir xw]

; ===============================================================================
; -------------------------------------------------------------------------------
; Global variables

globals [

  ;; globale variables
  x y     ; temp x and y coordinate
  g_vrai? ; temp Boolean var

  ;; Map info init by masc
  g_mapContext            ; name of the current map processed by the model, default "Default map"
  g_defaultColor          ; invalid Area for agents location default "white"
  g_csvPlotsExportFile    ; csv file name
  g_plotExportFileName    ; file name for plot one agent;; AJOUT DANIEL
  g_lessDeterioratedList ; less deteriorated map zones

  ;; IHM management
  g_agentInspector       ; message that appears on the node properties monitor
  g_dist
  g_ExternalHelpLinksColor
  g_OperatorLinksColor
  g_ManagerLinksColor
  g_hideExternalHelpLinks?
  g_hideOperatorLinks?
  g_hideManagerLinks?
  g_showDeterorationLevel?
  g_showDevianceLevel?
  g_watchMaxDeviant?
  g_agentToInspect
  g_stopHighlight?
  g_lastNode
  g_cpt        ; if > 100 => stop the process to find a valid agent area
  g_agentIdToPlot1 g_agentIdToPlot2 g_agentIdToPlot3 g_agentIdToPlot4 g_agentIdToPlot5 g_agentIdToPlot6
  g_mouseysave
  g_mousexsave
  g_time_line

  ;;;;;;;;;;;;;;;;; DEBUT AJOUT DANIEL;;;;;;;;;;;;;;;;
  g_csvExtFile
  g_listAgentToPlot ; list for plot
  g_listPlotName    ; list plotName pour contenir les noms
  g_strDateTime
  g_sep             ; OS separator for directory and subdirectory
  g_dirMaps         ; Maps directory
  g_modelPath       ; Path of the model
  g_listRegion      ; List with valid region name directory start with "1_"
  ;;;;;;;;;;;;;; Fin AJOUT DANIEL ;;;;;;;;;;;;;;
]

; ===============================================================================
; -------------------------------------------------------------------------------
; Types of Agents used by SIEGMAS (from JFSMA15'paper)

; stakeholders agents -------
breed [managers manager]
;->Typology of managers
;breed [StateMinistrys StateMinistry]
;breed [Decentralizedbodys Decentralizedbody]
;breed [BasicCommunitys Decentralizedbody]
breed [operators operator]
;->Typology of operator
;breed [Farmers Farmer]
;breed [Firms Firm]
breed [externalHelps externalHelp]
;->Typology of externalHelps
;breed [ForeignGovernments ForeignGovernment]
;breed [Backers Backer]
;breed [Associations Association]

; Resources agents ------
breed [naturalResources naturalResource]
;->Typology of naturalResources
; Bio
; Con
; Snb
breed [exploitations exploitation]
;->Typology of exploitations
; FallowLand
; ArableLand
; Forest

; -------------------------------------------------------------------------------
; Environment specification (adding custom patch variables)
patches-own [
  isForest             ; Boolean - 1 if the patch is a forest else 0
  isOwned              ; Boolean - 1 if terran is officially owned by a peasant
  deteriorationLevel   ; Integer - percentage of level of deterioration
  isProtected          ; Boolean - determines if this patch (normaly non exploited patch) is protected by a law
  savePatchColor       ; Color   - used to save the init patch color
  devianceAffordance   ; Color   - Used to express the deviance influence between agents
]

; -------------------------------------------------------------------------------
; Agents Specification (adding custom turtles variables)
turtles-own [
  devianceLevel        ; Integer between 0 to 100
  subtype              ; for example "ForeignGovernments" for an externalHelp
  knowledge            ; knowledge of environment protection policies (integer between 0 and 4)  pourcentage now
  influence            ; integer between -100 and 100
  money                ; Float - available money in euros
  rentability          ;
  revenu
  result_exploi
  impots
]

directed-link-breed [isHelpBys isHelpBy] ; used by manager agents
directed-link-breed [isExploitedBys isExploitedBy] ; used by Exploitation agents
directed-link-breed [isManagedBys isManagedBy] ; used by operator agents

managers-own [
  interaction          ; 100 / number of links
  interaction_o        ; weight of the interaction with operators
  interaction_eh       ; weight of the interaction with externalhelps
  nb_link
  transfert_financial_help
  collecte_impots
  nb_in_link
  nb_out_link
]

operators-own [
  plots                ; Integer - number of owned patch
  interaction
  nb_link
]

externalHelps-own [
  interaction
  sub_type
  nb_link
]

exploitations-own [
  bio                  ; Float - percentage of bio agriculture
  con                  ; Float - percentage of conventional agriculture
  snb                  ; Float - percentage of slash and burn agriculture
  owner                ; Integer - identificator of the owner
]

; ===============================================================================
; -------------------------------------------------------------------------------
; Initialisation of the simulation

to setup
  clear-all
  resize-world 0 0 0 0
  set nbIterate 100 ; by default
  set g_cpt 0
  set g_time_line "0 years 0 months"

  show g_lessDeterioratedlist

  if g_debug? [ print "========== New setup" print "*** INIT VARS"]

  ; init patches
  ; ifelse initByMasc?
  ifelse (Territory = "Default" )
    [ defaultMapInit ] ; initialisation by the default procedure
    [ initMapWithMasc  ; initialisation by a map build with MASC
      ask patches [ if (is-list? pcolor) [ set pcolor approximate-rgb (first pcolor) (first but-first pcolor) (last pcolor) ]] ; Mise au format Netlogo Color
      if g_debug? [ type " ** Default RGB Color: " print g_defaultColor]
      if (is-list? g_defaultColor) [ set g_defaultColor approximate-rgb (first g_defaultColor) (first but-first g_defaultColor) (last g_defaultColor)]
    ]

  if (g_mapContext != "Nill")
    [
      output-print word "map:" g_mapContext

      if g_debug? [
        type " ** Default NetLogo Color: " print g_defaultColor
        type " ** (max-pxcor, max-pycor): (" type (max-pxcor) type "," type (max-pycor) print ")"
      ]

      ; save patches Color for IHM switch
      ask patches [ set savePatchColor pcolor]

      ; init IHM vars for environment
      set g_dist 10 / 100 * min list (max-pxcor) (max-pycor)
      set g_hideExternalHelpLinks? TRUE
      set g_hideOperatorLinks? TRUE
      set g_hideManagerLinks? TRUE
      set g_showDeterorationLevel? FALSE
      set g_showDevianceLevel? TRUE
      set g_watchMaxDeviant? FALSE
      set g_diffusion-rate 2
      set g_ExternalHelpLinksColor violet
      set g_OperatorLinksColor green
      set g_ManagerLinksColor Yellow - 2
      set g_csvPlotsExportFile "plots.csv"
      set g_plotExportFileName "plot"
      set g_csvExtFile ".csv"

      ;; init Siegmas agents
      output-print "Creation of agents... "

      ifelse g_mapContext = "Default map"
        [ ; agents initialisation by the default procedure
          defaultAgentInit ]
        [ ; agents initialisation by a costom procedure
          customAgentInit ]

      ;; init IHM vars for agents
      set g_agentToInspect turtle 0 ;  default value
      set g_lastNode turtle 0 ;  default value
      set g_agentInspector ("Select <Highlight Agent> button and move the mouse on the map to get agent data")
      set g_stopHighlight? FALSE

      ;; set agents to plot (2 managers, 2 operators and 2 external helps) -> no deviance for natural resources !!
      set g_agentIdToPlot1 one-of Managers
      ask g_agentIdToPlot1 [ set g_agentIdToPlot2 one-of other Managers ]
      set g_agentIdToPlot3 one-of Operators
      ask g_agentIdToPlot3 [ set g_agentIdToPlot4 one-of other Operators ]
      set g_agentIdToPlot5 one-of ExternalHelps
      ask g_agentIdToPlot5 [ set g_agentIdToPlot6 one-of other ExternalHelps ]

      ;; init plots for agents

      set g_listAgentToPlot (list g_agentIdToPlot1 g_agentIdToPlot2 g_agentIdToPlot3 g_agentIdToPlot4 g_agentIdToPlot5 g_agentIdToPlot6 )
      set g_listPlotName []

      output-print ("    Agents specicaly followed by plot : ")
      let lindex 0
      foreach g_listAgentToPlot [
        set lindex lindex + 1
        if (is-turtle? ?)[
          set g_listPlotName lput (word "Agent ID" lindex ) g_listPlotName
          ask ? [
            let xposition [xcor] of ?
            let yposition [ycor] of ?
            output-print ( word "    - Agent" ? " x,y = " xposition "," yposition )
          ]
        ]
      ]

      ;; init path for files management
      init_working_contexte

      output-print "Initialisation OK"
      output-print "<Highlight> to inspect agents on the map"
      output-print "<Go> to Start the simulation"

      reset-ticks
    ]
end

; -------------------------------------------------------------------------------
; agents initialisation by the default procedure
to defaultAgentInit

  ;create resources
  createNaturalResources
  createExploitations

  ;createstakeholders
  createOperators
  createManagers
  createExternalHelps

  ;définir les types des stakeholders
  manager_type
  operator_type
  externalhelp_type

  ;calculer la variable money  au tick 0
  calculate_begin_money_manager
  calculate_begin_money_operator
  calculate_begin_money_externalhelp

  ;calcul du revenu des stakeholders
  calculate_revenu_manager
  calculate_revenu_operator
  calculate_revenu_externalhelp

  ;calcul des resultats d'exploitation des stakeholders
  calculate_resultexploi_manager
  calculate_resultexploi_operator

  ;calcul interaction stakeholders (manager gère cela seul car il est "au centre" des liens entre les stakeholders
  calculate_interaction_manager

  ;calcul influence stakeholders
  calculate_influence_manager
  calculate_influence_operator
  calculate_influence_externalhelp

  ;calcul impots stakeholders
  calculate_impot_manager
  calculate_impot_operator
  calculate_impot_externalhelp

  ; calcul rentabilité stakeholders
  calculate_rentability_manager
  calculate_rentability_operator
  calculate_rentability_externalhelp
end

;----------------------------------
; init the contexte to manage files
to init_working_contexte
  xw:clear-all ; remove all previous extra tabs and widgets.

  ;print "Get the name of this model: pathdir:get-model-name"
  ;print "Get the path to the model: pathdir:get-model-path"
  set g_modelPath pathdir:get-model-path
  set g_sep pathdir:get-separator
  set g_dirMaps (word g_modelPath g_sep "data" g_sep "maps")
  set g_listRegion []
  ;print "Strip the extension from the model name"
  ;set name substring name 0 (length name - position "." reverse name - 1)
  ;show name
  ;print "Put the model file and the path to it together"
  ;show (word pathdir:get-model-path pathdir:get-separator pathdir:get-model-file)

  set g_listRegion lput "Default" g_listRegion
  if-else pathdir:isDirectory? g_dirMaps [
    print "That subdirectory is:"
    show first g_dirMaps
    print "And its valid listing is:"
    let subDirectoryMaps pathdir:list g_dirMaps
    foreach subDirectoryMaps [
      if (first ? = "1" ) [
        show ?
        show substring ? 2 ( length ? )
        set g_listRegion lput ( substring ? 2 ( length ? ) ) g_listRegion
      ]
    ]
    let nbItems length g_listRegion
        show nbItems
   ]
   [show (word " \"." g_sep "data" g_sep "maps \" not found in model directory\n") ]

   xw:create-tab "xwTab1" [ ; we use "t1" as the key for our new tab
     ; and set its properties within a command block:
     xw:set-title "Parameters"
   ]

   xw:create-chooser "xwTerritory" [
     xw:set-label "Territory"
     xw:set-items g_listRegion
     xw:set-selected-item "Default"
   ]

  xw:create-button "xwDetails" [
    xw:set-label "Details"
    xw:set-x [ xw:x + xw:width + 10 ] xw:of "xwTerritory"
    xw:set-commands "details"
  ]
  xw:create-note "xwNoteDetails" [
    xw:set-height 600
    xw:set-width 800
    xw:set-color grey
    xw:set-opaque? true
    xw:set-y [ xw:y + xw:height + 10 ] xw:of "xwTerritory"
  ]
end

;;----------------------------------------------------------------------------------------
;;;; Functions to set and manage agent internal value

to calculate_interaction_manager

 ask managers [
    set nb_link count my-links      ;;; Pour les Managers le nombre de lien représentente ses liens entrants (les ExternalHelps) + ses liens sortants (les Operators)
    ifelse (nb_link != 0)                                ;;; Si le nombre de lien est supérieur à zéro ...
      [set interaction (100 / (nb_link))]                ;;; Interaction vaut 100 / le nombre de liens
      [set interaction 0]                                ;;; Sinon (si le nombre de liens vaut au moins 1) interaction prend la valeur 0

    let po (random 11 / 10)                              ;;; Pour ajouter un poids au différents liens on utilise un nombre alétoire entre 0 et 10 que l'on divise par 10 pour avoir le poids des liens vers les opérateurs => possible 1/10 ou alors 6/10 etc ...
    let peh 1 - po                                       ;;; Pour le poids des ExternalHelps on fait simplement un 1 - le poids opérateur calculer juste avant

    ifelse (count out-link-neighbors > 0)
      [set interaction_o (po) * interaction]               ;;; on multiplie (si le nombre de liens ne vaut pas zéro) le poids operateur à l'interaction total pour avoir le poids du lien (manager - operator)
      [set interaction_o 0]

    ifelse (count in-link-neighbors > 0)
      [set interaction_eh interaction - interaction_o]  ;;; pour avoir le poids du lien manager-externalHelps, on fait une soustraction entre l'interaction total et le poids du lien manager-operator (calculé juste avant)
      [set interaction_eh 0]
  ]
end

;; calulate influence -----------------------------------------------------------------------------------
;; evaluate the power of influence of an agent on other agents link to it by analysing its social network
to calculate_influence_manager
  ask managers [
    let vsocial sce_social * 50
    ;;; si le manager a plus que deux liens son influence va augmenter (ou diminuer si deviance elevée) plus ou moins fortement en fonction de son nombre de liens
    set influence ((interaction - devianceLevel) * (nb_link / 2) + (sce_social * 50))
    check_influence
  ]
end

to calculate_influence_operator
  ask operators [
    let vsocial sce_social * 50
    set influence ((interaction - devianceLevel) * (nb_link / 2) + (sce_social * 50))   ;;; Ici on peut voir que si le manager a plus que deux liens son influence va augmenter (ou diminué si deviance elevée) plus ou moins fort en fonction de son nombre de liens
    check_influence
  ]
end

to calculate_influence_externalhelp
  ask externalhelps [

    let vsocial sce_social * 50
    set influence ((interaction - devianceLevel) * (nb_link / 2) + (sce_social * 50))      ;;; Ici on peut voir que si le manager a plus que deux liens son influence va augmenter (ou diminué si deviance elevée) plus ou moins fort en fonction de son nombre de liens
    check_influence
  ]
end

;; check_influence :
;; Working procedure juste to factorise the code for influence value checking
;; the max influence value for an agent is 100 and the min is -100
to check_influence
    if (influence > 100)  [set influence 100]
    if (influence < -100) [set influence -100]
end

;; refine the types of agents -----------------------------------------------------------------------------------
;; sub types are define randomly with specifig rules for each agent type
to manager_type
  ask managers [
    if-else (random 2 = 0 )  [set subtype "village" ] ; 50% of chance between "regonial_authority" and "own_country"
    [ if-else(random 2 = 0)
      [set subtype "regonial_authority"]
      [set subtype "own_country" ]
    ]
  ]
end

to calculate_begin_money_manager
  ask managers [
    if (subtype = "village") [ set money (random 20000 + 30000) + (30000 * sce_eco) ]
    if (subtype = "regional_authority") [ set money (random 30000 + 50000) + (50000 * sce_eco) ]
    if (subtype = "own_country")[ set money (random 50000 + 100000) + (100000 * sce_eco) ]
  ]
end

to operator_type
  ask operators [
    if-else (random 2 = 0 )  [set subtype "farmer"] ; 50% de chance
      [if-else(random 3 = 0)
        [set subtype "cooperative"]
        [set subtype "company" ]
      ]
  ]
end

to calculate_begin_money_operator
  ask operators [
    if subtype = "farmer" [ set money (random 500 + 5000) + (5000 * sce_eco) + 1 ]
    if subtype = "cooperative" [ set money (random 800 + 10000) + (10000 * sce_eco) + 1  ]
    if subtype = "company" [ set money (random 2000 + 20000) + (20000 * sce_eco) + 1]
  ]
end

to externalhelp_type
  ask externalhelps [
     if-else (random 2 = 0 )  [ set subtype "association" ] ; 50% de chance
     [ if-else(random 3 = 0)
       [set subtype "funder"]
       [set subtype "foreignGovernment" ]
     ]
  ]
end

to calculate_begin_money_externalhelp
  ask externalhelps [
    if subtype = "association" [ set money (random 5000 + 5000) + (5000 * sce_eco) + 1]
    if subtype = "funder" [ set money (random 10000 + 10000) + (10000 * sce_eco) + 1]
    if subtype = "foreignGovernment" [ set money (random 50000 + 50000) + (50000 * sce_eco) + 1 ]
  ]
end

to calculate_revenu_manager
  ask managers [
    let nb_exploi (count out-link-neighbors + 1)                               ;;; calcul du nombre d'exploitation possédé par un operator (nombre de lien sortant + le sien)
    let salary 5000 + (3000 * sce_eco)                                         ;;; salaire moyen que touche un agriculteur (tout du moins pour la Réunion
    let chiff_aff ((random 4 + 1) * salary)                                    ;;; calcul du chiffre d'affaire => entre une et cinq fois plus que le salaire
    let taxes ((nb_exploi * 90) + (chiff_aff * (0.3 + (-0.2 * sce_eco))))      ;;; calcul des taxes => 20 % du chiffre d'affaire + 90 multiplié par le nombre d'exploitation
    let amende (200 + (-200 * sce_eco) * devianceLevel)                        ;;; Plus l'operator est déviant plus il va payer des amendes

    set revenu (salary + chiff_aff - taxes - amende)         ;;; REVENU = SALAIRE + CHIFFRE D'AFFAIRE - TAXES - AMENDES
  ]
end

to calculate_revenu_operator
  ask operators [
    let nb_exploi (count out-link-neighbors + 1)                               ;;; calcul du nombre d'exploitation possédé par un operator (nombre de lien sortant + le sien)
    let salary 1500 + (1000 * sce_eco)                                         ;;; salaire moyen que touche un agriculteur (tout du moins pour la Réunion
    let chiff_aff ((random 4 + 1) * salary)                                    ;;; calcul du chiffre d'affaire => entre une et cinq fois plus que le salaire
    let taxes (nb_exploi * 90) + (chiff_aff * (0.3 + (-0.2 * sce_eco)))        ;;; calcul des taxes => 20 % du chiffre d'affaire + 90 multiplié par le nombre d'exploitation
    let amende (100 + (-100 * sce_eco) * devianceLevel)                        ;;; Plus l'operator est déviant plus il va payer des amendes

    set revenu (salary + chiff_aff - taxes - amende)                           ;;; REVENU = SALAIRE + CHIFFRE D'AFFAIRE - TAXES - AMENDES
  ]
end

to calculate_revenu_externalhelp
  ask externalhelps [
    set revenu random 5000
  ]
end

to calculate_impot_manager
  ask managers [
    ifelse revenu > 0
    [set impots ((revenu * 0.5) + ((revenu * 0.3) * (- sce_eco)))]
    [set impots 0]
  ]
end

to calculate_impot_operator
  ask operators [
    ifelse revenu > 0
    [set impots ((revenu * 0.3) + ((revenu * 0.2) * (- sce_eco)))]
    [set impots 0]
  ]
end

to calculate_impot_externalhelp
  ask externalhelps [
    ifelse revenu > 0
    [set impots ((revenu * 0.1) + ((revenu * 0.075) * (- sce_eco)))]
    [set impots 0]
  ]
end

to calculate_resultexploi_manager
  ask managers [

                                                                   ;;; Version compliqué ! ;;;


    ;;;;;;;;;;; TOTAL PRODUITS D'EXPLOITATION ;;;;;;;;;;

    ;let pro_immo (random 3 * 20000 + nb_exploi * 20000) + (50000 * sce_eco)                           ;;; Production immobilisée : Marchandises supérieur à 100 000
    ;let subvention ((4000 + (3000 * sce_eco)) * nb_exploi)                                            ;;; Subventions : 4000 € fois le nombre d'exploitation
    ;let other_pro_exploi ((random 7000 + 2000) + (5000 * sce_eco)) * nb_exploi                        ;;; Achat divers et ponctuel de l'operator

    ;let sum_pro_exploi pro_immo + subvention + other_pro_exploi                                       ;;; PRODUIT D'EXPLOITATION = SOMME DE TOUTES LES VALEURS CI DESSUS


                                                                                                       ;;;;;;;;;;; TOTAL CHARGES D'EXPLOITATION ;;;;;;;;;;;;
    ;let raw_materials (10000 + random 10000) + (10000 * sce_eco)
    ;let buy_stuff (random 3 * 50000 + nb_exploi * 10000) * (70000 * sce_eco)                          ;;; Achat divers et variés (0, 100 000 ou 200 000 € ~ variable très random)
    ;let salary_to_pay (random 10 + 1) * 2000 * nb_exploi                                              ;;; Les salaires à payer ( augment en fonction du nombre d'exploitation que l'operator possède
    ;let social_cotisation (revenu * (0.2 + (-0.1 * sce_eco)))                                         ;;; Les cotisation sociales => 33 % du revenu
    ;set impots (revenu * (0.5 + ( -0.15 * sce_eco)))                                                  ;;; Les Impots => 20 % de ton revenu

    ;let sum_charges_exploi raw_materials + buy_stuff + salary_to_pay + social_cotisation + impots     ;;; CHARGES D'EXPLOITATION = SOMME DE TOUTES LES VALEURS CI DESSUS

   ; set result_exploi sum_pro_exploi - sum_charges_exploi                                             ;;; RESULTATS D'EXPLOITATION = PRODUCTION D'EXPLOITATION - CHARGES D'EXPLOITATION



                                                                  ;;; Version simplifié ! ;;;

    ;set result_exploi random (revenu * (sce_eco * 10) + revenu * 0.35 ) - random ( revenu * (sce_eco * 10))


    let p_eco random (sce_eco * 10) ; poids aléatoire basée sur le scénario economique pour calculer le resultat exploitation

    let pro_exploi ( p_eco + 0.5 ) * abs revenu
    let charges_exploi ( -1 * p_eco ) * abs revenu
    set result_exploi pro_exploi - charges_exploi

  ]

end

to calculate_resultexploi_operator

  ask operators [

                                                                   ;;; Version compliqué !!! ;;;

    ;;;;;;;;;;; TOTAL PRODUITS D'EXPLOITATION ;;;;;;;;;;

    ;let pro_stock (random 2000 * nb_exploi) + (2000 * sce_eco)                                        ;;; Production stockée :
    ;let pro_immo (random 3 * 50000 + nb_exploi * 15000) + (50000 * sce_eco)                                              ;;; Production immobilisée : Marchandises supérieur à 100 000
    ;let subvention (4000 + (3000 * sce_eco)) * nb_exploi                                              ;;; Subventions : 4000 € fois le nombre d'exploitation
    ;let other_pro_exploi (random 5000 + 1500) * nb_exploi + (2000 * sce_eco)                          ;;; Achat divers et ponctuel de l'operator

    ;let sum_pro_exploi pro_stock + pro_immo + subvention + other_pro_exploi                           ;;; PRODUIT D'EXPLOITATION = SOMME DE TOUTES LES VALEURS CI DESSUS


    ;;;;;;;;;;; TOTAL CHARGES D'EXPLOITATION ;;;;;;;;;;;;

    ;let buy_stuff random 3 * 50000 + nb_exploi * 10000 + (6000 * sce_eco)                             ;;; Achat divers et variés (0, 100 000 ou 200 000 € ~ variable très random)
    ;let salary_to_pay (random 5 + 1) * 1500 * nb_exploi                                               ;;; Les salaires à payer ( augment en fonction du nombre d'exploitation que l'operator possède
    ;let social_cotisation (revenu * (0.2 + (-0.1 * sce_eco)))                                         ;;; Les cotisation sociales => 33 % du revenu
    ;set impots (revenu * (0.2 + (-0.15 * sce_eco)))                                                   ;;; Les Impots => 20 % de ton revenu

    ;let sum_charges_exploi buy_stuff + salary_to_pay + social_cotisation + impots                     ;;; CHARGES D'EXPLOITATION = SOMME DE TOUTES LES VALEURS CI DESSUS



    ;set result_exploi sum_pro_exploi - sum_charges_exploi                                             ;;; RESULTATS D'EXPLOITATION = PRODUCTION D'EXPLOITATION - CHARGES D'EXPLOITATION

                                                                 ;;; Version simplifié !!! ;;;

    ;set result_exploi random (revenu * (sce_eco * 10) + revenu * 0.35 ) - random ( revenu * (sce_eco * 10))

    let p_eco random (sce_eco * 10) ; poids aléatoire basée sur le scénario economique pour calculer le resultat exploitation

    let pro_exploi ( p_eco + 0.35 ) * abs revenu
    let charges_exploi ( -1 * p_eco ) * abs revenu
    set result_exploi pro_exploi - charges_exploi

  ]

end


to calculate_rentability_manager
  ask managers [
     set rentability (result_exploi - impots) / (money + 1)
  ]
end

to calculate_rentability_operator
  ask operators [
     set rentability (result_exploi - impots) / money
  ]
end

to calculate_rentability_externalhelp
  ask externalhelps  [
     set rentability (result_exploi - impots) / money
  ]
end


; -------------------------------------------------------------------------------
to customAgentInit
  ; to be define depending on context
  defaultAgentInit ; @RC TODO a personnaliser
end

__includes["initMapWithMascGeneratedCode.nls"]

; -------------------------------------------------------------------------------
to initMapWithMasc
  ; *** Call to external file code generated by MASC ***
  ifelse (Territory != "nill")
    [
      initmap
      output-print "Buildind environment... "

      ask patches [
        ifelse (isInvalidArea?)
        [ set deteriorationLevel 0]
        [ ifelse (member? pcolor g_lessDeterioratedlist)
          [ set deteriorationLevel random min list 90 ((position pcolor g_lessDeterioratedlist) * 10) ]
          [ set deteriorationLevel random 100]
        ]
      ]

      ; test if the initialisation map is not to small
      if max-pxcor < 20 or max-pycor < 20 [
        user-message ("Switch initByMasc? to Off, or insert code generated by MASC see the procedure initMapWithMascGeneratedCode.")
        set g_mapContext "Nill" ;; @RC TODO tester le nom de la carte donner dans le fichier generer par
      ]
    ]
    [
      user-message ("Not yet implemented")
      set g_mapContext "Nill" ;; @RC TODO tester le nom de la carte donner dans le fichier generer par
      stop
    ]
end

; -------------------------------------------------------------------------------
; a default MapInit
to defaultMapInit
  set g_mapContext "Default map"
  set-patch-size 15.4
  resize-world 0 41 0 43
  set g_defaultColor white
  output-print "Buildind environment... "

  ; init patches with default value
  ask patches [
    set pcolor white
    set isForest 0
    set deteriorationLevel random 100
  ]

  ; set the given percentage of agriculture in patches randomly on the word
  if g_debug? [type " ** Number of crop patches: " print (floor (count patches * agriculture% / 100))]
  ask n-of (floor (count patches * agriculture% / 100)) patches [
    ; set color to brown (more darker -> more healthy)
    set pcolor scale-color green deteriorationLevel 0 100
  ]

  ; set the given percentage of forest in patches randomly on the word
  if g_debug? [type " ** Number of forest patches: " print (floor (count patches * forest% / 100))]
  ask n-of ( floor (count patches * forest% / 100)) patches [
    ; set color to green (more darker -> more healthy)
    set pcolor scale-color brown deteriorationLevel 0 100
    set isForest 1
  ]
end

; --- ------------------------------------------------------Création d'agent Manager ---------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------

to createManagers
  if g_debug? [print (word "*** Creating " nbManagers " manager agents")]
  create-managers nbManagers
  [
    set g_cpt 0;
    findValidAgentArea ; No Manager on non identified area
    set shape "person business"
    set size ceiling (max-pxcor / (100 - g_sizeRate))
    set color red

    ; set managers'knowledge : 8O% have a knowledge = 2/4, 10% > 2, and 10% < 2
    let rand random 10;
    ifelse (rand = 0)
      [set knowledge random 25 ]
      [ifelse (rand = 1)
        [set knowledge (random 25) + 75]
        [set knowledge 50]
      ]

    ifelse (knowledge < 50) ; agents with less knowledge are more prone to deviation
      [set devianceLevel ((random 40) + 60) ] ; kowledge = 0 or 1 -> deviance > 60%
      [ifelse (knowledge > 50)
        [set devianceLevel random 10] ; knowledge = 3 or 4 -> deviance < 10%
        [ifelse (random 2 = 1)
          [set devianceLevel random 30] ; 50% of knowledge = 2 -> 0% < deviance < 30%
          [set devianceLevel (random 30) + 30] ; 50% of knowledge = 2 -> 30% < deviance < 60%
        ]
      ]

    ;     ifelse (random 10 = 1) ; we expect that only 1/10 of opertors can be strongly deviant
    ;          [set devianceLevel ((random 25) * 4) ]
    ;          [ifelse (random 2 = 1) ; we expect that only 1/2 of the others can be slightly deviant opertors
    ;            [set devianceLevel random 50]
    ;            [set devianceLevel 0] ; we expect that the others opertors have a total respect of moral ethics
    ;          ]

    set knowledge (knowledge + (sce_envi * 25 ))
    if (knowledge > 100) [ set knowledge 100]
    if (knowledge < 0) [ set knowledge 0]
  ]

  ; Creating Links between a manager and operators
  if g_debug? [print " ** Creating Links between a manager and operators"]
  ask managers [ createManagerLinkWithOperators self]
end

to createOperators
  if g_debug? [print (word "*** Creating " nbOperators " Operators agents")]
  create-operators nbOperators
  [
    set g_cpt 0;
    findValidAgentArea ; No Operator on non identified area
    set shape "person farmer"
    set size ceiling (max-pxcor / g_sizeRate)
    set color gray

    ; set operators'knowledge : 8O% have a knowledge = 2/4, 10% > 2, and 10% < 2
    let rand random 10
    ifelse (rand = 0)
      [set knowledge random 25 ]
      [ifelse (rand = 1)
        [set knowledge (random 25) + 75]
        [set knowledge 50]
      ]

    ifelse (knowledge < 50) ; agents with less knowledge are more prone to deviation
      [set devianceLevel ((random 40) + 60) ] ; kowledge = 0 or 1 -> deviance > 60%
      [ifelse (knowledge > 50)
        [set devianceLevel random 10] ; knowledge = 3 or 4 -> deviance < 10%
        [ifelse (random 2 = 1)
          [set devianceLevel random 30] ; 50% of knowledge = 2 -> 0% < deviance < 30%
          [set devianceLevel (random 30) + 30] ; 50% of knowledge = 2 -> 30% < deviance < 60%
        ]
      ]

    ;     ifelse (random 10 = 1) ; we expect that only 1/10 of opertors can be strongly deviant
    ;          [set devianceLevel ((random 25) * 4) ]
    ;          [ifelse (random 2 = 1) ; we expect that only 1/2 of the others can be slightly deviant opertors
    ;            [set devianceLevel random 50]
    ;            [set devianceLevel 0] ; we expect that the others opertors have a total respect of moral ethics
    ;          ]

    set knowledge (knowledge + (sce_envi * 25 ))
    if (knowledge > 100) [ set knowledge 100]
    if (knowledge < 0) [ set knowledge 0]
  ]

  ; Creating Links between an operator and exploitations
  if g_debug? [print " ** Creating Links between an operator and exploitations"]
  ask operators [ createOperatorLinkWithExploitation self ]
end

to createExternalHelps
  if g_debug? [print (word "*** Creating " nbExternalHelps " ExternalHelp agents")]
  create-externalHelps nbExternalHelps
  [
    set g_cpt 0;
    findValidAgentArea ; No externalhelp on non identified area
    set shape "person service"
    set size ceiling (max-pxcor / g_sizeRate)
    set color pink

    ; set external helps'knowledge : 8O% have a knowledge = 2/4, 10% > 2, and 10% < 2
    let rand random 10
    ifelse (rand = 0)
      [set knowledge random 25 ]
      [ifelse (rand = 1)
        [set knowledge (random 25) + 75]
        [set knowledge 50]
      ]

    ifelse (knowledge < 50) ; agents with less knowledge are more prone to deviation
      [set devianceLevel ((random 40) + 60) ] ; kowledge = 0 or 1 -> deviance > 60%
      [ifelse (knowledge > 50)
        [set devianceLevel random 10] ; knowledge = 3 or 4 -> deviance < 10%
        [ifelse (random 2 = 1)
          [set devianceLevel random 30] ; 50% of knowledge = 2 -> 0% < deviance < 30%
          [set devianceLevel (random 30) + 30] ; 50% of knowledge = 2 -> 30% < deviance < 60%
        ]
      ]

    ;      ifelse (random 24 = 1) ; we expect that only 1/25 of externalHelp can be strongly deviant
    ;          [set devianceLevel ((random 25) * 4) ]
    ;          [ifelse (random 3 = 1) ; we expect that only 1/3 of the others can be slightly deviant externalHelp
    ;            [set devianceLevel random 50]
    ;            [set devianceLevel 0] ; we expect that the others externalHelp have a total respect of moral ethics
    ;          ]

    set knowledge (knowledge + (sce_envi * 25 ))
    if (knowledge > 100) [ set knowledge 100]
    if (knowledge < 0) [ set knowledge 0]
  ]

  ; Creating Links between ExternalHelp and Managers
  if g_debug? [print " ** Creating Links between ExternalHelp and Managers"]
  ask externalHelps [ createHelpLinkWithManagers self ]
end

; ----

to createNaturalResources
  create-naturalResources nbNaturalResources
  [
    set g_cpt 0;
    findValidResourceArea ; No NaturalResources on non identified area
    set shape "tree"
    set size ceiling (max-pxcor / g_sizeRate)
    set color lime
    set devianceLevel 0 ; non deviant par defaut
  ]
end

to createExploitations
  create-exploitations nbExploitations
  [
    set g_cpt 0;
    findValidResourceArea ; No NaturalResources on non identified area
    set shape "plant"
    set size ceiling (max-pxcor / g_sizeRate)
    set color orange
    set devianceLevel 0 ; non deviant par defaut
  ]
end

;----
; call at agent initialisation to not localise an agent in a clear area
to findValidResourceArea
  set g_cpt 0;
  let currentAgent self
  set x 0 set y 0 ; just to create x and y locals vars
  let aPatch one-of patches with [shade-of? pcolor green or shade-of? pcolor brown and not any? turtles-here]
  ifelse (aPatch = nobody)
    [findValidAgentArea] ; Default
    [ ask aPatch [set x pxcor set y pycor]
      set xcor x set ycor y
    ]
end

;----
; call at agent initialisation to not localise an agent in a clear area
to findValidAgentArea
  set g_cpt g_cpt + 1
  if g_cpt > 100 [Beep output-print (word "ERR1: Impossible to find a valid area to create agents " breed " in the environment") Stop ]
  setxy random-pxcor random-pycor
  set x xcor set y ycor
  let currentAgent self
  let aPatch one-of patches with [ pxcor = x and pycor = y]

  if (aPatch = nobody or count turtles-on aPatch > 1 or (pcolor = g_defaultColor))
    [ findValidAgentArea ]
end

to-report isInvalidArea?
  ifelse (pcolor = g_defaultColor) [report TRUE] [report FALSE]
end

; call by init of externalHelp
to createHelpLinkWithManagers [anExternalHelp]
  ;; getting the manager closest to the current Node
  ask anExternalHelp [
    set x xcor;
    set y ycor;
    let min-d min [distancexy x y] of managers

    let l managers with [distancexy x y <= min-d + g_dist
      and abs (x - xcor) < max-pxcor / 3
    and abs (y - ycor) < max-pycor / 3 ]
    let nodes n-of (random count l) l

    if (count nodes != 0) [ create-isHelpBys-to nodes ; link the chosen Manager nodes with the current externalHelp
      if g_debug? [ type "  - Agent:" type self type " helps " ask nodes [type self] print " " ]
    ]
    ask my-out-links [set color violet] ; g_ExternalHelpLinksColor
  ]
end

; call by init of createOperator
to createOperatorLinkWithExploitation [anOperator]
  ;; getting the exploitation closest to the current Node
  ask anOperator [
    set x xcor;
    set y ycor;
    let min-d min [distancexy x y] of exploitations
    set g_cpt 0

    loop [
      set g_cpt g_cpt + 1
      if g_cpt > 5 [if g_debug? [ type "warning: Impossible to link " type anOperator print " to an exploitation"] Stop ]

      let l exploitations with [distancexy x y <= min-d + g_dist * g_cpt
        and isNotLink?
        and abs (x - xcor) < max-pxcor / 3
      and abs (y - ycor) < max-pycor / 3  ]

      let selectedExploitations n-of (random count l) l
      if any? selectedExploitations
      [ create-isExploitedBys-to selectedExploitations ; link the chosen exploitation with the current operator
        if g_debug? [ type "  - Agent:" type self type " exploit " ask selectedExploitations [type self] print " " ]
        ask my-out-links [set color green ] ; g_OperatorLinksColor
        stop
      ]
    ]
  ]
end

; call by init of createOperator
to createManagerLinkWithOperators [aManager]
  ;; getting the Operators closest to the current Node
  ask aManager [

    set x xcor;
    set y ycor;
    let min-d min [distancexy x y] of operators
    set g_cpt 0

    loop [
      set g_cpt g_cpt + 1
      if g_cpt > 5 [if g_debug? [ type "warning: Impossible to link " type aManager print " to an operator"] Stop ]

      let l operators with [distancexy x y <= min-d + g_dist * g_cpt
        and isNotLink?
        and abs (x - xcor) < max-pxcor / 3
      and abs (y - ycor) < max-pycor / 3  ]

      let selectedOperators n-of (random count l) l
      if any? selectedOperators
      [ create-isManagedBys-to selectedOperators ; link the chosen operator with the current manager
        if g_debug? [ type "  - Agent:" type self type " manages " ask selectedOperators [type self] print " " ]
        ask my-out-links [set color yellow - 2] ; g_ManagerLinksColor]
        stop
      ]
    ]
  ]
end

to-report isNotLink?
  ifelse any? my-in-links [report FALSE] [report TRUE]
end


; ============================ Agents Behavior ===========================================

; ------------------------- operatorBehavior Main Behavior -------------------------
to operatorBehavior

  ask operators [

    ; if this operator is knowledgeable, his deviance slightly decreases proportionnally to his knowledge.
    if (knowledge > 25)
    [
      set devianceLevel max list (devianceLevel - random 3 * (100 / knowledge)) 0
    ]

    ifelse (devianceLevel = 0)
    ; if this externalHelp is totally Ethic, this may change due to major live event
      [ if (random 10 = 0)
        [set devianceLevel random 101] ; people live difficult experience in there live and get not ethic !
      ]
    ; if this agent is not totally ethic, his deviance level will slighly decrease or increase +/- 5%
      [ ifelse (random 2 = 0)
        [set devianceLevel min list (devianceLevel + random 4) 100 ]
        [set devianceLevel max list (devianceLevel - random 6) 0]
      ]

    set nb_link count in-link-neighbors  ;; calcul du nombre de lien entrant de l'operator ( => nombre de manager liés )

    ;;;; A chaque tick on calcul la nouvelle valeur de (variable qui change régulièrement) :

    ; - l'impot de l'operator
    ; - la rentability de l'operator
    ; - l'influence de l'operator
    ; - du revenu de l'operator
    ; - du resultat d'exploitation de l'operator ( nécéssaire pour le calcul de la rentability )
    calculate_impot_operator
    calculate_revenu_operator
    calculate_resultexploi_operator
    calculate_rentability_operator
    calculate_influence_operator

    if ((ticks != 0) and (ticks mod 4 = 0)) [
      ;;; money à payer tous les mois

      set money money - (((random 3 + 1) * 1500 * count out-link-neighbors))
      set money money - impots

      ;;; money reçu tous les mois (attention le revenu peut être négatif donc à payer)
      set money money + 1500 + (1000 * sce_eco)
      set money money + 4000 + (3000 * sce_eco)
      ifelse revenu > 0
      [set money money + revenu + ((revenu / 1.5) * (sce_eco))]
      [set money money + revenu + ((revenu / 1.5) * (- sce_eco))]
    ]
  ]
end


; ------------------------- ExternalHelp Main Behavior -------------------------
to externalHelpBehavior
  ask externalHelps [ ; for all externalHelp agent
    if g_debug? [type "==== externalHelp " type self type "deviance level : " print devianceLevel ] ;; *** debug
                                                                                                    ; count of the ethic manager linked with him
    let EthicAgentCounter linkedWithTotallyEthicManagerCount
    if g_debug? [type "    -> EthicAgentCounter " print EthicAgentCounter ] ;; *** debug
    ifelse (devianceLevel = 0)
    ; if this externalHelp is totally Ethic, this may change due to mobility or politics
      [ if (random 10 = 0)
        [set devianceLevel random 101] ; regularly people and politic change in the institution !
      if g_debug? [type "    -> Deviance Level of " type self print "changed randomly due to mobility or politics (not links)" ]
      ]
    ; if this agent is not totally ethic and linked with totally ethic managers, his deviance level will decrease
      [ ifelse (EthicAgentCounter != 0)
        [ set devianceLevel max list (devianceLevel - ((random 6) * EthicAgentCounter)) 0] ; the level of deviance decreases relative to the pressure
                                                                                           ; of "ethic" managers linked with this agent
                                                                                           ; if that agent is linked with strong deviant manager his devianceLevel will slightly increase else it will slightly decrease
        [ ifelse (linkedWithStrongDeviantMangerCount > 0)
          [   if g_debug? [ type "    -> This agent is linked with Strong Deviant Manager" type g_cpt print ", his level deviance increases"]
            set devianceLevel min list (devianceLevel + random 4) 100 ; the level deviance increases
          ]
          [ if g_debug? [ print "    -> This agent is NOT linked with Strong Deviant Manager - the level deviance decrease" ]
            set devianceLevel max list (devianceLevel - random 6) 0 ; the level deviance decrease
          ]
        ]
      ]
    if g_debug? [ type "    -> new deviance level : " print devianceLevel ] ;; *** debug
  ]
  if g_debug? [ print "---"]

  ask externalhelps [

    set nb_link count out-link-neighbors    ;;; nombre de lien externe des externalhelp ( => nombre de managers liés )
    ; - l'impot de l'externalhelp
    ; - l'influence de l'externalhelp
    ; - du revenu de l'operator (total random pour les externalhelp ==> représente les éventuels dons

    calculate_influence_externalhelp
    calculate_impot_externalhelp
    calculate_revenu_externalhelp

    if ((ticks != 0) and (ticks mod 4 = 0)) [
      ;;; money à payer tous les mois
      set money money - impots

      ;;; money reçu tous les mois (attention le revenu peut être négatif retiré de la money actuelle)
      set money money + 4000 + (3000 * sce_eco)
      set money money + revenu + ((revenu / 1.5) * (sce_eco))
      ]
    ]
end

to-report linkedWithTotallyEthicManagerCount
  set g_cpt 0;
  ask my-links [ if is-manager? end2  [ ask end2 [ if (devianceLevel = 0) [set g_cpt (g_cpt + 1) ]]] ] ;
  report g_cpt
end
to-report linkedWithStrongDeviantMangerCount
  set g_cpt 0;
  ask my-links [ if is-manager? end2  [ ask end2 [ if (devianceLevel > 75) [set g_cpt (g_cpt + 1) ]]] ] ;
  report g_cpt
end

; ------------------------- Manager Main Behavior -------------------------
to managerBehavior

  ; -------------------------------------------------------------------------------
  ; Public Manager
  ; -------------------------------------------------------------------------------
  ; * Objectif 1
  ;   Faire respecter les lois et mettre en place des mesures de protection des Ressources
  ;   Faire des profits grâce aux taxes, impôts et pénalités liées à l’environnement
  ;   Avoir de bonnes relations avec les autres agents
  ;   Etre déviant dans un régime instable dans un pays en développement

  ;-------------------------------------------------------
  ;;;; update deviancelevel and knowledge for each manager
  ask managers [
    ; if this manager is knowledgeable, his deviance slightly decreases proportionnally to his knowledge.
    if (knowledge > 25)
    [
      set devianceLevel max list (devianceLevel - random 3 * (knowledge / 100)) 0
    ]
    ifelse (devianceLevel = 0)
    ; if this manager is totally Ethic, this may change due to personal bad experience or major economic event
      [ if (random 15 = 0) [set devianceLevel random 101]] ; regularly people change !
                                                           ; if this manager is NOT totally Ethic, his devianceLevel can just slightly evolve +/- 10 % during time
      [ ifelse (random 2 = 0)
        [set devianceLevel min list (devianceLevel + random 8) 100 ]
        [set devianceLevel max list (devianceLevel - random 10) 0]
      ]

    ;sometimes (every 2 years -- 24 ticks) managers go to trainings and gain knowledge
    if ((ticks != 0) and (ticks mod 24 = 0 )) [                                ;Modification du code : allongement entre les temps de formation et augmentation de la chance de gain en knowledge
      if (random 2 = 0 and knowledge < 91) [set knowledge (knowledge + (sce_envi * 10))]
      if (knowledge > 100) [ set knowledge 100]
      if (knowledge < 0) [ set knowledge 0]
    ]

    ;once in a while (i.e. each tick which is a multiple of ten), managers meet their operators and transmit their knowledge : 2/3 of the operators are receptive if the manager is knowledgeable, 1/3 otherwise
    if ((ticks != 0) and (ticks mod 10 = 0)) [
      if (knowledge > 75)
      [
        ask out-link-neighbors [
          if (random 3 != 0)
          [set knowledge knowledge + 10]
          if (knowledge > 100) [set knowledge 100]
        ]
      ]
      if (knowledge < 75 )
      [
        ask out-link-neighbors [
          if (random 3 = 2)
          [set knowledge (knowledge + (sce_envi * 10))]
          if (knowledge > 100) [set knowledge 100]
          if (knowledge < 0) [ set knowledge 0]
        ]
      ]
    ]
  ]

  ;--------------------------------------------
  ;;;; update financial values for each manager
  ask managers [
    set nb_link count my-links    ;;; nombre de liens entrant et sortant du manager ( ==> nombre d'operator liés + nombre d'externalhelp liés )

    ;;; A chaque tick (chaque mois) on calcul la nouvelle valeur de (variable qui change régulièrement) :

    ; - l'impot du manager
    ; - la rentability du manager
    ; - l'influence du manager
    ; - du revenu du manager
    ; - du resultat d'exploitation du manager ( nécéssaire pour le calcul de la rentability )
    calculate_influence_manager
    calculate_impot_manager
    calculate_revenu_manager
    calculate_resultexploi_manager
    calculate_rentability_manager

    ;;; Tous les mois les managers ont 50 % de chance d'augmenter leur interaction avec leurs operators (accentué par le scénario social)
    if ((ticks != 0) and (ticks mod 4 = 0)) [
      if (random 2 = 0) [set interaction_o interaction_o + 2]
      if (random 2 = 1) [set interaction_eh interaction_o + 2]
    ]

    if ((ticks != 0) and (ticks mod 4 = 0)) [
      ;;; money à payer tous les mois
      set money money - (((random 10 + 1) * 1500 * count out-link-neighbors))
      set money money - impots

      ;;; money reçu tous les mois (attention le revenu peut être négatif donc à payer)
      set money money + 5000 + (1000 * sce_eco)
      set money money + 8000 + (3000 * sce_eco)
      ifelse revenu > 0
         [set money money + revenu + ((revenu / 1.5) * (sce_eco))]
         [set money money + revenu + ((revenu / 1.5) * (- sce_eco))]
    ]

    ;;; Si PM a de bonnes relations avec O et Eh, O et Eh collaborent. => gain en knowledge + don d'argent de EH vers O
    if ((ticks != 0) and (ticks mod 4 = 0)) [

      if ((interaction_o >= 20) and (interaction_eh >= 20) ) [                ;;; manager doit avoir une interaction de 20 minimum POUR LES DEUX, EH et O

        ask out-link-neighbors [ set knowledge (knowledge + 1 + (2 * sce_envi))]                ;;; gain en knowledge de l'operator
        if (knowledge > 100) [ set knowledge 100]
        if (knowledge < 0) [ set knowledge 0]

        ask in-link-neighbors [                                               ;;; si EH lié au manager à une money suffisante alors il donne 10 000 € à l'O lié du même manager
          if ( money > 10000 ) [
            ;; put 10000 from Externalhelps in transfert_financial_help
            set money (money  - 10000) ;
            ask myself [ set transfert_financial_help 10000 * nb_in_link]
          ]
      ]

      ;; if this manager have got link with operator
      if-else (nb_out_link > 0)[
         ;;distribute the financial_help to the operator
         ask out-link-neighbors [
           set money money + ([transfert_financial_help] of myself /  [nb_out_link] of myself )
         ]
      ]
      [
        ;;;;TODO :  WARNING ! a choise must be done for the redistribute of financial help when manager haven't got link with operators

        ;;distribute the financial_help to all manager
        ask managers [ set money money + ([transfert_financial_help] of myself / (count managers))]
      ]
      set transfert_financial_help 0
    ]

    ask out-link-neighbors [
      set money money - impots                                            ;;; collecte des impots payé par O pour les M
      ask myself [set collecte_impots collecte_impots + impots]
      ask myself [set money money + collecte_impots]

      if-else (rentability > 0)
      [ ask myself [set interaction_o interaction + 2]]                   ;;; SI rentability de O > 0 ==> manager content donc gain en interaction
      [ ask myself [set interaction_o interaction - 2]]                   ;;; dans le cas contraire baisse d'interaction entre  0 et M
    ]

    if ((ticks != 0) and (ticks mod 12 = 0) and (interaction_o > 5)) [   ;;; tous les 3 mois, si l'interaction entre M et O sont bonnes
       ask out-link-neighbors [

         if (money < 0) [                                                  ;;; si la money de O < 0 alors M donne à O 10 000 €
           if (random 1 = 0 ) [
             set money money + 10000
             ask myself [set money money - 10000]
           ]
         ]
       ]
    ]
    ]
  ]
end

; -------------------------------------------------------------------------------
; IHM Management
; -------------------------------------------------------------------------------
to showDevianceLevel
  ask patches with [savePatchColor != g_defaultColor] [
    ifelse g_showDevianceLevel?
      [ set pcolor black]
      [ set pcolor savePatchColor]
  ]
  ifelse g_showDevianceLevel?  [ ; showDevianceAffordance ; TODO //@RC pas top à revoir
    set g_showDevianceLevel?  FALSE] [set g_showDevianceLevel? TRUE]
  showDevianceLevel_label
end

to showDevianceLevel_label
  ask turtles [
    ifelse (g_showDevianceLevel? = FALSE and devianceLevel >= devianceLevelToShow) [
      set pcolor scale-color red (120 - devianceLevel) 0 100
      set label (round devianceLevel)
      set label-color pcolor
    ]
    [ set label "" ]
  ]
end
to showDevianceAffordance
  ask ExternalHelps [
    if (devianceLevel >= devianceLevelToShow) [
      ;; scale color to show deteriorationLevel concentration
      ask patches in-radius 1
        [ set pcolor scale-color red ([devianceLevel] of myself) 0 100 ]
    ]
  ]
  ask Managers [
    if (devianceLevel >= devianceLevelToShow) [
      ;; scale color to show deteriorationLevel concentration
      ask patches in-radius 1
        [ set pcolor scale-color red ([devianceLevel] of myself) 0 100 ]
    ]
  ]
  ask Operators [
    if (devianceLevel >= devianceLevelToShow) [
      ;; scale color to show deteriorationLevel concentration
      ask patches in-radius 1
        [ set pcolor scale-color red ([devianceLevel] of myself) 0 100 ]
    ]
  ]

  diffuse pcolor 0.5
end

;--------
to showDeterorationLevel
  ifelse g_showDeterorationLevel?
    [set g_showDeterorationLevel? FALSE
      ask patches [ set pcolor savePatchColor]
    ]
    [set g_showDeterorationLevel? TRUE
      ask turtles [set label ""]
      showDeterorationLevel_diffusion
    ]
end

to showDeterorationLevel_diffusion
  if g_showDeterorationLevel?
  [ask patches
    [ set pcolor scale-color blue (100 - deteriorationLevel) 0 100]
  ]
end


;========Begin Show links
;--------
to showExternalHelpLinks
  ask isHelpBys [
    set color violet ; g_ExternalHelpLinksColor
    ifelse g_hideExternalHelpLinks? [hide-link][show-link]
  ]
  ifelse g_hideExternalHelpLinks? [set g_hideExternalHelpLinks? FALSE] [set g_hideExternalHelpLinks? TRUE]
end

;--------
to ShowOperatorLinks
  ask isExploitedBys [
    set color green ; g_OperatorLinksColor
    ifelse g_hideOperatorLinks? [hide-link][show-link]
  ]
  ifelse g_hideOperatorLinks? [set g_hideOperatorLinks? FALSE] [set g_hideOperatorLinks? TRUE]
end

;--------
to ShowManagerLinks
  ask isManagedBys [
    set color yellow - 2; g_ManagerLinksColor
    ifelse g_hideManagerLinks? [hide-link][show-link]
  ]
  ifelse g_hideManagerLinks? [set g_hideManagerLinks? FALSE] [set g_hideManagerLinks? TRUE]
end

;========End show links
;--------
to showMaxDeviant
  let node max-one-of turtles [ devianceLevel ]
  watch node
  do-highlightAgent node
end

;;------
to highlight
  if mouse-inside? [
    ;to stop highlight when finding the right agent
    if (mouse-down? and (g_mouseysave != mouse-ycor) and (g_mousexsave != mouse-xcor)) [
      if g_debug? [ print (word "mouse down - mouse-xcor: " mouse-xcor " mouse-ycor:" mouse-ycor) ]
      ifelse (g_stopHighlight? = FALSE) [set g_stopHighlight? TRUE set g_agentInspector (word g_agentInspector " - <Inspect> or <Mouse Down>") ] [set g_stopHighlight? FALSE]
      set g_mouseysave mouse-ycor
      set g_mousexsave mouse-xcor
    ]

    if (g_stopHighlight? = FALSE) [
      ifelse g_showDeterorationLevel?
        [ do-highlightPatch one-of patches with [pxcor = ceiling mouse-xcor and pycor = ceiling mouse-ycor]]
        [let min-d min [distancexy mouse-xcor mouse-ycor] of turtles ; getting the closest node to the mouse
          let node one-of turtles with [distancexy mouse-xcor mouse-ycor = min-d]
          do-highlightAgent node
        ]
    ]
  ]
  display
end

;--------
to do-highlightAgent [node]
  if node != nobody
  [
    ;; highlight the chosen node
    ask node
    [
      ;; show node's clustering coefficient
      ifelse g_showDeterorationLevel?
        [set g_agentInspector (word "Patch position (" ceiling mouse-xcor "," ceiling mouse-ycor ") - Deterioration level = " deteriorationLevel )]
        [ set g_agentInspector (word "agent = " node " ; deviance level = " devianceLevel " ; (x,y) = (" xcor "," ycor ")" )]
      if is-turtle? g_agentToInspect [ask g_agentToInspect [set label " "]]
      set g_agentToInspect node
      set label-color black
      set label node
    ]

    ; hide all links
    ask links [hide-link]; [set color grey]
    ask turtles [set size computeTurtleSize(g_sizeRate)]

    ask node [set size computeTurtleSize (g_sizeRate + g_SizeRateDyn)]
    ; Show the link trees between
    ; isHelpBys : links to manager agents
    ; isManagedBys : links to operator agents
    ; isExploitedBys : links to Exploitation agents
    ask ([my-out-isHelpBys] of node) [ showManagerLinksTree (end2)]
    showManagerLinksTree (node)
    showOperatorLinksTree (node)
  ]
end
to showManagerLinksTree [node]
  ask node [set size computeTurtleSize (g_sizeRate + g_SizeRateDyn)]
  ask ([my-in-isHelpBys] of node) [ set color violet ; g_ExternalHelpLinksColor
    ask end1 [set size computeTurtleSize (g_sizeRate + g_SizeRateDyn)]
    show-link ]
  ask [my-out-isManagedBys] of node [ showOperatorLinksTree (end2) ]
end
to showOperatorLinksTree [node]
  ask node [set size computeTurtleSize (g_sizeRate + g_SizeRateDyn)]
  ask [my-in-isManagedBys] of node  [ set color Yellow - 2 ; g_ManagerLinksColor
    ask end1 [set size computeTurtleSize (g_sizeRate + g_SizeRateDyn)]
    show-link
  ]
  ask [my-out-isExploitedBys] of node [ set color green ; g_OperatorLinksColor
    ask end2 [set size computeTurtleSize (g_sizeRate + g_SizeRateDyn)]
    show-link ]
end

;--------
to do-highlightPatch [aPatch]
  if aPatch != nobody
  [
    ;; highlight the chosen node
    ask aPatch
    [
      set g_agentInspector (word "Patch position (" ceiling mouse-xcor "," ceiling mouse-ycor ") - Deterioration level = " deteriorationLevel )
      set g_agentToInspect aPatch
    ]
  ]
end

to-report computeTurtleSize [sizeRate]
  report ceiling (max-pxcor / (100 - sizeRate))
end ; computeTurtleSize --/

;--------
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Adding By D&D ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to plotAgents
let lindex 0
  foreach g_listAgentToPlot [
    set lindex lindex + 1
    if (is-turtle? ?)[
      set-current-plot (item (lindex - 1 ) g_listPlotName)
      set-current-plot-pen "deviance"

      ifelse (member? ? ExternalHelps)
        [ set-plot-pen-color yellow]
        [ ifelse (member? ? Managers)[set-plot-pen-color red] [set-plot-pen-color green]]
      ask ? [plot devianceLevel]

      set-current-plot-pen "knowledge"
      plot-pen-down
      set-plot-pen-color blue
      ask ? [plot knowledge]

      set-current-plot-pen "influence"
      plot-pen-down
      set-plot-pen-color grey
      ask ? [plot influence]

      set-current-plot-pen "money"
      plot-pen-up
      set-plot-pen-color orange
      ask ? [plot money]

      set-current-plot (word "money " (lindex ))
      set-current-plot-pen "money"
      set-plot-pen-color orange
      ask ? [plot money]
    ]
  ]
end ; plotAgents --/

;------------------------------------------------------------------------------------------
;----- save the results of a simulation in cvs files for further future analysis
;----- for example by prompto -- http://veroniquesebastien.eu/prompto/siegmas-v4/
to save
  ; we can save only if a simulation if the simulation is finished
  if (ticks > nbIterate)[
    let resultDirectory user-directory
    if (resultDirectory = false)
    [ set resultDirectory ""
      stop
    ]

    let nameFilesComposite (word resultDirectory g_strDateTime "_" ) ;
    output-print (word "Exporting data (all plots) in " nameFilesComposite g_csvPlotsExportFile)
    export-all-plots (word nameFilesComposite g_csvPlotsExportFile)

    let nameFilesEntity (word nameFilesComposite "entity.csv")
    file-open nameFilesEntity
    file-print (word "\"entityType\",\"name\",\"simuType\",\"role\",\"xPos\",\"yPos\"")

    let i 0
    let xposition 0
    let yposition 0
    foreach g_listAgentToPlot [
      set i i + 1
      ask ? [
        set xposition [xcor] of ?
        set yposition [ycor] of ?

        output-print ( word "Agent ID" i " is : " ? " x,y = " xposition "," yposition )
        file-print (word "\"agent\",\"Agent ID" i "\",\""  ?  "\",\"0\",\"" xposition "\",\"" yposition "\"" )
      ]
      output-print (word "Exporting data of " (item (i - 1) g_listPlotName) " in " nameFilesComposite g_plotExportFileName (i) g_csvExtFile)
      export-plot (item (i - 1) g_listPlotName) (word nameFilesComposite g_plotExportFileName (i) g_csvExtFile)
    ]
    file-close
  ]
end ; save --/

; ===============================================================================
; -------------------------------------------------------------------------------
; main entry - Go procedure
; -------------------------------------------------------------------------------
to go
  if g_mapContext = "Nill" [
    user-message ("Topological environment not set")
    stop
  ]

  if (ticks = 1) [
    let dateTime date-and-time
    set g_strDateTime (remove "." (remove "-" (remove " " (remove ":" (word dateTime)))))
    output-print word "*** Start of simulation : " dateTime
  ]

  ifelse (ticks <= nbIterate) [
    operatorBehavior
    externalHelpBehavior
    managerBehavior

    ; Narural propagation of deterioration level
    diffuse deteriorationLevel (g_diffusion-rate / 100)

    ; show the evolutions on the maps
    if g_watchMaxDeviant? [ShowMaxDeviant]
    showDevianceLevel_label
    showDeterorationLevel_diffusion

    ; plotting agents
    plotAgents
    set g_time_line word (ticks mod 12) " Months"
    set g_time_line word " years " g_time_line
    set g_time_line word (floor (ticks / 12)) g_time_line

    tick
  ]
  [
    output-print word "*** End of simulation   : " date-and-time
    stop
  ]
end
; -------------------------------------------------------------------------------
; Copyright 2015 LIM Lab.
; University of Reunion Island.
@#$#@#$#@
GRAPHICS-WINDOW
298
62
912
601
-1
-1
4.0
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
150
0
126
0
0
1
ticks
30.0

SLIDER
9
221
136
254
nbManagers
nbManagers
0
100
22
1
1
NIL
HORIZONTAL

BUTTON
231
47
287
92
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
114
104
228
137
Go
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
0

SLIDER
144
349
286
382
forest%
forest%
10
100
36
1
1
%
HORIZONTAL

SLIDER
10
256
135
289
nbOperators
nbOperators
0
100
60
1
1
NIL
HORIZONTAL

SLIDER
10
290
136
323
nbExternalHelps
nbExternalHelps
0
100
10
1
1
NIL
HORIZONTAL

SLIDER
146
222
289
255
nbNaturalResources
nbNaturalResources
0
100
28
1
1
NIL
HORIZONTAL

SLIDER
146
258
290
291
nbExploitations
nbExploitations
0
100
97
1
1
NIL
HORIZONTAL

INPUTBOX
11
664
125
735
nbIterate
100
1
0
Number

BUTTON
10
488
135
521
Max Deviant
ifelse g_watchMaxDeviant? \n   [reset-perspective \n    set g_watchMaxDeviant? false]\n   [ let node max-one-of externalHelps [ devianceLevel ]\n     watch node\n     set g_watchMaxDeviant? true\n     do-highlightAgent node]
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

TEXTBOX
10
49
160
67
>Init simulation
11
25.0
1

TEXTBOX
4
328
285
358
Other settings_________________________________
12
0.0
1

TEXTBOX
138
18
287
68
SIEGMAS V1.5a
20
0.0
1

TEXTBOX
10
204
160
222
Stakeholders
11
104.0
1

TEXTBOX
146
205
296
223
Resources
11
93.0
1

TEXTBOX
8
184
291
202
Agents settings________________________________
12
0.0
1

TEXTBOX
14
10
158
38
University of Reunion Island LIM Lab
9
15.0
1

PLOT
928
234
1475
593
Rate of deviant Stakeholders with devianceLevel > g_PlotRate %
tick
Rate of deviant agents (%)
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"cumul" 1.0 0 -16777216 true "" "plot (100 * (count turtles with [devianceLevel >= g_plotRate])) / (count operators + count managers + count externalhelps)"
"operator" 1.0 0 -10899396 true "" "plot (100 * (count operators with [devianceLevel >= g_plotRate])) / (count operators)"
"manager" 1.0 0 -2674135 true "" "plot (100 * (count managers with [devianceLevel >= g_plotRate])) / (count managers)"
"externalHelp" 1.0 0 -1184463 true "" "plot (100 * (count externalHelps with [devianceLevel >= g_plotRate])) / (count externalHelps)"

SLIDER
7
350
134
383
agriculture%
agriculture%
10
100
98
1
1
%
HORIZONTAL

BUTTON
10
523
135
556
Deteroration level
showDeterorationLevel
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
11
559
136
592
Deviance Level
showDevianceLevel
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
145
426
286
459
externalHelp->Manager
ShowExternalHelpLinks\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
146
410
236
428
Links
11
93.0
1

MONITOR
298
10
834
55
Agent Inspector
g_agentInspector
17
1
11

BUTTON
8
425
134
458
Highlight Agent
Highlight
T
1
T
OBSERVER
NIL
H
NIL
NIL
1

BUTTON
834
10
912
55
Inspect
inspect g_agentToInspect
NIL
1
T
OBSERVER
NIL
I
NIL
NIL
1

TEXTBOX
11
472
161
490
Show info...
11
93.0
1

TEXTBOX
9
408
159
426
Agents
11
93.0
1

BUTTON
231
104
286
137
Go once
Go
NIL
1
T
OBSERVER
NIL
O
NIL
NIL
1

SLIDER
133
629
283
662
g_diffusion-rate
g_diffusion-rate
0
20
2
1
1
NIL
HORIZONTAL

SWITCH
10
628
124
661
g_debug?
g_debug?
1
1
-1000

TEXTBOX
12
604
293
649
Advanced options_____________________________
12
0.0
1

OUTPUT
929
10
1475
226
12

CHOOSER
113
47
228
92
Territory
Territory
"La Reunion" "Analamanga" "Itasy" "Default"
0

SLIDER
133
665
226
698
g_sizeRate
g_sizeRate
50
80
69
1
1
NIL
HORIZONTAL

TEXTBOX
292
568
442
586
NIL
11
0.0
1

TEXTBOX
3
393
295
411
Display options________________________________
12
0.0
1

BUTTON
146
511
287
544
operator->exploit.
ShowOperatorLinks
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
227
665
282
698
RS
  ask turtles [set size computeTurtleSize (g_sizeRate)]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
145
467
288
500
Manager->Operator
ShowManagerLinks
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
144
559
287
592
DevianceLevelToShow
DevianceLevelToShow
0
100
40
1
1
%
HORIZONTAL

SLIDER
133
702
282
735
g_sizeRateDyn
g_sizeRateDyn
5
80
80
5
1
%
HORIZONTAL

PLOT
68
967
521
1153
Agent ID1
tick
(%)
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"deviance" 1.0 0 -2674135 true "" ""
"knowledge" 1.0 0 -13345367 true "" ""
"influence" 1.0 0 -7500403 true "" ""
"money" 1.0 0 -955883 true "" ""

MONITOR
69
903
522
948
Agent ID1
g_agentIdToPlot1
17
1
11

INPUTBOX
134
741
282
801
g_plotRate
1
1
0
Number

MONITOR
997
899
1451
944
Agent ID2
g_agentIdToPlot2
17
1
11

MONITOR
71
1178
523
1223
Agent ID3
g_agentIdToPlot3
17
1
11

MONITOR
999
1176
1452
1221
Agent ID4
g_agentIdToPlot4
17
1
11

MONITOR
73
1435
526
1480
Agent ID5
g_agentIdToPlot5
17
1
11

MONITOR
1001
1432
1454
1477
Agent ID6
g_agentIdToPlot6
17
1
11

PLOT
996
966
1451
1151
Agent ID2
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"deviance" 1.0 0 -16777216 true "" ""
"knowledge" 1.0 0 -7500403 true "" ""
"influence" 1.0 0 -2674135 true "" ""
"money" 1.0 0 -955883 true "" ""

TEXTBOX
10
868
709
916
Agent to inspect (plotting the devianceLevel)_______________________________________________
13
0.0
1

PLOT
71
1222
523
1409
Agent ID3
tick
(%)
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"deviance" 1.0 0 -16777216 true "" ""
"knowledge" 1.0 0 -7500403 true "" ""
"influence" 1.0 0 -2674135 true "" ""
"money" 1.0 0 -955883 true "" ""

PLOT
999
1219
1452
1407
Agent ID4
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"deviance" 1.0 0 -16777216 true "" ""
"knowledge" 1.0 0 -7500403 true "" ""
"influence" 1.0 0 -2674135 true "" ""
"money" 1.0 0 -955883 true "" ""

PLOT
73
1480
526
1665
Agent ID5
tick
 (%)
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"deviance" 1.0 0 -16777216 true "" ""
"knowledge" 1.0 0 -7500403 true "" ""
"influence" 1.0 0 -2674135 true "" ""
"money" 1.0 0 -955883 true "" ""

PLOT
1001
1477
1454
1662
Agent ID6
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"deviance" 1.0 0 -16777216 true "" ""
"knowledge" 1.0 0 -7500403 true "" ""
"influence" 1.0 0 -2674135 true "" ""
"money" 1.0 0 -955883 true "" ""

TEXTBOX
933
604
1407
658
Scenarios of simulation_________________________________________________________
12
0.0
1

BUTTON
232
141
287
185
Save
save
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
548
1225
918
1412
money 3
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"money" 1.0 0 -955883 true "" ""

PLOT
548
970
921
1153
money 1
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"money" 1.0 0 -955883 true "" ""

PLOT
543
1480
917
1664
money 5
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"money" 1.0 0 -955883 true "" ""

PLOT
1472
968
1828
1155
money 2
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"money" 1.0 0 -955883 true "" ""

PLOT
1470
1223
1830
1403
money 4
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"money" 1.0 0 -955883 true "" ""

PLOT
1473
1476
1834
1662
money 6
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"money" 1.0 0 -955883 true "" ""

SLIDER
932
632
1104
665
sce_eco
sce_eco
-1
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
932
670
1104
703
sce_social
sce_social
-1
1
0.2
0.1
1
NIL
HORIZONTAL

SLIDER
932
708
1104
741
sce_envi
sce_envi
-1
1
0.2
0.1
1
NIL
HORIZONTAL

TEXTBOX
1116
638
1266
656
Economic scenario
11
0.0
1

TEXTBOX
1118
678
1268
696
Social scenario
11
0.0
1

TEXTBOX
1117
719
1267
737
Environmental scenario
11
0.0
1

TEXTBOX
9
149
159
167
>Save result
11
25.0
1

TEXTBOX
9
105
159
123
>Run simulation
11
25.0
1

TEXTBOX
443
71
668
89
one tick correspond to 1 month
11
0.0
1

TEXTBOX
1084
603
1389
631
-1 : worth situation -> +1 best situation
11
5.0
1

TEXTBOX
932
752
1205
791
A realist scenario for Réunion Iland is : sce_eco=0,5 ; sce_social=0,2 ; sce_envi=0,2
11
3.0
1

MONITOR
114
140
228
185
time line
g_time_line
0
1
11

@#$#@#$#@
## WHAT IS IT?

SIEGMAS (Stakeholders Interactions in Environmental Governance by a Multi-Agents System) is a model which permits to study the interactions between stakeholders in common pool ressources. The implementation with Netlogo can make simulations on the management of natural resources evolutions'.
This decision support system called SIEGMAS-2 (Stakeholders Interactions in Environmental Governance by a Multi-Agent System) is based on a model of agents. Its aim is to study the interactions between agents acting on territory under an economic aspect via agronomic interface. The work presented here is an extension of a first system SIEGMAS.
SIEGMAS-2 uses an interactive and dynamic interface with powerful configuration properties through map and interpretation of results through tools from Big Data’s field.
In this model, we introduce the sensitive issue of community governance and justify the interest of SMA approach. We describe the Agent Based Simulation’s conceptual model associated with our system and then introduce some original extensions. First, we propose a configuration tool MASC (MAp Sector Creator) in order to generate flexibly a simulation environment from digital maps with expert’s data representation. Secondly, we introduce some data analysis tools based on a complete separation of generated data and its visualization.


## HOW IT WORKS ?

At each tick, corresponding to one month in the réalité, each stakeholder look at the patch that is currently on, has intercations with another one. He can cooperate or no, have a good behavior or be a deviant. Severals measures which describe the strategies can be use by the agent to achieve his goal.

A agent can be a public manager, an operator or an externalhelp.
Public Manager control others stakeholders, but he can also be a deviant.

Sometimes the public manager try to adopt good strategies to develop an area. So, externalhep and operator try to do the same thing to respect the rules and don't have sanctions.

But when the public manager is a deviant and when we can observe corruption at each level of the centralized and decentralized authorities others stakeholders (externalhelp and operator) have the right light to do the same thing.
So, the system and all the society can be deviant or it is more difficult to a stakeholder to adopt a good behavior when the rate of deviance is high in his country.


## HOW TO USE IT

At the beginning of the code source, we use MASC.

The computer modelling is the formal description of a system that allows manipulation of a virtual copy using a computer. To obtain this virtual representation, there is implementation of the model. There is a passage of a theoretical context to a more concrete one, which is the production of codes to be used to have a final product in the form of an application.
Before running a simulation, the initialization must be settled, which includes configuring the simulation context. Knowing that the context has a huge impact on the proceedings and the outcomes of the simulation, we often give more attention to data in particular and starting environment. Each configuration leads, so to speak, to an almost unique experience depending on the configuration settings. (Gangat, et al., 2009)
Optimization of working time issue arises when we handle complex systems, especially in multi-agents systems where we prefer to pay more attention to data and different proceedings performed during iterations.
For helping to solve this problem, we propose MASC, an easy to use tool that can provide an environment base represented by cutting a base map, diagram or plan into a grid of sectors directly usable in multi-agents simulation platforms as NetLogo (Wilensky, 1999) the platform of multi-agent simulation of IREMIA laboratory at the University of Reunion Island, GEAMAS-NG (GEneric Architecture for MultiAgent Simulations) (Payet, et al., 2006).
Thus, MASC permits to save time and focus on implementation of models. In addition, MASC provides a simplified user experience through opportunities brought by recent developments in Web technologies

After generated the MASc map in the Netlogo code, we can obtain the image pixels for each area in the interface.

GO: 	Starts and stops the model.
SETUP:	Resets the simulation according to the parameters ser by the sliders.

Agents Settings: Agents settings is used to fix number of operator, public manager, externalhelp, exploitation and of natural resources.

Others Settings : Others settings is used to observe natural resources and deviant during several iterations.

--------------------

## THINGS TO NOTICE

Run the model with the default settings. Watch the interactions between stakeholders in common pool resources in a territory. Which will be a deviant or have a good behavior? Which stakeholders influence more the resources management's in the territory?

## THINGS TO TRY

Slowly decrease the natural resources slider. What happens to the stakeholders ?
Slowly increase the deviants slider. What will be the stakeholders behaviors ?

## EXTENDING THE MODEL

Try to add somme other ennvironement factors influencing the comon pool resources and deviance. You could had patches of differents types of resources across the borders in neighbors areas for study severals areas in the same model. You could add more socio-economics and environment features to observ in others settings.

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

Breeds are used to represent the three differents kinds of agents. The TURTLES prioprities is used to refer to three breeds together.

## RELATED MODELS

Altruism and cooperative / individual / coopetitive.

## CREDITS AND REFERENCES

All tools can be found in the virtual machine of LIM, University of La Réunion at :

--------------------
If you mention this model in an academic publication, we ask that you include these citations for the model itself and for the all the tool SIEGMAS.

- A. Gaudieux, R. Courdier, J. Kwan. Multi-agents model for the study of interactions between the stakeholders in the common pool resources: application to the district of Miarinarivo (Madagascar). 8th International Conference on Multi-Agent Systems and Simulation (MAS&S’14), September 07-10 2014, Warsaw, Poland, pp.12, 2014.

- A. Gaudieux, J. Kwan,  Y. Gangat, R. Courdier.  MASC: MAp Sectors Creator - a tool to help at the configuration of multi-agents systems for everyone.SIMULTECH 2014. ISBN: 978-989-758-038-3.
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
NetLogo 5.3.1
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
