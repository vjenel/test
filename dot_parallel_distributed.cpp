// dot product ; distributed
#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>

int const ROOT_NODE = 0;

using namespace std;

double dot_product_serial(int , double* , double* );
void scan_file(const char *, int &);
void read_file_distrib(const char *, int N, double * &, double * &, const int , const int , int );
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
    N_local =  N/N_threads + 1 ; 
    i_start = (thread) * N_local; // i_start is a pointer to the original big array
   }else {
    N_local =  N/N_threads ;
    i_start = left*(N_local+1)+ (thread-left) * N_local;
   }
   i_end = i_start + N_local -1;
   double *x = (double*)malloc(N_local*sizeof(double)); //malloc(0): gracefully handling the case N < N_threads for thread>=left
   double *y = (double*)malloc(N_local*sizeof(double));

   read_file_distrib(nf, N, x, y, i_start, i_end,  N_threads ); // each cpu has a little chunck of data
   MPI_Barrier(MPI_COMM_WORLD);
   test = dot_product_serial(N_local, x, y);
//   cout << thread<<" local dot = "<<test<<"\n";
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

void read_file_distrib(const char *nf, int N, double * &x, double * &y, const int i_start, const int i_end,  int N_threads ){
// the data is so large that wont fit in one cpu onll it will be spit amoung cpus
 int size_buff=2048;
 int i,i00,j,send_to,rank;
 double r2[2];
 char buffer[size_buff];
 FILE * f ;
 MPI_Status status;
 MPI_Comm_rank(MPI_COMM_WORLD, &rank); 

 int i0[N_threads],i1[N_threads],di[N_threads], rest=N % N_threads;
// i0 i1 di rest is the information about data partitiong scheme duplocated on all threads
// i0 is the same wth i_start,  i1 is the same with i_end;  di is the same with N_local 
 for (int i=0;i<N_threads;++i){ if ( i<rest ) { di[i] = N/N_threads+1; } else {di[i]=N/N_threads;  } }
 for (int i=0;i<N_threads;++i){ if ( i<rest ) { i0[i] = i * di[i] ;  } else { i0[i] = rest*(di[i]+1)+(i-rest)*di[i] ;} }
 for (int i=0;i<N_threads;++i){ i1[i] = i0[i] + di[i] -1;}; // di[0] is guaranteed to have the largest size
 double *rbuffer = (double*)malloc(2*di[0]*sizeof(double));

// if (rank == ROOT_NODE){
// for (int i=0;i<N_threads;++i){cout <<rank<<" i="<<i <<" di="<<di[i]<<" i0="<<i0[i]<<" i="<<i1[i]<<"\n";}
// }}

 if (rank == ROOT_NODE){
   f = fopen(nf, "r");
   if (f==NULL){ printf(" ERROR opening the file \n");
   }else{   if (fgets(buffer, size_buff, f)!=NULL){ /* skip the first line */ }
   i00 = 0;
   for (int irank = 0 ; irank < N_threads; ++irank){
   for (int k=0;k<di[irank];++k){
       if (fgets(buffer, size_buff, f)==NULL){ exit_in_error((char*)"ERROR reading the data file \n"); }
       sscanf( buffer, "%lf %lf",&rbuffer[k],&rbuffer[di[irank]+k]  ); 
       i00 += 1;
//       cout << irank<<" rb="<<rbuffer[k]<<" "<<rbuffer[di[irank]+k]<<" "; 
   }
//   cout<<"\n";
   if (irank!=ROOT_NODE){ // send only to slaves nodes
   MPI_Send(rbuffer, 2*di[irank], MPI_DOUBLE, irank, 123+irank, MPI_COMM_WORLD);
   }else{ // in master node just save the buffer in exit' variables
      for (int k=0;k<di[rank];++k){
         x[k] = rbuffer[k]; y[k] = rbuffer[k+di[rank]];
//         printf("%d in master k= %d %lf %lf \n",rank,k, x[k], y[k]);
      }
   }
   } 
   }
 }

 if (rank!=ROOT_NODE){ // receive it if slave node
 MPI_Recv(rbuffer, 2*di[rank], MPI_DOUBLE, ROOT_NODE, 123+rank, MPI_COMM_WORLD, &status);
 for (int k=0;k<di[rank];++k){
    x[k] = rbuffer[k]; y[k] = rbuffer[k+di[rank]]; // copy the received buffer in exit' variables
//   printf("%d received k= %d %lf %lf \n",rank,k, x[k], y[k]);
 }
 }

 free(rbuffer);
  

 if (rank == ROOT_NODE){ fclose(f); }
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
 
