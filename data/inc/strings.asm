;===========================================================================================
;===================================                ========================================
;==================================   S T R I N G S   ======================================
;===================================                ========================================
;===========================================================================================




str: {
    .testtext: {
        db "        an act of love"
        db !msg_newline
        db !msg_newline
        db "         remains at last"
        db !msg_newline
        db !msg_newline
        db "          preserved above"
        db !msg_newline
        db !msg_newline
        db "           from robot past"
        
        db !msg_end
    }

    .text2: {
        db "text string 2"
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db "this one is less cool"
        db !msg_end
    }

    .intro1: {
        db "intro text 1"
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db "              intro text 1.1"
        db !msg_end
    }

    .intro2: {
        db "   intro text 2"
        db !msg_end
    }

    .intro3: {
        db "intro text 3 which is way longer"
        db !msg_end
    }

    .intro4: {
        db "intro text 4"
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db !msg_newline
        db "intro text 4.1"
        db !msg_end
    }







}