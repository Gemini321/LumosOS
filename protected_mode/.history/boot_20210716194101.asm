;*****************************
;*  保护模式引导程序
;*  by pwx, 2021.6.5
;*****************************

    SegAddr equ 0800h
    org 07c00h
start_boot:
    mov ax, cs
    mov ds, ax
    mov ss, ax
    mov es, ax

load_kernel:                ;将内核加载至SegAddr:0x100处
    mov ax, SegAddr
    mov es, ax
    mov bx, 100h            ;程序被加载的地址为ES: BX
    mov ah, 2               ;功能号
    mov al, 17              ;扇区数
    mov dh, 0               ;磁头号，初始编号为0
    mov dl, 0               ;驱动器类型：软盘为0，硬盘和U盘为080h
    mov ch, 0               ;柱面号，起始编号为0
    mov cl, 2               ;起始扇区号，起始编号为1
    int 13h                 ;调用BIOS的读硬盘服务
    jmp SegAddr:0100h

end:
    jmp $

    times 510 - ($ - $$) db 0
    db 055h, 0aah
