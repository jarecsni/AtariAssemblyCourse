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
    ldy #10                 ; Load Y with 10
Loop:
    tya                     ; Transfer Y to A
    sta $80,y               ; Store the value in A inside memory position $80+Y 
    dey                     ; Decrement Y
    bne Loop                ; Loop until we're done
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