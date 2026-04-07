;===========================================================================================
;===================================                   =====================================
;===================================   O B J E C T S   =====================================
;===================================                   =====================================
;===========================================================================================

;this is the file for routines of the object system
;at the bottom of this file is incsrc /obj_def.asm
;that file is for writing individual objects in this system
;
;
;w_obj_var1: tile for drawing
;w_obj_var2
;w_obj_var3: used to hold pointers for door and text trigger objects
;


obj: {
    .drawall: {
        phb
        
        phk
        plb
        
        ldx #!obj_count*2
        -
        
        lda w_obj_id,x          ;if slot empty, exit
        beq +
        
        lda w_obj_tile,x        ;if null tile, exit (do not draw)
        beq +
        
        jsr obj_draw
        
        +
        dex
        dex
        bpl -
        
        
        plb
        rtl
    }
    
    
    
    .draw: {
        ;x = object index
        
        ;single tile test
        ;(y-1) * 32 + x = tilemap index
        ;can then know based on range which screen it is in
        
        ;p_0    used for x coordinate
        ;p_2    used for y coordinate
        ;p_4    used for adding screen offsets
        
        phy
        phx
        
        stx w_obj_index
        stz w_obj_drawindex
        
        lda w_obj_x,x       ;x
        ;lda w_player_x
        ;lsr
        ;lsr
        ;lsr
        sta p_0
        
        lda w_obj_y,x       ;y
        ;lda w_player_y
        ;lsr
        ;lsr
        ;lsr
        sta p_2
        
        lda p_0                 ;if x > $20, we're on right half of screen
        cmp #$0020
        bpl ..righthalf
        
        ..lefthalf:             ;else, we're on left half
        lda p_2             
        cmp #$0020
        bpl +
        
        ldx #!obj_flag_update_screen0   ;if y < $20, we're in screen 0
        lda #$0000
        jsr obj_screen
        bra ..write
        +
        
        ldx #!obj_flag_update_screen2   ;if y > $20, we're in screen 2
        lda #$1000
        jsr obj_screen
        bra ..write
        ++
        
        ..righthalf:                    ;we're on right half
        lda p_2
        cmp #$0020
        bmi +
        
        ldx #!obj_flag_update_screen3
        lda #$1800
        jsr obj_screen          ;if y > $20, (and on right half), we're in screen 3
        bra ..write
        +
        
        ldx #!obj_flag_update_screen1
        lda #$0800
        jsr obj_screen          ;else, screen 1
        ++
        
        ..write
        tax
        ldy w_obj_index
        lda w_obj_tile,y        ;tile to draw
        ;lda #$0234
        sta.l l_level,x
        
        ..return:
        plx
        ply
        rts
    }
    
    
    .screen: {
        sta p_4                     ;a = screen offset
        
        txa
        ora w_obj_screenupdates
        sta w_obj_screenupdates     ;add screen to screen update list
        
        lda p_0
        and #$001f
        sta p_0
        ;screen relative position
        
        lda p_2
        and #$001f
        sta p_2
        ;screen relative position
        
        sep #$20
        
        lda p_2
        sta $4202
        
        lda #$20
        sta $4203
        
        rep #$20
        nop #8
        
        lda $4216           ;result = y*32
        asl
        
        clc
        adc p_0
        adc p_0             ;y*32+x*2
        
        clc
        adc p_4             ;+ screen
        
        ;return with A = index
        rts
    }
    
    
    .collision: {
        ;check all objects for collision with player
        
        jsl player_calchitbox
        ;w_player_hitbox vars now populated for the below
        
        ldx #!obj_count*2   ;for each object that exists
        
        -
        
        lda w_obj_id,x
        beq +
        
        jsr obj_collision_check
        bcc +
        
        jsr (w_obj_touch,x)
        
        +
        dex
        dex
        bpl -
        
        rtl
        
        ..check: {
            ;x = object index
            
            ;we start out with tile coordinates and radii
            ;then convert to pixels for checking against player position
            
            lda w_obj_x,x           ;object x - obj x size = left bound
            sec
            sbc w_obj_xsize,x
            asl #3                  ;*3 for tile -> pixel
            sta p_4
            
            lda w_obj_x,x           ;object x + obj x size = right bound
            clc
            adc w_obj_xsize,x
            asl #3                  ;*3 for tile -> pixel
            sta p_6
            
            lda w_obj_y,x           ;object y + obj y size = bottom bound
            clc
            adc w_obj_ysize,x
            asl #3                  ;*3 for tile -> pixel
            sta p_8
            
            lda w_obj_y,x           ;object y - obj y size = top bound
            sec
            sbc w_obj_ysize,x
            asl #3                  ;*3 for tile -> pixel
            sta p_a
            
            ;for current object, calculated right before this:
            ;p_4    =   left bound
            ;p_6    =   right bound
            ;p_8    =   bottom bound
            ;p_a    =   top bound
            
            lda w_player_hitboxleft
            cmp p_4
            bmi +
            
            lda w_player_hitboxright
            cmp p_6
            bpl +
            
            lda w_player_hitboxbottom
            cmp p_8
            bpl +
            
            lda w_player_hitboxtop
            cmp p_a
            bmi +
            
            sec     ;no collision
            rts
            
            +
            clc     ;collision
            rts
        }
    }
    
    
    
    .spawnall: {
        phb
        
        pea.w (objlist>>8)+0            ;db = object list bank
        plb                             ;so all ram access needs to be long
        plb
        
        
        ldx #!obj_count*2               ;for x = 2*obj slots
        {
            -
            lda.l w_level_objlist
            clc
            adc.l w_level_objlistindex  ;objlist + index = what we are currently looking at
            tay
            
            jsr obj_spawn               ;spawn object pointed at by the result of the above
            bcs ..done
            
            ..nextslot:
            lda.l w_level_objlistindex  ;advance to next object entry
            clc
            adc #(!obj_list_entry_length)
            sta.l w_level_objlistindex
            
            dex                         ;next object slot
            dex
            bpl -
        }
        
        ..done:                         ;reached terminator
        
        ;routine will return with x = $fffe if we ran out of slots (probably)
        
        plb
        rtl
    }

    .spawn: {
        ;spawn an object, w_level_objlistindex into the current room's object list
        
        ;x = object index
        ;y = object list pointer + object list index (pointer to object list entry)
        
        lda $0000,y         ;this section is related to this instance of the object
        cmp #$ffff
        beq ..done
        sta.l w_obj_id,x
        
        lda $0002,y
        and #$00ff
        sta.l w_obj_x,x
        
        lda $0003,y
        and #$00ff
        sta.l w_obj_y,x
        
        lda $0004,y
        sta.l w_obj_var1,x
        
        lda $0006,y
        sta.l w_obj_var2,x
        
        lda $0008,y
        sta.l w_obj_var3,x
        
        lda.l w_obj_id,x    ;this section is from the object definition
        tay
        
        lda $0000,y
        and #$00ff
        sta.l w_obj_xsize,x
        
        lda $0001,y
        and #$00ff
        sta.l w_obj_ysize,x
        
        lda $0002,y
        sta.l w_obj_init,x
        
        lda $0004,y
        sta.l w_obj_main,x
        
        lda $0006,y
        sta.l w_obj_touch,x
        
        lda $0008,y
        sta.l w_obj_tile,x
        
        clc
        rts
        
        ..done:
        sec
        rts
        
        ..long: {
            phb
            
            pea.w (objlist>>8)+0            ;db = object list bank
            plb                             ;so all ram access needs to be long
            plb
            
            jsr obj_spawn
            
            plb
            rtl
        }
    }
    
    .clearall: {
        phk
        plb
        
        stz w_level_objlistindex
        
        ldx #!obj_count*2
        
        -
        jsr obj_clear
        dex
        dex
        
        bpl -
        
        rtl
    }
    
    .clear: {
        ;x = object index
        
        stz w_obj_id,x
        stz w_obj_xsize,x
        stz w_obj_ysize,x
        stz w_obj_init,x
        stz w_obj_main,x
        
        stz w_obj_x,x
        stz w_obj_y,x
        stz w_obj_var1,x
        stz w_obj_var2,x
        stz w_obj_var3,x
        
        rts
    }
    
    .runinit: {
        ;runs all init routines for objects that exist
        
        ;this runs with forced blank enabled, in loadgame state,
        ;right after all objects are spawned
        
        phb
        
        phk
        plb
        
        ldx #!obj_count*2
        
        -
        lda w_obj_id,x
        beq +
        
        jsr (w_obj_init,x)
        
        +
        dex
        dex
        bpl -
        
        plb
        rtl
    }
    
    .runmain: {
        ;runs all main routines for objects that exist
        
        ;runs during main gameplay
        
        phb
        
        phk
        plb
        
        ldx #!obj_count*2
        
        -
        lda w_obj_id,x
        beq +
        
        jsr (w_obj_main,x)
        
        +
        dex
        dex
        bpl -
        
        plb
        rtl
    }
    
    
    ;object definitions
    incsrc "./src/obj_def.asm"
}