#include "p16f84.inc" 

c_adr set 0x30
c_len set 0x14

v_ptr equ 0x2F
v_is_sorted equ 0x2E
v_current_item equ 0x2D
v_swap_buf equ 0x2C
v_is_ascending equ 0x2B

BEGIN:
	BCF STATUS, RP0
	
	MOVLW c_len
	SUBLW 0x2
	BTFSC STATUS, C
	GOTO FINISH ; if len <= 1, the sort is finished

	MOVF PORTB, W
	ANDLW 0x1
	MOVWF v_is_ascending

OUTER_LOOP:
	CLRF v_ptr
	MOVLW 0x1
	MOVWF v_is_sorted ; is_sorted = true
	
INNER_LOOP:
	MOVF v_ptr, W
	ADDLW c_adr
	MOVWF FSR
	MOVF INDF, W
	MOVWF v_current_item ; current_item = array[ptr]
	
	MOVF v_is_ascending, W
	BTFSS STATUS, Z
	GOTO ASCENDING ; if is_ascending, do ascending sort

DESCENDING:
	INCF FSR
	MOVF INDF, W
	SUBWF v_current_item, W
	BTFSC STATUS, C
	GOTO CONTINUE ; if current >= next, don't swap
	GOTO SWAP
ASCENDING:
	INCF FSR
	MOVF INDF, W
	ADDLW 0x1
	SUBWF v_current_item, W
	BTFSS STATUS, C
	GOTO CONTINUE ; if current <= next, don't swap
	
SWAP:
	MOVLW 0
	MOVWF v_is_sorted ; is_sorted = false

	MOVF INDF, W
	MOVWF v_swap_buf ; swap_buf = next
	MOVF v_current_item, W
	MOVWF INDF ; next = current
	DECF FSR, F
	MOVF v_swap_buf, W
	MOVWF INDF ; current = swap_buf
	
CONTINUE:
	INCF v_ptr, F
	MOVLW c_len
	SUBWF v_ptr, W
	BTFSS STATUS, C
	GOTO INNER_LOOP ; if ptr != (len - 1), continue inner loop
	
	MOVF v_is_sorted, W
	BTFSC STATUS, Z
	GOTO OUTER_LOOP ; if not is_sorted, continue outer loop

FINISH:
	BSF STATUS, RP0
	BCF TRISA, RA0
	BCF STATUS, RP0
	BSF PORTA, RA0 ; set RA0 to notify about finish
	end
