;##############################################################################
; 
; (C) Johnny Jarecsni
;##############################################################################
    .include "../../headers/vcs.h"
    .include "../../headers/macro.h"
    .processor 6502         ; 6502 processor
    .seg code               ; Code segment   
    .org $F000              ; Start of ROM cartridge address

Start:
    CLEAN_START             ; Clean start (macro.h)
    ldx #$80                ; Blue background color
    stx COLUBK              ; Set background color
    lda #$1c                ; Set the playfield to yellow
    sta COLUPF              ; Set playfield colour to yellow

;##############################################################################
; Main program
;##############################################################################
NextFrame:
    lda #2                  ; Load 2 to A
    sta VSYNC               ; Set VSYNC to 2
    sta VBLANK              ; Set VBLANK to 2

    ;; Wait for 3 scanlines
    .repeat 3
    sta WSYNC               ; Wait for sync
    .repend
    lda #0                  ; Load 0 to A
    sta VSYNC               ; Set VSYNC to 0

    ;; Wait for 37 scanlines
    lda #2                  ; Load 1 to A
    ldx #37                 ; Load 37 to X
Wait:  
    sta WSYNC               ; Wait for sync
    dex                     ; X--
    bne Wait                ; Loop until X is 0
    lda #0                  ; Load 0 to A
    sta VBLANK              ; Set VBLANK to 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw 192 visible scanlines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #%00000001          ; Load 1 to X
    stx CTRLPF              ; Set the control playfield register to 1 (=reflect)

;; 7 empty lines
    ldx #0                  ; Load 0 to X
    stx PF0                 ; Set the playfield 0 register to 0
    stx PF1                 ; Set the playfield 1 register to 0
    stx PF2                 ; Set the playfield 2 register to 0

    .repeat 7
    sta WSYNC               ; Wait for sync
    .repend

;; 7 lines horizontal border
    ldx #%11100000          ; Load 11100000 to A
    stx PF0                 ; Set the playfield 0 register to 11100000
    ldx #%11111111          ; Load 11111111 to A
    stx PF1                 ; Set the playfield 1 register to 11111111
    stx PF2                 ; Set the playfield 2 register to 11111111
    .repeat 7
    sta WSYNC               ; Wait for sync
    .repend

;; Draw 164 side borders
    ldx #%00100000          ; Load 00100000 to X
    stx PF0                 ; Set the playfield 0 register to 00100000
    ldx #0                  ; Load 0 to X
    stx PF1                 ; Set the playfield 1 register to 0
    stx PF2                 ; Set the playfield 2 register to 0
    .repeat 164
    sta WSYNC               ; Wait for sync
    .repend

;; 7 lines horizontal border
    ldx #%11100000          ; Load 11100000 to A
    stx PF0                 ; Set the playfield 0 register to 11100000
    ldx #%11111111          ; Load 11111111 to A
    stx PF1                 ; Set the playfield 1 register to 11111111
    stx PF2                 ; Set the playfield 2 register to 11111111
    .repeat 7
    sta WSYNC               ; Wait for sync
    .repend

;; 7 empty lines
    ldx #0                  ; Load 0 to X
    stx PF0                 ; Set the playfield 0 register to 0
    stx PF1                 ; Set the playfield 1 register to 0
    stx PF2                 ; Set the playfield 2 register to 0

    .repeat 7
    sta WSYNC               ; Wait for sync
    .repend

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Outpu 30 VBLANK lines to comlete the frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;; Wait for 37 scanlines
    lda #2                  ; Load 1 to A
    sta VBLANK              ; Set VBLANK to 2
    ldx #30                 ; Load 37 to X

OverscanLoop:
    sta WSYNC               ; Wait for sync
    dex                     ; X--
    bne OverscanLoop        ; Loop until X is 0

    lda #0                  ; Load 0 to A
    sta VBLANK              ; Set VBLANK to 0
    jmp NextFrame           ; Jump to next frame

;##############################################################################
; Cleanup
;##############################################################################
    .org $FFFC              ; Reset vector
    .word Start             ; Start address
    .word Start             ; Start address
; ##############################################################################
; END
; ##############################################################################