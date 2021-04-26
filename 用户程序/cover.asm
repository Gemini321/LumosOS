; An assembly program
; by: pwx 2021/3/6

    Left equ 1
    Right equ 2
    Up equ 3
    Down equ 4
    Stop equ 5
    delay equ 3000
    ddelay equ 580
    org 08100h
init:
    push ax
    push bx
    push cx
    push dx
    push bp
    mov bp, sp
clear:                  ; 清除屏幕的所有字符
    mov ah, 6           ; 初始化屏幕
    mov al, 0           ; 显示器模式（80x25 16色）
    mov ch, 0           ; 左上角行号
    mov cl, 0           ; 左上角列号
    mov dh, 24          ; 右下角行号
    mov dl, 79          ; 右下角列号
    mov bh, 0           ; 使用黑色填充
    int 010h            ; BIOS对显示器的中断服务
start:
    mov ax, cs          ; 实地址模式
    mov ss, ax
    mov ds, ax
    mov ax, 0B800h      ; x86显存起始地址
    mov es, ax
    mov byte[char], '*'
    mov byte[direct], Right
    jmp print

loop1:
    dec word[count]     ; 制造延迟
    jnz loop1
    mov word[count], delay
    dec word[dcount]
    jnz loop1
    mov word[dcount], ddelay

    mov al, Left
    cmp al, byte[direct]
    jz GoLeft
    mov al, Right
    cmp al, byte[direct]
    jz GoRight
    mov al, Up
    cmp al, byte[direct]
    jz GoUp
    mov al, Down
    cmp al, byte[direct]
    jz GoDown
    jz middle              ; 输出中间框

middle:
    mov word[LeftBound], 63
    mov word[RightBound], 79
    mov word[UpBound], 19
    mov word[DownBound], 24
    mov word[y], 62
    mov word[x], 20
    jmp loop1

GoLeft:
    dec word[y]
    mov ax, word[LeftBound]
    cmp word[y], ax
    jg print
    mov byte[direct], Up      ; 从向左变为向上
    mov byte[char], '*'
    jmp print

GoRight:
    inc word[y]
    mov ax, word[RightBound]
    cmp word[y], ax
    jl print
    mov byte[direct], Down    ; 从向右变为向下
    mov byte[char], '*'
    jmp print
    
GoUp:
    dec word[x]
    mov ax, word[UpBound]
    cmp word[x], ax
    jg print
    mov byte[direct], Right    ; 从向上变为停止
    mov byte[char], '*'
    cmp word[finish], 1
    je print_name              ; print_num
    inc word[finish]
    jmp middle
    jmp print

GoDown:
    inc word[x]
    mov ax, word[DownBound]
    cmp word[x], ax
    jl print
    mov byte[direct], Left    ; 从向下变为向左
    mov byte[char], '*'
    jmp print

print:
    xor ax, ax          ; 计算偏移地址
    mov ax, word[x]     ; bias = 2 x (cur_x * 80 + cur_y)
    mov bx, 80
    mul bx
    add ax, word[y]
    ;mov bx, 2
    ;mul bx
    SAL ax, 1
    mov bp, ax
    mov ah, 0Fh
    mov al, byte[char]
    mov word[es:bp], ax
    jmp loop1

print_name:
    mov cx, 0
    mov word[y], 70
    mov word[x], 22

loop3:
    cmp cx, 3
    je print_osname
    xor ax, ax          ; 计算偏移地址
    mov ax, word[x]     ; bias = 2 x (cur_x * 80 + cur_y)
    mov bx, 80
    mul bx
    add ax, word[y]
    SAL ax, 1
    mov bp, ax
    mov ah, 0Fh
    mov bx, stu_name
    add bx, cx
    mov al, byte[bx]
    mov word[es:bp], ax
    inc word[y]
    inc cx
    jmp loop3
    jmp print_osname

print_osname:
    mov cx, 0
    mov word[y], 34
    mov word[x], 12

loop4:
    cmp cx, 19
    je keybroad_input
    xor ax, ax          ; 计算偏移地址
    mov ax, word[x]     ; bias = 2 x (cur_x * 80 + cur_y)
    mov bx, 80
    mul bx
    add ax, word[y]
    SAL ax, 1
    mov bp, ax
    mov ah, 04h
    mov bx, os_name
    add bx, cx
    mov al, byte[bx]
    mov word[es:bp], ax
    inc word[y]
    inc cx
    jmp loop4
    mov word[dcount], ddelay

keybroad_input:
    mov ah, 0           ; 从键盘读入字符，并将ASCII码送给AL
    int 016h            ; 键盘I/O中断

end:
    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
    ret
    jmp 0x0800: 0x0100  ; 返回内核

datadef:
    char db 'A'         ; 显示的字符类型
    x dw 0              ; 起始横坐标
    y dw 0              ; 起始纵坐标
    count dw delay
    dcount dw ddelay
    direct db Right     ; 移动方向
    LeftBound dw 0
    RightBound dw 79
    UpBound dw 0
    DownBound dw 24
    finish dw 0
    ;stu_num db "19335163"
    stu_name db "pwx"
    os_name db "Welcome to LumosOS!"
    return_addr dw 07c00h, 00000h

    times 512 - ($ - $$) db 0
