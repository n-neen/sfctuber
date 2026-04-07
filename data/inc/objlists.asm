objlist: {
    macro obj_list_entry(type, x, y, var1, var2, var3)
        dw <type>
        db <x>
        db <y>
        dw <var1>
        dw <var2>
        dw <var3>
    endmacro
    
    .definitionstart:
        ;this is used in defines.asm to determine the length of each entry
                        ;type       x   y    var1   var2   var3
        %obj_list_entry (obj_door, $10, $50, $1111, $2222, scenedef_room2)
    .definitionend:
    
    .room1: {
                         ;type,      x    y    var1,  var2,  var3
        %obj_list_entry (obj_door,  $39, $32, $0234, $0000, scenedef_room2)
        
        %obj_list_entry (obj_solid, $10, $10, $0000, $0000, $0000)
        dw $ffff    ;terminator
    }
    
    .room2: {
                        ;type,             x    y   var1,  var2,  var3
        %obj_list_entry (obj_door,        $1a, $13, $0234, $0223, scenedef_room1)
        %obj_list_entry (obj_texttrigger, $1a, $33, $2012, $0003, str_testtext)
        %obj_list_entry (obj_texttrigger, $2a, $33, $2012, $0008, str_text2)
        dw $ffff    ;terminator
    }
}
