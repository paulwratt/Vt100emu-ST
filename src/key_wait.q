; LIBRARY\KEY_WAIT
; PC-relativ --> 10 Bytes

; Gemdos(7)-Aufruf. R�ckgabeparameter in d0
; ver�ndert alle Register

WAIT:   move    #7,-(sp)
        trap    #1
        addq.l  #2,sp
        rts
 end
 