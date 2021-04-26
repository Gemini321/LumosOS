;**********************************
;* lab3
;* LumosOS：独立内核操作系统
;* 作者：pwx
;* 日期：2021.4.12
;**********************************

params:
    org 7c00h               ;主引导扇区偏移量
    kernelSeg equ 800h     ;内核存放绝对地址

start:
    mov ax, cs              ;实模式段地址初始化
    mov ds, ax
    mov es, ax
    mov ss, ax

load_kernel:
    mov ax, kernelSeg       ;将内核加载至内存
    mov es, ax
    mov bx, 100h            ;程序被加载的地址为ES: BX
    mov ah, 2               ;功能号
    mov al, 9               ;扇区数
    mov dh, 0               ;磁头号，初始编号为0
    mov dl, 0               ;驱动器类型：软盘为0，硬盘和U盘为080h
    mov ch, 0               ;柱面号，起始编号为0
    mov cl, 2               ;起始扇区号，起始编号为1
    int 13h                 ;调用BIOS的读硬盘服务
    jmp kernelSeg: 100h     ;内核地址为800h: 100h = 8100h

end:
    jmp $                   ;无限循环

    times 510 - ($ - $$) db 0
    db 055h, 0aah
