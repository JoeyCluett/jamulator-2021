
global update_ui
global check_button_press

extern draw_rect
extern draw_rect_1x1
extern draw_line
extern draw_circle

extern SDL_FillRect

extern draw_string
extern gray

section .data

    btn_label_data:
    and_btn_label:  db "AND",  0x00
    nand_btn_label: db "NAND", 0x00
    or_btn_label:   db "OR",   0x00
    nor_btn_label:  db "NOR",  0x00
    not_btn_label:  db "NOT",  0x00

    align 8
    btn_data_start:
    
    ;            x    y    w    h     mirrors exact layout of SDL_Rect
    and_btn:  dw 1,   200, 110, 47
              dd 11,  210
              dq and_btn_label
    nand_btn: dw 1,  251, 110,  47
              dd 11, 261
              dq nand_btn_label
    or_btn:   dw 1,  302, 110,  47
              dd 11, 312
              dq or_btn_label
    nor_btn:  dw 1,  353, 110,  47
              dd 11, 363
              dq nor_btn_label
    not_btn:  dw 1,  404, 110,  47
              dd 11, 414
              dq not_btn_label
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

    mov rax, qword [rsp + 8] ; load button data iterator

    ; draw_string( rdi:SDL_Surface*, rsi:x, rdx:y, rcx:char*, r8:color, r9:scale )
    mov rdi, qword [rsp + 0]  ; SDL_Surface*
    mov esi, dword [rax + 8]  ; x
    mov edx, dword [rax + 12] ; y
    mov rcx, qword [rax + 16] ; char*
    mov r8d, dword [gray + 0] ; color
    mov r9, 3                 ; scale
    call draw_string

    add qword [rsp + 8], 24   ; advance to next rect to draw
    mov rax, qword [rsp + 8] ; load new iterator value
    cmp rax, btn_data_end    ; compare to end iterator
    jne btn_update_loop      ; repeat until equal

    mov rsp, rbp ; destroy stack frame
    pop rbp      ; ...
    ret

;
; rdi = X
; rsi = Y
;
align 16
check_button_press:
    push rbp
    mov rbp, rsp

    xor rax, rax ; zero out rax
    mov rdx, btn_data_start ; button data iterator

  check_button_press_loop_start:

    mov cx, word [rdx + 0] ; load button X
    cmp di, cx ; check if X less than button X
    jl check_button_press_loop_afterthought

    add cx, word [rdx + 4] ; add button W to button X
    cmp di, cx ; check if X greater than button X+W
    jg check_button_press_loop_afterthought

    mov cx, word [rdx + 2] ; load button Y
    cmp si, cx ; check if Y less than button Y
    jl check_button_press_loop_afterthought

    add cx, word [rdx + 6] ; add button H to button Y
    cmp si, cx ; check if Y greater than button Y+H
    jg check_button_press_loop_afterthought

    ; if all of the above checks fail, X/Y overlaps a button
    ; jump to end of subroutine. rax contains index of correct button
    jmp check_button_press_end

  check_button_press_loop_afterthought:
    inc rax               ; increment button ident
    add rdx, 24           ; advance iterator
    cmp rdx, btn_data_end ; compare iterator to end
    jne check_button_press_loop_start ; loop until equal

    mov rax, -1 ; mov -1 (means no collision)

  check_button_press_end:
    mov rsp, rbp
    pop rbp
    ret
