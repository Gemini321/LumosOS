nasm -f bin cover.asm -o cover.com
nasm -f bin stoneNM.asm -o stoneNM.com
nasm -f bin square.asm -o square.com
nasm -f bin ld.asm -o ld.com
nasm -f bin lu.asm -o lu.com
nasm -f bin rd.asm -o rd.com
nasm -f bin ru.asm -o ru.com

nasm -f bin boot.asm -o boot.bin
tcc -mt -c -oos.obj os.c
del kernel.obj
tasm kernel.asm kernel.obj
tlink /3 /t kernel.obj os.obj, kernel.com
