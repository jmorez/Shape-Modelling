// exportObj.cpp : Defines the exported functions for the DLL application.
//

//#include "stdafx.h"


#include <stdio.h>
#include <iostream>

#include "mex.h"
#include "matrix.h"


//Better error-reporting function.
void mxShowCriticalErrorMessage(const char *msg)
{
    mxArray *arg;
    arg = mxCreateString(msg);
    mexCallMATLAB(0,0,1,&arg,"error");
}

//Warning: zero input verification
void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[]){
	if(nrhs !=5){
		mxShowCriticalErrorMessage("exportObjMex: wrong amount of input arguments. \n");
	}

	//Fetch the amount of lines to write for each array
	unsigned int v_amount=mxGetM(prhs[1]);
	unsigned int vt_amount=mxGetM(prhs[2]);
	unsigned int vn_amount=mxGetM(prhs[3]);
	unsigned int f_amount=mxGetM(prhs[4]);

	double *v_ptr  = mxGetPr(prhs[1]);
	double *vt_ptr = mxGetPr(prhs[2]);
	double *vn_ptr = mxGetPr(prhs[3]);
	int *f_ptr=(int*)mxGetData(prhs[4]);

	char* filePath= mxArrayToString(prhs[0]);
	FILE *filePtr = fopen(filePath,"w");	

	if (filePtr!=NULL){

		for(unsigned int i=0; i < v_amount; i++){
			fprintf(filePtr,"v %f %f %f \n",v_ptr[i],v_ptr[i+v_amount],v_ptr[i+2*v_amount]);
		}
		for(unsigned int i=0; i < vt_amount; i++){
			fprintf(filePtr,"vt %f %f \n",vt_ptr[i],vt_ptr[i+vt_amount]);
		}
		for(unsigned int i=0; i < vn_amount; i++){
			fprintf(filePtr,"vn %f %f %f \n",vn_ptr[i],vn_ptr[i+vn_amount],vn_ptr[i+2*vn_amount]);
		}
		for(unsigned int i=0; i < f_amount; i++){
			fprintf(filePtr,"f %d/%d/%d %d/%d/%d %d/%d/%d %d/%d/%d \n", 
							f_ptr[i],f_ptr[i],f_ptr[i],								
							f_ptr[i+f_amount],f_ptr[i+f_amount],f_ptr[i+f_amount],										
							f_ptr[i+2*f_amount],f_ptr[i+2*f_amount],f_ptr[i+2*f_amount],										
							f_ptr[i+3*f_amount],f_ptr[i+3*f_amount],f_ptr[i+3*f_amount]);
		}
		fclose(filePtr);
	}
	else{
		printf("Unable to open %s. \n",filePath);
	}
}