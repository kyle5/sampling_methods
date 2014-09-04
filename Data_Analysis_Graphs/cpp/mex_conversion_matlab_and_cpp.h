#ifndef __MEX_CONVERSION_MATLAB_AND_CPP_H__
#define __MEX_CONVERSION_MATLAB_AND_CPP_H__

#include <matrix.h>
#include <mex.h>
#include <cstdio>
#include <opencv2/opencv.hpp>
#include <iostream>
#include <opencv2/core/core.hpp>
#include <vector>
#include <cstring>
#include <string>

#include <opencv2/core/core.hpp>

std::vector< std::vector< double > > convert_vector_of_vector_to_doubles( std::vector< std::vector< int > > vector_input_of_ints );
mxArray* setup_mxArray_cell_array_of_matrices( std::vector< std::vector< double > > vector_of_vectors );
mxArray* create_mxArray_matrix( std::vector<double> vector_input );
double read_double_value( const mxArray *input_mx_array );
mxArray* setup_mxArray_cell_array_of_matrices_from_vector_of_matrices( std::vector< std::vector< std::vector< int > > > vector_of_vector_of_vectors );
std::vector< double > convert_vector_to_doubles( std::vector< int > vector_input_of_ints );
std::vector<cv::Mat> convertMatlabCellArrayOfMatricesToCPPvectorOfMats( const mxArray *input_mx_array );
mxArray* create_mxArray_matrix_from_double_value( double input_double_value );
#endif
