
errhandle: {
    rti
}


irq: {
    rep #$30
    phb
    pha
    phx
    phy
    
    lda $4211               ;acknowledge interrupt
    
    jml .setbank            ;maybe not necessary if this is short enough
    .setbank:
    
    lda w_irq_command
    beq +
    
    asl
    tax
    jsr (irq_commandlist,x)
    
    +
    ply
    plx
    pla
    plb
    rti
    
    .commandlist: {
        dw $0000            ;0
        dw irq_playerline   ;1
    }
    
    .settarget: {
        ;maybe we don't need this
        ;the only interrupt we're writing has a variable v target!
        
        phk
        plb
        
        phx
        
        lda w_irq_command
        asl
        tax
        
        lda irq_settarget_htable,x
        sta $4207
        
        lda irq_settarget_vtable,x
        sta $4209
        
        plx
        rts
        
        ..htable: {
            dw $0000    ;0
            dw $0040    ;1
        }
        
        ..vtable: {
            dw $0000    ;0
            dw $0080    ;1
        }
    }
    
    .playerlinebuildcolorlist: {
        php
        
        pea $7e7e
        plb
        plb
        
        sep #$10
        
        lda w_nmicounter
        and #$00ff
        tax
        
        ldy #$0080
        
        {
            -
            lda.l cgblastcolors,x
            sta.w w_cgblastbuffer,y
            
            dex
            dex
            dey
            dey
            bpl -
        }
        
        plp
        rts
    }
    
    .setupplayerline: {
        cli
        
        lda w_player_y_onscreen
        inc
        inc
        sta w_irq_vtarget
        sta $4209
        
        lda #$0050
        sta w_irq_htarget
        sta $4207
        
        sep #$20
        {
            lda w_nmitimen
            ora #%00110000      ;enable h and v for irq
            sta w_nmitimen
        }
        rep #$20
        
        lda #!irq_playerline
        sta w_irq_command
        
        rts
    }
    
    .updateplayerline: {
        ;huh
        
        rts
    }
    
    .playerline: {
        
        sep #$10
        
        ldx #$a0                    ;1      cgadd
        stx $2121
        
        ldx #%00000010              ;1      transfur mode: write twice
        stx $4300
        stx $4310
        
        ldx #$22                    ;1      register dest (cgram write)
        stx $4301
        stx $4311
        
        lda w_nmicounter
        asl
        and #$007e
        ora #cgblastcolors          ;2      source addr
        sta $4302
        
        lda #black
        sta $4312
        
        ldx #$c1                    ;1      source bank
        stx $4304
        
        ldx #$c1
        stx $4314
        
        lda #$0080                  ;2      transfur size
        sta $4305
        
        lda #$0002
        sta $4315
        
        ldx #$03                    ;1      enable transfur on dma channels 0+1
        stx $420b
        
        rep #$10
        
        rts
    }
}


;===========================================================================================
;===================================                   =====================================
;===================================    N    M    I    =====================================
;===================================                   =====================================
;===========================================================================================


nmi: {
    phb
    pha
    phx
    phy
    
    phk
    plb
    
    jml .setbank
    .setbank:
    
    sep #$10
    {
        ldx $4210
        ldx w_nmiflag
    }
    rep #$10
    beq .lag
    
    ;nmi stuf goez here
    ;todo: ppu register buffers
    
    jsr colorbufferupload
    jsr readcontroller
    jsr nmippuregisters
    jsl oam_uploadbuffer
    jsl load_updatelevelscreen
    ;jsl hdma_nmihandler         ;unfinished
    
    lda w_msg_uploadflag
    beq +
    jsr bg3upload
    +
    
    stz w_nmiflag
    
    .return
    ply
    plx
    pla
    plb
    inc w_nmicounter
    rti
    
    .lag
    inc w_lagcounter
    bra .return
}


bg3upload: {
    jsl msg_upload
    stz w_msg_uploadflag
    rts
}


nmippuregisters: {
    sep #$20
    {
        lda w_nmitimen
        sta $4200
        
        lda w_screenbrightness      ;update inidisp
        sta $2100
        
        lda w_bg1xscroll
        sta $210d
        lda w_bg1xscroll+1
        sta $210d
        
        lda w_bg1yscroll
        sta $210e
        lda w_bg1yscroll+1
        sta $210e
        
        lda w_bg2xscroll
        sta $210f
        lda w_bg2xscroll+1
        sta $210f
        
        lda w_bg2yscroll
        sta $2110
        lda w_bg2yscroll+1
        sta $2110
        
        lda w_bg3xscroll
        sta $2111
        lda w_bg3xscroll+1
        sta $2111
        
        lda w_bg3yscroll
        sta $2112
        lda w_bg3yscroll+1
        sta $2112
        
        lda w_mainscreenlayers
        sta $212c
        
        lda w_subscreenlayers
        sta $212d
        
        lda w_colormathlayers
        sta $2131
        
        lda w_colormathlogic
        sta $2130
        
    }
    rep #$20
    
    rts
}


colorbufferupload: {
    ;inline all this and do not use the thing in dma.asm
    ;for fasterness
    
    rep #$20
    sep #$10                                ;width  register
    
    ldx #$00                                ;1      cgadd
    stx $2121
    
    ldx #$02                                ;1      transfur mode: write twice
    stx $4300
    
    ldx #$22                                ;1      register dest (cgram write)
    stx $4301
    
    lda.w #w_cgrambuffer                    ;2      source addr
    sta $4302
    
    ldx.b #((w_cgrambuffer&$ff0000)>>16)+0  ;1      source bank
    stx $4304
    
    lda.w #!k_cgrambuffersize               ;2      transfur size
    sta $4305
    
    ldx #$01                                ;1      enable transfur on dma channel 0
    stx $420b
    
    rep #$10
    
    rts
}


readcontroller: {
    php
    sep #$20
    lda #$81            ;enable controller read
    sta $4200
    waitforread:
    lda $4212
    bit #$01
    bne waitforread
    rep #$20
    
    lda $4218           ;store to wram
    sta w_controller
    plp
    rts
}

;print pc, " wait for nmi"
waitfornmi: {
    php
    sep #$20
    lda #$01
    sta w_nmiflag
    rep #$20
    
    ;lda !showcpuflag
    ;beq +
    ;jsr debug_showcpu
    ;+
    
    .waitloop: {
        lda w_nmiflag
    } : bne .waitloop
    plp
    rts
    
    .long: {
        jsr waitfornmi
        rtl
    }
}


screenon: {         ;turn screen brightness on and disable forced blank
    pha
    sep #$20
    lda w_screenbrightness
    and #$7f
    ora #$0f
    sta $2100
    sta w_screenbrightness
    rep #$20
    pla
    rts
    
    .long: {
        jsr screenon
        rtl
    }
}


screenoff: {        ;enable forced blank
    pha
    sep #$20
    lda w_screenbrightness
    ora #$80
    sta $2100
    sta w_screenbrightness
    rep #$20
    pla
    rts
    
    .long: {
        jsr screenoff
        rtl
    }
}


disablenmi: {
    sep #$20
    stz $4200
    rep #$20
    rts
    
    .long: {
        jsr disablenmi
        rtl
    }
}


enablenmi: {
    sep #$20
    lda #$80
    sta $4200
    rep #$20
    rts
    
    .long: {
        jsr enablenmi
        rtl
    }
}