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
    
    .0  : skip 2
    .1  : skip 2
    .2  : skip 2
    .3  : skip 2
    .4  : skip 2
    .5  : skip 2
    .6  : skip 2
    .7  : skip 2
}

;======================================= direct page =======================================

d: {
    ;
    ;todo
    ;
}



;========================================= work ram ========================================
org $7e0100
w: {                                    ;w
    .nmicounter         : skip 2
    .nmiflag            : skip 2
    .lagcounter         : skip 2
    
    .screenbrightness   : skip 2
    
    ;dma arguments
    .dmabaseaddr        : skip 2
    .dmasrcptr          : skip 2
    .dmasrcbank         : skip 2
    .dmasize            : skip 2
    
    .controller         : skip 2
    .programstate       : skip 2
    
    .fadestate          : skip 2
    .fadecounter        : skip 2
    .fadebitmask        : skip 2
    .fadenextstate      : skip 2
    
    .level: {
        ..camerax       : skip 2
        ..cameray       : skip 2
        ..seamcolumn    : skip 2
        ..seamrow       : skip 2
        
        ..direction     : skip 2
    }
    
    
    org $7e1000
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
    
    org $7ec000
    .cgrambuffer        : skip !k_cgrambuffersize
}

org $7f0000


l: {
    ;level dimensions and data
    .xsize  : skip 2
    .ysize  : skip 2
    .level  : skip $8000
}