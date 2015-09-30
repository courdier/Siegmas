; -------------------------------------------------------------------------------
; SIEGMAS
; AN AGENT-BASED SYSTEM FOR STAKEHOLDERS INTERACTIONS IN ENVIRONNEMENTAL GOVERNANCE
; V 1.2 2015 
; -------------------------------------------------------------------------------

; -------------------------------------------------------------------------------
; Global variables
; -------------------------------------------------------------------------------
globals [
  
  ;; some globale variables 
  x y     ; temp x and y coordinate 
  g_vrai? ; temp Boolean var

  ;; Map info init by masc
  g_mapContext          ; name of the current map processed by the model, default "Default map"
  g_defaultColor        ; invalid Area for agents location default "white"
  
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
  g_agent_to_plot
  g_agentIdToPlot
  g_mouseysave
  g_mousexsave
]

; -------------------------------------------------------------------------------
; Types of Agents used by SIEGMAS (from JFSMA15)

; stakeholders -------
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

; Resources ------
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
]

directed-link-breed [isHelpBys isHelpBy] ; used by manager agents
directed-link-breed [isExploitedBys isExploitedBy] ; used by Exploitation agents
directed-link-breed [isManagedBys isManagedBy] ; used by operator agents

operators-own [
  plots                ; Integer - number of owned patch
  money                ; Float - available money in euros
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
        
        ; init Siegmas agents
        output-print "Creation of agents... "          

        ifelse g_mapContext = "Default map" 
        [ ; agents initialisation by the default procedure
          defaultAgentInit ] 
        [ ; agents initialisation by a costom procedure
          customAgentInit ]
      
        ; init IHM vars for agents
        set g_agentToInspect turtle 0 ;  default value
        set g_lastNode turtle 0 ;  default value
        set g_agentInspector ("Select <Highlight Agent> button and move the mouse on the map to get agent data")
        set g_stopHighlight? FALSE       

        ; plot the initial state of the simulation 
        reset-ticks
        output-print "Initialisation OK" 
        output-print "<Highlight> to inspect agents on the map" 
        output-print "<Go> to Start the simulation"                 
        set g_agent_to_plot max-one-of externalHelps [ devianceLevel ]
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

      ask patches [  ifelse (isInvalidArea?) [set deteriorationLevel 0] [set deteriorationLevel random 100]]
 
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

; --- Création d'agent Manager ---
; son niveau de déviance est initialisé avec une valeur aléatoire entre 0 et 100
to createManagers  
   if g_debug? [print (word "*** Creating " nbManagers " manager agents")]
   create-managers nbManagers
   [ 
     set g_cpt 0;
     findValidAgentArea ; No Manager on non identified area 
     set shape "person business" 
     set size ceiling (max-pxcor / (100 - g_sizeRate))
     set color red
     ifelse (random 10 = 1) ; we expect that only 1/10 of opertors can be strongly deviant
          [set devianceLevel ((random 25) * 4) ]
          [ifelse (random 2 = 1) ; we expect that only 1/2 of the others can be slightly deviant opertors
            [set devianceLevel random 50] 
            [set devianceLevel 0] ; we expect that the others opertors have a total respect of moral ethics
          ]
   ]
      
   ; Link a list of Operators to help
   if g_debug? [print " ** Creating Links between a manager and operators"]
   ask managers [ createManagerLinkWithOperators self ]

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
     ifelse (random 10 = 1) ; we expect that only 1/10 of opertors can be strongly deviant
          [set devianceLevel ((random 25) * 4) ]
          [ifelse (random 2 = 1) ; we expect that only 1/2 of the others can be slightly deviant opertors
            [set devianceLevel random 50] 
            [set devianceLevel 0] ; we expect that the others opertors have a total respect of moral ethics
          ]
   ]
   
   ; Link a list of managers to help
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
          
      ifelse (random 24 = 1) ; we expect that only 1/25 of externalHelp can be strongly deviant
          [set devianceLevel ((random 25) * 4) ]
          [ifelse (random 3 = 1) ; we expect that only 1/3 of the others can be slightly deviant externalHelp
            [set devianceLevel random 50] 
            [set devianceLevel 0] ; we expect that the others externalHelp have a total respect of moral ethics
          ]
    ]
    
    ; Link a list of managers to help
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
 
  ask managers [ 
     ifelse (devianceLevel = 0)
       ; if this manager is totally Ethic, this may change due to personal bad experience or major economic event
       [ if (random 15 = 0) [set devianceLevel random 101]] ; regularly people change !
       ; if this manager is not totally Ethic, his devianceLevel can just slightly evolve +/- 10 % during time
       [ ifelse (random 2 = 0) 
          [set devianceLevel min list (devianceLevel + random 8) 100 ] 
          [set devianceLevel max list (devianceLevel - random 10) 0]
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
  set g_agentIdToPlot turtle #_of_the_agent_To_Plot
  display
end

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
end 


; -------------------------------------------------------------------------------
; main entry - Go procedure
; -------------------------------------------------------------------------------
to go
  if g_mapContext = "Nill" [
    user-message ("Topological environment not set") 
    stop
  ]
  set g_agentIdToPlot turtle #_of_the_agent_To_Plot
   
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
      
      ; plotting an agent      
      if (#_of_the_agent_To_Plot != 0)
      [ ifelse (not is-turtle? turtle #_of_the_agent_To_Plot) 
        [ output-print "Error plotting an agent"]
        [ 
          set-current-plot "Plot_a_selected_agent"
          set-current-plot-pen "deviance"
          ifelse (is-externalHelp? turtle #_of_the_agent_To_Plot) 
              [set-plot-pen-color yellow] 
              [ ifelse (is-manager? turtle #_of_the_agent_To_Plot) [set-plot-pen-color red] [set-plot-pen-color green]]
          ask turtle #_of_the_agent_To_Plot [plot devianceLevel]
        ]
      ]
      tick
  ]
  [stop]
end

; -------------------------------------------------------------------------------
; Copyright 2015 LIM Lab.
; University of Reunion Island.
@#$#@#$#@
GRAPHICS-WINDOW
301
55
915
594
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
1
1
1
ticks
30.0

SLIDER
6
194
133
227
nbManagers
nbManagers
0
100
26
1
1
NIL
HORIZONTAL

BUTTON
139
71
285
104
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
229
107
284
140
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
336
286
369
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
7
229
132
262
nbOperators
nbOperators
0
100
48
1
1
NIL
HORIZONTAL

SLIDER
7
263
133
296
nbExternalHelps
nbExternalHelps
0
100
19
1
1
NIL
HORIZONTAL

SLIDER
143
195
286
228
nbNaturalResources
nbNaturalResources
0
100
40
1
1
NIL
HORIZONTAL

SLIDER
143
231
287
264
nbExploitations
nbExploitations
0
100
100
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
9
67
159
85
initial settings
11
0.0
1

TEXTBOX
8
313
289
343
Other settings_________________________________
12
0.0
1

TEXTBOX
202
10
325
60
SIEGMAS \n   V1.3.b
20
0.0
1

TEXTBOX
7
177
157
195
Stakeholders
11
104.0
1

TEXTBOX
143
178
293
196
Resources
11
93.0
1

TEXTBOX
8
158
291
176
Agents settings________________________________
12
0.0
1

TEXTBOX
6
10
173
38
University of Reunion Island, LIM Lab
11
15.0
1

PLOT
928
234
1475
593
Rate of deviant Stakeholders with devianceLevel > 50 %
tick
Rate of deviant agents (%)
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"cumul" 1.0 0 -16777216 true "" "plot (100 * (count turtles with [devianceLevel > 50])) / (count operators + count managers + count externalhelps)"
"operator" 1.0 0 -10899396 true "" "plot (100 * (count operators with [devianceLevel > 50])) / (count operators)"
"manager" 1.0 0 -2674135 true "" "plot (100 * (count managers with [devianceLevel > 50])) / (count managers)"
"externalHelp" 1.0 0 -1184463 true "" "plot (100 * (count externalHelps with [devianceLevel > 50])) / (count externalHelps)"

SLIDER
7
337
134
370
agriculture%
agriculture%
10
100
100
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
301
10
837
55
Inspect Agent
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
837
10
915
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
140
107
227
140
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
0
1
-1000

TEXTBOX
12
604
318
649
Advanced options_____________________________
12
0.0
1

OUTPUT
929
10
1475
227
15

CHOOSER
6
93
121
138
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
1
99
30
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
8
392
300
410
Display options________________________________
12
0.0
1

BUTTON
146
462
287
495
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
497
288
530
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
0
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
30
5
1
%
HORIZONTAL

INPUTBOX
926
608
1056
668
#_of_the_agent_To_Plot
145
1
0
Number

PLOT
926
670
1476
862
Plot_a_selected_agent
tick
deviance level (%)
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"deviance" 1.0 0 -16777216 true "" ""

MONITOR
1062
609
1210
654
Agent ID
g_agentIdToPlot
17
1
11

@#$#@#$#@
## WHAT IS IT?

SIEGMAS (Stakeholders Interactions in Environmental Governance by a Multi-Agents System) is a model which permits to study the interactions between stakeholders in common pool ressources. The implementation with Netlogo can make simulations on the management of natural resources evolutions'. 
This decision support system called SIEGMAS-2 (Stakeholders Interactions in Environmental Governance by a Multi-Agent System) is based on a model of agents. Its aim is to study the interactions between agents acting on territory under an economic aspect via agronomic interface. The work presented here is an extension of a first system SIEGMAS.
SIEGMAS-2 uses an interactive and dynamic interface with powerful configuration properties through map and interpretation of results through tools from Big Data’s field.
In this model, we introduce the sensitive issue of community governance and justify the interest of SMA approach. We describe the Agent Based Simulation’s conceptual model associated with our system and then introduce some original extensions. First, we propose a configuration tool MASC (MAp Sector Creator) in order to generate flexibly a simulation environment from digital maps with expert’s data representation. Secondly, we introduce some data analysis tools based on a complete separation of generated data and its visualization. 
 

## HOW IT WORKS

Every turn, each stakeholder look at the patch that is currently on, has intercations with another one. He can cooperate or no, have a good behavior or be a deviant. Severals measures which describe the strategies can be use by the agent to achieve his goal. 
--------------------
A turtle can be a public manager, an operator or an externalhelp. 
Public Manager control others stakeholders, but he can also be a deviant. 
--------------------
An iteration represents a month. 
--------------------
Sometimes the public manager try to adopt good strategies to develop an area. So, externalhep and operator try to do the same thing to respect the rules and don't have sanctions.  
But when the public manager is a deviant and when we can observe corruption at each level of the centralized and decentralized authorities others stakeholders (externalhelp and operator) have the right light to do the same thing. 
So, the system and all the society can be deviant or it is more difficult to a stakeholder to adopt a good behavior when the rate of deviance is high in his country. 

--------------------

## HOW TO USE IT

At the beginning of the code source, we use MASC. 
--------------------
The computer modelling is the formal description of a system that allows manipulation of a virtual copy using a computer. To obtain this virtual representation, there is implementation of the model. There is a passage of a theoretical context to a more concrete one, which is the production of codes to be used to have a final product in the form of an application.
Before running a simulation, the initialization must be settled, which includes configuring the simulation context. Knowing that the context has a huge impact on the proceedings and the outcomes of the simulation, we often give more attention to data in particular and starting environment. Each configuration leads, so to speak, to an almost unique experience depending on the configuration settings. (Gangat, et al., 2009)
Optimization of working time issue arises when we handle complex systems, especially in multi-agents systems where we prefer to pay more attention to data and different proceedings performed during iterations.
For helping to solve this problem, we propose MASC, an easy to use tool that can provide an environment base represented by cutting a base map, diagram or plan into a grid of sectors directly usable in multi-agents simulation platforms as NetLogo (Wilensky, 1999) the platform of multi-agent simulation of IREMIA laboratory at the University of Reunion Island, GEAMAS-NG (GEneric Architecture for MultiAgent Simulations) (Payet, et al., 2006). 
Thus, MASC permits to save time and focus on implementation of models. In addition, MASC provides a simplified user experience through opportunities brought by recent developments in Web technologies 
--------------------
After generated the MASc map in the Netlogo code, we can obtain the image pixels for each area in the interface. 
--------------------
GO: Starts and stops the model. 
SETUP:Resets the simulation according to the parameters ser by the sliders. 
 --------------------
Agents Settings 

Agents settings is used to fix number of operator, public manager, externalhelp, exploitation and of natural resources. 
--------------------
Others Settings

Others settings is used to observe natural resources and deviant during several iterations. 

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
NetLogo 5.1.0
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
