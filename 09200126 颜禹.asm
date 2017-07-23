data segment
i dw 0
res dw 0
ten db 10
disb db 10 dup(?),0dh,0ah,'$'
hh db 0dh,0ah,'$'
stringin db 100,0,100 dup(?),'$'
d0 dw 10 dup(?),'$'	
f0 dw 10 dup(?)
ddp dw 0
ffp dw 0
stringe db 'the number is:',0dh,0ah,'$'
stringy db 'your not',0dh,0ah,'$'
data ends
code segment
assume cs:code,ds:data
dis_hh proc	 near
       lea dx,hh
	   mov ah,09h
	   int 21h
	   ret
dis_hh endp

zhuan proc
 beg:cmp byte ptr[bp],'0'
	  jb ys
	  cmp byte ptr[bp],'9'
	  ja ys	
	  xor ax,ax
   zh:mov dl,byte ptr[bp];转换为数值
	  sub dl,'0'
	  xor dh,dh
	  mul ten   	;ax*10
	  add ax,dx		;累加如ax中
	  inc bp
	  cmp byte ptr[bp],'0'
	  jb ys1
	  cmp byte ptr[bp],'9'
	  ja ys1
	  jmp zh
  ys1:mov word ptr[di],ax
      inc di
	  inc di
   ys:cmp byte ptr[bp],'*'
	  jnz next
	  mov byte ptr[bx],'*'
	  inc bx
	  inc bp
	  jmp beg
 next:cmp byte ptr[bp],'+'
	  jnz next1
	  mov byte ptr[bx],'+'
	  inc bx
	  inc bp
	  jmp beg
next1:cmp byte ptr[bp],'-'
	  jnz next2
	 mov byte ptr[bx],'-'
	  inc bx
	  inc bp
	  jmp beg
next2:cmp byte ptr[bp],'/'
	  jnz next3
	  mov byte ptr[bx],'/'
	  inc bx
	  inc bp
	  jmp beg
next3:cmp byte ptr[bp],'='
      jnz next4
	  mov byte ptr[bx],'='
	  mov stringin+1,0
	  jmp start
next4:lea dx,stringe
      mov ah,09h
	  int 21h
	  call dis_hh
	  mov stringin+1,0
	  ret
zhuan endp

jisuan proc
	l0:mov ax,word ptr[di]
	   mov cl,byte ptr[bx]
	l1:cmp byte ptr[bx],'*'
	   jnz l2
	   inc di
	   inc di
	   mul word ptr[di]
	   inc bx
	   mov cl,byte ptr[bx]
	   jmp l1
	l2:cmp byte ptr[bx],'/'
	   jnz l3
	   inc di
	   inc di
	   xor dx,dx
	   div word ptr[di]
	   inc bx
	   mov cl,byte ptr[bx]
	   jmp l1
	l3:cmp byte ptr[bx],'-'
	   jnz l4
	q1:push di
	   push bx
	   mov di,ddp  ;切换指针
	   mov bx,ffp
	   mov word ptr[di],ax
	   mov byte ptr[bx],cl
	   pop bx	;恢复指针
	   pop di
	   inc ddp
	   inc ddp
	   inc ffp
	   inc di
	   inc di
	   inc bx
	   jmp l0
    l4:cmp byte ptr[bx],'+'
	   jnz l5
	   jmp q1
	l5:cmp byte ptr[bx],'='
	   jnz error
	   push di
	   push bx
	   mov di,ddp
	   mov bx,ffp
	   mov word ptr[di],ax
	   mov byte ptr[bx],cl
	   pop bx
	   pop di
	   lea di,d0;point at data buffer
	   lea bx,f0;point at flag buffer
	   mov ax,word ptr[di]
	   mov cl,byte ptr[bx]
	 m1:cmp byte ptr[bx],'+'
	   jnz m2
	   inc di
	   inc di
	   add ax,word ptr[di]
	   inc bx
	   mov cl,byte ptr[bx]
	   jmp m1
	 m2:cmp byte ptr[bx],'-'
	   jnz m3
	   inc di
	   inc di
	   sub ax,word ptr[di]
	   inc bx
	   mov cl,byte ptr[bx]
	   jmp m1
	m3:cmp byte ptr[bx],'='
	   jnz error 
	   mov res,ax
	   jmp s
 error:lea dx,stringy
       mov ah,09h
	   int 21h
	   lea dx,hh
	   mov ah,09h
	   int 21h
	 s:ret
jisuan endp


start:mov ax,data
      mov ds,ax
	  lea dx,stringin  ;input the strings
	  mov ah,0ah
	  int 21h
	  call dis_hh
	  lea di,d0
	  lea bx,f0
	  lea bp,stringin
	  add bp,2         ;指针指向算式处理的首个单元
	  call zhuan
	  lea di,d0;point at data buffer
	  lea bx,f0;point at flag buffer
	  mov ddp,di;指针备份
	  mov ffp,bx
	  call jisuan	;call jishuan to jisuan
	  lea bp,disb
	  add bp,9
	  mov ax,res
	  div ten
   ag:mov byte ptr[bp],ah
	  add byte ptr[bp],'0'
	  dec bp
	  xor ah,ah
	  div ten
	  cmp ax,0
	  jnz ag
	  inc bp
	  mov dx,bp
	  mov ah,09h
	  int 21h
	  jmp start
code ends
  end start