;only use these for contants
;DO NOT include # in constants

!exampleconstant = $1234        ;only this
!badconstant     = #$1234       ;never this

;================================ program state constants ==================================

!state_setup        =   $0000
!state_scenehandler =   $0001
!state_loadscene    =   $0002
!state_gameplay     =   $0003
!state_loadgame     =   $0004


;pre-state
;currently not used

!pre_state_none     =   $0000
!pre_state_start    =   $0001
!pre_state_out      =   $0002
!pre_state_in       =   $0003
!pre_state_done     =   $0004


;================================ constants ==================================

!fade_bitmask_default       =   $0005
!fade_timer_default         =   $0010

!scroll_upbound_default     =   $0001
!scroll_downbound_default   =   $00ff
!scroll_leftbound_default   =   $0001
!scroll_rightbound_default  =   $00ff

!camera_subspeed_default    =   $8000       ;default speed = speed.subspeed, set in main.asm
!camera_speed_default       =   $0001

!camera_box_up_bound        =   $0040
!camera_box_dn_bound        =   $0090
!camera_box_lf_bound        =   $0040
!camera_box_rt_bound        =   $00b0


!msg_newline    = $0a
!msg_end        = $00


!obj_list_entry_length      =   datasize(objlist_definitionstart)

!obj_flag_update_screen0    =   %0000000000000001
!obj_flag_update_screen1    =   %0000000000000010
!obj_flag_update_screen2    =   %0000000000000100
!obj_flag_update_screen3    =   %0000000000001000


;controller bit constants
!controller_b                         =       $8000
!controller_y                         =       $4000
!controller_sl                        =       $2000
!controller_st                        =       $1000
!controller_up                        =       $0800
!controller_dn                        =       $0400
!controller_lf                        =       $0200
!controller_rt                        =       $0100
!controller_a                         =       $0080
!controller_x                         =       $0040
!controller_l                         =       $0020
!controller_r                         =       $0010



;================================= module bank constants ===================================

;these are more often than not not being inlined
;at the site where needed

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
!bg2tilemap         =       $6000
!bg3tilemap         =       $6400

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


;============================== scrolling constants =================================

!k_scroll_columnsize    =   $0020
!k_scroll_rowsize       =   $0020               ;keep convention of ram labels = one letter
!k_level_bank           =   (l&$ff0000)>>16     ;label 'l' is for level, it's not a numeral '1'
