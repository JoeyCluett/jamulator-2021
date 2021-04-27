
global update_ui

extern draw_rect
extern draw_rect_1x1
extern draw_line
extern SDL_FillRect

section .data

    btn_data_start:
    
    ;              x    y    w   h     mirrors exact layout of SDL_Rect
    and_btn:  dw 1,   0, 100,  50
    nand_btn: dw 1,  51, 100,  50
    or_btn:   dw 1, 102, 100,  50
    nor_btn:  dw 1, 153, 100,  50
    not_btn:  dw 1, 204, 100,  50
    btn_data_end:

section .bss

section .text

;
; rdi = SDL_Surface*
; rsi = color
;
align 16
update_ui:
    push rbp     ; create stack frame
    mov rbp, rsp ; ...

    sub rsp, 32

    mov qword [rsp + 0], rdi            ; SDL_Surface*
    mov qword [rsp + 8], btn_data_start ; store iterator locally
    mov dword [rsp + 16], esi           ; color

  btn_update_loop:

    ; SDL_FillRect( rdi:SDL_Surface*, rsi:SDL_Rect*, rdx:color )
    mov rdi, qword [rsp + 0]  ; SDL_Surface*
    mov rsi, qword [rsp + 8]  ; SDL_Rect*
    mov edx, dword [rsp + 16] ; color
    call SDL_FillRect

    add qword [rsp + 8], 8   ; advance to next rect to draw
    mov rax, qword [rsp + 8] ; load new iterator value
    cmp rax, btn_data_end    ; compare to end iterator
    jne btn_update_loop      ; repeat until equal

    mov rsp, rbp ; destroy stack frame
    pop rbp      ; ...
    ret

align 16
check_button_press:
    push rbp
    mov rbp, rsp

    xor rax, rax ; zero out rax
    dec rax      ; need -1 here



    mov rsp, rbp
    pop rbp
    ret