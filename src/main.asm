main: {
    phk
    plb
    
    lda w_programstate
    asl
    tax
    
    jsr (main_table,x)
    
    jsr waitfornmi
    
    jmp main
    
    .table: {
        dw setup            ;0
        dw gameloop         ;1
    }
}


setup: {
    ;initial setup for loading graphics, tilemaps
    
    jsr waitfornmi
    jsr screenoff
    
    ;load graphics, palette, tilemap
    
    jsr screenon
    
    lda #!state_gameloop
    sta w_programstate
    
    rts
}


gameloop: {
    
    ;todo
    
    lda w_controller
    sta $7ec000
    
    rts
}