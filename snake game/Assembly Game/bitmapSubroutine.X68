*-----------------------------------------------------------
* Title      : Bitmap Chunk Subroutine
* Written by : Enya Bullard
* Date       : 5/30/2025
* Description: Modified version of our bitmap subroutine project to handle drawing images and
* chunks of images in game through functions.
*-----------------------------------------------------------

PEN_COLOR_TRAP_CODE             EQU     80
DRAW_PIXEL_TRAP_CODE            EQU     82


SET_POINTER_OFFSET              EQU     0
SET_CHUNK_X_OFFSET              EQU     4
SET_CHUNK_Y_OFFSET              EQU     8
SET_CHUNK_WIDTH_OFFSET          EQU     12
SET_CHUNK_HEIGHT_OFFSET         EQU     16
SET_DISPLAY_X_OFFSET            EQU     20
SET_DISPLAY_Y_OFFSET            EQU     24

GET_POINTER_OFFSET              EQU     4
GET_CHUNK_X_OFFSET              EQU     8
GET_CHUNK_Y_OFFSET              EQU     12
GET_CHUNK_WIDTH_OFFSET          EQU     16
GET_CHUNK_HEIGHT_OFFSET         EQU     20
GET_DISPLAY_X_OFFSET            EQU     24
GET_DISPLAY_Y_OFFSET            EQU     28

GET_BITS_OFFSET                 EQU     $1C
GET_IMAGE_DATA_OFFSET           EQU     $0A
GET_BITMAP_WIDTH_OFFSET         EQU     $12
GET_BITMAP_HEIGHT_OFFSET        EQU     $16

THIRTYTWOBITPIX                 EQU     32
  
      
*-----------------------------------------------------------
* drawChunk is a subroutine that draws a chunk from an image at a specified location.
* 7 arguments:
* d0= pointer to .bmp file 
* d1= top left corner x chunk
* d2= top left corner y chunk
* d3= width of bitmap chunk
* d4= height of bitmap chunk
* d5= top left corner x display
* d6= top left corner y display
*-----------------------------------------------------------

drawChunk
     move.l GET_POINTER_OFFSET(sp),d0
     move.l d0,a0                                   ;a0 now contains value from d0 (pointer)
     move.l  GET_CHUNK_X_OFFSET(sp),d1              ;d1=chunk x coordinate
     move.l  GET_CHUNK_Y_OFFSET(sp),d2              ;d2=chunk y coordinate
     
     clr.l d0
     move.w GET_BITS_OFFSET(a0),d0                  ;d0 stores the number of bits per pixel (32)
     ror.w #8, d0
   
     move.l GET_IMAGE_DATA_OFFSET(a0),d3            ;d3 stores the offset where the image data starts
     move.l d3, -(sp)
     jsr endianSwap
     move.l d7, d3
     add.l #4,sp  
    
     move.l GET_BITMAP_WIDTH_OFFSET(a0),d6          ;d6 stores bitmap width total
     move.l d6, -(sp)
     jsr endianSwap
     move.l d7, d6
     add.l #4,sp
    
     move.l GET_BITMAP_HEIGHT_OFFSET(a0),d5         ;d5 stores bitmap height total
     move.l d5, -(sp)
     jsr endianSwap
     move.l d7, d5
     add.l #4,sp
    
     adda.l  d3, a0                                 ;move to image data
     
     cmp.w #THIRTYTWOBITPIX, d0                     ;32 bit picture? 00BBGGRR
     beq thirtyTwoBitChunk
     bra exitChunk                                  ;if not 32-bit, exit

    
thirtyTwoBitChunk:
     * (bitmap width*4)*(bitmap height-(y coord + chunk height)) offset to right pixel in original image
     move.l d6,d3
     lsl.l #2, d3                                   ;bitmap width *4
     
     move.l  GET_CHUNK_HEIGHT_OFFSET(sp),d4         ;d4=height chunk
     add.l d2, d4                                   ;y coord + chunk height
     sub.l d4, d5                                   ;bmap height-(y coord + chunk height)

     mulu d3, d5                                    ;finish eqn
  
     adda.l  d5, a0                                 ;offset to right chunk
     lsl.l #2, d1
     adda.l d1, a0                                  ;offset to correct x position
     
     move.l  GET_CHUNK_WIDTH_OFFSET(sp),d3          ;d3=width chunk
     move.l d6, d7                                  ;d7 has bitmap total width
     sub.l d3, d7                                   ;(total width-chunk width)*4
     lsl.l #2, d7                                   ;d7 is our offset per row
     
     move.l  GET_DISPLAY_X_OFFSET(sp),d5            ;d5=display x
     move.l  GET_DISPLAY_Y_OFFSET(sp),d6            ;d6=display y
     
     add.l d5, d3                                   ;total width (display x coordinate +width chunk)
     move.l  GET_CHUNK_HEIGHT_OFFSET(sp),d4
     add.l d6, d4                                   ;total height (display y coordinate + height chunk)

     clr.l d1
     move.l #$FFFFFFFF, d0                          ;d0 will store last color (start with invalid value)
     
continueRow2Chunk:       
     move.l  (a0)+,d1                               
     cmp.b #$00,d1                                  ;check alpha channel for transparency. If 00 then skip
     beq skip
     lsr.l #8, d1                                   ;getting to right format 00BBGGRR
     
     cmp.l d0, d1                                   ;same color as last pixel?
     beq sameColor                                  ;if yes, skip setting pen color
     move.l d1, d0                                  ;store new color
     move.l  #PEN_COLOR_TRAP_CODE, d0               ;set the pen color       
     trap    #15
     move.l d1, d0                                  ;restore color to d0
     
sameColor:
     move.l  d5,d1                                  
     move.l  d4,d2                                  
     move.l  #DRAW_PIXEL_TRAP_CODE,d0               ;draw pixel at (x,y)
     trap #15
     move.l d1, d0                                  ;restore last color to d0
     
skip:
     addi.l  #1,d5                                  ;move to next pixel in the row
     cmp.l   d5,d3                                  ;reached end row? if not, continue printing row
     bne     continueRow2Chunk
     
     move.l  GET_DISPLAY_X_OFFSET(sp),d5            ;reset to beginning of col   
     subi.l  #1,d4                                  ;move to next row
     adda.l d7,a0                                   ;offset next row
     cmp.l  d6,d4                                   ;reached end height?
     bne     continueRow2Chunk                      ;if not, continue printing
     beq exitChunk     

exitChunk:
	 rts
	 	 
*-----------------------------------------------------------
* endianSwap is a subroutine that swaps from little endian to big endian.
* 1 argument: d7= item to swap and return
*-----------------------------------------------------------	 

endianSwap
    move.l  4(sp),d7
    ror.w #8, d7
    swap d7
    ror.w #8, d7 ;d7 is our return value
    rts
    
    

















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
