;===========================================================================================
;===================================  LOADING ROUTINES  ====================================
;===========================================================================================

;todo
;decide structure of this before proceeding

load: {
    .graphics: {
        ;todo: big table of pointers
        jsl dma_vramtransfur
        rtl
    }
    
    
    .tilemap: {
        ;
        jsl dma_vramtransfur
        rtl
    }
    
    
    .palette: {
        ;
        jsl dma_cgramtransfur
        rtl
    }
    
    
}

;maybe this again?

macro loadtablentry(pointer, size, baseaddr, index)
    dl <pointer>        ;long pointer to the data
    dw <size>           ;size of the data
    dw <baseaddr>       ;destination (in vram or cgram)
    db <index>          ;unused byte just makes the table entries 8 bytes long
endmacro


scenelist: {
    
}

