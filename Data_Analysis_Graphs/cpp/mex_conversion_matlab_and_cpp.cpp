#include "mex_conversion_matlab_and_cpp.h"
#include "convertMatlabMatToOpenCVMat.h"

using namespace cv;
using namespace std;

double read_double_value( const mxArray *input_mx_array ) {
  double *double_value_ptr =  ( double * ) mxGetData( input_mx_array );
	double double_value = *double_value_ptr;
	return double_value;
}

// Kyle TODO: setup header data for this
mxArray* setup_mxArray_cell_array_of_matrices_from_vector_of_matrices( vector< vector< vector< int > > > vector_of_vector_of_vectors ) {
	int dims = { (int) vector_of_vector_of_vectors.size() };
	mxArray *cell_array_ptr = mxCreateCellMatrix( 1, dims );
	mwIndex i;
	for( int i=0; i < (mwIndex) vector_of_vector_of_vectors.size(); i++ ) {
		vector< vector< int > > cur_vector_of_vectors_int_ret = vector_of_vector_of_vectors[i];
		vector< vector< double > > cur_vector_of_vectors_double_ret = convert_vector_of_vector_to_doubles( cur_vector_of_vectors_int_ret );
		mxArray* cell_array_ptr_cur_indices_one_count = setup_mxArray_cell_array_of_matrices( cur_vector_of_vectors_double_ret );
		mxSetCell( cell_array_ptr, i, cell_array_ptr_cur_indices_one_count );
	}
	return cell_array_ptr;
}

vector< vector< double > > convert_vector_of_vector_to_doubles( vector< vector< int > > vector_of_vector_input_of_ints ) {
	vector< vector< double > > vector_output_of_doubles( (int) vector_of_vector_input_of_ints.size() );
	for( int i = 0; i < (int) vector_of_vector_input_of_ints.size(); i++ ) {
		vector< double > vector_output_of_doubles_cur = convert_vector_to_doubles( vector_of_vector_input_of_ints[i] );
		vector_output_of_doubles[i] = vector_output_of_doubles_cur;
	}
	return vector_output_of_doubles;
}

// TODO: setup a header file for the below
vector< double > convert_vector_to_doubles( vector< int > vector_input_of_ints ) {
	vector< double > vector_output_of_doubles_cur( (int) vector_input_of_ints.size(), -1 );
	for( int j = 0; j < (int) vector_input_of_ints.size(); j++ ) {
		vector_output_of_doubles_cur[j] = (double) vector_input_of_ints[j];
	}
	return vector_output_of_doubles_cur;
}

mxArray* setup_mxArray_cell_array_of_matrices( vector< vector< double > > vector_of_vectors ) {
	int dims = { (int) vector_of_vectors.size() };
	mxArray *cell_array_ptr = mxCreateCellMatrix( 1, dims );
	mwIndex i;
	for( i=0; i < (mwIndex) vector_of_vectors.size(); i++ ) {
		vector< double > cur_vector_ret = vector_of_vectors[i];
		int num_current_points = (int) cur_vector_ret.size();
		mxArray *mat_out_m = mxCreateNumericArray( 1, &num_current_points, mxDOUBLE_CLASS, mxREAL );
		double *mat_out_m_ptr = (double *) mxGetPr( mat_out_m );
		for ( int c = 0; c < num_current_points; c++ ) {
		  mat_out_m_ptr[c] = (double) cur_vector_ret[c];
		}
		mxSetCell( cell_array_ptr, i, mat_out_m );
	}
	return cell_array_ptr;
}

mxArray* create_mxArray_matrix_from_double_value( double input_double_value ) {
	vector<double> vector_temp;
	vector_temp.push_back( input_double_value );
	mxArray* mxArray_temp = create_mxArray_matrix( vector_temp );
	return mxArray_temp;
}

mxArray* create_mxArray_matrix( vector<double> vector_input ) {
	mxArray *vector_input_out_m;
	int num_vector_input = vector_input.size();
	vector_input_out_m = mxCreateNumericArray(1, &num_vector_input, mxDOUBLE_CLASS, mxREAL);
  double *vector_input_out_m_ptr =(double *) mxGetPr(vector_input_out_m);
  for(int c=0;c<num_vector_input;c++) {
    vector_input_out_m_ptr[c] = (double) vector_input[c];
  }
	return vector_input_out_m;
}

vector<Mat> convertMatlabCellArrayOfMatricesToCPPvectorOfMats( const mxArray *input_mx_array ) {
	// for each cell array entry
	// get the current matlab mxArray Matrix
	const mwSize * current_size =  mxGetDimensions( input_mx_array );
	mwSize rows_cur = current_size[0];
	mwSize columns_cur = current_size[1];
	
  mwSize total_num_of_cells;
  mwIndex index;
  
  total_num_of_cells = mxGetNumberOfElements( input_mx_array );
	vector<Mat> vector_of_mats( (int) total_num_of_cells );
	
	int cur_count = 0;
	for ( index = 0; index < total_num_of_cells; index++ ) {
		mxArray *current_mat = mxGetCell( input_mx_array, index );
		// transfer the matrix from MATLAB to OpenCV
		Mat current_opencv_mat = convertMatlabMatToOpenCVMat( current_mat, true );
		vector_of_mats[cur_count] = current_opencv_mat;
		cur_count++;
	}
	return vector_of_mats;
}
