;##############################################################################
; Exercise 7
; Zero page inc/dec
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
    lda #10                 ; Load the A register with the decimal value 10
    sta $80                 ; Store the value from A into memory position $80
    inc $80                 ; Increment the value inside a (zero page) memory position $80 
    dec $80                 ; Decrement the value inside a (zero page) memory position $80
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