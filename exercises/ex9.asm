;##############################################################################
; Exercise 8
; Looping through 0 to 10 and storing values in memory
; (C) Johnny Jarecsni
;##############################################################################

    .processor 6502          ; 6502 processor
    .seg code                ; Code segment   
    .org $F000              ; Start of ROM cartridge address

Start:
    sei                     ; Disable interrupts 
    cld                     ; Clear decimal mode (BCD)
    ldx #$FF                ; Load X register with FF
    txs                     ; Transfer X to stack pointer register

;##############################################################################
; Main program
;##############################################################################
Main:
    lda #1                  ; A = 1 
Loop:
    sta $80                 ; $80 = A
    inc $80                 ; $80 = $80 + 1
    lda $80                 ; A = $80
    cmp #10                 ; A = 10?
    bne Loop                ; Loop if not 10
                            ;
    jmp Main
;##############################################################################
; Cleanup
;##############################################################################
    .org $FFFC              ; Reset vector
    .word Start             ; Start address
    .word Start             ; Start address
; ##############################################################################
; END
; ##############################################################################