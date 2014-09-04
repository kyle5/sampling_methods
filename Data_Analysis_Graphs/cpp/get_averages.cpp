#include "get_averages.h"

// temp
#include <cstdio>

double getAverage( std::vector<double> counts_input ) {
	// get average count
	if ((int) counts_input.size() == 0) return 0;
	double total = 0;
	for ( int ii = 0; ii < (int) counts_input.size(); ii++ ) {
		total += counts_input[ii];
	}
	return (double) total / (double) counts_input.size();
}

double getAverageArray( double *counts_input, int array_size ) {
	// get average count
	if ((int) array_size == 0) return 0;
	double total = 0;
	for ( int ii = 0; ii < array_size; ii++ ) {
		total += counts_input[ii];
	}
	return (double) total / (double) array_size;
}

