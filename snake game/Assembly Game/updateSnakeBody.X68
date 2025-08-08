*-----------------------------------------------------------
* Title      : updateSnakeBody
* Written by : Enya Bullard
* Date       : 6/10
* Description: Shifts the x and y coordinates of the snake as it moves
*-----------------------------------------------------------      
    
*-----------------------------------------------------------
* Function to shift our body coordinates down by one
*----------------------------------------------------------- 
updateBody
    movem.l ALL_REG, -(sp)
    lea SnakeX,a4                                    ;start at index 0
    movem.l	(a4),d1 
    
    lea SnakeY,a5
    movem.l	(a5),d2 
    
    movem.l	SnakeBodyLength,d5                       ;get snake length
    subi.l #1,d5 
    beq exitUpdate                                   ;if 0 (just the head), then no update
    subi.l #1,d5                                     ;otherwise, move to size -1

pushBack:                                            ;move to second to last element in our x,y tables

    move.l (a4)+,d1                                  ;move to next x coord and store previous in d1
    move.l (a5)+,d2                                  ;move to next y coord and store previous in d2
    
    dbra d5,pushBack
        
    * reset snake length for shiftElement loop
    movem.l	SnakeBodyLength,d5
    subi.l #1,d5
    beq exitUpdate                                   ;if 0 (just the head), then no update
    subi.l #1,d5                                     ;otherwise, move to length-1

    *starting at the second to last element: arr[i+1]=arr[i] to shift coordinates back by 1 
shiftElement:
    move.l d1,(a4)
    lea -4(a4),a4
    move.l -4(a4),d1
    
    move.l d2,(a5)
    lea  -4(a5),a5
    move.l -4(a5),d2
    dbra d5, shiftElement
    
exitUpdate:   
    movem.l (sp)+,ALL_REG
    rts






















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
