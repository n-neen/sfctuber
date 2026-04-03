main: {
    phk
    plb
    
    ;lda w_prestate
    ;beq +
    ;asl
    ;tax
    
    ;jsr (main_prestatetable,x)
    
    ;+
    lda w_programstate
    asl
    tax
    
    jsr (main_table,x)
    
    jsr waitfornmi
    
    jmp main
    
    .prestatetable: {
        dw pre_none         ;0: none yet
    }
    
    .table: {
        dw setup            ;0
        dw scenehandler     ;1
        dw loadscene        ;2
        dw gameplay         ;3
        dw loadgame         ;4
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
    
    lda $0002,x
    sta.l w_level_camerastartx
    
    lda $0004,x
    sta.l w_level_camerastarty
    
    lda $0006,x
    sta.l w_level_playerstartx
    
    lda $0008,x
    sta.l w_level_playerstarty
    
    plb
    rts
}


loadscene: {
    jsr waitfornmi
    jsr screenoff
    jsr disablenmi
    
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
}


layer3off: {
    sep #$20
    lda w_mainscreenlayers
    and #%11111011
    sta w_mainscreenlayers
    rep #$20
    
    rts
}


pre: {
    ;unimplemented
    
    .none: {
        ;todo
        
        rts
    }
}


setup: {
    ;initial setup for loading graphics, tilemaps
    
    jsr waitfornmi
    jsr screenoff
    
    ;load graphics, palette, tilemap
    
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
    
    ;ldy #glow_test
    ;jsl glow_spawn
    
    jsr enablenmi
    jsr waitfornmi
    jsr screenon
    
    lda #!state_loadscene       ;program state = load scene
    sta w_programstate
    
    rts
}


gameplay: {
    stz w_player_direction
    stz w_scroll_direction
    
    jsl player_main
    jsl scroll_main
    
    ;game goes here
    
    lda w_controller
    bit #!controller_x
    beq +
    
    ;test room change
    
    ldx #scenedef_room2         ;get scene pointer
    jsr scenetransition         ;populate scene area of memory
    
    lda w_scene_mode            ;transition to program state
    sta w_programstate          ;indicated by scene data (either loadscene or loadgame)
    
    jsr fadeout
    
    +
    
    rts
}


scenehandler: {
    ;todo
    
    ;jsl hdma_top
    ;jsl glow_top
    
    lda w_controller
    beq .return
    
    ;initiate scene change
    
    lda w_testsceneindex
    inc
    sta w_testsceneindex
    
    lda w_testsceneindex
    asl
    tax
    lda.l scenehandler_testtable,x
    tax
    jsr scenetransition
    
    lda w_scene_mode
    sta w_programstate
    
    jsr fadeout
    
    .return:
    rts
    
    
    .testtable: {
        dw scenedef_meetsisters,        ;0
           scenedef_bloodlotus,         ;1
           scenedef_light,              ;2
           scenedef_room1,              ;3
           scenedef_room2               ;4
    }
}


loadgame: {
    ;presumably something happens here
    ;but right now this is a reserved state
    
    jsr enablenmi
    jsr screenoff
    
    jsl load_scene
    
    ;do thing here
    
    ;initialize scroll bounds
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
    
    
    ;this should fix stale player onscreen position at the start
    ;of gameplay, but it doesn't
    
    jsl player_main
    jsl scroll_main
    
    
    jsl oam_uploadbuffer
    
    jsr waitfornmi
    jsr fadein
    
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