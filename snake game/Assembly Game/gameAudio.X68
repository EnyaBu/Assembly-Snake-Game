*-----------------------------------------------------------
* Title      : gameAudio
* Written by : Enya Bullard
* Date       : 6/5/2025
* Description: plays sounds upon collision and turns
*-----------------------------------------------------------
PLAY_MULTIPLE_SOUND_TRAP_CODE equ 73
PLAY_SOUND_TRAP_CODE equ 70

*-----------------------------------------------------------
* Functions to play sound
*-----------------------------------------------------------
playCollisionSound
    lea CollisionSound, a1
    move.b  #PLAY_SOUND_TRAP_CODE, d0 
    trap #15
    rts

playTurnSound
    lea TurnSound, a1
    move.b #PLAY_MULTIPLE_SOUND_TRAP_CODE, d0                 
    trap #15
    rts

playEatSound
    lea ChompSound, a1
    move.b #PLAY_MULTIPLE_SOUND_TRAP_CODE, d0        
    trap #15
    rts

playEnterSound
    lea EnterSound, a1
    move.b #PLAY_SOUND_TRAP_CODE, d0 
    trap #15
    rts


*-----------------------------------------------------------
* Variables
*-----------------------------------------------------------

ChompSound              dc.l    'wav_files\chomp_sound.wav',0
CollisionSound          dc.l    'wav_files\game_end.wav',0
TurnSound               dc.l    'wav_files\turn_sound.wav',0
EnterSound              dc.l    'wav_files\enter_game.wav',0














*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
