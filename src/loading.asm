;===========================================================================================
;===================================  LOADING ROUTINES  ====================================
;===========================================================================================

    
load: {
    .scene: {
        phb
        phx
        
        phk
        plb
        
        ;copy tilemap to buffer
        
        ;this now specifically puts layer 1 tilemap in l_level
        
        lda w_scene_bank
        sta p_2
        
        lda w_scene_mapptr          ;tilemap pointer
        sta p_0
        
        lda w_scene_tilemapsize     ;tilemap size
        jsl load_romtolevelbuffer   ;copy tilemap to level buffer
        
        ;upload buffer to vram
        
        lda w_scene_tilemapsize     ;tilemap size
        ldx #!bg1tilemap            ;destination in vram
        jsl load_levelbuffertovram  ;dma tilemap to vram
        
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
        sta.w l_decompressionbuffer,y   ;to buffer + y
        dey
        dey
        bpl -
        
        plb
        ply
        rtl
    }
    
    .romtolevelbuffer: {
        ;copy paste from above :/
        
        ;copy from rom to buffer
        ;eventually decompression will replace this
        
        ;arguments:
        ;p_0 = long pointer
        ;a   = size, must be < $8000
        
        phy
        phb
        
        and #$7fff
        tay
        
        pea.w (($ff0000&l_level)>>8)+0
        plb
        plb     ;db = buffer bank (7f)
        
        -
        lda [p_0],y                     ;copy from [long pointer] + y
        sta.w l_level,y                 ;to buffer + y
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
    
    
    .levelbuffertovram: {
        ;copy paste of above :/
        
        
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
        
        lda #l_level
        sta w_dmasrcptr
        
        ;print pc
        lda #(($ff0000&l_level)>>16)
        sta w_dmasrcbank
        
        jsl dma_vramtransfur
        
        plb
        rtl
    }
    
    
    .romtocolorbuffer: {
        ;a = palette bank (in low byte)
        ;x = palette pointer
        ;copies an entire palette to cg ram buffer
        ;skips first palette line ($20 bytes)
        
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
    
    .playerpal: {
        ;copies a single palette line
        ;to the last sprite palette in buffer
        
        ldx #$0020
        -
        lda.l playersprite_pal,x
        sta.l w_cgrambuffer+$01e0,x
        dex
        dex
        bpl -
        
        rtl
    }
    
    .playergfx: {
        lda.w #datasize(playersprite_gfx)
        sta w_dmasize
        
        lda #playersprite_gfx
        sta w_dmasrcptr
        
        lda.w #((playersprite_gfx)>>16)+0
        sta w_dmasrcbank
        
        lda #!spritegfx+$c00
        sta w_dmabaseaddr
        
        jsl dma_vramtransfur
        
        rtl
    }
    
    
    .bg3colortobuffer: {
        phb
        
        pea.w (($ff0000&bg3data)>>8)+0       ;db = bank of bg3data (palette)
        plb
        plb
        
        ldx #$0020
        
        -
        lda bg3data_pal,x
        sta w_cgrambuffer,x
        dex
        dex
        bpl -
        
        plb
        rtl
    }
    
    
    .bg3tilemapupload: {
        lda #(!bg3tilemap)
        sta w_dmabaseaddr
        
        lda.w #w_msgbuffer
        sta w_dmasrcptr
        
        lda.w #(($ff0000&w_msgbuffer)>>16)+0
        sta w_dmasrcbank
        
        lda #$0800
        sta w_dmasize
        
        jsl dma_vramtransfur
        
        rtl
    }
    
    
    .bg3tilemaptobuffer: {
        ;copy from rom to buffer
        
        phb
        
        pea.w (($ff0000&bg3data)>>8)+0
        plb
        plb
        
        ldx #$0800
        
        -
        lda bg3data_testmap,x
        sta.l w_msgbuffer,x
        dex
        dex
        bpl -
        
        plb
        rtl
    }
    
    
    .bg3tilesupload: {
        ;copy graphics from rom to vram
        
        lda #(!bg3tiles)
        sta w_dmabaseaddr
        
        lda.w #bg3data_gfx
        sta w_dmasrcptr
        
        lda.w #(($ff0000&bg3data)>>16)+0
        sta w_dmasrcbank
        
        lda #$0800
        sta w_dmasize
        
        jsl dma_vramtransfur
        
        rtl
    }
    
    
    .updatelevelscreen: {
        ;screen 0, 1, 2 or 3
        
        lda w_obj_screenupdates
        beq ..return
        ;if bits exist, we have at least one update queued
        
        bit #!obj_flag_update_screen0
        beq +
            
        {
            lda w_obj_screenupdates
            and #(!obj_flag_update_screen0^$ffff)+0     ;remove update bit
            sta w_obj_screenupdates
            
            lda #!bg1tilemap+0
            sta w_dmabaseaddr
            
            lda #l_level_screen0
            bra ..update                                ;can only afford one update per nmi
            +
        }
        
        bit #!obj_flag_update_screen1
        beq +
        
        {
            lda w_obj_screenupdates
            and #(!obj_flag_update_screen1^$ffff)+0     ;remove update bit
            sta w_obj_screenupdates
            
            lda #!bg1tilemap+$400
            sta w_dmabaseaddr
            
            lda #l_level_screen1
            bra ..update                                ;can only afford one update per nmi
            +
        }
        
        bit #!obj_flag_update_screen2
        beq +
        
        {
            lda w_obj_screenupdates
            and #(!obj_flag_update_screen2^$ffff)+0     ;remove update bit
            sta w_obj_screenupdates
            
            lda #!bg1tilemap+$800
            sta w_dmabaseaddr
            
            lda #l_level_screen2
            bra ..update                                ;can only afford one update per nmi
            +
        }
        
        bit #!obj_flag_update_screen3
        beq +
        
        {
            lda w_obj_screenupdates
            and #(!obj_flag_update_screen3^$ffff)+0     ;remove update bit
            sta w_obj_screenupdates
            
            lda #!bg1tilemap+$c00
            sta w_dmabaseaddr
            
            lda #l_level_screen3
            ;bra ..update                               ;can only afford one update per nmi
            +
        }
        
        ..update:
        
        sta w_dmasrcptr                     ;A = buffer location from above
        
        lda #$0800
        sta w_dmasize
        
        lda.w #(l_level>>16)+0
        sta w_dmasrcbank
        
        jsl dma_vramtransfur
        
        ..return:
        rtl
    }
}