;##############################################################################
; Exercise 5
; Different addressing modes with ADC
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
    lda #$a                 ; Load the A register with the hexadecimal value $A 
    ldx #%1010              ; Load the X register with the binary value %1010
    sta $80                 ; Store the value in the A register into (zero page) memory address $80 
    stx $81                 ; Store the value in the X register into (zero page) memory address $81
    lda #10                 ; Load A with the decimal value 10
    clc                     ; Clear the carry flag
    adc $80                 ; Add to A the value inside RAM address $80
    adc $81                 ; Add to A the value inside RAM address $81
                            ; A should contain (#10 + $A + %1010) = #30 (or $1E in hexadecimal)
    sta $82                 ; Store the result of the addition into RAM address $82

    jmp Main
; Store the value of A into RAM position $82
;##############################################################################
; Cleanup
;##############################################################################
    .org $FFFC              ; Reset vector
    .word Start             ; Start address
    .word Start             ; Start address
; ##############################################################################
; END
; ##############################################################################