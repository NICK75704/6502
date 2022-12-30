E = %10000000 			    ;Enable bit for sending instructions to LCD
RW = %01000000              ;Read/Write bit for sending instructions to LCD
RS = %00100000              ;Register Select bit for sending instructions to LCD

portB = $6000
portA = $6001
DDRB = $6002
DDRA = $6003

    .org $8000
reset:
    jsr initVIA
    jsr initDisplay
program:                    ;program goes here:
    
loop:                       ;end of program:
    jmp loop

initVIA:
    lda #%11111111          ;Set all pins on port B to output
    sta DDRB
    lda #%11100000          ;Set top 3 pins on port A to output
    sta DDRA
    rts


initDisplay:
    lda #%11111111          ;Set all pins on port B to output
    sta DDRB
    lda #%11100000          ;Set top 3 pins on port A to output
    sta DDRA
    lda #%00111000          ;Set 8-bit mode; 2-line display; 5x8 font
    jsr instructDisplay
    lda #%00001110          ;Display on; cursor on; blink off
    jsr instructDisplay
    lda #%00000110          ;Increment and shift cursor; don't shift display
    jsr instructDisplay
    lda #$00000001          ;Clear display
    jsr instructDisplay
    rts

resetDisplay:               ;clears character display
    lda #%00000001          ;load reset command to a register
    jsr instructDisplay     ;sends command to display
    rts                     ;returns to main program

instructDisplay:            ;sends command to display
    sta portB               ;sends character to display
    lda #0                  ;clears read/write/enable bits
    sta portA               
    lda #E                  ;loads enable bit
    sta portA               ;sends enable bit to display
    lda #0
    sta portA
    rts                     ;returns to main program

printChar:
    sta portB               ;sends character to display
    lda #RS                 ;loads register select bit
    sta portA               ;sends register select bit to display
    lda #(RS | E)
    sta portA               ;sends enable bit to display
    lda #RS                 ;loads register select bit
    sta portA               ;sends register select bit to display
    rts                     ;returns to main program

printString:                ;prints string to display
    ldx #0                  ;clears index register
printStringNextChar:
    txa                     ;loads character from string
    cpx #0                  ;compares index register to string length
    beq printStringEnd      ;returns to main program
    jsr printChar           ;sends character to display
    inx                     ;increments index register
    bne printStringNextChar ;branch if not equal
printStringEnd:
    rts                     ;returns to main program  


    .org $fffc
    .word reset
    .word $0000
