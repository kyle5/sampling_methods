#ifndef __GET_RANDOM_POINTS_new_H__
#define __GET_RANDOM_POINTS_new_H__

#include <algorithm>
#include <signal.h>
#include <sstream>
#include <time.h>
#include <unistd.h>
#include "DT_new.h"
#include "util_new.h"

// additional headers
#include <iostream>
#include <utility>
#include <stdexcept>
#include <opencv2/core/core.hpp>

enum Strategy_new {
    GLOBAL_NEW, LOCAL_NEW, HYBRID_NEW
};
static bool interruptFlag_new = false;
void generate_random_new( std::vector<Point_2_new> &points, unsigned npoints, MTRand &rng );
void generate_darts_new( std::vector<Point_2_new> &points, unsigned npoints, MTRand &rng );
void update_statistics_new( const DT_new &dt, unsigned it, double &global_md, double &avg_md, bool output = true );
std::vector < std::pair < double, int > > sort_and_return_indices( std::vector<double> input_vector );
static void sighandler(int sig) {
    std::cout << "Aborting...\n";
    interruptFlag_new = true;
}
void usage_new();
std::pair< std::pair< vector<cv::Point2f>, vector<int> >, std::pair< vector< vector< double > >, vector< vector< double > > > > get_random_points_new( unsigned max_iter, double max_md, Strategy_new strategy, bool silent, unsigned npoints, unsigned long seed, cv::Mat algorithm_counts, double weight_spatial );
void circumference_check( vector< Circle_2_new > list_of_circles );

#endif
