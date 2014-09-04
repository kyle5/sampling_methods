#include "get_random_points.h"
#include "get_random_points_new_object_model.h"
#include "get_optimal_sampling_sections_one_sample.h"
#include "get_rp_helper_functions.h"

#include <opencv2/core/core.hpp>
#include <vector>

using namespace std;
using namespace cv;

typedef vector< vector< double > > v_o_d;
typedef vector< cv::Point2f > v_p2f;
typedef cv::Mat mat;
typedef std::pair< v_p2f, vector< int > > one_type;
typedef std::pair< v_o_d, v_o_d > two_type;

// Set flag for either (spatial-stratified indices) or (purely spatial sampling)

std::pair< one_type, two_type > get_optimal_sampling_sections_one_sample( Mat algorithm_counts, int cur_sampling_number, int spatial_and_stratified, double weight_spatial ) {
	// setup the initial locations
	int number_to_sample = cur_sampling_number;
	// Below is why I get 2 points, when I attempt to sample 1...
	if( number_to_sample < 2) number_to_sample = 2;
	
	std::vector< cv::Point2f > pts_ret;
	std::pair< one_type, two_type > pts_indices_and_probabilities;
	
	if ( spatial_and_stratified > 0 ) {
		fprintf( stderr, "stratified and spatial : optimal points computation\n" );
		SamplingObjectModel sampling_object_model;
		// compute the indices and the probabilities
		sampling_object_model.get_random_points_new( 50, 0.925, SamplingObjectModel::GLOBAL_NEW, false, number_to_sample, 0, algorithm_counts, weight_spatial );
		// get the resulting points
		vector< vector< int > > indices_at_each_iteration_in_spatial_space = get_indices_at_each_iteration_in_spatial_space(  );
		
		// get the resulting probabilities
		vector< vector< double > > spatial_probability_in_spatial_space = get_spatial_probability_in_spatial_space(  );
		vector< vector< double > > stratified_probability_in_spatial_space = get_stratified_probability_in_spatial_space(  );
		vector< vector< double > > combined_stratified_and_spatial_probability_in_spatial_space = get_combined_stratified_and_spatial_probability_in_spatial_space(  );
		
		// get the resulting stratified indices
		vector< vector< int > > distribution_indices_in_spatial_space = get_distribution_indices_in_spatial_space(  );
		vector< double > stratified_indices_organized_by_spatial_indices = get_stratified_indices_organized_by_spatial_indices(  );
		vector< vector< double > > spatial_distance_in_spatial_space = get_spatial_distance_in_spatial_space(  );
		vector< vector< double > > stratified_distance_in_spatial_space = get_stratified_distance_in_spatial_space(  );

	} else {
		fprintf( stderr, "Purely spatial : optimal points computation\n" );
		
		std::vector< cv::Point2f > pts;
		pts = get_random_points( 50, 0.925, GLOBAL, false, number_to_sample, 0 );
		pts_ret = pts;
		
		vector< vector<double> > prob_spatial, prob_stratified;
		vector<int> all_point_indices; for (int i = 0; i < algorithm_counts.rows*algorithm_counts.cols; i++ ) { all_point_indices.push_back( i ); }
		Mat stratified_point_indices_mat_ret = get_stratified_point_indices_new( algorithm_counts, all_point_indices );
		std::pair< vector<Point2f>, Mat> pts_and_indices = std::pair < vector < Point2f >, Mat > ( pts_ret, stratified_point_indices_mat_ret );
		std::pair< vector< vector< double> >, vector< vector< double> > > probabilities = std::pair< vector< vector< double> >, vector< vector< double> > > ( prob_spatial, prob_stratified );
		
		std::pair< std::pair< vector<cv::Point2f>, cv::Mat >, std::pair< vector< vector< double > >, vector< vector< double > > > > 	pts_indices_and_probabilities = std::pair< std::pair< vector<cv::Point2f>, cv::Mat >, std::pair< vector< vector< double > >, vector< vector< double > > > > ( pts_and_indices, probabilities);
	}
	
	return pts_indices_and_probabilities;
}
