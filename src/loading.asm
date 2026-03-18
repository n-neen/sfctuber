;===========================================================================================
;===================================  LOADING ROUTINES  ====================================
;===========================================================================================

    
load: {
    .scene: {
        phb
        phx
        
        phk
        plb
        
        jsr waitfornmi
        jsr screenoff
        jsr disablenmi
        
        ;copy tilemap to buffer
        
        lda w_scene_bank
        sta p_2
        
        lda w_scene_mapptr          ;tilemap pointer
        sta p_0
        
        lda #$0800                  ;tilemap size
        
        jsl load_romtobuffer        ;copy tilemap to buffer
        
        ;upload buffer to vram
        
        lda #$0800                  ;tilemap size
        ldx #!bg1tilemap            ;destination in vram
        
        jsl load_buffertovram       ;dma tilemap to vram
        
        ;copy graphics to buffer
        
        lda w_scene_bank            ;contains bank byte in low
        sta p_2
        
        lda w_scene_gfxptr          ;gfx pointer
        sta p_0
        
        lda w_scene_gfxsize         ;tilemap size
        
        jsl load_romtobuffer        ;copy gfx to buffer
        
        ;upload buffer to vram
        
        lda w_scene_gfxsize         ;gfx size
        ldx #!bg1tiles              ;destination in vram
        
        jsl load_buffertovram       ;dma gfx to vram
        
        ;copy palette to ram buffer
            
        lda w_scene_bank
        ldx w_scene_palptr
        
        jsl load_romtocolorbuffer
        
        
        jsr enablenmi
        jsr waitfornmi
        jsr screenon
        
        lda #!state_gameloop        ;return to gameplay
        sta w_programstate
        
        
        plx
        plb
        rtl
    }
    
    
    .romtobuffer: {
        ;copy from rom to buffer
        ;eventually decompression will replace this
        
        ;arguments:
        ;p_0 = long pointer
        ;a   = size, must be < $8000
        
        phy
        phb
        
        and #$7fff
        tay
        
        pea.w (($ff0000&l_decompressionbuffer)>>8)+0
        plb
        plb     ;db = buffer bank (7f)
        
        -
        lda [p_0],y                     ;copy from [long pointer] + y
        sta.w l_decompressionbuffer,y   ;to buffer + x
        dey
        dey
        bpl -
        
        plb
        ply
        rtl
    }
    
    
    .buffertovram: {
        ;copy from decompression buffer to vram
        ;fixed start location, variable size
        
        ;arguments:
        ;a = size
        ;x = vram destination
        phb
        
        phk
        plb
        
        sta w_dmasize
        stx w_dmabaseaddr
        
        lda #l_decompressionbuffer
        sta w_dmasrcptr
        
        ;print pc
        lda #(($ff0000&l_decompressionbuffer)>>16)
        sta w_dmasrcbank
        
        jsl dma_vramtransfur
        
        plb
        rtl
    }
    
    .romtocolorbuffer: {
        ;a = palette bank (in low byte)
        ;x = palette pointer
        ;copies an entire palette to cg ram buffer
        ;skips first palette line
        
        phb
        phy
        
        stx p_0
        
        xba
        pha
        plb
        plb     ;db = palette bank
        
        ldy #$00e0
        ldx #$00e0
        
        -
        lda (p_0),y
        sta.l w_cgrambuffer+$20,x
        dex
        dex
        dey
        dey
        bpl -
        
        ply
        plb
        rtl
    }
}