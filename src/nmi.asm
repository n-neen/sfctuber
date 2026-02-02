
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
    ldx $4210
    ldx w_nmiflag
    rep #$10
    beq .lag
    
    ;nmi stuf goez here
    
    sep #$20
    lda w_screenbrightness
    sta $2100
    rep #$20
    
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