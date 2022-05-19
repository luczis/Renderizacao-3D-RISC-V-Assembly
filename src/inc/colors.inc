# Identification colors
# COLOR   | ERROR
# White   | TFT failed to initialize
# Orange  | Loading
# Yellow  | SD card failed to initialize
# Green   | File system not recognized
# Cyan    | Invalid ppm file
# Blue    | Problem with ppm file
# Magenta | Invalid obj file
# Red     | Problem with obj file

.equ COLOR_ERROR_TFT,   0xFFFF
.equ COLOR_LOADING,     0xFD20
.equ COLOR_ERROR_SD,    0xFFE0
.equ COLOR_ERROR_FAT,   0x07E0
.equ COLOR_INVALID_PPM, 0x07EE
.equ COLOR_PROBLEM_PPM, 0x001F
.equ COLOR_INVALID_OBJ, 0xF81F
.equ COLOR_PROBLEM_OBJ, 0xF800

# Color list

.equ COLOR_BLACK,       0x0000
.equ COLOR_NAVY,        0x000F
.equ COLOR_DARKGREEN,   0x03E0
.equ COLOR_DARKCYAN,    0x03EF
.equ COLOR_MAROON,      0x7800
.equ COLOR_PURPLE,      0x780F
.equ COLOR_OLIVE,       0x7BE0
.equ COLOR_LIGHTGREY,   0xC618
.equ COLOR_DARKGREY,    0x7BEF
.equ COLOR_BLUE,        0x001F
.equ COLOR_GREEN,       0x07E0
.equ COLOR_CYAN,        0x07FF
.equ COLOR_RED,         0xF800
.equ COLOR_MAGENTA,     0xF81F
.equ COLOR_YELLOW,      0xFFE0
.equ COLOR_WHITE,       0xFFFF
.equ COLOR_ORANGE,      0xFD20
.equ COLOR_GREENYELLOW, 0xAFE5
.equ COLOR_PINK,        0xF81F
