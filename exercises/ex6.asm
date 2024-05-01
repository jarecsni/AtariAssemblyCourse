;##############################################################################
; Exercise 6
; Increment and decrement
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

    lda #1                  ; Load the A register with the decimal value 1
    ldx #2                  ; Load the X register with the decimal value 2
    ldy #3                  ; Load the Y register with the decimal value 3
    inx                     ; Increment X
    iny                     ; Increment Y
                            ; Increment A
    sta $80                 ; Store A to memory location $80
    inc $80                 ; Increment memory location $80
    lda $80                 ; Load A from memory location $80
    dex                     ; Decrement X                            
    dey                     ; Decrement Y
                            ; Decrement A
    sta $81                 ; Store A to memory location $81
    dec $81                 ; Decrement memory location $81
    lda $81                 ; Load A from memory location $81                     
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