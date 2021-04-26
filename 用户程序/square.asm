; An assembly program
; by: pwx 2021/3/6

    Left equ 1
    Right equ 2
    Up equ 3
    Down equ 4
    Stop equ 5
    RightBound equ 79
    DownBound equ 24
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
    mov byte[char], 'A'
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
    jz end              ; 结束

GoLeft:
    dec word[y]
    jnz print
    mov byte[direct], Up      ; 从向左变为向上
    jmp print

GoRight:
    inc word[y]
    cmp word[y], RightBound
    jl print
    mov byte[direct], Down    ; 从向右变为向下
    jmp print
    
GoUp:
    dec word[x]
    jnz print
    mov byte[direct], Stop    ; 从向上变为停止
    jmp print

GoDown:
    inc word[x]
    cmp word[x], DownBound
    jl print
    mov byte[direct], Left    ; 从向下变为向左
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
    cmp byte[direct], Stop
    je keybroad_input
    jmp loop1

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
    ;jmp 0x0800: 0x0100  ; 返回内核

datadef:
    char db 'A'         ; 显示的字符类型
    x dw 0              ; 起始横坐标
    y dw 0              ; 起始纵坐标
    count dw delay
    dcount dw ddelay
    direct db Right     ; 移动方向
    return_addr dw 00000h, 07c00h
    times 512 - ($ - $$) db 0
