*-----------------------------------------------------------
* Title      : playerMovementGame
* Written by : Enya Bullard
* Date       : 6/3/2025
* Description: this defines the snake's movement. 
*-----------------------------------------------------------
UP_OFFSET                       equ     12 
LEFT_OFFSET                     equ     8 
DOWN_OFFSET                     equ     4 
RIGHT_OFFSET                    equ     0 


*-----------------------------------------------------------
* Function to check if requested move is valid (not reverse)
* Input: RequestedDirection contains the requested move offset
* Output: MoveOffset contains the validated move offset
*-----------------------------------------------------------
checkValidMove:
    movem.l ALL_REG, -(sp)                           ;save all registers
    
    move.l RequestedDirection, d0                    ;get requested direction
    move.l MoveOffset, d1                            ;get current direction
    
    cmpi.l #-1, d1                                   ;if first move, allow any direction
    beq useRequestedMove
    
    * check for reverse moves using our offsets
    * UP (12) and DOWN (4): difference is 8
    * LEFT (8) and RIGHT (0): difference is 8
    
    move.l d0, d2
    sub.l d1, d2                                     ;d2 = requested - current
    
    * check if difference is 8 (reverse move) or 0 (same move)
    cmpi.l #8, d2
    beq keepCurrentMove                          
    cmpi.l #-8, d2
    beq keepCurrentMove                            
    cmpi.l #0, d2
    beq keepCurrentMove
    
    * not a reverse or current move, use requested direction
useRequestedMove:
    move.l d0, MoveOffset                            ;update current direction
    move.l MoveOffset, PreviousDirection             ;update previous direction
    move.l #1, SoundFlag                             ;set flag: valid move made (play sound)
    bra checkValidMoveEnd
    
keepCurrentMove:
     move.l #0, SoundFlag                            ;otherwise, keep current move
     
checkValidMoveEnd:
    movem.l (sp)+, ALL_REG                           ;restore all registers
    rts
*-----------------------------------------------------------
* Function table methods to change the appropriate x and y coordinates for WASD movement
* Updates PreviousDirection after each move
*----------------------------------------------------------- 

moveUp   
    lea SnakeY,a3
    movem.l (a3),d0
    sub.l	d6,d0                                    ;subtract velocity to y position	
    movem.l d0,(a3) 

    lea MoveOffset,a5                                ;keeping track of our current move
    move.l #UP_OFFSET,(a5)
    lea PreviousDirection,a5                         ;update previous direction
    move.l #UP_OFFSET,(a5)
    rts
    
	
moveLeft 
    lea SnakeX,a3
    movem.l (a3),d7
    sub.l	d6,d7                                    ;subtract velocity to x position   
    movem.l d7,(a3) 

    lea MoveOffset,a5
    move.l #LEFT_OFFSET,(a5)
    lea PreviousDirection,a5                         ;update previous direction
    move.l #LEFT_OFFSET,(a5)    
    rts


moveDown 
    lea SnakeY,a3
    movem.l (a3),d0
    add.l	d6,d0                                    ;add velocity to y position	
    movem.l d0,(a3)
     
    lea MoveOffset,a5
    move.l #DOWN_OFFSET,(a5)
    lea PreviousDirection,a5                         ;update previous direction
    move.l #DOWN_OFFSET,(a5) 
    rts  
	
	
moveRight 
    lea SnakeX,a3
    movem.l (a3),d7
    add.l	d6,d7                                    ;add velocity to x position	
    movem.l d7,(a3)
    
    lea MoveOffset,a5
    move.l #RIGHT_OFFSET,(a5)
    lea PreviousDirection,a5                         ;update previous direction
    move.l #RIGHT_OFFSET,(a5)  
    rts  
    

*-----------------------------------------------------------
* Variables
*-----------------------------------------------------------

*Function table for movement
MoveTable               dc.l    moveRight,moveDown,moveLeft,moveUp  

* array of body segments for the snake
SnakeX                  ds.l    1000
SnakeY                  ds.l    1000
SnakeBodyLength         dc.l    1

MoveOffset              dc.l    -1
RequestedDirection      ds.l    1
PreviousDirection       ds.l    1
NumberShifts            ds.l    1
SoundFlag               ds.l    1

Velocity                ds.l    1
PrevTime                ds.l    1  
CurrTime                ds.l    1  





























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
