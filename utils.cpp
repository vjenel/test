// This perpare the files consisting of 
// N = an integer and 
// sequence of x[i] y[i] = with i 1..N
// copy the file data.data as text.txt as needed by other dot_product codes;
#include <stdio.h>
#include <stdlib.h>

long ISEED = -8373;
double ran2(long*);

using namespace std;

void write_in_file_random_seq(char* ,int); // write a random sequance of 2 arrays x,y and print out their dot product after writing it
void write_in_file_uniform_seq(char* ,int);
void read_from_file_and_get_dot_product(char*, double &); //return the value in tedouble

int main(){
char* nf = (char*) "data.data" ;
int N = 100;
double s=-999.0;

 write_in_file_uniform_seq( nf, N);
// write_in_file_random_seq( nf, N);
 read_from_file_and_get_dot_product(nf,  s);
 printf(" recomputed dot = %lf \n",s);  
}

void write_in_file_uniform_seq(char* nf, int N){
  FILE * f = fopen(nf, "w");
  double s=0.0,x1,x2;
  fprintf(f,"%d\n",N);
  for (int i=0;i<N;++i){
    x1 = (double)i;
    x2 = x1*x1/(10.0+x1);
    fprintf(f,"%lf %lf \n",x1,x2);
    s += x1*x2;
  }
  fclose(f);
  printf("---  write sequence with write_in_file_uniform_seq() in file %s \n",nf);
  printf("---  The dot product was %lf\n",s);
}

void write_in_file_random_seq(char* nf, int N){
  FILE * f = fopen(nf, "w");
  double s=0.0,x1,x2;
  fprintf(f,"%d\n",N);
  for (int i=0;i<N;++i){
    x1 = ran2(&ISEED) ; x2=ran2(&ISEED);
    fprintf(f,"%lf %lf \n",x1,x2);
    s += x1*x2;
  }
  fclose(f);
  printf("---  write sequence with write_in_file_random_seq() in file %s \n",nf);
  printf("---  The dot product was %lf\n",s);
}

void read_from_file_and_get_dot_product( char* nf, double & dot ){
 int N,i0=0,NNN=2048;
 double x1,x2,s=0.0;
 char buffer[NNN];
 FILE * f = fopen(nf,"r");
 if (f==NULL) {printf(" ERROR in read_from_file_and_get_dot_product(); file %s do not exists", nf);exit(0);}
 if (fgets(buffer, NNN, f)==NULL){ printf(" ERROR in read_from_file_and_get_dot_product(); insufficient records in file\n"); exit(0); };
 sscanf(buffer,"%d",&N);
 do {
    i0 += 1;
    if (fgets(buffer, NNN, f)==NULL){ printf(" ERROR in read_from_file_and_get_dot_product(); insufficient records in file\n"); exit(0); };
    sscanf(buffer,"%lf %lf",&x1,&x2);
    s += x1*x2;
 } while (i0<N);
 dot = s;
 fclose(f);
}

double ran2(long *idum){
// a basic random generator based on the method given in the function ran2 of www.nr.com
const long IM1=2147483563,IM2=2147483399,IA1=40014,IA2=40692,IQ1=53668,IQ2=52774,IR1=12211,IR2=3791,NTAB=32,IMM1=(IM1-1), NDIV=(1+IMM1/NTAB);
const double AM=(1.0/((double)(IM1))) , EPS=1.2e-7, RNMX=(1.0-EPS);

  int j;
  long k;
  static long idum2 = 123456789,iy = 0,iv[NTAB];  // save idum2 iy iv internally here
  double temp;

  if (*idum <= 0) {
    if (-(*idum) < 1) *idum = 1;
    else *idum = -(*idum);
    idum2 = (*idum);
    for (j = NTAB+7; j >= 0; j--) {
      k = (*idum) / IQ1;
      *idum = IA1 * (*idum - k*IQ1) - k*IR1;
      if (*idum < 0) *idum += IM1;
      if (j < NTAB) iv[j] = *idum;
    }
    iy = iv[0];
  }

  k = (*idum) / IQ1;
  *idum = IA1 * (*idum - k*IQ1) - k*IR1;
  if (*idum < 0) *idum += IM1;
  k = idum2 / IQ2;
  idum2 = IA2 * (idum2 - k*IQ2) - k*IR2;
  if (idum2 < 0) idum2 += IM2;
  j = iy / NDIV;
  iy = iv[j] - idum2;
  iv[j] = *idum;
  if (iy < 1) iy += IMM1;
  if ((temp = AM * iy) > RNMX) return RNMX;
  else return temp;
} // ran2


