 ; ######################
 ; ## Scrollfunktionen ## letzte Bearbeitung: 29.03.1994
 ; ######################


SCROLL_UP:   move.l $44e,a0                     ; Screenadr
             lea    16*80(a0),a1                ; + 1 Zeile
             subq   #1,(in_arbeit-esc_vars)(a6)
             move   #(32000-16*80)/160-1,d5
\HOOK2       movem.l (a1)+,d0-d4/d6-d7/a2-a4    ; 40 Bytes
             movem.l d0-d4/d6-d7/a2-a4,(a0)
             movem.l (a1)+,d0-d4/d6-d7/a2-a4    ; 40 Bytes
             movem.l d0-d4/d6-d7/a2-a4,40(a0)
             movem.l (a1)+,d0-d4/d6-d7/a2-a4    ; 40 Bytes
             movem.l d0-d4/d6-d7/a2-a4,80(a0)
             movem.l (a1)+,d0-d4/d6-d7/a2-a4    ; 40 Bytes
             movem.l d0-d4/d6-d7/a2-a4,120(a0)
             lea     160(a0),a0
             dbra    d5,\HOOK2

             lea     blk_feld(pc),a0            ; Feld-Scroll-up
             lea     4*80(a0),a1
             moveq   #24-1,d5
\HOOK        MOVEM.L (A1)+,D0-D4/D6-D7/A2-A4   ; 1 ZEILE
             movem.l d0-d4/d6-d7/a2-a4,(a0)
             movem.l (a1)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,40(a0)
             movem.l (a1)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,80(a0)
             movem.l (a1)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,120(a0)
             movem.l (a1)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,160(a0)
             movem.l (a1)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,200(a0)
             movem.l (a1)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,240(a0)
             movem.l (a1)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,280(a0)
             lea     320(a0),a0
             dbra    d5,\hook
             addq    #1,(in_arbeit-esc_vars)(a6)
             BRA     ERASE_LINE

SCROLL_DOWN: move.l $44e,a0
             lea    32000(a0),a1
             lea    -(16*80)(a1),a0
             move   #-1,in_arbeit
             move   #((32000-(16*80))/80)-1,d5
\hook2       lea    -80(a0),a0
             movem.l 40(a0),d0-d4/d6-d7/a2-a4    ; 40 Bytes
             movem.l d0-d4/d6-d7/a2-a4,-(a1)
             movem.l (a0),d0-d4/d6-d7/a2-a4    ; 40 Bytes
             movem.l d0-d4/d6-d7/a2-a4,-(a1)
             dbra    d5,\hook2

             lea     (blk_feld+24*80*4)(pc),a1    ; FELD-SCROLL-DOWN
             lea      -4*80(a1),a0
             moveq   #24-1,d5
\hook        movem.l (a0)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,(a1)
             movem.l (a0)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,40(a1)
             movem.l (a0)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,80(a1)
             movem.l (a0)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,120(a1)
             movem.l (a0)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,160(a1)
             movem.l (a0)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,200(a1)
             movem.l (a0)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,240(a1)
             movem.l (a0)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,280(a1)
             lea     -4*80(a1),a1
             lea     -4*80(a1),a0
             dbra    d5,\hook
             clr     (in_arbeit-esc_vars)(a6)
             BRA     ERASE_LINE

  ; Hier kommen die Scrollfunktionen f�r die Scroll-Region
  ; (sind etwas langsamer)

MULTISCROLLUP:      ; alles von Cursorzeile bis Top of region scrollen
             move.l $44e,a0                     ; Screenadr
             moveq  #0,d0
             move   reg_top(a6),d0
             mulu   #16*80,d0
             add.l  d0,a0                       ; + REG_TOP
             lea    16*80(a0),a1                ; + 1 Zeile
             moveq  #0,d5                       ; Anzahl Zeilen berechnen
             move   reg_bot(a6),d5
             sub    reg_top(a6),d5
             beq    erase_line                  ; wenn Bot=top nur Zeile l�schen
             mulu   #(16*80/160),d5             ; (*8)
             subq   #1,(in_arbeit-esc_vars)(a6)
             subq   #1,d5
\HOOK2       movem.l (a1)+,d0-d4/d6-d7/a2-a4    ; 40 Bytes
             movem.l d0-d4/d6-d7/a2-a4,(a0)
             movem.l (a1)+,d0-d4/d6-d7/a2-a4    ; 40 Bytes
             movem.l d0-d4/d6-d7/a2-a4,40(a0)
             movem.l (a1)+,d0-d4/d6-d7/a2-a4    ; 40 Bytes
             movem.l d0-d4/d6-d7/a2-a4,80(a0)
             movem.l (a1)+,d0-d4/d6-d7/a2-a4    ; 40 Bytes
             movem.l d0-d4/d6-d7/a2-a4,120(a0)
             lea     160(a0),a0
             dbra    d5,\HOOK2

             lea     blk_feld(pc),a0            ; Feld-Scroll-up
             moveq  #0,d0
             move   reg_top(a6),d0
             mulu   #4*80,d0
             add.l  d0,a0                       ; + REG_TOP
             lea     4*80(a0),a1                ; +1
             moveq  #0,d5                       ; Anzahl Zeilen berechnen
             move   reg_bot(a6),d5
             sub    reg_top(a6),d5
             subq   #1,d5
\HOOK        MOVEM.L (A1)+,D0-D4/D6-D7/A2-A4   ; 1 ZEILE
             movem.l d0-d4/d6-d7/a2-a4,(a0)
             movem.l (a1)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,40(a0)
             movem.l (a1)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,80(a0)
             movem.l (a1)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,120(a0)
             movem.l (a1)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,160(a0)
             movem.l (a1)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,200(a0)
             movem.l (a1)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,240(a0)
             movem.l (a1)+,d0-d4/d6-d7/a2-a4
             movem.l d0-d4/d6-d7/a2-a4,280(a0)
             lea     320(a0),a0
             dbra    d5,\hook

\ende        clr     (in_arbeit-esc_vars)(a6)
             bra     ERASE_LINE    ; Zeile mit Cursor l�schen
 end
 