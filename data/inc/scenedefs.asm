
scenedef: {
    macro scenedefentry(label)
        dl <label>                  ;long pointer to the scene data ;0
        dw <label>_pal              ;inbank pointer to palette,     ;3
        dw <label>_gfx              ;graphics,                      ;5
        dw <label>_map              ;tilemap                        ;7
        dw datasize(<label>_gfx)    ;graphics size                  ;9
        dw <label>_props            ;gameplay properties            ;11
    endmacro
    
    
    
    .light:             %scenedefentry(light)
    .meetsisters:       %scenedefentry(meetsisters)
    .blood_lotus:       %scenedefentry(blood_lotus)
    
}