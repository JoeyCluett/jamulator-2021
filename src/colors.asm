;
; as per the System-V ABI, registers are allocated in the order:
;   rdi, rsi, rdx, rcx, r8, r9
;

extern SDL_MapRGB

global setup_colors
global color_lut_begin
global color_lut_end

global white
global black
global maroon
global red
global orange
global yellow
global olive
global purple
global fuschia
global lime
global green
global navy
global blue
global aqua
global silver
global gray
global brown
global gold
global darkbrown
global beige

section .data
align 16
color_rgb_values_start:
    c_white:     db 0xFF, 0xFF, 0xFF
    c_black:     db 0x00, 0x00, 0x00
    c_maroon:    db 0x80, 0x00, 0x00
    c_red:       db 0xFF, 0x00, 0x00
    c_orange:    db 0xFF, 0xA5, 0x00
    c_yellow:    db 0xFF, 0xFF, 0x00
    c_olive:     db 0x80, 0x80, 0x00
    c_purple:    db 0x80, 0x00, 0x80
    c_fuscia:    db 0xFF, 0x00, 0xFF
    c_lime:      db 0x00, 0xFF, 0x00
    c_green:     db 0x00, 0x80, 0x00
    c_navy:      db 0x00, 0x00, 0x80
    c_blue:      db 0x00, 0x00, 0xFF
    c_aqua:      db 0x00, 0xFF, 0xFF
    c_silver:    db 0xC0, 0xC0, 0xC0
    c_gray:      db 0x80, 0x80, 0x80
    c_brown:     db 0x8B, 0x45, 0x13
    c_gold:      db 0xFF, 0xDF, 0x00
    c_darkbrown: db 0x2b, 0x1d, 0x0e
    c_beige:     db 0xf5, 0xf5, 0xdc
color_rgb_values_end:

section .bss

align 8
color_lut_begin:
    white:     resd 2
    black:     resd 2
    maroon:    resd 2
    red:       resd 2
    orange:    resd 2
    yellow:    resd 2
    olive:     resd 2
    purple:    resd 2
    fuschia:   resd 2
    lime:      resd 2
    green:     resd 2
    navy:      resd 2
    blue:      resd 2
    aqua:      resd 2
    silver:    resd 2
    gray:      resd 2
    brown:     resd 2
    gold:      resd 2
    darkbrown: resd 2
    beige:     resd 2
color_lut_end:

section .text

;
; rdi = SDL_Surface->format
;
align 16
setup_colors:
    push rbp     ; create stack frame and re-align stack
    mov rbp, rsp ; ...

    sub rsp, 32
    mov qword [rsp + 0], color_rgb_values_start
    mov qword [rsp + 8], color_lut_begin
    mov qword [rsp + 16], rdi ; save SDL_Surface->format

  start_setup_loop:
    mov rax, qword [rsp + 0] ; current source bytes

    ; SDL_MapRGB( rdi:format, rsi:red, rdx:green, rcx:blue ) -> eax
    mov rdi, qword [rsp + 16]
    movzx rsi, byte [rax + 0] ; red
    movzx rdx, byte [rax + 1] ; green
    movzx rcx, byte [rax + 2] ; blue
    call SDL_MapRGB
    mov r10, qword [rsp + 8] ; current destination
    mov [r10 + 0], dword eax ; store SDL_MapRGB result

    ; we're already here. generate SDL_gfx-compatible colors as well
    mov rax, qword [rsp + 0]  ; current source bytes
    movzx rdi, byte [rax + 0] ; red 
    movzx rsi, byte [rax + 1] ; green
    movzx rdx, byte [rax + 2] ; blue
    shl rdi, 24 ; shift into reds place
    shl rsi, 16 ; shift into greens place
    shl rdx, 8  ; shift into blues place
    or rdi, rsi ; or red w/ green
    or rdi, rdx ; or red|green w/ blue
    or rdi, 0x000000FF ; alpha channel is always 255
    mov [r10 + 4], edi ; save lower 32 bits of rdi

    add qword [rsp + 0], 3   ; advance to next 3 source bytes
    add qword [rsp + 8], 8   ; advance to next dest
    mov rax, qword [rsp + 0] ; get current source bytes address
    mov r10, color_rgb_values_end ; reuse r10
    cmp rax, r10         ; iterate to end
    jne start_setup_loop ; repeat until we hit the end

    mov rsp, rbp ; destroy stack frame
    pop rbp      ; ...
    ret

