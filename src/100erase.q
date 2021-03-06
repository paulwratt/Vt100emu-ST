 ; #####################
 ; ## L�schfunktionen ##  Letzte Bearbeitung: 29.03.1994
 ; #####################


CLEAR_SCREEN: move.l $44e,a0
             lea     32000(a0),a0
             lea     load_nul(pc),a1
             movem.l (a1)+,d0-d4/d6-d7/a2-a4      ; Register l�schen
             subq    #1,(in_arbeit-esc_vars)(a6)
             move    #(32000/80)-1,d5
\HOOK:       MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)
             dbra    d5,\HOOK
feld_CLEAR:  lea     (blk_feld+80*4*25)(pc),a0
             lea     load_nul(pc),a1
             movem.l (a1)+,d0-d4/d6-d7/a2-a4      ; Register l�schen
             moveq   #25-1,d5
\hook        MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)      ; 80 Eintr�ge
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)      ; = 1 Zeile
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)
             dbra    d5,\hook
             addq    #1,(in_arbeit-esc_vars)(a6)
             rts

ERASE_LINE:  move.l  $44e,a0
             move    cursor_y(A6),d2
             mulu    #80*16,d2
             lea     (a0,d2.w),a0
             lea     16*80(a0),a0
             lea     load_nul(pc),a1
             movem.l (a1)+,d0-d4/d6-d7/a2-a4      ; Register l�schen
             subq    #1,(in_arbeit-esc_vars)(a6)
             moveq   #3,d5
\hook        MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)      ; 80 Bytes
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)      ; 80 Bytes
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)      ; 80 Bytes
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)      ; 80 Bytes
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)
             dbra   d5,\hook

             lea    blk_feld(pc),a0
             move   cursor_y(A6),d2
             mulu   #80*4,d2
             lea    (a0,d2.w),a0
             lea    80*4(a0),a0
             lea    load_nul(pc),a1
             movem.l (a1)+,d0-d4/d6-d7/a2-a4      ; Register l�schen
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)   ; 8*40 Bytes l�schen= 1 Zeile
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)
             MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)
             addq    #1,(in_arbeit-esc_vars)(a6)
             rts

erasesbc     bsr    e_sc          ; Screen bis cursor
erasezbc     tst    cursor_x(A6)  ; Zeile bis Cursor l�schen
             beq.s  \ret
             move.l $44e,a0
             lea    blk_feld(pc),a1
             move   cursor_y(A6),d1         ; d1,d4,d5
             move   d1,d2
             mulu   #80*4,d2
             MULU   #80*16,D1
             add.l  d1,a0
             add.l  d2,a1
             move   #-1,(in_arbeit-esc_vars)(a6)
             moveq  #15,d5
\hook1       move   cursor_x(A6),d4
             subq   #1,d4
\hook2       clr.B  (A0,D4.W)
             dbra   d4,\hook2
             lea    80(a0),a0
             dbra   d5,\hook1
             move   cursor_x(A6),d4
             subq   #1,d4
\HOOK3       clr.l  (A1)+
             dbra   d4,\HOOK3
             clr   (in_arbeit-esc_vars)(a6)
\ret         rts

erasesac     bsr     e_sce        ; Screen ab cursor
erasezac     move.l  $44e,a0      ; Zeile ab Cursor l�schen
             lea     blk_feld(pc),a1
             move    cursor_y(A6),d1
             move    d1,d2
             MULU    #80*16,D1
             mulu    #80*4,d2
             lea     (a0,d1.w),a0
             lea     (a1,d2.w),a1
             MOVE    CURSOR_X(A6),D1
             lea     (a0,d1.w),a0
             lsl     #2,d1
             lea     (a1,d1.w),a1
             move    #-1,(in_arbeit-esc_vars)(a6)
             moveq   #15,d5
\hook1       move   max_curx(A6),d4
             sub    cursor_x(a6),d4
\hook2       clr.B  (A0,D4.W)
             dbra   d4,\hook2
             lea    80(a0),a0
             dbra   d5,\hook1
             move   max_curx(A6),d4   ; Im Feld
             sub    cursor_x(a6),d4
\hook3       clr.l  (A1)+
             dbra   d4,\hook3
             clr    (in_arbeit-esc_vars)(a6)
             rts
 ; ### Screen bis ausschl. Cursorzeile l�schen ###
E_sc:        tst     cursor_y(a6)
             beq.s   \ret
             move.l  $44e,a0
             lea     blk_feld(pc),a5
             move    cursor_y(a6),d5
             move    d5,d1
             MULU    #80*16,D5
             mulu    #80*4,d1
             lea     (a5,d1.w),a5
             lea     (a0,d5.w),a0
             divu    #40,d5
             move    d1,-(sp)
             lea     load_nul(pc),a1
             movem.l (a1)+,d0-d4/d6-d7/a2-a4      ; Register l�schen
             move    #-1,(in_arbeit-esc_vars)(a6)
             subq    #1,d5     ; d1=anzahl der zu l�schenden halbzeilen
\hook2       MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)
             dbra    d5,\hook2
             move    (sp)+,d5                  ; noch im Felde
             divu    #40,d5
             subq    #1,d5
\hook        MOVEm.L d0-d4/d6-d7/a2-a4,-(A5)
             dbra    d5,\hook
             clr     (in_arbeit-esc_vars)(a6)
\ret         rts

 ; ### Screen ab ausschl. Cursorzeile l�schen ###
E_sce:       move   cursor_y(a6),d5
             cmp    max_cury(A6),d5
             bge.s  \ret
             move.l $44e,a0
             lea    (blk_feld+80*25*4)(pc),a5
             lea    32000(a0),a0
             move   max_cury(A6),d5
             sub    cursor_y(a6),d5
             move   d5,d1
             MULU   #80*16/40,D5
             mulu   #80*4/40,d1
             move   d1,-(sp)
             lea    load_nul(pc),a1
             movem.l (a1)+,d0-d4/d6-d7/a2-a4      ; Register l�schen
             move   #-1,(in_arbeit-esc_vars)(a6)
             subq   #1,d5
\HOOK        MOVEm.L d0-d4/d6-d7/a2-a4,-(A0)
             dbra   d5,\HOOK
             move   (sp)+,d5
             subq   #1,d5
\HOOK2       MOVEm.L d0-d4/d6-d7/a2-a4,-(A5)
             dbra   d5,\hook2
             clr    (in_arbeit-esc_vars)(a6)
\ret         rts
    data
Load_nul:    ds.l   10,0
     text
     end

 