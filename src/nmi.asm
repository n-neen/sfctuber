
errhandle: {
    rti
}


irq: {
    rti
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
    
    jsr readcontroller
    jsr colorbufferupload
    
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