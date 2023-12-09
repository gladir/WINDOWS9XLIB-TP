{ @author: Sylvain Maltais (support@gladir.com)
  @created: 1993
  @website(https://www.gladir.com/CODER/WINDOWS9XLIB-TP)
  @abstract(Target: Turbo Pascal 7)
}

Unit W9XFILE;

INTERFACE

Uses DOS;

Type
 Win9XSearchRec=Record
  Attr:LongInt;                  { Attribut }
  CreationTime,                  { Date de cr‚ation }
  LastAccessTime,                { Dernier temps d'accŠs }
  LastModTime:Comp;              { Dernier modification }
  HiSize,LoSize:LongInt;         { Taille du fichier }
  Reserved:Comp;                 { R‚serv‚ }
  Name:Array[0..259]of Char;     { Nom long }
  ShortName:Array[0..13]of Char; { Seulement si le nom existe }
  Handle:Word;                   { Handle correspondant }
 End;

Function  Win9XFileSystemInfo(RootName:PChar;FSName:PChar;
                              FSNameBufSize:Word;Var Flags,
                              MaxFileNameLen,MaxPathLen:Word):Word;
Function  Win9XFindFirst(FileSpec:PChar;Attr:Word;Var SRec:Win9XSearchRec):Word;
Function  Win9XFindNext(Var SRec:Win9XSearchRec):Word;
Function  Win9XFindClose(Var SRec:Win9XSearchRec):Word;
Function  Win9XGetLastErrCode:Word;
Function  Win9XGetLongName(FileName:PChar;_Result:PChar):Word;
Function  Win9XGetShortName(FileName:PChar;_Result:PChar):Word;
Function  Win9XTime2Dos(Var LTime:Comp):LongInt;
Function  Win9XTrueName(FileName:PChar;Result:PChar):Word;
Procedure Win9XUnpackTime(Var LTime:Comp;Var DT:DateTime);

IMPLEMENTATION

Var
 SysErr:Word;


{@description: Cette fonction permet de trouver le premier
               ‚l‚ment d'une liste de fichiers de format nom
               long du systŠme d'exploitation 95 et 98.
}

Function Win9XFindFirst(FileSpec:PChar;Attr:Word;Var SRec:Win9XSearchRec):Word;Assembler;ASM
 PUSH DS
  LDS DX,FileSpec
  LES DI,SRec
  MOV CX,Attr
  XOR SI,SI
  MOV AX,714Eh
 INT 21h
 POP DS
 SBB BX,BX
 MOV ES:[DI].Win9XSearchRec.Handle,AX
 AND AX,BX
 MOV SysErr,AX
END;

{@description: Cette fonction permet de trouver l'‚l‚ment
               suivant d'une liste de fichiers de format nom
               long du systŠme d'exploitation 95 et 98.
}

Function Win9XFindNext(Var SRec:Win9XSearchRec):Word;Assembler;ASM
 MOV AX,714Fh
 XOR SI,SI
 LES DI,SRec
 MOV BX,ES:[DI].Win9XSearchRec.Handle
 INT 21h
 SBB BX,BX
 AND AX,BX
 MOV SysErr,AX
END;

{@description: Cette fonction doit toujours ˆtre appel‚e aprŠs
               que la terminaison de la lecture effectu‚e par
               les deux routines ®Win9XFindFirst¯ et
               ®Win95FindNext¯ est termin‚e  afin que le systŠme
               d'exploitation puisse restituer les ressources
               allou‚.
}

Function Win9XFindClose(Var SRec:Win9XSearchRec):Word;Assembler;ASM
 MOV AX,71A1h
 MOV BX,ES:[DI].Win9XSearchRec.Handle
 INT 21h
 SBB BX,BX
 AND AX,BX
 MOV SysErr,AX
END;

{@description: Cette fonction permet de retourner le v‚ritable
               nom d'un nom de fichier du systŠme d'exploitation
               95, 98 et NT.
}

Function Win9XTrueName(FileName:PChar;Result:PChar):Word;Assembler;ASM
 PUSH DS
  MOV AX,7160h
  XOR CX,CX
  LDS SI,FileName
  LES DI,Result
  INT 21h
 POP DS
 SBB BX,BX
 AND AX,BX
 MOV SysErr,AX
END;

{@description: Cette fonction permet de retourner le nom court
               en format DOS d'un nom long de fichier de format
               Windows 95/98 et NT.
}

Function Win9XGetShortName(FileName:PChar;_Result:PChar):Word;Assembler;ASM
 PUSH DS
  LDS SI,FileName
  LES DI,_Result
  MOV AX,7160h
  MOV CX,1
  INT 21h
 POP DS
 SBB BX,BX
 AND AX,BX
 MOV SysErr,AX
END;

{@Description Cette fonction permet de retourner le nom long
              en format Windows 95/98 et NT en format DOS court
              (8 de noms, 3 d'extension).
}

Function Win9XGetLongName(FileName:PChar;_Result:PChar):Word;Assembler;ASM
 PUSH DS
  LDS SI,FileName
  LES DI,_Result
  MOV AX,7160h
  MOV CX,2
  INT 21h
 POP DS
 SBB BX,BX
 AND AX,BX
 MOV SysErr,AX
END;

Function Win9XFileSystemInfo(RootName:PChar;FSName:PChar;
                             FSNameBufSize:Word;Var Flags,
                             MaxFileNameLen,MaxPathLen:Word):Word;
Assembler;ASM
 PUSH DS
  LDS DX,RootName
  LES DI,FSName
  MOV CX,FSNameBufSize
  MOV AX,71A0h
  INT 21h
 POP DS
 LES DI,Flags
 MOV ES:[DI],BX
 LES DI,MaxFileNameLen
 MOV ES:[DI],CX
 LES DI,MaxPathLen
 MOV ES:[DI],DX
 SBB BX,BX
 AND AX,BX
 MOV SysErr,AX
END;

{@description: Cette fonction permet de convertir les dates
               des noms long … l'ancien format DOS.
}

Function Win9XTime2Dos(Var LTime:Comp):LongInt;Assembler;ASM
 PUSH DS
  LDS SI,LTime
  XOR BL,BL
  MOV AX,71A7h
  INT 21h
  POP DS
 MOV AX,CX
 CMC
 SBB CX,CX
 AND AX,CX
 AND DX,CX
END;

Procedure Win9XUnpackTime(Var LTime:Comp;Var DT:DateTime);Begin
 UnpackTime(Win9XTime2Dos(LTime),DT);
End;

Function Win9XGetLastErrCode:Word;Begin
 Win9XGetLastErrCode:=SysErr;
 SysErr:=0;
End;

BEGIN
 SysErr:=0;
END.