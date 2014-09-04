#include "mex_conversion_matlab_and_cpp.h"
#include "get_rp_helper_functions.h"
#include "convertMatlabMatToOpenCVMat.h"
#include "convertOpenCVMatToMatlabMat.h"
#include "sampling_object.h"

#include "mex_get_optimal_indices_globally.h"

using namespace std;
using namespace cv;

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {
	fprintf(stderr, "very start of the function\n");
	Mat algorithm_counts = convertMatlabMatToOpenCVMat(prhs[0], true);
	
	double cur_sampling_number = read_double_value( prhs[1] );
	double spatial_and_stratified_designation = read_double_value( prhs[2] );
	int spatial_and_stratified = (int) round( spatial_and_stratified_designation );
	double weight_spatial = read_double_value( prhs[3] );
	
	Mat hand_counts = convertMatlabMatToOpenCVMat( prhs[4], true );
	double seed_variable_input = read_double_value( prhs[5] );
	unsigned int rand_seed = (unsigned long) seed_variable_input;
	cerr << "random seed: " << rand_seed << endl;
	Mat valid_counts = convertMatlabMatToOpenCVMat( prhs[6], true );
	//
	fprintf(stderr, "after reading all variables\n");
	int points_to_obtain = cur_sampling_number;
	// just make one of the already completed methods into a helper function
	// below should be a mapping from spatial space indices to stratified space indices
	
	vector<int> valid_indices;
	for ( int i = 0; i < valid_counts.rows*valid_counts.cols; i++ ) {
		if ( valid_counts.at<double>( i % valid_counts.rows, i / valid_counts.rows ) == 1.0 ) {
			valid_indices.push_back(i);
		}
	}
	if ( (int) valid_indices.size() == 0 ) throw runtime_error("There are no valid indices?!");
	int total_points_on_grid = valid_counts.rows*valid_counts.cols;
	int rows_matrix = valid_counts.rows;
	int cols_matrix = valid_counts.cols;
	vector<int> stratified_indices(total_points_on_grid, 0);
	
	sampling_object sampling_object_instance;
	vector<int> final_indices = sampling_object_instance.get_representative_points( points_to_obtain, stratified_indices, valid_indices, total_points_on_grid, rows_matrix, cols_matrix, rand_seed );
	
	vector< double > final_indices_matlab = convert_vector_to_doubles( final_indices );
	for ( int i = 0; i < (int) final_indices_matlab.size(); i++ ) final_indices_matlab[i] += 1;  // Add 1 to convert to MATLAB //
	fprintf(stderr, "before returning values\n");
	plhs[0] = create_mxArray_matrix( final_indices_matlab );
}
