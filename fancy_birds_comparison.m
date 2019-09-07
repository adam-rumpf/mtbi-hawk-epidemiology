function [means,stdevs] = fancy_birds_comparison(iterations,sigmas)
% results = fancy_birds_comparison(iterations,sigmas)
%
% Last revised 7/24/11, 7:47pm
%
% This script runs fancy_birds.m many times to compare average results for various sigma values.
% Also prints progress to screen so you know it's still running.
% Each realization is run for 3700 days, with initial conditions H0=200, S0=200, I0=100, R0=0.
%
% Inputs:
% iterations ~ number of times to run each version of the script
% sigmas ~ vector of sigma values to try
% 	ex. use sigmas = [0.1:0.1:0.9] to try values from 0.1 to 0.9 in increments of 0.1
% 	remember that negative values default to ~0.35
%
% Outputs:
% means ~ matrix holding the average results of all iterations for each sigma value
% stdevs ~ matrix holding the standard deviations of all iterations for each sigma value

% Script parameters:
outputs = 12; % number of outputs produced by fancy_birds.m
loop_results = zeros(iterations,outputs); % matrix to hold results from each iteration
means = zeros(length(sigmas),outputs); % average results for each sigma
stdevs = zeros(length(sigmas),outputs);
loops = iterations * length(sigmas); % total loops that will be run
counter = 0; % current loop number

% fancy_birds.m parameters:
evf = 1000000;
tf = 3700;
H0 = 200;
S0 = 200;
I0 = 100;
R0 = 0;

tic; % Start stopwatch
for i = 1:length(sigmas) % For each sigma value...
	for j = 1:iterations % For each iteration...
		loop_results(j,:) = fancy_birds(evf,tf,H0,S0,I0,R0,sigmas(i),0); % Run fancy_birds.m and record the results
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