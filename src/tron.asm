assume CS:CODE
CODE SEGMENT
    const = 320
    START:
        mov ax, CODE
        mov DS, ax

        mov ax, 0003h ; clear screen (text mode)
        int 10h

        MENU:
            MENU_OUT:
                mov ah, 09h
                mov dx, offset menu_content
                int 21h

            MENU_IN:
                xor ax, ax
                int 16h

                cmp ah, 28
                jz VIDEO_INIT

                cmp al, 27
                jz QUIT

                JMP MENU_IN

        QUIT:
            mov ax, 4c00h
            int 21h

        VIDEO_INIT:
            mov ax, 0013h ; video mode
            int 10h

            mov ax, 0a000h
            mov ES, ax

            xor bl, bl
            xor di, di
            mov cx, 64000
            clear:
                mov ES:[di], bl
                inc di
                loop clear
	        mov si, const
            mov bl, 48 ;green border
        ;--------------------------------------------------------------------
        Border:
        
            xor di, di
            xor cx, cx

            horizontal:
                xor ax, ax ; Y
                mul si ; Y * 320
                add ax, cx ; Y * 320 + X
                mov di, ax
                mov ES:[di], bl

                mov ax, 199 ; Y
                mul si ; Y * 320
                add ax, cx ; Y * 320 + X
                mov di, ax

                mov ES:[di], bl

                inc cx
                cmp cx, 319
                jle horizontal

            ;-------------------------------------------------------------------- 
            
            xor di, di
            xor cx, cx

            vertical:
                mov ax, cx ; Y
                mul si ; Y * 320 + X
                mov di, ax
                mov ES:[di], bl

                mov ax, cx ; Y
                mul si ; Y * 320
                add ax, 319 ; Y * 320 + X
                mov di, ax

                mov ES:[di], bl


                inc cx
                cmp cx, 200
                jle vertical

            ;-------------------------------------------------------------------- 
        inits:
            p2_init:
                mov ax, 100 ; Y 
                mul si ; Y * 320
                add ax, 240 ; Y * 320 + X
                mov di, ax

                push di
                mov di, offset p2i
                mov bx, -1
                mov [di], bx
                pop di
            ;--------------------------------------------------------------------
            p1_init:
                mov ax, 100 ; Y
                mul si ; Y * 320
                add ax, 80 ; Y * 320 + X
                mov si, ax
                
                push si
                mov si, offset p1i
                mov bx, 1
                mov [si], bx
                pop si
            ;--------------------------------------------------------------------
        jmp Schedule
        GAMEOVER:
            jmp MENU_OUT

        Game:
            mov ah, 01h
            int 16h
            jz Schedule

            xor ax, ax
            int 16h
            jmp CheckInput1

        Schedule:
            xor ah, ah
            int 1ah
            push dx
            timer:
                int 1ah
                pop bx
                sub dx, bx
                push bx
                cmp dx, 1
                jnc Draw
            jmp timer

        wins:
            p2wins:
                mov ax, 0013h ; video mode
                int 10h

                mov ax, 0003h ; text mode
                int 10h

                mov dx, offset p2win
                mov ah, 09h
                int 21h

                jmp GAMEOVER
            ;-------------------------------------------------------------------- 
            p1wins:
                mov ax, 0013h ; video mode
                int 10h

                mov ax, 0003h ; text mode
                int 10h

                mov dx, offset p1win
                mov ah, 09h
                int 21h

                jmp GAMEOVER
            ;--------------------------------------------------------------------
        Draw:
            p1:
                mov al, 43 ;orange
                mov ES:[si], al

                push si
                mov si, offset p1i
                mov bx, [si] 
                pop si
                add si, bx

                xor bh, bh
                cmp ES:[si], bh
                jnz p2wins

                mov al, 39 ;red
                mov ES:[si], al
            ;--------------------------------------------------------------------
            p2:
                mov al, 52 ;light blue
                mov ES:[di], al

                push di
                mov di, offset p2i
                mov bx, [di]
                pop di
                add di, bx

                xor bh, bh
                cmp ES:[di], bh
                jnz p1wins

                mov al, 55 ;dark blue
                mov ES:[di], al
            ;--------------------------------------------------------------------
            jmp Game
        ;--------------------------------------------------------------------
        CheckInputs:
            CheckInput1:
                push si
                cmp al, 'a'
                jz p1Left

                cmp al, 'd'
                jz p1Right

                cmp al, 'w'
                jz p1Upwards

                cmp al, 's'
                jz p1Downwards

                jmp CheckInput2

                p1Left:
                    mov si, offset p1i

                    mov bx, [si]
                    cmp bx, 1
                    jz Save1

                    mov bx, -1
                    jmp Save1

                p1Right:
                    mov si, offset p1i

                    mov bx, [si]
                    cmp bx, -1
                    jz Save1

                    mov bx, 1
                    jmp Save1

                p1Upwards:
                    mov si, offset p1i
                
                    mov bx, [si]
                    cmp bx, 320
                    jz Save1

                    mov bx, -320
                    jmp Save1

                p1Downwards:
                    mov si, offset p1i

                    mov bx, [si]
                    cmp bx, -320
                    jz Save1

                    mov bx, 320
                    jmp Save1

                Save1:
                    mov [si], bx
                    pop si
                    jmp Game
            ;--------------------------------------------------------------------
            CheckInput2:
                push di
                cmp ah, 75
                jz p2Left

                cmp ah, 77
                jz p2Right

                cmp ah, 72
                jz p2Upwards

                cmp ah, 80
                jz p2Downwards

                jmp Schedule

                p2Left:
                    mov di, offset p2i

                    ; Opposite direction
                    mov bx, [di]
                    cmp bx, 1
                    jz Save2

                    mov bx, -1
                    jmp Save2

                p2Right:
                    mov di, offset p2i

                    ; Opposite direction
                    mov bx, [di]
                    cmp bx, -1
                    jz Save2

                    mov bx, 1
                    jmp Save2

                p2Upwards:
                    mov di, offset p2i

                    ; Inverz irany
                    mov bx, [di]
                    cmp bx, 320
                    jz Save2

                    mov bx, -320
                    jmp Save2

                p2Downwards:
                    mov di, offset p2i

                    ; Inverz irany
                    mov bx, [di]
                    cmp bx, -320
                    jz Save2

                    mov bx, 320
                    jmp Save2

                Save2:
                    mov [di], bx
                    pop di
                    jmp Game
        ;--------------------------------------------------------------------
        menu_content db "ENTER. Start game",10,"ESC. Quit",10,"$"
        p1win db "Game over. (Orange won)",10,"$"
        p2win db "Game over. (Blue won)",10,"$"
        p1i dw 1
        p2i dw -1
CODE ENDS
END START
