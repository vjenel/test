//  serial version of dort product 
// file structure 
//N
//x(i) y(i)
#include <stdio.h>
#include <stdlib.h>
#include <iostream>

using namespace std;

double dot_product_serial(int , double* , double* );
void scan_file(const char *, int &);
void read_file_serial(const char *, int N, double * &, double * &  );

int main(int argc, char * argv[]){
   int i,j,k, N;
   char * nf = (char*) "./text.txt"; 
   double sum;
 
   scan_file(nf, * &N); 
   double *x = (double*)malloc(N*sizeof(double)); 
   double *y = (double*)malloc(N*sizeof(double)); 
   read_file_serial(nf, N, x, y ); 
   sum = dot_product_serial(N, x, y); 
   printf(" -------  dot product = %lf\n",sum);

  free(x);free(y);
}

void scan_file(const char *nf, int & N){ 
 int size_buff=2048;
 char buffer[size_buff];
 FILE * f = fopen(nf, "r");
 if (f==NULL){ printf(" ERROR opening the file \n");
 }else{
    if (fgets(buffer, size_buff, f)!=NULL){ 
        sscanf(buffer,"%d", &N);
    } 
 }
 fclose(f);
}

void read_file_serial(const char *nf, int N, double * &x, double * &y ){
// the data is so large that wont fit in one cpu onll it will be spit amoung cpus
 int size_buff=2048;
 int i,i00,j,send_to,rank;
 double r2[2];
 char buffer[size_buff];
 FILE * f ;

   f = fopen(nf, "r");
   if (f==NULL){ printf(" ERROR opening the file \n");
   }else{   if (fgets(buffer, size_buff, f)!=NULL){ /* skip the first line */ }
   for (int i=0; i<N; ++i) {
       if (fgets(buffer, size_buff, f)==NULL){ printf("ERROR reading the data file \n");exit(0); }
       sscanf( buffer, "%lf %lf",&x[i],&y[i]  );
   }}
   fclose(f);

}


double dot_product_serial(int N, double* A, double* B){
 double s=0.0;
 for (int i=0;i<N;++i){ s += A[i]*B[i]; };
 return (s);
}

 
