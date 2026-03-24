;===========================================================================================
;===========================================================================================
;======================================= RAM  LABELS =======================================
;===========================================================================================
;===========================================================================================


;the conventions is that top level ram labels are one letter

;p = pseudoregisters
;d = direct page
;w = work ram
;l = level data

org $00

p: {
    ;0-f are reserved for pseudoregisters
    
    .0  : skip 1
    .1  : skip 1
    .2  : skip 1
    .3  : skip 1
    .4  : skip 1
    .5  : skip 1
    .6  : skip 1
    .7  : skip 1
    .8  : skip 1
    .9  : skip 1
    .a  : skip 1
    .b  : skip 1
    .c  : skip 1
    .d  : skip 1
    .e  : skip 1
    .f  : skip 1
}

;======================================= direct page =======================================

d: {
    org $20
    ;
    ;todo
    ;
}



;========================================= work ram ========================================
org $7e0100
w: {
    print "work ram start: ", pc
    .nmicounter         : skip 2
    .nmiflag            : skip 2
    .lagcounter         : skip 2
    
    ;ppu register buffers
    .screenbrightness   : skip 2
    .bg1xscroll         : skip 2
    .bg1yscroll         : skip 2
    
    .bg2xscroll         : skip 2
    .bg2yscroll         : skip 2
    
    .bg3xscroll         : skip 2
    .bg3yscroll         : skip 2
    
    ;dma arguments
    .dmabaseaddr        : skip 2
    .dmasrcptr          : skip 2
    .dmasrcbank         : skip 2
    .dmasize            : skip 2
    
    .controller         : skip 2
    .programstate       : skip 2
    
    .prestate           : skip 2
    .fadecounter        : skip 2
    .fadebitmask        : skip 2
    .fadenextstate      : skip 2
    
    .testsceneindex     : skip 2
    
    .level: {
        ..camerax       : skip 2
        ..cameray       : skip 2
        ..seamcolumn    : skip 2
        ..seamrow       : skip 2
        
        ..direction     : skip 2
    }
    
    .scene: {
        ..definitionptr : skip 2
        ..bank          : skip 2
        ..palptr        : skip 2
        ..gfxptr        : skip 2
        ..mapptr        : skip 2
        ..gfxsize       : skip 2
        ..tilemapsize   : skip 2
        ..gameprops     : skip 2    ;probably store all this
                                    ;individually when it exists
    }
    
    .oam: {
        ;print "oam buffer: ", pc
        ..index         : skip 2
        ..lo_buffer     : skip 512
        ..hi_buffer     : skip 32
    }
    
    .hdma: {                           ;w_hdma
        ;object independent
        ..channels  : skip 2
        ..enable    : skip 2

        ;object arrays
        !k_hdma_objects_count #=   $0007
        ..id        :   skip 2*!k_hdma_objects_count+2
        ..init      :   skip 2*!k_hdma_objects_count+2
        ..routine   :   skip 2*!k_hdma_objects_count+2
        ..timer     :   skip 2*!k_hdma_objects_count+2
        ..table     :   skip 2*!k_hdma_objects_count+2
        ..params    :   skip 2*!k_hdma_objects_count+2  ;for $4300 and $4301 write at once
        ..var       :   skip 2*!k_hdma_objects_count+2
        ..bank      :   skip 2*!k_hdma_objects_count+2  ;low byte = direct bank, high byte = indirect bank
        
    }
    
    print "work ram end:   ", pc
    
    org $7ec000
    .cgrambuffer    :   skip !k_cgrambuffersize
    
    org $7ee000
    .msg: {
        ..buffer    :   skip $800
    }
}

org $7f0000


;decompressionbuffer overlaps level data:
;decompress graphics here, upload to vram, then decompress level data here


l: {
    .decompressionbuffer:
    ;level dimensions and data
    .xsize  : skip 2
    .ysize  : skip 2
    .level  : skip $8000
    
    
}