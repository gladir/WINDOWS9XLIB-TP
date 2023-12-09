{ @author: Sylvain Maltais (support@gladir.com)
  @created: 1993
  @website(https://www.gladir.com/CODER/WINDOWS9XLIB-TP)
  @abstract(Target: Turbo Pascal 7)
}

Unit W9XAPI;

INTERFACE

Const
  {Format du Presse-Papier Windows 9X}
 cfText=1;           { Texte }
 cfBitmap=2;         { Bitmap OEM }
 cfOemText=7;        { Texte OEM }
 cfDspText=$81;      { Format texte }
 cfDspBitmap=$82;    { Format dessin }

Function Win9XClipboardCompact(lDesired:LongInt):LongInt;
Function Win9XClipboardFunctionsAvailable:Boolean;
Function Win9XCloseClipboard:Boolean;
Function Win9XEmptyClipboard:Boolean;
Function Win9XGetClipboardData(wFormat:Word;DataPtr:Pointer):Boolean;
Function Win9XGetClipboardDataSize(wFormat:Word):LongInt;
Function Win9XOpenClipboard:Boolean;
Function Win9XSetClipboardData(wFormat:Word;DataPtr:Pointer;lSize:LongInt):Boolean;
Function Win9XSetTitle(Name:PChar):Boolean;

IMPLEMENTATION

{@description: Cette fonction permet de sp‚cifier le nouveau
               nom que doit avoir l'application actuel sous
               une session DOS de Windows 95 ou 98.
}

Function Win9XSetTitle(Name:PChar):Boolean;Assembler;ASM
 MOV AX,168Eh
 XOR DX,DX
 LES DI,Name
 INT 2Fh
END;

{@description: Cette fonction indique si les outils du
               presse-papier sont disponibles pour une
               application DOS.
}

Function Win9XClipboardFunctionsAvailable:Boolean;Assembler;ASM
 MOV AX,1700h
 INT 2Fh
 XOR BL,BL
 CMP AX,1700h
 JE  @1
 MOV BL,1
@1:
 XCHG AX,BX
END;

Function Win9XClipboardCompact(lDesired:LongInt):LongInt;Assembler;ASM
 MOV AX,1709h
 LES CX,lDesired
 MOV SI,ES
 INT 2Fh
END;

{@description: Cette fonction permet d'effectuer la fermeture
               (terminaison du processus de lecture) du
               presse-papier pr‚c‚dement pr‚parer par
               ®Win9XOpenClipboard¯.
}

Function Win9XCloseClipboard:Boolean;Assembler;ASM
 MOV AX,1708h
 INT 2Fh
 OR  AX,AX
 JE  @End
 MOV AL,1
@End:
END;

{@description: Cette fonction permet de savoir si le
               presse-papier est actuellement vide et sans
               aucun contenu.
}

Function Win9XEmptyClipboard:Boolean;Assembler;ASM
 MOV AX,1702h
 INT 2Fh
 OR  AX,AX
 JE  @End
 MOV AL,1
@End:
END;

Function Win9XGetClipboardDataSize(wFormat:Word):LongInt;Assembler;ASM
 MOV AX,1704h
 MOV DX,wFormat
 INT 2Fh
END;

Function Win9XGetClipboardData(wFormat:Word;DataPtr:Pointer):Boolean;Assembler;ASM
 MOV AX,1705h
 MOV DX,wFormat
 LES BX,DataPtr
 INT 2Fh
 OR  AX,AX
 JE  @End
 MOV AL,1
@End:
END;

{@description: Cette fonction permet d'effectuer l'ouverture
               du presse-papier afin d'‚ventuellement lire le
               contenu de celui-ci.
}

Function Win9XOpenClipboard:Boolean;Assembler;ASM
 MOV AX,1701h
 INT 2Fh
 OR  AX,AX
 JE  @End
 MOV AL,1
@End:
END;

Function Win9XSetClipboardData(wFormat:Word;DataPtr:Pointer;lSize:LongInt):Boolean;Begin
 Win9XSetClipboardData:=False;
 If(DataPtr<>Nil)and(lSize<>0)and(Win9XClipboardCompact(lSize)>=lSize)Then Begin
  ASM
   MOV AX,1703h
   MOV DX,wFormat
   LES CX,lSize
   MOV SI,ES
   LES BX,DataPtr
   INT 2Fh
   OR  AX,AX
   JE  @End
   MOV AL,1
@End:
   MOV @Result,AL
  END;
 End;
End;


END.