function results = fancy_birds_beta(evf,tf,H0,S0,I0,R0,b,flag)
% results = fancy_birds_beta(evf,tf,H0,S0,I0,R0,b,flag)
%
% Last revised 7/26/11, 8:45pm
%
% Runs a Markov process on a hawk population that consumes infected dove meat.
%
% Inputs:
% evf ~ maximum number of events
% tf ~ maximum number of days
% H0 ~ initial adult hawks
% S0 ~ initial susceptible fledgelings
% I0 ~ initial infected fledgelings
% R0 ~ initial recovered fledgelings
% b ~ birth rate (use a negative value to default to ~0.009)
% flag ~ whether to create a plot
%
% Outputs:
% results ~ a vector containing the following totals from the simulation:
%   total birth events
%   total infection events
%   total recovery events
%   total susceptible natural death events
%   total infected natural death events
%   total recovered natural death events
%   total infected disease death events
%   total susceptible aging events
%   total recovered aging events
%   total adult death events
%   total immigration events
%   mean annual growth

% Parameters:
muH = 1 / (365*5); % natural adult deaths
muj = 0.36 / (365*2); % natural baby deaths
d = 0.41 / 40; % disease death rate based on our research
lambda = 1; % adult hawk immigration rate
if (b < 0)
	b = (3.44 / 365 / 2) * (2/3) * 0.835;
end
delta = 8.9; % food brought in per adult hawk
doveprob = 0.83; % fraction of food that is doves
sigma = 0.38*0.14 + 0.47*0.5 + 0.15*0.9; % dove infection rate based on our research
rho = (1/3)*(1/10); % chance that you get infected from eating infected food
gamma = 0.59 / 40; % recovery rate
alpha = 1 / (365*2); % fledgeling -> adult conversions per hawk
ifood = delta * doveprob * rho * sigma; % overall chance of getting infected from food every day

% Event totals:
btot = 0; % total birth events
itot = 0; % total infection events
rtot = 0; % total recovery events
sntot = 0; % total susceptible natural death events
intot = 0; % total infected natural death events
rntot = 0; % total recovered natural death events
idtot = 0; % total infected disease death events
satot = 0; % total susceptible aging events
ratot = 0; % total recovered aging events
hntot = 0; % total adult death events
imtot = 0; % total immigration events

% Rows represent, in order: adult, susceptible, infected, recovered
pop = zeros(4,evf); % initial population matrix
% Setting up the initial conditions
pop(:,1) = [H0; S0; I0; R0];
times = zeros(1,evf); % Times of each event
counter = 2;

% Annual stats:
years = floor(tf/365); % number of full years
yearid = 1; % index of the current year
annual_pop = zeros(1,years+1); % adult population every year
annual_growth = zeros(1,years+1); % adult population growth between years

% The main loop:
while (counter-1 < evf && times(counter-1) < tf) % While we still have events left to calculate...

	% Shorthand names for each variable this loop
	H = pop(1,counter-1);
	Sj = pop(2,counter-1);
	Ij = pop(3,counter-1);
	Rj = pop(4,counter-1);
	if (pop(1,counter-1) <= 0) % If there are no adults left...
		error(['Simulation aborted at event number ' num2str(counter-1) ' (ran out of adult hawks).']);
	end
	
	% Event probabilities
	totrate = b*H + ifood*Sj + gamma*Ij + muj*(Sj+Ij+Rj) + d*Ij + alpha*(Sj+Rj) + muH*H + lambda/H; % total event rate
	brate = b*H / totrate; % rate of birth event
	irate = ifood*Sj / totrate; % rate of infection event
	rrate = gamma*Ij / totrate; % rate of recovery event
	snrate = muj*Sj / totrate; % rate of susceptible natural death event
	inrate = muj*Ij / totrate; % rate of infected natural death event
	rnrate = muj*Rj / totrate; % rate of recovered natural death event
	idrate = d*Ij / totrate; % rate of infected disease death event
	sarate = alpha*Sj / totrate; % rate of susceptible aging event
	rarate = alpha*Rj / totrate; % rate of recovered aging event
	hnrate = muH*H / totrate; % rate of adult death event
	immrate = lambda/H / totrate; % rate of immigration event
	
	% Figuring out which event happens
	event = rand;
	schange = 0;
	ichange = 0;
	rchange = 0;
	hchange = 0;
	if (event < brate)
		schange = 1;
		btot = btot + 1;
	elseif (event < brate+irate)
		schange = -1;
		ichange = 1;
		itot = itot + 1;
	elseif (event < brate+irate+rrate)
		ichange = -1;
		rchange = 1;
		rtot = rtot + 1;
	elseif (event < brate+irate+rrate+snrate)
		schange = -1;
		sntot = sntot + 1;
	elseif (event < brate+irate+rrate+snrate+inrate)
		ichange = -1;
		intot = intot + 1;
	elseif (event < brate+irate+rrate+snrate+inrate+rnrate)
		rchange = -1;
		rntot = rntot + 1;
	elseif (event < brate+irate+rrate+snrate+inrate+rnrate+idrate)
		ichange = -1;
		idtot = idtot + 1;
	elseif (event < brate+irate+rrate+snrate+inrate+rnrate+idrate+sarate)
		schange = -1;
		hchange = 1;
		satot = satot + 1;
	elseif (event < brate+irate+rrate+snrate+inrate+rnrate+idrate+sarate+rarate)
		rchange = -1;
		hchange = 1;
		ratot = ratot + 1;
	elseif (event < brate+irate+rrate+snrate+inrate+rnrate+idrate+sarate+rarate+hnrate)
		hchange = -1;
		hntot = hntot + 1;
	else
		hchange = 1;
		imtot = imtot + 1;
	end
	pop(:,counter) = [pop(1,counter-1)+hchange;pop(2,counter-1)+schange;pop(3,counter-1)+ichange;pop(4,counter-1)+rchange]; % Evaluating the changes due to the event
	
	% Figuring out when the event happens
	timeadd = exprnd(1/totrate);
	times(counter) = times(counter-1) + timeadd;
	
	% Annual stats
	if (times(counter-1) >= (yearid-1)*365) % If we've entered a new year...
		if (annual_pop(yearid) == 0) % If we haven't recorded the adult population yet...
			annual_pop(yearid) = pop(1,counter-1);
			yearid = yearid + 1;
		end
	end
	
	counter = counter + 1;
end

if (years) % If we have at least a year's worth of simulation...
	for i = 1:years % For each year...
		annual_growth(i+1) = annual_pop(i+1) / annual_pop(i);
	end
	avg_annual_growth = mean(annual_growth(2:end));
else
	avg_annual_growth = 0;
end

% Drop all the unfilled columns
times = times(1:counter-1);
pop = pop(:,1:counter-1);
% pop % Uncomment this to display the entire population matrix

results = [btot, itot, rtot, sntot, intot, rntot, idtot, satot, ratot, hntot, imtot, avg_annual_growth];
% Uncomment these to see some actual labels
% btot
% itot
% rtot
% sntot
% intot
% rntot
% idtot
% satot
% ratot
% hntot
% imtot
% annual_pop
% annual_growth
% percent_baby_disease_deaths = results(7) / (results(7)+results(4)+results(5)+results(6))

% Plotting the results
if (flag)
	figure;
	hold on;
	stairs(times,pop(1,:),'r');
	stairs(times,pop(2,:),'b');
	stairs(times,pop(3,:),'k');
	stairs(times,pop(4,:),'g');
	legend('H','S','I','R',2);
	xlabel('Day');
	ylabel('Hawks');
	title(['Markov process for hawk population, continuous time, \beta = ' num2str(b)]);
end