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

    mov qword [rsp + 0], color_lut_begin

  main_loop_start:

    ; draw_rect( rdi:SDL_Surface*, rsi:x, rdx:y, rcx:w, r8:h, r9:color )
    mov rdi, [screen_ptr]
    mov rsi, 200 ; x
    mov rdx, 200 ; y
    mov rcx, 400 ; w
    mov r8,  200 ; h
    mov r9, [rsp + 0]       ; address of color
    mov r9d, dword [r9 + 0] ; actual color
    call draw_rect

    ; swap buffers
    mov rdi, [screen_ptr]
    call SDL_Flip

    ; delay for one second
    mov rdi, 2500
    call SDL_Delay

    add qword [rsp + 0], 8 ; advance to next color
    mov rax, [rsp + 0]     ; 
    cmp rax, color_lut_end ; compare iterator to end
    jne main_loop_start    ; repeat until end

    ; let SDL clean itself up
    call SDL_Quit

    ; exit program
    add rsp, 32 ; destroy pseudo-stackframe
    mov rbx, 0 ; exit code
    mov rax, 1 ; syscall (exit)
    int 0x80   ; sw interrupt
