 *-----------------------------------------------------------
* Title      : Main
* Written by : Enya Bullard
* Date       : 5/28/2025
* Description: Recreation of the snake game except you get faster with each fruit eaten!
*              Main.X68 is where we run the game, and contains all the includes for functions.
*-----------------------------------------------------------
SET_OUTPUT_RESOLUTION_TRAP_CODE        equ     33
DRAW_MODE_TRAP_CODE                    equ     92 
ENABLE_DOUBLE_BUFFER_TRAP_CODE         equ     17 

SCREEN_WIDTH                           equ     800
SCREEN_HEIGHT                          equ     700

SPACE_KEY                              equ     $20
ENTER_KEY                              equ     $D

ALL_REG                                reg     D0-D7/A0-A6

    ORG    $1000
    
START: 


*-----------------------------------------------------------
* Set screen to 800x700
*-----------------------------------------------------------
    move.b #SET_OUTPUT_RESOLUTION_TRAP_CODE, d0
    move.l  #SCREEN_WIDTH,d1
    swap.w  d1                              
    move.w  #SCREEN_HEIGHT,d1
    trap #15
    
    
*-----------------------------------------------------------
* Set drawing mode to enable double buffering
*-----------------------------------------------------------
    move.b #DRAW_MODE_TRAP_CODE, d0
    move.b #ENABLE_DOUBLE_BUFFER_TRAP_CODE,d1
    trap #15
    

*-----------------------------------------------------------
* Set the loading screen, and swap when title screen is done drawing
*-----------------------------------------------------------
restart:
    jsr clearRegisters
    jsr clearScreen
    jsr loadingScreen  
    jsr titleScreen
    
    
*-----------------------------------------------------------
* Checks for space press, and when pressed, enters the game screen and starts the game
*-----------------------------------------------------------    
enterGame
    move.l #SPACE_KEY,d2                    
    move.b #CHECK_INPUT_TRAP_CODE,d0
    move.l d2,d1                            ;check if space was pressed
    and.l #$00FF,d1
    trap   #15
    cmpi.b #00,d1                           ;if space was pressed, start game. 
    beq enterGame                           ;Otherwise continue check
    jsr playEnterSound
    jsr loadingScreen
    jsr gameScreen
    jmp startGameLoop
    

*-----------------------------------------------------------
* Function that clears all registers and takes no argument.
*-----------------------------------------------------------
clearRegisters
     clr.l d0
     clr.l d1
     clr.l d2
     clr.l d3
     clr.l d4
     clr.l d5
     clr.l d6
     clr.l d7
    
     rts


*-----------------------------------------------------------
* Function that clears memory for snake position
*-----------------------------------------------------------
clearMemory
     lea SnakeX, a1
     lea SnakeY, a2
     lea SnakeBodyLength, a3
     move.l (a3),d5
     subi.l #1,d5                                    ;dbra stops loop at -1
clearLoop:
     move.l #$FFFFFFFF,(a1)+
     move.l #$FFFFFFFF,(a2)+
     dbra d5, clearLoop
    
     move.l #1,(a3)                                  ;reinitialize size to be 1
     lea CollisionFlag, a3                           ;reinitialize collision flag to be 0
     move.l #0,(a3)
     rts


   

*-----------------------------------------------------------
* Includes
*----------------------------------------------------------- 
    INCLUDE gameScreens.X68
    INCLUDE gameLoop.X68
    INCLUDE bitmapSubroutine.X68
    INCLUDE playerMovement.X68
    INCLUDE randomFruitSpawn.X68
    INCLUDE collisionChecks.X68
    INCLUDE gameAudio.X68
    INCLUDE sevenSegmentScore.X68
    INCLUDE updateSnakeBody.X68
    INCLUDE gameDrawFunctions.X68   



    END    START        ; last line of source





























































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
