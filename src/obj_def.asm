.door: {
    ;first object written is for initiating room transitions
    ;wrote object system 4.5.26 and this along with it
    ;tested, working
    
    db $10, $10         ;x, y radii
    dw obj_door_init    ;\
    dw obj_door_main    ; routine pointers
    dw obj_door_touch   ;/
    
    ..init: {
        ;runs once when object is spawned
        rts
    }
    
    ..main: {
        ;runs once per frame in main gameplay
        rts
    }
    
    ..touch: {
        ;runs when player overlaps object
        phx
        
        lda w_obj_roomptr,x         ;get scene pointer
        tax
        jsr scenetransition         ;populate scene area of memory
        
        lda w_scene_mode            ;transition to program state
        sta w_programstate          ;indicated by scene data (either loadscene or loadgame)
        
        jsr fadeout
        
        plx
        rts
    }
}
