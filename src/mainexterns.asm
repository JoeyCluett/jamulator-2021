
; stdlib stuff
extern printf
extern puts
extern sprintf
extern bzero

; a bunch of SDL1.2 library stuff
extern SDL_Init
extern SDL_SetVideoMode
extern SDL_FillRect
extern SDL_MapRGB
extern SDL_Flip
extern SDL_Delay
extern SDL_Quit
extern SDL_ShowCursor
extern SDL_GetTicks

extern draw_rect

; math stuff
extern lerp
extern euclidean_distance

; input subsystem stuff
extern evaluate_inputs
extern clear_inputs
extern key_w
extern key_a
extern key_s
extern key_d
extern key_enter
extern key_spc
extern key_esc
extern quit_p
extern key_up
extern key_down
extern key_left
extern key_right
extern mouse_X
extern mouse_Y


; global color symbols
extern setup_colors
extern color_lut_begin
extern color_lut_end

extern white
extern black
extern maroon
extern red
extern orange
extern yellow
extern olive
extern purple
extern fuschia
extern lime
extern green
extern navy
extern blue
extern aqua
extern silver
extern gray
extern brown