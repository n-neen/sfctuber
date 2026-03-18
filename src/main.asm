main: {
    phk
    plb
    
    lda w_prestate
    beq +
    asl
    tax
    
    jsr (main_prestatetable,x)
    
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
    
    .prestatetable: {
        dw pre_none         ;0: none
        dw pre_startfade    ;1
        dw pre_fadeout      ;2
        dw pre_fadein       ;3
        dw pre_fadedone     ;4
    }
}

scenetransition: {
    ;populate scene area of memory
    
    ;arguments:
    ;x = scene pointer in scenedef bank
    
    phb
    
    pea.w (($ff0000&scenedef)>>8)+0         ;db = scene def bank (7e)
    plb
    plb
    
    lda $0000,x
    sta.l w_scene_definitionptr
    
    lda $0002,x
    and #$00ff
    sta.l w_scene_bank
    
    lda $0003,x
    sta.l w_scene_palptr
    
    lda $0005,x
    sta.l w_scene_gfxptr
    
    lda $0007,x
    sta.l w_scene_mapptr
    
    lda $0009,x
    sta.l w_scene_gfxsize
    
    lda $0011,x
    sta.l w_scene_gameprops
    
    plb
    rts
}

loadscene: {
    jsl load_scene
    rts
}


pre: {
    ;handle fading screen brightness as its own thread prior to
    ;main state handler
    
    ;unimplemented
    
    .none: {
        rts
    }
    
    .startfade: {
        ;arguments:
        ;a = initial timer value
        ;x = fade bitmask to check nmi counter
        ;y = main state to enter when done
        
        ;untested 3.15.26
        
        sta w_fadecounter
        stx w_fadebitmask
        sty w_fadenextstate
        
        lda #!pre_state_out
        sta w_prestate
        
        rts
    }
    
    
    .fadeout: {
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
    
    .fadein: {
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
    
    .fadedone: {
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
    
    
    ;ldy.w #hdma_testobject_inidisp
    ;ldx #$0002
    ;jsl hdma_spawn
    
    ;ldy.w #hdma_testobject_coldata
    ;ldx #$0004
    ;jsl hdma_spawn
    
    ;ldy.w #hdma_testobject_coldata_indirect
    ;ldx #$0006
    ;jsl hdma_spawn
    
    stz w_hdma_enable
    
    ;ldx.w #scenedef_meetsisters
    ldx.w #scenedef_blood_lotus
    ;ldx.w #scenedef_light
    
    jsr scenetransition         ;testing, populate pointers in scene ram
    
    jsr enablenmi
    jsr waitfornmi
    jsr screenon
    
    ;ldy.w #hdma_testobject_inidisp
    ;ldx #$0002
    ;jsl hdma_spawn
    
    ;lda #$0001
    ;sta w_hdma_enable
    
    lda #!state_loadscene       ;program state = load scene
    sta w_programstate
    
    rts
}


gameloop: {
    ;todo
    
    jsl hdma_top
    
    rts
}