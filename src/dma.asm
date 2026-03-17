;===========================================================================================
;=================================== dma routines ==========================================
;===========================================================================================


dma: {
    .vramtransfur: {        ;for dma channel 0
                                                ;register width (bytes)
        ;dma_control            =   $2115       ;1
        ;dma_dest_baseaddr      =   $2116       ;2
        ;dma_transfur_mode      =   $4300       ;1
        ;dma_reg_destination    =   $4301       ;1
        ;dma_source_address     =   $4302       ;2
        ;dma_bank               =   $4304       ;1
        ;dma_transfur_size      =   $4305       ;2
        ;dma_enable             =   $430b       ;1
                            ;set to #%00000001 to enable transfur on channel 0
        phx
        phb
        php
        
        phk
        plb
        
        rep #$20
        sep #$10
                                    ;width  register
        ldx.b #$80                  ;1      dma control
        stx $2115
        
        lda.w w_dmabaseaddr         ;2      dest base addr
        sta $2116
        
        ldx #$01                    ;1      transfur mode
        stx $4300
        
        ldx #$18                    ;1      register dest (vram port)
        stx $4301
        
        lda.w w_dmasrcptr           ;2      source addr
        sta $4302
        
        ldx w_dmasrcbank            ;1      source bank
        stx $4304
        
        lda.w w_dmasize             ;2      transfur size
        sta $4305
        
        ldx #$01                    ;1      enable transfur on dma channel 0
        stx $420b
        
        plp
        plb
        plx
        rtl
    }
    
    .cgramtransfur: {
        phx
        phb
        php
        
        phk
        plb
        
        rep #$20
        sep #$10                    ;width  register
        
        ldx w_dmabaseaddr           ;1      cgadd
        stx $2121
        
        ldx #$02                    ;1      transfur mode
        stx $4300
        
        ldx #$22                    ;1      register dest (cgram write)
        stx $4301
        
        lda.w w_dmasrcptr           ;2      source addr
        sta $4302
        
        ldx w_dmasrcbank            ;1      source bank
        stx $4304
        
        lda.w w_dmasize             ;2      transfur size
        sta $4305
        
        ldx #$01                    ;1      enable transfur on dma channel 0
        stx $420b
        
        plp
        plb
        plx
        rtl
    }
    
    .clearvram: {
        phx
        phb
        php
        
        phk
        plb        
        
        rep #$20
        sep #$10                    ;width  register
        
        ldx.b #$80                  ;1      dma control
        stx $2115
        
        lda #$0000                  ;2      dest base addr
        sta $2116
        
        ldx.b #%00011001            ;1      transfur mode
        stx $4300
        
        ldx #$18                    ;1      register dest (vram port)
        stx $4301
        
        lda.w #..fillword           ;2      source addr
        sta $4302
        
        stz $4305                   ;2      transfur size ($10000)
        
        ldx.b #!dmabankshort        ;1      source bank
        stx $4304
        
        ldx.b #$01                  ;1      enable transfur on dma channel 0    
        stx $420b
        
        plp
        plb
        plx
        rtl    
        ..fillword: {
            dw $0000
        }
    }
    
    
    .clearcgram: {
        phx
        phb
        php
        
        phk
        plb
        
        rep #$20
        sep #$10                    ;width  register
        
        ldx.b #$00                  ;1      cgadd
        stx $2121

        ldx.b #%00011001            ;1      transfur mode: write twice
        stx $4300
        
        ldx #$22                    ;1      register dest (cgram write)
        stx $4301
        
        lda.w #..fillword           ;2      source addr
        sta $4302
        
        ldx.b #!dmabankshort        ;1      source bank
        stx $4304
        
        lda.w #$0400                ;2      transfur size
        sta $4305
        
        ldx.b #$01                  ;1      enable transfur on dma channel 0
        stx $420b
        
        plp
        plb
        plx
        rtl  
        
        ..fillword: {
            dw $3800
        }
    }
    
}
    
    
    
load: {
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
        ;dex
        ;dex
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
        ;copies an entire $100 byte palette to cg ram buffer
        
        phb
        phy
        
        stx p_0
        
        xba
        pha
        plb
        plb     ;db = palette bank
        
        ldy #$0100
        ldx #$0100
        
        -
        lda (p_0),y
        sta.l w_cgrambuffer,x
        dey
        dey
        dex
        dex
        bpl -
        
        ply
        plb
        rtl
    }
}