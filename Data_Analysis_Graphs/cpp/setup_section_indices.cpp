// setup_section_indices.cpp

#include "setup_section_indices.h"

// temp
#include <cstdio>

using namespace std;
using namespace cv;

std::pair< vector<int>, vector<int> > setup_section_indices( vector<double> all_algorithm_counts_vec, string error_calc_type, int cur_sections_algorithm_counted, int cur_hand_sampled_number, int total_sections ) {
	
	std::pair< vector<int>, vector<int> > indices_ground_and_algorithm;	
	int sections_hand_sampled[cur_hand_sampled_number];
	int sections_sampled_by_algorithm[cur_sections_algorithm_counted];
	vector<int> sections_hand_sampled_vec;
	vector<int> sections_sampled_by_algorithm_vec;
	// Kyle: TODO: if ( strcmp( error_calc_type.c_str(), "RANDOM" ) == 0 || strcmp( error_calc_type.c_str(), "STRATIFIED" ) == 0 ) {
	if ( strcmp( error_calc_type.c_str(), "RANDOM" ) == 0 ) {
		for (int m = 0; m < cur_sections_algorithm_counted; m++) {
			int random_variable = std::rand();
			sections_sampled_by_algorithm[m] = random_variable % total_sections;
		}
		for (int m = 0; m < cur_hand_sampled_number; m++) {
			if ( m < cur_sections_algorithm_counted ) {
				sections_hand_sampled[m] = sections_sampled_by_algorithm[m];
			} else {
				int random_variable = std::rand();
				sections_hand_sampled[m] = random_variable % total_sections;
			}
		}
		if ( cur_hand_sampled_number > 0 && cur_sections_algorithm_counted > 0 ) {
			vector<int> sections_hand_sampled_vec_temp(sections_hand_sampled, sections_hand_sampled + sizeof(sections_hand_sampled) / sizeof(sections_hand_sampled[0]));
			vector<int> sections_sampled_by_algorithm_vec_temp(sections_sampled_by_algorithm, sections_sampled_by_algorithm + sizeof(sections_sampled_by_algorithm) / sizeof(sections_sampled_by_algorithm[0]));
			sections_hand_sampled_vec = sections_hand_sampled_vec_temp;
			sections_sampled_by_algorithm_vec = sections_sampled_by_algorithm_vec_temp;
		}
	} else if (strcmp( error_calc_type.c_str(), "STRATIFIED" ) == 0) {
		// Can either get the counts here or in the computeAlgorithmEstimateErrorValues.cpp code
		for (int m = 0; m < cur_sections_algorithm_counted; m++) {
			int random_variable = std::rand();
			sections_sampled_by_algorithm[m] = random_variable % total_sections;
		}
		// Get the lowest yielding counts from all_algorithm_counts_vec
	} else if (strcmp( error_calc_type.c_str(), "SPATIAL" ) == 0) {
		// Need to get the optimal spatial arrangement specified by the optimal spatial arrangements vector
			// should be row and column indices
	} else {
		// Assume: error_calc_type = string( "STDEV" );
	}
	indices_ground_and_algorithm = make_pair( sections_hand_sampled_vec, sections_sampled_by_algorithm_vec );
	return indices_ground_and_algorithm;
}
