section .data 
extern temp1
extern Rstate
extern MAX_INT
extern Rstate32bit
extern floatNum
extern range
extern rangeFloat
extern numco
extern constRange
extern constRangeFloat
extern maxAlpha
extern constPi
extern temp1
extern temp2
extern currentDroneToRun
extern numStepsToPrint
extern currentStepNum
extern numDestroyToWin
extern betaTemp
extern beta
extern gamma
extern maxDistance
extern NumOfDrones
extern droneIdCounter

section .bss
extern Drones
extern currDrone
extern RestCors
extern CURR
extern SPT
extern SPMAIN
extern schedulerStruct
extern printerStruct
extern targetStruct

section	.rodata	
    extern formatTarget
    extern formatDrone
    extern formatCheckArgs
    extern formatCheckRandom
    extern winner_format
    extern formatMyId
    extern argBuffer
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
global printerFunc
extern generateRandom
extern scaleRandom
extern endCo
extern resume
extern printf




printerFunc:
    push printerFunc ; push for next time
    mov eax,[targetStruct]
    push dword [eax+Yposition+4]
    push dword [eax+Yposition]
    push dword [eax+Xposition+4]
    push dword [eax+Xposition]
    push formatTarget
    call printf
    add esp,20
    mov esi,[NumOfDrones]
    mov eax,[Drones]
printDrones:
    push eax
    finit
    finit
    fild dword [constPi]   ; Convert radians into degrees
    fmul qword [eax+alphaPosition] ;180*angle(rad)
    fstp qword [temp1] ; ;180*angle(rad)
    finit
    fldpi
    fld qword [temp1]
    fdiv st0,st1
    fstp qword [eax+alphaPosition]
    push dword [eax+numOfTargetsDestroyedPos]
    push dword [eax+alphaPosition+4]
    push dword [eax+alphaPosition]
    push dword [eax+Yposition+4]
    push dword [eax+Yposition]
    push dword [eax+Xposition+4]
    push dword [eax+Xposition]
    push dword [eax+droneId]
    push formatDrone
    call printf
    add esp,36
    pop eax
    finit
    fldpi  ; Convert degrees into redians
    fmul qword [eax+alphaPosition] 
    fidiv dword [constPi]
    fstp qword [eax+alphaPosition] 
    dec esi
    cmp esi,0
    jz finishPrint
    add eax,DroneSize
    jmp printDrones
finishPrint:
    mov ebx,[schedulerStruct]
    jmp resume
    
