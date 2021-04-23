;
; as per the System-V ABI, registers are allocated in the order:
;   rdi, rsi, rdx, rcx, r8, r9
;


global draw_rect

extern lerp
extern SDL_FillRect

section .bss
section .data

section .text

;
; rdi = SDL_Surface*
; rsi = x
; rdx = y
; rcx = w
; r8  = h
; r9  = color
;
align 16
draw_rect:
    push rbp     ; create stack frame, realign stack
    mov rbp, rsp ; ...

    sub rsp, 16 ; space for locals (while maintaining 16-byte alignment requirement)

    ; we are going to 'manufacture' an SDL_Rect on the stack
    ;mov [rsp + 0], word si  ; x
    ;mov [rsp + 2], word dx  ; y
    ;mov [rsp + 4], word cx  ; w
    ;mov [rsp + 6], word r8w ; h (thats right, every register has a 16-bit alias)


    ; alternate method uses single memory access
    and rsi, 0xFFFF
    and rdx, 0xFFFF
    and rcx, 0xFFFF
    and r8,  0xFFFF    
    shl rdx, 16 ; shift into y position
    shl rcx, 32 ; shift into w position
    shl r8,  48 ; shift into h position
    or rcx, r8
    or rsi, rdx
    or rcx, rsi ; rcx now contains a full SDL_Rect struct (8 bytes)
    mov [rsp], qword rcx ; single memory access now

    ; get ready to call SDL_FillRect(rdi:SDL_Surface*, rsi:SDL_Rect*, rdx:color)
    ; rdi already has SDL_Surface*
    mov rsi, rsp ; SDL_Rect is on the stack
    mov rdx, r9  ; color
    call SDL_FillRect

    mov rsp, rbp ; destroy stack frame
    pop rbp      ; ...
    ret

;
; rdi = SDL_Surface*
; rsi = x0
; rdx = y0
; rcx = x1
; r8  = y1
; r9  = color
;
align 16
draw_line:
    push rbp
    mov rbp, rsp


    


    mov rsp, rbp
    pop rbp
    ret