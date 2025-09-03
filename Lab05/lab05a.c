#define STDOUT_FD 1

char buffer_dec[20];
char buffer_bin[34];
char buffer_hex[20];

int main();

int read(int __fd, const void *__buf, int __n){
   int ret_val;
 __asm__ __volatile__(
   "mv a0, %1           # file descriptor\n"
   "mv a1, %2           # buffer \n"
   "mv a2, %3           # size \n"
   "li a7, 63           # syscall read code (63) \n"
   "ecall               # invoke syscall \n"
   "mv %0, a0           # move return value to ret_val\n"
   : "=r"(ret_val)  // Output list
   : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
   : "a0", "a1", "a2", "a7"
 );
 return ret_val;
}

void write(int __fd, const void *__buf, int __n)
{
 __asm__ __volatile__(
   "mv a0, %0           # file descriptor\n"
   "mv a1, %1           # buffer \n"
   "mv a2, %2           # size \n"
   "li a7, 64           # syscall write (64) \n"
   "ecall"
   :   // Output list
   :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
   : "a0", "a1", "a2", "a7"
 );
}

void exit(int code)
{
 __asm__ __volatile__(
   "mv a0, %0           # return code\n"
   "li a7, 93           # syscall exit (93) \n"
   "ecall"
   :   // Output list
   :"r"(code)    // Input list
   : "a0", "a7"
 );
}

void _start()
{
 int ret_code = main();
 exit(ret_code);
}

void zerarBufferBin(){
    for (int i = 0; i != '\0'; i++){
        buffer_bin[i] = '0';
    }
}

void decimalParaBin(int num, int inicio, int fim, char* buffer_bin) {
    unsigned int n = (unsigned int) num;  // Trata como complemento de dois
    int pos = fim;

    for (int i = 0; i <= fim - inicio; i++) {
        buffer_bin[pos--] = (n & 1) ? '1' : '0';
        n >>= 1;
    }
}

void hex_code(int val){
    char hex[11];
    unsigned int uval = (unsigned int) val, aux;

    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--){
        aux = uval % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        uval = uval / 16;
    }
    write(1, hex, 11);
}

int StrDecimalPraInt(char num[], int inicio, int fim){
    int resultado = 0;
    short negativo = 0;

    // Verifica se o número é negativo
    if (num[inicio] == '-'){
        negativo = 1;
    }
    inicio++;


    for (int i = inicio; i < fim; i++){
        resultado = resultado * 10 + (num[i] - '0');
    }

    if (negativo == 1){
        resultado = -resultado;
    }
 
    return resultado;
}

int binParaDecimal(char* bin){
    int num = 0;

    for (int i = 0; bin[i] != '\n'; i++){
        num *= 2;
        if (bin[i] == '1'){
            num++;
        }
    }

    return num;
}

int main(){
    int num;
    char entrada[30];
    char* respBinConc;

    read(STDIN_FD, entrada, 30);

    num = StrDecimalPraInt(entrada, 0, 5);
    decimalParaBin(num, 29, 31, respBinConc);
    num = StrDecimalPraInt(entrada, 6, 11);
    decimalParaBin(num, 21, 28, respBinConc);
    num = StrDecimalPraInt(entrada, 12, 17);
    decimalParaBin(num, 16, 20, respBinConc);
    num = StrDecimalPraInt(entrada, 18, 23);
    decimalParaBin(num, 11, 15, respBinConc);
    num = StrDecimalPraInt(entrada, 24, 29);
    decimalParaBin(num, 0, 10, respBinConc);

    respBinConc[32] = '\n';   

    num = binParaDecimal(respBinConc);

    hex_code(num);

    return 0;
}