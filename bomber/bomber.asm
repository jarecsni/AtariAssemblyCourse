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

    ldx #192                ; x = 192 (visible lines)
.GameLineLoop:
    sta WSYNC               ; Wait for sync
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

JETHEIGHT = * - JetSprite   ; Height of the jet sprite

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