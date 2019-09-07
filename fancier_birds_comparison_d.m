function [means,stdevs] = fancier_birds_comparison_d(iterations,drates)
% results = fancier_birds_comparison_d(iterations,drates)
%
% Last revised 7/27/11, 11:16pm
%
% This script runs fancier_birds.m many times to compare average results.
% Also prints progress to screen so you know it's still running.
% Each realization is run for 3700 days, with the initial condition H0=200.
% Also runs for different d values
%
% Inputs:
% iterations ~ number of times to run each version of the script (must be > 1)
%
% Outputs:
% means ~ matrix holding the average results of all iterations
% stdevs ~ matrix holding the standard deviations of all iterations

% Script parameters:
outputs = 18; % number of outputs produced by fancy_birds.m
loop_results = zeros(iterations,outputs); % matrix to hold results from each iteration
means = zeros(length(drates),outputs); % average results for each d
stdevs = zeros(length(drates),outputs);
loops = iterations * length(drates); % total loops that will be run
counter = 0; % current loop number

% fancy_birds.m parameters:
tf = 3700;
H0 = 200;

tic; % Start stopwatch
for i = 1:length(drates) % For each d value...
	for j = 1:iterations % For each iteration...
		loop_results(j,:) = fancier_birds_d(tf,H0,drates(i),0); % Run fancier_birds_d.m and record the results
        counter = counter + 1;
        percent_completion = 100 * (counter / loops) % Print the percent completion
	end
	if (iterations > 1)
		means(i,:) = mean(loop_results); % Average the results for every iteration for that sigma value
		stdevs(i,:) = std(loop_results);
	else
		means(i,:) = loop_results; % Don't average them if you're only running one iteration
	end
end
toc % Print the total elapsed time