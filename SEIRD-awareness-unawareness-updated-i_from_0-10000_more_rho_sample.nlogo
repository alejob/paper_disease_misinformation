extensions [ nw profiler]

turtles-own
  [ susceptible?
    exposed?             ;; if true -> person exposed //el ? indica booleano
    infected?            ;; if true -> person infected
    immunity?            ;; if true -> person immune (removed)
    dead?                ;; if true -> person dead
    buried?                ;; if true -> person has been buried
    exposed-time         ;; how long, in days, the person has been exposed
    infected-time        ;; how long, in days, the person has been infected
    immunity-time        ;; how long, in days, the person has been immune
    dead-time            ;; how long, in days, the person has died
    bury-time            ;; how long, in days, the person has been buried
    secondary-cases-live ;; how many people has infected while infected and live
    secondary-cases-dead ;; how many people has infected while infected and dead
    secondary-cases-live-temp ;; how many people has infected while infected and live in the last time step
    secondary-cases-dead-temp ;; how many people has infected while infected and dead in the last time step
    ;;Awareness
    awareness-level      ;; level of awareness, awarenes=0 is the maximum awareness
    awareness-time       ;; how long, in days, the person has been awareness
    ;;Fake news
    unawareness-level       ;; level of unawareness, unawarenes=0 is the maximum unawareness
    unawareness-time        ;; how long, in days, the person has been unawareness
    ;;Acceptance rate of central entity
    ;;acceptance_rate_gov  ;;how much the information from a central gov is accepted, 0<acceptance_rate_gov<1
    ;;infected-prev?         ;; if true -> person was infected previous day
 ]

globals
  [ %susceptible
    %exposed             ;; what % of the population is exposed
    %infected            ;; what % of the population is infected
    %immune              ;; what % of the population is immune (recovered)
    %dead                ;; what % of the population is dead
    %buried              ;; what % of the population is buried
    exposed-constant     ;; disease parameters
    infected-constant    ;; disease parameters
    bury-constant
    infection-rate       ;; live to susceptible infection rate
    infection-dead-rate  ;; dead to susceptible infection rate
    dead-rate            ;;
    sec-cases            ;; auxiliar to set secondary cases
    R0                   ;; Basic reproductive number calculated by formula
    R0-histogram
    R0-live              ;; R0 of live people in time
    R0-dead              ;; R0 of dead people in time
    R0-total             ;; sum of R0-live and R0-dead
    f                    ;; proportion of people that dead after being infected
    R0-live-temp              ;; R0 of live people in one time step
    R0-dead-temp              ;; R0 of dead people in one time step
    R0-total-temp             ;; sum of R0-live and R0-dead in one time step
    infected-prev        ;;
    infected-new         ;; new infected

    ;; awareness globals
    %awareness           ;; what % of the population is awareness
    %unawareness           ;; what % of the population is unawareness
    decay-constant-awareness        ;; how fast awareness decrease, also know as rho. Bigger is bigger awareness.
    decay-constant-unawareness      ;; how fast unawareness decrease, also know as rho. Bigger is bigger awareness.
    alpha-awareness          ;;how beneficial is the behaviour to avoid the disease, <0 THESE CONSTANT COULD BE IN AGENT PROPERTIES, HERE ARE GLOBAL PROPERTIES
    alpha-unawareness        ;;how harmful is the behaviour to power up the disease, >0
    infected-constant-var ;; to plot
    counter              ;; helps to counter the numbers of persons in certain awareness level
    randnum             ;;auxiliar
    time                 ;; execution time
    denominator          ;; auxiliar in update variable
    live-agents            ;;live agents, no matter states, only if they are alive
    prev-susceptible-number ;; to evaluate stop the simulation, if susceptibles don't change after 10 step, then stop
    susceptible-number      ;; idem
    counterb
    stop_now                ;; boolean to stop simulation
    Lambda                 ;; behavior-information constant
    ;;total_agents         ;; total agents, auxiliar variable to avoid call many times "count turtles", ya existe, definido en los sliders
    aux_imm                ;; auxiliar
]



to setup
  clear-all
  set stop_now False
  setup-constants
  setup-agents
  ;;update-R0
  update-global-variables
  ;;nw:set-context turtles links
  ;;nw:generate-watts-strogatz turtles links total-agents 2 0.1
  update-display
  ;;create-communications-links
  reset-ticks
end

;;to create-communications-links
  ;;this create an Erdos-Renyi random network of communication among agents
;;  ask turtles [
;;    create-links-with turtles with [self > myself and random-float 1.0 < network-probability]
  ;;]
;;end


;; We create a variable number of turtles of which 10 are infectious,
;; and/or awareness, and distribute them randomly
to setup-agents
  create-turtles total-agents
    [ setxy random-xcor random-ycor
      set exposed-time 0
      set infected-time 0
      set immunity-time 0
      set dead-time 0
      set bury-time 0
      set secondary-cases-live 0
      set secondary-cases-dead 0
      set secondary-cases-live-temp 0
      set secondary-cases-dead-temp 0
      set size 1.5  ;; easier to see
      set susceptible? true
      set exposed? false
      set infected? false
      set immunity? false
      set dead? false
      set buried? false
      ;; awareness setup
      set awareness-level 100
      set unawareness-level 100
      ;;set acceptance_rate_gov 0.4
  ]
  ask n-of init-infected turtles
      [ get-infected  ]
  ask n-of awareness-init turtles
      [ gen-awareness ]
  ask n-of unawareness-init turtles
      [ gen-unawareness ]
  ;;nw:set-context turtles links
  ;;nw:generate-watts-strogatz turtles links total-agents 2 0.1

end

;;to update-R0
;;  set R0 mean [infection-rate * (1 - alpha-awareness * decay-constant-awareness ^ awareness-level + alpha-unawareness * decay-constant-unawareness ^ unawareness-level) * infected-constant + dead-rate * infection-dead-rate * (1 - alpha-awareness * decay-constant-awareness ^ awareness-level + alpha-unawareness * decay-constant-unawareness ^ unawareness-level) * bury-constant] of turtles with [not dead? and not buried?]
  ;;set R0-histogram [
  ;;histogram [infection-rate * (1 - alpha-awareness * decay-constant-awareness ^ awareness-level + alpha-unawareness * decay-constant-unawareness ^ unawareness-level) * infected-constant + dead-rate * infection-dead-rate * (1 - alpha-awareness * decay-constant-awareness ^ awareness-level + alpha-unawareness * decay-constant-unawareness ^ unawareness-level) * bury-constant] of turtles
;;end

;; Here the persons changes its states
;; Disease states
to get-exposed
  set susceptible? false
  set exposed? true
end

to get-infected
  set infected? true
  if susceptible? [set susceptible? false]
  set exposed? false
  if inform-infected [ set awareness-level 0 ] ;; el infectado tiene nueva informacion/replinesh
  ;;set infected-prev? true
end

to get-immunity
  set infected? false
  set immunity? true
end

to get-dead
  set infected? false
  set dead? true
end

to get-buried
  set dead? false
  set buried? true
end

;; Awareness states
to gen-awareness
  set awareness-time 0
  set awareness-level 0
end

to gen-unawareness
  set unawareness-time 0
  set unawareness-level 0
end

to time-awareness-reset
  set awareness-time 0
end

to time-unawareness-reset
  set unawareness-time 0
end

;;End change of states

;; This sets up basic constants of the model.
to setup-constants
  ;; disease parameters
  set exposed-constant 11
  set infected-constant 6
  set bury-constant 4
  set dead-rate 0.7
  set infection-rate 0.25   ;; original 0.25                     ;; coloco 100 para probar hasta que infection-rate puedo detener solo con awareness
  set infection-dead-rate 0.20;; original  0.20
  ;; awareness parameters, 0 < decay-constant=rho < 1, closer to 1 the people remember more time
  set decay-constant-awareness decay-aw          ;;0.8
  set decay-constant-unawareness decay-unaw      ;;0.8
  set alpha-awareness alpha-aw                   ;; 0<x<1, bigger is more beneficial protective behaviour
  set alpha-unawareness alpha-unaw               ;; >0, bigger is more harmful behavior
  set infected-prev     0
end

to go
  ;;if ticks = 0 [reset-timer]
  ;;set prev-susceptible-number count turtles with [ susceptible? ]
  ;;set infected-prev (count turtles with [ infected? ])
  ;;get-older                                                              ;; all the turtles get older
  ask turtles [
    ;; disease
    if buried? [stop]
    if not dead? and not buried? and not immunity? [move]                                  ;; dead, buried and immunity don't move


;    if exposed? and exposed-time >= exposed-constant [get-infected]
;    if infected? [infect]
;    if infected? and infected-time >= infected-constant [recover-or-die]
;    if dead? [infect-dead]
;    if dead? and dead-time >= bury-constant [get-buried]

    ;; In this way there is only one change of state or action by time step. In this way the spread of infectious disease is slower.
    (ifelse
      exposed? and exposed-time >= exposed-constant
          [get-infected]
      infected? and infected-time >= infected-constant
          [recover-or-die]
      infected?
          [infect]
      dead? and dead-time >= bury-constant
          [get-buried]
      dead?
          [infect-dead]
    )

    if not dead? and not buried? and people-communication[               ;; awareness, only live people contribute to awareness, must be live agents
      awareness-communicate
      unawareness-communicate
    ]
  ]

  ;;COMMUNICATION FROM GOVERNMENT
  ;;Awareness
  if ticks > init_info_time and (ticks mod freq-information) = 0 and gov-communication [        ;; init_info_time is when the gov starts to send messages and ticksmodfreq change the frequency of information. freq-information is the numbers of days since last message
    set live-agents (total-agents - count turtles with [dead?] -  count turtles with [buried?])
    ;;ask n-of awareness-cte turtles with [not dead? and not buried?]                           ;; estas acciones se aplican a cada agente, NUMERO FIJO DE AGENTES
    ask n-of (live-agents * %awareness-cte) turtles with [not dead? and not buried?]            ;; estas acciones se aplican a cada agente, PORCENTAJE
          [ set randnum  random-float 100
            ;;print "random" print randnum;; se crea un random para cada agente, BIEN
            if randnum < 100 * acceptance_rate_gov
               [gen-awareness]
    ]
  ]

  ;;Unawareness
    ;; DON'T USE if ticks > init_info_time and (ticks mod freq-information) = 0 and fake-communication [        ;; init_info_time is when the gov starts to send messages and ticksmodfreq change the frequency of information. freq-information is the numbers of days since last message
    if ticks > init_info_time and (ticks mod freq-information) = 0 [        ;; init_info_time is when the gov starts to send messages and ticksmodfreq change the frequency of information. freq-information is the numbers of days since last message
    set live-agents (total-agents - count turtles with [dead?] -  count turtles with [buried?])
    ask n-of (live-agents * %unawareness-cte) turtles with [not dead? and not buried?]            ;; estas acciones se aplican a cada agente, PORCENTAJE
          [ set randnum  random-float 100
            if randnum < 100 * acceptance_rate_fake_media ;; 0.68, acceptance_rate_fake_media, Vosoughi 2018 (reality: 70% more retweet probability than true. True=40% so False=70*40/100 + 40 = 68%)
               [gen-unawareness]
    ]
  ]

  ;;update-R0
  ;;update-global-variables
  ;; USE TO SEE DISPLAY
  ;;update-display
  ;; USE THIS ifelse count turtles with [infected?] - infected-prev > 0 [set infected-new ((count turtles with [infected?]) - infected-prev)] [set infected-new 0]
  ;;ifelse empty? [secondary-cases-live-temp] of turtles with [infected?] [set R0-live-temp 0] [set R0-live-temp mean [secondary-cases-live-temp] of turtles with [infected?]] ;; count infected


  get-older    ;; all the turtles get older

  tick
end

to evaluate-stop
  set susceptible-number count turtles with [ susceptible? ]
  ifelse prev-susceptible-number = susceptible-number [
    set counterb counterb + 1
    ;;print counterb
    if counterb = 50 [
      set stop_now True
      ;;stop
    ]
  ]
  [set counterb 0]
end

;;Turtle counting variables are advanced.
to get-older
  ask turtles [
  ;; disease
  if exposed?  [ set exposed-time exposed-time + 1 ]
  if infected? [ set infected-time infected-time + 1 ]
  if immunity? [ set immunity-time immunity-time + 1 ]
  if dead?     [ set dead-time dead-time + 1 ]
  if buried?   [ set bury-time bury-time + 1 ]
  ;; awareness
  if not dead? and not buried? [
      set awareness-time awareness-time + 1
      set awareness-level awareness-level + 1
      set unawareness-time unawareness-time + 1
      set unawareness-level unawareness-level + 1 ]
  ]
end

;; Turtles move about at random.
;; turtle procedure
to move
  rt random 100
  lt random 100      ;;The turtle turns left by number degrees. (If number is negative, it turns right.)
  ;;rt -100 + random 200
  fd 1               ;;move random just one step
end

;; DISEASE
;; turtle procedure
to recover-or-die
    ifelse random-float 100 < 100 * dead-rate;; chance-recover, either recover or die. Ebola 70% mortality.
      [ get-dead ]
      [ get-immunity ]

end

;; If a turtle is infected, it infects other turtles on the same patch.
;; exposed, infected, immune, dead and buried turtles don't get sick.
;; Here I set how the information affects the infectious rate.
to infect
  ;;print "####Begin"
  set sec-cases 0
  set randnum  random-float 100
  ask other turtles-here with [ not exposed? and not infected? and not immunity? and not buried? and not dead? ]
      [ if randnum < 100 * infection-rate * (1 - alpha-awareness * decay-constant-awareness ^ awareness-level + alpha-unawareness * decay-constant-unawareness ^ unawareness-level) ;; infectiousness
        [ get-exposed
          set sec-cases (sec-cases + 1)
          ;;print "infected"
        ]
  ]
  ;;print sec-cases
  set secondary-cases-live (secondary-cases-live + sec-cases)
  set secondary-cases-live-temp sec-cases
  ;;print secondary-cases-live
  ;;print "####End"
end

to infect-dead ;; turtle procedure
  set sec-cases 0
  ask other turtles-here with [ not exposed? and not infected? and not immunity? and not buried? and not dead? ]
    [ if random-float 100 < 100 * infection-dead-rate * (1 - alpha-awareness * decay-constant-awareness ^ awareness-level + alpha-unawareness * decay-constant-unawareness ^ unawareness-level)
      [ get-exposed
        set sec-cases (sec-cases + 1)
      ]
  ]
  set secondary-cases-dead (secondary-cases-dead + sec-cases)
  set secondary-cases-dead-temp sec-cases
end

;; WE ASSUMME 100% OF MESSAGE ACCEPTANCE, UNCOMMENT "and randnum < 100" TO CHANGE THIS
;; AWARENESS
;; If a turtle has awareness, it communicates turtles on the same patch
to awareness-communicate ;; turtle procedure
  ;;set randnum  random-float 100
  ask other turtles-here with [not buried? and not dead? ]
  [ if awareness-level > ([awareness-level] of myself ) and ([awareness-level] of myself ) < ([unawareness-level] of myself);; and randnum < 100;; 40 es la tasa a la que los agentes aceptan la informacion (0.4). Simbolo < porque mas cercano a cero es mas awareness
      [ time-awareness-reset set awareness-level ([awareness-level] of myself + 1) ] ] ;; ejecuto func time-awareness-reset y luego set awareness-level
end

to unawareness-communicate
  ;;set randnum  random-float 100
  ask other turtles-here with [not buried? and not dead? ]
  [ if unawareness-level > ([unawareness-level] of myself ) and ([unawareness-level] of myself) < ([awareness-level] of myself);; and randnum < 100 ;; 40*1.7 = 68, rate at which agents retweet false news, Vosoughi2018
      [ time-unawareness-reset set unawareness-level ([unawareness-level] of myself + 1) ] ] ;; ejecuto func time-unawareness-reset y luego set unawareness-level
end

to update-global-variables
 ;; disease
 ;;set %susceptible (count turtles with [ susceptible? ] / total-agents) * 100
 ;;set %exposed (count turtles with [ exposed? ] / total-agents) * 100
 ;;set %infected (count turtles with [ infected? ] / total-agents) * 100
 ;;set %immune (count turtles with [ immunity? ] / total-agents) * 100
 ;;set %dead (count turtles with [ dead? ] / total-agents) * 100
 ;;set %buried (count turtles with [ buried? ] / total-agents) * 100


 ;; awareness
  ;;set counter 0
  ;;set %awareness 0
  ;;set %unawareness 0
  ;;set denominator total-agents - count turtles with [dead?] -  count turtles with [buried?] ;; this is for speed up the execution, set outside the while
  ;;while [counter < 200] ;; bigger than 200 terms in the sum can be neglected, sobre 100 parece que da lo mismo la cantidad
  ;;    [
  ;;     set %awareness %awareness + ((count turtles with [ awareness-level = counter and awareness-level < unawareness-level and not dead? and not buried?] / denominator) * alpha-awareness * decay-constant-awareness ^ counter)
       ;;uncomment when use unawareness
  ;;     set %unawareness %unawareness + ((count turtles with [ unawareness-level = counter and unawareness-level < awareness-level and not dead? and not buried?] / denominator) * alpha-unawareness * decay-constant-unawareness ^ counter)
  ;;     set counter counter + 1
  ;;    ]

  ;;R0 to plot
  ;;Original
  ;;ifelse empty? [secondary-cases-live] of turtles with [not susceptible? and not exposed?] [set R0-live 0] [set R0-live mean [secondary-cases-live] of turtles with [not susceptible? and not exposed?]] ;; count infected, removed, dead and buried
  ;;set aux_imm   count turtles with [not susceptible? and not exposed?]  / (count turtles with [immunity?])
  ;;ifelse count turtles with [immunity? or buried?] = 0 [set aux_imm 1] [set aux_imm count turtles with [immunity? or buried?]]

  ;; R_effective
  ;;ifelse empty? [secondary-cases-live] of turtles with [not susceptible? and not exposed? and not immunity? and not buried? and not dead?] [set R0-live 0] [set R0-live mean [secondary-cases-live] of turtles with [not susceptible? and not exposed? and not immunity? and not buried? and not dead? ]] ;; count infected
  ;;ifelse empty? [secondary-cases-dead] of turtles with [dead?]                                                                             [set R0-dead 0] [set R0-dead mean [secondary-cases-dead] of turtles with [dead?]]                  ;; count only dead
  ;;ifelse empty? [secondary-cases-live + secondary-cases-dead] of turtles with [not susceptible? and not exposed?] [set R0-total 0] [set R0-total mean [secondary-cases-dead + secondary-cases-live] of turtles with [not susceptible? and not exposed?]]

  ;;f, proportion of dead people from infected
  ;;set f count turtles with [dead? or buried?] / count turtles with [infected? or immunity? or dead? or buried?]

  ;;ifelse empty? [secondary-cases-live-temp] of turtles with [infected?] [set R0-live-temp 0] [set R0-live-temp mean [secondary-cases-live-temp] of turtles with [infected?]] ;; count infected
  ;;ifelse empty? [secondary-cases-dead-temp] of turtles with [dead?]     [set R0-dead-temp 0] [set R0-dead-temp mean [secondary-cases-dead-temp] of turtles with [dead?]]     ;; count dead
  ;;ifelse empty? [secondary-cases-live-temp + secondary-cases-dead-temp] of turtles with [dead? or infected?] [set R0-total-temp 0] [set R0-total-temp mean [secondary-cases-dead-temp + secondary-cases-live-temp] of turtles with [dead? or infected?]]


end

to update-display
  ask turtles
    [ if shape != turtle-shape [ set shape turtle-shape ]
      if susceptible? [set color green]
      if exposed? [set color orange]
      if infected? [set color red]
      if immunity? [set color grey]
      ;;if dead? and not buried? [set color white]
      if dead? [set color white]
      ;;if dead? [set color sky - 1]
      if buried? [set color brown]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
761
121
1268
629
-1
-1
5.874
1
10
1
1
1
0
1
1
1
-42
42
-42
42
1
1
1
ticks
30.0

BUTTON
1700
362
1790
395
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

SLIDER
984
10
1156
43
total-agents
total-agents
10
50000
10000.0
1
1
NIL
HORIZONTAL

MONITOR
707
89
773
134
immune
%immune
17
1
11

BUTTON
1816
362
1879
395
go
go
T
1
T
OBSERVER
NIL
1
NIL
NIL
1

CHOOSER
782
10
920
55
turtle-shape
turtle-shape
"person" "circle"
0

MONITOR
585
89
685
134
susceptible
%susceptible
17
1
11

PLOT
763
624
1199
924
States
time
persons
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"exposed" 1.0 0 -955883 true "" "plot count turtles with [exposed?]"
"infected" 1.0 0 -2674135 true "" "plot count turtles with [infected?]"
"immune" 1.0 0 -7500403 true "" "plot count turtles with [immunity?]"
"dead" 1.0 0 -16777216 true "" "plot count turtles with [dead?]"
"susceptible" 1.0 0 -13840069 true "" "plot count turtles with [susceptible?]"

SLIDER
983
53
1155
86
init-infected
init-infected
1
total-agents
100.0
1
1
NIL
HORIZONTAL

MONITOR
789
90
876
135
buried
%buried
17
1
11

PLOT
35
66
413
291
Awareness
time
awareness
0.0
0.0
0.0
0.0
true
true
"" ""
PENS
"awareness" 1.0 0 -13840069 true "" "plot %awareness"
"unawareness" 1.0 0 -2674135 true "" "plot %unawareness"

PLOT
1230
753
1617
1033
behavior_info_factor
bif
frequency
0.0
10.0
0.0
10.0
true
true
"" "set-plot-x-range 0 2\nset-plot-y-range 0 600\nset-histogram-num-bars 40"
PENS
"default" 1.0 1 -16777216 true "" "histogram [1 - alpha-awareness * decay-constant-awareness ^ awareness-level + alpha-unawareness * decay-constant-unawareness ^ unawareness-level] of turtles"

SLIDER
1176
10
1357
43
%awareness-cte
%awareness-cte
0
1
0.7
0.01
1
NIL
HORIZONTAL

PLOT
490
740
650
896
Ro histogram
NIL
NIL
0.0
5.0
0.0
10.0
true
false
"" "set-plot-y-range 0 10000\nset-histogram-num-bars 100"
PENS
"default" 1.0 1 -16777216 true "" "histogram [infection-rate * (1 - alpha-awareness * decay-constant-awareness ^ awareness-level + alpha-unawareness * decay-constant-unawareness ^ unawareness-level) * infected-constant + dead-rate * infection-dead-rate * (1 - alpha-awareness * decay-constant-awareness ^ awareness-level + alpha-unawareness * decay-constant-unawareness ^ unawareness-level) * bury-constant] of turtles with [not dead? and not buried?]\n"

MONITOR
1751
460
1902
505
NIL
infected-constant-var
17
1
11

SLIDER
1176
48
1359
81
%unawareness-cte
%unawareness-cte
0
2
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
1399
10
1570
43
alpha-aw
alpha-aw
0
1
0.7
0.01
1
NIL
HORIZONTAL

SLIDER
1398
50
1570
83
alpha-unaw
alpha-unaw
0
1
0.0
0.01
1
NIL
HORIZONTAL

SLIDER
1678
13
1850
46
decay-aw
decay-aw
0
1
0.8
0.01
1
NIL
HORIZONTAL

SLIDER
1678
59
1850
92
decay-unaw
decay-unaw
0
1
0.0
0.01
1
NIL
HORIZONTAL

MONITOR
1071
116
1128
161
R0
R0
17
1
11

SLIDER
1178
92
1360
125
awareness-init
awareness-init
0
total-agents
0.0
1
1
NIL
HORIZONTAL

SLIDER
1178
131
1361
164
unawareness-init
unawareness-init
0
total-agents
0.0
1
1
NIL
HORIZONTAL

MONITOR
890
93
955
138
Infected
%infected
17
1
11

SLIDER
1710
179
1882
212
freq-information
freq-information
1
30
1.0
1
1
NIL
HORIZONTAL

SLIDER
1425
234
1620
267
acceptance_rate_gov
acceptance_rate_gov
0
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
1709
225
1881
258
init_info_time
init_info_time
0
200
0.0
1
1
NIL
HORIZONTAL

SLIDER
1473
334
1671
367
network-probability
network-probability
0
1
0.0
0.01
1
NIL
HORIZONTAL

MONITOR
1806
410
1863
455
time
time
17
1
11

BUTTON
1701
306
1778
339
profile
setup                  ;; set up the model\nprofiler:start         ;; start profiling\nrepeat 500 [ go ]       ;; run something you want to measure\nprofiler:stop          ;; stop profiling\nprint profiler:report  ;; view the results\nprofiler:reset         ;; clear the data
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
1489
183
1683
216
people-communication
people-communication
0
1
-1000

SWITCH
1489
138
1661
171
gov-communication
gov-communication
0
1
-1000

SWITCH
1488
94
1653
127
inform-infected
inform-infected
0
1
-1000

PLOT
18
323
398
619
histogram secondary cases (numeric R0)
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
"live" 1.0 1 -2674135 true "" "histogram  [secondary-cases-live] of turtles with [not susceptible? and not exposed?]"
"dead" 1.0 1 -16777216 true "" "histogram  [secondary-cases-dead] of turtles with [dead? or buried?]"
"live-temp" 1.0 0 -7500403 true "" "histogram  [secondary-cases-live-temp] of turtles with [not susceptible? and not exposed?]"

PLOT
1436
518
1917
863
numeric R0 test
NIL
NIL
0.0
10.0
0.0
2.5
true
true
"" ""
PENS
"R0-live" 1.0 0 -2674135 true "" "plot R0-live"
"R0-dead" 1.0 0 -16777216 true "" "plot R0-dead"
"R0-total" 1.0 0 -7500403 true "" "plot R0-live + R0-dead"
"R0-total-old" 1.0 0 -955883 true "" "plot R0-total"
"pen-4" 1.0 0 -6459832 true "" "plot 1"

MONITOR
303
702
373
747
R0 live
R0-live
17
1
11

MONITOR
300
755
366
800
R0-dead
R0-dead
17
1
11

MONITOR
394
703
516
748
R0-total
R0-total
17
1
11

PLOT
218
808
441
988
f
NIL
NIL
0.0
10.0
0.0
1.5
true
false
"" ""
PENS
"f" 1.0 0 -16777216 true "" "plot f"

SLIDER
1426
286
1693
319
acceptance_rate_fake_media
acceptance_rate_fake_media
0
1
1.0
0.01
1
NIL
HORIZONTAL

MONITOR
77
863
236
908
R0_converg
(sum [secondary-cases-dead + secondary-cases-live] of turtles with [not susceptible? and not exposed?] + 10 )\n / count turtles with [infected? or immunity? or dead? or buried?]
17
1
11

MONITOR
27
957
171
1002
secondary cases
sum [secondary-cases-dead + secondary-cases-live] of turtles with [not susceptible? and not exposed?]
17
1
11

MONITOR
30
732
90
777
new R0
(sum [secondary-cases-dead + secondary-cases-live] of turtles with [infected?] + 1)\n / count turtles with [immunity? or buried?]
17
1
11

MONITOR
136
738
240
783
mean Ci + Cd
mean [secondary-cases-dead + secondary-cases-live] of turtles with [not susceptible? and not exposed?]
17
1
11

MONITOR
18
792
85
837
mean Ci
mean [secondary-cases-live] of turtles with [immunity? or buried?]
17
1
11

PLOT
391
412
699
635
infected and infected-prev
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
"default" 1.0 0 -16777216 true "" "plot infected-prev"
"pen-1" 1.0 0 -2674135 true "" "plot count turtles with [infected?]"

MONITOR
433
319
531
364
infected prev
infected-prev
17
1
11

MONITOR
1306
395
1414
440
current infected
count turtles with [infected?]
17
1
11

MONITOR
447
199
543
244
infected-new
infected-new
17
1
11

MONITOR
1553
445
1619
490
NIL
R0-dead
17
1
11

MONITOR
1462
447
1519
492
NIL
R0-live
17
1
11

MONITOR
1644
446
1707
491
NIL
R0-total
17
1
11

MONITOR
1354
487
1423
532
exposed
count turtles with [exposed?]
17
1
11

MONITOR
674
323
746
368
NIL
aux_imm
17
1
11

@#$#@#$#@
## WHAT IS IT?

Code to reproduce a SEIRD model.

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
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="info_to_infected_r0_sec_cases_Lambda_evol" repetitions="20" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="320"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>Lambda</metric>
    <metric>f</metric>
    <steppedValueSet variable="alpha-aw" first="0.5" step="0.1" last="1"/>
    <steppedValueSet variable="decay-aw" first="0.5" step="0.1" last="1"/>
  </experiment>
  <experiment name="info_from_gov_basal" repetitions="20" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-info_from_gov_basal.csv")</final>
    <timeLimit steps="600"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>Lambda</metric>
    <metric>f</metric>
  </experiment>
  <experiment name="info_from_gov_inform_all_people" repetitions="20" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "all-plots" random-float 1.0 ".csv")</final>
    <timeLimit steps="900"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>Lambda</metric>
    <metric>f</metric>
  </experiment>
  <experiment name="info_from_gov_all_comm" repetitions="20" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "plots_info_from_gov_all_comm" random-float 1.0 ".csv")</final>
    <timeLimit steps="600"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>Lambda</metric>
    <metric>f</metric>
  </experiment>
  <experiment name="info_from_gov_2500" repetitions="20" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-info_from_gov_2500.csv")</final>
    <timeLimit steps="600"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>Lambda</metric>
    <metric>f</metric>
  </experiment>
  <experiment name="info_from_gov_10000" repetitions="20" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-info_from_gov_10000.csv")</final>
    <timeLimit steps="1300"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>Lambda</metric>
    <metric>f</metric>
  </experiment>
  <experiment name="info_from_gov_10000_find_per" repetitions="50" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-info_from_gov_10000_find_per.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>Lambda</metric>
    <metric>f</metric>
    <steppedValueSet variable="%awareness-cte" first="0.37" step="0.01" last="0.47"/>
  </experiment>
  <experiment name="gov_accept_rate_mod" repetitions="50" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-gov_accept_rate_mod.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>Lambda</metric>
    <metric>f</metric>
    <enumeratedValueSet variable="acceptance_rate_gov">
      <value value="0.2"/>
      <value value="0.4"/>
      <value value="0.6"/>
      <value value="0.8"/>
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="messages_on_time" repetitions="50" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "/tmp/messages_on_time.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>Lambda</metric>
    <metric>f</metric>
    <steppedValueSet variable="init_info_time" first="0" step="10" last="90"/>
  </experiment>
  <experiment name="fake_news" repetitions="50" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>Lambda</metric>
    <metric>f</metric>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="0"/>
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="acceptance_rate_gov">
      <value value="0.4"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-aw">
      <value value="0.8"/>
      <value value="0.99"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0.8"/>
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gov-communication">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inform-infected">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news_" repetitions="50" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>Lambda</metric>
    <metric>f</metric>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="0"/>
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="acceptance_rate_gov">
      <value value="0.4"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-aw">
      <value value="0.8"/>
      <value value="0.99"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0.8"/>
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gov-communication">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="inform-infected">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news_diff_rho-2" repetitions="50" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news_diff_rho-2.csv")</final>
    <timeLimit steps="500"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>Lambda</metric>
    <metric>f</metric>
    <enumeratedValueSet variable="decay-aw">
      <value value="0.7"/>
      <value value="0.6"/>
      <value value="0.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news_behavior_evaluation_mod_aw" repetitions="50" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-behavior_evaluation_mod_aw.csv")</final>
    <timeLimit steps="350"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>Lambda</metric>
    <metric>f</metric>
    <enumeratedValueSet variable="alpha-aw">
      <value value="0.8"/>
      <value value="0.7"/>
      <value value="0.6"/>
      <value value="0.5"/>
      <value value="0.4"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-no_agent_comm" repetitions="50" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news_cent-no_agent_comm.csv")</final>
    <timeLimit steps="700"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>Lambda</metric>
    <metric>f</metric>
    <enumeratedValueSet variable="acceptance_rate_gov">
      <value value="1"/>
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="0"/>
      <value value="0.25"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-var_percent_aw_unaw" repetitions="10" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-var_percent_aw_unaw.csv")</final>
    <timeLimit steps="100"/>
    <metric>%awareness</metric>
    <metric>R0-total</metric>
    <steppedValueSet variable="%awareness-cte" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="%unawareness-cte" first="0" step="0.1" last="1"/>
  </experiment>
  <experiment name="fake_news-var_percent_aw_unaw-alpha_aw-unaw1.0" repetitions="10" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-var_percent_aw_unaw-alpha_aw-unaw1.0.csv")</final>
    <timeLimit steps="100"/>
    <metric>R0-total</metric>
    <steppedValueSet variable="%awareness-cte" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="%unawareness-cte" first="0" step="0.1" last="1"/>
  </experiment>
  <experiment name="fake_news-var_percent_aw_unaw-alpha_aw-unaw1.0b" repetitions="10" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-var_percent_aw_unaw-alpha_aw-unaw1.0b.csv")</final>
    <timeLimit steps="100"/>
    <metric>R0-total</metric>
    <steppedValueSet variable="%awareness-cte" first="0" step="0.05" last="1"/>
    <steppedValueSet variable="%unawareness-cte" first="0" step="0.01" last="0.4"/>
  </experiment>
  <experiment name="fake_news-var_percent-aw_unaw-decay_aw_unaw-rho_aw_unaw1.0_more_sample" repetitions="5" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-var_percent-aw_unaw-decay_aw_unaw-rho_aw_unaw1.0_more_sample.csv")</final>
    <timeLimit steps="40"/>
    <metric>R0-total</metric>
    <steppedValueSet variable="%awareness-cte" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="%unawareness-cte" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="decay-aw" first="0" step="0.05" last="1"/>
    <steppedValueSet variable="decay-unaw" first="0" step="0.05" last="1"/>
  </experiment>
  <experiment name="fake_news-var_percent_aw-var_decay_aw_unaw-var_gamma_unaw-gamma_aw1.0" repetitions="5" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-var_percent_aw-var_decay_aw_unaw-var_gamma_unaw-gamma_aw1.0.csv")</final>
    <timeLimit steps="40"/>
    <metric>R0-total</metric>
    <steppedValueSet variable="%awareness-cte" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="decay-aw" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="decay-unaw" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="alpha-unaw" first="0" step="0.1" last="1"/>
  </experiment>
  <experiment name="fake_news-var_percent_aw-var_decay_aw_unaw-var_gamma_unaw-gamma_aw1.0-unaw_cte_10percent" repetitions="5" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-var_percent_aw-var_decay_aw_unaw-var_gamma_unaw-gamma_aw1.0-unaw_cte_10percent.csv")</final>
    <timeLimit steps="40"/>
    <metric>R0-total</metric>
    <steppedValueSet variable="%awareness-cte" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="decay-aw" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="decay-unaw" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="alpha-unaw" first="0" step="0.1" last="1"/>
  </experiment>
  <experiment name="fake_news-var_percent-aw_unaw-decay_aw_unaw-rho_aw_unaw1.0_more_sample-c" repetitions="10" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-var_percent-aw_unaw-decay_aw_unaw-rho_aw_unaw1.0_more_sample_c.csv")</final>
    <timeLimit steps="40"/>
    <metric>R0-total</metric>
    <steppedValueSet variable="%awareness-cte" first="0" step="0.05" last="1"/>
    <steppedValueSet variable="%unawareness-cte" first="0" step="0.05" last="1"/>
    <steppedValueSet variable="decay-aw" first="0" step="0.05" last="1"/>
    <steppedValueSet variable="decay-unaw" first="0" step="0.05" last="1"/>
  </experiment>
  <experiment name="last_plot-alpha_un-0.95" repetitions="10" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-last_plot.csv")</final>
    <timeLimit steps="40"/>
    <metric>R0-total</metric>
    <steppedValueSet variable="%awareness-cte" first="0" step="0.05" last="1"/>
    <steppedValueSet variable="%unawareness-cte" first="0" step="0.05" last="1"/>
    <steppedValueSet variable="decay-aw" first="0" step="0.05" last="1"/>
    <steppedValueSet variable="decay-unaw" first="0" step="0.05" last="1"/>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="0.95"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="last_plot-alpha_un-1.00" repetitions="10" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-last_plot.csv")</final>
    <timeLimit steps="40"/>
    <metric>R0-total</metric>
    <steppedValueSet variable="%awareness-cte" first="0" step="0.05" last="1"/>
    <steppedValueSet variable="%unawareness-cte" first="0" step="0.05" last="1"/>
    <steppedValueSet variable="decay-aw" first="0" step="0.05" last="1"/>
    <steppedValueSet variable="decay-unaw" first="0" step="0.05" last="1"/>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="info_from_gov_10000_find_per-testing_convergence" repetitions="500" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-info_from_gov_10000_find_per-testing_convergence.csv")</final>
    <timeLimit steps="60"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0.27"/>
      <value value="0.42"/>
      <value value="0.57"/>
      <value value="0.86"/>
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="info_from_gov_1000_find_per-testing_convergence-1000_rep" repetitions="1000" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-info_from_gov_1000_find_per-testing_convergence-1000_rep.csv")</final>
    <timeLimit steps="60"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>f</metric>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0.27"/>
      <value value="0.42"/>
      <value value="0.57"/>
      <value value="0.86"/>
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="info_from_gov_10000_find_per-testing_convergence-1000_rep" repetitions="1000" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-info_from_gov_10000_find_per-testing_convergence-1000_rep.csv")</final>
    <timeLimit steps="60"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>f</metric>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0.27"/>
      <value value="0.42"/>
      <value value="0.57"/>
      <value value="0.86"/>
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="info_from_gov_30000_find_per-testing_convergence-1000_rep" repetitions="1000" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-info_from_gov_30000_find_per-testing_convergence-1000_rep.csv")</final>
    <timeLimit steps="60"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>f</metric>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0.27"/>
      <value value="0.42"/>
      <value value="0.57"/>
      <value value="0.86"/>
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="info_from_gov_50000-states_convergence-1000_rep-400_time" repetitions="1000" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-info_from_gov_50000-states_convergence-1000_rep-400_time.csv")</final>
    <timeLimit steps="400"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>f</metric>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="info_from_gov_5000_50-find_optimal_std_dev-1000_rep" repetitions="1000" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-info_from_gov_5000_50-find_optimal_std_dev-1000_rep.csv")</final>
    <timeLimit steps="500"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>f</metric>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0"/>
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="info_from_gov_5000_50-find_optimal_std_dev-500_rep" repetitions="500" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-info_from_gov_5000_50-find_optimal_std_dev-500_rep.csv")</final>
    <timeLimit steps="500"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>f</metric>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0"/>
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="info_from_gov_5000_50-find_optimal_std_dev-750_rep" repetitions="750" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-info_from_gov_5000_50-find_optimal_std_dev-750_rep.csv")</final>
    <timeLimit steps="500"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>f</metric>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0"/>
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="info_from_gov_5000_50-find_optimal_std_dev-250_rep" repetitions="250" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-info_from_gov_5000_50-find_optimal_std_dev-250_rep.csv")</final>
    <timeLimit steps="500"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>f</metric>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0"/>
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="info_from_gov_5000_50-find_optimal_std_dev-100_rep" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-info_from_gov_5000_50-find_optimal_std_dev-100_rep.csv")</final>
    <timeLimit steps="500"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>f</metric>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0"/>
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="info_from_gov_5000_50-find_optimal_std_dev-2000_rep" repetitions="2000" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-info_from_gov_5000_50-find_optimal_std_dev-2000_rep.csv")</final>
    <timeLimit steps="500"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <metric>%awareness</metric>
    <metric>R0-live</metric>
    <metric>R0-dead</metric>
    <metric>R0-total</metric>
    <metric>f</metric>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0"/>
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="info_infected-10000_100-100_rep" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-info_infected-10000_100-100_rep.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="decay-aw" first="0" step="0.02" last="1"/>
    <enumeratedValueSet variable="inform-infected">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="info_central-10000_100-100_rep" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-info_central-10000_100-100_rep.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <steppedValueSet variable="%awareness-cte" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="decay-aw" first="0" step="0.02" last="1"/>
    <enumeratedValueSet variable="inform-infected">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="freq_info_central-10000_100-100_rep" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-freq_info_central-5000_50-100_rep.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="decay-aw" first="0" step="0.02" last="1"/>
    <enumeratedValueSet variable="inform-infected">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="freq-information">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="14"/>
      <value value="21"/>
      <value value="28"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="accept_rate_central-10000_100-100_rep" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-accept_rate_central-10000_100-100_rep.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <steppedValueSet variable="acceptance_rate_gov" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="decay-aw" first="0" step="0.02" last="1"/>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="delay_messages-10000_100-100_rep" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-delay_messages-5000_50-100_rep.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <steppedValueSet variable="init_info_time" first="0" step="10" last="90"/>
    <steppedValueSet variable="decay-aw" first="0" step="0.02" last="1"/>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="awareness_init_var-10000_100-100_rep" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-awareness_init_var-10000_100-100_rep.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="decay-aw" first="0" step="0.02" last="1"/>
    <enumeratedValueSet variable="awareness-init">
      <value value="10"/>
      <value value="100"/>
      <value value="1000"/>
      <value value="10000"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="central_and_people_comm-10000_100-100_rep" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-central_and_people_comm-10000_100-100_rep.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <steppedValueSet variable="%awareness-cte" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="decay-aw" first="0" step="0.02" last="1"/>
    <enumeratedValueSet variable="people-communication">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="info_central-10000_100-100_rep-MORE-SAMPLING" repetitions="5" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-info_central-10000_100-100_rep.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <steppedValueSet variable="%awareness-cte" first="0" step="0.02" last="1"/>
    <steppedValueSet variable="decay-aw" first="0" step="0.05" last="1"/>
    <enumeratedValueSet variable="inform-infected">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="delay_messages-10000_100-100_rep-MORE-SAMPLING" repetitions="5" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-delay_messages-10000_100-100_rep-MORE-SAMPLING.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <metric>count turtles with [ exposed? ]</metric>
    <metric>count turtles with [ infected? ]</metric>
    <metric>count turtles with [ immunity? ]</metric>
    <metric>count turtles with [ dead? ]</metric>
    <metric>count turtles with [ buried? ]</metric>
    <steppedValueSet variable="init_info_time" first="0" step="2" last="90"/>
    <steppedValueSet variable="decay-aw" first="0" step="0.05" last="1"/>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="plot1_fake_news_aw_unaw_Sf" repetitions="30" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-plot1_fake_news_aw_unaw_Sf.csv")</final>
    <timeLimit steps="800"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <steppedValueSet variable="decay-aw" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="decay-unaw" first="0" step="0.1" last="1"/>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-aw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="plot1_fake_news_aw_unaw_Sf_test2" repetitions="1" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-plot1_fake_news_aw_unaw_Sf_test2.csv")</final>
    <timeLimit steps="800"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <steppedValueSet variable="decay-aw" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="decay-unaw" first="0" step="0.1" last="1"/>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="0.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-not_fake" repetitions="30" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <steppedValueSet variable="decay-aw" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="alpha-aw" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="%awareness-cte" first="0" step="0.1" last="1"/>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-not_fake-only_over" repetitions="30" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake-only_over.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <steppedValueSet variable="decay-aw" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="alpha-aw" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="%awareness-cte" first="0" step="0.1" last="1"/>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-dec_a-dec_u-perc_unaw-only_last_state" repetitions="30" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-only_last_state.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <enumeratedValueSet variable="alpha-aw">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="decay-aw" first="0" step="0.1" last="1"/>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="decay-unaw" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="%unawareness-cte" first="0" step="0.1" last="1"/>
  </experiment>
  <experiment name="fake_news-dec_a-dec_u-perc_aw-only_last_state" repetitions="30" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-dec_a-dec_u-perc_aw-only_last_state.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <enumeratedValueSet variable="alpha-aw">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="decay-aw" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="%awareness-cte" first="0" step="0.1" last="1"/>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="decay-unaw" first="0" step="0.1" last="1"/>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-not_fake_3points-1point" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <enumeratedValueSet variable="decay-aw">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-aw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-not_fake_3points-2point" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <enumeratedValueSet variable="decay-aw">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-aw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-not_fake_3points-3point" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <enumeratedValueSet variable="decay-aw">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-aw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-not_fake_3points-1point-aw0.7" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <enumeratedValueSet variable="decay-aw">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-aw">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-not_fake_3points-2point-aw0.7" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <enumeratedValueSet variable="decay-aw">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-aw">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-not_fake_3points-3point-aw0.7" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <enumeratedValueSet variable="decay-aw">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-aw">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="umap" repetitions="3" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <steppedValueSet variable="decay-aw" first="0" step="0.2" last="1"/>
    <steppedValueSet variable="alpha-aw" first="0" step="0.2" last="1"/>
    <steppedValueSet variable="%awareness-cte" first="0" step="0.2" last="1"/>
    <steppedValueSet variable="alpha-unaw" first="0" step="0.2" last="1"/>
    <steppedValueSet variable="decay-unaw" first="0" step="0.2" last="1"/>
    <steppedValueSet variable="%unawareness-cte" first="0" step="0.2" last="1"/>
  </experiment>
  <experiment name="fake_news-3points-1point-unaw0.7" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <enumeratedValueSet variable="decay-aw">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-aw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="0.7"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-3points-2point-unaw0.7" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <enumeratedValueSet variable="decay-aw">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-aw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="0.7"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-3points-3point-unaw0.7" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <enumeratedValueSet variable="decay-aw">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-aw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="0.7"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-3points-1point-unaw1.0" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <enumeratedValueSet variable="decay-aw">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-aw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-3points-2point-unaw1.0" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <enumeratedValueSet variable="decay-aw">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-aw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-3points-3point-unaw1.0" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <enumeratedValueSet variable="decay-aw">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-aw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-3points-1point-aw0.5" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <enumeratedValueSet variable="decay-aw">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-aw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-3points-2point-aw0.5" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <enumeratedValueSet variable="decay-aw">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-aw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-3points-3point-aw0.5" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <enumeratedValueSet variable="decay-aw">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-aw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-3points-1point-unaw0.1" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <enumeratedValueSet variable="decay-aw">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-aw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-3points-2point-unaw0.1" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <enumeratedValueSet variable="decay-aw">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-aw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="fake_news-3points-3point-unaw0.1" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <enumeratedValueSet variable="decay-aw">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-aw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%awareness-cte">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha-unaw">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="decay-unaw">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%unawareness-cte">
      <value value="0.1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="umap_more_sampling" repetitions="3" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <final>export-all-plots (word "parameters-fake_news-no_fake.csv")</final>
    <timeLimit steps="1000"/>
    <metric>count turtles with [ susceptible? ]</metric>
    <steppedValueSet variable="decay-aw" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="alpha-aw" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="%awareness-cte" first="0" step="0.2" last="1"/>
    <steppedValueSet variable="alpha-unaw" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="decay-unaw" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="%unawareness-cte" first="0" step="0.2" last="1"/>
  </experiment>
</experiments>
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
