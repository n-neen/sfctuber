objlist: {
    .definitionstart:
        ;this is used in defines.asm to determine the length of each entry
        ;type               xpos   ypos   var1   var2   var3 (room ptr for door, text ptr for text triggers)
        dw obj_door :    db $10, $50 : dw $1111, $2222, scenedef_room2
    .definitionend:
    
    .room1: {
       ;object type,        x     y       var1,  var2,  var3
        dw obj_door :    db $03, $0b : dw $1111, $2222, scenedef_room2
        dw $ffff    ;terminator
    }
    
    .room2: {
       ;object type,            x     y       var1,  var2,  var3
        dw obj_door        : db $01, $01 : dw $1112, $2223, scenedef_room1
        dw obj_texttrigger : db $1a, $36 : dw $3332, $4442, msg_testtext
        dw $ffff    ;terminator
    }
}
