msg: {
    .writetilemap: {
        ;eventually, x = message pointer
                  ;, text strings in some other bank
                  
        ;need to specify starting location
        ;in w_msg_start
                  
        stx p_0
        lda #((msg&$ff0000)>>16)
        sta p_2
        
        ldy #$0000
        ldx #$0000
        
        ;x = starting index in tilemap
        
        -
        lda [p_0],y                     ;eventually this will be read from rom
        and #$00ff
        cmp #$00ff
        beq ..done
        sec
        sbc #$0020                      ;align ascii with tiles
        ora #$2000                      ;add priority bit
        sta.l w_msgbuffer,x             ;write to ram. possibly hirom area so needs this
        iny
        inx
        inx
        bra -
        
        sty.w w_msg_size
        
        ..done
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
        db "       "
        db "buncha wordz ova here sum 1 gonna read dis shit"
        db "wooooooooooooooooooooahahahahahaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        db "test"
        db $ff
    }
}