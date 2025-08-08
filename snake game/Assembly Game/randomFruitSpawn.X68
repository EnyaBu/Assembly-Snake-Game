*-----------------------------------------------------------
* Title      : randomFruitSpawn
* Written by : Enya Bullard
* Date       : 6/4/2025
* Description: spawns fruit in various locations on the screen.
*-----------------------------------------------------------
GET_PIXEL_COLOR_TRAP_CODE equ 83

*-----------------------------------------------------------
* Function to spawn a fruit at a random location within game boundaries
*-----------------------------------------------------------
spawnFruit
getNew:
    *get words
    jsr getRandomLongIntoD6
    move.l d6, d1                                    ;d1 holds x
    clr.w d1
    swap d1

    move.l d6,d2                                     ;d2 holds y
    swap d2
    clr.w d2
    swap d2
    
    * make sure the word is within border bounds 
    divu #96,d1                                      ;fit within left and right side of screen
    swap d1
    clr.w d1
    swap d1                                 
    addi.l #(LEFT_SIDE_OF_SCREEN+10),d1              ;space between border
    lsr.l #7,d2                                  
    addi.l #(UP_SIDE_OF_SCREEN+10),d2
    
    lea xCoordFruit, a5
    lea yCoordFruit, a6
    move.l d1, (a5)                                  ;save fruit coords in memory
    move.l d2, (a6)
    
    * check 1: upper left hitbox 
    move.l #GET_PIXEL_COLOR_TRAP_CODE, d0             
    trap #15                                         
    cmp.l #DARK_GREEN, d0                           
    beq getnew                                       ;early exit on collision
    
    * check 2: upper right of hitbox
    move.l xCoordFruit, d1                           ;restore x and y starting coords
    move.l yCoordFruit, d2  
    add.l #(FRUIT_WIDTH),d1                          ;upper right x
    move.l #GET_PIXEL_COLOR_TRAP_CODE, d0             
    trap #15                                         
    cmp.l #DARK_GREEN, d0                           
    beq getnew                                       ;early exit on collision
    
    * check 3: lower right of hitbox
    move.l xCoordFruit, d1                           ;restore x and y starting coords
    move.l yCoordFruit, d2  
    add.l #(FRUIT_WIDTH),d1                          ;lower right x
    add.l #(FRUIT_HEIGHT),d2                         ;lower right y
    move.l #GET_PIXEL_COLOR_TRAP_CODE, d0             
    trap #15                                         
    cmp.l #DARK_GREEN, d0                           
    beq getnew                                       ;early exit on collision
        
    * check 4: lower left of hitbox
    move.l xCoordFruit, d1                           ;restore x and y starting coords
    move.l yCoordFruit, d2  
    add.l #(FRUIT_HEIGHT),d2                         ;lower left y
    move.l #GET_PIXEL_COLOR_TRAP_CODE, d0             
    trap #15                                         
    cmp.l #DARK_GREEN, d0                           
    beq getnew                                       ;early exit on collision
    
    
    * all checks passed - restore original coordinates and draw
    move.l xCoordFruit, d1                         
    move.l yCoordFruit, d2  
    
    * draw the fruit at generated location  
    lea Apple, a0
    sub.l   #28, sp                                     
    move.l  a0,SET_POINTER_OFFSET(sp)                   
    move.l  #0,SET_CHUNK_X_OFFSET(sp)                   
    move.l  #0,SET_CHUNK_Y_OFFSET(sp)                   
    move.l  #FRUIT_WIDTH,SET_CHUNK_WIDTH_OFFSET(sp)     
    move.l  #FRUIT_HEIGHT,SET_CHUNK_HEIGHT_OFFSET(sp)   
    move.l  d1,SET_DISPLAY_X_OFFSET(sp)                 
    move.l  d2,SET_DISPLAY_Y_OFFSET(sp)                 
    jsr     drawChunk                                   
    add.l   #28, sp                                     
    rts


*-----------------------------------------------------------
* Functions to generate a random long (Utsab provided)
*-----------------------------------------------------------
seedRandomNumber
    movem.l ALL_REG,-(sp)    
    clr.l   d6
    move.b  #GET_TIME_TRAP_CODE,d0
    TRAP    #15

    move.l  d1,RANDOMVAL
    movem.l (sp)+,ALL_REG
    rts

getRandomByteIntoD6
    movem.l d0,-(sp)
    movem.l d1,-(sp)
    movem.l d2,-(sp)
    move.l  RANDOMVAL,d0
    moveq	#$AF-$100,d1
    moveq	#18,d2
Ninc0	
	add.l	d0,d0
	bcc	Ninc1
	eor.b	d1,d0
Ninc1
	dbf	d2,Ninc0
	
	move.l	d0,RANDOMVAL
	clr.l	d6
	move.b	d0,d6
	
    movem.l (sp)+,d2
    movem.l (sp)+,d1
    movem.l (sp)+,d0
    rts
    
getRandomLongIntoD6
    movem.l ALL_REG,-(sp)
    jsr     getRandomByteIntoD6
    move.b  d6,d5
    jsr     getRandomByteIntoD6
    lsl.l   #8,d5
    move.b  d6,d5
    jsr     getRandomByteIntoD6
    lsl.l   #8,d5
    move.b  d6,d5
    jsr     getRandomByteIntoD6
    lsl.l   #8,d5
    move.b  d6,d5
    move.l  d5,TEMPRANDOMLONG
    movem.l (sp)+,ALL_REG
    move.l  TEMPRANDOMLONG,d6
    rts



*-----------------------------------------------------------
* Variables
*-----------------------------------------------------------
RANDOMVAL               ds.l    1
TEMPRANDOMLONG          ds.l    1
xCoordFruit             ds.l    1
yCoordFruit             ds.l    1






















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
