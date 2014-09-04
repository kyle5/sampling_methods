// inputs: (Field size) Mat of some values, (Nx1) Mat of index values, num_adjusted_indices
// outputs: outer vector corresponding to num_adjusted_indices and inner vector corresponding to the actual indices

#include "create_adjusted_indices.h"

#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

using namespace std;
using namespace cv;

vector< vector< int > > create_adjusted_indices( Mat mat_of_size_field_data, Mat original_optimal_indices, int num_adjusted_indices, double distance_to_alter_indices, double percentage_of_indices_to_alter, int count_variable ) {
	srand( (unsigned int) (count_variable) );
	fprintf( stderr, "In create_adjusted_indices\n");
	vector< vector< int > > all_adjusted_indices( num_adjusted_indices );
	for ( int i = 0; i < num_adjusted_indices; i++ ) {
		vector<int> current_adjusted_indices = adjust_indices_one_iteration( mat_of_size_field_data, original_optimal_indices, distance_to_alter_indices, percentage_of_indices_to_alter );
		all_adjusted_indices[i] = current_adjusted_indices;
	}

	bool all_first_are_empty = true;
	for(int i = 0; i < max( ((double)10), (double) all_adjusted_indices.size() ); i++ ) {
		if ( all_adjusted_indices[i].size() > 0 ) {
			all_first_are_empty = false;
		}
	}

	if ( (int) all_adjusted_indices.size() > 1000 && all_first_are_empty ) {
		throw std::runtime_error( "The indexing is almost certainly wrong");
	} else if ( (int) all_adjusted_indices.size() > 1000 ) {
		throw std::runtime_error( "Only: all_adjusted_indices.size() > 1000" );
	}
	return all_adjusted_indices;
}

vector < int > adjust_indices_one_iteration( Mat mat_of_size_field_data, Mat original_optimal_indices, double distance_to_alter_indices, double percentage_of_indices_to_alter ) {
	fprintf( stderr, "In adjust_indices_one_iteration\n");
	Mat indices_occupied = Mat::zeros( (int) mat_of_size_field_data.rows, (int) mat_of_size_field_data.cols, CV_8U );
	int mat_rows = indices_occupied.rows;
	int mat_columns = indices_occupied.cols;
	setup_indices_boolean( indices_occupied, original_optimal_indices );
	//
	for(int i = 0; i < original_optimal_indices.rows; i++ ) { 
		double temp = 1000;
		bool valid_point_to_move = ( (int) rand() % (int) temp ) > round( (double) temp * percentage_of_indices_to_alter );
		if ( valid_point_to_move ) {
			int cur_index_to_set = (int) round( original_optimal_indices.at<double>( i, 0 ) );
			int cur_pt_row = cur_index_to_set % mat_rows;
			int cur_pt_column = cur_index_to_set / mat_rows;
			
			double rand_y = (double) ( ((int) rand())  % 11 ) / 10;
			double rand_x = (double) ( ((int) rand())  % 11 ) / 10;
			int y_delta = (int) round( distance_to_alter_indices*( rand_y ) - distance_to_alter_indices/2 );
			int x_delta = (int) round( distance_to_alter_indices*( rand_x ) - distance_to_alter_indices/2 );
			
			int altered_cur_pt_row = cur_pt_row+y_delta;
			int altered_cur_pt_column = cur_pt_column+x_delta;
			if ( altered_cur_pt_row > (mat_rows-1) || altered_cur_pt_row < 0 || altered_cur_pt_column > (mat_columns-1) || altered_cur_pt_column < 0 ) continue;
			else if ( indices_occupied.at<uchar>( altered_cur_pt_row, altered_cur_pt_column ) == 0 ) {
				indices_occupied.at<uchar>( cur_pt_row, cur_pt_column ) = 0;
				indices_occupied.at<uchar>( altered_cur_pt_row, altered_cur_pt_column ) = 1;
			}
		}
	}
	vector< int > non_zero_indices_vector = myFindNonZero( indices_occupied );
	fprintf( stderr, "returning from adjust_indices_one_iteration\n");
	return non_zero_indices_vector;
}

void setup_indices_boolean( Mat &indices_occupied, const Mat &original_optimal_indices ) {
	int mat_rows = indices_occupied.rows;
	for(int i = 0; i < original_optimal_indices.rows; i++ ) {
		int cur_index_to_set = (int) round( original_optimal_indices.at<double>( i, 0 ) );
		indices_occupied.at<uchar>( cur_index_to_set % mat_rows, cur_index_to_set / mat_rows ) = 1;
	}
}

vector<int> myFindNonZero( Mat indices_occupied ) {
	vector<int> non_zero_indices;
	int index_count = 0;
	for( int j = 0; j < indices_occupied.cols; j++ ) {
		for( int i = 0; i < indices_occupied.rows; i++ ) {
			uchar cur_value = indices_occupied.at<uchar>( i, j );
			if (cur_value > 0) non_zero_indices.push_back( index_count );
			index_count++;
		}
	}
	return non_zero_indices;
}
