BELL:        movem.l d7/a6,-(sp)
             pea   \belldata(pc)
             move  #32,-(sp)     ; DOSOUND
             trap  #14
             addq.l #6,sp
             movem.l (sp)+,d7/a6
             rts
\BELLDATA    dc.w $00ff,$0100,$0200,$0300,$0400,$0500,$0600,$07f8,$0810
             dc.w $0900,$0a00,$0b00,$0c10,$0d09,$ff00
  end
 