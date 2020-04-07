%============================================================================ 
% Function name.: sources_emd
% Date..........: February 11, 2019
% Author........: Eric F Schmiele
%                 (eric.robotic@gmail.com)
% Description...:
%                 Calculates the earth mover's distance between two source
%                 calculations considering only sources with significant
%                 signal since a total calculation would cost too much
%                 computationaly.
%
% Parameters....: 
%                 source1.-> source type struct in the fieldtrip format. It
%                            must have the same number of sources and
%                            dimensions as the other, for comparison.
%                 source2.-> source type struct in the fieldtrip format. It
%                            must have the same number of sources and
%                            dimensions as the other, for comparison.
%                 min_val.-> optional input: minimal value for the percentage
%                            of the total average signal that is to be
%                            considered as a source of interest.
%                            Default: 1.5.
% Return........:
%                 emd_dist.-> emd distance.
%============================================================================ 

function emd_dist = sources_emd(source1, source2, min_val)

%============================================================================
%% Manage inputs
if nargin ~= 3
    min_val = 1.5;
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

n_samples = size(source1.avg.pow, 2);
%============================================================================
%% Main sources
mains1 = find(mean(source1.avg.pow, 2) >= min_val*mean(mean(source1.avg.pow, 2)));
mains2 = find(mean(source2.avg.pow, 2) >= min_val*mean(mean(source2.avg.pow, 2)));
%============================================================================
%% Main sources positions and values
w_source1 = source1.avg.pow(mains1,:);
w_source2 = source2.avg.pow(mains2,:);
for i = 1:size(w_source1, 2)
    w_source1(:,i) = w_source1(:,i)/sum(w_source1(:,1));
    w_source2(:,1) = w_source2(:,1)/sum(w_source2(:,1));
end
pos_source1 = source1.pos(mains1,:);
pos_source2 = source2.pos(mains2,:);
%============================================================================
%% Calculate distances
% for i = 1:mains
% 	for j = 1:mains
% 		D(i,j) = norm(pos_source1(i,:) - pos_source2(j,:));
% 	end
% end
%============================================================================
%% Calculate emd
for i = 1:n_samples
    disp(strcat('Sample', 32, num2str(i), 32, 'out of', 32, num2str(n_samples)));
	emd_dist(:,i) = emd(pos_source1, pos_source2, w_source1(:,i), w_source2(:,i));
end
%============================================================================ 

end