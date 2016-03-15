#include <stdio.h>
#include <iostream>
#include <time.h>
#include <string>
#include <sstream>

#include "mex.h"
#include "matrix.h"


//Warning: zero input verification
void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] ){
	
	const char* filepath = mxArrayToString(prhs[0]);
	FILE* filePtr=fopen(filepath,"r");
	if(filePtr!=NULL){
		//Parsing variables
		char c[512];    //Character buffer to store each line
		char prefix[3]; //Variable that will hold the prefix for each line.
		prefix[2]='\0';

		int v_index =0;
        int vt_index=0;
        int vn_index=0;
        int f_index =0;
        int n=0;
        
        //This dummy variable will be used to skip every 2nd and 3rd number
        //in stringstream variable "line".
        char ch_dummy[3];
        char ch_slash;
        int  int_dummy=0;
        
        //Figure out the total amount of lines. 
        while(fgets(c,256,filePtr) != NULL){
            n++;
        }
        
        rewind(filePtr);
       
        
        //Allocate more than enough memory so we don't have to reallocate.
        plhs[0] = mxCreateNumericMatrix(n, 3, mxDOUBLE_CLASS, mxREAL);
        plhs[1] = mxCreateNumericMatrix(n, 2, mxDOUBLE_CLASS, mxREAL);
        plhs[2] = mxCreateNumericMatrix(n, 3, mxDOUBLE_CLASS, mxREAL);
        plhs[3] = mxCreateNumericMatrix(n, 4, mxINT32_CLASS,  mxREAL);
        
        //Fetch the pointers so we can copy data.
        double *v_ptr  = mxGetPr(plhs[0]);
        double *vt_ptr = mxGetPr(plhs[1]);
        double *vn_ptr = mxGetPr(plhs[2]);
        int    *f_ptr = (int*) mxGetData(plhs[3]);
        
        //Optional timing.
		//clock_t start = clock(), diff;
		while(fgets(c,512,filePtr) != NULL){
			strncpy(prefix,c,2);
			std::stringstream line(c);	

			if (strncmp(prefix,"v ",2)==0){
                line >> ch_dummy;
				line >> v_ptr[v_index];
				line >> v_ptr[v_index+n]; 
				line >> v_ptr[v_index+2*n];
               
                v_index++;
			}
            else if (strncmp(prefix,"vt",2)==0){
                line >> ch_dummy;
				line >> vt_ptr[vt_index];
				line >> vt_ptr[vt_index+n];

				vt_index++;
			}
            else if (strncmp(prefix,"vn",2)==0){
				line >> ch_dummy;
				line >> vn_ptr[vn_index];
				line >> vn_ptr[vn_index+n]; 
				line >> vn_ptr[vn_index+2*n];

                vn_index++;
			}
            else if (strncmp(prefix,"f ",2)==0){
                line >> ch_dummy;
				line >> f_ptr[f_index] >> ch_slash >> int_dummy>> ch_slash >> int_dummy;
				line >> f_ptr[f_index+n] >> ch_slash >> int_dummy>> ch_slash >> int_dummy;
				line >> f_ptr[f_index+2*n] >> ch_slash >> int_dummy>> ch_slash >> int_dummy;
				line >> f_ptr[f_index+3*n] >> ch_slash >> int_dummy>> ch_slash >> int_dummy;
                
				f_index++;
			}
		}
        
        //End of timing
		//diff = clock() - start;
        
        //int msec = diff * 1000 / CLOCKS_PER_SEC;
		//printf("Processed %s: %d lines in %d.%d seconds. \n",filepath, n, msec/1000, msec%1000);
		

		if(filePtr != NULL){
			fclose(filePtr);
		}
     
	}
    else{
        mexPrintf("importObjMex: Unable to open %s \n",filepath);
    }
}