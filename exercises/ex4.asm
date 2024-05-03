;##############################################################################
; Exercise 4
; ALU - Arithmetic Logic Unit, add substract 
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
    lda #100                ; Load the A register with the literal decimal value 100
    clc                     ; Clear the carry flag before ADC
    adc #5                  ; Add the decimal value 5 to the accumulator
    sec                     ; Set the carry flag before SBC
    sbc #10                 ; Subtract the decimal value 10 from the accumulator
                            ; Register A should now contain the decimal 95 (or $5F in hexadecimal)


;##############################################################################
; Cleanup
;##############################################################################
    .org $FFFC              ; Reset vector
    .word Start             ; Start address
    .word Start             ; Start address
; ##############################################################################
; END
; ##############################################################################