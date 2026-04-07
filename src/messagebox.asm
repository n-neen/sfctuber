msg: {
    .display: {
        ;x = message pointer
        ;y = starting line
        
        stx p_0
        
        lda #((str&$ff0000)>>16)    ;text string bank
        sta p_2
        
        tya
        asl
        asl
        asl
        asl
        asl
        asl
        sta w_msg_start
        tax                     ;x = starting index in tilemap (line * 32)*2 again for tilemap (2 bytes per tile)
        ldy #$0000              ;y = starting index in source text
        
        -
        lda [p_0],y
        and #$00ff
        beq ..done
        
        cmp #$0020                      ;characters < $20 are control characters
        bpl ..notcontrol
        jsr msg_handlecontrolchars
        bra +
        ..notcontrol:
        
        sec
        sbc #$0020                      ;align ascii with tiles
        ora #$2000                      ;add priority bit
        sta.l w_msgbuffer,x             ;write to ram. possibly hirom area so needs this
        
        
        {   ;use this if you want to type out one character per frame
            phy
            phx
            
            lda #$0001
            sta w_msg_uploadflag
            txa
            inc
            inc
            sta w_msg_size
            jsl waitfornmi_long
            
            ;jsl gameplay                ;could call gameplay here too
            ;jsl gameplay_shadow         ;this is a better idea but still not ideal
            
            ;maybe gameplay and scene handler both have shadow modes?
            ;scene handler doesn't need to do anyhting else, so i think gameplay
            ;is the only one that needs this
            
            plx
            ply
        }
        
        inx
        inx
        +
        iny     ;if it was a control character, inc source index but not destination index
        bra -
        
        
        ..done:
        
        ;stx w_msg_size
        rtl
    }
    
    
    .handlecontrolchars: {
        ;low byte of A = ascii character
        ;   (control characters are under $20)
        ;x = tilemap index
        ;y = source text index
        
        cmp.w #!msg_newline
        bne +
        
        ;if newline:
        
        pha
        txa
        
        clc
        adc #$0040      ;add $20*2 (two bytes of tilemap) to go down a line
        and #$ffc0      ;remove bits lower than $40 to align to left
        
        tax
        pla
        
        +
        rts
    }
    
    
    .reset: {
        jsl msg_cleartilemap
        
        lda #$0001
        sta w_msg_uploadflag
        lda #$0800
        sta w_msg_size
        
        jsl layer3off_long
        
        rtl
    }
    
    
    .cleartilemap: {
        pea.w (($ff0000&w_msgbuffer)>>8)+0     ;db = message buffer bank (7e)
        plb
        plb
        
        ldx #$0100
        
        -
        stz.w w_msgbuffer,x
        stz.w w_msgbuffer+$100,x
        stz.w w_msgbuffer+$200,x
        stz.w w_msgbuffer+$300,x
        stz.w w_msgbuffer+$400,x
        stz.w w_msgbuffer+$500,x
        stz.w w_msgbuffer+$600,x
        stz.w w_msgbuffer+$700,x
        dex
        dex
        bpl -
        
        rtl
    }
    
    
    .upload: {
        lda #(!bg3tilemap)
        sta w_dmabaseaddr
        
        lda.w #w_msgbuffer
        sta w_dmasrcptr
        
        lda.w #(($ff0000&w_msgbuffer)>>16)+0
        sta w_dmasrcbank
        
        lda w_msg_size
        sta w_dmasize
        
        jsl dma_vramtransfur
        
        rtl
    }
    
}