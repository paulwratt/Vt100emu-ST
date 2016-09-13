; Klinkt sich in den Tastatur-Interrupt ein und protokolliert
; Bytes von IKBD-ACIA in Ringpuffer mit

;new_acia:
           ;  movem.l d0-a6,-(sp)
           ;  lea    -$400,a1
           ;  move.b   0(a1),d2
           ;  btst    #7,d2
           ;  beq.s   old
           ;  btst    #0,d2
           ;  beq.s   old
         ;    move.b  2(a1),d0        ; Funktioniert nicht !
           ;  lea     ikbd_buf(pc),a0
           ;  moveq   #0,d5
           ;  move.b  ikbd_buf_tail(pc),d5
           ;  MOVE.B  D0,0(a0,d5)
           ;  addq    #1,d5
           ;  move.b  d5,(ikbd_buf_tail-ikbd_buf)(a0)
;old:     movem.l (sp)+,d0-a6
;         dc.w $4ef9
;old_acia: dc.l 0

INPS2:       move.l   keybufp(pc),a0   ; Erfragt Tastaturstatus
             moveq    #-1,d0
             lea      6(a0),a2
             lea      8(a0),a3
             cmpm     (a3)+,(a2)+
             bne.s    \ret
             moveq    #0,d0
\ret         rts
INP2:        bsr.s    INPS2            ; Liest Zeichen von Tastatur
             tst      d0
             beq.s    INP2
GETKEY:      bsr.s    inps2
             tst      d0
             beq.s    \eret
             move     sr,-(sp)
             or       #$700,sr
             move     6(a0),d1
             cmp      8(a0),d1
             beq.s    \sret
             addq     #4,d1
             cmp      4(a0),d1
             bcs.s    \ub
             moveq    #0,d1
\ub          move.l   (a0),a1
             move.l   0(a1,d1),d0
             move     d1,6(a0)
             move     (sp)+,sr
             rts
\sret        move     (sp)+,sr
\eret        moveq    #-1,d0
             rts

; Verwaltung der Ringpuffer INP(4) und inp(5)

INPS4:   moveq    #0,d0
         move.b   ikbd_buf_tail(pc),d1
         move.b   ikbd_buf_head(pc),d2
         cmp.b    d1,d2
         beq.s    \ret
         moveq    #-1,d0
\ret     rts
INP4:    lea      ikbd_buf(pc),a0
         moveq    #0,d0
         moveq    #0,d1
         move.b   ikbd_buf_head(pc),d1
         move.b   0(a0,d1),d0
         addq     #1,d1
         move.b   d1,(ikbd_buf_head-ikbd_buf)(a0)
         rts

INPS5:   lea      esc_vars(pc),a6
         btst     #2,status(a6)  ; Tastatur frei ?
         BNE      \UB
         bsr.s    getkey       ; aus Tastaturpuffer
         tst.l    d0
         BMI      \UB          ; KEIN ZEICHEN GEFUNDEN
         swap     d0
         cmp.b    #$3b,d0      ; <F1
         BLT      \GETASCII    ; ASCII-CODE
         cmp.b    #$44,d0      ; >F10
         BGT      \NOtF1F10
         ; F1 bis F10
         move     d0,d1
         and.l    #$FF,d1
         sub      #$3b,d1
         lsl      #2,d1   ; *4
         lea      \f1f10tab(pc),a1
         lea      (a1,d1),a0
         BSR      SINBUF
         BRA      \UB
       data
\F1f10tab:   dc.b 27,'OP',0
             dc.b 27,'OQ',0
             dc.b 27,'OR',0
             dc.b 27,'OS',0
             ds.l 6
\CUP:        dc.b 27,'[A',0
             dc.b 27,'OA',0
\cdown:      dc.b 27,'[B',0
             dc.b 27,'OB',0
\cright:     dc.b 27,'[C',0
             dc.b 27,'OC',0
\cleft:      dc.b 27,'[D',0
             dc.b 27,'OD',0
\minus       dc.b '-',0,0,0
             dc.b 27,'Om',0
       text
\notf1f10    moveq    #0,d4
             btst     #1,setup(a6)    ; Cursortastenmodus
             beq.s    \norm
             moveq    #4,d4
\norm        cmp.b    #$48,d0     ; UP
             bne.s    \NOTUP
             lea      \cup(pc),a0
             add.l    d4,a0
             BSR      SINBUF
             BRA      \UB
\notup       cmp.b    #$50,d0     ; DOWN
             bne.s    \NOTdown
             lea      \cdown(pc),a0
             add.l    d4,a0
             BSR      SINBUF
             bra.s    \ub
\notdown     cmp.b    #$4d,d0     ; right
             bne.s    \NOTright
             lea      \cright(pc),a0
             add.l    d4,a0
             BSR      SINBUF
             bra.s    \ub
\notright    cmp.b    #$4b,d0     ; left
             bne.s    \NOTleft
             lea      \cleft(pc),a0
             add.l    d4,a0
             BSR      SINBUF
             bra.s    \ub
\notleft     cmp.b    #$4e,d0     ; minus
             bne.s    \NOTminus
             lea      \minus(pc),a0
             btst     #0,flags(a6)
             beq.s    \go
             addq.l   #4,a0
\go          bsr.s    sinbuf
             bra.s    \ub

\notminus    cmp.b    #$54,d0
             blt.s    \getascii   ; <F11
             cmp.b    #$63,d0     ; < Numerik-Block
             blt.s    \getascii
             cmp.b    #$72,d0
             bgt.s    \getascii
             btst     #0,flags(a6)  ; Keypad in Normalmode ?
             beq.s    \getascii
              ; Keypad
             move     d0,d1
             and.l    #$FF,d1
             sub      #$63,d1
             lsl      #2,d1   ; *4
             lea      \keytab(pc),a1
             lea      (a1,d1),a0
             bsr.s    sinbuf
             bra.s    \ub
        data
\keytab:     ds.l     3
             dc.b     27,'Ol',0
             dc.b     27,'Ow',0
             dc.b     27,'Ox',0
             dc.b     27,'Oy',0
             dc.b     27,'Ot',0
             dc.b     27,'Ou',0
             dc.b     27,'Ov',0
             dc.b     27,'Oq',0
             dc.b     27,'Or',0
             dc.b     27,'Os',0
             dc.b     27,'Op',0
             dc.b     27,'OM',0

        text
\getascii    swap     d0
             bsr.s    inbuf
\ub      move.b   mes_buf_tail(pc),d1  ; Buffer auslesen
         move.b   mes_buf_head(pc),d2
         moveq    #0,d0
         cmp.b    d1,d2
         beq.s    \ret
         moveq    #-1,d0
\ret     rts

INP5:    lea      mes_buf(pc),a0
         moveq    #0,d0
         moveq    #0,d1
         move.b   mes_buf_head(pc),d1
         move.b   0(a0,d1),d0
         addq     #1,d1
         move.b   d1,(mes_buf_head-mes_buf)(a0)
         rts
INBUF:   lea     mes_buf(pc),a1
         moveq   #0,d1
         move.b  mes_buf_tail(pc),d1
         MOVE.B  D0,0(a1,d1)
         addq    #1,d1
         move.b  d1,(mes_buf_tail-mes_buf)(a1)
         rts
SINBUF:  move.b  (a0)+,d0
         beq.s   \ret
         bsr.s   INBUF
         bra.s   SINBUF
\ret     rts
CLRBUF:  lea     mes_buf(pc),a0
         clr.b   (mes_buf_tail-mes_buf)(a0)
         clr.b   (mes_buf_head-mes_buf)(a0)
         rts

 bss
ikbd_buf_tail:   ds.b 1
ikbd_buf_head:   ds.b 1
ikbd_buf:        ds.b 256
mes_buf_tail:   ds.b 1
mes_buf_head:   ds.b 1
mes_buf:        ds.b 256


 text
 end
 