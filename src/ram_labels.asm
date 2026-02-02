

;zero page
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


d: {
    ;direct page
    
    ;
    ;
}


org $7e0100

w: {
    ;work ram
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
}

;registers

r: {
    ;
    ;
}

;base off