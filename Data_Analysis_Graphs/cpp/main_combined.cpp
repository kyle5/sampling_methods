// call the combined approach

#include <cstdio>
#include <opencv2/opencv.hpp>
#include <iostream>
#include <opencv2/core/core.hpp>
#include <vector>
#include <cstring>
#include <string>
#include <cstdlib>
#include <ctime>

#include <opencv2/core/core.hpp>

#include "get_random_points.h"
#include "get_random_points_new_object_model.h"
#include "get_rp_helper_functions.h"

using namespace cv;
using namespace std;

int main() {
	
	fprintf(stderr, "very start of the function\n");
	
	Mat algorithm_counts = Mat::zeros( 10, 10, CV_8U );
	Mat valid_counts = Mat::ones( 10, 10, CV_64F );
	srand(time(NULL));
	for ( int i = 0; i < algorithm_counts.rows; i++ ) {
		for ( int j = 0; j < algorithm_counts.cols; j++ ) {
			// set the index to a random value between 1 and 50
			uchar random_uchar = (uchar) ( rand() % 50 + 1 );
			algorithm_counts.at<uchar>( i, j ) = random_uchar;
			
		}
	}
	double cur_sampling_number = 5;
	int spatial_and_stratified = 0;
	double weight_spatial = 0.9;
	int visualize_images = 0;
	fprintf(stderr, "after reading input values\n");
	
	// setup the necessary output variables from each function
	vector< Point2f > final_points;
	vector< vector< int > > indices_at_each_iteration_in_spatial_space;
	vector< vector< double > > spatial_probability_in_spatial_space;
	vector< vector< double > > stratified_probability_in_spatial_space;
	vector< vector< double > > combined_stratified_and_spatial_probability_in_spatial_space;
	vector< vector< int > > distribution_indices_in_spatial_space;
	vector< double > stratified_indices_organized_by_spatial_indices;
	vector< vector< double > > spatial_distance_in_spatial_space;
	vector< vector< double > > stratified_distance_in_spatial_space;
	
	if ( spatial_and_stratified > 0 ) {
		SamplingObjectModel sampling_object_model;
		sampling_object_model.get_random_points_new( 50, 0.925, SamplingObjectModel::GLOBAL_NEW, false, cur_sampling_number, 0, algorithm_counts, weight_spatial, valid_counts );
		vector< Point2f > final_points = sampling_object_model.get_final_points(  );
	} else {
		final_points = get_random_points( 50, 0.925, GLOBAL, false, cur_sampling_number, 0, valid_counts );
	}

	// print the end of the function
	cerr << "Fin" << endl;
	return 0;
}
