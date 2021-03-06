
; ################################################
; ## Routine zur unabh�ngigen Druckerausgabe    ##
; ##                                            ##
; ## Aufruf: Move   #ascii,d0                   ##
; ##         bsr    lprint                      ##
; ## R�ckgabe: d0=0: alles OK                   ##
; ##           d0=-1: TIMEOUT                   ##
; ## Aufruf nur im Supervisormodus              ##
; ## Ben�tigte Routinen:  OUT_STAT              ##
; ## Ver�ndert Register d0,d2,d3,d4,d7,a0       ##
; ################################################
LPRINT: move  d0,d7
        lea   timeout_flg,a1
        tst   (a1)            ; Schon Timeout gemeldet ?
        bne   testp           ; nein, drucke
        bsr   out_stat        ; Ja, Status ?
        move  d0,(a1)
        tst   d0              ; Drucker wieder bereit ?
        beq.s timeout         ; nein, noch nicht
testp:  move.l $4ba,d2        ; TIMER -> d2
testo:  bsr   out_stat
        move.l $4ba,d3
        sub.l  d2,d3          ; TIMER-t% > time ?
        move   time,d4
        cmp    d4,d3
        bgt    timeout        ; ja, -> timeout
        tst   d0
        beq   testo
      ; Zeichen auf Parallelport ausgeben
        move  sr,d3
        or    #$700,sr       ; Interrupts sperren
        lea   $ff8800,a0
        move.b #7,(a0)
        move.b (a0),d0       ; Register 7 lesen
        bset   #7,d0         ; Port B als Ausgabe
        move.b d0,2(a0)
        move.b #15,(a0)      ; Reg 15
        move.b d7,2(a0)      ; Daten
        move.b #14,(a0)      ; Reg 14 = Port A
        move.b (a0),d0
        bclr   #5,d0         ; STROBE low
        move.b d0,2(a0)
        move   #100,d2       ; Warteschleife
hhh:    nop
        dbra   d2,hhh
        bset   #5,d0         ; STROBE high
        move.b d0,2(a0)
        move  d3,sr
        moveq.l #0,d0
        rts
TIMEOUT: MOVE   #0,(A1)      ; TIMEOUT_FLG
         moveq  #-1,d0
         rts
TIME:   dc.w 400    ; =2 sekunden
TIMEOUT_flg: dc.w -1
; ################################################
; ## Routine zur unabh�ngigen Abfrage des       ##
; ## Druckerstatus'.                            ##
; ## Aufruf:   bsr    OUT_stat                  ##
; ## R�ckgabe: d0: -1=Drucker bereit            ##
; ##                0=Drucker nicht bereit      ##
; ## Aufruf nur im Supervisormodus              ##
; ##                                            ##
; ## Ver�nderte Register: D0,a0                 ##
; ################################################
OUT_stat:  lea $FFFFFA01,a0
           moveq #-1,d0
           btst  #0,0(a0)
           beq.s  ws2
           moveq  #0,d0
ws2:       rts
   end
 