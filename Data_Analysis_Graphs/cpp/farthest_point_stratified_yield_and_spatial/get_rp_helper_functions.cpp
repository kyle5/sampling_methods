#include "get_random_points_new_object_model.h"
#include "get_rp_helper_functions.h"

using namespace std;
using namespace cv;

void print_opencv_matrix( Mat matrix_to_print ) {
	fprintf( stderr, "[" );
	for (int i = 0; i < matrix_to_print.rows; i++) {
		if ( i != 0 ) fprintf( stderr, "\n" );
		for (int j = 0; j < matrix_to_print.cols; j++) {
			double value = matrix_to_print.at<double>(i, j);
			if ( j != 0 ) fprintf( stderr, ", " );
			fprintf( stderr, "%.2f", value );
		}
	}
	fprintf( stderr, "]\n" );
}

vector< double > create_spatial_distribution_new( vector < Circle_2_new > list_of_circles ) {
	int length_of_spatial_samples = (int) list_of_circles.size();
	vector< double > ret = vector< double >( length_of_spatial_samples, 0 );
	int last_point = floor( ((double) length_of_spatial_samples) / 3 );
	double cur_value = 0, total_value = 0;
	for (int i = 0; i <= last_point; i++) {
		double exp_part = pow( last_point - i, 3 );
		cur_value = exp_part * list_of_circles[i].squared_radius() + 1;
		ret[i] = cur_value;
		total_value += cur_value;
	}
	for ( int i = 0; i <= last_point; i++ ) {
		ret[i] = ret[i] / total_value;
	}
	return ret;
}

vector< Point2f > get_point_coordinates_new( unsigned npoints, unsigned *order, DT_new &dt, unsigned original_idx ) {
	vector < Point2f > cur_points;
	for ( int j = 0; j < (int) npoints; j++ ) {
		unsigned rr = order[j];
    if ( rr == original_idx ) continue;
		Point_2_new cur_pt_cgal = dt.get_vertex(rr)->point();
		double x = (double) cur_pt_cgal.x();
		double y = (double) cur_pt_cgal.y();
		Point2f cur_pt_cv( x, y );
		if ( cur_pt_cv.x < 0 || cur_pt_cv.x > 1 || cur_pt_cv.y < 0 || cur_pt_cv.y > 1 ) throw std::runtime_error( "OpenCV coordinates out of bounds: check above" );
		cur_points.push_back( cur_pt_cv );
	}
	return cur_points;
}

vector<int> get_point_indices_new( Mat algorithm_counts, vector<Point2f> cur_points ) {
	vector<int> all_indices;
	for (int i = 0; i < (int) cur_points.size(); i++ ) {
		Point2f cur_pt = cur_points[i];
		int rounded_x = round( cur_pt.x * (algorithm_counts.cols-1) );
		if (cur_pt.x == 1) rounded_x = (algorithm_counts.cols-1);
		int rounded_y = round( cur_pt.y * (algorithm_counts.rows-1) );
		if (cur_pt.y == 1) rounded_y = (algorithm_counts.rows-1);
		if ( rounded_x > (algorithm_counts.cols-1) ) {
			throw std::runtime_error( " rounded_x > (algorithm_counts.cols-1) " );
		} else if ( rounded_y > (algorithm_counts.rows-1) ) {
			throw std::runtime_error( " rounded_y > (algorithm_counts.rows-1) " );
		}
		int cur_idx = rounded_x * algorithm_counts.rows + rounded_y;
		all_indices.push_back( cur_idx );
	}
	return all_indices;
}

vector<int> get_stratified_point_indices_new( Mat algorithm_counts, vector<int> point_indices ) {
	vector< double > original_algorithm_counts;
	for( int i = 0; i < (int) point_indices.size(); i++ ) {
		int cur_pt_index = point_indices[i];
		double cur_algorithm_count = algorithm_counts.at< double >( cur_pt_index % algorithm_counts.rows, cur_pt_index / algorithm_counts.rows );
		original_algorithm_counts.push_back( cur_algorithm_count );
	}
	vector< std::pair<double, int> > sorted_algorithm_counts_pair_vector = sort_and_return_indices( original_algorithm_counts );
	vector< int > stratified_point_indices;
	// Look if the values really are correctly sorted after the sort operation
	for( int i = 0; i < algorithm_counts.rows * algorithm_counts.cols; i++ ) {
		for( int j = 0; j < (int) sorted_algorithm_counts_pair_vector.size(); j++) {
			if ( i == sorted_algorithm_counts_pair_vector[j].second ) {
				stratified_point_indices.push_back( j );
				break;
			}
			if ( j == (int) sorted_algorithm_counts_pair_vector.size() ) {
				throw std::runtime_error("The index was not found in the stratified counts array?");
			}
		}
	}
	stratified_point_indices_checks( stratified_point_indices, algorithm_counts );
	Mat stratified_point_indices_mat = cv::Mat::zeros( algorithm_counts.rows, algorithm_counts.cols, CV_64F );
	for ( int i = 0; i < (int) stratified_point_indices.size(); i++ ) {
		int cur_x = i / algorithm_counts.rows;
		int cur_y = i % algorithm_counts.rows;
		stratified_point_indices_mat.at<double>( cur_y, cur_x ) = stratified_point_indices[i];
	}
	return stratified_point_indices_mat;
}

void stratified_point_indices_checks( vector< int > stratified_point_indices, Mat algorithm_counts ) {
	for ( int i = 0; i < (int) stratified_point_indices.size(); i++ ) {
		for ( int j = 0; j < (int) stratified_point_indices.size(); j++ ) {
			if ( i == j ) continue; 
			if ( stratified_point_indices[i] == stratified_point_indices[j] ) throw std::runtime_error("There are multiple instances of the same index!\n");
		}
	}
	for ( int i = 0; i < (int) algorithm_counts.rows * algorithm_counts.cols; i++ ) {
		for ( int j = 0; j < (int) stratified_point_indices.size(); j++ ) {
			if ( i == stratified_point_indices[j] ) break;
			if ( j == (int) stratified_point_indices.size() ) throw std::runtime_error("An index was not found!\n");
		}
	}
	double last_count = -1;
	for ( int i = 0; i < (int) stratified_point_indices.size(); i++ ) {
		// Find index "i" in stratified_point_indices
		for ( int j = 0; j < (int) stratified_point_indices.size(); j++ ) {
			int cur_idx = stratified_point_indices[i];
			if ( cur_idx == i ) {
				int cur_x = cur_idx / algorithm_counts.rows;
				int cur_y = cur_idx % algorithm_counts.rows;
				double cur_count = (int) algorithm_counts.at<double>( cur_y, cur_x );
				if ( cur_count < last_count )  {
					throw std::runtime_error( "The indices do not appear to be sorted correctly!" );
				} else {
					last_count = cur_count;
					break;
				}
			}
			if ( j == (int) stratified_point_indices.size() ) {
				throw std::runtime_error( "Could not find an index!\n" );
			}
		}
	}
}

vector<bool> get_stratified_occupied_locations_new( vector<int> cur_stratified_indices, int total_possible_points ) {
	vector<bool> stratified_point_indices_b( total_possible_points, false );
	for( int i = 0; i < (int) cur_stratified_indices.size(); i++ ) {
		int cur_stratified_idx = cur_stratified_indices[i];
		if (cur_stratified_idx >= 0)
			stratified_point_indices_b[cur_stratified_idx] = true;
	}
	return stratified_point_indices_b;
}

vector< Point2f > get_circle_coordinates_new( vector<Circle_2_new> list_of_circles ) {
	vector< Point2f > circle_centers;
	for( int i = 0; i < (int) list_of_circles.size(); i++) {
		Circle_2_new cur_circle = list_of_circles[i];
		Point_2_new org_pt = cur_circle.center();
		Point2f cur_pt( org_pt.x(), org_pt.y() );
		circle_centers.push_back( cur_pt );
	}
	return circle_centers;
}

vector< double > get_average_distance_for_possible_points_new( vector< bool > stratified_point_indices_b, vector< int > cur_stratified_circumcircle_point_indices  ) {
	vector< double > all_min_distances;
	for ( int i = 0; i < (int) cur_stratified_circumcircle_point_indices.size(); i++ ) {
		int cur_stratified_idx = cur_stratified_circumcircle_point_indices[i];
		double min_distance = (double) stratified_point_indices_b.size();
		int left_search_idx = cur_stratified_idx;
		int right_search_idx = cur_stratified_idx+1;
		while ( left_search_idx >= 0 ) {
			if ( stratified_point_indices_b[left_search_idx] == true ) {
				double cur_distance = abs( left_search_idx - cur_stratified_idx );
				if ( cur_distance < min_distance ) {
					min_distance = cur_distance;
					break;
				}
			}
			left_search_idx--;
		}
		while ( right_search_idx < (int) stratified_point_indices_b.size() ) {
			if ( stratified_point_indices_b[right_search_idx] == true ) {
				double cur_distance = abs( right_search_idx - cur_stratified_idx );
				if ( cur_distance < min_distance ) {
					min_distance = cur_distance;
					break;
				}
			}
			right_search_idx++;
		}
		all_min_distances.push_back( min_distance );
	}
	return all_min_distances;
}

Mat create_opencv_imagesc_of_stratified_distances( vector<double> circumcircle_average_distances, vector<bool> stratified_point_indices_b, vector<double> stratified_distribution_organized_by_spatial_indices, vector< int > circumcircle_point_indices ) {
	// change stratified distribution into cartesian space
	vector<int> best_stratified_indices( stratified_point_indices_b.size(), -1 );
	for ( int cur_distribution_idx = 0; cur_distribution_idx < (int) stratified_distribution_organized_by_spatial_indices.size(); cur_distribution_idx++ ) {
		// organize the points into a mat 
		double cur_stratified_probability = stratified_distribution_organized_by_spatial_indices[cur_distribution_idx];
		int cur_circumcircle_point_index = circumcircle_point_indices[cur_distribution_idx];
		
		int cur_best_distribution_index = best_stratified_indices[cur_circumcircle_point_index];
		bool new_best_idx = false;
		if ( cur_best_distribution_index == -1 ) {
			// this is the best probability at this index
			// set the cartesian array index to this distribution index
			new_best_idx = true;
		} else {
			// compare with the previous best probability at this index
			double cur_stratified_probability_original_best = stratified_distribution_organized_by_spatial_indices[cur_best_distribution_index];
			if ( cur_stratified_probability > cur_stratified_probability_original_best ) {
				// this is the new best
				new_best_idx = true;
			}
		}
		if ( new_best_idx == true ) {
			best_stratified_indices[cur_circumcircle_point_index] = cur_distribution_idx;
		}
	}
	vector< double > optimal_probabilities_in_cartesian_space( stratified_point_indices_b.size(), 0 );
	for( int i = 0; i < (int) best_stratified_indices.size(); i++ ) {
		int cur_best_stratified_index = best_stratified_indices[i];
		optimal_probabilities_in_cartesian_space[i] = stratified_distribution_organized_by_spatial_indices[cur_best_stratified_index];
	}
	// get the max values in each row
	double max_value_stratified_point_indices_b = get_max_value_bool( stratified_point_indices_b );
	double max_value_optimal_probabilities_in_cartesian_space = get_max_value_double( optimal_probabilities_in_cartesian_space );
	double max_value_circumcircle_average_distances = get_max_value_double( circumcircle_average_distances );
	
	// create the mat that imagesc will use
	int height_step = 100;
	int num_rows = 3;
	int temp_desired_width_imagesc_mat = 600;
	int num_columns = stratified_point_indices_b.size();
	int width_step = (int) round( temp_desired_width_imagesc_mat / num_columns );
	Mat imagesc_stratified_mat = cv::Mat::zeros( (int) num_rows, (int) num_columns, CV_8U );
	for ( int i = 0; i < (int) num_columns; i++ ) {
		for (int ii = 0; ii < (int) num_rows; ii++ ) {
			double cur_value = -1, normalizing_value = -1;
			if ( ii == 0 ) {
				cur_value = (double) stratified_point_indices_b[i];
				normalizing_value = (double) 1 / max_value_stratified_point_indices_b;
			} else if ( ii == 1 ) {
				cur_value = (double) optimal_probabilities_in_cartesian_space[i];
				normalizing_value = (double) 1 / max_value_optimal_probabilities_in_cartesian_space;
			} else if ( ii == 2 ) {
				cur_value = (double) circumcircle_average_distances[i];
				normalizing_value = (double) 1 / max_value_circumcircle_average_distances;
			}
			double normalized_value = cur_value > 0 ? cur_value * normalizing_value * 200 + 55 : 0;
			imagesc_stratified_mat.at<uchar>( ii, i ) = (uchar) floor( normalized_value );
		}
	}
	Mat imagesc_stratified_mat_expanded = imagesc_opencv( imagesc_stratified_mat, (int) height_step, (int) width_step );
	return imagesc_stratified_mat_expanded;
}

Mat imagesc_opencv( Mat imagesc_stratified_mat, int row_step, int column_step ) {
	int rows_input = imagesc_stratified_mat.rows;
	int columns_input = imagesc_stratified_mat.cols;
	Mat imagesc_stratified_mat_expanded = cv::Mat::zeros( (int) row_step*rows_input, (int) column_step*columns_input, CV_8U );
	for ( int cur_row_index = 0; cur_row_index < rows_input; cur_row_index++ ) {
		for ( int cur_column_index = 0; cur_column_index < columns_input; cur_column_index++ ) {
			uchar cur_value = imagesc_stratified_mat.at<uchar>( cur_row_index, cur_column_index );
			for ( int j = 0; j < (int) row_step; j++ ) {
				for ( int k = 0; k < (int) column_step; k++ ) {
					int image_y_cord = cur_row_index * row_step + j;
					int image_x_cord = cur_column_index * column_step + k;
					imagesc_stratified_mat_expanded.at<uchar>( image_y_cord, image_x_cord ) = cur_value;
				}
			}
		}
	}
	return imagesc_stratified_mat_expanded;
}

double get_max_value_double( vector<double> input_vector ) {
	double max_value = -1, cur_value = -1;
	for ( int i = 0; i < (int) input_vector.size(); i++ ) {
		cur_value = (double) input_vector[i];
		if ( (double) cur_value > max_value ) max_value = cur_value;
	}
	return max_value;
}

double get_max_value_bool( vector<bool> input_vector ) {
	double max_value = -1, cur_value = -1;
	for ( int i = 0; i < (int) input_vector.size(); i++ ) {
		cur_value = (double) input_vector[i];
		if ( (double) cur_value > max_value ) max_value = cur_value;
	}
	return max_value;
}

double get_max_value_int( vector<int> input_vector ) {
	double max_value = -1, cur_value = -1;
	for ( int i = 0; i < (int) input_vector.size(); i++ ) {
		cur_value = (double) input_vector[i];
		if ( (double) cur_value > max_value ) max_value = cur_value;
	}
	return max_value;
}

vector<double> create_stratified_distribution_new( int length_of_spatial_samples ) {
	vector<double> stratified_distribution( length_of_spatial_samples, 0.0 );
	int last_point = floor( (double) length_of_spatial_samples / 3 );
	double cur_value = 0, total_value = 0;
	for ( int i = 0; i <= last_point; i++ ) {
		cur_value = pow( last_point - i + 1, 3 );
		stratified_distribution[i] = cur_value;
		total_value += cur_value;
	}
	for ( int i = 0; i <= last_point; i++ ) {
		stratified_distribution[i] = stratified_distribution[i] / total_value;
	}
	return stratified_distribution;
}

vector<int> get_all_stratified_indices( Mat valid_counts, Mat algorithm_counts ) {
	vector<int> all_stratified_indices( valid_counts.rows*valid_counts.cols, -1.0 );
	// for every index in both mats
	vector<double> valid_algorithm_counts_to_sort;
	vector<int> farm_indices_for_valid_indices;
	for ( int i = 0; i < valid_counts.rows*valid_counts.cols; i++ ) {
		// if valid: then setup for sorting with algorithm_counts value
		int cur_y_idx = i % valid_counts.rows;
		int cur_x_idx = i / valid_counts.rows;
		if ( valid_counts.at<double>(cur_y_idx, cur_x_idx) == 1.0 ) {
			// also keep track of the corresponding original index for every valid idx
			valid_algorithm_counts_to_sort.push_back( algorithm_counts.at<double>(cur_y_idx, cur_x_idx) );
			farm_indices_for_valid_indices.push_back( i );
		}
		// if invalid: leave out of array to be sorted
	}
	// sort all possible values
	vector < pair < double, int > > sorted_valid_algorithm_counts = sort_and_return_indices( valid_algorithm_counts_to_sort );
	// start with array of length farm plot indices of all -1 values
	// for i in sorted list:
	int total_valid = (int) sum(valid_counts)[0];
	double last_count = 0;
	for (int i = 0; i < (int) sorted_valid_algorithm_counts.size(); i++ ) {
		// get the corresponding possible index
		int cur_stratified_idx = i;
		double cur_value = sorted_valid_algorithm_counts[i].first;
		int original_possible_idx = sorted_valid_algorithm_counts[i].second;
		if ( original_possible_idx < 0 || original_possible_idx > total_valid ) throw runtime_error("invalid indices: out of range");
		if (cur_value < last_count ) throw runtime_error("indices are not sorting correctly");
		last_count = cur_value;
		int original_farm_plot_idx = farm_indices_for_valid_indices[original_possible_idx];
		all_stratified_indices[original_farm_plot_idx] = cur_stratified_idx;
	}
	return all_stratified_indices;
}

vector < pair < double, int > > sort_and_return_indices( vector<double> input_vector ) {
	vector < pair < double, int > > input_vector_with_indices;
	for ( int i = 0; i < (int) input_vector.size(); i++ ) {
		pair< double, int > cur_pair = pair< double, int >( input_vector[i], i );
		input_vector_with_indices.push_back( cur_pair );
	}
	sort( input_vector_with_indices.begin(), input_vector_with_indices.end() );
	return input_vector_with_indices;
}

template <class T> vector< pair< T, int > > sort_and_return_indices_specified_function( vector< T > input_array_of_elements, bool (*pt2Func)(pair<T, int>, pair<T, int>) ) {
	// move input_array_of_elements to a vector that records the starting indices as well 
	vector< pair< T, int > > input_array_of_elements_with_indices;
	for (int i = 0; i < (int)input_array_of_elements.size(); i++ ) {
		pair<T, int> cur_pair_to_add( input_array_of_elements[i], i );
		input_array_of_elements_with_indices.push_back( cur_pair_to_add );
	}
	sort( input_array_of_elements_with_indices.begin(), input_array_of_elements_with_indices.end(), pt2Func );
	return input_array_of_elements_with_indices;
}
template vector< pair< Circle_2_new, int > > sort_and_return_indices_specified_function<Circle_2_new>( vector< Circle_2_new > input_array_of_elements, bool (*pt2Func)( pair<Circle_2_new, int>, pair<Circle_2_new, int>) );
