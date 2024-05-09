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
    ldx #$88                ; Black background
    stx COLUBK              ; Set background color

    ;; initialise variables
    lda #0                  ; Player 0 X position
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

    sec                     ; Set carry flag

    sta WSYNC               ; Wait for sync
    sta HMCLR               ; Clear horizontal motion registers

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

    ;; one way of incrementing and testing for upper boundary 80
    ; inc P0XPos              ; Increment player 0 X position
    ; lda P0XPos              ; Load player 0 X position
    ; cmp #81                 ; Compare to 80
    ; bne RepeatFrame         ; If not equal, repeat frame

    ; lda #40
    ; sta P0XPos              ; Reset player 0 X position

    ; Gustavo's way of incrementing and testing for upper boundary 80
    lda P0XPos              ; Load player 0 X position
    cmp #80                 ; Compare to 80
    bpl ResetP0XPos         ; If greater than 80, reset player 0 X position
    jmp IncrementP0XPos     ; Otherwise, increment player 0 X position
ResetP0XPos:
    ;lda #40
    ;sta P0XPos              ; Reset player 0 X position
IncrementP0XPos:
    ;inc P0XPos              ; Increment player 0 X position
        
    jmp StartFrame


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bit maps
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .org $FFE8

;; Player 0 bit map (inverted, bottom to top)
P0BitMap:
    .byte #%00000000
    .byte #%00010000
    .byte #%00001000
    .byte #%00011100
    .byte #%00110110
    .byte #%00101110
    .byte #%00101110
    .byte #%00111110
    .byte #%00011100

;; Playe 0 color by lines
P0Color:
    .byte #$00
    .byte #$02
    .byte #$02
    .byte #$52
    .byte #$52
    .byte #$52
    .byte #$52
    .byte #$52
    .byte #$52


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cleanup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .org $FFFC              ; Reset vector
    .word Start             ; Start address
    .word Start             ; Start address