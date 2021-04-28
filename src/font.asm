global draw_char
global draw_string

extern font_data
extern SDL_FillRect

section .text

;
; rdi = SDL_Surface*
; rsi = x
; rdx = y
; rcx = char value
; r8  = color
; r9  = scale
;
align 16
draw_char:
    push rbp     ; create stack frame
    mov rbp, rsp ; ...

    push r12 ; letter data iter start
    push r13 ; letter data iter end
    push r14 ; scale
    push r15 ; color
    sub rsp, 32 ; space for locals while maintaining stack alignment

    mov qword [rsp + 0], rdi  ; save SDL_Surface* locally
    mov dword [rsp + 8], esi  ; save x value
    mov dword [rsp + 12], edx ; save y value locally
    mov r14, r9 ; save scale locally
    mov r15, r8 ; save color locally

    ; [rsp + 16->19] is reserved for the SDL_Rect structure needed for drawing

    movzx rcx, cl ; zero extend char into full 64-bit register
    shl rcx, 3    ; multiply by 8 to get the correct offset
    lea r12, [font_data + rcx]     ; get address of letter data
    lea r13, [font_data + rcx + 8] ; get end iter of letter data


  draw_char_test_bit_7:
    bt word [r12], 7 ; test bit 7 of current char data
    jnc draw_char_test_bit_6

    ; create SDL_Rect on stack
    mov eax, dword [rsp + 8]  ; fetch x from stack
    mov word [rsp + 16], ax   ; SDL_Rect.x
    mov eax, dword [rsp + 12] ; fetch y from stack
    mov word [rsp + 18], ax   ; SDL_Rect.y
    mov word [rsp + 20], r14w ; SDL_Rect.w
    mov word [rsp + 22], r14w ; SDL_Rect.h

    ; SDL_FillRect( rdi:SDL_Surface*, rsi:SDL_Rect*, rdx:color )
    mov rdi, qword [rsp + 0] ; SDL_Surface*
    lea rsi, [rsp + 16]      ; SDL_Rect is currently hiding out on the stack
    mov rdx, r15             ; color
    call SDL_FillRect

  draw_char_test_bit_6:
    add dword [rsp + 8], r14d ; advance x offset by scale
    bt word [r12], 6 ; test bit 6 of current char data
    jnc draw_char_test_bit_5

    ; create SDL_Rect on stack
    mov eax, dword [rsp + 8]  ; fetch x from stack
    mov word [rsp + 16], ax   ; SDL_Rect.x
    mov eax, dword [rsp + 12] ; fetch y from stack
    mov word [rsp + 18], ax   ; SDL_Rect.y
    mov word [rsp + 20], r14w ; SDL_Rect.w
    mov word [rsp + 22], r14w ; SDL_Rect.h

    ; SDL_FillRect( rdi:SDL_Surface*, rsi:SDL_Rect*, rdx:color )
    mov rdi, qword [rsp + 0] ; SDL_Surface*
    lea rsi, [rsp + 16]      ; SDL_Rect is currently hiding out on the stack
    mov rdx, r15             ; color
    call SDL_FillRect


  draw_char_test_bit_5:
    add dword [rsp + 8], r14d ; advance x offset by scale
    bt word [r12], 5 ; test bit 5 of current char data
    jnc draw_char_test_bit_4

    ; create SDL_Rect on stack
    mov eax, dword [rsp + 8]  ; fetch x from stack
    mov word [rsp + 16], ax   ; SDL_Rect.x
    mov eax, dword [rsp + 12] ; fetch y from stack
    mov word [rsp + 18], ax   ; SDL_Rect.y
    mov word [rsp + 20], r14w ; SDL_Rect.w
    mov word [rsp + 22], r14w ; SDL_Rect.h

    ; SDL_FillRect( rdi:SDL_Surface*, rsi:SDL_Rect*, rdx:color )
    mov rdi, qword [rsp + 0] ; SDL_Surface*
    lea rsi, [rsp + 16]      ; SDL_Rect is currently hiding out on the stack
    mov rdx, r15             ; color
    call SDL_FillRect

  draw_char_test_bit_4:
    add dword [rsp + 8], r14d ; advance x offset by scale
    bt word [r12], 4 ; test bit 4 of current char data
    jnc draw_char_test_bit_3

    ; create SDL_Rect on stack
    mov eax, dword [rsp + 8]  ; fetch x from stack
    mov word [rsp + 16], ax   ; SDL_Rect.x
    mov eax, dword [rsp + 12] ; fetch y from stack
    mov word [rsp + 18], ax   ; SDL_Rect.y
    mov word [rsp + 20], r14w ; SDL_Rect.w
    mov word [rsp + 22], r14w ; SDL_Rect.h

    ; SDL_FillRect( rdi:SDL_Surface*, rsi:SDL_Rect*, rdx:color )
    mov rdi, qword [rsp + 0] ; SDL_Surface*
    lea rsi, [rsp + 16]      ; SDL_Rect is currently hiding out on the stack
    mov rdx, r15             ; color
    call SDL_FillRect

  draw_char_test_bit_3:
    add dword [rsp + 8], r14d ; advance x offset by scale
    bt word [r12], 3 ; test bit 3 of current char data
    jnc draw_char_test_bit_2

    ; create SDL_Rect on stack
    mov eax, dword [rsp + 8]  ; fetch x from stack
    mov word [rsp + 16], ax   ; SDL_Rect.x
    mov eax, dword [rsp + 12] ; fetch y from stack
    mov word [rsp + 18], ax   ; SDL_Rect.y
    mov word [rsp + 20], r14w ; SDL_Rect.w
    mov word [rsp + 22], r14w ; SDL_Rect.h

    ; SDL_FillRect( rdi:SDL_Surface*, rsi:SDL_Rect*, rdx:color )
    mov rdi, qword [rsp + 0] ; SDL_Surface*
    lea rsi, [rsp + 16]      ; SDL_Rect is currently hiding out on the stack
    mov rdx, r15             ; color
    call SDL_FillRect

  draw_char_test_bit_2:
    add dword [rsp + 8], r14d ; advance x offset by scale
    bt word [r12], 2 ; test bit 2 of current char data
    jnc draw_char_test_bit_1

    ; create SDL_Rect on stack
    mov eax, dword [rsp + 8]  ; fetch x from stack
    mov word [rsp + 16], ax   ; SDL_Rect.x
    mov eax, dword [rsp + 12] ; fetch y from stack
    mov word [rsp + 18], ax   ; SDL_Rect.y
    mov word [rsp + 20], r14w ; SDL_Rect.w
    mov word [rsp + 22], r14w ; SDL_Rect.h

    ; SDL_FillRect( rdi:SDL_Surface*, rsi:SDL_Rect*, rdx:color )
    mov rdi, qword [rsp + 0] ; SDL_Surface*
    lea rsi, [rsp + 16]      ; SDL_Rect is currently hiding out on the stack
    mov rdx, r15             ; color
    call SDL_FillRect

  draw_char_test_bit_1:
    add dword [rsp + 8], r14d ; advance x offset by scale
    bt word [r12], 1 ; test bit 1 of current char data
    jnc draw_char_test_bit_0

    ; create SDL_Rect on stack
    mov eax, dword [rsp + 8]  ; fetch x from stack
    mov word [rsp + 16], ax   ; SDL_Rect.x
    mov eax, dword [rsp + 12] ; fetch y from stack
    mov word [rsp + 18], ax   ; SDL_Rect.y
    mov word [rsp + 20], r14w ; SDL_Rect.w
    mov word [rsp + 22], r14w ; SDL_Rect.h

    ; SDL_FillRect( rdi:SDL_Surface*, rsi:SDL_Rect*, rdx:color )
    mov rdi, qword [rsp + 0] ; SDL_Surface*
    lea rsi, [rsp + 16]      ; SDL_Rect is currently hiding out on the stack
    mov rdx, r15             ; color
    call SDL_FillRect

  draw_char_test_bit_0:
    add dword [rsp + 8], r14d ; advance x offset by scale
    bt word [r12], 0 ; test bit 0 of current char data
    jnc draw_char_loop_end

    ; create SDL_Rect on stack
    mov eax, dword [rsp + 8]  ; fetch x from stack
    mov word [rsp + 16], ax   ; SDL_Rect.x
    mov eax, dword [rsp + 12] ; fetch y from stack
    mov word [rsp + 18], ax   ; SDL_Rect.y
    mov word [rsp + 20], r14w ; SDL_Rect.w = scale
    mov word [rsp + 22], r14w ; SDL_Rect.h = scale

    ; SDL_FillRect( rdi:SDL_Surface*, rsi:SDL_Rect*, rdx:color )
    mov rdi, qword [rsp + 0] ; SDL_Surface*
    lea rsi, [rsp + 16]      ; SDL_Rect is currently hiding out on the stack
    mov rdx, r15             ; color
    call SDL_FillRect


  draw_char_loop_end:
    ; avoid an unnecessary 'mul' instruction
    shl r14, 3                 ; multiply scale by 8
    sub dword [rsp + 8], r14d  ; reset x offset to original value
    shr r14, 3                 ; divide scale to get original value
    add dword [rsp + 8], r14d  ; need to add to get (x - (scale*(8-1))) => (x - (8*scale - scale)) => (x - 8*scale + scale)
    add dword [rsp + 12], r14d ; advance y offset by scale
    inc r12      ; advance char data iter
    cmp r12, r13 ; compare iterator to end value
    jne draw_char_test_bit_7 ; repeat until end

    add rsp, 32 ; destroy space for locals
    pop r15 ; restore callee-saved registers
    pop r14 ; ...
    pop r13 ; ...
    pop r12 ; ...

    mov rsp, rbp ; destroy stack frame
    pop rbp      ; ...
    ret


;
; rdi = SDL_Surface*
; rsi = x
; rdx = y
; rcx = char* (null-terminated)
; r8  = color
; r9  = scale
;
align 16
draw_string:
    push rbp
    mov rbp, rsp

    push r12 ; char* string
    push r13 ; x
    push r14 ; y
    push r15 ; color
    sub rsp, 16 ; make space for locals

    mov qword [rsp + 0], rdi ; store SDL_Surface* locally
    mov dword [rsp + 8], r9d ; store scale locally

    mov r12, rcx ; move char* string
    mov r13, rsi ; move x
    mov r14, rdx ; move y
    mov r15, r8  ; move color

  draw_string_begin_loop:
    mov al, byte [r12] ; fetch current character
    cmp al, 0 ; compare current character to zero
    je draw_string_end ; skip rest of routine if null-terminator

    ; draw_char( rdi:SDL_Surface*, rsi:x, rdx:y, rcx:charvalue, r8:color, r9:scale )
    mov rdi, qword [rsp + 0] ; SDL_Surface*
    mov esi, r13d            ; x
    mov edx, r14d            ; y
    movzx rcx, al            ; char
    mov r8, r15              ; color
    mov r9d, dword [rsp + 8] ; scale
    call draw_char

    mov eax, dword [rsp + 8]     ; fetch scale from stack
    lea r13d, [r13d + eax*8 + 0] ; calculate next x offset
    inc r12                      ; advance char* to next
    jmp draw_string_begin_loop   ; repeat

  draw_string_end:

    add rsp, 16 ; destroy locals
    pop r15 ; restore preserved register
    pop r14 ; ...
    pop r13 ; ...
    pop r12 ; ...

    mov rsp, rbp
    pop rbp
    ret