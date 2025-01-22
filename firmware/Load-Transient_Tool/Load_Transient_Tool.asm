
_main:

;Load_Transient_Tool.c,43 :: 		void main(void)
;Load_Transient_Tool.c,45 :: 		init();
	CALL       _init+0
;Load_Transient_Tool.c,48 :: 		dutyCycle = EEPROM_Read(NVM_ADDRESS);
	MOVLW      2
	MOVWF      FARG_EEPROM_Read_Address+0
	CALL       _EEPROM_Read+0
	MOVF       R0+0, 0
	MOVWF      _dutyCycle+0
	CLRF       _dutyCycle+1
;Load_Transient_Tool.c,50 :: 		PWM1_Init(PWM_FREQ);
	BCF        T2CON+0, 0
	BCF        T2CON+0, 1
	MOVLW      99
	MOVWF      PR2+0
	CALL       _PWM1_Init+0
;Load_Transient_Tool.c,51 :: 		PWM1_set_Duty(dutyCycle); // 0 to 255
	MOVF       _dutyCycle+0, 0
	MOVWF      FARG_PWM1_Set_Duty_new_duty+0
	CALL       _PWM1_Set_Duty+0
;Load_Transient_Tool.c,52 :: 		PWM1_Start();
	CALL       _PWM1_Start+0
;Load_Transient_Tool.c,54 :: 		while (1)
L_main0:
;Load_Transient_Tool.c,56 :: 		if (CALI_PIN == 0) {
	BTFSC      GPIO+0, 3
	GOTO       L_main2
;Load_Transient_Tool.c,57 :: 		Delay_ms(10); // Short debounce delay
	MOVLW      13
	MOVWF      R12+0
	MOVLW      251
	MOVWF      R13+0
L_main3:
	DECFSZ     R13+0, 1
	GOTO       L_main3
	DECFSZ     R12+0, 1
	GOTO       L_main3
	NOP
	NOP
;Load_Transient_Tool.c,58 :: 		if (CALI_PIN == 0) {
	BTFSC      GPIO+0, 3
	GOTO       L_main4
;Load_Transient_Tool.c,59 :: 		calibrate();
	CALL       _calibrate+0
;Load_Transient_Tool.c,60 :: 		}
L_main4:
;Load_Transient_Tool.c,61 :: 		}
L_main2:
;Load_Transient_Tool.c,62 :: 		}
	GOTO       L_main0
;Load_Transient_Tool.c,63 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_init:

;Load_Transient_Tool.c,65 :: 		void init(void)
;Load_Transient_Tool.c,67 :: 		TRISIO = 0b00011001; // GP0 and GP3 as inputs, others as outputs
	MOVLW      25
	MOVWF      TRISIO+0
;Load_Transient_Tool.c,68 :: 		ANSEL  = 0b00010001; // AN0, AN4 (GP0 & GP4) as analog input
	MOVLW      17
	MOVWF      ANSEL+0
;Load_Transient_Tool.c,69 :: 		CMCON0 = 0x07;       // Disable comparators
	MOVLW      7
	MOVWF      CMCON0+0
;Load_Transient_Tool.c,70 :: 		ADC_Init();          // Initialize ADC
	CALL       _ADC_Init+0
;Load_Transient_Tool.c,71 :: 		LED1_PIN = 0;
	BCF        GPIO+0, 1
;Load_Transient_Tool.c,72 :: 		LED2_PIN = 0;
	BCF        GPIO+0, 5
;Load_Transient_Tool.c,73 :: 		}
L_end_init:
	RETURN
; end of _init

_calibrate:

;Load_Transient_Tool.c,82 :: 		void calibrate(void)
;Load_Transient_Tool.c,84 :: 		i = 0;
	CLRF       _i+0
;Load_Transient_Tool.c,85 :: 		LED1_PIN = 0;
	BCF        GPIO+0, 1
;Load_Transient_Tool.c,86 :: 		LED2_PIN = 0;
	BCF        GPIO+0, 5
;Load_Transient_Tool.c,87 :: 		dutyCycle = 0;
	CLRF       _dutyCycle+0
	CLRF       _dutyCycle+1
;Load_Transient_Tool.c,89 :: 		calibrationSuccess  = false;  // Flag for successful calibration
	CLRF       _calibrationSuccess+0
;Load_Transient_Tool.c,90 :: 		closest_voltage = 0;          // Store the closest voltage to the target
	CLRF       _closest_voltage+0
	CLRF       _closest_voltage+1
	CLRF       _closest_voltage+2
	CLRF       _closest_voltage+3
;Load_Transient_Tool.c,91 :: 		closest_dutyCycle = 0;        // Store the duty cycle for the closest voltage
	CLRF       _closest_dutyCycle+0
	CLRF       _closest_dutyCycle+1
;Load_Transient_Tool.c,93 :: 		target_voltage = readVoltage(4);  // Read the target voltage from ADC channel 4
	MOVLW      4
	MOVWF      FARG_readVoltage+0
	CALL       _readVoltage+0
	MOVF       R0+0, 0
	MOVWF      _target_voltage+0
	MOVF       R0+1, 0
	MOVWF      _target_voltage+1
	MOVF       R0+2, 0
	MOVWF      _target_voltage+2
	MOVF       R0+3, 0
	MOVWF      _target_voltage+3
;Load_Transient_Tool.c,97 :: 		while (i < MAX_CAL_ATTEMPTS)
L_calibrate5:
	MOVLW      150
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_calibrate6
;Load_Transient_Tool.c,100 :: 		PWM1_set_Duty(dutyCycle);
	MOVF       _dutyCycle+0, 0
	MOVWF      FARG_PWM1_Set_Duty_new_duty+0
	CALL       _PWM1_Set_Duty+0
;Load_Transient_Tool.c,101 :: 		Delay_ms(30);
	MOVLW      39
	MOVWF      R12+0
	MOVLW      245
	MOVWF      R13+0
L_calibrate7:
	DECFSZ     R13+0, 1
	GOTO       L_calibrate7
	DECFSZ     R12+0, 1
	GOTO       L_calibrate7
;Load_Transient_Tool.c,104 :: 		voltage = readVoltage(0);  // Read the voltage from ADC channel 0
	CLRF       FARG_readVoltage+0
	CALL       _readVoltage+0
	MOVF       R0+0, 0
	MOVWF      _voltage+0
	MOVF       R0+1, 0
	MOVWF      _voltage+1
	MOVF       R0+2, 0
	MOVWF      _voltage+2
	MOVF       R0+3, 0
	MOVWF      _voltage+3
;Load_Transient_Tool.c,107 :: 		if (abs(target_voltage - voltage) < abs(target_voltage - closest_voltage) || i == 0)
	MOVF       R0+0, 0
	MOVWF      R4+0
	MOVF       R0+1, 0
	MOVWF      R4+1
	MOVF       R0+2, 0
	MOVWF      R4+2
	MOVF       R0+3, 0
	MOVWF      R4+3
	MOVF       _target_voltage+0, 0
	MOVWF      R0+0
	MOVF       _target_voltage+1, 0
	MOVWF      R0+1
	MOVF       _target_voltage+2, 0
	MOVWF      R0+2
	MOVF       _target_voltage+3, 0
	MOVWF      R0+3
	CALL       _Sub_32x32_FP+0
	CALL       _double2int+0
	MOVF       R0+0, 0
	MOVWF      FARG_abs_a+0
	MOVF       R0+1, 0
	MOVWF      FARG_abs_a+1
	CALL       _abs+0
	MOVF       R0+0, 0
	MOVWF      FLOC__calibrate+0
	MOVF       R0+1, 0
	MOVWF      FLOC__calibrate+1
	MOVF       _closest_voltage+0, 0
	MOVWF      R4+0
	MOVF       _closest_voltage+1, 0
	MOVWF      R4+1
	MOVF       _closest_voltage+2, 0
	MOVWF      R4+2
	MOVF       _closest_voltage+3, 0
	MOVWF      R4+3
	MOVF       _target_voltage+0, 0
	MOVWF      R0+0
	MOVF       _target_voltage+1, 0
	MOVWF      R0+1
	MOVF       _target_voltage+2, 0
	MOVWF      R0+2
	MOVF       _target_voltage+3, 0
	MOVWF      R0+3
	CALL       _Sub_32x32_FP+0
	CALL       _double2int+0
	MOVF       R0+0, 0
	MOVWF      FARG_abs_a+0
	MOVF       R0+1, 0
	MOVWF      FARG_abs_a+1
	CALL       _abs+0
	MOVLW      128
	XORWF      FLOC__calibrate+1, 0
	MOVWF      R2+0
	MOVLW      128
	XORWF      R0+1, 0
	SUBWF      R2+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__calibrate26
	MOVF       R0+0, 0
	SUBWF      FLOC__calibrate+0, 0
L__calibrate26:
	BTFSS      STATUS+0, 0
	GOTO       L__calibrate22
	MOVF       _i+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L__calibrate22
	GOTO       L_calibrate10
L__calibrate22:
;Load_Transient_Tool.c,109 :: 		closest_voltage = voltage;
	MOVF       _voltage+0, 0
	MOVWF      _closest_voltage+0
	MOVF       _voltage+1, 0
	MOVWF      _closest_voltage+1
	MOVF       _voltage+2, 0
	MOVWF      _closest_voltage+2
	MOVF       _voltage+3, 0
	MOVWF      _closest_voltage+3
;Load_Transient_Tool.c,110 :: 		closest_dutyCycle = dutyCycle;
	MOVF       _dutyCycle+0, 0
	MOVWF      _closest_dutyCycle+0
	MOVF       _dutyCycle+1, 0
	MOVWF      _closest_dutyCycle+1
;Load_Transient_Tool.c,111 :: 		}
L_calibrate10:
;Load_Transient_Tool.c,114 :: 		if (voltage < target_voltage) {
	MOVF       _target_voltage+0, 0
	MOVWF      R4+0
	MOVF       _target_voltage+1, 0
	MOVWF      R4+1
	MOVF       _target_voltage+2, 0
	MOVWF      R4+2
	MOVF       _target_voltage+3, 0
	MOVWF      R4+3
	MOVF       _voltage+0, 0
	MOVWF      R0+0
	MOVF       _voltage+1, 0
	MOVWF      R0+1
	MOVF       _voltage+2, 0
	MOVWF      R0+2
	MOVF       _voltage+3, 0
	MOVWF      R0+3
	CALL       _Compare_Double+0
	MOVLW      1
	BTFSC      STATUS+0, 0
	MOVLW      0
	MOVWF      R0+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_calibrate11
;Load_Transient_Tool.c,115 :: 		dutyCycle++; // Increase duty cycle
	INCF       _dutyCycle+0, 1
	BTFSC      STATUS+0, 2
	INCF       _dutyCycle+1, 1
;Load_Transient_Tool.c,116 :: 		}
	GOTO       L_calibrate12
L_calibrate11:
;Load_Transient_Tool.c,117 :: 		else if (voltage > target_voltage) {
	MOVF       _voltage+0, 0
	MOVWF      R4+0
	MOVF       _voltage+1, 0
	MOVWF      R4+1
	MOVF       _voltage+2, 0
	MOVWF      R4+2
	MOVF       _voltage+3, 0
	MOVWF      R4+3
	MOVF       _target_voltage+0, 0
	MOVWF      R0+0
	MOVF       _target_voltage+1, 0
	MOVWF      R0+1
	MOVF       _target_voltage+2, 0
	MOVWF      R0+2
	MOVF       _target_voltage+3, 0
	MOVWF      R0+3
	CALL       _Compare_Double+0
	MOVLW      1
	BTFSC      STATUS+0, 0
	MOVLW      0
	MOVWF      R0+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_calibrate13
;Load_Transient_Tool.c,119 :: 		if (abs(target_voltage - closest_voltage) < abs(target_voltage - voltage)) {
	MOVF       _closest_voltage+0, 0
	MOVWF      R4+0
	MOVF       _closest_voltage+1, 0
	MOVWF      R4+1
	MOVF       _closest_voltage+2, 0
	MOVWF      R4+2
	MOVF       _closest_voltage+3, 0
	MOVWF      R4+3
	MOVF       _target_voltage+0, 0
	MOVWF      R0+0
	MOVF       _target_voltage+1, 0
	MOVWF      R0+1
	MOVF       _target_voltage+2, 0
	MOVWF      R0+2
	MOVF       _target_voltage+3, 0
	MOVWF      R0+3
	CALL       _Sub_32x32_FP+0
	CALL       _double2int+0
	MOVF       R0+0, 0
	MOVWF      FARG_abs_a+0
	MOVF       R0+1, 0
	MOVWF      FARG_abs_a+1
	CALL       _abs+0
	MOVF       R0+0, 0
	MOVWF      FLOC__calibrate+0
	MOVF       R0+1, 0
	MOVWF      FLOC__calibrate+1
	MOVF       _voltage+0, 0
	MOVWF      R4+0
	MOVF       _voltage+1, 0
	MOVWF      R4+1
	MOVF       _voltage+2, 0
	MOVWF      R4+2
	MOVF       _voltage+3, 0
	MOVWF      R4+3
	MOVF       _target_voltage+0, 0
	MOVWF      R0+0
	MOVF       _target_voltage+1, 0
	MOVWF      R0+1
	MOVF       _target_voltage+2, 0
	MOVWF      R0+2
	MOVF       _target_voltage+3, 0
	MOVWF      R0+3
	CALL       _Sub_32x32_FP+0
	CALL       _double2int+0
	MOVF       R0+0, 0
	MOVWF      FARG_abs_a+0
	MOVF       R0+1, 0
	MOVWF      FARG_abs_a+1
	CALL       _abs+0
	MOVLW      128
	XORWF      FLOC__calibrate+1, 0
	MOVWF      R2+0
	MOVLW      128
	XORWF      R0+1, 0
	SUBWF      R2+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__calibrate27
	MOVF       R0+0, 0
	SUBWF      FLOC__calibrate+0, 0
L__calibrate27:
	BTFSC      STATUS+0, 0
	GOTO       L_calibrate14
;Load_Transient_Tool.c,120 :: 		calibrationSuccess  = true;
	MOVLW      1
	MOVWF      _calibrationSuccess+0
;Load_Transient_Tool.c,121 :: 		break; // Stop further adjustments if closest is found
	GOTO       L_calibrate6
;Load_Transient_Tool.c,122 :: 		}
L_calibrate14:
;Load_Transient_Tool.c,124 :: 		dutyCycle--; // Decrease duty cycle
	MOVLW      1
	SUBWF      _dutyCycle+0, 1
	BTFSS      STATUS+0, 0
	DECF       _dutyCycle+1, 1
;Load_Transient_Tool.c,126 :: 		}
L_calibrate13:
L_calibrate12:
;Load_Transient_Tool.c,128 :: 		i++;
	INCF       _i+0, 1
;Load_Transient_Tool.c,129 :: 		}
	GOTO       L_calibrate5
L_calibrate6:
;Load_Transient_Tool.c,132 :: 		PWM1_set_Duty(closest_dutyCycle);
	MOVF       _closest_dutyCycle+0, 0
	MOVWF      FARG_PWM1_Set_Duty_new_duty+0
	CALL       _PWM1_Set_Duty+0
;Load_Transient_Tool.c,133 :: 		dutyCycle = closest_dutyCycle;
	MOVF       _closest_dutyCycle+0, 0
	MOVWF      _dutyCycle+0
	MOVF       _closest_dutyCycle+1, 0
	MOVWF      _dutyCycle+1
;Load_Transient_Tool.c,135 :: 		if (calibrationSuccess  == true) {
	MOVF       _calibrationSuccess+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_calibrate16
;Load_Transient_Tool.c,137 :: 		for (i = 0; i < 4; i++) {
	CLRF       _i+0
L_calibrate17:
	MOVLW      4
	SUBWF      _i+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_calibrate18
;Load_Transient_Tool.c,138 :: 		LED2_PIN = !LED2_PIN;
	MOVLW      32
	XORWF      GPIO+0, 1
;Load_Transient_Tool.c,139 :: 		Delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_calibrate20:
	DECFSZ     R13+0, 1
	GOTO       L_calibrate20
	DECFSZ     R12+0, 1
	GOTO       L_calibrate20
	DECFSZ     R11+0, 1
	GOTO       L_calibrate20
	NOP
	NOP
;Load_Transient_Tool.c,137 :: 		for (i = 0; i < 4; i++) {
	INCF       _i+0, 1
;Load_Transient_Tool.c,140 :: 		}
	GOTO       L_calibrate17
L_calibrate18:
;Load_Transient_Tool.c,141 :: 		EEPROM_Write(NVM_ADDRESS, dutyCycle);
	MOVLW      2
	MOVWF      FARG_EEPROM_Write_Address+0
	MOVF       _dutyCycle+0, 0
	MOVWF      FARG_EEPROM_Write_data_+0
	CALL       _EEPROM_Write+0
;Load_Transient_Tool.c,142 :: 		} else {
	GOTO       L_calibrate21
L_calibrate16:
;Load_Transient_Tool.c,143 :: 		LED1_PIN = 1;  // Turn on LED1 to indicate failure
	BSF        GPIO+0, 1
;Load_Transient_Tool.c,144 :: 		}
L_calibrate21:
;Load_Transient_Tool.c,145 :: 		}
L_end_calibrate:
	RETURN
; end of _calibrate

_readVoltage:

;Load_Transient_Tool.c,147 :: 		float readVoltage(uint8_t adcChannel)
;Load_Transient_Tool.c,149 :: 		return ADC_Read(adcChannel) * (5.0 / 1023.0);
	MOVF       FARG_readVoltage_adcChannel+0, 0
	MOVWF      FARG_ADC_Read_channel+0
	CALL       _ADC_Read+0
	CALL       _word2double+0
	MOVLW      10
	MOVWF      R4+0
	MOVLW      40
	MOVWF      R4+1
	MOVLW      32
	MOVWF      R4+2
	MOVLW      119
	MOVWF      R4+3
	CALL       _Mul_32x32_FP+0
;Load_Transient_Tool.c,150 :: 		}
L_end_readVoltage:
	RETURN
; end of _readVoltage
