;===========================================================================================
;========================================= HDMA ============================================
;===========================================================================================

;hdma object:
    ;init routine   ;runs once when it is created
    ;main routine   ;runs once per frame
    ;hdma target
    ;indirect or direct
    ;table source bank
    ;(object's index in hdma system arrays)/2 is used as hdma channel
    
    ;w_hdma_params contains data to write to both $4300 and $4301
        ;ttpp
        ;p = params
        ;t = ppu target

hdma: {
    .nmihandler: {
        ;look for object slots that are occupied
        ;use the object's prarmeters to configure the hdma channel
        
        ;ok we unroll this
        
        ;print pc
        
        macro hdmachannelconfig(channel)
            !regbitmask #= (<channel>)<<4       ;obj slot 3 = bitmask $30
                                                ;mask onto hdma reg addr
            lda.w w_hdma_id+((<channel>)<<1)
            beq +++
            
            lda.w w_hdma_params+((<channel>)<<1)  ;$43x0/43x1
            sta.w $4300|!regbitmask
            
            bit.w #$0040
            beq +                               ;if indirect
            
            lda.w w_hdma_bank+((<channel>)<<1)
            and.w #$00ff
            sta.w $4305|!regbitmask
            
            lda.w w_hdma_table+((<channel>)<<1)   ;use $43x5/43x6/43x7
            sta.w $4306|!regbitmask
            
            bra ++
            
            +                                   ;if direct
            
            lda.w w_hdma_table+((<channel>)<<1)   ;use $43x2/43x3/43x4
            sta.w $4302|!regbitmask
            
            lda.w w_hdma_bank+((<channel>)<<1)
            and.w #$00ff
            sta.w $4304|!regbitmask
            
            ++
            
            lda.w #($0100)|($0001<<(<channel>))
            ora.w w_hdma_channels
            sta.w w_hdma_channels
            
            +++
        endmacro
        
        lda.w w_hdma_enable
        bne +
        
        %hdmachannelconfig(1)
        %hdmachannelconfig(2)
        %hdmachannelconfig(3)
        %hdmachannelconfig(4)
        %hdmachannelconfig(5)
        %hdmachannelconfig(6)
        %hdmachannelconfig(7)
        
        lda.w w_hdma_channels
        sta $420c
        
        +
        rtl
    }
    
    
    .top: {
        ;main routine for when gameplay is happening
        ;iterate over slots
        ;run main routine for each
        
        phk
        plb
        
        ldx.w #!k_hdma_objects_count*2
        -
        
        lda w_hdma_id,x
        beq +
        
        phx
        jsr (w_hdma_routine,x)
        plx
        
        +
        dex
        dex
        bpl -
        
        rtl
    }
    
    
    .spawn: {
        ;y = pointer to object header
        ;x = object index
        
        phb
        
        phk
        plb
        
        tya
        sta w_hdma_id,x         ;object id (pointer to header)
        
        lda $0000,y             ;object init routine
        sta w_hdma_init,x
        
        lda $0002,y             ;object main routine
        sta w_hdma_routine,x
        
        lda $0004,y             ;object table pointer
        sta w_hdma_table,x
        
        lda $0006,y             ;object table bank
        and #$00ff
        sep #$20
        sta w_hdma_bank,x
        rep #$20
        
        phx
        jsr (w_hdma_init,x)     ;run init routine
        plx
        
        plb
        rtl
    }
    
    
    .clearall: {
        phb
        
        phk
        plb
        
        ldx.w #!k_hdma_objects_count*2
        -
        
        jsr hdma_clear
        dex
        dex
        bpl -
        
        plb
        rtl
    }
    
    
    .clear: {
        ;x = object index
        
        ;we could probably do without setting db here
        ;but we're a hirom program, so it's best to do this
        
        stz w_hdma_id,x
        stz w_hdma_init,x
        stz w_hdma_routine,x
        stz w_hdma_timer,x
        stz w_hdma_table,x
        stz w_hdma_params,x
        
        sep #$20
        {
            stz w_hdma_bank,x       ;how to get around this sep?
        }
        rep #$20
        
        rts
    }
    
    
    
    
    
    .testobject_inidisp: {
        ;to create the structure
        dw ..init, ..routine
        dl ..table                  ;bank byte is written last
        
        ..init: {
            ;x = object index
            
            lda #$0000              ;target is high byte ($2100), params 00
            sta w_hdma_params,x
            
            rts
        }
        
        ..routine: {
            rts
        }
        
        ..table: {
            ;gradient of screen brightness
            ;3 lines each value
            
            db $01, $00
            db $01, $01
            db $01, $02
            db $01, $03
            db $01, $04
            db $01, $05
            db $01, $06
            db $01, $07
            db $01, $08
            db $01, $09
            db $01, $0a
            db $01, $0b
            db $01, $0c
            db $01, $0d
            db $01, $0e
            db $01, $0f

            db $02, $0f
            db $02, $0e
            db $02, $0d
            db $02, $0c
            db $02, $0b
            db $02, $0a
            db $02, $09
            db $02, $08
            db $02, $07
            db $02, $06
            db $02, $05
            db $02, $04
            db $02, $03
            db $02, $02
            db $02, $01
            
            db $03, $00
            db $03, $01
            db $03, $02
            db $03, $03
            db $03, $04
            db $03, $05
            db $03, $06
            db $03, $07
            db $03, $08
            db $03, $09
            db $03, $0a
            db $03, $0b
            db $03, $0c
            db $03, $0d
            db $03, $0e
            db $03, $0f
            
            db $04, $0f
            db $04, $0e
            db $04, $0d
            db $04, $0c
            db $04, $0b
            db $04, $0a
            db $04, $09
            db $04, $08
            db $04, $07
            db $04, $06
            db $04, $05
            db $04, $04
            db $04, $03
            db $04, $02
            db $04, $01
            
            db $05, $00
            db $05, $01
            db $05, $02
            db $05, $03
            db $05, $04
            db $05, $05
            db $05, $06
            db $05, $07
            db $05, $08
            db $05, $09
            db $05, $0a
            db $05, $0b
            db $05, $0c
            db $05, $0d
            db $05, $0e
            db $05, $0f
            
            db $00
        }
        
    }
    
    
    .testobject_inidisp_indirect: {
        dw ..init, ..routine
        dl ..table                  ;bank byte is written last
        
        ..init: {
            lda #$3200              ;target is high byte ($2100), params 00
            sta w_hdma_params,x
            rts
        }
        
        ..routine: {
            phb
            
            pea $7e7e
            plb
            plb
            
            
            inc
            
            plb
            rts
        }
        
        ..table: {

            db $00
        }
    }
    
    
    .testobject_coldata: {
        ;to create the structure
        dw ..init, ..routine
        dl ..table                  ;bank byte is written last
        
        ..init: {
            ;x = object index
            
            lda #$3200              ;target is high byte ($2100), params 00
            sta w_hdma_params,x
            
            rts
        }
        
        ..routine: {
            rts
        }
        
        ..table: {
            db $70, $01
            db $70, $1f

            db $00
        }
        
    }
    
    
    
    
    
    
    
    
}