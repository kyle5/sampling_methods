template <typename T> double getAverage( std::vector<T> counts_input ) {
	// get average count
	if ((int) counts_input.size() == 0) return 0;
	T total = 0;
	for ( int ii = 0; ii < (int) counts_input.size(); ii++ ) {
		total += counts_input[ii];
	}
	return (double) total / (double) counts_input.size();
}

template <typename T> double getAverageArray( T *counts_input, int array_size ) {
	// get average count
	if ((int) array_size == 0) return 0;
	T total = 0;
	for ( int ii = 0; ii < array_size; ii++ ) {
		total += counts_input[ii];
	}
	return (double) total / (double) counts_input.size();
}
