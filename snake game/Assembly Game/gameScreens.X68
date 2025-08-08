*-----------------------------------------------------------
* Title      : gameScreens
* Written by : Enya Bullard
* Date       : 5/30/2025
* Description: Screen commands, including loading screen, title screen, and 
*              end screen set up for the snake game, as well as helper functions
*              for clearing the screen and swaping screens. 
*-----------------------------------------------------------   
SET_TEXT_POSITION_TRAP_CODE  equ 95
DISPLAY_NUMBER_TRAP_CODE     equ 3
SET_CURSOR_TRAP_CODE         equ 11
DRAW_COLOR_COMMAND           equ 4
SET_FILL_COLOR_TRAP_CODE     equ 81
DRAW_UNFILLED_RECT           equ 90
DRAW_RECTANGLE_TRAP_CODE     equ 87
PEN_WIDTH_TRAP_CODE          equ 93
REPAINT_SCREEN_TRAP_CODE     equ 94
CLEAR_SCREEN_TRAP_CODE       equ 11

FRUIT_WIDTH                  equ 13
FRUIT_HEIGHT                 equ 15

GAME_BORDER_X                equ 25
GAME_BORDER_Y                equ 20
GAME_BORDER_WIDTH            equ 775
GAME_BORDER_HEIGHT           equ 600

TITLE_TEXT_X                 equ 277
TITLE_TEXT_Y                 equ 600

INS_TEXT_X                   equ 180
INS_TEXT_Y                   equ 650

GAME_OVER_TEXT_X             equ 290
GAME_OVER_TEXT_Y             equ 195

RESTART_TITLE_TEXT_X         equ 254
RESTART_TITLE_TEXT_Y         equ 220

RESTART_GAME_TEXT_X          equ 290
RESTART_GAME_TEXT_Y          equ 245

LOADING_WIDTH                equ 275
LOADIND_HEIGHT               equ 94
LOADING_Y                    equ 250

LOGO_WIDTH                   equ 420
LOGO_HEIGHT                  equ 156
LOGO_Y                       equ 60

SNAKE_IMAGE_WIDTH            equ 249
SNAKE_IMAGE_HEIGHT           equ 150
SNAKE_IMAGE_Y                equ 250

KEYS_WIDTH                   equ 222
KEYS_HEIGHT                  equ 150
KEYS_Y                       equ 420

SKULL_WIDTH                  equ 100
SKULL_HEIGHT                 equ 88
SKULL_Y                      equ 300

SCORE_TEXT_POSITION          equ $3F0D

PEN_WIDTH                    equ 5
THIN_PEN_WIDTH               equ 3

SNAKE_CENTER__X              equ 400
SNAKE_CENTER__Y              equ 250
SNAKE_WIDTH		             equ 13
SNAKE_HEIGHT		         equ 13

SNAKE_INITIAL_VELOCITY       equ 40

BACKGROUND_COLOR             equ $005ABA9B
WHITE                        equ $FFFFFF
BLACK                        equ $000000
DARK_GREEN                   equ $002B331A

SCORE_BOX_FULL_X             equ 25
SCORE_BOX_FULL_Y             equ 575
SCORE_BOX_FULL_WIDTH         equ 775
SCORE_BOX_FULL_HEIGHT        equ 680

*-----------------------------------------------------------
* Loading screen with a loading image centered
*-----------------------------------------------------------       
loadingScreen
     ;jsr clearRegisters
     lea LoadingText, a0
     sub.l   #28, sp                                              ;7 arguments:
     move.l  a0,SET_POINTER_OFFSET(sp)                            ;d0= pointer to .bmp file 
     move.l  #0,SET_CHUNK_X_OFFSET(sp)                            ;d1= top left corner x chunk
     move.l  #0,SET_CHUNK_Y_OFFSET(sp)                            ;d2= top left corner y chunk
     move.l  #LOADING_WIDTH,SET_CHUNK_WIDTH_OFFSET(sp)                   ;d3= width of bitmap chunk
     move.l  #LOADIND_HEIGHT,SET_CHUNK_HEIGHT_OFFSET(sp)                 ;d4= height of bitmap chunk
     move.l  #(SCREEN_WIDTH-LOADING_WIDTH)>>1,SET_DISPLAY_X_OFFSET(sp)   ;d5= top left corner x display
     move.l  #LOADING_Y,SET_DISPLAY_Y_OFFSET(sp)                         ;d6= top left corner y display
     jsr     drawChunk                                            ;call the subroutine to draw image
     add.l   #28, sp                                              ;fix stack
     jsr swapScreen                                               ;jumps back when done loading
     rts


*-----------------------------------------------------------
* Title screen with logo and instructions centered
*-----------------------------------------------------------  
titleScreen 
     jsr clearScreen
     
     move.b #SET_FILL_COLOR_TRAP_CODE,d0               ;set fill color 
     move.l #BACKGROUND_COLOR,d1   
     trap   #15
    
     move.b	#DRAW_RECTANGLE_TRAP_CODE,d0               ;fill screen with background color
     move.l #0,d1   
     move.l #0,d2                           
	 move.l #SCREEN_WIDTH,d3
     move.l	#SCREEN_HEIGHT,d4                         
	 trap	#15
	
     lea Logo, a0                                      ;draw logo on top 
     sub.l  #28, sp                            
     move.l a0,SET_POINTER_OFFSET(sp)           
     move.l #0,SET_CHUNK_X_OFFSET(sp)          
     move.l #0,SET_CHUNK_Y_OFFSET(sp)          
     move.l #LOGO_WIDTH,SET_CHUNK_WIDTH_OFFSET(sp)   
     move.l #LOGO_HEIGHT,SET_CHUNK_HEIGHT_OFFSET(sp) 
     move.l #(SCREEN_WIDTH-LOGO_WIDTH)>>1,SET_DISPLAY_X_OFFSET(sp)     
     move.l #LOGO_Y,SET_DISPLAY_Y_OFFSET(sp)       
     jsr    drawChunk                          
     add.l  #28, sp                            
	 
	 lea SnakeImage, a0                                ;snake image in the middle
     sub.l  #28, sp                            
     move.l a0,SET_POINTER_OFFSET(sp)           
     move.l #0,SET_CHUNK_X_OFFSET(sp)          
     move.l #0,SET_CHUNK_Y_OFFSET(sp)          
     move.l #SNAKE_IMAGE_WIDTH,SET_CHUNK_WIDTH_OFFSET(sp)   
     move.l #SNAKE_IMAGE_HEIGHT,SET_CHUNK_HEIGHT_OFFSET(sp) 
     move.l #(SCREEN_WIDTH-SNAKE_IMAGE_WIDTH)>>1,SET_DISPLAY_X_OFFSET(sp)     
     move.l #SNAKE_IMAGE_Y,SET_DISPLAY_Y_OFFSET(sp)       
     jsr    drawChunk                          
     add.l  #28, sp
     
     lea Keys, a0                                      ;WASD keys at the bottom

     sub.l  #28, sp                            
     move.l a0,SET_POINTER_OFFSET(sp)           
     move.l #0,SET_CHUNK_X_OFFSET(sp)          
     move.l #0,SET_CHUNK_Y_OFFSET(sp)          
     move.l #KEYS_WIDTH,SET_CHUNK_WIDTH_OFFSET(sp)    
     move.l #KEYS_HEIGHT,SET_CHUNK_HEIGHT_OFFSET(sp)  
     move.l #(SCREEN_WIDTH-KEYS_WIDTH)>>1,SET_DISPLAY_X_OFFSET(sp)      
     move.l #KEYS_Y,SET_DISPLAY_Y_OFFSET(sp)      
     jsr    drawChunk                          
     add.l  #28, sp                            
     
     lea TitleText, a1                                 ;explains what keys to use
     move.l #TITLE_TEXT_X, d1
     move.l #TITLE_TEXT_Y, d2
     move.b #SET_TEXT_POSITION_TRAP_CODE,d0
     trap   #15
     
     lea InstructionsText, a1                          ;explains how the game works
     move.l #INS_TEXT_X, d1
     move.l #INS_TEXT_Y, d2
     move.b #SET_TEXT_POSITION_TRAP_CODE,d0
     trap   #15
     
     jsr swapScreen
     rts
 

*-----------------------------------------------------------
* Game screen with a border, 7 segment score display at the bottom, fruit and a snake
*-----------------------------------------------------------      
gameScreen
     jsr clearRegisters
     jsr clearScreen 
 
     move.b #SET_FILL_COLOR_TRAP_CODE,d0               ;set fill color
     move.l #BACKGROUND_COLOR,d1   
     trap #15
    
     move.b	#DRAW_RECTANGLE_TRAP_CODE,d0 
     move.l #0,d1   
     move.l #0,d2                           
	 move.l #SCREEN_WIDTH,d3
     move.l	#SCREEN_HEIGHT,d4                         
	 trap	#15 
	
     move.l #DARK_GREEN,d1                           ;draw our border for the game
	 move.b #PEN_COLOR_TRAP_CODE,d0
	 trap   #15
	 move.b #PEN_WIDTH_TRAP_CODE,d0
	 move.l #PEN_WIDTH,d1
	 trap   #15 
     move.b #DRAW_UNFILLED_RECT,d0
     move.l #GAME_BORDER_X, d1                       ;border starts at (25,20) and ends at (775,600)
     move.l #GAME_BORDER_Y, d2
     move.l #GAME_BORDER_WIDTH,d3
     move.l #GAME_BORDER_HEIGHT,d4
     trap #15
   
     movem.l ALL_REG, -(sp)
    
	 move.b #PEN_WIDTH_TRAP_CODE,d0
	 move.l #PEN_WIDTH,d1
	 trap   #15
     move.b #SET_FILL_COLOR_TRAP_CODE,d0             ;set fill color
     move.l #DARK_GREEN,d1   
     trap #15
    
     move.b	#DRAW_RECTANGLE_TRAP_CODE,d0             ;draw the score box
     move.l #SCORE_BOX_FULL_X,d1   
     move.l #SCORE_BOX_FULL_Y,d2
     move.l d1,d3                              
	 move.l #SCORE_BOX_FULL_WIDTH,d3
     move.l	#SCORE_BOX_FULL_HEIGHT,d4                         
	 trap	#15 
		
     movem.l (sp)+,ALL_REG
    
     move.b #PEN_WIDTH_TRAP_CODE,d0
	 move.l #THIN_PEN_WIDTH,d1
	 trap   #15
 
     lea Score, a4                                   ;initialize score to 0
     move.l #0, d1
     movem.l d1,(a4)

     jsr spawnFruit                                  ;spawn first fruit
     jsr callScoreFunction                           ;draw score
    
	 move.l	#SNAKE_CENTER__X<<FRACTIONAL_BITS,d7     ;draw snake: d7= start x, d2= start y
	 lea SnakeX,a2
	 movem.l d7,(a2)                                 ;save our head coordinate x to variable SnakeX
	
     move.l	#SNAKE_INITIAL_VELOCITY,d6                       
	 lea Velocity, a2
     movem.l d6,(a2) 	                             ;save d6= velocity to variable Velocity
    
     move.l	#SNAKE_CENTER__Y<<FRACTIONAL_BITS,d2      
     lea SnakeY,a3
	 movem.l d2,(a3)                                 ;save our head coordinate y to variable SnakeY
     move.l	d2,d4                                    ;d4= end y
	 add.l	#SNAKE_WIDTH,d4	
     lea SnakeBodyLength, a2                         ;snake gets longer (snake length +20px)
     movem.l (a2),d6
     addi.l #10,d6
     movem.l d6,(a2)  
     jsr updateBody                                  ;shift everything back once to make space for the head
    
     move.b #PEN_WIDTH_TRAP_CODE,d0
	 move.b #THIN_PEN_WIDTH,d1
	 trap   #15 
     jsr drawSnake
     jsr swapScreen
     rts 
    
    
*-----------------------------------------------------------
* Game over screen with game over text, score, as well as keys to restart the game
*-----------------------------------------------------------          
gameOverScreen
    jsr clearScreen
    
     move.b #SET_FILL_COLOR_TRAP_CODE,d0               ;set fill color
     move.l #BACKGROUND_COLOR,d1   
     trap #15
    
     move.b	#DRAW_RECTANGLE_TRAP_CODE,d0 
     move.w  #0,d1   
     move.w  #0,d2                           
	 move.w  #SCREEN_WIDTH,d3
     move.w	#SCREEN_HEIGHT,d4                         
	 trap	#15
	
     lea GameOverText, a1
     move.l #GAME_OVER_TEXT_X, d1
     move.l #GAME_OVER_TEXT_Y, d2
     move.b #SET_TEXT_POSITION_TRAP_CODE,d0
     trap #15
    
     lea RestartTitleText, a1
     move.l #RESTART_TITLE_TEXT_X, d1
     move.l #RESTART_TITLE_TEXT_Y, d2
     move.b #SET_TEXT_POSITION_TRAP_CODE,d0
     trap #15
    
     lea RestartGameText, a1
     move.l #RESTART_GAME_TEXT_X, d1
     move.l #RESTART_GAME_TEXT_Y, d2
     move.b #SET_TEXT_POSITION_TRAP_CODE,d0
     trap #15
    
     move.l #SET_CURSOR_TRAP_CODE,d0
     move.l #SCORE_TEXT_POSITION,d1
     trap #15
     move.l #DISPLAY_NUMBER_TRAP_CODE,d0
     lea Score, a4
     movem.l (a4),d1
     trap #15

     lea Skull, a0
     sub.l   #28, sp                            
     move.l  a0,SET_POINTER_OFFSET(sp)           
     move.l  #0,SET_CHUNK_X_OFFSET(sp)          
     move.l  #0,SET_CHUNK_Y_OFFSET(sp)          
     move.l  #SKULL_WIDTH,SET_CHUNK_WIDTH_OFFSET(sp)    
     move.l  #SKULL_HEIGHT,SET_CHUNK_HEIGHT_OFFSET(sp)  
     move.l  #(SCREEN_WIDTH-SKULL_WIDTH)>>1,SET_DISPLAY_X_OFFSET(sp)      
     move.l  #SKULL_Y,SET_DISPLAY_Y_OFFSET(sp)      
     jsr     drawChunk                          
     add.l   #28, sp   
     
     jsr swapScreen
     rts


*-----------------------------------------------------------
* Function that swaps the screen by copying off screen buffer to visible screen
*----------------------------------------------------------- 
swapScreen
     move.b  #REPAINT_SCREEN_TRAP_CODE, d0
     trap    #15
     rts 
   
   
*-----------------------------------------------------------
* Function that clears the screen
*----------------------------------------------------------- 
clearScreen
	 move.b  #CLEAR_SCREEN_TRAP_CODE,d0
     move.l  #$FF00,d1
     trap    #15
     rts



*-----------------------------------------------------------
* Variables
*-----------------------------------------------------------
LoadingText             INCBIN  'bitmaps\loading.bmp'
Background              INCBIN  'bitmaps\background.bmp'
Logo                    INCBIN  'bitmaps\logo.bmp'
Keys                    INCBIN  'bitmaps\wasd_keys.bmp'
Apple                   INCBIN  'bitmaps\fruit.bmp'
SnakeImage              INCBIN  'bitmaps\snakeImage.bmp'
Skull                   INCBIN  'bitmaps\skull.bmp'

GameOverText            dc.l    'Game over! Your score was: ',0 
RestartTitleText        dc.l    'Press ENTER to go back to title screen',0 
RestartGameText         dc.l    'Press SPACE to restart game',0 
TitleText               dc.l    'WASD to move and SPACE to start',0  
InstructionsText        dc.l    'Eat apples, and avoid collision with the wall or yourself!',0






























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
