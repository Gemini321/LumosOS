#include <stdio.h>
#include <string.h>
#include <math.h>

#define MAX 2000

int main() {
    char buffer[MAX];
    FILE* fin = fopen("BOOT.BIN", "rb");
    FILE* fout = fopen("boot.img", "wb+");
    int n, sum = 0;
    while((n = fread(buffer, 1, MAX, fin)) != 0) { // 写入主引导扇区（1号扇区）
        fwrite(buffer, n, 1, fout);
        sum += n;
    }
    fin = fopen("KERNEL.COM", "rb");
    while((n = fread(buffer, 1, MAX, fin)) != 0) {
        fwrite(buffer, n, 1, fout);
        sum += n;
    }
    memset(buffer, 0, sizeof(char) * MAX);
    while(512 * 10 - sum > MAX) {
        fwrite(buffer, MAX, 1, fout);
        sum += MAX;
    }
    fwrite(buffer, 1, 512 * 10 - sum, fout);
    sum = 512 * 10;

    fin = fopen("COVER.COM", "rb");
    while((n = fread(buffer, 1, MAX, fin)) != 0) { // 写入11号扇区
        fwrite(buffer, n, 1, fout);
        sum += n;
    }

    fin = fopen("STONENM.COM", "rb");
    while((n = fread(buffer, 1, MAX, fin)) != 0) { // 写入12号扇区
        fwrite(buffer, n, 1, fout);
        sum += n;
    }

    fin = fopen("SQUARE.COM", "rb");
    while((n = fread(buffer, 1, MAX, fin)) != 0) { // 写入13号扇区
        fwrite(buffer, n, 1, fout);
        sum += n;
    }

    fin = fopen("LD.COM", "rb");
    while((n = fread(buffer, 1, MAX, fin)) != 0) { // 写入14号扇区
        fwrite(buffer, n, 1, fout);
        sum += n;
    }

    fin = fopen("LU.COM", "rb");
    while((n = fread(buffer, 1, MAX, fin)) != 0) { // 写入15号扇区
        fwrite(buffer, n, 1, fout);
        sum += n;
    }

    fin = fopen("RD.COM", "rb");
    while((n = fread(buffer, 1, MAX, fin)) != 0) { // 写入16号扇区
        fwrite(buffer, n, 1, fout);
        sum += n;
    }

    fin = fopen("RU.COM", "rb");
    while((n = fread(buffer, 1, MAX, fin)) != 0) { // 写入17号扇区
        fwrite(buffer, n, 1, fout);
        sum += n;
    }

    int total = 1474560 - sum;                     // 写入剩下空间
    memset(buffer, 0, sizeof(char) * MAX);
    while(total > MAX) {
        fwrite(buffer, 1, MAX, fout);
        total -= MAX;
    }
    fwrite(buffer, 1, total, fout);
}