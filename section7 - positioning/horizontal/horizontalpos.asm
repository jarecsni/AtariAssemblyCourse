;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Horizontal positioning of player sprites
;; (C) Johnny Jarecsni
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .include "../../headers/vcs.h"
    .include "../../headers/macro.h"
    .processor 6502          ; 6502 processor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Vars
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg.u Variables
    .org $80
P0XPos .byte                ; Player 0 X position

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code segment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .seg code               ; Code segment   
    .org $F000              ; Start of ROM cartridge address
    
Start:
    CLEAN_START             ; Clean start (macro.h)
    ldx #$00                ; Black background
    stx COLUBK              ; Set background color

    ;; initialise variables
    lda #50                 ; Player 0 X position
    sta P0XPos            
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Render frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:
    lda #2                  ; Load 2 to A
    sta VSYNC               ; Set VSYNC to 2
    sta VBLANK              ; Set VBLANK to 2

    ;; Wait for 3 scanlines (VSYNC)
    .repeat 3
    sta WSYNC               ; Wait for sync
    .repend
    lda #0                  ; Load 0 to A
    sta VSYNC               ; Set VSYNC to 0

    ;; still in vblank area
    lda P0XPos              ; Load player 0 X position
    and #$7F                ; Mask out the 8th bit (=0) -> A always positive
    
    sta WSYNC               ; Wait for sync
    sta HMCLR               ; Clear horizontal motion registers

    sec                     ; Set carry flag
DivideLoop:
    sbc #15                 ; Subtract 15
    bcs DivideLoop          ; If carry flag is set, repeat DivideLoop

    ;; todo - clarify how this works
    eor #7                  ; Invert the 3 lowest bits (adjust between -8 and 7 for fine pos)
    ;; shift left by 4, HMP0 uses the 4 highest bits only
    asl                     ; Multiply by 2
    asl                     ; Multiply by 2
    asl                     ; Multiply by 2
    asl                     ; Multiply by 2

    sta HMP0                ; Set player 0 horizontal motion
    sta RESP0               ; Set player 0 horizontal position

    sta WSYNC               ; Wait for sync
    sta HMOVE               ; Enable horizontal motion

    ;; Wait for 35 (=37 - 2 as 2 has been spent above) scanlines (VBLANK)
    .repeat 35
    sta WSYNC               ; Wait for sync
    .repend
    lda #0                  ; Load 0 to A
    sta VBLANK              ; Set VBLANK to 0

    ;; Visible scanlines
    .repeat 60
    sta WSYNC               ; Wait for sync
    .repend

    ldy #8                  ; counter
DrawBitMap:
    lda P0BitMap,y          ; Load player 0 bit map
    sta GRP0                ; Set player 0 bit map
    lda P0Color,y           ; Load player 0 color
    sta COLUP0              ; Set player 0 color
    sta WSYNC               ; Wait for sync
    dey
    bne DrawBitMap          ; Loop until y is 0

    lda #0                  ; Load 0 to A
    sta GRP0                ; Clear player 0 bit map    

    .repeat 124
    sta WSYNC               ; Wait for sync
    .repend


    ;; 30 overscan lines
    lda #2                  ; Load 1 to A
    sta VBLANK              ; Set VBLANK to 2
    .repeat 30
    sta WSYNC               ; Wait for sync
    .repend
    lda #0                  ; Load 0 to A
    sta VBLANK              ; Set VBLANK to 0

    inc P0XPos              ; Increment player 0 X position
    
    jmp StartFrame


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bit maps
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .org $FFE8

;; Player 0 bit map (inverted, bottom to top)
P0BitMap:
    .byte #%00000000
    .byte #%00101000
    .byte #%01110100
    .byte #%11111010
    .byte #%11111010
    .byte #%11111010
    .byte #%11111110
    .byte #%01101100
    .byte #%00110000

;; Playe 0 color by lines
P0Color:
    .byte #$00
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$40
    .byte #$42
    .byte #$42
    .byte #$44
    .byte #$D2


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cleanup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .org $FFFC              ; Reset vector
    .word Start             ; Start address
    .word Start             ; Start address