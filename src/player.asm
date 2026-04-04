;===========================================================================================
;======================================= PLAYER ============================================
;===========================================================================================

;need sprite system

player: {
    .init: {
        lda w_level_playerstartx
        sta w_player_x
        
        lda w_level_playerstarty
        sta w_player_y
        
        jsr player_draw              ;test sprite not real
        
        rtl
    }
    
    
    .main: {
        jsr player_input
        jsr player_boundscheck
              
        ;locate player on screen
        
        lda w_player_x
        sec
        sbc w_level_camerax
        sta w_player_x_onscreen
        
        lda w_player_y
        sec
        sbc w_level_cameray
        sta w_player_y_onscreen
        
        ;then draw
        
        jsr player_draw
        
        ;put a state machine here
        ;or like three or four
        
        rtl
    }
    
    
    .boundscheck: {
        ;todo: add level bounds to level metadata
        
        lda w_player_x
        cmp #$0004
        bpl +
        lda #$0004
        sta w_player_x
        +
        
        lda w_player_x
        cmp #$01f0
        bmi +
        lda #$01f0
        sta w_player_x
        +
        
        lda w_player_y
        cmp #$0004
        bpl +
        lda #$0004
        sta w_player_y
        +
        
        lda w_player_y
        cmp #$01d0
        bmi +
        lda #$01d0
        sta w_player_y
        +
        
        
        rts
    }
    
    
    .input: {
        lda w_controller
        
        bit #!controller_up
        beq ..noup
        {
            ;if up pressed
            pha
            
            lda w_player_direction      ;add up to the direction
            ora #!controller_up
            sta w_player_direction
            
            lda w_player_suby
            sec
            sbc #$8000
            sta w_player_suby
            
            lda w_player_y
            sbc #$0001
            sta w_player_y 
            
            pla
        }
        ..noup:
        
        bit #!controller_dn
        beq ..nodn
        {
            ;if dn pressed
            pha
            
            lda w_player_direction      ;add down to the direction
            ora #!controller_dn
            sta w_player_direction
            
            lda w_player_suby
            clc
            adc #$8000
            sta w_player_suby
            
            lda w_player_y
            adc #$0001
            sta w_player_y 
            
            pla
        }
        ..nodn:
        
        bit #!controller_lf
        beq ..nolf
        {
            ;if lf pressed
            pha
            
            lda w_player_direction      ;add left to the direction
            ora #!controller_lf
            sta w_player_direction
            
            lda w_player_subx
            sec
            sbc #$8000
            sta w_player_subx
            
            lda w_player_x
            sbc #$0001
            sta w_player_x 
            
            pla
        }
        ..nolf:
        
        bit #!controller_rt
        beq ..nort
        {
            ;if rt pressed
            pha
            
            lda w_player_direction      ;add rt to the direction
            ora #!controller_rt
            sta w_player_direction
            
            lda w_player_subx
            clc
            adc #$8000
            sta w_player_subx
            
            lda w_player_x
            adc #$0001
            sta w_player_x 
            
            pla
        }
        ..nort:
        
        rts
    }
    
    
    .draw: {
        sep #$20
        
        ldx #$0000
        
        phk
        plb
        
        lda w_nmicounter
        bit #$07
        bne +
        
        lda w_player_animationtimer
        inc
        sta w_player_animationtimer
        cmp #$08
        bmi +
        stz w_player_animationtimer
        lda #$00
        +
        ldy w_player_animationtimer
        
        lda w_player_x_onscreen
        sta w_oam_lo_buffer,x       ;x pos
        inx
        
        lda w_player_y_onscreen
        sta w_oam_lo_buffer,x       ;y pos
        inx
        
        
        rep #$20
        lda w_player_direction
        bit #!controller_lf|!controller_rt
        bne ..h
        lda player_draw_animationlist_vert,y
        bra ..v
        ..h
        lda player_draw_animationlist_horz,y
        ..v
        sep #$20
        
        sta w_oam_lo_buffer,x       ;tile
        inx
        
        lda #%00111110              ;properties
        sta w_oam_lo_buffer,x
        inx
        
        ;stx oamindex
        
        rep #$20
        
        rts
        
        ..animationlist_vert: {
            db $c0, $c1, $c2, $c3, $c4, $c5, $c6, $c7, $c8
        }
        
        ..animationlist_horz: {
            db $d0, $d1, $d2, $d3, $d4, $d5, $d6, $d7, $d8
        }
    }
    
    
    .spritemap: {
        ; xx yy tt pp hh
        ; ^  ^  ^  ^  ^
        ; x  ^  ^  ^  high table bits
        ;    y  ^  properties
        ;       tile
        ;
        ..test: {
            ;number of sprites
            db $01
             ;  xx   yy   tt   pp   hh
            db $80, $80, $c0, $00, $00
        }
    }
}