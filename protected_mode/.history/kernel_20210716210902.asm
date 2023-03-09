;*****************************
;*  保护模式内核汇编代码
;*  by pwx, 2021.6.5
;*****************************

    %include "pm.inc"
    PageDirBase equ 80000h
    PageTblBase equ 81000h
    org 0100h               ;内核地址为0x0800:0x100
    jmp LABEL_S16

;GDT段
[SECTION .gdt]  ;段基址为0的段描述符需要填入实际的段基址后才能使用
;GDT                            段基址,             段界限,   描述符属性
LABEL_GDT:          Descriptor      0,                  0, 0        ;空描述符
LABEL_DESC_DATA:    Descriptor      0,        DataLen - 1, DA_DRW
LABEL_DESC_STACK:   Descriptor      0,         TopOfStack, DA_DRWA + DA_32   ;32位段
LABEL_DESC_CODE32:  Descriptor      0,      Code32Len - 1, DA_C + DA_32
LABEL_DESC_CODE16:  Descriptor      0,             0ffffh, DA_C
LABEL_DESC_VEDIO:   Descriptor 0B8000h,            0ffffh, DA_DRW + DA_DPL3
LABEL_DESC_NORMAL:  Descriptor      0,             0ffffh, DA_DRW
LABEL_DESC_LDT:     Descriptor      0,         LDTLen - 1, DA_LDT
LABEL_DESC_CODE_DEST:Descriptor     0,    CodeDestLen - 1, DA_C + DA_32 + DA_DPL0
LABEL_DESC_RING3:   Descriptor      0,   CodeRing3Len - 1, DA_C + DA_32 + DA_DPL3
LABEL_DESC_RING3_STACK: Descriptor  0,    TopOfStackRing3, DA_DRWA + DA_32 + DA_DPL3
LABEL_DESC_TSS:     Descriptor      0,         TSSLen - 1, DA_386TSS
LABEL_DESC_PAGE_DIR:Descriptor PageDirBase,         0fffh, DA_DRW
LABEL_DESC_PAGE_TBL:Descriptor PageTblBase,         8000h, DA_DRW

;门                                目标选择子, 偏移, PCount, 属性
LABEL_CALL_GATE_TEST:   Gate    SelectorDest,   0,       0, DA_386CGate + DA_DPL3

GdtLen  equ $ - LABEL_GDT
GdtPtr  dw  GdtLen - 1      ;段界限
        dd  0               ;段基址（待填入）


;GDT选择子
SelectorData    equ LABEL_DESC_DATA     - LABEL_GDT
SelectorStack   equ LABEL_DESC_STACK    - LABEL_GDT
SelectorCode32  equ LABEL_DESC_CODE32   - LABEL_GDT
SelectorCode16  equ LABEL_DESC_CODE16   - LABEL_GDT
SelectorVedio   equ LABEL_DESC_VEDIO    - LABEL_GDT
SelectorNormal  equ LABEL_DESC_NORMAL   - LABEL_GDT
SelectorLDT     equ LABEL_DESC_LDT      - LABEL_GDT
SelectorDest    equ LABEL_DESC_CODE_DEST - LABEL_GDT
SelectorRing3   equ LABEL_DESC_RING3    - LABEL_GDT + SA_RPL3
SelectorStackRing3  equ LABEL_DESC_RING3_STACK - LABEL_GDT + SA_RPL3
SelectorTSS     equ LABEL_DESC_TSS      - LABEL_GDT
SelectorPageDir equ LABEL_DESC_PAGE_DIR - LABEL_GDT
SelectorPageTbl equ LABEL_DESC_PAGE_TBL - LABEL_GDT

;门选择子
SelectorCallGateTest    equ LABEL_CALL_GATE_TEST - LABEL_GDT + SA_RPL3
;end of [SECTION .gdt]

;IDT
[SECTION .idt]
ALIGN 32
[BITS 32]
LABEL_IDT:
;       门                   目标选择子,        偏移,     DCount, 属性
%rep 32
       Gate              SelectorCode32, SpuriousHandler,    0, DA_386IGate
%endrep
.020h: Gate              SelectorCode32,    ClockHandler,    0, DA_386IGate
%rep 95
       Gate              SelectorCode32, SpuriousHandler,    0, DA_386IGate
%endrep
.080h: Gate              SelectorCode32,  UserIntHandler,    0, DA_386IGate

IdtLen      equ $ - LABEL_IDT
IdtPtr      dw  IdtLen - 1  ;段界限
            dd  0           ;基地址
;end of [SECTION .idt]

;TSS
[SECTION .tss]
ALIGN 32
[BITS 32]
LABEL_TSS:
	dd	0			    ; 上一个任务链接
	dd	TopOfStack		; 0 级堆栈
	dd	SelectorStack	; 
	dd	0			    ; 1 级堆栈
	dd	0			    ; 
	dd	0			    ; 2 级堆栈
	dd	0			    ; 
	dd	0			    ; CR3
	dd	0			    ; EIP
	dd	0			    ; EFLAGS
	dd	0			    ; EAX
	dd	0			    ; ECX
	dd	0			    ; EDX
	dd	0			    ; EBX
	dd	0			    ; ESP
	dd	0			    ; EBP
	dd	0			    ; ESI
	dd	0			    ; EDI
	dd	0			    ; ES
	dd	0			    ; CS
	dd	0			    ; SS
	dd	0			    ; DS
	dd	0			    ; FS
	dd	0			    ; GS
	dd	0			    ; LDT
	dw	0			    ; 调试陷阱标志
	dw	$ - LABEL_TSS + 2	; I/O位图基址
	db	0ffh			; I/O位图结束标志
TSSLen          equ $ - LABEL_TSS

;数据段
[SECTION .data1]
ALIGN   32
[BITS   32]
LABEL_DATA:
;字符串
MyMessage   db "Hello LumosOS!", 0
OffsetMyMessage equ MyMessage - $$
MyMessageLen    equ $ - MyMessage
_szMemChkTitle:		db	"BaseAddrL BaseAddrH LengthLow LengthHigh   Type", 0Ah, 0	; 进入保护模式后显示此字符串
_szRAMSize			db	"RAM size:", 0
_szReturn			db	0Ah, 0

;内存相关变量
RealModeSP  dw  0
_dwMCRNumber:			dd	0	; Memory Check Result
_dwDispPos:			dd	(80 * 6 + 0) * 2	; 屏幕第 6 行, 第 0 列。
_dwMemSize:			dd	0
_ARDStruct:			; Address Range Descriptor Structure
	_dwBaseAddrLow:		dd	0
	_dwBaseAddrHigh:	dd	0
	_dwLengthLow:		dd	0
	_dwLengthHigh:		dd	0
	_dwType:		    dd	0

_MemChkBuf:	times	256	db	0
;IDTR相关变量
_SavedIDTR:             dd  0 ;保存IDTR
                        dd  0
_SavedIMREG:            db  0 ;保存中断屏蔽寄存器值
;时钟变量
_wheel_cnt:             dw 16

; 保护模式下使用这些符号
szMemChkTitle	equ	_szMemChkTitle	- $$
szRAMSize		equ	_szRAMSize	- $$
szReturn		equ	_szReturn	- $$
dwDispPos		equ	_dwDispPos	- $$
dwMemSize		equ	_dwMemSize	- $$
dwMCRNumber		equ	_dwMCRNumber	- $$
ARDStruct		equ	_ARDStruct	- $$
dwBaseAddrLow	equ	_dwBaseAddrLow	- $$
dwBaseAddrHigh	equ	_dwBaseAddrHigh	- $$
dwLengthLow	    equ	_dwLengthLow	- $$
dwLengthHigh	equ	_dwLengthHigh	- $$
dwType		    equ	_dwType		- $$
MemChkBuf		equ	_MemChkBuf	- $$
SavedIDTR       equ _SavedIDTR  - $$
SavedIMREG      equ _SavedIMREG - $$  
wheel_cnt       equ _wheel_cnt  - $$

DataLen         equ $ - LABEL_DATA
;end of [SECTION .data1]

;全局栈段
[SECTION .stack]
ALIGN   32
[BITS   32]
LABEL_STACK:
    times 512 db 0

TopOfStack  equ $ - LABEL_STACK - 1
;end of [SECTION .stack]

;16位代码段
[SECTION .s16]  ;16位代码段不需要段描述符和选择子
[BITS   16]
LABEL_S16:
    mov ax, cs
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov sp, 0100h

    ;为返回实模式做准备
    mov [LABEL_BACK_TO_16 + 3], ax
    mov [RealModeSP], sp

	;得到内存数
	mov	ebx, 0
	mov	di, _MemChkBuf
.loop:
	mov	eax, 0E820h
	mov	ecx, 20
	mov	edx, 0534D4150h
	int	15h                     ;int 15h中断，返回RAM的内存图（只能在实模式调用）
	jc	LABEL_MEM_CHK_FAIL
	add	di, 20
	inc	dword [_dwMCRNumber]
	cmp	ebx, 0
	jne	.loop
	jmp	LABEL_MEM_CHK_OK
LABEL_MEM_CHK_FAIL:
	mov	dword [_dwMCRNumber], 0
LABEL_MEM_CHK_OK:

    ;初始化栈段描述符
    xor eax, eax
    mov ax, ds
    shl eax, 4
    add eax, LABEL_STACK
    mov word [LABEL_DESC_STACK + 2], ax
    shr eax, 16
    mov byte [LABEL_DESC_STACK + 4], al
    mov byte [LABEL_DESC_STACK + 7], ah

    ;初始化数据段描述符
    xor eax, eax
    mov ax, ds
    shl eax, 4
    add eax, LABEL_DATA
    mov word [LABEL_DESC_DATA + 2], ax
    shr eax, 16
    mov byte [LABEL_DESC_DATA + 4], al
    mov byte [LABEL_DESC_DATA + 7], ah

    ;初始化32位代码段描述符
    xor eax, eax
    mov ax, cs
    shl eax, 4
    add eax, LABEL_S32
    mov word [LABEL_DESC_CODE32 + 2], ax
    shr eax, 16
    mov byte [LABEL_DESC_CODE32 + 4], al
    mov byte [LABEL_DESC_CODE32 + 7], ah

    ;初始化32位到16位代码段描述符
    xor eax, eax
    mov ax, cs
    shl eax, 4
    add eax, LABEL_FROM_32_TO_16
    mov word [LABEL_DESC_CODE16 + 2], ax
    shr eax, 16
    mov byte [LABEL_DESC_CODE16 + 4], al
    mov byte [LABEL_DESC_CODE16 + 7], ah

    ;初始化LDT在GDT中的段描述符
    xor eax, eax
    mov ax, ds
    shl eax, 4
    add eax, LABEL_LDT
    mov word [LABEL_DESC_LDT + 2], ax
    shr eax, 16
    mov byte [LABEL_DESC_LDT + 4], al
    mov byte [LABEL_DESC_LDT + 7], ah

    ;初始化LDT中的描述符
    xor eax, eax
    mov ax, ds
    shl eax, 4
    add eax, LABEL_CODE_A
    mov word [LABEL_LDT_DESC_CODEA + 2], ax
    shr eax, 16
    mov byte [LABEL_LDT_DESC_CODEA + 4], al
    mov byte [LABEL_LDT_DESC_CODEA + 7], ah

    ;初始化调用门目的段段描述符
    xor eax, eax
    mov ax, cs
    shl eax, 4
    add eax, LABEL_CODE_DEST
    mov word [LABEL_DESC_CODE_DEST + 2], ax
    shr eax, 16
    mov byte [LABEL_DESC_CODE_DEST + 4], al
    mov byte [LABEL_DESC_CODE_DEST + 7], ah

    ;初始化Ring3段描述符
    xor eax, eax
    mov ax, cs
    shl eax, 4
    add eax, LABEL_RING3
    mov word [LABEL_DESC_RING3 + 2], ax
    shr eax, 16
    mov byte [LABEL_DESC_RING3 + 4], al
    mov byte [LABEL_DESC_RING3 + 7], ah

    ;初始化Ring3栈段描述符
    xor eax, eax
    mov ax, ds
    shl eax, 4
    add eax, LABEL_STACK_RING3
    mov word [LABEL_DESC_RING3_STACK + 2], ax
    shr eax, 16
    mov byte [LABEL_DESC_RING3_STACK + 4], al
    mov byte [LABEL_DESC_RING3_STACK + 7], ah

    ;初始化TSS描述符
    xor eax, eax
    mov ax, ds
    shl eax, 4
    add eax, LABEL_TSS
    mov word [LABEL_DESC_TSS + 2], ax
    shr eax, 16
    mov byte [LABEL_DESC_TSS + 4], al
    mov byte [LABEL_DESC_TSS + 7], ah

    ; 为加载 IDTR 作准备
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_IDT		; eax <- idt 基地址
	mov	dword [IdtPtr + 2], eax	; [IdtPtr + 2] <- idt 基地址

    ;保存IDTR
    sidt [_SavedIDTR]
    ;保存中断屏蔽寄存器(IMREG)的值
    in al, 21h
    mov [_SavedIMREG], al
    ;加载IDTR
    lidt [IdtPtr]

    ;加载GDTR
    xor eax, eax
    mov ax, ds
    shl eax, 4
    add eax, LABEL_GDT
    mov dword [GdtPtr + 2], eax
    lgdt [GdtPtr]

    ;打开A20地址线
    ;cli             ;在保护模式下一直关中断，中断以其他形式实现
    in al, 92h
    or al, 00000010b
    out 92h, al

    ;cr0置PE位
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ;进入保护模式
    jmp dword SelectorCode32:0  ;本指令将SelectorCode32装载进入cs，dword不能少

LABEL_REAL_ENTRY:   ;保护模式跳转为实模式
    ;实模式下恢复段寄存器
    mov ax, cs
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov gs, ax

    mov sp, [RealModeSP]    ;将栈恢复为实模式的栈

    ;IDTR相关设置
    lidt [_SavedIDTR]       ;恢复IDTR原值
    mov al, [_SavedIMREG]   ;恢复原中断屏蔽寄存器(IMREG)原值
    out 21h, al

    ;关闭A20地址线
    in al, 92h
    and al, 11111101b
    out 92h, al

    sti             ;恢复实模式中断

    jmp $           ;死循环
;end of [SECTION .s16]

;32位代码段
[SECTION .s32]
[BITS   32]
LABEL_S32:
    ;初始化段寄存器
    mov ax, SelectorStack
    mov ss, ax
    mov ax, SelectorData
    mov ds, ax
    mov ax, SelectorData
    mov es, ax
    mov ax, SelectorVedio
    mov gs, ax
    mov esp, TopOfStack

    ;初始化8259芯片
    call Init8259A
    xchg bx, bx
    int 079h
    int 080h
    sti

    ;显示一个字符串
    mov dword [dwDispPos], (80 * 10 + 35) * 2
    push OffsetMyMessage
    call DispStr
    add esp, 4          ;参数要记得出栈

    mov dword [dwDispPos], (80 * 11 + 0) * 2
    push szMemChkTitle
    call DispStr
    add esp, 4

    call DispMemSize    ;显示内存信息
    call SetupPaging    ;启动分页机制
    ;call SetRealMode8259A

    mov ax, SelectorTSS
    ltr ax
    push SelectorStackRing3
    push TopOfStackRing3
    push SelectorRing3
    push 0
    retf                ;跳转到SelectorRing3:0处，下面的代码不会执行

    ;加载LDT，执行子程序CodeA
    mov ax, SelectorLDT
    lldt ax
    jmp SelectorLDTCodeA:0  ;在LDT内搜索，跳入局部任务
    jmp $

;Init8259A------------------------------------------------------------
Init8259A:
    mov al, 011h
    out 020h, al        ;主8259，ICW1
    call io_delay

    out 0a0h, al        ;从8259，ICW1
    call io_delay

    mov al, 020h        ;IRQ0对应中断向量0x20
    out 021h, al        ;主8259，ICW2
    call io_delay

    mov al, 028h        ;IRQ8对应中断向量0x28
    out 0a1h, al        ;从8259，ICW2
    call io_delay

    mov al, 04h         ;IR2对应从8259
    out 021h, al        ;主8259，ICW3
    call io_delay

    mov al, 02h         ;对应主8259的IR2
    out 0a1h, al        ;从8259，ICW3
    call io_delay

    mov al, 01h
    out 021h, al        ;主8259，ICW4
    call io_delay

    out 0a1h, al        ;从8259，ICW4
    call io_delay

    ;mov al, 11111111b  ;屏蔽主8259所有中断
    mov al, 11111110b   ;仅开启时钟中断
    out 021h, al        ;主8259，OCW1
    call io_delay

    mov al, 11111111b   ;屏蔽从8259所有中断
    out 0a1h, al        ;从8259，OCW1
    call io_delay
    ret
;Init8259A------------------------------------------------------------

;SetRealMode8259A-----------------------------------------------------
SetRealMode8259A:
    mov ax, SelectorData
    mov fs, ax

    mov al, 017h
    out 020h, al        ;主8259，ICW1
    call io_delay

    mov al, 08h         ;IRQ0对应中断向量0x8
    out 021h, al        ;主8259，ICW2
    call io_delay

    mov al, 01h
    out 021h, al        ;主8259，ICW4
    call io_delay

    mov al, [fs:SavedIMREG] ;恢复原中断屏蔽寄存器(IMREG)的原值
    out 021h, al
    call io_delay
    ret
;SetRealMode8259A-----------------------------------------------------

io_delay:
    nop
    nop
    nop
    nop
    ret

;int handler----------------------------------------------------------
_ClockHandler:
ClockHandler    equ _ClockHandler - $$
    mov ax, SelectorData
    mov ds, ax
    mov bh, 0fh
    mov dx, word [wheel_cnt]
    ;mov dx, 16
    cmp dx, 0
    jg cmp_wheel_cnt
    mov word [wheel_cnt], 16
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
    mov word [gs:(80 * 24 + 79) * 2], bx
exit_timer:
    dec word [wheel_cnt]
    mov al, 20h
    out 020h, al

    iretd



_UserIntHandler:
UserIntHandler  equ _UserIntHandler - $$
    mov ah, 0Ch
    mov al, 'U'
    mov [gs:((80 * 0 + 78) * 2)], ax    ;在屏幕第0行第78列打印字符'U'
    iretd

_SpuriousHandler:
SpuriousHandler equ _SpuriousHandler - $$
    mov ah, 0Ch
    mov al, 'S'
    mov [gs:((80 * 0 + 79) * 2)], ax    ;在屏幕第0行第79列打印字符'S'
    iretd

;启动分页机制----------------------------------------------------------
;简单起见，所有的线性地址等于对应的物理地址，即分页机制开启前后物理地址不变
SetupPaging:            ;计算当前内存并计算页表大小
    xor edx, edx
    mov eax, [dwMemSize]
    mov ebx, 400000h
    div ebx
    mov ecx, eax        ;ecx存放根页表数
    test edx, edx
    jz .no_remainder    ;能整除
    inc ecx             ;如果不能整除，则需要增加一个页表
.no_remainder:
    push ecx            ;暂时保存页表数量

    ;初始化页目录表
    mov ax, SelectorPageDir
    mov es, ax
    xor edi, edi
    xor eax, eax
    mov eax, PageTblBase + PG_P + PG_USU + PG_RWW
.1:
    stosd
    add eax, 4096
    loop .1

    ;初始化页表
    mov ax, SelectorPageTbl
    mov es, ax
    pop eax             ;取出页表数
    mov ebx, 1024
    mul ebx             ;页表项PTE数 = 1024 * 页表数
    mov ecx, eax        ;循环次数 = PTE数
    xor edi, edi
    xor eax, eax
    mov eax, PG_P + PG_USU + PG_RWW
.2:
    stosd
    add eax, 4096
    loop .2

    mov eax, PageDirBase
    mov cr3, eax        ;将页目录表基址载入cr3
    mov eax, cr0
    or eax, 080000000h  ;PG = 1
    mov cr0, eax
    jmp short .3
.3:
    nop
    ret
;分页机制启动完成------------------------------------------------------

    %include "lib.inc"  ;库函数
Code32Len   equ $ - LABEL_S32
;end of [SECTION .s32]

;32位到16位的过渡代码段
[SECTION .from32to16]
ALIGN   32
[BITS   16]
LABEL_FROM_32_TO_16:
    mov ax, SelectorNormal  ;将段属性在保护模式恢复为实模式属性
    mov ds, ax
    mov ss, ax
    mov gs, ax
    mov es, ax
    mov fs, ax

    mov eax, cr0
    and eax, 07ffffffeh     ;PE = 0, PG = 0
    mov cr0, eax

LABEL_BACK_TO_16:
    jmp 0:LABEL_REAL_ENTRY

From32To16Len   equ $ - LABEL_FROM_32_TO_16
;end of [SECTION .from32to16]

;LDT段
[SECTION .ldt]
ALIGN   32
LABEL_LDT:
;LDT                            段基址,        段界限, 段属性
LABEL_LDT_DESC_CODEA: Descriptor    0,  CodeALen - 1, DA_C + DA_32

LDTLen  equ $ - LABEL_LDT

;LDT选择子
SelectorLDTCodeA    equ LABEL_LDT_DESC_CODEA - LABEL_LDT + SA_TIL
;end of [SECTION .ldt]

;CodeA（LDT代码段）
[SECTION .codea]
ALIGN   32
[BITS]  32
LABEL_CODE_A:
    mov ax, SelectorVedio
    mov gs, ax

    mov edi, (80 * 11 + 40) * 2
    mov ah, 0Ch
    mov al, 'L'                 ;打印一个黑底红字的字符'L'
    mov [gs:edi], ax

    ;跳转进入32位到16位的过渡代码段
    jmp SelectorCode16:0
CodeALen    equ $ - LABEL_CODE_A
;end of [SECTION .codea]

;调用门目的段
[SECTION .cdest]
ALIGN 32
[BITS 32]
LABEL_CODE_DEST:
    mov ax, SelectorVedio
    mov gs, ax

    mov edi, (80 * 0 + 40) * 2
    mov ah, 0Ch
    mov al, 'C'                 ;打印一个黑底红字的字符'C'
    mov [gs:edi], ax

    retf
CodeDestLen     equ $ - LABEL_CODE_DEST
;end of [SECTION .cdest]

;Ring3栈段
[SECTION .ring3stack]
ALIGN 32
[BITS 32]
LABEL_STACK_RING3:
    times 512 db 0
TopOfStackRing3 equ $ - LABEL_STACK_RING3 - 1
;end of [SECTION .ring3stack]

;Ring3代码段
[SECTION .ring3code]
ALIGN 32
[BITS 32]
LABEL_RING3:
    mov ax, SelectorVedio
    mov gs, ax

    mov edi, (80 * 0 + 39) * 2
    mov ah, 0Ch
    mov al, '3'                 ;打印一个黑底红字的字符'3'
    mov [gs:edi], ax

    call SelectorCallGateTest:0 ;调用门
    jmp $
CodeRing3Len    equ $ - LABEL_RING3
;end of [SECTION .ring3code]
