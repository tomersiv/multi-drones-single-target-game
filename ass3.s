section .data 
global temp1
global Rstate
global MAX_INT
global Rstate32bit
global floatNum
global range
global rangeFloat
global numco
global constRange
global constRangeFloat
global maxAlpha
global constPi
global temp1
global temp2
global currentDroneToRun
global numStepsToPrint
global currentStepNum
global numDestroyToWin
global betaTemp
global beta
global gamma
global maxDistance
global NumOfDrones
global droneIdCounter



Rstate: dw 65248
MAX_INT : dd 65535
Rstate32bit :dd 1
floatNum: dq 1.0
range : dd 100
rangeFloat : dq 60.0
numco: dd 3
constRange : dd 100
constRangeFloat : dq 100.0
maxAlpha : dq 360.0
constPi : dd 180
temp1 : dq 0
temp2 : dq 0
currentDroneToRun: dd 0
numStepsToPrint : dd 0
currentStepNum : dd 0
numDestroyToWin : dd 0
betaTemp: dd 1
beta: dq 1.0
gamma: dq 1.0
maxDistance: dd 1
NumOfDrones: dd 0
droneIdCounter: dd 1

section .bss
global Drones
global currDrone
global RestCors
global CURR
global SPT
global SPMAIN
global schedulerStruct
global printerStruct
global targetStruct

Drones: resb 4
currDrone: resb 4
RestCors: resb 4 
CURR: resb 4
SPT: resb 4 ;temporary stack pointer
SPMAIN: resb 4 ; stack pointer of main
schedulerStruct: resb 4
printerStruct: resb 4
targetStruct: resb 4
originsStacks: resd 1
    

section	.rodata	
    global formatTarget
    global STKSIZE
    global RANDOM_MASK
    global CODEP
    global SPP
    global Xposition
    global Yposition
    global alphaPosition
    global numOfTargetsDestroyedPos
    global DroneSize
    global formatDrone
    global formatCheckArgs
    global formatCheckRandom
    global winner_format
    global formatMyId
    global argBuffer
    global droneId
    global TargetSize

    formatTarget: db "%.2f,%.2f",10,0 
    formatDrone: db "%d,%.2f,%.2f,%.2f,%d",10,0 
    formatCheckArgs: db "%d,%d,%d,%d,%d,%d",10,0
    formatCheckRandom: db "%.2f",10,0 
    winner_format: db "Drone id %d  I am a winner",10,0 
    formatMyId: db "%d",10,0 
    argBuffer: db "%d", 0
    STKSIZE equ 16*1024
    CODEP equ 0
    SPP equ 4
    droneId equ 32
    Xposition equ 8
    Yposition equ 16
    alphaPosition equ 24
    numOfTargetsDestroyedPos equ 36
    DroneSize equ  40 ; func , stack pointer ,  x , y , alpha ,id, num of targets destroyed.
    TargetSize equ 24 ; func , stack pointer, x , y
    RANDOM_MASK equ 0x2D
      
    
section .text
  align 16
     extern printf
     extern malloc
     extern free
     extern sscanf
    extern schedulerFunc
    extern targetFunc
    extern droneFunc
    extern printerFunc
    global generateRandom
    global scaleRandom
    global endCo
    global resume
    global main


main: 

    
    
    
    ; push dword 100
    ; call scaleRandom
    ; add esp,4
    ; push dword [floatNum+4]
    ; push dword [floatNum]
    ; push dword [floatNum+4]
    ; push dword [floatNum]
    ; push formatTarget
    ; call printf
    ; add esp,20




    push ebp ;Get N argument
	mov ebp,esp
	mov edx,[ebp+12]
    add edx,4
	pushad
	push dword NumOfDrones
	push argBuffer
	push dword [edx]
	call sscanf
	add esp,12
	popad
    ;mov eax,dword [NumOfDrones]
    add edx,4

           
    pushad ;Get T argument
	push dword numDestroyToWin
	push argBuffer
	push dword [edx]
	call sscanf
	add esp,12
	popad 
    add edx,4
                     
    pushad ;Get K argument
	push dword numStepsToPrint
	push argBuffer
	push dword [edx]
	call sscanf
	add esp,12
	popad 
    add edx,4

                
    pushad ;Get Beta argument
	push dword betaTemp
	push argBuffer
    push dword [edx]
	call sscanf
	add esp,12
	popad 
    finit
    fldpi   ; Convert degrees into radians
    fimul dword [betaTemp]
    fidiv dword [constPi]
    fstp qword [beta] 
    add edx,4

    pushad ;Get d argument
    push dword maxDistance
	push argBuffer
    push dword [edx]
	call sscanf
	add esp,12
	popad 
    add edx,4

    pushad ;Get seed argument
	push dword Rstate32bit
	push argBuffer
	push dword [edx]
	call sscanf
	add esp,12
	popad 
    add edx,4
    mov ax,[Rstate32bit]
    mov [Rstate],ax

    ; call generateRandom
    ; push 360
    ; call scaleRandom
    ; add esp,4
    ; finit
    ; fldpi   ; Convert degrees into radians
    ; fmul qword [floatNum]
    ; fidiv dword [constPi]
    ; fstp qword [floatNum]
    ; finit
    ; fild dword [constPi]   ; Convert radians into degrees
    ; fmul qword [floatNum] ;180*angle(rad)
    ; fstp qword [floatNum] ; ;180*angle(rad)
    ; finit
    ; fldpi
    ; fld qword [floatNum]
    ; fdiv st0,st1
    ; fstp qword [floatNum]
    ; push dword [floatNum+4]
    ; push dword [floatNum]
    ; push formatCheckRandom
    ; call printf
    ; ret


; randomCheck:
;     mov edi,  10 
; loopRandom :
;     call generateRandom 
;     push word [Rstate]
;     push formatCheckRandom
;     call printf
;     add esp,6
;     dec edi
;     cmp edi,0
;     jnz loopRandom
;     ret

    mov eax, [NumOfDrones]
    add eax, 4
    imul eax, 4
    push eax
    call malloc
    add esp, 4
    mov dword [originsStacks], eax
;init printer    
    push dword 1
    push dword 8
    call malloc
    add esp,8
    mov [printerStruct],eax
    mov dword ebx,[printerStruct]
    mov [ebx+CODEP],dword printerFunc;setting printer func at the struct
    push 1
    push dword STKSIZE
    call malloc
    add esp,8
    ;;;;;;;;
    mov dword [originsStacks], eax
    ;;;;;;;;
    mov dword ebx,[printerStruct]
    add eax,STKSIZE
    mov dword [ebx+SPP],eax ;setting printer stuck at the struct
    push dword [printerStruct]
    call initCo
    add esp,4


    ; ;init target
    push dword 1
    push dword TargetSize
    call malloc
    add esp,8
    mov [targetStruct],eax
    mov dword ebx,[targetStruct]
    mov [ebx+CODEP],dword targetFunc;setting target func at the struct
    push 1
    push dword STKSIZE
    call malloc
    add esp,8
    ;;;;;;;;
    mov dword [originsStacks+4], eax
    ;;;;;;;;
    mov dword ebx,[targetStruct]
    add eax,STKSIZE
    mov dword [ebx+SPP],eax ;setting target stuck at the struct
    call generateRandom ;random for X
    push dword 100
    call scaleRandom ; scale for [0,100] range
    add esp,4
    mov dword ebx,[targetStruct]
    finit
    fld qword [floatNum]
    fstp qword [ebx+Xposition] ;put Y in its position in the struct 
    finit
    call generateRandom ;random for Y
    push dword 100
    call scaleRandom ; scale for [0,100] range
    add esp,4
    mov dword ebx,[targetStruct]
    finit
    fld qword [floatNum]
    fstp qword [ebx+Yposition] ;put Y in its position in the struct 
    finit
    push dword [targetStruct]
    call initCo
    add esp,4

    ;init scheduler
    push  1
    push dword 8
    call malloc
    add esp,8
    mov [schedulerStruct],eax
    mov dword ebx,[schedulerStruct]
    mov [ebx+CODEP],dword schedulerFunc;setting scheduler func at the struct
    push 1
    push STKSIZE
    call malloc
    add esp,8
    ;;;;;;;;
    mov dword [originsStacks+8], eax
    ;;;;;;;;
    mov dword ebx,[schedulerStruct]
    add eax,STKSIZE
    mov dword [ebx+SPP],eax ;setting scheduler stuck at the struct
    push dword [schedulerStruct]
    call initCo
    add esp,4

    ;init drones
    push dword [NumOfDrones]
    push dword DroneSize
    call malloc
    add esp,8
    mov [Drones], dword eax
    mov [currDrone], dword eax
    mov ecx, dword [NumOfDrones]
initDrones:
    mov dword ebx,[currDrone]
    mov [ebx+CODEP],dword droneFunc;setting drone func at the struct
    push ecx
    push 1
    push dword STKSIZE
    call malloc
    add esp,8
    pop ecx

    ;;;;;;;;;;;;;;;;;;;;;;;;
    push ecx
    add ecx, 3
    mov dword [originsStacks + ecx*4], eax
    pop ecx
    ;;;;;;;;;;;;;;;;;;;;;;;;

    add eax,STKSIZE
    mov dword ebx,[currDrone]
    mov dword [ebx+SPP],eax ;setting drone stuck at the struct
    push ecx
    call generateRandom ;random for X
    pop ecx
    push dword 100
    call scaleRandom ; scale for [0,100] range
    add esp,4
    mov dword ebx,[currDrone]
    finit
    fld qword [floatNum]
    fstp qword [ebx+Xposition] ;put X in its position in the struct 
    finit 
    push ecx
    call generateRandom ;random for Y
    pop ecx
    push dword 100
    call scaleRandom ; scale for [0,100] range
    add esp,4
    mov dword ebx,[currDrone]
    finit
    fld qword [floatNum]
    fstp qword [ebx+Yposition] ;put Y in its position in the struct 
    finit
    ;----------------------------------------------------------------
    ;alpha init code here
    finit 
    push ecx
    call generateRandom ;random for alpha
    pop ecx
    push dword 360
    call scaleRandom ; scale for [0,360] range
    add esp,4
    mov dword ebx,[currDrone]
    finit
    fldpi   ; Convert degrees into radians
    fmul qword [floatNum]
    fidiv dword [constPi]
    fstp qword [floatNum]
    finit 
    fld qword [floatNum]
    fstp qword [ebx+alphaPosition] ;put alpha in its position in the struct 
    finit
    ;--------------------------------------------------------------------
    mov esi,[droneIdCounter]
    mov dword [ebx+droneId] , esi
    mov dword [ebx+numOfTargetsDestroyedPos] , 0 
    push dword [currDrone]
    call initCo
    add esp,4
    mov dword ebx,[currDrone]
    dec ecx ; decrease num of drones counter
    add ebx, dword DroneSize
    mov [currDrone] , dword ebx ; mov curr drone to the next drone
    inc dword [droneIdCounter]
    cmp ecx,0
    jnz initDrones
   ; push dword [schedulerStruct]
    ;call startCo
    ;add esp,4


startCo:
    ; push ebp
    ; mov ebp,esp
    pushad
    mov [SPMAIN], esp
    mov ebx, [schedulerStruct]
    jmp do_resume
    ; mov esp,ebp
    ; pop ebp
    ; ret

endCo:
    mov esp, [SPMAIN]
    jmp CleanDrones
    ; jmp cleanTarget
ConendCo:
    mov eax,1
    xor ebx, ebx
    int 0x80


resume:
    pushfd
    pushad
    mov edx,[CURR]
    mov [edx+SPP] , esp
do_resume:
    mov esp,[ebx+SPP]
    mov [CURR], ebx
    popad
    popfd
    ret 




initCo:
    push ebp
    mov ebp,esp
    mov ebx, [ebp+8] ;get the cor struct
    mov eax, [ebx+CODEP] ;get cor func
    mov [SPT], esp ; save esp value
    mov esp, [ebx+SPP] ;set esp to cor stuck
    push eax ;push cor func
    pushfd ;push flags
    pushad ; push registers
    mov [ebx+SPP], esp ; update esp after pushes
    mov esp, [SPT] ;restore ESP value
    mov esp,ebp
    pop ebp
    ret






















;function that put [0,MAX_INT] random number in Rstate
generateRandom:
    push ebp
    mov ebp,esp
    mov esi,16
randomFunc: 
    mov word dx,[Rstate]
    and dx,1
    mov word ax,[Rstate]
    shr ax,2
    and ax,1
    xor dx, ax
    mov word ax,[Rstate]
    shr ax,3
    and ax,1
    xor dx,ax
    mov word ax,[Rstate]
    shr ax,5
    and ax,1
    xor dx,ax
    mov word ax,[Rstate]
    shr ax,1
    shl dx,15
    add ax,dx
    mov word [Rstate],ax
    dec esi
    cmp esi,0
    jnz randomFunc
    mov esp,ebp
    pop ebp
    ret    





;     push ebp
;     mov ebp,esp
;     mov eax,0
; random_word:
;     mov ecx,16
; next_bit:
;     call random_bit
;     loop next_bit,ecx
;     mov esp,ebp
;     pop ebp
;     ret 
; random_bit:;create a random bit
;     push ebp
;     mov ebp,esp
;     mov al,RANDOM_MASK
;     xor al,[Rstate]
;     jpe result_ok
;     stc
; result_ok:
;     rcr word [Rstate],1
;     mov esp,ebp
;     pop ebp
;     ret   
    
scaleRandom:
     push ebp
     mov ebp,esp
     finit
     mov eax,0
     mov ax,  [Rstate]
     mov [Rstate32bit], word ax ;mov the random number to 32bit 
     mov ebx,[ebp+8] ;get range argument
     mov dword [range] , ebx
     fild dword [Rstate32bit] ;load the random number
     fidiv dword  [MAX_INT] ;divide by max_int
     fimul dword [range];mul by range
     fstp qword [floatNum] ;save the number to floatnum
     finit
     mov esp,ebp
     pop ebp
     ret 
     CleanDrones:
        mov ecx, [NumOfDrones]
        add ecx, 3
        mov edx, [originsStacks]
        cleanLoop:
            pushad
            push dword [edx+ecx*4]
            call free
            add esp, 4
            popad
            loop cleanLoop, ecx
        push dword [originsStacks]
        call free
        add esp, 4
         push dword [Drones]
         call free
         add esp, 4
        
cleanTarget:
        mov eax,dword [targetStruct]
        ; mov ebx,[targetStruct+SPP]
        pushad
        push eax
        call free
        add esp,4
        popad
        ; pushad
        ; push ebx
        ; call free
        ; add esp,4
        ; popad

cleanPrinter:
        mov eax,dword [printerStruct]
         mov ebx,[printerStruct+SPP]
        pushad
        push eax
        call free
        add esp,4
        popad
         pushad
         push ebx
         call free
         add esp,4
         popad

cleanScheduler:
        mov eax,dword [schedulerStruct]
         mov ebx,[schedulerStruct+SPP]
        pushad
        push eax
        call free
        add esp,4
        popad
         pushad
         push ebx
         call free
         add esp,4
         popad
        
cleanDroneArray:
 
    jmp ConendCo
    