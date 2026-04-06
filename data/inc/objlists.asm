objlist: {
    .definitionstart:
        ;this is used in defines.asm to determine the length of each entry
        ;type               xpos   ypos   var1   var2   room ptr (var3 if not transition object)
        dw obj_door,        $1234, $5678, $9abc, $def0, scenedef_room2
    .definitionend:
    
    .room1: {
       ;object type,    x      y      var1,  var2,  roomptr
        dw obj_door,    $0010, $0050, $1111, $2222, scenedef_room2
        dw $ffff    ;terminator
    }
    
    .room2: {
       ;object type,    x      y      var1,  var2,  roomptr
        dw obj_door,    $000c, $0060, $1112, $2223, scenedef_room1
        dw $ffff    ;terminator
    }
}
