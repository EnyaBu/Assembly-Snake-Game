*-----------------------------------------------------------
* Title      : collisionMechanics
* Written by : Enya Bullard
* Date       : 6/5/2025
* Description: defines collision of fruit for the snake
*-----------------------------------------------------------
FRUIT_HITBOX_WIDTH         equ 20
SELF_HITBOX_WIDTH          equ 10
SNAKE_BODY_HIT_WIDTH       equ 41
IGNORE_SNAKE_LENGTH        equ 31
SNAKE_OFFSET               equ 20
VELOCITY_INCREASE          equ 5
SNAKE_LENGTH_INCREASE      equ 10
SCORE_INCREASE             equ 1

RIGHT_SIDE_OF_SCREEN	   equ 757
UP_SIDE_OF_SCREEN	       equ 25
DOWN_SIDE_OF_SCREEN	       equ 557
LEFT_SIDE_OF_SCREEN	       equ 30


*-----------------------------------------------------------
* Function to check if our head collides with a fruit
*-----------------------------------------------------------    
fruitCollisionCheck
    movem.l ALL_REG, -(sp)
    
    move.l SnakeX,d3                                 ;d3= start x coord of snake head
    asr.l  #FRACTIONAL_BITS,d3
    addi.l #SNAKE_WIDTH>>1, d3                       ;move x to middle 
 
    move.l SnakeY,d4                                 ;d4=start y coord of snake head
    asr.l  #FRACTIONAL_BITS,d4
    addi.l #SNAKE_HEIGHT>>1, d4                      ;move y to middle 
    
    move.l xCoordFruit,d1                            ;d1=start x of fruit (left bound)
    subi.l #FRUIT_HITBOX_WIDTH>>1,d1                 ;make hit box larger by starting (x-10,y-10)
    move.l yCoordFruit,d2                            ;d2=start y of fruit (upper bound) 
    subi.l #FRUIT_HITBOX_WIDTH>>1,d2
    
    move.l d1,d5
    add.l #(FRUIT_WIDTH+FRUIT_HITBOX_WIDTH),d5       ;d5 has right bound (accounting for larger hitbox)
    
    move.l d2,d6
    add.l #(FRUIT_HEIGHT+FRUIT_HITBOX_WIDTH),d6      ;d6 has lower bound
    
checkX:
    cmp.l d1,d3                                      ;is snake x before our left bound?
    blt noCollision
    cmp.l d5,d3                                      ;is snake x after our right bound?
    bgt noCollision
    
    
checkY:
    cmp.l d2,d4                                      ;is snake y before our upper bound?
    blt noCollision
    cmp.l d6,d4                                      ;is snake y after our lower bound?
    bgt noCollision
    
collision:     
    jsr playEatSound    
    jsr eraseFruit
    jsr spawnFruit                                   

    lea Score, a4
    movem.l (a4),d1
    add.l #SCORE_INCREASE,d1
    movem.l d1, (a4)                                 ;add 1 to score
    jsr callScoreFunction                            ;change 7 segment led
    
    lea Velocity, a2                                 ;snake gets faster
    movem.l (a2),d6
    addi.l #VELOCITY_INCREASE,d6 
    move.l d6,(a2)
    
    lea SnakeBodyLength, a2                          ;snake gets longer (snake length +20px)
    movem.l (a2),d6
    addi.l #SNAKE_LENGTH_INCREASE,d6
    movem.l d6,(a2)  
    jsr updateBody                                   ;shift everything back once to make space for head
    
   
noCollision:
    movem.l (sp)+,ALL_REG
    rts


*-----------------------------------------------------------
* Function to check if our head collides with a wall
*----------------------------------------------------------- 
wallCollisionCheck
    movem.l ALL_REG, -(sp)
    
    *check left corner of head
    move.l SnakeY,d2                                 ;check if our x or y reaches the boundary
    move.l SnakeX,d7
    cmpi.l  #UP_SIDE_OF_SCREEN<<FRACTIONAL_BITS,d2   
    blt setFlag                                     ;if so, exit the game
    cmpi.l  #LEFT_SIDE_OF_SCREEN<<FRACTIONAL_BITS,d7 
    blt setFlag
    cmpi.l  #DOWN_SIDE_OF_SCREEN<<FRACTIONAL_BITS,d2  
    bgt setFlag
    cmpi.l  #RIGHT_SIDE_OF_SCREEN<<FRACTIONAL_BITS,d7 
    bgt setFlag
    
    *check right corner
    addi.l #SNAKE_WIDTH,d7
    cmpi.l  #LEFT_SIDE_OF_SCREEN<<FRACTIONAL_BITS,d7 
    blt setFlag
    cmpi.l  #RIGHT_SIDE_OF_SCREEN<<FRACTIONAL_BITS,d7 
    bgt setFlag
    
    movem.l (sp)+,ALL_REG
    rts
    
setFlag:
    jsr flagCollision
    movem.l (sp)+,ALL_REG
    rts


*-----------------------------------------------------------
* Function to check if our head collides with ourselves
*----------------------------------------------------------- 
selfCollisionCheck
    *each of our body segments has a hitbox
    movem.l ALL_REG, -(sp)
    
    move.l SnakeBodyLength, d5
    cmpi.l #SNAKE_BODY_HIT_WIDTH, d5
    blt noSelfCollision                              ;do we only have our head and first 3 segments?
    
    lea SnakeX, a1
    lea SnakeY, a2
    
    *check middle of head
    move.l (a1),d1
    asr.l  #FRACTIONAL_BITS,d1
    addi.l #SNAKE_WIDTH>>1, d1                       ;move to middle
    move.l (a2),d2                                   ;get our current head coordinates d1=x1, d2=y1
    asr.l  #FRACTIONAL_BITS,d2
     
    move.l #SNAKE_OFFSET,d7                          ;d7 keeps track of offset since we are adding by 10 segments each time
    subi.l #IGNORE_SNAKE_LENGTH,d5                   ;skip first 3 segments to allow for turns

selfCollisionCheckLoop:
    lsl.l #2,d7                                      ;offset by *4
    
    move.l (a1,d7),d3                                ;d3=x2
    asr.l  #FRACTIONAL_BITS,d3
    subi.l #SELF_HITBOX_WIDTH>>1,d3                  ;hitbox is larger our sides cannot touch during tight turns    
    move.l (a2,d7),d4                                ;d4=y2
    asr.l  #FRACTIONAL_BITS,d4
    subi.l #SELF_HITBOX_WIDTH>>1,d4
    
    move.l d3,d5
    move.l d4,d6 
    
    addi.l #(SNAKE_WIDTH+SELF_HITBOX_WIDTH),d5       ;d5 is our end x 
    addi.l #(SNAKE_HEIGHT+SELF_HITBOX_WIDTH),d6      ;d6 is our end y 
    
checkSnakeX:
    cmp.l d3,d1                                      ;is snake x before our left bound?
    blt continueCheck
    cmp.l d5,d1                                      ;is snake x after our right bound?
    bgt continueCheck
       
checkSnakeY:
    cmp.l d4,d2                                      ;is snake y before our upper bound?
    blt continueCheck
    cmp.l d6,d2                                      ;is snake y after our lower bound?
    bgt continueCheck

selfCollision:     
    jsr flagCollision
    movem.l (sp)+,ALL_REG
    rts
    
continueCheck:
    lsr.l  #2,d7                                      ;reset and increment the index
    addi.l #1,d7
    move.l SnakeBodyLength, d5
    subi.l #1,d5                                     ;check from index 11 to length-1
    cmp.l d5, d7                                     ;did we reach the end of our snake?
    blt selfCollisionCheckLoop

noSelfCollision:
    movem.l (sp)+,ALL_REG
    rts


*-----------------------------------------------------------
* Set our collision flag
*-----------------------------------------------------------
flagCollision
    movem.l ALL_REG, -(sp)
    lea CollisionFlag,a0
    move.b #1,(a0)
    movem.l (sp)+,ALL_REG
    rts


*-----------------------------------------------------------
* Variables
*-----------------------------------------------------------
CollisionFlag               dc.l    0
Score                       ds.l    1































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
