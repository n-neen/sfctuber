
scenedef: {
    macro scenedefentry(label)
        dl <label>                  ;long pointer to the scene data ;0
        dw <label>_pal              ;inbank pointer to palette,     ;3
        dw <label>_gfx              ;graphics,                      ;5
        dw <label>_map              ;tilemap                        ;7
        dw datasize(<label>_gfx)    ;graphics size                  ;9
        dw <label>_props            ;gameplay properties            ;11     ;unimplemented
    endmacro
    
    ;list of scenes
    
    ;run superfamiconv to output every scene using at most the bottom 7 palettes
    ;of bg palette area. reserve top 16 colors for bg3!
    
    ;todo: run the conversion again for these three:
    
    .light:             %scenedefentry(light)
    .meetsisters:       %scenedefentry(meetsisters)
    .blood_lotus:       %scenedefentry(blood_lotus)     ;done
    
}