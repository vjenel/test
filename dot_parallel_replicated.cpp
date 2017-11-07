// The read data is replicated amoung all CPUs
// file structure 
//N
//x(i) y(i)
#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>

int const ROOT_NODE = 0;

using namespace std;

double dot_product_serial(int , double* , double* );
void scan_file(const char *, int &);
void read_file(const char *, int N, double * &, double * &, const int , const int  );
void exit_in_error(char *);

int main(int argc, char * argv[]){
   int i,j,k,thread, N_threads, N, N_local, left, i_start, i_end;
   char * nf = (char*) "./text.txt"; 
   double sum,test;
 
   MPI_Init( &argc, &argv);
   MPI_Comm_size(MPI_COMM_WORLD, &N_threads);
   MPI_Comm_rank(MPI_COMM_WORLD, &thread);

   if (thread==ROOT_NODE){  scan_file(nf, * &N); }
   MPI_Bcast(&N, 1, MPI_INT, ROOT_NODE, MPI_COMM_WORLD);
//cout << N << " " << thread << "\n";
   left = N % N_threads; 
   if (thread < left) { //distribute the remianing elements uniformly
    N_local = N/N_threads + 1 ; 
    i_start = (thread) * N_local; // i_start is a pointer to the original big array
   }else {
    N_local = N/N_threads ;
    i_start = left*(N_local+1)+ (thread-left) * N_local;
   }
   i_end = i_start + N_local -1;
   double *x = (double*)malloc(N*sizeof(double)); // all threads will have the entire replicated copies of x and y 
   double *y = (double*)malloc(N*sizeof(double)); // in MD -> replicated data parallelization strategy

   read_file(nf, N, x, y, i_start, i_end ); // each cpu has a little chunck of data
   MPI_Barrier(MPI_COMM_WORLD);
   MPI_Bcast(x,N, MPI_DOUBLE, ROOT_NODE, MPI_COMM_WORLD);
   MPI_Bcast(y,N, MPI_DOUBLE, ROOT_NODE, MPI_COMM_WORLD);

   test = dot_product_serial(N_local, (x+i_start), (y+i_start)); 
//   note that (x+i_start) is the pointer notetion (of  x[i_start:i_start+N_local-1]  
//   and it is the same as:
//   test = dot_product_serial(N_local, &x[i_start], &y[i_start]);

   MPI_Reduce(&test, &sum, 1, MPI_DOUBLE, MPI_SUM, ROOT_NODE,MPI_COMM_WORLD);
   if (thread==ROOT_NODE){
    printf(" -------  dot product = %lf\n",sum);
  }

   free(x);free(y);
   MPI_Finalize();
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

void read_file(const char *nf, int N, double * &x, double * &y, const int i_start, const int i_end ){
// the data is so large that wont fit in one cpu onll it will be spit amoung cpus
 int size_buff=2048;
 int i,i00,j,send_to,rank;
 double r2[2];
 char buffer[size_buff];
 FILE * f ;
 MPI_Status status;
 MPI_Comm_rank(MPI_COMM_WORLD, &rank); 

 if (rank == ROOT_NODE){
   f = fopen(nf, "r");
   if (f==NULL){ printf(" ERROR opening the file \n");
   }else{   if (fgets(buffer, size_buff, f)!=NULL){ /* skip the first line */ }
   for (int i=0; i<N; ++i) {
       if (fgets(buffer, size_buff, f)==NULL){ exit_in_error((char*)"ERROR reading the data file \n"); }
       sscanf( buffer, "%lf %lf",&x[i],&y[i]  );
   }}
   fclose(f);
   }

}


double dot_product_serial(int N, double* A, double* B){
 double s=0.0;
 for (int i=0;i<N;++i){ s += A[i]*B[i]; };
 return (s);
}

void exit_in_error(char* msg){
 int ierr;
 printf("ERROR: \n %s \n", msg);
 MPI_Abort(MPI_COMM_WORLD,ierr);
}
 
