#include "setup_counts_from_sections.h"

// temp
#include <cstdio>

using namespace std;
using namespace cv;

std::pair< vector<int>, vector<int> > setup_counts_from_sections( Mat algorithm_counts_mat, Mat groundtruth_counts_mat, std::pair< vector<int>, vector<int> > indices_ground_and_algorithm ) {

	std::pair< vector<int>, vector<int> > counts_ground_and_algorithm;
	vector< int > ground_counts;
	vector< int > algorithm_counts;
	
	vector< int > indices_ground_counts = indices_ground_and_algorithm.first;
	vector< int > indices_algorithm_counts = indices_ground_and_algorithm.second;
	
	double *groundtruth_counts_mat_data_ptr = (double *) groundtruth_counts_mat.data;
	for (int i = 0; i < indices_ground_counts.size(); i++) {
		int cur_ground_count = (int) groundtruth_counts_mat_data_ptr[i];
		ground_counts.push_back( cur_ground_count );
	}
	
	double *algorithm_counts_mat_data_ptr = (double *) algorithm_counts_mat.data;
	for (int i = 0; i < indices_algorithm_counts.size(); i++) {
		int cur_algorithm_count = (int) algorithm_counts_mat_data_ptr[i];
		algorithm_counts.push_back( cur_algorithm_count );
	}
	counts_ground_and_algorithm = make_pair( ground_counts, algorithm_counts );
	return counts_ground_and_algorithm;
}
