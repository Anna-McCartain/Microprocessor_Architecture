;my programme prints out a present, then prints out on the screen which notes
;to play and then youi can play them - they are a xmas song

ORG 0

bal clears

;definintions

lights     	defw 0xFF00     		;1
red     		defw 0x00E0     		;2
green  			defw 0x001C     		;3
blue   			defw 0x0003     		;4
lightsend 	defw 0xFF40  				;5
off					defw 0x0000       	;6
linestart 	defw 0xFF40  				;7
lineend   	defw 0xFF90  				;8
p  					defw 0x0050      		;9
l  					defw 0x004C      		;10
a  					defw 0x0041      		;11
y  					defw 0x0059      		;12
row1end 		defw 0xFF08    			;13
key2				defw 0x0004					;14
key5				defw 0x0020					;15
buzzer  		defw &FF92      		;r1 + 1
busy    		defw &FF93      		;r1 + 2
keypad			defw &FF94					;r1 + 3
key0				defw 0x0001					;r1 + 4
key8				defw 0x0100					;r1 + 5
E 					defw 0x8155					;r1 + 6
G						defw 0x8158					;r1 + 7
C						defw 0x8150     		;r1 + 8
D						defw 0x8153					;r1 + 9
two     		defw 0x0032					;r1 + 10
five    		defw 0x0035					;r1 + 11
eight   		defw 0x0038					;r1 + 12
zero    		defw 0x0030					;r1 + 13

;loop to clear LED screen
clears  	ld  r6, [r0, #8]
					ld  r3, [r0, #15]
    			ld  r2, [r0, #7]
loopcl		mov r1, r2
					add r2, r2, #1
    			st  r3, [r1]
					cmp r2, r6
					bne loopcl


;loop to clear rbg led screen
clear  		ld  r6, [r0, #5]
					ld  r3, [r0, #6]
    			ld  r2, [r0, #1]
loopclr		mov r1, r2
					add r2, r2, #1
    			st  r3, [r1]
					cmp r2, r6
					bne loopclr


;print present
present
					ld  r3, [r0, #4] 		;blue
     			ld  r2, [r0, #1] 		;firstaddress

															;load the end of matrix address into r6
					ld  r6, [r0, #13]

															;load a place counter into r5
					mov r5, #0

															;light the first row
					loop1	mov r1, r2
					add r2, r2, #1
					add r5, r5, #1
					ld  r4, [r0, #1] 		;delay
delay1		subs r4, r4, #1
					bne delay1
     			st  r3, [r1]
					cmp r2, r6
					bne loop1

															;row2
					add r6, r6, #8
loop2			mov r1, r2
					add r2, r2, #1
					add r5, r5, #1
					ld  r4, [r0, #1] 		;delay
delay2		subs r4, r4, #1
					bne delay2
					cmp r5, #11
					beq green1
					cmp1	cmp r5, #13
					bne str1
green1		ld r3, [r0, #3]
str1    	st  r3, [r1]
					ld r3, [r0, #4]
					cmp r2, r6
					bne loop2

															;row 3
															;reset counter
					mov r5, #0
					add r6, r6, #8
loop3			mov r1, r2
					add r2, r2, #1
					add r5, r5, #1
					ld  r4, [r0, #1] 		;delay
delay3		subs r4, r4, #1
					bne delay3
					cmp r5, #4
					bne str2
					ld r3, [r0, #3]
str2    	st  r3, [r1]
					ld r3, [r0, #4]
					cmp r2, r6
					bne loop3

															;row 4
															;reset counter
					mov r5, #0
					add r6, r6, #8
loop4			mov r1, r2
					add r2, r2, #1
					add r5, r5, #1
					ld  r4, [r0, #1] 		;delay
delay4		subs r4, r4, #1
					bne delay4
					cmp r5, #4
					bne cmp4
					ld r3, [r0, #3]
cmp4			cmp r5, #2
					beq red4
					cmp r5, #3
					beq red4
					cmp r5, #5
					beq red4
					cmp r5, #6
					beq red4
					b str4
red4			ld r3, [r0, #2]
str4    	st  r3, [r1]
					ld r3, [r0, #4]
					cmp r2, r6
					bne loop4

															;row 5
															;reset counter
	        mov r5, #0
					add r6, r6, #8
loop5			mov r1, r2
					add r2, r2, #1
					add r5, r5, #1
					ld  r4, [r0, #1] 		;delay
delay5		subs r4, r4, #1
					bne delay5
					cmp r5, #4
					bne cmp5
					ld r3, [r0, #3]
cmp5			cmp r5, #2
					beq red5
					cmp r5, #3
					beq red5
					cmp r5, #5
					beq red5
					cmp r5, #6
					beq red5
					b str5
red5			ld r3, [r0, #2]
str5    	st  r3, [r1]
					ld r3, [r0, #4]
					cmp r2, r6
					bne loop5

															;row 6
															;reset counter
	        mov r5, #0
					add r6, r6, #8
loop6			mov r1, r2
					add r2, r2, #1
					add r5, r5, #1
					ld  r4, [r0, #1] 		;delay
delay6		subs r4, r4, #1
					bne delay6
cmp6			cmp r5, #2
					beq green6
					cmp r5, #3
					beq green6
					cmp r5, #4
					beq green6
					cmp r5, #5
					beq green6
					cmp r5, #6
					beq green6
					b str6
green6		ld r3, [r0, #3]
str6    	st  r3, [r1]
					ld r3, [r0, #4]
					cmp r2, r6
					bne loop6

																;row 7
																;reset counter
					mov r5, #0
					add r6, r6, #8
loop7			mov r1, r2
					add r2, r2, #1
					add r5, r5, #1
					ld  r4, [r0, #1] 			;delay
delay7		subs r4, r4, #1
					bne delay7
					cmp r5, #4
					bne cmp7
					ld r3, [r0, #3]
cmp7			cmp r5, #2
					beq red7
					cmp r5, #3
					beq red7
					cmp r5, #5
					beq red7
					cmp r5, #6
					beq red7
					b str7
red7			ld r3, [r0, #2]
str7    	st  r3, [r1]
					ld r3, [r0, #4]
					cmp r2, r6
					bne loop7

																	;row 8
																	;reset counter
	        mov r5, #0
					add r6, r6, #8
loop8			mov r1, r2
					add r2, r2, #1
					add r5, r5, #1
					ld  r4, [r0, #1] 				;delay
delay8		subs r4, r4, #1
					bne delay8
					cmp r5, #4
					bne cmp8
					ld r3, [r0, #3]
cmp8			cmp r5, #2
					beq red8
					cmp r5, #3
					beq red8
					cmp r5, #5
					beq red8
					cmp r5, #6
					beq red8
					b str8
red8			ld r3, [r0, #2]
str8    	st  r3, [r1]
					ld r3, [r0, #4]
					cmp r2, r6
					bne loop8


;print the keys to play on screen
ps				ld  r3, [r0, #9]
    			ld  r2, [r0, #7]
					mov r1, r2
					add r2, r2, #1
    			st  r3, [r1]

					ld  r4, [r0, #1]
delayb		subs r4, r4, #1
					bne delayb


					ls	ld  r3, [r0, #10]
					mov r1, r2
					add r2, r2, #1
    			st  r3, [r1]

					ld  r4, [r0, #1]
delayc		subs r4, r4, #1
					bne delayc


as				ld  r3, [r0, #11]
					mov r1, r2
					add r2, r2, #1
    			st  r3, [r1]

					ld  r4, [r0, #1]
delayd		subs r4, r4, #1
					bne delayd



ys				ld  r3, [r0, #12]
					mov r1, r2
					add r2, r2, #1
    			st  r3, [r1]

					ld  r4, [r0, #1]
delaye		subs r4, r4, #1
					bne delaye


s					ld  r3, [r0, #15]
					mov r1, r2
					add r2, r2, #1
    			st  r3, [r1]

					ld  r4, [r0, #1]
delayf		subs r4, r4, #1
					bne delayf


					mov r5, #15
					ld  r3, [r5, #11]
					mov r1, r2
					add r2, r2, #1
    			st  r3, [r1]

					ld  r4, [r0, #1]
delayg		subs r4, r4, #1
					bne delayg


					mov r1, r2
					add r2, r2, #1
    			st  r3, [r1]

					ld  r4, [r0, #1]
delayh		subs r4, r4, #1
					bne delayh


					mov r1, r2
					add r2, r2, #1
    			st  r3, [r1]

					ld  r4, [r0, #1]
delayi		subs r4, r4, #1
					bne delayi


					mov r1, r2
					add r2, r2, #1
    			st  r3, [r1]

					ld  r4, [r0, #1]
delayj		subs r4, r4, #1
					bne delayj


					mov r1, r2
					add r2, r2, #1
    			st  r3, [r1]

					ld  r4, [r0, #1]
delayk		subs r4, r4, #1
					bne delayk


					mov r1, r2
					add r2, r2, #1
    			st  r3, [r1]

					ld  r4, [r0, #1]
delayl		subs r4, r4, #1
					bne delayl


					mov r1, r2
					add r2, r2, #1
    			st  r3, [r1]

					ld  r4, [r0, #1]
delaym		subs r4, r4, #1
					bne delaym




2					ld  r3, [r5, #10]
					mov r1, r2
					add r2, r2, #1
    			st  r3, [r1]

					ld  r4, [r0, #1] ;delay
delayn		subs r4, r4, #1
					bne delayn


0					ld  r3, [r5, #13]
					mov r1, r2
					add r2, r2, #1
    			st  r3, [r1]

					ld  r4, [r0, #1] ;delay
delayo		subs r4, r4, #1
					bne delayo


8					ld  r3, [r5, #12]
					mov r1, r2
					add r2, r2, #1
    			st  r3, [r1]

					ld  r4, [r0, #1] ;delay
delayp		subs r4, r4, #1
					bne delayp


55				ld  r3, [r5, #11]
					mov r1, r2
					add r2, r2, #1
    			st  r3, [r1]



;this part allows you to hit the keys and play a song

main
																					;new offset is in r1
					mov r1, #15

					ld  r2, [r1, #3] 								;keypad
					ld  r2, [r2]
					ld  r3, [r0, #14] 							;key2
					ld  r4, [r0, #15] 							;key5
					ld  r5, [r1, #5]  							;key8
					ld  r6, [r1, #4]  							;key0
					cmp r2, r3
					beq gee
					cmp r2, r4
					beq eee
					cmp r2, r5
					beq dee
					cmp r2, r6
					beq cee
					b main

gee				ld r4, [r1, #1]
					ld r3, [r1, #7]
					st r3, [r4]
buzzlp1		ld  r2, [r1, #2]
					ld  r2, [r2]
					cmp r2, r0
					bne buzzlp1
					b main

eee				ld r4, [r1, #1]
					ld r3, [r1, #6]
					st r3, [r4]
buzzlp2		ld  r2, [r1, #2]
					ld  r2, [r2]
					cmp r2, r0
					bne buzzlp2
					b main

dee				ld r4, [r1, #1]
					ld r3, [r1, #9]
					st r3, [r4]
buzzlp3		ld  r2, [r1, #2]
					ld  r2, [r2]
					cmp r2, r0
					bne buzzlp3
					b main

cee				ld r4, [r1, #1]
					ld r3, [r1, #8]
					st r3, [r4]
buzzlp4		ld  r2, [r1, #2]
					ld  r2, [r2]
					cmp r2, r0
					bne buzzlp4
					b main
