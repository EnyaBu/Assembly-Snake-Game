*-----------------------------------------------------------
* Title      : sevenSegmentScore
* Written by : Enya Bullard
* Date       : 6/6/2025
* Description: seven segment that shows the score at the bottom of the screen
*-----------------------------------------------------------
READ_NUMBER_TRAP_CODE           equ     4
DRAW_LINE_TRAP_CODE             equ     84      

SEG_CENTER__X                   equ     640
SEG_CENTER__Y                   equ     480

SEG_WIDTH                       equ     80
SEG_HEIGHT                      equ     10

SET_START_X_OFFSET              equ     0
SET_START_Y_OFFSET              equ     4
SET_END_X_OFFSET                equ     8
SET_END_Y_OFFSET                equ     12

GET_START_X_OFFSET              equ     4
GET_START_Y_OFFSET              equ     8
GET_END_X_OFFSET                equ     12
GET_END_Y_OFFSET                equ     16


SCORE_BOX_X                     equ     $166
SCORE_BOX_Y                     equ     $25C
SCORE_BOX_WIDTH                 equ     80
SCORE_BOX_HEIGHT                equ     50

SCORE_LEFT_X                    equ     $19A   
SCORE_RIGHT_X                   equ     $1AE 

SCORE_UPPER_Y                   equ     $260
SCORE_MIDDLE_Y                  equ     $274
SCORE_LOWER_Y                   equ     $288

SCORE_LEFT_X2                   equ     $172   
SCORE_RIGHT_X2                  equ     $186 


*-----------------------------------------------------------
* Function that draws a segment on the screen
* 4 arguments: start x, start y, end x, end y
*-----------------------------------------------------------
drawSegment
    move.l #WHITE, d1
    move.l #PEN_COLOR_TRAP_CODE, d0          ;set outline color
    trap   #15
    move.l  GET_START_X_OFFSET(sp),d1
    move.l  GET_END_X_OFFSET(sp),d2 

    move.l  GET_START_X_OFFSET(sp),d1
    move.l  GET_START_Y_OFFSET(sp),d2
    move.l  GET_END_X_OFFSET(sp),d3
    move.l  GET_END_Y_OFFSET(sp),d4 
    move.l  #DRAW_LINE_TRAP_CODE,d0
    trap #15    
    
    rts


*-----------------------------------------------------------
* Function that draws a 7 segment number in the ones place.
* Takes one argument: d6=bitmask to draw
*-----------------------------------------------------------
drawOnesPlace
    lea StartXOnes, a1
    lea StartYOnes, a2
    lea EndXOnes, a3
    lea EndYOnes, a4
    move.l  #0, d7                            ;d7 keeps track of offset for parameter
    jsr checkSeg
    rts
    

*-----------------------------------------------------------
* Function that draws a 7 segment number in the tenths place.
* Takes one argument: d6=bitmask to draw
*-----------------------------------------------------------
drawTensPlace
    lea StartXTens, a1
    lea StartYTens, a2
    lea EndXTens, a3
    lea EndYTens, a4
    move.l  #0, d7                            ;d7 keeps track of offset for parameter   
    jsr checkSeg
    rts
    
     
*-----------------------------------------------------------
* Function that checks if a segment should be drawn and draws it
*-----------------------------------------------------------
checkSeg
    move.l NumSegments,d5
    subi.l #1,d5                              ;using dbra for drawing segments loop
    
getBitmask:
    move.l d6, d1                             ;get bitmask
    and.l #1,d1                               ;get the last bit
    cmpi.b #00,d1                             ;if it is not "on" (1), skip
    beq skipSeg

draw:
    sub.l   #16, sp                           ;4 arguments:
    move.l  (a1,d7),SET_START_X_OFFSET(sp)    ;start x
    move.l  (a2,d7),SET_START_y_OFFSET(sp)    ;start y
    move.l  (a3,d7),SET_END_X_OFFSET(sp)      ;end x
    move.l  (a4,d7),SET_END_Y_OFFSET(sp)      ;end y
    jsr drawSegment
    add.l   #16, sp                           ;fix stack
    
skipSeg:
    lsr.l #1,d6                               ;go to next bit
    add.l #4,d7
    dbra d5, getBitmask

    rts
           
*-----------------------------------------------------------
* Function that redraws the score when the score increases
*-----------------------------------------------------------
callScoreFunction
    jsr eraseScore                            ;clears score area 
      
firstNum:
    jsr clearRegisters
    movem.l Score,d5
    divu #10, d5                              ;d5=get our score remainder (ones place)
    clr.w d5
    swap d5
    lsl.l #2,d5                               ;offset to correct bitmask (*4)
    lea BitmaskTable,a0                       ;load up bitmask table
    move.l (a0,d5),d6                         ;d6=bitmask
    jsr drawOnesPlace                         ;draw the number
    
secondNum:
    jsr clearRegisters
    movem.l Score,d5
    divu #10, d5                              ;d5=get our score whole number (tenths)
    swap d5
    clr.w d5
    swap d5
    lsl.l #2,d5                               ;offset to correct bitmask (*4)  
    lea BitmaskTable,a0                       ;load up bitmask table
    move.l (a0,d5),d6                         ;d6=bitmask
    jsr drawTensPlace                         ;draw the number
    
    rts


*-----------------------------------------------------------
* Function that clears the score area
*-----------------------------------------------------------
eraseScore
    movem.l ALL_REG, -(sp)
    move.l	#DARK_GREEN,d1
	move.b	#PEN_COLOR_TRAP_CODE,d0
	trap	#15
	move.b	#SET_FILL_COLOR_TRAP_CODE,d0
	trap	#15
	
    move.b	#DRAW_RECTANGLE_TRAP_CODE,d0 
    move.l  #SCORE_BOX_X,d1
	move.l	d1,d3                                     
	addi.l  #SCORE_BOX_WIDTH,d3
	move.l	#SCORE_BOX_Y,d2                          
    move.l  d2,d4
    add.l	#SCORE_BOX_HEIGHT,d4                         
	trap	#15 
	
    movem.l (sp)+,ALL_REG                                      
    rts




*-----------------------------------------------------------
* Variables
*-----------------------------------------------------------

* contains start and end(x,y) parameters for g,f,e,d,c,b,a segments respectively for ones place and tenths place 
StartXOnes              dc.l    SCORE_LEFT_X,SCORE_LEFT_X,SCORE_LEFT_X,SCORE_LEFT_X,SCORE_RIGHT_X,SCORE_RIGHT_X,SCORE_LEFT_X
StartYOnes              dc.l    SCORE_MIDDLE_Y,SCORE_UPPER_Y,SCORE_MIDDLE_Y,SCORE_LOWER_Y,SCORE_MIDDLE_Y,SCORE_UPPER_Y,SCORE_UPPER_Y
EndXOnes                dc.l    SCORE_RIGHT_X,SCORE_LEFT_X,SCORE_LEFT_X,SCORE_RIGHT_X,SCORE_RIGHT_X,SCORE_RIGHT_X,SCORE_RIGHT_X
EndYOnes                dc.l    SCORE_MIDDLE_Y,SCORE_MIDDLE_Y,SCORE_LOWER_Y,SCORE_LOWER_Y,SCORE_LOWER_Y,SCORE_MIDDLE_Y,SCORE_UPPER_Y

StartXTens              dc.l    SCORE_LEFT_X2,SCORE_LEFT_X2,SCORE_LEFT_X2,SCORE_LEFT_X2,SCORE_RIGHT_X2,SCORE_RIGHT_X2,SCORE_LEFT_X2
StartYTens              dc.l    SCORE_MIDDLE_Y,SCORE_UPPER_Y,SCORE_MIDDLE_Y,SCORE_LOWER_Y,SCORE_MIDDLE_Y,SCORE_UPPER_Y,SCORE_UPPER_Y
EndXTens                dc.l    SCORE_RIGHT_X2,SCORE_LEFT_X2,SCORE_LEFT_X2,SCORE_RIGHT_X2,SCORE_RIGHT_X2,SCORE_RIGHT_X2,SCORE_RIGHT_X2
EndYTens                dc.l    SCORE_MIDDLE_Y,SCORE_MIDDLE_Y,SCORE_LOWER_Y,SCORE_LOWER_Y,SCORE_LOWER_Y,SCORE_MIDDLE_Y,SCORE_UPPER_Y

* contains bitmask values for digits 0-9                
BitmaskTable            dc.l    $7E,$30,$6D,$79,$33,$5B,$5F,$70,$7F,$7B  
NumSegments             dc.l    8
























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
