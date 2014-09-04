#ifndef __GET_OPTIMAL_SAMPLING_SECTIONS_ONE_SAMPLE
#define __GET_OPTIMAL_SAMPLING_SECTIONS_ONE_SAMPLE

#include <opencv2/core/core.hpp>
#include <vector>
using std::vector;

std::pair< std::pair< vector<cv::Point2f>, vector < int > >, std::pair< vector< vector< double > >, vector< vector< double > > > > get_optimal_sampling_sections_one_sample( cv::Mat algorithm_counts, int cur_sampling_number, int spatial_and_stratified, double weight_spatial );

#endif
