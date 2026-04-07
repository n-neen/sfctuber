main: {
    phk
    plb
    
    ;lda w_prestate
    ;beq +
    ;asl
    ;tax
    ;
    ;jsr (main_prestatetable,x)
    ;
    ;+
    lda w_programstate
    asl
    tax
    
    jsr (main_table,x)
    
    jsr waitfornmi
    
    jmp main
    
    .prestatetable: {
        dw pre_none         ;0: none yet
        dw pre_msg          ;1
    }
    
    .table: {
        dw setup            ;0
        dw scenehandler     ;1
        dw loadscene        ;2
        dw gameplayvector   ;3
        dw loadgame         ;4
    }
}


pre: {
    ;unimplemented
    
    .none: {
        ;todo
        
        rts
    }
    
    .msg: {
        jsl msg_display
        
        rts
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
    
    tax
    
    ;scene dialogue/gameplay properties
    
    lda $0000,x
    sta.l w_scene_mode
    
    cmp #!state_loadscene
    beq .notgameplay
    
    .gameplay:                  ;else, gameplay
    
    lda $0002,x
    sta.l w_level_camerastartx
    
    lda $0004,x
    sta.l w_level_camerastarty
    
    lda $0006,x
    sta.l w_level_playerstartx
    
    lda $0008,x
    sta.l w_level_playerstarty
    
    lda $000a,x
    sta.l w_level_objlist
    
    plb
    rts
    
    .notgameplay:
    
    lda $0002,x
    sta.l w_scene_strptr       ;eventually, script (list of text pointers)
    
    lda $0004,x
    and #$00ff
    sta.l w_scene_strline       ;what line to start text on
    
    plb
    rts
}


loadscene: {
    jsr waitfornmi
    jsr screenoff
    jsr disablenmi
    
    stz w_scene_timer
    
    jsl load_scene
    
    lda #!state_scenehandler
    sta w_programstate
    
    jsr layer3on
    
    jsr waitfornmi
    jsr fadein
    
    rts
}


layer3on: {
    sep #$20
    lda w_mainscreenlayers
    ora #%00000100
    sta w_mainscreenlayers
    rep #$20
    
    rts
    
    .long: {
        jsr layer3on
        rtl
    }
}


layer3off: {
    sep #$20
    lda w_mainscreenlayers
    and #%11111011
    sta w_mainscreenlayers
    rep #$20
    
    rts
    
    .long: {
        jsr layer3off
        rtl
    }
}


setup: {
    ;initial setup for loading graphics, tilemaps
    
    jsr waitfornmi
    jsr screenoff
    
    ;load graphics, palette, tilemap
    
    stz w_prestate
    
    jsl hdma_clearall
    jsl glow_clearall
    
    stz w_hdma_enable
    stz w_glow_enable
    
    lda #!fade_bitmask_default
    sta w_fadebitmask
    
    lda #!fade_timer_default
    sta w_fadetimer
    
    lda #!camera_subspeed_default
    sta w_scroll_camerasubspeed
    
    lda #!camera_speed_default
    sta w_scroll_cameraspeed
    
    ldx.w #scenedef_meetsisters
    jsr scenetransition         ;testing, populate pointers in scene ram
    
    ;temp test not real
    
    jsl load_bg3colortobuffer       ;bg3 palette
    jsl load_bg3tilemaptobuffer     ;tilemap copy to buffer
    jsl load_bg3tilemapupload       ;upload buffer
    jsl load_bg3tilesupload         ;bg3 tiles to vram
    jsl load_playerpal
    jsl load_playergfx
    
    jsl obj_clearall
    
    ;ldy #glow_test
    ;jsl glow_spawn
    
    jsr enablenmi
    jsr waitfornmi
    jsr screenon
    
    lda #!state_loadscene       ;program state = load scene
    sta w_programstate
    
    rts
}


gameplayvector: {
    
    jsl gameplay
    
    rts
}


scenehandler: {
    lda w_scene_timer
    bne +
    {
        stz w_bg3yscroll
        jsr layer3on
        
        ldx w_scene_strptr
        ldy w_scene_strline
        jsl msg_display
        
        lda #$0001
        sta w_scene_timer
    }
    +
    
    
    lda w_controller
    beq .return
    {
        lda w_testsceneindex
        inc
        sta w_testsceneindex            ;advance scene index
        
        lda w_testsceneindex
        asl
        tax
        lda.l scenehandler_testtable,x
        tax
        jsr scenetransition             ;initiate scene change
        
        lda w_scene_mode
        sta w_programstate
        
        jsr fadeout
        jsl msg_reset
    }
    .return:
    rts
    
    
    .testtable: {
        dw scenedef_meetsisters,        ;0
           scenedef_bloodlotus,         ;1
           scenedef_flamecircle,        ;2
           scenedef_room1,              ;3
           scenedef_room2               ;4
    }
}


loadgame: {
    jsr disablenmi
    jsr screenoff
    
    jsl load_scene
    
    jsl obj_clearall
    
    ;initialize scroll
    stz w_scroll_direction
    
    lda #!scroll_upbound_default
    sta w_scroll_upbound
    
    lda #!scroll_downbound_default
    sta w_scroll_downbound
    
    lda #!scroll_leftbound_default
    sta w_scroll_leftbound
    
    lda #!scroll_rightbound_default
    sta w_scroll_rightbound
    
    jsr layer3off
    jsl msg_cleartilemap
    lda #$0001
    sta w_msg_uploadflag
    lda #$0800
    sta w_msg_size
    
    jsl player_init
    
    sep #$20
    lda w_mainscreenlayers
    ora #%00010000
    sta w_mainscreenlayers
    rep #$20
    
    lda w_level_camerastartx
    sta w_level_camerax
    sta w_bg1xscroll
    
    lda w_level_camerastarty
    sta w_level_cameray
    sta w_bg1yscroll
    
    jsl obj_spawnall
    jsl obj_runinit
    jsl obj_drawall
    
    jsl player_main
    jsl scroll_main
    
    jsl oam_uploadbuffer
    
    jsr enablenmi
    jsr waitfornmi
    jsr fadein
    jsr screenon
    
    lda #!state_gameplay
    sta w_programstate
    
    rts
}


fadeout: {
    ;screen must be ON when this is called
    
    jsr enablenmi
    jsr screenon        ;in fact just do this to be sure
    
    -
    jsr waitfornmi
    
    lda w_nmicounter
    bit w_fadebitmask
    beq -
    
    lda w_screenbrightness
    dec
    sta w_screenbrightness
    bne -
    
    jsr screenoff
    rts
}


fadein: {
    jsr enablenmi
    stz w_screenbrightness
    
    -
    jsr waitfornmi
    
    lda w_nmicounter
    bit w_fadebitmask
    beq -
    
    lda w_screenbrightness
    inc
    sta w_screenbrightness
    cmp #$000f
    bne -
    
    ;returns with screen brightness = $0f
    jsr screenon
    rts
}