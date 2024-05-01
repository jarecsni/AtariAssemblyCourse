;##############################################################################
; Exercise 3
; Transferring data between registers
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

    lda #15                 ; Load the A register with the literal decimal value 15 
    tax                     ; Transfer the value from A to X
    tay                     ; Transfer the value from A to Y
    txa                     ; Transfer the value from X to A
    tya                     ; Transfer the value from Y to A
    ldx #6                  ; Load X with the decimal value 6 
    txa                     ; Transfer the value from X to Y
    tay
;##############################################################################
; Cleanup
;##############################################################################
    .org $FFFC              ; Reset vector
    .word Start             ; Start address
    .word Start             ; Start address
; ##############################################################################
; END
; ##############################################################################