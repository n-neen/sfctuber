
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
        
        lda.b #!spritegfxshifted>>1
        sta $2101
        
        ;tilemap base addresses
        
        lda.b #%00000011|(!bg1tilemapshifted<<2)
        sta $2107
        
        lda.b #%00000000|(!bg2tilemapshifted<<2)
        sta $2108
        
        lda.b #%00000010|(!bg3tilemapshifted<<2)
        sta $2109
        
        lda.b #%00001001    ;drawing mode: 1 with bg3 priority
        sta $2105
        
        lda #%00000000      ;color math layers
        sta $2131
    
        lda #%00000101      ;main screen layers
        sta $212c
        
        lda #%00000000
        sta $212d
        
        ;gotta set the bg scroll to -1 because of course we do
        lda #$ff
        stz $210d       ;bg1 x scroll
        stz $210d
        
        sta $210e       ;bg1 y scroll
        sta $210e
        
        stz $210f       ;bg2 x scroll
        stz $210f
        
        sta $2110       ;bg2 y scroll
        sta $2110
        
        stz $2111       ;bg3 x scroll
        stz $2111
        
        lda #$ff
        sta $2112       ;bg3 vertical scroll
        lda #$80
        sta $2112
        
        rep #$20
        
    }
    
    lda #$ffff
    sta w_bg1yscroll
    sta w_bg2yscroll
    
    lda #$ff80
    sta w_bg3yscroll
    
    stz w_bg1xscroll
    stz w_bg2xscroll
    stz w_bg3xscroll
    
    ;lda #$0000
    ;jsl $80e278
    ;jsl $80e0bd             ;sound test. no work
    
    
    stz.w w_programstate
    stz.w w_prestate
}

;fall through to main