extern void setCursor();
extern void printChar(char c);
extern void printString(char* s);
extern void inputChar();
extern void getTime();
extern void jump(char c);
extern void clear();
int cursorX, cursorY, dispPos, curModeID;
char ch1, ch2, ch3, ch4, errorCh;
char hour, min, sec;
#define BUFSIZE 100

/*******************************************************************
 *
 * C string functions: strlen(), strcmp(), strcpy()...
 *
 *******************************************************************
 */

int strlen(const char* s) {
    int i = 0;
    while(s[i ++] != 0);
    return i - 1;
}

int strcmp(const char* s1, const char* s2) {
    int flag = 0, len1, len2, i = 0;
    len1 = strlen(s1); len2 = strlen(s2);
    if(len1 != len2) return 1;
    while(i < len1) {
        if(s1[i] != s2[i]) {
            flag = 1;
            break;
        }
        i ++;
    }
    return flag;
}

void strcpy(char* dest, const char* src) {
    int len = strlen(src), i;
    for(i = 0; i < len; i ++) dest[i] = src[i];
    return;
}

int memcmp(const void* p1, const void* p2, const int len) {
    char* s1 = (char*) p1;
    char* s2 = (char*) p2;
    int i, flag = 1;
    for(i = 0; i < len; i ++) {
        if(s1[i] != s2[i]) {
            flag = 0;
            break;
        }
    }
    return flag;
}

void memcpy(void* p1, const void* p2, const int len) {
    char* s1 = (char*) p1;
    char* s2 = (char*) p2;
    int i;
    for(i = 0; i < len; i ++) s1[i] = s2[i];
    return;
}

void memset(void* p1, const char c, const int size) {
    char* s1 = (char*) p1;
    int i;
    for(i = 0; i < size; i ++) s1[i] = c;
}

int isdigit(const char c) {
    return (c >= '0' && c <= '9');
}

int isupper(const char c) {
    if(c >= 'A' && c <= 'Z') return 1;
    else return 0;
}

int islower(const char c) {
    if(c >= 'a' && c <= 'z') return 1;
    else return 0;
}

int isalpha(const char c) {
    if(isupper(c)) return 1;
    else if(islower(c)) return 2;
    else return 0;
}

char toupper(const char c) {
    if(islower(c)) {
        return c - 'a' + 'A';
    }
    else return c;
}

char tolower(const char c) {
    if(isupper(c)) {
        return c - 'A' + 'a';
    }
    else return c;
}

void reverse(char* s) {
    int len = strlen(s), i;
    char tmp;
    for(i = 0; i < len / 2; i ++) {
        tmp = s[i];
        s[i] = s[len - i - 1];
        s[len - i - 1] = tmp;
    }
}

int split(char* dst, const char* src, char delim) {
    int len = strlen(src), i;
    strcpy(dst, src);
    for(i = 0; i < len; i ++) {
        if(dst[i] == delim) {
            dst[i] = 0;
            return i + 1;
        }
    }
    return len;
}

void swap(void* p1, void* p2, int size) {
    char tmp[20];
    memcpy(tmp, p1, size);
    memcpy(p1, p2, size);
    memcpy(p2, tmp, size);
}

/*******************************************************************
 *
 * I/O functions: printInt(), printTime(), getChar(), getString()
 *
 *******************************************************************
 */

void calPos() {
    if(cursorY >= 80) {
        cursorX ++;
        cursorY = 0;
    }
    if(cursorX >= 25) {
        cursorX = 0;
        cursorY = 0;
        clear();
    }
    dispPos = (80 * cursorX + cursorY) * 2;
    setCursor();
}

void printInt(int n) {
    char s[30];
    int i = 0, j;
    if(n == 0) {
        printChar('0');
        return;
    }
    while(n > 0) {
        s[i] = n % 10 + '0';
        n /= 10;
        i ++;
    }
    s[i] = 0;
    reverse(s);
    for(j = 0; j < i; j ++) {
        if(s[j] != '0') break;
    }
    printString(s + j);
}

void printTime() {
    int hourInt, minInt, secInt;
    getTime();
    printString("Current time: ");
    hourInt = (hour >> 4) * 10 + hour % 16;
    if(hourInt == 0) printString("00");
    else if(hourInt < 10) {
        printString("0");
        printInt(hourInt);
    }
    else printInt(hourInt);
    printChar(':');
    minInt = (min >> 4) * 10 + min % 16;
    if(minInt == 0) printString("00");
    else if(minInt < 10) {
        printString("0");
        printInt(minInt);
    }
    else printInt(minInt);
    printChar(':');
    secInt = (sec >> 4) * 10 + sec % 16;
    if(secInt == 0) printString("00");
    else if(secInt < 10) {
        printString("0");
        printInt(secInt);
    }
    else printInt(secInt);
    printString("\n");
}

int getChar() {
    inputChar();
    if(ch1 == '\b') {
        if(curModeID == 3) {
            if(cursorY > 10 && cursorY < 80) {
                cursorY --;
                calPos();
                printChar(' ');
                cursorY --;
                calPos();
            }
        }
        else {
            if(cursorY > 0 && cursorY < 80) {
                cursorY --;
                calPos();
                printChar(' ');
                cursorY --;
                calPos();
            }
        }
        return 0;
    }
    else if(ch1 != '\r') {
        printChar(ch1);
        calPos();
    }
    return 1;
}

int getString(char* buf) {
    int i = 0;
    memset(buf, 0, sizeof(char) * BUFSIZE);
    while(1) {
        if(getChar()) {
            if(ch1 == '\r') {
                break;
            }
            else {
                buf[i ++] = ch1;
            }
        }
        else {
            if(i > 0) {
                i --;
            }
        }
    }
    buf[i] = 0;
    printString("\n");
    return i;
}
