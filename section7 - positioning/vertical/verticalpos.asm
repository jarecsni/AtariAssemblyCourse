;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Vertical positioning of player sprites
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
P0Height byte               ; Player 0 height
P0PositionY byte            ; Player 0 position Y

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code segment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg code                ; Code segment   
    .org $F000              ; Start of ROM cartridge address
    
Start:
    CLEAN_START             ; Clean start (macro.h)
    ldx #$00                ; Black background
    stx COLUBK              ; Set background color

    ;; initialise variables
    ldx #180            
    stx P0PositionY         ; Set player 0 height to 180

    lda #9                  ; 
    sta P0Height            ; Set player 0 height to 9


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

    ;; Wait for 37 scanlines (VBLANK)
    .repeat 37
    sta WSYNC               ; Wait for sync
    .repend
    lda #0                  ; Load 0 to A
    sta VBLANK              ; Set VBLANK to 0

    ldx #192                ; 192 scanlines
ScanLine:
    txa                     ; Copy X to A
    sec                     ; Set carry flag
    sbc P0PositionY         ; Subtract player 0 position Y
    cmp P0Height            ; Compare with player 0 height
    bcc LoadBitMap          ; if result < SpriteHeight, jump to draw sprite
    lda #0                  ; Load 0 to A and then proceed to LoadBitMap 
                            ; this effectively draws line 0 of the bitmap which is
                            ; the empty bottom line (bitmap is inverted mind you)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Positioning logic explained
;; 
;; The P0PositionsY is where the bottom of the sprite will be drawn on screen:
;;
;; The sprite of 9 rows will be drawn from P0PositionY + 9 to P0PositionY (given that 
;; we count the scanlines starting from 192, down to 0).
;; 
;; P0PositionY + 9
;; ...
;; P0PositionY + 0
;;
;; This is why the bitmap is stored in reverse order.
;; 
;; This why the above substraction is done:
;; scanline - positionY < 9
;; 
;; 189 - 180 = 9 ! (since the comparison is equal, carry flag is set)
;; 188 - 180 = 8
;; 187 - 180 = 7
;; 186 - 180 = 6
;; 185 - 180 = 5
;; 184 - 180 = 4
;; 183 - 180 = 3
;; 182 - 180 = 2
;; 181 - 180 = 1
;; 180 - 180 = 0
;; 179 - 180 = -1 !

LoadBitMap:
    tay                     ; Copy A to Y
    lda P0BitMap,y          ; Load player 0 bitmap line defined by y
    sta WSYNC
    sta GRP0                ; Set player 0 bitmap
    lda P0Color,y           ; Load player 0 color
    sta COLUP0              ; Set player 0 color
    dex                     ; Decrement X
    bne ScanLine            ; If X is not zero, repeat ScanLine


    ;; 30 overscan lines
    lda #2                  ; Load 1 to A
    sta VBLANK              ; Set VBLANK to 2
    .repeat 30
    sta WSYNC               ; Wait for sync
    .repend
    lda #0                  ; Load 0 to A
    sta VBLANK              ; Set VBLANK to 0

    dec P0PositionY         ; Decrement player 0 position Y
    
    jmp StartFrame


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bit maps
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .org $FFE8

;; Player 0 bit map (inverted, bottom to top)
P0BitMap:
    byte #%00000000
    byte #%00101000
    byte #%01110100
    byte #%11111010
    byte #%11111010
    byte #%11111010
    byte #%11111110
    byte #%01101100
    byte #%00110000

;; Playe 0 color by lines
P0Color:
    byte #$00
    byte #$40
    byte #$40
    byte #$40
    byte #$40
    byte #$42
    byte #$42
    byte #$44
    byte #$D2


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cleanup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .org $FFFC              ; Reset vector
    .word Start             ; Start address
    .word Start             ; Start address