// This is a seperate function to test the ability of linking to the get_random_points method 

#include <opencv2/core/core.hpp>
#include "get_random_points_new.h"

using namespace cv;
using namespace std;

int main() {
	
	Mat algorithm_counts = Mat::zeros( 4, 4, CV_64F );
	double arr[16] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};
	double *algorithm_counts_data_ptr = (double *) algorithm_counts.data;
	for( int i = 0; i < 16; i++ ) {
		algorithm_counts_data_ptr[i] = arr[i];
	}
	
	cout << algorithm_counts << endl << endl;
	
	std::pair< vector<cv::Point2f>, std::pair< vector< vector< double > >, vector< vector< double > > > > all_random_points_results = get_random_points_new( 20, 0.925, GLOBAL, false, 400, 0, algorithm_counts );
	return 1;
}
