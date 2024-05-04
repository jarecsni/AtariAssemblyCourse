;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (C) Johnny Jarecsni
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .include "../headers/vcs.h"
    .include "../headers/macro.h"
    .processor 6502          ; 6502 processor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Vars
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg.u Variables
    .org $80
P0Height ds 1               ; Player 0 height
P1Height ds 1               ; Player 1 height


    seg code                ; Code segment   
    .org $F000              ; Start of ROM cartridge address
    
Start:
    CLEAN_START             ; Clean start (macro.h)
    ldx #$80                ; NTSC Blue
    stx COLUBK              ; Set background color
    lda #%1111              ; NTSC White
    sta COLUPF              ; Set playfield colour to yellow
    ldy #%00000010          ; Set the playfield to 2 (means score)
    sty CTRLPF              ; Set the control register for the playfield

    ; initialise variables
    lda #10                 
    sta P0Height            ; Set player 0 height to 10
    sta P1Height            ; Set player 1 height to 10

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Player0 and Player1 colors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #$48                ; NTSC Red
    sta COLUP0              ; Set player0 color to red
    lda #$C6                ; NTSC Green
    sta COLUP1              ; Set player1 color to green

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Render frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NextFrame:
    lda #2                  ; Load 2 to A
    sta VSYNC               ; Set VSYNC to 2
    sta VBLANK              ; Set VBLANK to 2

    ;; Wait for 3 scanlines (VSYNC)
    .repeat 3
    sta WSYNC               ; Wait for sync
    .repend
    lda #0                  ; Load 0 to A
    sta VSYNC               ; Set VSYNC to 0

    ;; Wait for 37 scanlines (VBLANK)
    lda #2                  ; Load 1 to A
    .repeat 37
    sta WSYNC               ; Wait for sync
    .repend
    lda #0                  ; Load 0 to A
    sta VBLANK              ; Set VBLANK to 0

VisibleScanLines:
    ; 10 empty lines at the top
    .repeat 10
    sta WSYNC               ; Wait for sync
    .repend

    ; Display 10 scan lines for the scoreboard numbers
    ldy #0                  ; Load 0 to y 
ScoreboardLoop:
    lda NumberBitMap,y      ; Load the number bitmap   
    sta PF1                 ; Set playfield 1
    sta WSYNC               ; Wait for sync
    iny                     ; Increment Y
    cpy #10                 ; Check if we reached the end of the bitmap (10 lines)
    bne ScoreboardLoop      ; If not, loop
    lda #0                  ; Load 0 to A
    sta PF1                 ; Clear playfield 1
    ; 50 empty lines between score and the player 
    .repeat 50
    sta WSYNC               ; Wait for sync
    .repend

    ;; Player 0
    ldy #0                  ; Load 0 to y
Player0Loop:
    lda PlayerBitMap,y      ; Load the player bitmap
    sta GRP0                ; Set player 0
    sta WSYNC               ; Wait for sync
    iny                     ; Increment Y    
    cpy P0Height            ; Check if we reached the end of the bitmap (10 lines)
    bne Player0Loop         ; If not, loop
    lda #0                  ; Load 0 to A
    sta GRP0                ; Clear player 0

    ;; Player 1
    ldy #0                  ; Load 0 to y
Player1Loop:
    lda PlayerBitMap,y      ; Load the player bitmap
    sta GRP1                ; Set player 0
    sta WSYNC               ; Wait for sync
    iny                     ; Increment Y    
    cpy P1Height            ; Check if we reached the end of the bitmap (10 lines)
    bne Player1Loop         ; If not, loop
    lda #0                  ; Load 0 to A
    sta GRP1                ; Clear player 0

    .repeat 102
    sta WSYNC               ; Wait for sync
    .repend

    ; 30 overscan
    lda #2                  ; Load 1 to A
    sta VBLANK              ; Set VBLANK to 2
    .repeat 30
    sta WSYNC               ; Wait for sync
    .repend
    lda #0                  ; Load 0 to A
    sta VBLANK              ; Set VBLANK to 0

    
    jmp NextFrame


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bit maps
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .org $FFE8
PlayerBitMap:
    .byte %01111110         ;    ######
    .byte %11111111         ;   ########
    .byte %10011001         ;   #  ##  #
    .byte %11111111         ;   ########
    .byte %11111111         ;   ########
    .byte %11111111         ;   ########
    .byte %10111101         ;   # #### #
    .byte %11000011         ;   ##    ##
    .byte %11111111         ;   ########
    .byte %01111110         ;    ######

NumberBitMap:
    .byte %00001110         ;   ########
    .byte %00001110         ;   ########
    .byte %00000010         ;        ###
    .byte %00000010         ;        ###
    .byte %00001110         ;   ########
    .byte %00001110         ;   ########
    .byte %00001000         ;   ###
    .byte %00001000         ;   ###
    .byte %00001110         ;   ########
    .byte %00001110         ;   ########


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cleanup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .org $FFFC              ; Reset vector
    .word Start             ; Start address
    .word Start             ; Start address