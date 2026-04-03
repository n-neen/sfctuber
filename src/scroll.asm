;===========================================================================================
;======================================== SCROLLING ========================================
;===========================================================================================

scroll: {
    .main: {
        ;determine which directions to scroll
        
        lda w_player_x_onscreen
        cmp #!camera_box_lf_bound
        bpl ..skipleft
        ;if > x bound (towards center of screen),
        lda w_player_direction
        bit #!controller_lf
        beq ..skipleft
        ;and moving left,
        and #!controller_lf
        ora w_scroll_direction      ;add left to scroll direction
        sta w_scroll_direction
        ..skipleft:
        
        lda w_player_x_onscreen
        cmp #!camera_box_rt_bound
        bmi ..skipright
        ;if < x bound (towards center of screen),
        lda w_player_direction
        bit #!controller_rt
        beq ..skipright
        ;and moving right,
        and #!controller_rt
        ora w_scroll_direction      ;add right to scroll direction
        sta w_scroll_direction
        ..skipright:
        
        lda w_player_y_onscreen
        cmp #!camera_box_up_bound
        bpl ..skipup
        ;if > y bound (towards center of screen),
        lda w_player_direction
        bit #!controller_up
        beq ..skipup
        ;and moving up,
        and #!controller_up
        ora w_scroll_direction      ;add up to scroll direction
        sta w_scroll_direction
        ..skipup:
        
        lda w_player_y_onscreen
        cmp #!camera_box_dn_bound
        bmi ..skipdown
        ;if < y bound (towards center of screen),
        lda w_player_direction
        bit #!controller_dn
        beq ..skipdown
        ;and moving down,
        and #!controller_dn
        ora w_scroll_direction      ;add down to scroll direction
        sta w_scroll_direction
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
        sec
        sbc w_scroll_camerasubspeed
        sta w_level_camerasuby
        
        lda w_level_cameray
        sbc w_scroll_cameraspeed
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
        adc w_scroll_camerasubspeed
        sta w_level_camerasuby
        
        lda w_level_cameray
        adc w_scroll_cameraspeed
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
        sec
        sbc w_scroll_camerasubspeed
        sta w_level_camerasubx
        
        lda w_level_camerax
        sbc w_scroll_cameraspeed
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
        adc w_scroll_camerasubspeed
        sta w_level_camerasubx
        
        lda w_level_camerax
        adc w_scroll_cameraspeed
        sta w_level_camerax
        
        +
        
        pla
        rts
    }
    
}