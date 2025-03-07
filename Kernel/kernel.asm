; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================

%include "print.mac"

global start


; COMPLETAR - Agreguen declaraciones extern según vayan necesitando
extern A20_enable
extern GDT_DESC

extern screen_draw_layout

extern IDT_DESC
extern idt_init

extern pic_reset
extern pic_enable

extern mmu_init_kernel_dir
extern copy_page
extern mmu_init_task_dir

extern tss_init
extern tasks_screen_draw
extern sched_init
extern tasks_init

; COMPLETAR - Definan correctamente estas constantes cuando las necesiten
%define CS_RING_0_SEL 0x8   
%define DS_RING_0_SEL 24   

%define TASK_INIT_SEL 88 ; (11 << 3, selector de segmento de init task)
%define TASK_IDLE_SEL 96 ; (12 << 3, selector de segmento de idle task)

%define DIVISOR 0x800

BITS 16
;; Saltear seccion de datos
jmp start

;;
;; Seccion de datos.
;; -------------------------------------------------------------------------- ;;
start_rm_msg db     'Iniciando kernel en Modo Real'
start_rm_len equ    $ - start_rm_msg

start_pm_msg db     'Iniciando kernel en Modo Protegido'
start_pm_len equ    $ - start_pm_msg

;;
;; Seccion de código.
;; -------------------------------------------------------------------------- ;;

;; Punto de entrada del kernel.
BITS 16
start:
    ; COMPLETAR - Deshabilitar interrupciones
    cli

    ; Cambiar modo de video a 80 X 50
    mov ax, 0003h
    int 10h ; set mode 03h
    xor bx, bx
    mov ax, 1112h
    int 10h ; load 8x8 font

    ; COMPLETAR - Imprimir mensaje de bienve3nida - MODO REAL
    ; (revisar las funciones definidas en print.mac y los mensajes se encuentran en la
    ; sección de datos)
    print_text_rm start_rm_msg, start_rm_len, 4, 0, 0

    ; COMPLETAR - Habilitar A20
    call A20_enable
    ;-------------------------------------------------------------------------
    ; (revisar las funciones definidas en a20.asm)

    ; COMPLETAR - Cargar la GDT
    lea eax, [GDT_DESC]
    lgdt [eax]

    ; COMPLETAR - Setear el bit PE del registro CR0
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    ; COMPLETAR - Saltar a modo protegido (far jump)
    jmp CS_RING_0_SEL:modo_protegido

    ; (recuerden que un far jmp se especifica como jmp CS_selector:address)
    ; Pueden usar la constante CS_RING_0_SEL definida en este archivo

BITS 32
modo_protegido:
    ; COMPLETAR - A partir de aca, todo el codigo se va a ejectutar en modo protegido
    ; Establecer selectores de segmentos DS, ES, GS, FS y SS en el segmento de datos de nivel 0

    mov ax, DS_RING_0_SEL
    mov ds, ax
    mov es, ax
    mov gs, ax
    mov fs, ax
    mov ss, ax

    ; Pueden usar la constante DS_RING_0_SEL definida en este archivo

    ; COMPLETAR - Establecer el tope y la base de la pila
    mov esp, 0x25000
    mov ebp, esp

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO PROTEGIDO
    print_text_pm start_pm_msg, start_pm_len, 4, 0, 0


    ; COMPLETAR - Inicializar pantalla
    call screen_draw_layout

    
    
    
    call idt_init

    lea eax, [IDT_DESC]
    lidt [eax]

    mov ax, DIVISOR
    out 0x40, al
    rol ax, 8
    out 0x40, al

    call pic_reset
    call pic_enable

    call mmu_init_kernel_dir
    mov cr3, eax


    mov eax, cr0 
    or eax, 0x80000000
    mov cr0, eax

    call tss_init

	push 0x18000
	call mmu_init_task_dir
	; ahora el cr3 de la tarea está en eax
  ;  mov edi, cr3
  ;  mov cr3, eax

	;mov byte [0x07000000], 0x1
	;mov byte [0x07000001], 0x1

	;mov cr3, edi

    call sched_init
    call tasks_init

    call tasks_screen_draw

    mov ax, TASK_INIT_SEL
	ltr ax
	jmp TASK_IDLE_SEL:0

	mov eax, 0xFFFF
	mov ebx, 0xFFFF
	mov ecx, 0xFFFF
	mov edx, 0xFFFF
	jmp $

    ; Ciclar infinitamente 
    
;; -------------------------------------------------------------------------- ;;

%include "a20.asm"
