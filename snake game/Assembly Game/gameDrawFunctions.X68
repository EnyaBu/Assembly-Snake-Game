*-----------------------------------------------------------
* Title      : gameDrawFunctions
* Written by : Enya Bullard
* Date       : 6/18
* Description: Functions that help with drawing to the game screen
*-----------------------------------------------------------


*-----------------------------------------------------------
* Function to draw the snake and its body segments
*----------------------------------------------------------- 
drawSnake
    movem.l ALL_REG, -(sp)
    move.l	#DARK_GREEN,d1
	move.b	#PEN_COLOR_TRAP_CODE,d0
	trap	#15
	move.b	#SET_FILL_COLOR_TRAP_CODE,d0
	trap	#15 
	
	lea SnakeX,a4
	lea SnakeY,a5
    
    move.l	SnakeBodyLength,d5
    subi.l #1, d5                                    ;using dbra, loop stops at -1
drawLoop:
    move.l	(a4)+,d1 
    move.l	(a5)+,d2 
	asr.l	#FRACTIONAL_BITS,d1                      ;d1= start x
	move.l	d1,d3                                    ;d3= end x 
	add.l	#SNAKE_WIDTH,d3	 
	asr.l	#FRACTIONAL_BITS,d2                      ;d2= start y
    move.l  d2,d4
    add.l	#SNAKE_HEIGHT,d4                         ;d4= end y 
    
    *is d1,d2 of our snake valid?
    cmpi.l  #UP_SIDE_OF_SCREEN,d2   
    blt skipDrawRect                                
    cmpi.l  #LEFT_SIDE_OF_SCREEN,d1 
    blt skipDrawRect
    cmpi.l  #DOWN_SIDE_OF_SCREEN,d2  
    bgt skipDrawRect
    cmpi.l  #RIGHT_SIDE_OF_SCREEN,d1 
    bgt skipDrawRect

    *otherwise draw
    move.b	#DRAW_RECTANGLE_TRAP_CODE,d0 
	trap	#15
	
skipDrawRect:      
    dbra d5,drawLoop
skipDraw:
    movem.l (sp)+,ALL_REG         
	rts
 
    
*-----------------------------------------------------------
* Function to replace the background at the tail segment
*-----------------------------------------------------------    
replaceBackground
    movem.l ALL_REG, -(sp)
    
    move.l	SnakeBodyLength,d5                       ;using dbra, loop ends at -1
    subi.l #1,d5 
    
    lea	SnakeX,a4 
    lea	SnakeY,a5
 
moveToTail:
    move.l (a4)+,d1                                 
    move.l (a5)+,d2                                 
    dbra d5,moveToTail                               ;d1,d2 stores the start (x,y) for the tail
    
    lea Background, a0
	asr.l	#FRACTIONAL_BITS,d1
	subi.l  #2, d1                                   ;make replacement box bigger
	asr.l	#FRACTIONAL_BITS,d2
	subi.l  #2, d2
    sub.l   #28, sp                                         
    move.l  a0,SET_POINTER_OFFSET(sp)                       
    move.l  #0,SET_CHUNK_X_OFFSET(sp)                      
    move.l  #0,SET_CHUNK_Y_OFFSET(sp)                       
    move.l  #(SNAKE_WIDTH+4),SET_CHUNK_WIDTH_OFFSET(sp)     
    move.l  #(SNAKE_HEIGHT+4),SET_CHUNK_HEIGHT_OFFSET(sp)   
    move.l  d1,SET_DISPLAY_X_OFFSET(sp)                     
    move.l  d2,SET_DISPLAY_Y_OFFSET(sp)                    
    jsr     drawChunk                                ;draw background over the tail        
    add.l   #28, sp                                       
    movem.l (sp)+,ALL_REG
    rts


*-----------------------------------------------------------
* Function to handle deferred background redraw at old fruit position
*-----------------------------------------------------------
eraseFruit
    movem.l ALL_REG, -(sp)

    * get the old fruit coordinates
    move.l xCoordFruit, d1                     ; d1 = old fruit X position
    move.l yCoordFruit, d2                     ; d2 = old fruit Y position
    
    * redraw background at old fruit position
    lea Background, a0
    sub.l   #28, sp                                         
    move.l  a0,SET_POINTER_OFFSET(sp)                       
    move.l  #0,SET_CHUNK_X_OFFSET(sp)                      
    move.l  #0,SET_CHUNK_Y_OFFSET(sp)                       
    move.l  #FRUIT_WIDTH,SET_CHUNK_WIDTH_OFFSET(sp)         
    move.l  #FRUIT_HEIGHT,SET_CHUNK_HEIGHT_OFFSET(sp)       
    move.l  d1,SET_DISPLAY_X_OFFSET(sp)                     
    move.l  d2,SET_DISPLAY_Y_OFFSET(sp)                    
    jsr     drawChunk                                ; draw background over old fruit position        
    add.l   #28, sp
    
skipBackgroundRedraw:
    movem.l (sp)+,ALL_REG
    rts







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
