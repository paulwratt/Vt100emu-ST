; VT100 VDI-ESC-Manager

            dc.l  'XBRA',XB_ID,0
NEW_GEM:    cmp   #$73,d0   ; VDI ?
            BNE   VDI_OLD   ; nein, dann weiter

            movem.l d0-a6,-(sp)

            move.l d1,a1    ; VDIPB
            move.l (a1),control
            move.l 4(a1),intin
            move.l 12(a1),intout
            move.l (a1),a1  ; Control
            move   (a1),d7  ; Opcode
            CMP    #5,d7    ; VDI-ESC-Funktionen
            bne.s  vdi_old2
            lea    esc_vars(pc),a6
new_vdi:    move   10(a1),d0 ; Funktionsnummer
            cmp    #19,d0    ; gr��er 19 ?
            bhi.s  vdi_spec  ; --> Ja
            asl.w  #1,d0
            lea    vdi_tab(pc),a0
            move  (a0,d0.w),(vbas-vdi_tab)(a0)
            bsr    hide_cursor
            dc.w  $6100        ; BSR
vbas:       dc.w  '##'
            bsr    show_cursor
vende       movem.l (sp)+,d0-a6
            rte
      bss
control:    ds.l   1                ; control-
intin:      ds.l   1                ; intin-array.adresse
intout:     ds.l   1                ; intout-
      text
vdi_spec:   cmp    #101,d0          ; ESC-101  Offset setzen
            bne.s  vdi102t
vdi_101:    bsr    hide_cursor      ; hat noch keine Wirkung
            move.l intin(pc),a0
            move   (a0),d0
            mulu   #80,d0
            move   d0,offset(a6)
            bsr    show_cursor
            bra.s  vende
vdi102t     cmp    #102,d0          ; ESC-102
            bne.s  vende
Vdi_102:                            ; ESC-102 nicht installiert
            bra.s  vende

vdi_old2:   movem.l (sp)+,d0-a6
vdi_old:    dc.w    $4ef9           ; JMP
old_gem:    dc.l    'M.H.'

vdi_tab:    dc.w   vret-vbas,iaacc-vbas,exalpha-vbas,inalpha-vbas  ; 0,1,2,3
            dc.w   cursor_up-vbas,cursor_down-vbas,cursor_right-vbas,cursor_left-vbas ; 4,5,6,7
            dc.w   cursor_home-vbas,erasesac-vbas,erasezac-vbas,vdi_esc_11-vbas   ; 8,9,10,11
            dc.w   vdi_esc_12-vbas,vdi_esc_13-vbas,vdi_esc_14-vbas,getcurpos-vbas ; 12,13,14,15
            dc.w   getstatus-vbas,print_page-vbas,vdi_esc_18-vbas,vdi_esc_19-vbas

iaacc:      move.l control(pc),a0   ; inquire adressable alpha character cells
            move   #2,8(a0) ; 2 intout  ; Bildschirmgr��e holen...
            move.l intout(pc),a0
            move   max_curx(a6),d0
            addq   #1,d0
            move   d0,2(a0)
            move   max_cury(a6),d0
            addq   #1,d0
            move   d0,(a0)
vret        rts
inalpha:    bsr.s  alpha
vdi_esc_18: sf  (cursor_o_o_flg-esc_vars)(a6) ; Cursor on
            rts
vdi_esc_19: st     (cursor_o_o_flg-ESC_vars)(a6)
            rts
EXALPHA:    ST     (CURSOR_O_O_FLG-ESC_VARS)(A6) ; CURSOR OFF
alpha       bsr    cursor_home            ; exit alpha-mode
            bra    clear_screen
VDI_ESC_11: move.l intin(pc),a0    ; Print at
            move   (a0),d0
            subq   #1,d0
            move   d0,cursor_y(a6)
            move   2(a0),d0
            subq   #1,d0
            move   d0,cursor_x(a6)
            bra    sst2
VDI_ESC_12: move.l  control(pc),a0  ; Zeichenausgabe
            move    6(a0),d0
            move.l  intin(pc),a0
            bra.s   \L
\HOOK:      move    (a0)+,d7
            movem.l d0/a0,-(sp)
            bsr     conout
            movem.l (sp)+,d0/a0
\l:         dbra    d0,\HOOK
            rts
VDI_ESC_13:  move style(a6),d0     ; INV on
             bset        #7,d0
             move        d0,style(a6)
             rts
VDI_ESC_14:  move style(a6),d0     ; INV OFF
             bclr        #7,d0
             move        d0,style(a6)
             rts
getcurpos    move.l  control(pc),a0
             move    #2,8(a0)
             move.l  intout(pc),a0
             move    cursor_y(a6),d0
             addq    #1,d0
             move    d0,(a0)
             move    cursor_x(a6),d0
             addq    #1,d0
             move    d0,2(a0)
             rts
getstatus    move.l control(pc),a0
             move   #1,8(a0)
             move.l intout(pc),a0
             move   #7,(a0)         ; Hieran erkennt man unsere Emulation
             rts                    ; System liefert eine 1
           end

 