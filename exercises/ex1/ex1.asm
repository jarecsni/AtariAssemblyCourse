;##############################################################################
; 
; 
; 
; 
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
; 
; 
;##############################################################################
    lda #$82                ; load the A register with the literal value 0x82
    ldx #82                 ; load the X register with the literal value 82 (dec)
    ldy $82                 ; load the Y register with the value at address 0x82

;##############################################################################
; Cleanup
;##############################################################################
    .org $FFFC              ; Reset vector
    .word Start             ; Start address
    .word Start             ; Start address
; ##############################################################################
; END
; ##############################################################################