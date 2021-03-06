; ################################
; ## Zeichenausgaberoutine      ##
; ## d7 = Zeichen               ##
; ################################
ZEICHENAUSGABE:
        move.l $44e,a1
        move   cursor_y(a6),d1
        MULU   #80*16, D1
        lea    (a1,d1.w),a1
        move   cursor_x(a6),d1
        lea    (a1,d1.w),a1
        move   style(a6),d1
        lea    blk_feld(pc),a0
        move   cursor_y(a6),d0
        mulu   #80*4,d0
        lea    (a0,d0.w),a0
        move   cursor_x(a6),d0
        lsl    #2,d0
        lea    (a0,d0.w),a0     ; a0 = Blk-Pos
        subq   #1,(in_arbeit-esc_vars)(a6)    ; Interrupt sperren

        btst   #5,d1         ; Blink !
        beq.s    meier
 ; Hier wird das Zeichen in die Zeichentabelle eingetragen ...
        and  #%1111111111011111,d1  ; Blink Ausmaskieren
        move.b #3,(a0)+         ; Blink+ist schon
        bra.s  summo
meier:  clr.b  (a0)+
summo:  move.b (font_nr+1)(a6),(a0)+  ; Fontnr.
        move.b d1,(a0)+         ; Style
        move.b d7,(a0)+         ; ASCII
        bsr.s  einsp             ; Das Zeichen noch darstellen
        addq   #1,(in_arbeit-esc_vars)(a6)   ; Interrupt wieder freigeben
        rts
; ####################################
; ## Zeichen darstellen (d7)        ##
; ## Font: fontadr(a6)              ##
; ## Style: d1                      ##
; ## Position: a1                   ##
; ####################################

einsp:     move.l fontadr(A6),a0
           lea    (a0,d7.w),a0

           tst    d1         ; Keine Sonderfunktion ?
           beq.s  quick_aus

           moveq   #15,d5
next_line: move.b  (a0),d0
           btst    #2,d1      ; Fett
           beq.s   \efat
           move.b  d0,d3
           ror.b   #1,d3
           or      d3,d0
\efat      btst    #4,d1      ; Underline
           beq.s   \u2
           cmp     #1,d5
           bne.s   \u1
           moveq   #-1,d0
\u1        tst     d5
           bne.s   \u2
           moveq   #-1,d0
\u2        btst    #7,d1      ; Inverse
           beq.s   \einv
           not     d0
\einv      btst    #1,d1      ; Highlight
           beq.s   \ehigh
           move    #%10101010,d3
           rol.b   d5,d3
           and     d3,d0
           bra.s   \egrau     ; Kombination grauer Hintergrund+Highlight abfangen
\ehigh     btst    #6,d1      ; Grauer Hintergr, sw Schrift
           beq.s   \egrau
           move    #%10101010,d3
           rol.b   d5,d3
           or      d3,d0
\egrau     move.b  d0,(a1)
           lea     80(a1),a1
           lea     256(a0),a0
           dbra    d5,next_line
           rts

QUICK_AUS: IBYTES "..\vt100emu\quickaus.b"

   end
 