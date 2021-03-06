; ## DRUCKEN.Q      Modul fuer VT100emu     Letzte Bearbeitung:
;                   (c) Markus Hoffmann     9.2.1995



print_control_on: tst (fragezeichenf-esc_vars)(a6)
              beq.s \ret
              st autoprintf(a6)
\ret          rts

print_control_off: tst (fragezeichenf-esc_vars)(a6)
              beq.s \ret
              sf autoprintf(a6)
\ret          rts

PRINT_M:  move  varwert1(pc),d6
          tst   d6
          beq.s P_P     ;  Print_page/region
          cmp   #1,d6
          beq.s Print_line
          cmp   #4,d6
          beq.s print_control_off
          cmp   #5,d6
          beq.s print_control_on
          rts

 ; je nach Statusbit: Printpage/Printregion
P_P:      move.l status(a6),d0
          btst  #19,d0
          Bne.s PRINT_PAGE
; ############################################################
; ## Funktion gibt den Bildschirminhalt auf den Drucker aus.##
; ## Parameter: keine                                       ##
; ## R�ckgabe: d0: 0=alles OK, -1=Drucker nicht bereit      ##
; ## Ver�nderte Register: d0,d1,d5                          ##
; ## nur Supervisormodus !                                  ##
; ############################################################
PRINT_REGION:  move    reg_top(a6),d1
               move    reg_bot(a6),d5
               sub     d1,d5
               bra.s   print_next_zeile   ; VDI kennt nur Printpage !
PRINT_PAGE:    moveq.l #0,d1
               move    max_cury(a6),d5
print_next_zeile: move d1,d0
               movem.l d1/d5,-(sp)
               bsr.s   eingang         ; ----> Zur Print_line Routine
               movem.l (sp)+,d1/d5
               addq    #1,d1
               dbra    d5,print_next_zeile
               move.l  status(a6),d0
               btst    #18,d0          ; Print formfeed ?
               beq.s   \ret
               moveq   #12,d0          ; Formfeed
               bra.s   lprint
\ret           rts
; ############################################################
; ## Funktion gibt die Zeile, in der der Cursor steht,      ##
; ## auf den Drucker aus. Parameter: keine                  ##
; ## R�ckgabe: d0: 0=alles OK, -1=Drucker nicht bereit      ##
; ## Ver�nderte Register: d0                                ##
; ## nur Supervisormodus !                                  ##
; ############################################################
PRINT_LINE:    Move   cursor_y(a6),d0
eingang:                                  ; eingang: hier springt die Print-
               lea    blk_feld(pc),a0     ; page routine ein. Parameter d0=zeile
               mulu   #80*4,d0
               lea    (a0,d0.w),a0
               move   max_curx(a6),d5
next_print_char:movem.l d5/a0,-(sp)
               moveq.l #0,d0
               move.b   3(a0),d0
               tst.b    d0
               bne.s    \tues
               moveq    #$20,d0
\tues          BSR.s    LPRINT
               movem.l  (sp)+,d5/a0
               addq.l   #4,a0
               dbra     d5,next_print_char
               moveq    #13,d0
               BSR.s    LPRINT
               moveq    #10,d0
             ;  BRA      LPRINT
; LPRINT:
          include  "\assemble\library\lprint_u.q"

; ############################################################
; ## Funktion Autoprint  d7=ASCII-Code                      ##
; ## d7 und a6 d�rfen nicht ver�ndert werden !              ##
; ############################################################

AUTOPRINT:  cmp   #12,d7        ; Formfeed
            bne.s \others
            move.l status(a6),d0
            btst   #18,d0       ; Formfeed off ?
            beq.s  \ret
\others     movem.l d7/a6,-(sp)
            move  d7,d0         ; Zeichen
            BSR   LPRINT
            movem.l (sp)+,d7/a6
\ret        rts


 end
 