hirom

optimize dp always
optimize address mirrors

incsrc "./src/defines.asm"
incsrc "./src/ram_labels.asm"

;===========================================================================================
;===================================               =========================================
;===================================   B A N K S   =========================================
;===================================               =========================================
;===========================================================================================

org $808000
    incsrc "./src/boot.asm"
    incsrc "./src/main.asm"
    incsrc "./src/nmi.asm"
    incsrc "./src/dma.asm"
    

org $c00000
    ;
org $c10000
    ;
org $c20000
    ;

;===========================================================================================
;==================================               ==========================================
;==================================  H E A D E R  ==========================================
;==================================               ==========================================
;===========================================================================================


org $c0ffc0                             ;game header
    db "superfamicomtuber    "          ;cartridge name
    db $31                              ;fastrom, lorom
    db $02                              ;rom + ram + sram
    db $09                              ;rom size = 512k
    db $00                              ;sram size 0
    db $00                              ;country code
    db $ff                              ;developer code
    db $00                              ;rom version
    dw $FFFF                            ;checksum complement
    dw $FFFF                            ;checksum
    
    ;interrupt vectors
    
    ;native mode
    dw errhandle, errhandle, errhandle, errhandle, errhandle, nmi, errhandle, irq
    
    ;emulation mode
    dw errhandle, errhandle, errhandle, errhandle, errhandle, errhandle, boot, errhandle