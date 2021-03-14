	processor	16f877a
	#include	<p16f877a.inc>
	
	__CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF
 
	org		0x00
	goto		Main
	org		0x04
	goto		Interrupt  
    
	Count1		equ 0x20
	Count2		equ 0x21
	Count3		equ 0x22
	Micros		equ 0x23
	Ones		equ 0x24
	Tens		equ 0x25
	
Main:
	bsf		STATUS,5	
	movlw		b'00000000'	   	
	movwf		TRISA
	movlw		b'00000000'	    
	movwf		TRISB
	movlw		b'00000000'	    
	movwf		TRISC
	movlw		b'00000011'	   	
	movwf		TRISD
	movlw		b'00000111'
	movwf		OPTION_REG
	bcf		STATUS,5
	bsf		INTCON,7
	bsf		INTCON,5
	clrf		Ones
	clrf		Tens
	clrf		Micros
    
Check1:	
	bsf		PORTB,7
	bcf		PORTA,3
	btfsc		PORTD,0 
	goto		Gopen
	bcf		PORTA,0
	goto		Check1

Check2:	
	btfss		PORTD,0 
	goto		Gclose
	bcf		PORTA,0
	goto		Check2
	
Gopen:	
	bsf		PORTA,0
	call		Delay2
	bcf		PORTA,0
	goto            Check2
	
Gclose:	
	bsf		PORTA,1
	call		Delay2
	bcf		PORTA,1
	
Check3:	
	btfsc		PORTD,1
	goto		LED
	bcf		PORTA,3
	bsf		PORTB,7
	clrf		Ones
	clrf		Tens
	clrf		Micros
	goto	        Check3

LED:
	bcf		PORTB,7
	bsf		PORTA,3
	goto		Timer
	
Timer:
	movlw		b'00000010'
	movwf		PORTC
	movf		Ones, W
	call		Table
	movwf		PORTB
	call		Delay1
	movlw		b'00000001'
	movwf		PORTC
	movf		Tens, W
	call		Table
	movwf		PORTB
	call		Delay1
	btfss		PORTD,1
	goto		Check4
	goto		Timer
	
Check4:	
	clrf		Ones
	clrf		Tens
	clrf		Micros
	bsf		PORTB,7
	bcf		PORTA,3
	btfsc		PORTD,0 
	goto		GopenAgain
	bcf		PORTA,0
	goto		Check4

Check5:	
	btfss		PORTD,0 
	goto		GcloseAgain
	bcf		PORTA,0
	goto		Check5
	
GopenAgain:	
	bsf		PORTA,0
	call		Delay2
	bcf		PORTA,0
	goto            Check5
	
GcloseAgain:	
	bsf		PORTA,1
	call		Delay2
	bcf		PORTA,1
	goto		Check1
	
Interrupt:
	bcf		INTCON,7
	bcf		INTCON,5
	incf		Micros,1
	movf		Micros,0
	sublw		b'00001111'
	btfsc		STATUS,2
	goto		Inc_Ones
	goto		ReIn
	
Inc_Ones:
	clrf		Micros
	incf		Ones, 1
	movf		Ones, 0
	sublw		b'00001010'
	btfsc		STATUS,2
	goto		Inc_Tens
	goto		ReIn
	
Inc_Tens:
	clrf		Ones
	incf		Tens, 1
	movf		Tens, 0
	sublw		b'00001010'
	btfsc		STATUS,2
	clrf		Tens
	goto		ReIn
	
ReIn:
	bcf		INTCON,2
	bsf		INTCON,7
	bsf		INTCON,5
	retfie
 
Table:
	addwf		PCL
        retlw		b'00111111'    ;digit 0
        retlw		b'00000110'    ;digit 1
        retlw		b'01011011'    ;digit 2
        retlw		b'01001111'    ;digit 3
        retlw		b'01100110'    ;digit 4
        retlw		b'01101101'    ;digit 5
        retlw		b'01111101'    ;digit 6
        retlw		b'00000111'    ;digit 7
        retlw		b'01111111'    ;digit 8
        retlw		b'01101111'    ;digit 9 
	
Delay1:
	loop		decfsz Count1,F
	goto		loop
	return
	
Delay2:
	loop1		decfsz	Count2,1 
	goto		loop1					
	decfsz		Count3,1 				
	goto		loop1
	return
    
End