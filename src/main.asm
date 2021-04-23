
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
    screen_format_ptr: resq 1

section .data

section .text
align 16
_start:

    ; may (definitely will) need space for locals later
    sub rsp, 32

    mov rdi, cSDL_INIT_EVERYTHING
    call SDL_Init

    mov rdi, cSCREEN_WIDTH
    mov rsi, cSCREEN_HEIGHT
    mov rdx, cBITS_PER_PIXEL
    mov rcx, cSDL_HWSURFACE
    or  rcx, cSDL_DOUBLEBUF
    ;or  rcx, cSDL_FULLSCREEN
    call SDL_SetVideoMode

    ; save screen and screen format information
    mov [screen_ptr], rax
    mov rax, qword [rax + 8]
    mov [screen_format_ptr], rax

    ; swap buffers
    mov rdi, [screen_ptr]
    call SDL_Flip

    ; delay for one second
    mov rdi, 1000
    call SDL_Delay

    ; let SDL clean itself up
    call SDL_Quit

    ; exit program
    add rsp, 32 ; destroy pseudo-stackframe
    mov rbx, 0 ; exit code
    mov rax, 1 ; syscall (exit)
    int 0x80   ; sw interrupt
