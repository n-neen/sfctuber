
boot: {
    sei
    clc
    xce             ;enable native mode
    jml .setbank    ;set bank
    .setbank:
    
    sep #$20
    lda #$01
    sta $420d       ;enable fastrom
    rep #$30
    
    ldx #$1fff
    txs             ;set initial stack pointer
    lda #$0000
    tcd             ;clear dp register
    
    ldy #$0000      ;lmaoooo
    ldx #$0000
    
    
    ;fall through
}

init: {

    .clear7e: {
        pea $7e7e
        plb : plb
        
        ldx #$1ffe
        
        -
        stz $0000,x
        stz $1000,x
        stz $2000,x
        stz $3000,x
        stz $4000,x
        stz $5000,x
        stz $6000,x
        stz $7000,x
        stz $8000,x
        stz $9000,x
        stz $a000,x
        stz $b000,x
        stz $c000,x
        stz $d000,x
        stz $e000,x
        
        dex : dex
        bpl -
    }

    .clear7f: {
        pea $7f7f
        plb : plb
        
        ldx #$1ffe
        
        -
        stz $0000,x
        stz $1000,x
        stz $2000,x
        stz $3000,x
        stz $4000,x
        stz $5000,x
        stz $6000,x
        stz $7000,x
        stz $8000,x
        stz $9000,x
        stz $a000,x
        stz $b000,x
        stz $c000,x
        stz $d000,x
        stz $e000,x
        
        dex : dex
        bpl -
    }
    
    .registers: {
        
        phk
        plb                 ;set db
        
        sep #$30
        lda #$8f
        sta $2100           ;enable forced blank
        lda #$01
        sta $4200           ;enable joypad autoread
        rep #$30
        
        
        ldx #$000a
-       stz $4200,x         ;clear registers $4200-$420b
        dex : dex
        bne - 
        
        ldx #$0082          ;clear registers $2101-2183
--      stz $2101,x
        dex : dex
        bne --
        
        sep #$20
        
        lda #$80            ;enable nmi
        sta $4200
        
        sta $2100           ;enable forced blank
        
        rep #$20
        
    }
    
    
    .vram: {   
        ;clear vram
        jsl dma_clearvram
        jsl dma_clearcgram
        
    }
    
    .ppu: {
        sep #$20
        
        ;tile layer graphics base addresses
        
        lda.b #!bg1tileshifted|(!bg2tileshifted<<4)     ;bg1|2
        sta $210b
        
        lda.b #!bg3tileshifted                          ;bg3
        sta $210c
        
        ;tilemap base addresses
        
        lda.b #%00000011|(!bg1tilemapshifted<<2)
        sta $2107
        
        lda.b #%00000011|(!bg2tilemapshifted<<2)
        sta $2108
        
        lda.b #%00000011|(!bg3tilemapshifted<<2)
        sta $2109
        
        rep #$20
    }
    
    stz.w w_programstate
}

;fall through to main