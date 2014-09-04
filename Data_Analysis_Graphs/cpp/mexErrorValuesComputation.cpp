#include <matrix.h>
#include <mex.h>
#include <iostream>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/nonfree/nonfree.hpp>
#include <opencv2/nonfree/features2d.hpp>
#include <opencv2/flann/flann.hpp>
#include <opencv2/legacy/legacy.hpp>
#include <vector>
#include <iostream>
#include <bitset>
#include <cstring>
#include <string>
#include <cstdio>

#include "convertOpenCVMatToMatlabMat.h"
#include "convertMatlabMatToOpenCVMat.h"
#include "computeAlgorithmEstimateErrorValues.h"

using namespace std;
using namespace cv;

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {
	//
	
	Mat algorithm_counts = convertMatlabMatToOpenCVMat(prhs[0], true);
	Mat ground_truth = convertMatlabMatToOpenCVMat(prhs[1], true);
	//	Get all of the boolean values that signal (what processes to run) or (return values)
	//	Mat boolean_to_process_command_values = convertMatlabMatToOpenCVMat(prhs[2], true);
	
	const mxArray *row_data_dimension_mxArray_ptr = prhs[2];
  double *row_data_dimension_double_ptr =  ( double * ) mxGetData( row_data_dimension_mxArray_ptr );
	int row_data_dimension = (int) *row_data_dimension_double_ptr;
	fprintf(stderr, "Before printout\n");
	fprintf(stderr, "row_data_dimension: %d\nac.r: %d\tac.c: %d\tgt.r: %d\tgt.c: %d\n\n", row_data_dimension, algorithm_counts.rows, algorithm_counts.cols, ground_truth.rows, ground_truth.cols );
	
	std::pair< Mat, Mat > all_error_values_computer_counts = computeAlgorithmEstimateErrorValues( algorithm_counts, ground_truth, row_data_dimension );
	Mat algorithm_error_values = all_error_values_computer_counts.first;
	
	double* data_ptr = (double*) algorithm_error_values.data;
	
	//////////////////
	//////////////////
	//////////////////
	int ndim = 4;
	int dims[4] = {algorithm_error_values.size[0], algorithm_error_values.size[1], algorithm_error_values.size[2], algorithm_error_values.size[3]};
	
  int     nsubs, index, x; 
  double  *temp;
  int     *subs;
  nsubs=4;
  mxArray *pout = plhs[0] = mxCreateNumericArray(ndim, dims, mxDOUBLE_CLASS, mxREAL);
	
  subs = (int*) mxCalloc(nsubs,sizeof(int));
	for (int i = 0; i < (int) algorithm_error_values.size[0]; i++) {
		for (int j = 0; j < (int) algorithm_error_values.size[1]; j++) {
			for (int k = 0; k < (int) algorithm_error_values.size[2]; k++) {
				for (int m = 0; m < (int) algorithm_error_values.size[3]; m++) {
					subs[0] = i;
					subs[1] = j;
					subs[2] = k;
					subs[3] = m;
					
					index = mxCalcSingleSubscript(pout, nsubs, subs);
					int idx = algorithm_error_values.size[1]*algorithm_error_values.size[2]*algorithm_error_values.size[3]*i + algorithm_error_values.size[3]*algorithm_error_values.size[2]*j + algorithm_error_values.size[3]*k + m;
					double cur_value = data_ptr[ idx ];
					mxGetPr(pout)[index] = cur_value;
//					fprintf( stderr, "idx: %d i: %d j: %d k: %d\tcur_value: %.2f\n", idx, i, j, k, cur_value );
				}
			}
		}
	}
}
