gameplay: {
    ;there's a problem with fadeout and fadein leaving
    ;screen brightness in a bad place
    ;maybe only happens on snes9x?!
    ;todo fix that
    ;ok i can't reproduce it anymore, no idea lol
    ;this bug seems to be permanently gone but
    ;i can't recall actually understanding how it worked
    ;or deliberately fixing it
    
    
    stz w_player_direction
    stz w_scroll_direction
    
    jsl obj_runmain
    jsl obj_collision
    
    jsl player_main
    jsl scroll_main
    
    ;game goes here
    
    lda w_controller
    bit #!controller_a      ;push A: clear text
    beq +
    
    {   ;reset dialog prototype
        stz w_msg_size
        jsl msg_cleartilemap
        jsl layer3off_long
    }
    +
    
    lda w_controller
    bit #!controller_st      ;push start: screen update test
    beq +
    
    {   ;screen update test
        ;lda #!obj_flag_update_screen0
        ;lda #$000f
        ;sta w_obj_screenupdates
        
        ldx #!obj_count*2
        jsl obj_draw
        
    }
    +
    
    
    
    rtl
}