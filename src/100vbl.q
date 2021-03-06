; ################################################################
; VBL-Interruptroutine, �bernimmt das Cursorblinken
; und die Style-Option "Blink"
; ################################################################
          dc.l    'XBRA',XB_ID,0
NEW_VBL:  tst     $43e.s       ; Diskettenoperation ?
          BNE     \soFORT
          TST     IN_ARBEIT    ; REENTRANCE ?
          BNE     \soFORT
          movem.l d0-a6,-(sp)
          lea     esc_vars(pc),a6
          subq    #1,(IN_ARBEIT-esc_vars)(a6)
          tst.b   cur_br(a6)      ; Blinkrate 0, dann nicht blinken !
          BEQ     \jump
          tst.b   cur_bc(a6)      ; Counter auf null gelaufen
          BNE     \dec_COUNTER     ; NEIN, DANN NOCH WARTEN

          tst.b   (cursor_s_h_flg-esc_vars)(a6)
          beq.s   \blink
          BSR     CCCU            ; Cursor-Blink
          not.b   (cursor_v_l_flg-esc_vars)(a6)

\blink:      lea     (blk_feld+25*80*4)(pc),a0  ; Hier die 'BLINK' Bearbeitung
             move    #25*80-1,d5
\bighook     subq.l  #4,a0
             BTST    #0,(A0)      ; 1.Byte: Bit 0: Flag
             beq.s   \nxtbbl
             move d5,-(sp)
             move.l $44e,a1
             move   d5,d1
             ext.l  d1
             divu   #80,d1
             move   d1,d0        ; Y-Pos
             mulu   #16*80,d0
             add.l  d0,a1
             swap   d1           ; X-Pos
             move   d1,d0
             add.l  d0,a1

             moveq.l #0,d1
             move.b  1(a0),d1     ; Fontnr
             lsl     #2,d1        ; *4
             lea     FONTTABLE(pc),a2
             move.l  (a2,d1.w),fontadr(a6)

             move.b 2(a0),d1     ; Style
             move.b 3(a0),d7     ; Zeichen
             and.l  #$ff,d7
             tst.b  (blink_flg-esc_vars)(a6)
             beq.s  \stelle
             moveq  #32,d7
\stelle      move.l a0,-(sp)
             BSR    EINSP
             move.l (sp)+,a0
             move   (sp)+,d5
\nxtbbl      DBRA    D5,\bigHOOK

             move    font_nr(a6),d1  ; alte Fontadresse installieren
             lsl     #2,d1
             lea     FONTTABLE(pc),a2
             move.l  (a2,d1.w),fontadr(a6)
             not.b   (blink_flg-esc_vars)(a6)
             move.b  cur_br(a6),cur_bc(a6)   ; Blinkcounter laden
             bra.s   \jump
\dec_counter subq.b  #1,cur_bc(a6)
\jump        movem.l (sp)+,d0-a6
             addq    #1,in_arbeit
\sofort      DC.W    $4EF9         ; JMP
OLD_VBL:     dc.l    "4'91"
        END

 