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
%define cSCREEN_HEIGHT       600
%define cSCREEN_WIDTH        800
%define cBITS_PER_PIXEL      32

section .bss
    screen_ptr: resq 1
    screen_format: resq 1

section .data

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

    mov qword [rsp + 0], color_lut_begin

  main_loop_start:

    xor rdi, rdi
    call evaluate_inputs

    ; draw_rect( rdi:SDL_Surface*, rsi:x, rdx:y, rcx:w, r8:h, r9:color )
    mov rdi, [screen_ptr]
    mov rsi, 200 ; x
    mov rdx, 200 ; y
    mov rcx, 400 ; w
    mov r8,  200 ; h
    mov r9, [rsp + 0]       ; address of color
    mov r9d, dword [r9 + 0] ; actual color
    call draw_rect

    ; draw_line( rdi:SDL_Surface*, rsi:x0, rdx:y0, rcx:x1, r8:y1, r9:color )
    mov rdi, [screen_ptr]
    xor rsi, rsi
    xor rdx, rdx
    mov rcx, 799
    mov r8, 599
    mov r9d, dword [yellow + 0]
    call draw_line

    mov rdi, [screen_ptr]
    mov rsi, 799
    xor rdx, rdx
    xor rcx, rcx
    mov r8, 599
    mov r9d, dword [yellow + 0]
    call draw_line

    mov rdi, [screen_ptr]
    mov esi, dword [navy + 0]
    call update_ui

    ; draw_circle( rdi:SDL_Surface*, rsi:x, rdx:y, rcx:radius, r8:color )
    mov rdi, [screen_ptr]
    mov esi, 400 ; x
    mov edx, 400 ; y
    mov ecx, 100 ; radius
    mov r8d, dword [fuschia + 0] ; color
    call draw_circle

    ; swap buffers
    mov rdi, [screen_ptr]
    call SDL_Flip

    ; delay for some time
    mov rdi, 100
    call SDL_Delay

    ;add qword [rsp + 0], 8 ; advance to next color
    ;mov rax, [rsp + 0]     ; get new color source ptr
    ;cmp rax, color_lut_end ; compare iterator to end
    ;jne main_loop_start    ; repeat until end

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


