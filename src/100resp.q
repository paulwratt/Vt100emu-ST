 ; ## Requests ESC-[-bs-n ##

requests:    move  varwert1(pc),d6
             TST    (FRAGEZEICHENF-esc_vars)(a6)
             bne.s  \req2
             cmp   #5,d6
             BEQ.s REP_STATUS
             cmp   #6,d6
             BEQ.s REP_CURSOR
             rts

\req2        cmp   #15,d6
             BEQ.s REP_PRINTER
             rts

identify:     move   varwert1(pc),d6
              tst    d6
              bne.s  rtret
REP_TERMINAL: lea    DA_100(pc),a0
              bsr    sinbuf
rtret         rts

REP_printer:   bsr    out_stat
               tst    d0
               bmi.s  \ok
               lea    DSR_PRTERR(pc),a0
               bsr    sinbuf
               rts
\ok            lea  DSR_PRTOK(pc),a0
               bsr  sinbuf
               rts
REP_CURSOR:     lea  DSR_CURPOS(pc),a0
                bsr  sinbuf
                moveq #';',d0
                bsr  inbuf
                moveq #'R',d0
                bsr  inbuf
                rts
REP_STATUS:     lea  DSR_OK(pc),a0
                bsr  sinbuf
                rts

   data

DSR_OK:    dc.b  27,'[0n',0    ; no malfunktion
DSR_ERR:   dc.b  27,'[3n',0    ; Error
DSR_PRTOK: dc.b  27,'[?10n',0  ; Printer ready
DSR_PRTERR: dc.b 27,'[?11n',0  ; Printer not ready
DSR_CURPOS: dc.b 27,'[',0
DA_102:    dc.b  27,'[?6c',0   ; VT102
DA_100:    dc.b  27,'[?1;0c',0 ; Vt100
   align
   text
  end
 