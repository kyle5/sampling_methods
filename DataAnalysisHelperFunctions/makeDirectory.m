function [ path_str ] = makeDirectory( list_of_directory_path )
    path_str = '';
    f_slash = '/';
    number_of_directories = numel(list_of_directory_path);
    for i = 1:number_of_directories
        current_str = list_of_directory_path{i};
        path_str = strcat(path_str, current_str, f_slash);
    end
    mkdir(path_str);
end