main: {
    phk
    plb
    
    lda w_fadestate
    beq +
    asl
    tax
    
    jsr (main_fadestatetable,x)
    
    +
    lda w_programstate
    asl
    tax
    
    jsr (main_table,x)
    
    jsr waitfornmi
    
    jmp main
    
    .table: {
        dw setup            ;0
        dw gameloop         ;1
        dw loadscene        ;2
    }
    
    .fadestatetable: {
        dw fade_none        ;0: none
        dw fade_start       ;1
        dw fade_out         ;2
        dw fade_in          ;3
        dw fade_done        ;4
    }
}

loadscene: {
    ;needs forced blank already enabled from
    ;previous state
    
    
    
    rts
}

fade: {
    ;handle fading screen brightness as its own thread prior to
    ;main state handler
    
    ;unimplemented
    
    .none: {
        rts
    }
    
    .start: {
        ;arguments:
        ;a = initial timer value
        ;x = fade bitmask to check nmi counter
        ;y = main state to enter when done
        
        sta w_fadecounter
        stx w_fadebitmask
        sty w_fadenextstate
        
        lda #!fade_state_out
        sta w_fadestate
        
        rts
    }
    
    
    .out: {
        lda w_nmicounter
        bit w_fadebitmask
        bne +
        
        sep #$20
        
        lda w_screenbrightness
        beq ..proceed
        dec
        sta w_screenbrightness
        
        rep #$20
        +
        rts
        
        ..proceed: {
            rep #$20
            
            jsr waitfornmi
            jsr screenoff
            
            lda w_fadenextstate
            sta w_programstate
            
            rts
        }
        
    }
    
    .in: {
        lda w_nmicounter
        bit w_fadebitmask
        bne +
        
        sep #$20
        
        lda w_screenbrightness
        cmp #$0f
        beq ..proceed
        inc
        sta w_screenbrightness
        
        rep #$20
        +
        rts
        
        ..proceed: {
            rep #$20
            
            jsr waitfornmi
            jsr screenon
            
            lda w_fadenextstate
            sta w_programstate
            
            rts
        }
        
    }
    
    .done: {
        ;not sure this is necessary
        
        rts
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
    
    ;ldy.w #hdma_testobject_coldata
    ;ldx #$0004
    ;jsl hdma_spawn
    
    ;ldy.w #hdma_testobject_coldata_indirect
    ;ldx #$0006
    ;jsl hdma_spawn
    
    jsr waitfornmi
    jsr screenon
    
    lda #!state_gameloop
    sta w_programstate
    
    rts
}


gameloop: {
    
    ;todo
    
    jsl hdma_top
    
    lda w_nmicounter
    and #$01f0
    ora w_controller
    ora #$1000
    
    ;lda.w #$3038
    sta $7ec000
    
    rts
}