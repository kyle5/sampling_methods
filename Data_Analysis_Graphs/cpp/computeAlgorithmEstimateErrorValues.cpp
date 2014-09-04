#include "computeAlgorithmEstimateErrorValues.h"
#include "compute_error_helpers.h"
#include "setup_section_indices.h"
#include "setup_counts_from_sections.h"
#include "get_averages.h"

// temp
#include <iostream>
#include <cstdio>
#include <cmath>

using namespace std;
using namespace cv;

std::pair< Mat, Mat > computeAlgorithmEstimateErrorValues( Mat algorithm_counts_mat, Mat groundtruth_counts_mat, int rows_dimension ) {

	std::srand(std::time(0)); // use current time as seed for random generator

	static const double arr[] = {2, 5, 10};
	vector<double> hand_sampled_percentages(arr, arr + sizeof(arr) / sizeof(arr[0]) );
	
//	static const string arr_error_calcs[] = {"Unscaled Computer Counts", "Direct Extrapolation of Computer Counts", "Kriging of Computer Counts", "Stratified Counts", "Spatial", "Standard Deviation"};
	static const string arr_error_calcs[] = {"Unscaled Computer Counts", "Direct Extrapolation of Computer Counts", "Kriging of Computer Counts", "Stratified Counts"};
	vector<string> str_error_calcs_vector(arr_error_calcs, arr_error_calcs + sizeof(arr_error_calcs) / sizeof(arr_error_calcs[0]) );

	static const string arr_names_of_orchard_areas[] = {"Error of Estimated Apples Counted in Individual Sections", "Error of Estimated Apples Counted in Individual Rows", "Error of Total Estimated Apples Counted in Orchard"};
	vector<string> names_of_orchard_areas_vector( arr_names_of_orchard_areas, arr_names_of_orchard_areas + sizeof(arr_names_of_orchard_areas) / sizeof(arr_names_of_orchard_areas[0]) );
	
	int area_in_orchard_for_error_calculation = 3;
	int loop_iterations = 1000;
	int increment = 6;
	
	int rows_cur_map = algorithm_counts_mat.rows;
	int columns_cur_map = algorithm_counts_mat.cols;
	
	int starting_point = 1;
  int total_sections = algorithm_counts_mat.rows * algorithm_counts_mat.cols;
	
	vector<int> sections_algorithm_counted_vector = linspace( starting_point, total_sections, increment );
  
  int num_types_of_error_calcs = (int) 2*str_error_calcs_vector.size();
  int num_areas_of_orchard = (int) names_of_orchard_areas_vector.size();
	
	Mat cur_predictions_mat = Mat::zeros( rows_cur_map, columns_cur_map, CV_64F );
	double *cur_predictions_mat_ptr = (double *)cur_predictions_mat.data;
  Mat X, Y;
	meshgrid( Range(0, columns_cur_map-1), Range(0, rows_cur_map-1), X, Y );
	
	Mat tree_locations_x = X;
	Mat tree_locations_y = Y;
  Mat larger_image_template = X;
	
	int all_results_dim[4] = { (int)hand_sampled_percentages.size(), (int) sections_algorithm_counted_vector.size(), num_types_of_error_calcs, num_areas_of_orchard };
	Mat all_computer_mean_errors( 4, all_results_dim, CV_64F, Scalar::all(-5) );
	Mat std_dev_computer_errors( 4, all_results_dim, CV_64F, Scalar::all(-5) );
	
	vector<double> all_algorithm_counts_vec, all_groundtruth_counts_vec;
	for (int i = 0; i < algorithm_counts_mat.rows; i++ ) {
		for (int j = 0; j < algorithm_counts_mat.cols; j++ ) {
			all_algorithm_counts_vec.push_back( algorithm_counts_mat.at<double>(i, j) );
			all_groundtruth_counts_vec.push_back( groundtruth_counts_mat.at<double>(i, j) );
		}
	}
	int total_groundtruth_count = 0;
	for (int i = 0; i < total_sections; i++ ) {
		total_groundtruth_count += all_groundtruth_counts_vec[i];
	}
	
	for ( int i = 0; i < (int) hand_sampled_percentages.size(); i++ ) {
		double cur_hand_sampled_percentage = hand_sampled_percentages[i];
		double cur_hand_sampled_number = (cur_hand_sampled_percentage * total_sections)/ 100;
		for ( int j = 0; j < (int) sections_algorithm_counted_vector.size(); j++ ) {
			int cur_sections_algorithm_counted = sections_algorithm_counted_vector[j];
			int arr_temp[3] = {loop_iterations, num_types_of_error_calcs, num_areas_of_orchard};
			Mat cur_computer_errors_all_types_all_iterations( 3, arr_temp, CV_64F, Scalar::all(1) );
			for ( int cur_loop_iteration = 0; cur_loop_iteration < loop_iterations; cur_loop_iteration++ ) {
				for ( int a = 0; a < 2; a++) {
					if (a != 1) continue;
					for( int b = 0; b < 6; b++) {
						if (b > 1) continue; // Just do unscaled and scaled for now
						// STILL: sets up random hand sampling and computer imaged (connected/disconnected)
						// This can be sped up in the near future to only use one set of memory for the short-term
							// Just need to use to allocate the vector
						string error_calc_type;
						if ( b >= 0 && b <= 2 ) {
							error_calc_type = string( "RANDOM" );
						} else if (b == 3) {
							error_calc_type = string( "STRATIFIED" );
						} else if (b == 4) {
							error_calc_type = string( "SPATIAL" );
						} else {
							error_calc_type = string( "STDEV" );
						}
						std::pair< vector<int>, vector<int> > indices_ground_and_algorithm = setup_section_indices( all_algorithm_counts_vec, error_calc_type, cur_sections_algorithm_counted, cur_hand_sampled_number, total_sections );
						vector<int> ground_count_indices = indices_ground_and_algorithm.first;
						vector<int> algorithm_count_indices = indices_ground_and_algorithm.second;
						std::pair< vector<int>, vector<int> > counts_ground_and_algorithm = setup_counts_from_sections( algorithm_counts_mat, groundtruth_counts_mat, indices_ground_and_algorithm );
						vector< int > ground_counts = counts_ground_and_algorithm.first;
						vector< int > algorithm_counts = counts_ground_and_algorithm.second;
						vector< int > algorithm_counts_sorted = algorithm_counts;
						sort ( algorithm_counts_sorted.begin(), algorithm_counts_sorted.end() );
						
						// random sampling
						// get the scaling factor
						vector<double> all_scaling_factors;
						double cur_total_ground = 0;
						double cur_total_algorithm = 0;
						for ( int ii = 0; ii < ground_count_indices.size(); ii++ ) {
							int cur_index = ground_count_indices[ii];
							int cur_algorithm_count = all_algorithm_counts_vec[cur_index];
							int cur_groundtruth_count = all_groundtruth_counts_vec[cur_index];
							double cur_scaling_factor = (double)cur_algorithm_count/(double)cur_groundtruth_count;
							all_scaling_factors.push_back( cur_scaling_factor );
							cur_total_ground += cur_groundtruth_count;
							cur_total_algorithm += cur_algorithm_count;
						}
						double scaling_factor = cur_total_algorithm / cur_total_ground;
						// get average count
						double average_unscaled_algorithm_count, average_algorithm_count_scaled;
						vector<double> algorithm_counts_double;
						for(int ii = 0; ii < (int) algorithm_counts.size(); ii++) {
							algorithm_counts_double.push_back( (double) algorithm_counts[ii] );
						}
						average_unscaled_algorithm_count = getAverage( algorithm_counts_double );
						average_algorithm_count_scaled = average_unscaled_algorithm_count / scaling_factor;
						if ( b >= 0 && b <= 3 ) {
							if (b == 0 || b == 1) { 		// b == 0; unscaled counts
								double average_count = average_algorithm_count_scaled;
								double scaling_factor_cur_method = scaling_factor;
								if (b == 0) {
									average_count = average_unscaled_algorithm_count;
									scaling_factor_cur_method = 1.0;
								}
								// setup predictions vector
								vector<int> algorithm_count_indices_sorted = algorithm_count_indices;
								sort( algorithm_count_indices_sorted.begin(), algorithm_count_indices_sorted.end() );
								int last_idx_found = -1;
								for( int ii = 0; ii < total_sections; ii++ ) {
									int found_idx = 0;
									if ( algorithm_count_indices_sorted[last_idx_found+1] == ii ) {
										found_idx = 1; last_idx_found++;
									}
									int cur_row = ii%algorithm_counts_mat.rows;
									int cur_col = ii/algorithm_counts_mat.rows;
									if ( found_idx ) {
										// scale the algorithm count
										double cur_count = (double) all_algorithm_counts_vec[ii];
										cur_predictions_mat_ptr[ii] = ( (double) all_algorithm_counts_vec[ii] / (double) scaling_factor_cur_method );
									} else {
										cur_predictions_mat_ptr[ii] = average_count;
									}
								}
							} else if (b == 2) {
								// kriging
								vector<int> algorithm_count_indices_sorted = algorithm_count_indices;
								sort( algorithm_count_indices_sorted.begin(), algorithm_count_indices_sorted.end() );
								// sudo code:
								// setup the input to kriging:
								// // already known X and Y locations and their corresponding counts
								// // requested X and Y locations
								// // Call kriging
								// // Output of kriging:
								// // // Are the predictions
								int last_idx_found = -1;
								for( int ii = 0; ii < total_sections; ii++ ) {
									int found_idx = 0;
									if ( algorithm_count_indices_sorted[last_idx_found+1] == ii ) {
										found_idx = 1; last_idx_found++;
									}
									int cur_row = ii%algorithm_counts_mat.rows;
									int cur_col = ii/algorithm_counts_mat.rows;
									if ( found_idx ) {
										// scale the algorithm count
										double scaled_algorithm_count = ((double) all_algorithm_counts_vec[ii] / (double) scaling_factor);
										cur_predictions_mat_ptr[ii] = scaled_algorithm_count;
									} else {
										cur_predictions_mat_ptr[ii] = average_algorithm_count_scaled;
									}
								}
							} else {
								// Assume that (b == 3 )
								// unimplemented stratafied
								// sudo code:
								// // sort the known counts
								// // sort the indices in the same manner
								// // Get locations based on a spread of the algorithm counts:
								// // // varied_sections_step = num_sections_for_computer_to_count / (num_sections_to_compute_scaling_factor+1);
								// // // 
								// // already known X and Y locations and their corresponding counts
								// // requested X and Y locations
							}
						}
						else {
							// assume that (b > 3)
							// unimplemented sampling methods
						}

						double total_predictions = 0;
						for( int ii = 0; ii < (int) total_sections; ii++) {
							int cur_row = ii%algorithm_counts_mat.rows;
							int cur_col = ii/algorithm_counts_mat.rows;
							total_predictions += cur_predictions_mat.at<double>( cur_row, cur_col );
						}
						// compute error over all sections
						double error_entire_vineyard =  abs((double) total_predictions - (double) total_groundtruth_count) / (double) total_groundtruth_count;
						// compute error over rows
						vector<double> all_row_errors;
						for ( int ii = 0; ii < cur_predictions_mat.cols; ii++ ) {
							double total_row_gt = 0;
							double total_row_comp = 0;
							for ( int jj = 0; jj < cur_predictions_mat.rows; jj++ ) {
								total_row_gt += groundtruth_counts_mat.at<double>(jj, ii);
								total_row_comp += cur_predictions_mat.at<double>(jj, ii);
							}
							double cur_row_error = abs( (total_row_comp-total_row_gt)/total_row_gt );
							all_row_errors.push_back( cur_row_error );
						}
						double error_by_row = getAverage( all_row_errors );
						// compute error over sections
						vector<double> all_section_errors;
						for ( int ii = 0; ii < cur_predictions_mat.cols; ii++ ) {
							for ( int jj = 0; jj < cur_predictions_mat.rows; jj++ ) {
								double cur_gt = groundtruth_counts_mat.at<double>(jj, ii);
								double cur_comp = cur_predictions_mat.at<double>(jj, ii);
								double cur_section_error = abs( (cur_comp-cur_gt)/cur_gt );
								all_section_errors.push_back( cur_section_error );
							}
						}
						double error_by_section = getAverage( all_section_errors );
						// save the iteration error values to a results structure
						cur_computer_errors_all_types_all_iterations.at<double>( cur_loop_iteration, (int)a*(int)str_error_calcs_vector.size()+b, 2 ) = error_entire_vineyard;
		    		cur_computer_errors_all_types_all_iterations.at<double>( cur_loop_iteration, (int)a*(int)str_error_calcs_vector.size()+b, 1 ) = error_by_row;
						cur_computer_errors_all_types_all_iterations.at<double>( cur_loop_iteration, (int)a*(int)str_error_calcs_vector.size()+b, 0 ) = error_by_section;
					}
				}
			}
			int dimension_iteration = 0;
			Mat cur_mean_errors = average_cur_iteration( cur_computer_errors_all_types_all_iterations, dimension_iteration, 3 );
			int cur_dims[4] = {i, j, 0, 0};
			for ( int ii = 0; ii < cur_mean_errors.size[0]; ii++ ) {
				cur_dims[2] = ii;
				for ( int jj = 0; jj < cur_mean_errors.size[1]; jj++ ) {
					cur_dims[3] = jj;
					all_computer_mean_errors.at<double>( cur_dims ) = cur_mean_errors.at<double>( ii, jj );
				}
			}
		}
		// CUTOUT: saves results for current percentage to overall results set
	}
	std::pair < Mat, Mat > all_results;
	all_results = std::make_pair( all_computer_mean_errors, std_dev_computer_errors );
	return all_results;
}
