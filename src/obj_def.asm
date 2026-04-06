.door: {
    ;first object written is for initiating room transitions
    ;wrote object system 4.5.26 and this along with it
    ;tested, working
    
    db $02, $02         ;x, y radii
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
        
        lda w_obj_var3,x            ;get scene pointer
        tax
        jsr scenetransition         ;populate scene area of memory
        
        lda w_scene_mode            ;transition to program state
        sta w_programstate          ;indicated by scene data (either loadscene or loadgame)
        
        jsr fadeout
        
        plx
        rts
    }
}


.texttrigger: {
    db $02, $02         ;x, y radii
    dw ..init           ;\
    dw ..main           ; routine pointers
    dw ..touch          ;/
    
    ..init: {
        rts
    }
    
    ..main: {
        rts
    }
    
    ..touch: {
        ;x = obj index
        
        phx
        
        jsl layer3on_long
        stz w_bg3yscroll
        
        lda w_obj_var3,x
        tax
        jsr msg_writetilemap
        
        lda #$0001
        sta w_msg_uploadflag
        
        plx
        
        jsr obj_clear
        rts
    }
}