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
    
    .subscreenlayers    : skip 1
    .mainscreenlayers   : skip 1
    .colormathlayers    : skip 1
    .colormathlogic     : skip 1
    
    ;dma arguments
    .dmabaseaddr        : skip 2
    .dmasrcptr          : skip 2
    .dmasrcbank         : skip 2
    .dmasize            : skip 2
    
    .controller         : skip 2
    .programstate       : skip 2
    
    .prestate           : skip 2        ;not sure if using this
    .fadetimer          : skip 2
    .fadebitmask        : skip 2
    .fadenextstate      : skip 2        ;deprecated
    
    .testsceneindex     : skip 2
    
    .nmitimen           : skip 2
    
    .irq: {
        ..command       : skip 2
        ..htarget       : skip 2
        ..vtarget       : skip 2
    }
    
    .player: {
        ;print pc
        ..x                 : skip 2
        ..subx              : skip 2
        ..y                 : skip 2
        ..suby              : skip 2
        
        ..xspeed            : skip 2
        ..yspeed            : skip 2
        ..xsubspeed         : skip 2
        ..ysubspeed         : skip 2
        
        ..x_onscreen        : skip 2
        ..y_onscreen        : skip 2
        
        ..direction         : skip 2
        ..previousdirection : skip 2
        
        ..animationtimer    : skip 2
        
        ..xsize             : skip 2
        ..ysize             : skip 2
        
        ..hitboxleft        : skip 2
        ..hitboxright       : skip 2
        ..hitboxtop         : skip 2
        ..hitboxbottom      : skip 2
        
        ..collisiontype     : skip 2
    }
    
    .level: {
        ..camerax       : skip 2
        ..cameray       : skip 2
        
        ..camerasubx    : skip 2
        ..camerasuby    : skip 2
        
        ..camerastartx  : skip 2
        ..camerastarty  : skip 2
        
        ..playerstartx  : skip 2
        ..playerstarty  : skip 2
        
        ..objlist       : skip 2
        ..objlistindex  : skip 2
    }
    
    .scroll: {
        ..direction     : skip 2
        
        ..leftbound     : skip 2
        ..rightbound    : skip 2
        ..upbound       : skip 2
        ..downbound     : skip 2
        
        ..cameraspeed    : skip 2
        ;..camerayspeed   : skip 2
        
        ..camerasubspeed : skip 2
        ;..cameraysubspeed: skip 2
        
        ;todo: put other camera stuff here
    }
    
    .prevscene          : skip 2        ;scene to return to after dialog
    
    .scene: {
        ..definitionptr : skip 2
        ..bank          : skip 2
        ..palptr        : skip 2
        ..gfxptr        : skip 2
        ..mapptr        : skip 2
        ..gfxsize       : skip 2
        ..tilemapsize   : skip 2
        ..gameprops     : skip 2        ;pointer to rom where the following was gotten
        ..mode          : skip 2        ;program mode to use for scene
        ..strptr        : skip 2
        ..strline       : skip 2
        ..timer         : skip 2
        ..hdmaobj       : skip 2        ;unused currently
    }
    
    .msg: {
        ..uploadflag    :   skip 2
        ..size          :   skip 2
        ..start         :   skip 2
        ..ptr           :   skip 2
        ..index         :   skip 2
    }
    
    .obj: {
        ..id            :   skip 2*!obj_count+2
        ..xsize         :   skip 2*!obj_count+2
        ..ysize         :   skip 2*!obj_count+2
        ..init          :   skip 2*!obj_count+2
        ..main          :   skip 2*!obj_count+2
        ..touch         :   skip 2*!obj_count+2
        ..tile          :   skip 2*!obj_count+2
        ..draw          :   skip 2*!obj_count+2
        
        ..x             :   skip 2*!obj_count+2
        ..y             :   skip 2*!obj_count+2
        ..var1          :   skip 2*!obj_count+2
        ..var2          :   skip 2*!obj_count+2
        ..var3          :   skip 2*!obj_count+2
        
        ..screenupdates :   skip 2
        ..drawindex     :   skip 2
        ..index         :   skip 2
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
        !k_hdma_objects_count   =   $0007
        ..id        :   skip 2*!k_hdma_objects_count+2
        ..init      :   skip 2*!k_hdma_objects_count+2
        ..routine   :   skip 2*!k_hdma_objects_count+2
        ..timer     :   skip 2*!k_hdma_objects_count+2
        ..table     :   skip 2*!k_hdma_objects_count+2
        ..params    :   skip 2*!k_hdma_objects_count+2  ;for $4300 and $4301 write at once
        ..var       :   skip 2*!k_hdma_objects_count+2
        ..bank      :   skip 2*!k_hdma_objects_count+2  ;low byte = direct bank, high byte = indirect bank
        
    }
    
    .glow: {
        !glow_objects_count = $0008
        
        ..enable        : skip 2
        
        ..id                : skip 2*!glow_objects_count+2
        ..init              : skip 2*!glow_objects_count+2
        ..routine           : skip 2*!glow_objects_count+2
        ..timer             : skip 2*!glow_objects_count+2
        ..colorindex        : skip 2*!glow_objects_count+2
        ..list              : skip 2*!glow_objects_count+2
        ..liststart         : skip 2*!glow_objects_count+2
        ..colorindexstart   : skip 2*!glow_objects_count+2
    }
    
    print "work ram end:   ", pc
    
    org $7ec000
    .cgrambuffer    :   skip !k_cgrambuffersize
    
    org $7ee000
    .msgbuffer      :   skip $800
    
    org $7ef000
    .cgblastbuffer  :   skip $80
}

org $7f0000


;decompressionbuffer overlaps level data:
;decompress graphics here, upload to vram, then decompress level data here


l: {
    .level: {
        ..screen0   :   skip $800
        ..screen1   :   skip $800
        ..screen2   :   skip $800
        ..screen3   :   skip $800
        
        ..extra     :   skip $6000      ;reserved space
    }
    .decompressionbuffer    :   skip $8000
}