
scenedef: {
    macro scenedefentry(label)
        dl <label>                  ;long pointer to the scene data ;0
        dw <label>_pal              ;inbank pointer to palette,     ;3
        dw <label>_gfx              ;graphics,                      ;5
        dw <label>_map              ;tilemap                        ;7
        dw datasize(<label>_gfx)    ;graphics size                  ;9
        dw datasize(<label>_map)    ;tilemap size                   ;b
        dw properties_<label>       ;gameplay properties            ;d
    endmacro
    
    ;list of scenes
    
    ;run superfamiconv to output every scene using at most the bottom 7 palettes
    ;of bg palette area. reserve top 16 colors for bg3!
    ;the routine load_romtocolorbuffer will start at the second palette
    .leveltest:         %scenedefentry(leveltest)           ;unused
    
    
    .light:             %scenedefentry(light)               ;unused
    .meetsisters:       %scenedefentry(meetsisters)
    .bloodlotus:        %scenedefentry(bloodlotus)
    .flamecircle:       %scenedefentry(flamecircle)
    .city:              %scenedefentry(city)
    
    
    .room1:             %scenedefentry(room1)
    .room2:             %scenedefentry(room2)
}


properties: {
    ;if a scene is a dialogue screen, we need to point at the text scripts
    ;if a scene is a gameplay room, we need gameplay data
    .light: {
        dw !state_loadscene
    }
    
    .meetsisters: {                 ;intro 1
        dw !state_loadscene         ;program state to enter
        dw str_intro1               ;text string pointer
        db $08                      ;starting line for text
        dw hdma_testobject_inidisp  ;hdma object to spawn and run
    }
    
    .bloodlotus: {                  ;intro 2
        dw !state_loadscene
        dw str_intro2
        db $16
        dw $0000                    ;hdma object to spawn and run
    }
    
    .flamecircle: {                 ;intro 3
        dw !state_loadscene
        dw str_intro3
        db $18
        dw $0000                    ;hdma object to spawn and run
    }
    
    .city: {
        dw !state_loadscene
        dw str_intro4
        db $04
        dw $0000                    ;hdma object to spawn and run
    }
    
    .leveltest: {                   ;unused
        dw !state_loadgame
        db $10
        dw $0000                    ;hdma object to spawn and run
    }
    
    .room1: {                           ;description                ;number of bytes in
        dw !state_loadgame              ;program mode to use        ;0
        dw $0001, $0001                 ;starting camera position   ;2,4
        dw $0028, $0058                 ;starting player position   ;6,8
        dw objlist_room1                ;object list pointer        ;a
        ;dw spritelist_room1            ;unimplemented              ;c
    }
    
    .room2: {
        dw !state_loadgame              ;program mode to use
        dw $0100, $0000                 ;starting camera position x,y
        dw $01e0, $0080                 ;starting player position x,y
        dw objlist_room2                ;object list pointer
        ;dw spritelist_room1            ;unimplemented
    }
}