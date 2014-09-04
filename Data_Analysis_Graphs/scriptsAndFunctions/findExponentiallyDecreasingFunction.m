function [ fh, P ] = findExponentiallyDecreasingFunction(all_sections, cur_percentage_mean_error_computer_count)

        fh = @(x,p) p(1) + p(2)*exp(-x./p(3));
      errfh = @(p,x,y) sum((y(:)-fh(x(:),p)).^2);
      p0 = [mean(cur_percentage_mean_error_computer_count) ...
          (max(cur_percentage_mean_error_computer_count)-min(cur_percentage_mean_error_computer_count))...
          (max(all_sections) - min(all_sections))/2];
      P = fminsearch(errfh,p0,[],all_sections,cur_percentage_mean_error_computer_count);

end