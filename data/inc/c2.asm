;===========================================================================================
;========================================== TEST ===========================================
;=============================== GRAPHICS, TILEMAP, PALETTES ===============================
;===========================================================================================


pillar_room: {
    .pal:   incbin "./data/pal/pillar_room.pal"
    .gfx:   incbin "./data/gfx/pillar_room.gfx"
    .map:   incbin "./data/map/pillar_room.map"
    
    .props:
        dw $ffff
}

meetsisters: {
    .pal:   incbin "./data/pal/meetsisters.pal"
    .gfx:   incbin "./data/gfx/meetsisters.gfx"
    .map:   incbin "./data/map/meetsisters.map"
    
    
    .props:
        ;gameplay aspects of this scene
        dw $ffff
}
