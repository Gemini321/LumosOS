; 程序源代码（stone.asm）
; 本程序在文本方式显示器上从左边射出A,以45度向右下运动，撞到边框后反射,如此类推.
;  凌应标 2014/3
;   NASM/MASM汇编格式
    Dn_Rt equ 1                  ;D-Down,U-Up,R-right,L-Left
    Up_Rt equ 2                  ;
    Up_Lt equ 3                  ;
    Dn_Lt equ 4                  ;
    delay equ 3000					; 计时器延迟计数,用于控制画框的速度
    ddelay equ 580					; 计时器延迟计数,用于控制画框的速度
    org 08100h					; 程序用于生成COM
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
    mov ax,cs					;获得程序运行时，代码段在内存的位置
	mov ds,ax					; DS = CS
	mov ss,ax					; SS = CS
	mov	ax,0B800h				; 文本窗口显存起始地址
	mov	es,ax					; ES = B800h
    mov byte[char],'A'
loop1:
	dec word[count]				; 递减计数变量
	jnz loop1					; >0：跳转;
	mov word[count],delay
	dec word[dcount]				; 递减计数变量
      jnz loop1
	mov word[count],delay
	mov word[dcount],ddelay

exit_loop:
    cmp word[x], 0
    jne step
    cmp word[y], 1
    jne step
    jmp keybroad_input

step:
      mov al,1
      cmp al,byte[rdul]
	jz  DnRt
      mov al,2
      cmp al,byte[rdul]
	jz  UpRt
      mov al,3
      cmp al,byte[rdul]
	jz  UpLt
      mov al,4
      cmp al,byte[rdul]
	jz  DnLt
      jmp $	

DnRt:
	inc word[x]
	inc word[y]
	mov bx,word[x]
	mov ax,25
	sub ax,bx
      jz  dr2ur
	mov bx,word[y]
	mov ax,80
	sub ax,bx
      jz  dr2dl
	jmp show
dr2ur:
      mov word[x],23
      mov byte[rdul],Up_Rt	
      jmp show
dr2dl:
      mov word[y],78
      mov byte[rdul],Dn_Lt	
      jmp show

UpRt:
	dec word[x]
	inc word[y]
	mov bx,word[y]
	mov ax,80
	sub ax,bx
      jz  ur2ul
	mov bx,word[x]
	mov ax,-1
	sub ax,bx
      jz  ur2dr
	jmp show
ur2ul:
      mov word[y],78
      mov byte[rdul],Up_Lt	
      jmp show
ur2dr:
      mov word[x],1
      mov byte[rdul],Dn_Rt	
      jmp show

	
	
UpLt:
	dec word[x]
	dec word[y]
	mov bx,word[x]
	mov ax,-1
	sub ax,bx
      jz  ul2dl
	mov bx,word[y]
	mov ax,-1
	sub ax,bx
      jz  ul2ur
	jmp show

ul2dl:
      mov word[x],1
      mov byte[rdul],Dn_Lt	
      jmp show
ul2ur:
      mov word[y],1
      mov byte[rdul],Up_Rt	
      jmp show

	
	
DnLt:
	inc word[x]
	dec word[y]
	mov bx,word[y]
	mov ax,-1
	sub ax,bx
      jz  dl2dr
	mov bx,word[x]
	mov ax,25
	sub ax,bx
      jz  dl2ul
	jmp show

dl2dr:
      mov word[y],1
      mov byte[rdul],Dn_Rt	
      jmp show
	
dl2ul:
      mov word[x],23
      mov byte[rdul],Up_Lt	
      jmp show
	
show:	
    xor ax,ax                 ; 计算显存地址：addr = 2 x (cur_x x 80 + cur_y)（cur_x和cur_y分别存放在word[x]和word[y]中）
    mov ax,word[x]
	mov bx,80
	mul bx
	add ax,word[y]
	mov bx,2
	mul bx
	mov bp,ax
	mov ah,0Fh				;  0000：黑底、1111：亮白字（默认值为07h），设置显示字符属性
	mov al,byte[char]			;  AL = 显示字符值（默认值为20h=空格符），本程序显示byte[char] = 'A'
	mov word[es:bp],ax  		;  NASM汇编，显示字符的ASCII码值；将1 word=16 bits赋值到显存相应位置
;	mov word es:[bp],ax  		;  TASM/MASM汇编，显示字?的ASCII码值
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
    jmp 0x0800: 0x0100  ; 返回内核
	
datadef:	
    count dw delay
    dcount dw ddelay
    rdul db Dn_Rt         ; 向右下运动
    x    dw 7
    y    dw 0
    char db 'A'
    return_addr dw 00000h, 07c00h
    times 512 - ($ - $$) db 0
