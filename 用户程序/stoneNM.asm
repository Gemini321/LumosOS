; ����Դ���루stone.asm��
; ���������ı���ʽ��ʾ���ϴ�������A,��45���������˶���ײ���߿����,�������.
;  ��Ӧ�� 2014/3
;   NASM/MASM����ʽ
    Dn_Rt equ 1                  ;D-Down,U-Up,R-right,L-Left
    Up_Rt equ 2                  ;
    Up_Lt equ 3                  ;
    Dn_Lt equ 4                  ;
    delay equ 3000					; ��ʱ���ӳټ���,���ڿ��ƻ�����ٶ�
    ddelay equ 580					; ��ʱ���ӳټ���,���ڿ��ƻ�����ٶ�
    org 08100h					; ������������COM
init:
    push ax
    push bx
    push cx
    push dx
    push bp
    mov bp, sp
clear:                  ; �����Ļ�������ַ�
    mov ah, 6           ; ��ʼ����Ļ
    mov al, 0           ; ��ʾ��ģʽ��80x25 16ɫ��
    mov ch, 0           ; ���Ͻ��к�
    mov cl, 0           ; ���Ͻ��к�
    mov dh, 24          ; ���½��к�
    mov dl, 79          ; ���½��к�
    mov bh, 0           ; ʹ�ú�ɫ���
    int 010h            ; BIOS����ʾ�����жϷ���
start:
    mov ax,cs					;��ó�������ʱ����������ڴ��λ��
	mov ds,ax					; DS = CS
	mov ss,ax					; SS = CS
	mov	ax,0B800h				; �ı������Դ���ʼ��ַ
	mov	es,ax					; ES = B800h
    mov byte[char],'A'
loop1:
	dec word[count]				; �ݼ���������
	jnz loop1					; >0����ת;
	mov word[count],delay
	dec word[dcount]				; �ݼ���������
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
    xor ax,ax                 ; �����Դ��ַ��addr = 2 x (cur_x x 80 + cur_y)��cur_x��cur_y�ֱ�����word[x]��word[y]�У�
    mov ax,word[x]
	mov bx,80
	mul bx
	add ax,word[y]
	mov bx,2
	mul bx
	mov bp,ax
	mov ah,0Fh				;  0000���ڵס�1111�������֣�Ĭ��ֵΪ07h����������ʾ�ַ�����
	mov al,byte[char]			;  AL = ��ʾ�ַ�ֵ��Ĭ��ֵΪ20h=�ո��������������ʾbyte[char] = 'A'
	mov word[es:bp],ax  		;  NASM��࣬��ʾ�ַ���ASCII��ֵ����1 word=16 bits��ֵ���Դ���Ӧλ��
;	mov word es:[bp],ax  		;  TASM/MASM��࣬��ʾ��?��ASCII��ֵ
	jmp loop1

keybroad_input:
    mov ah, 0           ; �Ӽ��̶����ַ�������ASCII���͸�AL
    int 016h            ; ����I/O�ж�

end:
    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
    ret
    jmp 0x0800: 0x0100  ; �����ں�
	
datadef:	
    count dw delay
    dcount dw ddelay
    rdul db Dn_Rt         ; �������˶�
    x    dw 7
    y    dw 0
    char db 'A'
    return_addr dw 00000h, 07c00h
    times 512 - ($ - $$) db 0
