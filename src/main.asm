;
; as per the System-V ABI, registers are allocated in the order:
;   rdi, rsi, rdx, rcx, r8, r9
;


; let assembler know where to start
global _start

%include 'mainexterns.asm'

%define cSDL_HWSURFACE       1
%define cSDL_DOUBLEBUF       1073741824
%define cSDL_FULLSCREEN      2147483648
%define cSDL_INIT_EVERYTHING 65535
%define cSCREEN_HEIGHT       800
%define cSCREEN_WIDTH        1000
%define cBITS_PER_PIXEL      32

section .bss
    screen_ptr: resq 1
    screen_format: resq 1

    draw_type_callback: resq 1

section .data

    game_title: db "not-logic.ly", 0x00

    and_gate_type_string:  db "AND",  0x00
    nand_gate_type_string: db "NAND", 0x00
    or_gate_type_string:   db "OR",   0x00    
    nor_gate_type_string:  db "NOR",  0x00
    not_gate_type_string:  db "NOT",  0x00
    none_gate_type_string: db "none", 0x00

section .text

align 16
_start:

    ; may (definitely will) need space for locals later
    ; stack must be aligned on 16-byte boundary before call-ing subroutines
    sub rsp, 32 

    mov rdi, cSDL_INIT_EVERYTHING
    call SDL_Init

    ; SDL_SetVideoMode( rdi:width, rsi:height, rdx:bpp, rcx:flags )
    mov rdi, cSCREEN_WIDTH
    mov rsi, cSCREEN_HEIGHT
    mov rdx, cBITS_PER_PIXEL
    mov rcx, cSDL_HWSURFACE
    or  rcx, cSDL_DOUBLEBUF
    ;or  rcx, cSDL_FULLSCREEN ; uncomment to make fullscreen
    call SDL_SetVideoMode ; SDL_Surface* returned in rax

    ; save screen and screen format information
    mov [screen_ptr], rax
    mov rax, qword [rax + 8] ; offset of SDL_Surface->format is 8 btyes
    mov [screen_format], rax

    mov rdi, rax ; rax currently has SDL_Surface->format
    call setup_colors
    call clear_inputs

    mov qword [draw_type_callback], none_gate_type_string

  main_loop_start:

    mov rdi, mouse_click_callback
    call evaluate_inputs

    ; draw_rect( rdi:SDL_Surface*, rsi:x, rdx:y, rcx:w, r8:h, r9:color )
    mov rdi, [screen_ptr]
    mov rsi, 0   ; x
    mov rdx, 0   ; y
    mov rcx, 1000 ; w
    mov r8, 800  ; h
    mov r9, [black + 0] ; color
    call draw_rect

    ; draw UI elements
    mov rdi, [screen_ptr]
    mov esi, dword [navy + 0]
    call update_ui

    ; draw_string( rdi:SDL_Surface*, rsi:x, rdx:y, rcx:char*, r8:color, r9:scale )
    mov rdi, [screen_ptr]
    mov rsi, 300 ; x
    mov rdx, 10  ; y
    mov rcx, game_title
    mov r8d, [white + 0]
    mov r9, 4 ; scale
    call draw_string

    ; draw_string( rdi:SDL_Surface*, rsi:x, rdx:y, rcx:char*, r8:color, r9:scale )
    mov rdi, [screen_ptr]
    mov rsi, 10 ; x
    mov rdx, 750 ; y
    mov rcx, qword [draw_type_callback]
    mov r8d, dword [red + 0]
    mov r9, 4
    call draw_string

    ; draw_and_gate( rdi:SDL_Surface*, rsi:x, rdx:y, rcx:color )
    mov rdi, [screen_ptr]
    ;mov esi, 500 ; x
    ;mov edx, 100 ; y
    mov esi, [mouse_X]
    mov edx, [mouse_Y]
    mov ecx, dword [white + 0] ; color
    call draw_and_gate

    ; swap buffers
    mov rdi, [screen_ptr]
    call SDL_Flip

    ; delay for some time
    mov rdi, 20
    call SDL_Delay


    mov al, byte [ quit_p ]
    or al, byte [ key_esc ]
    jnz program_exit
    jmp main_loop_start

  program_exit:
    ; let SDL clean itself up
    call SDL_Quit

    ; exit program
    add rsp, 32 ; destroy pseudo-stackframe
    mov rbx, 0 ; exit code
    mov rax, 1 ; syscall (exit)
    int 0x80   ; sw interrupt


align 16
mouse_click_callback:
    push rbp
    mov rbp, rsp

    mov edi, dword [mouse_X]
    mov esi, dword [mouse_Y]
    call check_button_press

  mouse_click_callback_check_and:
    cmp eax, 0 ; 0=AND
    jne mouse_click_callback_check_nand
    mov qword [draw_type_callback], and_gate_type_string
    jmp mouse_click_callback_end

  mouse_click_callback_check_nand:
    cmp eax, 1 ; 1=NAND
    jne mouse_click_callback_check_or
    mov qword [draw_type_callback], nand_gate_type_string
    jmp mouse_click_callback_end


  mouse_click_callback_check_or:
    cmp eax, 2 ; 2=OR
    jne mouse_click_callback_check_nor
    mov qword [draw_type_callback], or_gate_type_string
    jmp mouse_click_callback_end


  mouse_click_callback_check_nor:
    cmp eax, 3 ; 3=NOR
    jne mouse_click_callback_check_not
    mov qword [draw_type_callback], nor_gate_type_string
    jmp mouse_click_callback_end


  mouse_click_callback_check_not:
    cmp eax, 4 ; 4=NOT
    jne mouse_click_callback_none
    mov qword [draw_type_callback], not_gate_type_string
    jmp mouse_click_callback_end


  mouse_click_callback_none:
    mov qword [draw_type_callback], none_gate_type_string

  mouse_click_callback_end:
    mov rsp, rbp
    pop rbp
    ret

