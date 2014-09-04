#include "mex_conversion_matlab_and_cpp.h"
#include "get_random_points.h"
#include "get_random_points_new_object_model.h"
#include "get_rp_helper_functions.h"
#include "convertMatlabMatToOpenCVMat.h"
#include "convertOpenCVMatToMatlabMat.h"

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {
	fprintf( stderr, "start of getting optimal indices\n" );

	Mat algorithm_counts = convertMatlabMatToOpenCVMat(prhs[0], true);
	
	double cur_sampling_number = read_double_value( prhs[1] );
	double spatial_and_stratified_designation = read_double_value( prhs[2] );
	int spatial_and_stratified = (int) round( spatial_and_stratified_designation );
	double weight_spatial = read_double_value( prhs[3] );
	
	Mat hand_counts = convertMatlabMatToOpenCVMat( prhs[4], true );

	double seed_variable_input = read_double_value( prhs[5] );
	Mat valid_counts = convertMatlabMatToOpenCVMat( prhs[6], true );

	vector< Point2f > final_points;
	final_points.push_back( Point2f( 10, 10 ) );

	unsigned long seed_variable = (unsigned long) seed_variable_input;
	cerr << "random seed: " << seed_variable << endl;
	fprintf( stderr, "before if statement\n" );
/*
	if ( spatial_and_stratified > 0 ) {
		SamplingObjectModel sampling_object_model;
		sampling_object_model.get_random_points_new( 50, 0.925, SamplingObjectModel::GLOBAL_NEW, false, cur_sampling_number, seed_variable, algorithm_counts, weight_spatial, valid_counts );
		final_points = sampling_object_model.get_final_points();
	} else {
		fprintf( stderr, "purely spatial\n" );
*/
		final_points = get_random_points( 50, 0.925, GLOBAL, false, cur_sampling_number, seed_variable, valid_counts );
/*
	}
*/
	fprintf(stderr, "after getting indices\n");
	vector<int> final_indices = get_point_indices_new( algorithm_counts, final_points );
	vector< double > final_indices_matlab = convert_vector_to_doubles( final_indices );
	for ( int i = 0; i < (int) final_indices_matlab.size(); i++ ) final_indices_matlab[i] += 1;  // Add 1 to convert to MATLAB //
	plhs[0] = create_mxArray_matrix( final_indices_matlab );
}
