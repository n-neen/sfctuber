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
    
    jsl hdma_clearall
    
    
    
    ldy.w #hdma_testobject_inidisp
    ldx #$0002
    jsl hdma_spawn
    
    ldy.w #hdma_testobject_coldata
    ldx #$0004
    jsl hdma_spawn
    
    
    
    jsr screenon
    
    lda #!state_gameloop
    sta w_programstate
    
    rts
}


gameloop: {
    
    ;todo
    
    jsl hdma_top
    
    ;lda w_controller
    
    lda.w #$3038
    sta $7ec000
    
    rts
}