*-----------------------------------------------------------
* Title      : gameLoop
* Written by : Enya Bullard
* Date       : 6/18/2025
* Description: defines start and end game
*-----------------------------------------------------------
WASD_ASCII                  equ $57415344
ENTER_SPACE_ASCII           equ $00000D20
CHECK_INPUT_TRAP_CODE       equ 19
SPEED_CAP_VELOCITY          equ 80

FRACTIONAL_BITS             equ 4
GET_TIME_TRAP_CODE          equ 8


*-----------------------------------------------------------
* Initializes our WASD keys and initialize offset and direction
*-----------------------------------------------------------
startGameLoop:
    move.l #-1, MoveOffset                           ; mark current direction as uninitialized
    move.l #-1, PreviousDirection
    lea NumberShifts,a6
    move.l #WASD_ASCII,d3                            ;wasd in ascii is 57 41 53 44                     
    move.l #0,d5                                     ;d5 keeps track of number of shifts
    move.l d5,(a6)
   
  
*-----------------------------------------------------------
* Checks if W,A,S,D was pressed by first checking "D"
*-----------------------------------------------------------    
gameLoop:
    move.b #CHECK_INPUT_TRAP_CODE,d0
    move.l d3,d1                                     ;check if D was pressed
    and.l #$00FF,d1
    trap #15
    cmpi.b #00,d1                                    ;if key was pressed, call function. 
    beq noCall                                       ;Otherwise check other values
    bra callFunction


*-----------------------------------------------------------
* If no key was pressed, continue checking the other values.
*-----------------------------------------------------------          
noCall:
    add.l           #4,d5                            ;offset to next shift
    move.l d5,(a6)
    ror.l           #8,d3                            ;go to next value, 44574153, 53445741, etc
    cmpi.l          #16,d5                           ;if we checked all then reinitialize data
    bne             gameloop                
    bra             startGameLoop

    
*-----------------------------------------------------------
* Using a function table, we move in the appropriate direction
* Once we start moving, we do not stop. 
*-----------------------------------------------------------  
callFunction:
 
move:
    move.l NumberShifts,d5                                      
    lea MoveTable,a0                                 ;load up MoveTable
    lea RequestedDirection,a1
    move.l d5,(a1)                                   ;store requested direction
    
    * check if the requested move is valid (not reverse)
    jsr checkValidMove
    
    * use the validated direction (either requested or current)
    lea MoveOffset,a1
    move.l (a1),d5                                   ;get the direction we'll actually use
    move.l (a0,d5),a1                                ;offset to right function
    
    move.b #GET_TIME_TRAP_CODE,d0
    trap #15                                         ;d1 contains time in hundredths of a second since midnight
    lea PrevTime, a2 
    movem.l d1, (a2)                                 ;set as previous time
    
    lea Velocity, a3
    movem.l (a3),d6 

    move.b #GET_TIME_TRAP_CODE,d0
    trap #15                                        
    lea CurrTime, a2
    movem.l d1, (a2)                                 ;set as current time (might need to move)
    cmpi.l #SPEED_CAP_VELOCITY,d6                    ;cap speed
    bgt capped
    
    move.l CurrTime, d1                              ;set as current time
    move.l PrevTime, d2                              
    cmp.l d1,d2                                      ;is it the same? (prevent snake from stopping)
    beq capped
    
    move.l #(CurrTime-PrevTime),d1
    lsr.l #FRACTIONAL_BITS,d1
    mulu d1,d6                                       ;time based = velocity*(time elapsed)

capped:        
    jsr replaceBackground                            ;replace where our snake moved
    
    jsr wallCollisionCheck                           ;check if we hit a wall,self, or fruit
    jsr selfCollisionCheck
    jsr fruitCollisionCheck
    
    move.b CollisionFlag,d0
    cmpi.b #1,d0
    beq exitGame
    
    jsr updateBody                                   ;shift coordinates to replace previous positions
    
    move.l MoveOffset,d5
    jsr (a1)                                         ;update snake head position by moving in WASD direction                         
    
    jsr drawSnake                                    ;draw snake
    jsr	swapScreen
    
    move.l #WASD_ASCII,d3
    move.b #CHECK_INPUT_TRAP_CODE,d0
    move.l d3,d1                                     ;check if no press (all 0)
    trap   #15
    cmpi.l #00,d1                                    ;if no keys were pressed, no change
    beq move    
    
    move.l SoundFlag, d1                             ;if sound flag is activated, play sound
    cmpi.l #1,d1
    bne reinitialize
    jsr playTurnSound
    
    *otherwise check for next input
reinitialize:
    lea NumberShifts,a6
    move.l #0, d5
    move.l #WASD_ASCII,d3
checkOtherInput:
    move.b #CHECK_INPUT_TRAP_CODE,d0
    move.l d3,d1                                     ;check if D was pressed
    and.l #$00FF,d1
    trap #15
    cmpi.b #00,d1                                    ;if key was pressed, call function.
    beq offsetting                                   ;Otherwise check other values
    move.l d5,(a6)
    bra callFunction
    
offsetting:
    add.l #4,d5                                      ;offset to next shift
    ror.l #8,d3                                      ;go to next value, 44574153, 53445741, etc
    cmpi.l #16,d5                                    ;if we checked all then reinitialize data
    bne checkOtherInput
    bra callFunction
  
    
*-----------------------------------------------------------
* Once a player dies, we exit the game and get a game over screen with sound and score
*-----------------------------------------------------------  
exitGame:
    jsr gameOverScreen  
    jsr playCollisionSound
    jsr clearMemory   
    jsr clearRegisters
    move.l #ENTER_SPACE_ASCII,d2            ;enter key=D space key=20
    
check:                     
    move.b #CHECK_INPUT_TRAP_CODE,d0
    move.l d2,d1                            ;check if enter was pressed
    trap #15
    
    move.l #$FF00,d6 
    cmp.l d6,d1
    beq goToTitle                           ;goes back to title screen
    
    move.l #$00FF,d6                        ;check if space was pressed
    cmp.l d6, d1
    beq goToGame                            ;goes back to game screen
    
    bra check
    
goToTitle:
    jmp restart                             ;goes back to title screen

goToGame:
    jmp enterGame                           ;goes back to game screen





















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
