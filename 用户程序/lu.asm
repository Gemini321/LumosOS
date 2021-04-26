;   NASM汇编格式
    Dn_Rt equ 1                  ;D-Down,U-Up,R-right,L-Left
    Up_Rt equ 2                  ;
    Up_Lt equ 3                  ;
    Dn_Lt equ 4                  ;
    delay equ 50000					; 计时器延迟计数,用于控制画框的速度
    ddelay equ 580					; 计时器延迟计数,用于控制画框的速度

org 08100h				
start:
	xor ax,ax					; AX = 0   程序加载到0000：100h才能正确执行
    mov ax,cs
	mov es,ax					; ES = 0
	mov ds,ax					; DS = CS
	mov es,ax					; ES = CS
	mov	ax,0B800h				; 文本窗口显存起始地址
    mov	gs,ax					; GS = B800h
    mov byte[char],'*'
	mov byte[rdul],1
	mov byte[color], 5
loop1:
	dec word[count]				; 递减计数变量
	jnz loop1					; >0：跳转;
	mov word[count],delay
	dec word[dcount]				; 递减计数变量
      jnz loop1
	mov word[count],delay
	mov word[dcount],ddelay
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
	;mov byte[color], 1
	mov bx,word[x]
	mov ax,13
	sub ax,bx
      jz  dr2ur
	mov bx,word[y]
	mov ax,40
	sub ax,bx
      jz  dr2dl
	jmp show
dr2ur:
      mov word[x],11
      mov byte[rdul],Up_Rt	
      jmp show
dr2dl:
      mov word[y],38
      mov byte[rdul],Dn_Lt	  
      jmp show

UpRt:
	dec word[x]
	inc word[y]
	;mov byte[color], 2
	mov bx,word[y]
	mov ax,40
	sub ax,bx
      jz  ur2ul
	mov bx,word[x]
	mov ax,0
	sub ax,bx
      jz  ur2dr
	jmp show
ur2ul:
      mov word[y],38
      mov byte[rdul],Up_Lt
      jmp show
ur2dr:
      mov word[x],2
      mov byte[rdul],Dn_Rt
      jmp show

	
	
UpLt:
	dec word[x]
	dec word[y]
	;mov byte[color], 4
	mov bx,word[x]
	mov ax,0
	sub ax,bx
      jz  ul2dl
	mov bx,word[y]
	mov ax,0
	sub ax,bx
      jz  ul2ur
	jmp show

ul2dl:
      mov word[x],2
      mov byte[rdul],Dn_Lt	  
      jmp show
ul2ur:
      mov word[y],2
      mov byte[rdul],Up_Rt
      jmp show

	
	
DnLt:
	inc word[x]
	dec word[y]
	;mov byte[color], 7
	mov bx,word[y]
	mov ax,0
	sub ax,bx
      jz  dl2dr
	mov bx,word[x]
	mov ax,13
	sub ax,bx
      jz  dl2ul
	jmp show

dl2dr:
      mov word[y],2
      mov byte[rdul],Dn_Rt
      jmp show
	
dl2ul:
      mov word[x],11
      mov byte[rdul],Up_Lt  
      jmp show
	
show:
	inc word[cnt]
	mov bx,word[cnt]
    cmp bx,200
	je over
    xor ax,ax                 ; 计算显存地址
    mov ax,word[x]
	mov bx,80
	mul bx
	add ax,word[y]
	mov bx,2
	mul bx
	mov bp,ax
	mov ah,byte[color]				;  0000：黑底、1111：亮白字（默认值为07h）
	mov al,byte[char]			;  AL = 显示字符值（默认值为20h=空格符）
	mov word[gs:bp],ax  		;  显示字符的ASCII码值
	mov ah,13h ; 功能号
	mov al,1 ; 光标放到串尾
	mov bl,04h ; 
	jmp loop1
over:
	ret 	
end:
    jmp $                   ; 停止画框，无限循环 
	
datadef:	
    count dw delay
    dcount dw ddelay
    rdul db Dn_Rt         ; 向右下运动
	color db 1
    x    dw 0
    y    dw 0
    char db '*'
	cnt dw 1
    times 512 - ($ - $$) db 0