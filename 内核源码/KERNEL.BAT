tcc -mt -c -oos.obj os.c
del kernel.obj
tasm kernel.asm kernel.obj
tlink /3 /t kernel.obj os.obj, kernel.com
