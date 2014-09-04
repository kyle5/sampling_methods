#ifndef __GET_RANDOM_POINTS_H__
#define __GET_RANDOM_POINTS_H__


#include <algorithm>
#include <signal.h>
#include <sstream>
#include <time.h>
#include <unistd.h>
#include "DT.h"
#include "util.h"

#include <opencv2/core/core.hpp>

enum Strategy {
    GLOBAL, LOCAL, HYBRID
};
static bool interruptFlag = false;
void generate_random(vector<Point_2> &points, unsigned npoints, MTRand &rng);
void generate_darts(vector<Point_2> &points, unsigned npoints, MTRand &rng);
void update_statistics(const DT &dt, unsigned it, double &global_md, double &avg_md, bool output = true);
static void sighandler(int sig);
void usage();
vector<cv::Point2f> get_random_points( unsigned max_iter, double max_md, Strategy strategy, bool silent, unsigned npoints, unsigned long seed, cv::Mat valid_counts );

#endif
