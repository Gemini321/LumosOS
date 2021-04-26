extrn _main:near            ;C程序的主函数
extrn _calPos:near          ;C函数，计算当前的光标坐标
extrn _errorPrint:near      ;C函数，打印异常信息；接收一个字符后返回
extrn _exitMode             ;C函数，打印退出界面
extrn _printOuch            ;C函数，打印Ouch信息
extrn _showpro33h:near      ;C函数，显示int 33h中断信息
extrn _showpro34h:near
extrn _showpro35h:near
extrn _showpro36h:near
extrn _cursorX:near         ;C变量，光标的行号
extrn _cursorY:near         ;C变量，光标的列号
extrn _dispPos:near         ;C变量，下一个显存单位的相对偏移地址（相对B800h）
extrn _ch1:near             ;C变量，临时保存字符，避免参数传递
extrn _ch2:near
extrn _ch3:near
extrn _ch4:near
extrn _errorCh:near         ;C变量，异常信息字符，用于传递异常类型
extrn _hour:near            ;C变量，记录当前时间
extrn _min:near
extrn _sec:near
extrn _center_x:near        ;C变量，记录风火轮的显示位置
extrn _center_y:near
extrn _int8h_ip:near        ;C变量，记录int 8h中断的地址
extrn _int8h_cs:near
extrn _int9h_ip:near        ;C变量，记录int 9h中断的地址
extrn _int9h_cs:near
extrn _wheel_cnt:near       ;C变量，风火轮计数器
extrn _ouch_cnt:near        ;C变量，ouch计数器
extrn _ouch_init:near       ;C变量，ouch初始化标志
extrn _ouch:near            ;C变量，ouch标语
.8086
_TEXT segment byte public 'CODE'
DGROUP group _TEXT,_DATA,_BSS
       assume cs:_TEXT
       assume ds:_DATA
org 100h

start_kernel:
    mov ax, cs                  ;实模式段地址初始化
    mov ds, ax
    mov es, ax
    mov ss, ax
    call _setTime
    call _setExtraInt           ;设置33h, 34h, 35h, 36h中断
    call near ptr _main         ;调用C的主函数
    call _exitMode              ;打印退出界面

Timer proc                      ;无敌风火轮！
    cli
    push ax
    push bx
    push cx
    push dx
    push ds
    push es
    push ss
    push bp
    push si
    push di

    mov dx, 0b800h
    mov es, dx
    mov bh, 0fh
    mov dx, word ptr [_wheel_cnt]
    cmp dx, 0
    jg cmp_wheel_cnt
    mov word ptr [_wheel_cnt], 16
    mov dx, 16
cmp_wheel_cnt:                  ;控制速度：每中断16次，风火轮旋转一周
    cmp dx, 16
    je wheel1
    cmp dx, 12
    je wheel2
    cmp dx, 8
    je wheel3
    cmp dx, 4
    je wheel4
    jmp exit_timer              ;若当前计数器不是4的倍数，不更新风火轮
wheel1:
    mov bl, '|'
    jmp print_wheel
wheel2:
    mov bl, '/'
    jmp print_wheel
wheel3:
    mov bl, '-'
    jmp print_wheel
wheel4:
    mov bl, '\'
    jmp print_wheel
print_wheel:                    ;输出当前风火轮的状态
    xor ax, ax
    mov ax, word ptr [_center_x]
    mov cx, 80
    mul cx
    add ax, word ptr [_center_y]
    SAL ax, 1
    mov di, ax
    ;mov word ptr es:[di], bx
    mov word ptr es:[(24*80+79)*2], bx
exit_timer:
    dec word ptr [_wheel_cnt]
    mov al, 20h
    out 020h, al
    out 0a0h, al
    pop di
    pop si
    pop bp
    pop ss
    pop es
    pop ds
    pop dx
    pop cx
    pop bx
    pop ax
    sti
    iret
Timer endp

keyboard_ouch proc      ;在键盘输入时显示Ouch
    cli
    push ax
    push bx
    push cx
    push dx
    push ds
    push es
    push ss
    push bp
    push si
    push di
    call near ptr _printOuch
exit_ouch:
    in al, 60h      ;从60h端口读入一个字符，清除读缓冲区
    mov al, 20h
    out 020h, al
    out 0a0h, al
    pop di
    pop si
    pop bp
    pop ss
    pop es
    pop ds
    pop dx
    pop cx
    pop bx
    pop ax
    sti
    iret
keyboard_ouch endp

pro33h proc
    cli
	call _showpro33h
	sti
	iret
pro33h endp

pro34h proc
    cli
	call _showpro34h
	sti
	iret
pro34h endp

pro35h proc
    cli
	call _showpro35h
	sti
	iret
pro35h endp

pro36h proc
    cli
	call _showpro36h
	sti
	iret
pro36h endp

public _extraInt
_extraInt proc
    int 033h
    int 034h
    int 035h
    int 036h
_extraInt endp

public _setTime
_setTime proc           ;将int 8h中断设置为无敌风火轮！
    cli
    push ax
    push bx
    push cx
    push es
    push si
save_8h:
    mov ax, 0
    mov es, ax
    mov si, 8 * 4
    mov ax, word ptr es:[si]
    mov word ptr [_int8h_ip], ax
    mov ax, word ptr es:[si + 2]
    mov word ptr [_int8h_cs], ax
    mov ax, offset Timer
    mov word ptr es:[si], ax
    mov word ptr es:[si + 2], cs

    pop si
    pop es
    pop cx
    pop bx
    pop ax
    sti
    ret
_setTime endp

public _reTime
_reTime proc            ;恢复原来的int 8h中断
    cli
    push ax
    push bx
    push cx
    push dx
    push ds
    push es
    push ss
    push bp
    push si
    push di
    mov ax, 0
    mov es, ax
    mov si, 8 * 4
    mov bx, word ptr [_int8h_ip]
    mov word ptr es:[si], bx
    mov bx, word ptr [_int8h_cs]
    mov word ptr es:[si + 2], bx

    pop di
    pop si
    pop bp
    pop ss
    pop es
    pop ds
    pop dx
    pop cx
    pop bx
    pop ax
    sti
    ret
_reTime endp

public _setKeyboard
_setKeyboard proc           ;将int 9h中断设置为ouch程序
    cli
    push ax
    push bx
    push cx
    push dx
    push ds
    push es
    push ss
    push bp
    push si
    push di
save_9h:
    mov ax, 0
    mov es, ax
    mov si, 9 * 4
    mov ax, word ptr es:[24h]
    mov word ptr [_int9h_ip], ax
    mov ax, word ptr es:[26h]
    mov word ptr [_int9h_cs], ax
    mov ax, offset keyboard_ouch
    mov word ptr es:[24h], ax
    mov ax, cs
    mov word ptr es:[26h], ax
    mov word ptr [_ouch_init], 1

    pop di
    pop si
    pop bp
    pop ss
    pop es
    pop ds
    pop dx
    pop cx
    pop bx
    pop ax
    sti
    ret
_setKeyboard endp

public _reKeyboard
_reKeyboard proc            ;恢复原来的int 9h中断
    cli
    push ax
    push bx
    push cx
    push dx
    push ds
    push es
    push ss
    push bp
    push si
    push di
    mov ax, 0
    mov es, ax
    mov si, 9 * 4
    mov bx, word ptr [_int9h_ip]
    mov word ptr es:[24h], bx
    mov bx, word ptr [_int9h_cs]
    mov word ptr es:[26h], bx
    mov word ptr [_ouch_init], 0

    pop di
    pop si
    pop bp
    pop ss
    pop es
    pop ds
    pop dx
    pop cx
    pop bx
    pop ax
    sti
    ret
_reKeyboard endp

public _setExtraInt
_setExtraInt proc
    cli
    push ax
    push bx
    push cx
    push dx
    push ds
    push es
    push ss
    push bp
    push si
    push di
    xor  ax,ax
	mov es,ax
	mov word ptr es:[033h * 4],offset pro33h
	mov ax,cs
	mov word ptr es:[033h * 4 + 2],ax
	mov word ptr es:[034h * 4],offset pro34h
	mov word ptr es:[034h * 4 + 2],ax
	mov word ptr es:[035h * 4],offset pro35h
	mov word ptr es:[035h * 4 + 2],ax
	mov word ptr es:[036h * 4],offset pro36h
	mov word ptr es:[036h * 4 + 2],ax

    pop di
    pop si
    pop bp
    pop ss
    pop es
    pop ds
    pop dx
    pop cx
    pop bx
    pop ax
    sti
    ret
_setExtraInt endp

Public	_cprintf
_cprintf proc
	; push	bp         ;sp+2
	; push	es         ;sp+2+2
	; push  ax         ;sp+2+2+2
	push es
	push si
	push di
	push ax
	push bx
	push cx
	push dx
	push bp
	push ds
	
	mov	bp, sp
	mov ax,0b800h
	mov es,ax
	mov	si, word ptr [bp+18+2]      ;fetch the first place of the string
	mov	di, word ptr [_dispPos]     ;fetch the position
	mov	ah, byte ptr [bp +22]
.1:
	mov al,byte ptr [si]            ;fetch the char
	inc si                          ;change to the next place 
	test al,al                      ;text whether empty
	jz .2                           ;empty->2@
	cmp al,0ah                      ;test whther Enter
	jz .3                           ;Enter->3@
	;else:
	mov	ah, byte ptr [bp +22]
	mov word ptr es:[di],ax
	inc byte ptr [_cursorY]
	call near ptr _calPos
	mov di,word ptr [_dispPos]
	jmp .1
.3:                                 ;cursorX ++, cursorY = 0
	inc word ptr [_cursorX]
	mov word ptr [_cursorY],0
	call near ptr _calPos
	mov di,word ptr [_dispPos]
	jmp	.1
.2:
	call _setCursor

    ; pop ax
	; pop es
	; pop bp
	pop ds
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	pop di
	pop si
	pop es
	ret
_cprintf endp

public SCOPY@                   ;局部字符串带初始化作为实参问题补钉程序
SCOPY@ proc 
	arg_0 = dword ptr 6
	arg_4 = dword ptr 0ah
	push bp
	mov bp,sp
    push si
	push di
	push ds
	lds si,[bp+arg_0]
	les di,[bp+arg_4]
	cld
	shr cx,1
	rep movsw
	adc cx,cx
	rep movsb
    pop ds
	pop di
	pop si
	pop bp
	retf 8
SCOPY@ endp

public _setCursor
_setCursor proc
    push ax                 ;保存AX, BX值
    push bx
    push dx
    mov ah, 2               ;功能号为2，设置光标位置
    mov dh, byte ptr [_cursorX]      ;(DH, DL)为光标坐标
    mov dl, byte ptr [_cursorY]
    mov bh, 0               ;BH为显示页码
    int 10h
    pop dx
    pop bx
    pop ax
    ret
_setCursor endp

public _printChar
_printChar proc 
	push bp
    push es
	push ax
    push bx
    mov bp, sp
	;***
    call _setCursor                 ;设置光标位置
    mov ax, 0b800h
	mov es, ax
	mov al, byte ptr [bp+2+2+2+2+2]   ;ch\IP\bp\es\ax\dx，从栈中取出字符
	mov ah, 0fh
	;***
    jmp commonChar                  ;普通字符
commonChar:
    mov bx, word ptr [_dispPos]     ;显示位置
	mov word ptr es:[bx], ax
    mov al, ' '
    mov word ptr es:[bx + 2], ax
    inc word ptr [_cursorY]         ;列号+1
    jmp endPrintChar
endPrintChar:
    call _calPos                    ;重新计算光标坐标
	mov sp,bp
    pop bx
    pop ax
	pop es
	pop bp
	ret
_printChar endp

public _printString
_printString proc
    push es
    push ax
    push bp
    mov ax, 0b800h                  ;ES = B800h
    mov es, ax
    mov bp, sp
    mov si, word ptr [bp+2+2+2+2]   ;stringAddr\IP\es\ax\bp
    mov di, word ptr [_dispPos]     ;DI为显存下一个单元地址
.1@:
    mov ah, 0fh                     ;黑底白字
    mov al, byte ptr [si]           ;AL = char
    inc si                          ;s ++
    cmp al, 0                       ;遇到'\0'，结束输出
    je .2@
    cmp al, 0ah                     ;遇到'\n'，换行
    je .3@
    cmp al, 0dh                     ;遇到'\r'，换行
    je .3@
    mov word ptr es:[di], ax        ;老师代码中的一个BUG：未添加段地址ES；未将AH传入显存
    inc word ptr [_cursorY]         ;列号+1
    call _calPos
    mov di, word ptr [_dispPos]     ;更新下一个显存地址
    jmp .1@
.3@:
    inc word ptr [_cursorX]         ;'\n': cursorX ++, cursorY = 0;
    mov word ptr [_cursorY], 0
    call _calPos
    mov di, word ptr [_dispPos]
    jmp .1@
.2@:
    call _calPos                 ;更新光标位置
    mov di, word ptr [_dispPos]     ;更新下一个显存地址
    mov al, ' '
    mov word ptr es:[_dispPos], ax
    pop bp
    pop ax
    pop es
    ret
_printString endp

public _inputChar
_inputChar proc
    push ax                         ;老师的程序中未压栈保存AX
    call _setCursor                 ;重新设置光标位置
    mov ax,0
	int 16h                         ;返回的结果存放在AL中
    mov byte ptr [_ch1], al         ;将读入的字符放入_ch1中，避免压栈
    pop ax
	ret
_inputChar endp

public _getTime
_getTime proc
    push ax
    push cx
    push dx

    mov ah, 2h                      ;功能号为2：读取时间
    int 1ah                         ;时钟服务
	mov byte ptr[_hour], ch         ;BCD码形式的小时
	mov byte ptr[_min], cl          ;BCD码形式的分钟
	mov byte ptr[_sec], dh          ;BCD码形式的秒

	pop dx
	pop cx
	pop ax
	ret
_getTime endp

public _jump
_jump proc
    push ax
    push bx
    push cx
    push dx
    push ds
    push es
    push ss
    push bp
    push si
    push di
    mov bp, sp
    mov al, byte ptr [bp+20+2] ;ch\IP\ax\bx\cx\dx\bp
    cmp al, 97                      ;ch = 'a'
    je prog_a
    cmp al, 98                      ;ch = 'b'
    je prog_b
    cmp al, 99                      ;ch = 'c'
    je prog_c
    cmp al, 100                     ;ch = 'd'
    je prog_d
    cmp al, 101                     ;ch = 'e'
    je prog_e
    cmp al, 102                     ;ch = 'f'
    je prog_f
    cmp al, 103                     ;ch = 'g'
    je prog_g
    jmp noFile
prog_a:
    mov cl, 11          ;程序a加载11号扇区的内容
    jmp load
prog_b:
    mov cl, 12          ;程序b加载12号扇区的内容
    jmp load
prog_c:
    mov cl, 13          ;程序c加载13号扇区的内容
    jmp load
prog_d:
    mov cl, 14          ;程序d加载14号扇区的内容
    jmp load
prog_e:
    mov cl, 15          ;程序d加载15号扇区的内容
    jmp load
prog_f:
    mov cl, 16          ;程序d加载16号扇区的内容
    jmp load
prog_g:
    mov cl, 17          ;程序d加载17号扇区的内容
    jmp load
load:
    mov ax, cs
    mov es, ax
    mov bx, 8100h       ;将程序加载至ES: BX处（0x0800:0x8100）
    mov ax, 0201h       ;功能号为2，加载的扇区数为1
    mov dx, 0000h       ;磁头号为0，驱动类型为软盘
    mov ch, 0           ;柱面号为0
    int 13h             ;调用BIOS的读磁盘服务

    call _setKeyboard   ;进入ouch模式
    call bx             ;使用call进行程序跳转
    call _reKeyboard    ;退出ouch模式
    pop di
    pop si
    pop bp
    pop ss
    pop es
    pop ds
    pop dx
    pop cx
    pop bx
    pop ax
    ret
noFile:
    mov byte ptr[_errorCh], 'a'
    call _errorPrint    ;打印异常信息：'a'为文件不存在；获取一个字符后返回
    mov sp, bp
    pop di
    pop si
    pop bp
    pop ss
    pop es
    pop ds
    pop dx
    pop cx
    pop bx
    pop ax
    ret                 ;返回主程序
_jump endp

public _clear
_clear proc             ;清除屏幕的所有字符
    push ax             ;保存寄存器
    push bx
    push cx
    push dx
    mov ah, 6           ;初始化屏幕
    mov al, 0           ;显示器模式（80x25 16色）
    mov ch, 0           ;左上角行号
    mov cl, 0           ;左上角列号
    mov dh, 24          ;右下角行号
    mov dl, 79          ;右下角列号
    mov bh, 0           ;使用黑色填充
    int 10h             ;BIOS对显示器的中断服务
    pop dx
    pop cx
    pop bx
    pop ax
    ret
_clear endp

_TEXT ends

;************DATA segment*************
_DATA segment word public 'DATA'
_DATA ends
;*************BSS segment*************
_BSS	segment word public 'BSS'
_BSS ends
;**************end of file***********
end start_kernel