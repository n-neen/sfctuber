;===========================================================================================
;======================================== SCROLLING ========================================
;===========================================================================================

scroll: {
    .main: {
        ;determine which directions to scroll
        
        ;this doesn't work anymore
        ;need to update based on what is actually moved
        ;not directions held
        
        lda w_player_x_onscreen
        cmp #!camera_box_lf_bound           ;if > x bound (towards center of screen),
        bpl ..skipleft
        {
            lda w_player_xspeed             ;and x pseed is negative
            bpl ..skipleft
            
            {
                lda w_scroll_direction
                ora #!controller_lf         ;add left to scroll direction
                sta w_scroll_direction
            }
        }
        ..skipleft:
        
        
        lda w_player_x_onscreen
        cmp #!camera_box_rt_bound           ;if < x bound (towards center of screen),
        bmi ..skipright
        {
            lda w_player_xspeed             ;and x speed is positive
            bmi ..skipright
            
            {
                lda w_scroll_direction
                ora #!controller_rt         ;add right to scroll direction
                sta w_scroll_direction
            }
        }
        ..skipright:
        
        
        lda w_player_y_onscreen
        cmp #!camera_box_up_bound           ;if > y bound (towards center of screen),
        bpl ..skipup
        {
            lda w_player_yspeed             ;and y speed is negative
            bpl ..skipup
            
            {
                lda w_scroll_direction
                ora #!controller_up         ;add up to scroll direction
                sta w_scroll_direction
            }
        }
        ..skipup:
        
        
        
        lda w_player_y_onscreen
        cmp #!camera_box_dn_bound           ;if < y bound (towards center of screen),
        bmi ..skipdown
        
        {
            lda w_player_yspeed             ;and y speed is positive
            bmi ..skipdown
            {
                lda w_scroll_direction
                ora #!controller_dn         ;add down to scroll direction
                sta w_scroll_direction
            }
        }
        ..skipdown:
        
        ;handle scrolling each direction
        
        lda w_scroll_direction
        
        bit #!controller_up
        beq ..noup
        jsr scroll_up
        ..noup:
        
        bit #!controller_dn
        beq ..nodown
        jsr scroll_down
        ..nodown:
        
        bit #!controller_lf
        beq ..noleft
        jsr scroll_left
        ..noleft:
        
        bit #!controller_rt
        beq ..noright
        jsr scroll_right
        ..noright:
        
        ;apply camera to bg1 scroll
        ;currently this doesn't make all that much sense
        ;but i think the idea was that it would be useful later?
        ;curious
        
        lda w_level_camerax
        sta w_bg1xscroll
        
        lda w_level_cameray
        sta w_bg1yscroll
        
        rtl
    }
    
    .up: {
        pha
        
        lda w_level_cameray
        cmp w_scroll_upbound
        bmi +
        
        lda w_level_camerasuby
        clc
        adc w_player_ysubspeed
        sta w_level_camerasuby
        
        lda w_level_cameray
        adc w_player_yspeed
        sta w_level_cameray
        
        +
        
        pla
        rts
    }
    
    .down: {
        pha
        
        lda w_level_cameray
        cmp w_scroll_downbound
        bpl +
        
        lda w_level_camerasuby
        clc
        adc w_player_ysubspeed
        sta w_level_camerasuby
        
        lda w_level_cameray
        adc w_player_yspeed
        sta w_level_cameray
        
        +
        
        pla
        rts
    }

    .left: {
        pha
        
        lda w_level_camerax
        cmp w_scroll_leftbound
        bmi +
        
        lda w_level_camerasubx
        clc
        adc w_player_xsubspeed
        sta w_level_camerasubx
        
        lda w_level_camerax
        adc w_player_xspeed
        sta w_level_camerax
        
        +
        
        pla
        rts
    }

    .right: {
        pha
        
        lda w_level_camerax
        cmp w_scroll_rightbound
        bpl +
        
        
        lda w_level_camerasubx
        clc
        ;adc w_scroll_camerasubspeed
        adc w_player_xsubspeed
        sta w_level_camerasubx
        
        lda w_level_camerax
        ;adc w_scroll_cameraspeed
        adc w_player_xspeed
        sta w_level_camerax
        
        +
        
        pla
        rts
    }
    
}