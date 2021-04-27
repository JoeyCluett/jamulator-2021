;
; as per the System-V ABI, registers are allocated in the order:
;   rdi, rsi, rdx, rcx, r8, r9
;


global draw_rect
global draw_rect_1x1
global draw_line
global draw_circle

extern lerp
extern euclidean_distance
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

    ; build up and store an instance of SDL_Rect
    and rsi, 0xFFFF ; truncate x to 16 bits
    and rdx, 0xFFFF ; truncate y to 16 bits
    and rcx, 0xFFFF ; truncate w to 16 bits
    and r8,  0xFFFF ; truncate h to 16 bits
    shl rdx, 16 ; shift into y position
    shl rcx, 32 ; shift into w position
    shl r8,  48 ; shift into h position
    or rcx, r8
    or rsi, rdx
    or rcx, rsi ; rcx now contains a full SDL_Rect struct (8 bytes)
    mov [rsp], qword rcx ; single memory access

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
; rsi = x
; rdx = y
; rcx = color
;
; TODO: optimize to avoid explicit stack frame prologue
align 16
draw_rect_1x1:
    push rbp     ; create stack frame
    mov rbp, rsp ; ...

    sub rsp, 16

    and rsi, 0xFFFF ; x
    and rdx, 0xFFFF ; y
    shl rdx, 16     ; shift y into place
    or rsi, rdx     ; combine x and y into rsi
    mov rax, 0x0001000100000000 ; h and w are 1 
    or rsi, rax     ; combine h and w into rsi
    mov [rsp], rsi  ; store full struct on stack

    ; SDL_FillRect(rdi:SDL_Surface*, rsi:SDL_Rect*, rdx:color)
    ; rdi already = SDL_Surface*
    mov rsi, rsp
    mov rdx, rcx
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

    sub rsp, 48

    ; store 32-bit values locally
    mov dword [rsp + 0], esi  ; x0
    mov dword [rsp + 4], edx  ; y0
    mov dword [rsp + 8], ecx  ; x1
    mov dword [rsp + 12], r8d ; y1

    ; store SDL_Surface* locally
    mov qword [rsp + 24], rdi ; SDL_Surface*
    mov dword [rsp + 32], r9d ; color

    ; euclidean_distance( xmm0:x0, xmm1:y0, xmm2:x1 xmm3:y1 ) -> xmm0
    cvtsi2ss xmm0, esi ; convert int to float
    cvtsi2ss xmm1, edx ; ...
    cvtsi2ss xmm2, ecx ; ...
    cvtsi2ss xmm3, r8d ; ...
    call euclidean_distance

    cvtss2si eax, xmm0 ; convert result back into integer
    mov dword [rsp + 16], eax ; one of these copies will change
    mov dword [rsp + 20], eax ; the other wont

  draw_line_loop:
    ; calculate x and y offsets for current pixel

    ; lerp( xmm0:x, xmm1:x_begin, xmm2:x_end, xmm3:y_begin, xmm4:y_end ) -> xmm0
    cvtsi2ss xmm0, dword [rsp + 16] ; x
    pxor xmm1, xmm1                 ; x_begin - always zero
    cvtsi2ss xmm2, dword [rsp + 20] ; x_end
    cvtsi2ss xmm3, dword [rsp + 0]  ; y_begin
    cvtsi2ss xmm4, dword [rsp + 8]  ; y_end
    call lerp ; <-- only uses SSE registers!

    ; save x offset locally
    cvtss2si esi, xmm0 ; x pixel offset

    ; lerp( xmm0:x, xmm1:x_begin, xmm2:x_end, xmm3:y_begin, xmm4:y_end ) -> xmm0
    cvtsi2ss xmm0, dword [rsp + 16] ; x
    pxor xmm1, xmm1                 ; x_begin - always zero
    cvtsi2ss xmm2, dword [rsp + 20] ; x_end
    cvtsi2ss xmm3, dword [rsp + 4]  ; y_begin
    cvtsi2ss xmm4, dword [rsp + 12] ; y_end
    call lerp ; <-- only uses SSE registers!

    ; draw_rect_1x1( rdi:SDL_Surface*, rsi:x, rdx:y, rcx:color )
    mov rdi, qword [rsp + 24]      ; SDL_Surface*
    ; esi already contains x       ; x
    cvtss2si edx, xmm0             ; y
    mov ecx, dword [rsp + 32]      ; color
    call draw_rect_1x1

    ; iterate backwards until zero
    dec dword [rsp + 16] ; decrement every iteration
    jnz draw_line_loop   ; repeat until zero (...pretty sure theres an instruction specifically for this. curse you CISC!)

    mov rsp, rbp
    pop rbp
    ret


;
; rdi = SDL_Surface*
; rsi = x
; rdx = y
; rcx = radius
; r8  = color
;
align 16
draw_circle:
    push rbp     ; create stack frame
    mov rbp, rsp ; ...

    ; intelligent use of temp registers
    push r12 ; y iterator
    push r13 ; x iterator
    push r14 ; persistent (callee-saved) copy of min x
    push rbx ; SDL_Surface*

    sub rsp, 48  ; need a lot of space for locals here

    mov rbx, rdi
    mov qword [rsp + 16], r8  ; save color locally
    cvtsi2ss xmm0, esi ; convert x-center to float
    cvtsi2ss xmm1, edx ; convert y-center to float
    movss dword [rsp + 24], xmm0 ; save fp x-center
    movss dword [rsp + 28], xmm1 ; save fp y-center
    mov dword [rsp + 32], ecx    ; save radius to local storage

    mov rax, rsi ; mov x into rax
    mov r9, rdx  ; mov y into r9
    sub rax, rcx ; calculate min x
    sub r9, rcx  ; calculate min y
    mov r14, rax ; gonna need a copy of min x for each iteration of y
    mov r13, rax ; save min x locally (use callee-saved temp register)
    mov r12, r9  ; save min y locally ...
    shl rcx, 1   ; multiply radius by 2
    add rax, rcx ; calculate max x
    add r9, rcx  ; calculate max y
    mov qword [rsp + 0], rax ; save max x locally
    mov qword [rsp + 8], r9  ; save max y locally

  draw_circle_outer_loop:

    ; setup inner loop
    mov r13, r14 ; move min x to iterator register

  draw_circle_inner_loop:


    ; euclidean_distance( xmm0:x0, xmm1:y0, xmm2:x1, xmm3:y1 )
    ; x:r13, y:r12
    movss xmm0, dword [rsp + 24] ; mov fp x-center
    movss xmm1, dword [rsp + 28] ; mov fp y-center
    cvtsi2ss xmm2, r13 ; convert current x to fp
    cvtsi2ss xmm3, r12 ; convert current y to fp
    call euclidean_distance ; <-- only uses SSE registers

    cvtss2si eax, xmm0         ; convert distance to integer
    cmp eax, dword [rsp + 32]  ; compare distance to radius
    jg inner_loop_afterthought ; skip draw routine if outside of circle

    ; TODO: rewrite to call SDL_FillRect directly
    ; draw_rect_1x1( rdi:SDL_Surface*, rsi:x, rdx:y, rcx:color )
    mov rdi, rbx ; SDL_Surface*
    mov rsi, r13 ; x
    mov rdx, r12 ; y
    mov ecx, dword [rsp + 16] ; color
    call draw_rect_1x1

  inner_loop_afterthought:
    inc r13                    ; increment x iterator
    cmp r13, qword [rsp + 0]   ; compare to max x
    jle draw_circle_inner_loop ; loop while less than

    ; outer loop afterthought
    inc r12                    ; increment y iterator
    cmp r12, qword [rsp + 8]   ; compare to max y
    jle draw_circle_outer_loop ; loop while less than

    add rsp, 48
    pop rbx  ; restore temporary registers (as per Sys-V abi)
    pop r14  ; restore temporary registers (as per Sys-V abi)
    pop r13  ; ...
    pop r12  ; ...

    mov rsp, rbp ; destroy stack frame
    pop rbp      ; ...
    ret
