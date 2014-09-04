opencv_link_args=" -L /opt/ros/fuerte/lib/ -l opencv_core -l opencv_highgui"
cgal_link_args="-L /usr/local/lib/CGAL/ -l CGAL -l gmp"

g++ -shared -fPIC -I .. -I ../../farthest_point_stratified_yield_and_spatial/ -I/opt/ros/fuerte/include/ -Wall -frounding-math -o libget_points.so ../DT.cpp ../../farthest_point_stratified_yield_and_spatial/get_rp_helper_functions.cpp ../get_random_points.cpp ${cgal_link_args} ${opencv_link_args}
