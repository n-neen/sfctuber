scenedefs: {
    macro scenedefentry(label)
        dl <label>                  ;long pointer to the scene data
        dw <label>_pal              ;inbank pointer to palette
        dw <label>_gfx              ;graphics
        dw <label>_map              ;tilemap
        dw datasize(<label>_gfx)    ;graphics size
        dw <label>_props            ;gameplay properties
    endmacro
    
    
    
    .light: %scenedefentry(light)
    
    
    
}