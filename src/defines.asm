;only use these for contants
;DO NOT include # in constants

!exampleconstant = $1234        ;only this
!badconstant     = #$1234       ;never this

;================================ program state constants ==================================

!state_setup      =   $0000
!state_gameloop   =   $0001


;================================= module bank constants ===================================


;!MODULEbanklong           =   (MODULE&$ff0000)
;!MODULEbankword           =   !MODULEbanklong>>8
;!MODULEbankshort          =   !MODULEbanklong>>16

!dmabanklong           =   (dma&$ff0000)
!dmabankword           =   !dmabanklong>>8
!dmabankshort          =   !dmabanklong>>16



;================================ vram address constants ===================================
;before shifting into the format needed to actually use
;with the ppu registers

!bg1tiles           =       $0000
!bg2tiles           =       $0000
!bg3tiles           =       $4000

!bg1tilemap         =       $5000
!bg2tilemap         =       $5400
!bg3tilemap         =       $5c00

!spritegfx          =       $6000


;reference for how much to shift these

!bg1tileshifted     =       !bg1tiles>>12
!bg2tileshifted     =       !bg2tiles>>12
!bg3tileshifted     =       !bg3tiles>>12

!bg1tilemapshifted  =       !bg1tilemap>>10
!bg2tilemapshifted  =       !bg2tilemap>>10
!bg3tilemapshifted  =       !bg3tilemap>>10

!spritegfxshifted   =       !spritegfx>>12

;================================ cgram constants ===================================

!k_cgrambuffersize  =       $0200
