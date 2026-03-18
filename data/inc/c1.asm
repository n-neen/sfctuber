;===========================================================================================
;========================================= SCENE ===========================================
;=============================== GRAPHICS, TILEMAP, PALETTES ===============================
;===========================================================================================

light: {
    .pal:   incbin "./data/pal/light.pal"
    .gfx:   incbin "./data/gfx/light.gfx"
    .map:   incbin "./data/map/light.map"
    
    
    .props:
        ;gameplay aspects of this scene
        dw $ffff
}


blood_lotus: {
    .pal:   incbin "./data/pal/blood.pal"
    .gfx:   incbin "./data/gfx/blood.gfx"
    .map:   incbin "./data/map/blood.map"
    
    
    .props:
        ;gameplay aspects of this scene
        dw $ffff
}

;===========================================================================================
;========================================= BG3 =============================================
;==================================== FONT GRAPHICS ========================================
;===========================================================================================

;reserve first palette line for bg3 for every scene maybe


bg3data: {
    .gfx:
        ;incbin "./data/gfx/bg3.gfx"
    .testmap:
        ;incbin "./data/map/bg3testmap.gfx"
    .pal:
        ;incbin "./data/pal/bg3.pal"
}