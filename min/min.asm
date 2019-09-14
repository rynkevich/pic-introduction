#include "p16f84.inc" 

c_adr set 0x30
c_len set 0x14

v_ptr equ 0x2F
v_min equ 0x2E

BEGIN:
	BCF STATUS, RP0
	
	MOVLW c_adr
	MOVWF FSR
	MOVF INDF, W
	MOVWF v_min ; consider first item as minimal

	CLRF v_ptr
	INCF v_ptr, 0x1
	
LOOP:
	MOVF v_ptr, W
	ADDLW c_adr
	MOVWF FSR
	MOVF INDF, W
	SUBWF v_min, W
	BTFSS STATUS, C
	GOTO SKIP ; if current >= min, skip

	MOVF v_ptr, W
	ADDLW c_adr
	MOVWF FSR
	MOVF INDF, W
	MOVWF v_min ; min = current
	
SKIP:
	INCF v_ptr, F
	MOVLW c_len + 1
	SUBWF v_ptr, W
	BTFSS STATUS, C
	GOTO LOOP ; if didn't reach the end of array, continue
	end

