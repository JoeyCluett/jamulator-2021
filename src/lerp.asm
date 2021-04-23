
global lerp
global euclidean_distance

section .text

;
; xmm0 = x
; xmm1 = x_begin
; xmm2 = x_end
; xmm3 = y_begin
; xmm4 = y_end
;
; xmm0 = output
;
; output = y_begin + ((y_end - y_begin) / (x_end - x_begin)) * (x - x_begin)
;
align 16
lerp:
    ; leaf function so no need to create stack frame
    subss xmm4, xmm3 ; y_end -= y_begin
    subss xmm0, xmm1 ; x -= x_begin
    subss xmm2, xmm1 ; x_end -= x_begin

    divss xmm4, xmm2 ; y_end /= x_end
    mulss xmm4, xmm0 ; y_end *= x

    addss xmm3, xmm4 ; y_begin += y_end
    movss xmm0, xmm3 ; returned in xmm0

    ret

;
; xmm0 = x0
; xmm1 = y0
; xmm2 = x1
; xmm3 = y1
;
align 16
euclidean_distance:
    subss xmm0, xmm1  ; delta x
    subss xmm2, xmm3  ; delta y
    mulss xmm0, xmm0  ; (delta x) ^ 2
    mulss xmm2, xmm2  ; (delta y) ^ 2
    addss xmm0, xmm2  ; x^2 + y^2
    sqrtss xmm0, xmm0 ; xmm0 = sqrt(x^2 + y^2)
    ret
