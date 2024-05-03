;##############################################################################
; 
; (C) Johnny Jarecsni
;##############################################################################
    .include "../../headers/vcs.h"
    .include "../../headers/macro.h"
    .processor 6502         ; 6502 processor
    .seg code               ; Code segment   
    .org $F000              ; Start of ROM cartridge address

    CLEAN_START             ; Clean start (macro.h)

Start:
;##############################################################################
; Main program
;##############################################################################
NextFrame:
    lda #2                  ; Load 2 to A
    sta VSYNC               ; Set VSYNC to 2
    sta VBLANK              ; Set VBLANK to 2

    ;; Wait for 3 scanlines
    sta WSYNC               ; Wait for sync
    sta WSYNC               ; Wait for sync
    sta WSYNC               ; Wait for sync

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
    ldx #192                ; Load 192 to X
DrawScanline:
    stx COLUBK              ; Set background color
    sta WSYNC               ; Wait for sync
    dex                     ; X--
    bne DrawScanline        ; Loop until X is 0

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