#include "clibrary.h"
extern void setTime();
extern void reTime();
extern void setKeyboard();
extern void reKeyboard();
extern void extraInt();
extern void cprintf();
extern void setCursor();
extern void printChar(char c);
extern void printString(char* s);
extern void inputChar();
extern void getTime();
extern void jump(char c);
extern void clear();
char readBuffer[BUFSIZE], writeBuffer[BUFSIZE];
char* coverLines[]   = {"Welcome to LumosOS!",
                       "Press a letter to enter a specific mode:",
                       "[c]: Enter command mode       [h]: Display help information",
                       "[1]~[7]: Execute a program and press any key to return after executing",
                       "[Esc]: Exit LumosOS"};
char* commandLines[] = {"LumosOS >> ",
                        "Error! Please enter the right instruction: ls, clear, exit or run a/b/c!\n"};
char* fileLines[]    = {"     File      Size                        Usage          \n",
                        "      a        1 KB        Displaying the interface of LumosOS\n",
                        "      b        1 KB               Emulating bouncing ball\n",
                        "      c        1 KB                 Printing a square\n"};
char* helpLines[]    = {"Commond mode is not available currently."};
char* errorLines[]   = {"File not found!\n"};
char* exitLines[]    = {"Successfully exited LumosOS",
                       "Goodbye and have a good day!"};
char ouch[] = "Ouch!";
char name[] = "Wenxuan Pan";
char id[] = "19335163";
int center_x = 24, center_y = 79, int8h_ip, int8h_cs, wheel_cnt = 0;
int ouch_cnt = 1, ouch_init = 1;
int int9h_ip, int9h_cs, ouch_x = 1, ouch_y = 0;

void helpMode() {
    clear();
    curModeID = 2;
    cursorX = 12; cursorY = 22;
    calPos();
    printString("Help page is not available currently.");
    cursorX = 13, cursorY = 30;
    calPos();
    printString("To be continued...");
    calPos();
    inputChar();
}

void printCommandHelp() {
    printString(commandLines[1]);
}

void listFiles() {
    int i;
    printString(fileLines[0]);
    printString(fileLines[1]);
    printString(fileLines[2]);
    printString(fileLines[3]);
}

void printOuch() {
    if(ouch_init == 1) {
        cursorY = 0;
        cursorX = 2;
        ouch_init = 0;
        ouch_cnt = 1;
        calPos();
    }
    cprintf(ouch, ouch_cnt);
    ouch_cnt ++;
    if(ouch_cnt == 255) ouch_cnt = 1;
}

void showpro33h() {
    cursorX = 4; cursorY = 8;
    calPos();
    cprintf(name, 2);
    cursorX = 5; cursorY = 8;
    calPos();
    cprintf(id, 2);
    cursorX = 6; cursorY = 8;
    calPos();
    cprintf("I'm int 33h.", 2);
}

void showpro34h() {
    cursorX = 4; cursorY = 58;
    calPos();
    cprintf(name, 3);
    cursorX = 5; cursorY = 58;
    calPos();
    cprintf(id, 3);
    cursorX = 6; cursorY = 58;
    calPos();
    cprintf("I'm int 34h.", 3);
}

void showpro35h() {
    cursorX = 14; cursorY = 8;
    calPos();
    cprintf(name, 4);
    cursorX = 15; cursorY = 8;
    calPos();
    cprintf(id, 4);
    cursorX = 16; cursorY = 8;
    calPos();
    cprintf("I'm int 35h.", 4);
}

void showpro36h() {
    cursorX = 14; cursorY = 58;
    calPos();
    cprintf(name, 5);
    cursorX = 15; cursorY = 58;
    calPos();
    cprintf(id, 5);
    cursorX = 16; cursorY = 58;
    calPos();
    cprintf("I'm int 36h.", 5);
}

void commandMode() {
    int nextBegin;
    char instr[20];
    clear();
    curModeID = 3;
    cursorX = 0; cursorY = 0;
    calPos();
    while(1) {
        memset(instr, 0, sizeof(char) * 20);
        printString(commandLines[0]);
        getString(readBuffer);
        if(!strcmp(readBuffer, "exit")) {
            break;
        }
        nextBegin = split(instr, readBuffer, ' ');
        if(!strcmp(instr, "clear")) {
            clear();
            cursorX = cursorY = 0;
            calPos();
        }
        else if(!strcmp(instr, "ls")) {
            listFiles();
        }
        else if(!strcmp(instr, "time")) {
            printTime();
        }
        else if(!strcmp(instr, "settime")) {
            setTime();
        }
        else if(!strcmp(instr, "retime")) {
            reTime();
        }
        else if(!strcmp(instr, "interrupt")) {
            extraInt();
            cursorX = 18; cursorY = 0;
            calPos();
        }
        else if(nextBegin == strlen(readBuffer)) {
            printCommandHelp();
        }
        else if(!strcmp(instr, "run")) {
            switch(readBuffer[nextBegin]) {
                case 'a': jump('a'); clear(); cursorX = cursorY = 0; break;
                case 'b': jump('b'); clear(); cursorX = cursorY = 0; break;
                case 'c': jump('c'); clear(); cursorX = cursorY = 0; break;
                case 'd': jump('d'); clear(); cursorX = cursorY = 0; break;
                case 'e': jump('e'); clear(); cursorX = cursorY = 0; break;
                case 'f': jump('f'); clear(); cursorX = cursorY = 0; break;
                case 'g': jump('g'); clear(); cursorX = cursorY = 0; break;
                default: printCommandHelp();
            }
            calPos();
        }
        else {
            printCommandHelp();
        }
    }
}

void exitMode() {
    clear();
    curModeID = 4;
    cursorX = 12; cursorY = 27;
    calPos();
    printString(exitLines[0]);
    cursorX = 13; cursorY = 27;
    calPos();
    printString(exitLines[1]);
    setCursor();
    inputChar();
}

int coverMode() {
    int i;
    curModeID = 1;
    cursorX = 10; cursorY = 29;
    calPos();
    printString(coverLines[0]);
    cursorX = 11; cursorY = 20;
    calPos();
    printString(coverLines[1]);
    cursorX = 12; cursorY = 8;
    calPos();
    printString(coverLines[2]);
    cursorX = 13; cursorY = 8;
    calPos();
    printString(coverLines[3]);
    cursorX = 14; cursorY = 8;
    calPos();
    printString(coverLines[4]);
    inputChar();
    switch(ch1) {
        case 'c': commandMode(); break;
        case 'h': helpMode(); break;
        case '1': jump('a'); break;
        case '2': jump('b'); break;
        case '3': jump('c'); break;
        case '4': jump('d'); break;
        case '5': jump('e'); break;
        case '6': jump('f'); break;
        case '7': jump('g'); break;
        case  27: exitMode(); return 1;
    }
    return 0;
}

void errorPrint() {
    switch(errorCh) {
        case 'a':
            printString(errorLines[0]);
            break;
        default:
            printString("Unknown error appears.\n");
    }
}

int main() {
    int exitFlag = 0;
    while(1) {
        clear();
        exitFlag = coverMode();
        if(exitFlag) break;
    }
    return 0;
}