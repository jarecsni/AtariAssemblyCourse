    
    processor 6502

    seg code
    org $F000               ; Start of ROM cartridge address

Start:
    sei                     ; Disable interrupts 
    cld                     ; Clear decimal mode (BCD)
    ldx #$FF                ; Load X register with FF
    txs                     ; Transfer X to stack pointer register

; ##############################################################################
; Clear the page zero region (0x00-0xFF)
; This means the entire RAM + TIA space
; ##############################################################################
    lda #0                  ; A = 0x00
    ldx #$FF                ; X = 0xFF

ClearPageZero:
    sta $0,X                ; Store A at 0x00 + X => NO SPACE after comma!   
    dex                     ; X--
    bne ClearPageZero       ; Loop until X = 0x00 (=> z flag is set)   

; ##############################################################################
; Cleanup
; ##############################################################################
    org $FFFC               ; Reset vector
    .word Start             ; Start address
    .word Start             ; Start address
; ##############################################################################
; END
; ##############################################################################