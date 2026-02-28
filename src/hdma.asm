;===========================================================================================
;========================================= HDMA ============================================
;===========================================================================================

;hdma object:
    ;init routine   ;runs once when it is created
    ;main routine   ;runs once per frame
    ;hdma target
    ;indirect or direct
    ;table source bank
    ;specify channel or let handler pick on creation
        ;(1-7, keep channel 0 for regular dma)
    


hdma: {
    .nmihandler: {
        ;look for object slots that are occupied
        ;use the object's prarmeters to configure the hdma channel
        
        
        phx
        
        ldx #!k_hdma_objects_count*2
        -
        
        lda w_hdma_id,x
        beq +
        jsr hdma_configurechannel
        +
        
        dex
        dex
        bpl -
        
        plx
        rtl
    }
    
    .configurechannel: {
        ;a = hdma object pointer (id)
        ;x = hdma object slot index
        ;we can clobber a?
        
        txy             ;y = hdma object slot index
        
        txa
        asl
        asl
        asl
        ora #$4300
        sta p_0         ;p_0 = hdma register base address for this object
                        ;least significant nibble needs to be set for use
        
        ;unroll this for nmi time reasons
        
        lda w_hdma_params,y
        and #$00ff
        sta (p_0)
        
        inc p_0
        
        lda w_hdma_target,y
        
        
        rts
    }
    
    .spawn: {
        ;a = pointer to object header
        ;returns = index of object if created
        rtl
    }
    
    .clear: {
        ;x = object index
        phb
        
        phk
        plb
        
        stz w_hdma_id,x
        stz w_hdma_init,x
        stz w_hdma_routine,x
        stz w_hdma_timer,x
        stz w_hdma_table,x
        
        sep #$20
        {
            stz w_hdma_bank,x
            stz w_hdma_target,x
            stz w_hdma_channel,x
            stz w_hdma_params,x
        }
        rep #$20
        
        plb
        rts
    }
    
    .testobject: {
        ;to create the structure
        dw ..init, ..routine, ..table
        
        
        ..init: {
            ;
        }
        
        ..routine: {
            ;
        }
        
        ..table: {
            ;
        }
        
    }
}