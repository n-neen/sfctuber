msg: {
    .writetilemap: {
        ;eventually, x = message pointer
                  ;, text strings in some other bank
                  
        ;need to specify starting location
        ;in w_msg_start
                  
        stx p_0
        lda #((msg&$ff0000)>>16)
        sta p_2
        
                          ;eventually we will specify starting destination (in tilemap)
        ldy #$0000        ;y = starting index in source text
        ldx #$0000        ;x = starting index in tilemap
        
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
        
        inx
        inx
        +
        iny     ;if it was a control character, inc source index but not destination index
        bra -
        
        
        ..done:
        
        sty w_msg_size
        rts
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
        adc #$0040
        and #$ffc0
        
        tax
        pla
        
        +
        rts
    }
    
    
    .upload: {
        lda #(!bg3tilemap)
        sta w_dmabaseaddr
        
        lda.w #w_msgbuffer
        sta w_dmasrcptr
        
        lda.w #(($ff0000&w_msgbuffer)>>16)+0
        sta w_dmasrcbank
        
        lda #$0200
        sta w_dmasize
        
        jsl dma_vramtransfur
        
        rtl
    }
    
    
    .tilemaptest: {
        ldx #msg_testtext
        jsr msg_writetilemap
        
        lda #$0001
        sta w_msg_uploadflag
        
        jsl layer3on_long
        
        stz w_bg3yscroll
        
        rtl
    }
    
    
    .testtext: {
        
        db "From robot past"
        db !msg_newline
        
        db "this is a sentence with wordz"
        db !msg_newline
        
        db "test12"
        db !msg_newline
        db !msg_newline
        
        db "test123 slightly longer"
        db !msg_newline
        db !msg_newline
        db !msg_newline
        
        db "even more wordz"
        
        db !msg_end
    }
}