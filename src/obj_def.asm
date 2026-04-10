.door: {
    ;first object written is for initiating room transitions
    ;wrote object system 4.5.26 and this along with it
    ;tested, working
    
    db $02, $02         ;x, y radii
    dw obj_door_init    ;\
    dw obj_door_main    ; routine pointers
    dw obj_door_touch   ;/
    dw obj_door_draw    ;draw instruction ptr
    
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
    
    ..draw: {
        db $04                      ;number of tiles to draw
        db $00, $00 : dw $4234      ;x,y relative to object tile; tile to draw
        db $ff, $ff : dw $8234      ;x,y relative to object tile; tile to draw
        db $00, $ff : dw $0234      ;x,y relative to object tile; tile to draw
        db $ff, $00 : dw $c234      ;x,y relative to object tile; tile to draw
        
    }
}


.solid: {
    db $01, $01         ;x, y radii
    dw ..init           ;\
    dw ..main           ; routine pointers
    dw ..touch          ;/
    dw ..draw           ;draw instruction ptr
    
    ..init: {
        ;
        rts
    }
    
    ..main: {
        ;
        rts
    }
    
    ..touch: {
        lda #!collision_type_solid
        sta w_player_collisiontype
        
        rts
    }
    
    ..draw: {
        db $01
        db $00, $00 : dw $0234
    }
}


.texttrigger: {
    db $02, $02         ;x, y radii
    dw ..init           ;\
    dw ..main           ; routine pointers
    dw ..touch          ;/
    dw ..draw           ;draw instruction ptr
    
    ;var1   
    ;var2   text starting line
    ;var3   text string pointer
    
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
        
        lda w_obj_var2,x        ;var2 = text starting line
        tay
        lda w_obj_var3,x        ;var3 = text string pointer
        tax
        jsl msg_display         ;call message box
        
        lda #$0001
        sta w_msg_uploadflag
        
        plx
        
        jsr obj_clear           ;delete
        rts
    }
    
    ..draw: {
        db $01
        db $00, $00 : dw $0234
    }
}