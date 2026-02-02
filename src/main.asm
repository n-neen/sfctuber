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
        dw setup
    }
}

setup: {
    ;initial setup for loading graphics, tilemaps
    
    
    
    rts
}