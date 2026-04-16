gameplay: {
    ;there's a problem with fadeout and fadein leaving
    ;screen brightness in a bad place
    ;maybe only happens on snes9x?!
    ;todo fix that
    ;ok i can't reproduce it anymore, no idea lol
    ;this bug seems to be permanently gone but
    ;i can't recall actually understanding how it worked
    ;or deliberately fixing it
    
    stz w_player_direction  ;direction bits = 0
    stz w_scroll_direction
    stz w_player_collisiontype
    
    ;jsr irq_playerlinebuildcolorlist
    jsr irq_setupplayerline
    
    jsl obj_runmain
    jsl obj_collision       ;removes direction bits
    
    jsl player_main         ;adds direction bits based on dpad and moves
    jsl scroll_main
    jsl scroll_bg2
    
    
    ;game goes here
    
    lda w_controller
    bit #!controller_x      ;push A: clear text
    beq +
    
    {
        jsl msg_reset
        jsl layer3off_long
    }
    +
    
    rtl
    
    
    .shadow: {
        ;stripped down gameplay to allow player to move during text
        ;but does not allow for collision
        
        
        stz w_player_direction
        stz w_scroll_direction
        
        jsl player_main
        jsl scroll_main
        
        rtl
    }
}