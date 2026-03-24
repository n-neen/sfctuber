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
    
    .prestatetable: {
        dw pre_none         ;0: none
        dw pre_startfade    ;1
        dw pre_fadeout      ;2
        dw pre_fadein       ;3
        dw pre_fadedone     ;4
    }
    
    .table: {
        dw setup            ;0
        dw gameloop         ;1
        dw loadscene        ;2
        dw scenehandler     ;3
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
    
    lda $000b,x
    sta.l w_scene_tilemapsize
    
    lda $000d,x
    sta.l w_scene_gameprops
    
    plb
    rts
}


loadscene: {
    jsl load_scene
    
    lda #$0020
    ldx #$0003
    ldy #!state_gameloop
    jsr pre_startfade_in
    
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
        
        ..in:
        sta w_fadecounter
        
        lda #!pre_state_in
        sta w_prestate
        bra +
        
        ..out:
        sta w_fadecounter
        
        lda #!pre_state_out
        sta w_prestate
        
        +
        
        stx w_fadebitmask
        sty w_fadenextstate
        
        
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
            
            stz w_prestate
            
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
            
            stz w_prestate
            
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
    
    stz w_hdma_enable
    
    ldx.w #scenedef_meetsisters
    
    jsr scenetransition         ;testing, populate pointers in scene ram
    
    ;temp test not real
    
    jsl load_bg3colortobuffer       ;bg3 palette
    jsl load_bg3tilemaptobuffer     ;tilemap copy to buffer
    jsl load_bg3tilemapupload       ;upload buffer
    jsl load_bg3tilesupload         ;bg3 tiles to vram
    jsl load_playerpal
    jsl load_playergfx
    
    jsr enablenmi
    jsr waitfornmi
    jsr screenon
    
    lda #!state_loadscene       ;program state = load scene
    sta w_programstate
    
    rts
}


scenehandler: {
    rts
}


gameloop: {
    ;todo
    
    jsl hdma_top
    
    
    
    ;testing
    
    lda w_controller
    bit #$8000
    beq ++
    
    ;initiate scene change
    
    {
        lda w_prestate
        bne ++
        
        lda #$0015              ;fade counter
        ldx #$0003              ;fade bitmask (interval)
        ldy #!state_loadscene   ;next state after fade
        jsr pre_startfade_out   ;set parameters for prestate: fadeout
        
        lda w_testsceneindex
        inc
        cmp #$0004
        bne +
        
        stz w_testsceneindex
        lda #$0000
        
        +
        sta w_testsceneindex
        asl
        tax
        lda.l gameloop_testtable,x
        tax
        jsr scenetransition
    }
    
    ++
    
    lda w_controller        ;up
    bit #$0800
    beq +
    dec w_bg1yscroll
    +
    
    bit #$0400              ;down
    beq +
    inc w_bg1yscroll
    +
    
    bit #$0200              ;left
    beq +
    dec w_bg1xscroll
    +
    
    bit #$0100              ;right
    beq +
    inc w_bg1xscroll
    +
    
    rts
    
    
    .testtable: {
        dw scenedef_meetsisters,        ;0
           scenedef_bloodlotus,         ;1
           scenedef_light,              ;2
           scenedef_leveltest           ;3
    }
}