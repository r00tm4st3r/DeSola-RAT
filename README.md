# DeSola-RAT
> r00tm4st3r | 29/01/2026

```
                                                                                              
                                          ,,                                                  
`7MM"""Yb.             .M"""bgd         `7MM              `7MM"""Mq.        db   MMP""MM""YMM 
  MM    `Yb.          ,MI    "Y           MM                MM   `MM.      ;MM:  P'   MM   `7 
  MM     `Mb  .gP"Ya  `MMb.      ,pW"Wq.  MM   ,6"Yb.       MM   ,M9      ,V^MM.      MM      
  MM      MM ,M'   Yb   `YMMNq. 6W'   `Wb MM  8)   MM       MMmmdM9      ,M  `MM      MM      
  MM     ,MP 8M"""""" .     `MM 8M     M8 MM   ,pm9MM mmmmm MM  YM.      AbmmmqMA     MM      
  MM    ,dP' YM.    , Mb     dM YA.   ,A9 MM  8M   MM       MM   `Mb.   A'     VML    MM      
.JMMmmmdP'    `Mbmmd' P"Ybmmd"   `Ybmd9'.JMML.`Moo9^Yo.   .JMML. .JMM..AMA.   .AMMA..JMML.    
                                                                                              
                                                                                              
```

## Overview

DeSola-RAT is a research project focused on studying the architecture and behavior of **Remote Access Tools (RATs)** and **Command and Control (C2)** systems within a controlled and ethical environment.

We are developing a remote access tool [RAT]. We can use this to command and control [C2] target computers.

The goal is to better understand how remote administration mechanisms operate so defenders and security researchers can improve detection, analysis, and mitigation strategies.

## Purpose

- Analyze RAT and C2 communication models  
- Learn how remote command execution and response handling works at a conceptual level  
- Support malware analysis, reverse engineering, and defensive security research  
- Strengthen blue team and ethical hacking knowledge  

## Components

- Keylogger  
  - Backspace detection  
- screen shots  
- webcam  
- exfiltration  
  - stealing documents  
- remote access  
- credentials  
  - web  
  - computer  
  - applications  
  - wifi  
- advanced reconnaissance  
  - contact information  
- privesc  
- worm
- killswitch
- break pc
- generate in console payloads
- custom payloads

## Roadmap

- initial staging
- redevelop keylogger
- screenshots
- webcam
- obtaining credential
- obfuscation  
  - av, vm detection  
  - disabling firewall, av

## Stages
1. initial payload creates files in start directory
- cmd to run administrative commands
  - set exec bypass
- vbs file to hold `alt` + `y` for UAC bypass
- self delete
2. new malware initializes remote connection
  - any additional tools can be installed remotely
  - keeps a low profile on the payload
3. modularity
  - having a directory to store resources for the RAT

## Extraneous

- bsod [Blue Screen Of Death]  
- web history  
- user activity  

## ⚠️ Legal & Ethical Notice

This project is intended **strictly for educational and research purposes**.  
Use only on systems you own or have **explicit authorization** to test.  
Any unauthorized use is illegal. The authors take no responsibility for misuse.

## Status

Currently under active research and development.
