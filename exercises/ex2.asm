;##############################################################################
; Exercise 2 - load and store values
;##############################################################################

    .processor 6502          ; 6502 processor
    .seg code                ; Code segment   
    .org $F000              ; Start of ROM cartridge address

;##############################################################################
; Main program
;##############################################################################
Start:
    lda #$a                 ; load the A register with the literal value 0xa
    ldx #%11111111          ; load the X register with the literal value 0xFF 
    sta $80                 ; store the A register value at address 0x80
    stx $81                 ; store the X register value at address 0x81
    jmp Start

;##############################################################################
; Cleanup
;##############################################################################
    .org $FFFC              ; Reset vector
    .word Start             ; Start address
    .word Start             ; Start address
; ##############################################################################
; END
; ##############################################################################