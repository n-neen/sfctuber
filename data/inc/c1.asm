;===========================================================================================
;========================================== TEST ===========================================
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
    .pal:   incbin "./data/pal/blood_lotus.pal"
    .gfx:   incbin "./data/gfx/blood_lotus.gfx"
    .map:   incbin "./data/map/blood_lotus.map"
    
    
    .props:
        ;gameplay aspects of this scene
        dw $ffff
}