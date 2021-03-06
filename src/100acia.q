; Modul f�r VT100EMU    (c) Markus Hoffmann
; ######################################### Letzte Bearbeitung 15.03.1995

; Klinkt sich in den Tastatur-Interrupt ein und protokolliert
; Bytes von IKBD-ACIA in Ringpuffer mit, der mit INP(4) ausgelesen
; werden kann.
; Funktioniert noch nicht
           ; dc.l 'XBRA',XB_ID,0
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

    ; ###############
    ; ## INP?(2)   ##
    ; ###############
INPS2:       move.l   keybufp(pc),a0   ; Erfragt Tastaturstatus
             moveq    #-1,d0
             lea      6(a0),a2
             lea      8(a0),a3
             cmpm     (a3)+,(a2)+
             bne.s    \ret
             moveq    #0,d0
\ret         rts

    ; ###############
    ; ## INP(2)    ##
    ; ###############
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


; ############################################
; Verwaltung der Ringpuffer INP(4) und inp(5)
; ############################################
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

; ################################################
; ## INP?(5) prepariert gleichzeitig den Puffer ##
; ################################################

INPS5:   lea      esc_vars(pc),a6
         btst     #2,status(a6)  ; Tastatur frei ?
         BNE      \UB
         bsr.s    getkey       ; aus Tastaturpuffer
         tst.l    d0
         BMI      \UB          ; KEIN ZEICHEN GEFUNDEN
         swap     d0
 
 ; Sondertasten

         cmp.b    #$62,d0      ; HELP
         bne.s    \nothelp
         lea      \pa1(pc),a0
         bsr      sinbuf
         bra      \ub
\nothelp cmp.b    #$61,d0      ; UNDO
         bne.s    \notundo
         lea      \pa2(pc),a0
         bsr      sinbuf
         bra      \ub
\notundo cmp.b    #$52,d0      ; Insert
         bne.s    \notinsert
         lea      \insert(pc),a0
         bsr      sinbuf
         bra      \ub
\notinsert cmp.b    #$47,d0      ; Clr Home
         bne.s    \nothome
         lea      \delete(pc),a0
         bsr      sinbuf
         bra      \ub

; Funktionstasten F1-F10


\nothome cmp.b    #$3b,d0      ; <F1
         BLT.s    \notf1f10
         cmp.b    #$44,d0      ; >F10
         BGT.s    \NOtF1F10
      ; Funktionstasten F1 bis F10
         move     d0,d1
         and.l    #$FF,d1
         sub      #$3b,d1
         lsl      #3,d1   ; *8
         lea      \f1f10tab(pc),a1
         lea      (a1,d1),a0
         BSR      SINBUF
         BRA      \UB
\notf1f10 cmp.b    #$54,d0      ; <F11
         BLT.s     \notf11f20
         cmp.b    #$5D,d0      ; >F20
         BGT.s    \NOtF11F20
      ; Funktionstasten F11 bis F20
         move     d0,d1
         and.l    #$FF,d1
         sub      #$54,d1
         lsl      #3,d1   ; *8
         lea      \f11f20tab(pc),a1
         lea      (a1,d1),a0
         BSR      SINBUF
         BRA      \UB

       data
; Jede Taste 8 Bytes
\F1f10tab:   dc.b 27,'OP',0,0,0,0,0 ; F1       $3b
             dc.b 27,'OQ',0,0,0,0,0 ; F2
             dc.b 27,'OR',0,0,0,0,0 ; F3
             dc.b 27,'OS',0,0,0,0,0 ; F4
             dc.b 27,'[15~',0,0,0   ; F5
             dc.b 27,'[17~',0,0,0   ; F6
             dc.b 27,'[18~',0,0,0   ; F7
             dc.b 27,'[19~',0,0,0   ; F8
             dc.b 27,'[20~',0,0,0   ; F9
             dc.b 27,'[21~',0,0,0   ; F10      $44


\F11f20tab:  dc.b 27,'[23~',0,0,0   ; F11      $54
             dc.b 27,'[24~',0,0,0   ; F12
             dc.b 27,'[25~',0,0,0   ; F13
             dc.b 27,'[26~',0,0,0   ; F14
             dc.b 27,'[28~',0,0,0   ; F15
             dc.b 27,'[29~',0,0,0   ; F16
             dc.b 27,'[31~',0,0,0   ; F17
             dc.b 27,'[32~',0,0,0   ; F18
             dc.b 27,'[33~',0,0,0   ; F19
             dc.b 27,'[34~',0,0,0   ; F20      $5D

\CUP:        dc.b 27,'[A',0         ; Curpos-Mode
             dc.b 27,'OA',0         ; Appl. Mode
\cdown:      dc.b 27,'[B',0
             dc.b 27,'OB',0
\cright:     dc.b 27,'[C',0
             dc.b 27,'OC',0
\cleft:      dc.b 27,'[D',0
             dc.b 27,'OD',0


; vt52-Keypad. Minus Taste $4a

\minus       dc.b '-',0,0,0
             dc.b 27,'Om',0

; ANSI-Keypad. Minus Taste $4a

\minus2      dc.b '-',0,0,0
             dc.b 27,'?m',0


       text
\notf11f20    moveq    #0,d4
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
\notleft     cmp.b    #$4a,d0     ; Minus auf Keypad abfangen
             bne.s    \NOTminus
             lea      \minus(pc),a0
             btst     #0,flags(a6)
             beq.s    \go
             addq.l   #4,a0
\go          bsr.s    sinbuf
             bra.s    \ub

\notminus    cmp.b    #$63,d0     ; < Numerik-Block
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

 ;Vt52 alternate Keypad              IBM            TAste
 ;                                                    $
\keytab:     ds.l     3
             dc.b     27,'Ol',0    ; Komma          66   ('*')
             dc.b     27,'Ow',0    ;     7          67
             dc.b     27,'Ox',0    ;     8          68
             dc.b     27,'Oy',0    ;     9          69
             dc.b     27,'Ot',0    ;     4          6a
             dc.b     27,'Ou',0    ;     5          6b
             dc.b     27,'Ov',0    ;     6          6c
             dc.b     27,'Oq',0    ;     1          6d
             dc.b     27,'Or',0    ;     2          6e
             dc.b     27,'Os',0    ;     3          6f
             dc.b     27,'Op',0    ;     0          70
             dc.b     27,'On',0    ; Punkt          71
             dc.b     27,'OM',0    ; Enter          72

 ;ANSI  alternate Keypad              IBM            TAste
 ;                                                    $
\keytab2:    ds.l     3
             dc.b     27,'?l',0    ; Komma          66   ('*')
             dc.b     27,'?w',0    ;     7          67
             dc.b     27,'?x',0    ;     8          68
             dc.b     27,'?y',0    ;     9          69
             dc.b     27,'?t',0    ;     4          6a
             dc.b     27,'?u',0    ;     5          6b
             dc.b     27,'?v',0    ;     6          6c
             dc.b     27,'?q',0    ;     1          6d
             dc.b     27,'?r',0    ;     2          6e
             dc.b     27,'?s',0    ;     3          6f
             dc.b     27,'?p',0    ;     0          70
             dc.b     27,'?n',0    ; Punkt          71
             dc.b     27,'?M',0    ; Enter          72


        text

\getascii    swap     d0                   ; Keine Sondertaste, dann �bernehme
             bsr.s    inbuf                ; ASCII vom System
\ub          move.b   mes_buf_tail(pc),d1  ; Buffer testen
             move.b   mes_buf_head(pc),d2
             moveq    #0,d0
             cmp.b    d1,d2
             beq.s    \ret
             moveq    #-1,d0
\ret         rts



      data
; ################### Tastaturbelegungen ###########################
; Sondertasten  (Vt320)

\find:       dc.b 27,'[1~',0
\insert:     dc.b 27,'[2~',0
\delete:     dc.b 27,'[3~',0
\Select:     dc.b 27,'[4~',0
\next:       dc.b 27,'[5~',0
\prev:       dc.b 27,'[6~',0
\home:       dc.b 27,'h',0
\help:       dc.b 27,'[28~',0
\undo:       dc.b 27,'[29~',0
\pa1:        dc.b 27,'[025q',0
\pa2:        dc.b 27,'[026q',0
\pa3:        dc.b 27,'[027q',0
          align
          text

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
mes_buf_tail:    ds.b 1            ; Buffer genau 256 Bytes, dann
mes_buf_head:    ds.b 1            ; wird es automatisch ein
mes_buf:         ds.b 256          ; Ringbuffer.


 text
 end
