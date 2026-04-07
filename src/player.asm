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
        
        lda #!player_xsize_default
        sta w_player_xsize
        
        lda #!player_ysize_default
        sta w_player_ysize
        
        jsr player_draw             ;test sprite not real
        
        rtl
    }
    
    
    .calchitbox: {
        phb
        
        phk
        plb
        
        lda w_player_x              ;player x - x size = left bound
        sec
        sbc w_player_xsize
        sta w_player_hitboxleft
        
        lda w_player_x              ;player x + x size = right bound
        clc
        adc w_player_xsize
        sta w_player_hitboxright
        
        lda w_player_y              ;player y + y size = bottom bound
        clc
        adc w_player_ysize
        sta w_player_hitboxbottom
        
        lda w_player_y              ;player y + y size = top bound
        sec
        sbc w_player_ysize
        sta w_player_hitboxtop
        
        plb
        rtl
    }
    
    
    .hitboxsize: {
        lda w_player_direction
        beq +
        
        lda #!player_xsize_default-5        ;if moving
        sta w_player_xsize
        
        lda #!player_ysize_default-5
        sta w_player_ysize
        
        rts
        
        +
        lda #!player_xsize_default          ;if not moving
        sta w_player_xsize
        
        lda #!player_ysize_default
        sta w_player_ysize
        
        rts
    }
    
    
    .main: {
        phk
        plb
        
        jsr player_input            ;get input (adds direction bits to w_player_direction)
        jsr player_hitboxsize       ;make hitbox bigger if moving
        jsr player_boundscheck      ;hardcoded test harness for level bounds
        jsr player_collision        ;removes direction bits from w_player_direction
        
        lda w_player_direction
        jsr player_move             ;move in the directions of remaining direction bits
              
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
        
        rtl
    }
    
    
    .move: {
        ;A = direction bits
        
        bit #!controller_up
        beq +
        {
            pha
            jsr player_move_up
            pla
        }
        +
        
        bit #!controller_dn
        beq +
        {
            pha
            jsr player_move_down
            pla
        }
        +
        
        bit #!controller_lf
        beq +
        {
            pha
            jsr player_move_left
            pla
        }
        +
        
        
        bit #!controller_rt
        beq +
        {
            pha
            jsr player_move_right
            pla
        }
        +
        
        rts
        
        ..up: {
            lda w_player_suby
            sec
            sbc #$8000
            sta w_player_suby
            
            lda w_player_y
            sbc #$0001
            sta w_player_y 
            
            rts
        }
        
        ..down: {
            lda w_player_suby
            clc
            adc #$8000
            sta w_player_suby
            
            lda w_player_y
            adc #$0001
            sta w_player_y 
        
            rts
        }
        
        ..right: {
            lda w_player_subx
            clc
            adc #$8000
            sta w_player_subx
            
            lda w_player_x
            adc #$0001
            sta w_player_x
            
            rts
        }
        
        ..left: {
            lda w_player_subx
            sec
            sbc #$8000
            sta w_player_subx
            
            lda w_player_x
            sbc #$0001
            sta w_player_x
            
            rts
        }
    }
    
    
    .collision: {
        lda w_player_collisiontype
        asl
        tax
        
        jsr (player_collision_table,x)
        
        rts
        
        ..table: {
            dw player_collision_air             ;0
            dw player_collision_preventup       ;1
            dw player_collision_preventdown     ;2
            dw player_collision_preventleft     ;3
            dw player_collision_preventright    ;4
            dw player_collision_solid           ;5
        }
        
        ..air: {
            
            rts
        }
        
        ..solid: {
            lda w_player_direction
            eor #$ffff
            jsr player_move
            jsr player_move
            jsr player_move
            
            stz w_player_direction

            rts
        }
        
        ..preventup: {
            lda w_player_direction
            and #($ffff^!controller_up)
            sta w_player_direction
            
            rts
        }
        
        ..preventdown: {
            lda w_player_direction
            and #($ffff^!controller_dn)
            sta w_player_direction
            
            rts
        }
        
        ..preventleft: {
            lda w_player_direction
            and #($ffff^!controller_lf)
            sta w_player_direction
            
            rts
        }
        
        ..preventright: {
            lda w_player_direction
            and #($ffff^!controller_rt)
            sta w_player_direction
            
            rts
        }
    }
    
    
    .boundscheck: {
        ;todo: add level bounds to level metadata
        
        lda w_player_x          ;left bound
        cmp #$0004
        bpl +
        lda #$0004
        sta w_player_x
        +
        
        lda w_player_x          ;right bound
        cmp #$01f0
        bmi +
        lda #$01f0
        sta w_player_x
        +
        
        lda w_player_y          ;top bound
        cmp #$0004
        bpl +
        lda #$0004
        sta w_player_y
        +
        
        lda w_player_y          ;bottom bound
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

