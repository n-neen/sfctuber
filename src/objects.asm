;===========================================================================================
;===================================                   =====================================
;===================================   O B J E C T S   =====================================
;===================================                   =====================================
;===========================================================================================

;this is the file for routines of the object system
;at the bottom of this file is incsrc /obj_def.asm
;that file is for writing individual objects in this system
;


obj: {
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
            
            lda w_obj_x,x           ;object x - obj x size = left bound
            sec
            sbc w_obj_xsize,x
            sta p_4
            
            lda w_obj_x,x           ;object x + obj x size = right bound
            clc
            adc w_obj_xsize,x
            sta p_6
            
            lda w_obj_y,x           ;object y + obj y size = bottom bound
            clc
            adc w_obj_ysize,x
            sta p_8
            
            lda w_obj_y,x           ;object y - obj y size = top bound
            sec
            sbc w_obj_ysize,x
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
            adc.l w_level_objlistindex
            tay
            
            jsr obj_spawn
            bcs ..done
            
            ..nextslot:
            lda.l w_level_objlistindex
            clc
            adc #(!obj_list_entry_length)   ;next object list entry
            sta.l w_level_objlistindex
            
            dex                             ;next object slot
            dex
            bpl -
        }
        
        ..done:                             ;reached terminator
        
        ;routine will return with x = $fffe if we ran out of slots (probably)
        
        plb
        rtl
    }

    .spawn: {
        ;spawn an object, w_level_objlistindex into the current room's object list
        
        ;x = object index
        ;y = object list pointer + object list index (pointer to object list entry)
        
        lda $0000,y         ;this is related to this instance of the object
        cmp #$ffff
        beq ..done
        sta.l w_obj_id,x
        
        lda $0002,y
        sta.l w_obj_x,x
        
        lda $0004,y
        sta.l w_obj_y,x
        
        lda $0006,y
        sta.l w_obj_var1,x
        
        lda $0008,y
        sta.l w_obj_var2,x
        
        lda $000a,y
        sta.l w_obj_roomptr,x
        
        lda.l w_obj_id,x    ;this is from the object definition
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
        stz w_obj_roomptr,x
        
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