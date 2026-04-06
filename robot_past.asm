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
    incsrc "./src/gameplay.asm"
    incsrc "./src/nmi.asm"
    incsrc "./src/dma.asm"
    incsrc "./src/hdma.asm"
    incsrc "./src/scroll.asm"
    incsrc "./src/loading.asm"
    incsrc "./src/player.asm"
    incsrc "./src/sprites.asm"
    incsrc "./src/color_cycling.asm"
    incsrc "./src/messagebox.asm"
    
    incsrc "./src/objects.asm"          ;also contains inc for obj_def.asm for individual objects
    
    print "80 end: ", pc
    
org $c00000
    incsrc "./data/inc/scenedefs.asm"
    incsrc "./data/inc/objlists.asm"
    print "c0 end: ", pc
    
org $c10000
    incsrc "./data/inc/c1.asm"
    print "c1 end: ", pc
    
org $c20000
    incsrc "./data/inc/c2.asm"
    print "c2 end: ", pc
    
org $c30000
    incsrc "./data/inc/c3.asm"
    print "c3 end: ", pc

org $c40000
    incsrc "./data/inc/c4.asm"
    print "c4 end: ", pc
    
    
    ;org $c4ffff
    ;db 00

;===========================================================================================
;==================================               ==========================================
;==================================  H E A D E R  ==========================================
;==================================               ==========================================
;===========================================================================================


org $c0ffc0                             ;game header
    db "robot past           "          ;cartridge name
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