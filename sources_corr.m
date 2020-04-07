%============================================================================ 
% Function name.: sources_corr
% Date..........: April 11, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Calculates the correlation between two source calculations.
%
% Parameters....: 
%                 source1.-> source type struct in the fieldtrip format. It
%                            must have the same number of sources and
%                            dimensions as the other, for comparison.
%                 source2.-> source type struct in the fieldtrip format. It
%                            must have the same number of sources and
%                            dimensions as the other, for comparison.
%                 pow......> optional input: logical flag specifying if the
%                            correlation will be calculated for each of the
%                            dimentions of the sources or just for the power
%                            values.
%                            Default: 0.
% Return........:
%                 correlation.-> values of correlation for all dimensions of
%                                each source point.
%============================================================================ 

function correlation = sources_corr(source1, source2, pow)

%============================================================================
%% Manage inputs
if nargin ~= 3
	pow = 0;
end
%============================================================================
%% Check sizes
if length(source1.avg.mom) ~= length(source2.avg.mom)
	disp('Unequal number of source points');
	return;
end
if size(source1.avg.mom{1}) ~= size(source1.avg.mom{1})
	disp('Unequal number of dimensions or unequal time duration');
	return;
end

n_sources = length(source1.avg.mom);
dim = size(source1.avg.mom{1}, 1);
%============================================================================
%% Calculate correlation
if pow
	correlation = nan(n_sources, 1);
	for i = 1:n_sources
        if sum(source1.avg.pow(i,:)) == 0 || sum(source2.avg.pow(i,:)) == 0
            source1.avg.pow(i,:) = source1.avg.pow(i,:) + 0.1;
            source2.avg.pow(i,:) = source2.avg.pow(i,:) + 0.1;
        end
	    r = corrcoef(source1.avg.pow(i,:), source2.avg.pow(i,:));
	    correlation(i, 1) = r(1,2);
	end
else
	correlation = nan(n_sources, dim);
	for i = 1:n_sources
	    for j = 1:dim
            if sum(source1.avg.mom{i}(j,:)) == 0 || sum(source2.avg.mom{i}(j,:)) == 0
                source1.avg.mom{i}(j,:) = source1.avg.mom{i}(j,:) + 0.1;
                source2.avg.mom{i}(j,:) = source2.avg.mom{i}(j,:) + 0.1;
            end
	    	r = corrcoef(source1.avg.mom{i}(j,:), source2.avg.mom{i}(j,:));
	    	correlation(i, j) = r(1,2);
	    end
	end
end
%============================================================================ 

end