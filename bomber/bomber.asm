;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Horizontal positioning of player sprites
;; (C) Johnny Jarecsni
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   .processor 6502          ; 6502 processor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Include files with VCS constants and macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .include "../headers/vcs.h"
    .include "../headers/macro.h"
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define a segment for variables starting at $80
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg.u Variables
    .org $80

JetXPos:            .byte       ; Horizontal position of the jet (player 0)
JetYPos:            .byte       ; Vertical position of the jet (player 0)
BomberXPos:         .byte       ; Horizontal position of the bomber (player 1)
BomberYPos:         .byte       ; Vertical position of the bomber (player 1)
JetSpritePtr:       .word       ; Pointer to the jet sprite (player 0)
JetColorPtr:        .word       ; Pointer to the jet color (player 0)
BomberSpritePtr:    .word       ; Pointer to the bomber sprite (player 1)
BomberColorPtr:     .word       ; Pointer to the bomber color (player 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
JET_HEIGHT = 9                  ; Height of the jet sprite    
BOMBER_HEIGHT = 9               ; Height of the bomber sprite


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ROM Code segment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .seg Code               ; Code segment   
    .org $F000              ; Start of ROM cartridge address

Reset:
    CLEAN_START             ; Clean start (macro.h)    
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialise RAM variables and TIA registers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #10                 ; 
    sta JetYPos             ; JetYPos = 10
    lda #60                 ;
    sta JetXPos             ; JetXPos = 60
    lda #83                 ;
    sta BomberYPos          ; BomberYPos = 83
    lda #54                 ; 
    sta BomberXPos          ; BomberXPos = 54

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialise pointers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #<JetSprite             ; Low byte of JetSprite
    sta JetSpritePtr            ; JetSpritePtr = JetSprite
    lda #>JetSprite             ; High byte of JetSprite
    sta JetSpritePtr+1          ; JetSpritePtr = JetSprite

    lda #<JetColor              ; Low byte of JetColor
    sta JetColorPtr             ; JetColorPtr = JetColor
    lda #>JetColor              ; High byte of JetColor
    sta JetColorPtr+1           ; JetColorPtr = JetColor

    lda #<BomberSprite          ; Low byte of BomberSprite
    sta BomberSpritePtr         ; BomberSpritePtr = BomberSprite
    lda #>BomberSprite          ; High byte of BomberSprite
    sta BomberSpritePtr+1       ; BomberSpritePtr = BomberSprite

    lda #<BomberColor           ; Low byte of BomberColor   
    sta BomberColorPtr          ; BomberColorPtr = BomberColor
    lda #>BomberColor           ; High byte of BomberColor
    sta BomberColorPtr+1        ; BomberColorPtr = BomberColor

    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main Display Loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; VBLANK & VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK             ; VBLANK on
    sta VSYNC              ; VSYNC on
    .repeat 3
        sta WSYNC          ; Wait for sync
    .repend
    lda #0
    sta VSYNC              ; VSYNC off
    .repeat 37
        sta WSYNC          ; Wait for sync
    .repend
    sta VBLANK             ; VBLANK off

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display 192 visible lines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
VisibleLines:
    lda #$84                ; NTSC color blue
    sta COLUBK              ; Background color
    lda #$C2                ; NTSC color green
    sta COLUPF              ; Playfield color

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Playfield pattern
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #%00000001          ; Reflect = true
    sta CTRLPF              ; Playfield control

    lda #$F0                ; Playfield pattern
    sta PF0                 ; Playfield 0
    lda #$FC                ; Playfield pattern
    sta PF1                 ; Playfield 1
    lda #0
    sta PF2                 ; Playfield 2   

    ldx #96                 ; x = 192 / 2 (as we do a double line kernel)
.GameLineLoop:

.InsideJetSprite:
    txa                     ; x -> a
    sec                     ; Set carry
    sbc JetYPos             ; a = x - JetYPos
    cmp JET_HEIGHT          ; are we inside the jet sprite?
    bcc .DrawJet            ; Yes, draw the jet sprite 
    lda #0                  ; no, so set y to 0 (which is all 0 bits in the sprite)
.DrawJet:
    tay                     ; a -> y
    lda (JetSpritePtr),y    ; Load the jet sprite data
    sta WSYNC               ; Wait for sync
    sta GRP0                ; Draw the jet sprite
    lda (JetColorPtr),y     ; Load the jet color data
    sta COLUP0              ; Set the jet color

.InsideBomberSprite:
    txa                     ; x -> a
    sec                     ; Set carry
    sbc BomberYPos          ; a = x - BomberYPos
    cmp BOMBER_HEIGHT       ; are we inside the bomber sprite?
    bcc .DrawBomber         ; Yes, draw the bomber sprite 
    lda #0                  ; no, so set y to 0 (which is all 0 bits in the sprite)
.DrawBomber:
    tay                     ; a -> y

    lda #%00000101          ; (Stretch = 1, Reflect = 0)
    sta NUSIZ1              ; Set the size of the bomber sprite

    lda (BomberSpritePtr),y ; Load the bomber sprite data
    sta WSYNC               ; Wait for sync
    sta GRP1                ; Draw the bomber sprite
    lda (BomberColorPtr),y  ; Load the bomber color data
    sta COLUP1              ; Set the bomber color

    dex                     ; x--
    bne .GameLineLoop       ; Loop until x = 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Overscan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2                  ;   
    sta VBLANK              ; VBLANK on
    .repeat 30
        sta WSYNC           ; Wait for sync
    .repend
    lda #0                  ;
    sta VBLANK              ; VBLANK off

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; End of Display Loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    jmp StartFrame          ; Jump to the start of the display loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sprites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
JetSprite:
    .byte %00000000         ;  
    .byte %00010100         ;   # #
    .byte %01111111         ; #######
    .byte %00111110         ;  #####    
    .byte %00011100         ;   ###
    .byte %00011100         ;   ###
    .byte %00001000         ;    #
    .byte %00001000         ;    #
    .byte %00001000         ;    #

;JETHEIGHT = * - JetSprite   ; Height of the jet sprite

JetSpriteTurn:
    .byte %00000000         ;  
    .byte %00001000         ;    #
    .byte %00111110         ;  ##### 
    .byte %00011100         ;   ###     
    .byte %00011100         ;   ###
    .byte %00011100         ;   ###
    .byte %00001000         ;    #
    .byte %00001000         ;    #
    .byte %00001000         ;    #

BomberSprite:
    .byte %00000000         ;
    .byte %00001000         ;    #
    .byte %00001000         ;    # 
    .byte %00101010         ;  # # #
    .byte %00111110         ;  #####
    .byte %01111111         ; #######
    .byte %00101010         ;  # # #
    .byte %00001000         ;    #
    .byte %00011100         ;   ###

;BOMBER_HEIGHT = * - BomberSprite   ; Height of the bomber sprite

JetColor:
    .byte #$00              ;
    .byte #$FE              ; 
    .byte #$0C              ; 
    .byte #$0E              ; 
    .byte #$0E              ; 
    .byte #$04              ; 
    .byte #$BA              ;
    .byte #$0E              ;
    .byte #$08              

JetColorTurn
    .byte #$00              ;
    .byte #$FE              ; 
    .byte #$0C              ; 
    .byte #$0E              ; 
    .byte #$0E              ; 
    .byte #$04              ; 
    .byte #$0E              ;
    .byte #$0E              ;
    .byte #$08              

BomberColor
    .byte #$00              ;
    .byte #$32              ; 
    .byte #$32              ; 
    .byte #$0E              ; 
    .byte #$40              ; 
    .byte #$40              ; 
    .byte #$40              ;
    .byte #$40              ;
    .byte #$40              ;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cleanup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .org $FFFC              ; Reset vector
    .word Reset             ; Start address
    .word Reset             ; Start address