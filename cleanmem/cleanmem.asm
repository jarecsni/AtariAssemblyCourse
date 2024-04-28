;##############################################################################
; Assembly program that clears the page zero region (0x00-0xFF)
; 
; Page Zero is the first 256 bytes of the 6502 memory map, 
; covering 128 bytes of RAM and 128 bytes of TIA registers
;##############################################################################

    processor 6502          ; 6502 processor
    seg code                ; Code segment   
    .org $F000              ; Start of ROM cartridge address

Start:
    sei                     ; Disable interrupts 
    cld                     ; Clear decimal mode (BCD)
    ldx #$FF                ; Load X register with FF
    txs                     ; Transfer X to stack pointer register

;##############################################################################
; Clear the page zero region (0x00-0xFF)
; This means the entire RAM + TIA space
;##############################################################################
    lda #0                  ; A = 0x00
    ldx #$FF                ; X = 0xFF
    sta $FF                 ; Store A (0) at 0xFF (as loop will start at FE)

ClearPageZero:
    dex                     ; X--
    sta $0,X                ; Store A at 0x00 + X => NO SPACE after comma!   
    bne ClearPageZero       ; Loop until X = 0x00 (=> z flag is set)   

;##############################################################################
; Cleanup
;##############################################################################
    .org $FFFC              ; Reset vector
    .word Start             ; Start address
    .word Start             ; Start address
; ##############################################################################
; END
; ##############################################################################