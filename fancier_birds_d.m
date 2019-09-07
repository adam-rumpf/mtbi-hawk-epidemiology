function results = fancier_birds_d(tf,H0,drate,flag)
% results = fancier_birds_d(tf,H0,drate,flag)
%
% Last revised 7/27/11, 11:12pm
%
% Runs a Markov process on a hawk population that consumes infected dove meat.
% Lets you set the disease death rate.
%
% Inputs:
% tf ~ number of days to run (use an integer >= 3)
% H0 ~ initial number of adult hawks
% d ~ disease death rate, [0,1]
% flag ~ 0 -> no plot, 1 -> plot all classes, 2 -> plot total adults and total nestlings, 3 -> plot both
%
% Outputs:
% data ~ matrix containing various statistics from the course of the entire simulation.
% The outputs are as folows:
% 01. total adult deaths
% 02. total 2nd year deaths
% 03. total 1st year deaths
% 04. total births
% 05. total immigrations
% 06. total nests
% 07. total successful nests
% 08. fraction of nests that are successful
% 09. total juvenile natural deaths
% 10. total infections
% 11. total recoveries
% 12. total disease deaths
% 13. total food items
% 14. total infected food items
% 15. fraction of food that was infected
% 16. average fledging rate
% 17. fraction of juvenile deaths caused by disease
% 18. average annual growth rate.

% Pseudocode (slightly out of date by now):
% Start with a certain number of nesting adults and give each a random number of nestlings
% ~5 times per day (assuming 5 prey per day) (could increase number as nesting period goes on)
% For each nesting adult (that's still alive)
% Determine which type of prey they get
% If it's a dove and it happens to be infected, continue
% For each susceptible nestling
% If the nestling eats an infected part, continue
% If the nestling happens to get infected from it, continue
% Switch a healthy nestling to an infected nestling
% Evaluate any nestling deaths (natural, disease)
% At the end of ~60 days, advance all surviving nestlings to young adults (but separate from last year's young adults)
% All the hawks are now some sort of adult
% Run a much simpler loop that just subtracts some natural deaths every day for the rest of the year
% Promote last year's young adults to regular adults, and the new young adults to last year's young adults
% Repeat for however many years you wanted

% Assumptions and generalizations:
% All nests are produced at the same time
% All fledgelings leave the nest at the same time
% Sex ratios are never an issue
% Nestlings may move through the disease extremely quickly or slowly, but on average there's about 7 days of latent period and 7 days of infectious period
% If one parent dies, the other one abandons the nest and all the nestlings die
% If you get to 2 weeks (on average) with the disease, or you become a fledgeling, you're safe from the disease
% Adult hawks are the only ones that breed

% Current issues:
% The annual reset doesn't actually happen until day 367, not day 365
% Many parameters still need to be finalized
% Figure out if anything breaks if H = 0
% Fledging rate and nest success rate vary wildly between realizations
% Add support for saving and tracking various statistics

% Parameters:
doveprob = 0.83; % probability that prey is a dove
dovetypeM = 0.38; % fraction of doves eaten that are Mourning Doves
dovetypeI = 0.47; % fraction of doves eaten that are Inca Doves
dovetypeW = 0.15; % fraction of doves eaten that are White-Winged Doves
doveiM = 0.14; % infection rate in Mourning Doves
doveiI = 0.5; % infection rate in Inca Doves
doveiW = 0.9; % infection rate in White-Winged Doves
idoveprob = doveprob * (dovetypeM*doveiM + dovetypeI*doveiI + dovetypeW*doveiW); % weighted probability that the food item is an infected dove
nestdays = 40; % nesting period (days until they're basically safe from the disease)
yeardays = 365; % days in a year
ichance = (1/3)*(1/10); % probability of getting infected from eating infected meat
muH = 1 / (365*5); % natural adult deaths per day
muY = 0.36 / nestdays; % natural baby deaths per day %#######
if (drate < 0)
	drate = 0.41; % default death rate
end
d = drate / 14; % disease baby deaths per day
muHy1 = (1-0.69) / yeardays; % natural 1st year fledgeling deaths per day
muHy2 = muHy1; % natural 2nd year fledgeling deaths per day
latency = 1 / 7; % latent -> infectious rate %##########################
iperiod = (1 - 14*d) / 14; % infectious -> recovered rate %########################
avgeggs = 3.44; % average hawk hatchlings per clutch
stdeveggs = sqrt(371) * 0.053; % standard deviation of hawk hatchlings per clutch
avgfood = 8.9; % average food items brought in per day
stdevfood = 0.04 * 13; % standard deviation of food items brought in per day %###################################
secfrac = 1/3; % number of 2nd year fledgelings to start with relative to adults
matefrac = (2/3) * 0.835; % fraction of adults that actually wind up mating every nesting season
lambda = 1; % immigration coefficient

% Initial conditions:
H = H0; % initial adult hawks (make it an even number)
Hy1 = 0; % initial 1st year fledgelings
Hy2 = floor(H*secfrac); % initial 2nd year fledgelings
Hn = 0; % initial non-mating adults
transfer = 0;
for i = 1:H % For each adult...
	if (rand > matefrac) % If the adult doesn't mate...
		transfer = transfer + 1; % Transfer one from mating adults to non-mating adults
	end
end
if (floor(H/2) < H/2) % If there's an odd number of mating adults...
	transfer = transfer + 1; % Transfer one more to non-mating
end
H = H - transfer;
Hn = Hn + transfer;

% Each column of the population matrix represents one nest
% The rows represent (in order): adult, susceptible, latent, infected, recovered
pop = zeros(5,floor(H/2)); % initial population matrix
pop(1,:) = 2; % Begin with 2 parents per nest
% Filling the matrix with randomized numbers of babies
for i = 1:length(pop)
	pop(2,i) = max(0,floor(0.5+normrnd(avgeggs,stdeveggs))); % Random number of susceptible hatchlings for every adult hawk
end
adults = H + Hn;

data = zeros(7,tf); % Output file which keeps track of all hawk groups for every day
% Format is [adult, 2nd year, 1st year, susceptible, latent, infected, recovered]
data(:,1) = [adults; Hy2; Hy1; sum(pop(2,:)); 0; 0; 0];

% Final result initialization:
adult_deaths = 0; % total adult natural deaths
second_year_deaths = 0; % total 2nd year fledgeling natural deaths
first_year_deaths = 0; % total 1st year fledgeling natural deaths
births = sum(pop(2,:)); % total births
immigrations = 0; % total adult hawks that immigrated into the system
nests = length(pop); % total number of nests
successful_nests = 0; % total number of nests that produce at least one fledgeling
baby_natural_deaths = 0; % total baby natural deaths
infections = 0; % total infections
recoveries = 0; % total recoveries (due to I -> R and due to aging)
disease_deaths =  0; % total deaths due to infection
total_food = 0; % total food items caught
infected_food = 0; % toal infected food items caught
percent_infected_food = 0; % percent of food items that were infected
day = 1; % day number
year = 1; % year number
leftover_days = tf - yeardays * floor(tf/yeardays); % day number from final year
if (leftover_days >= nestdays)
	seasons = floor(tf/yeardays) + 1; % number of seasons to run for
else
	seasons = floor(tf/yeardays);
end
if (tf >= yeardays) % If we have at least a year's worth of simulation...
	avg_annual_growth_rate = 0; % average increase in adult population per year
end
if (seasons > 0) % If we have at least a nesting season's worth of simulation...
	avg_fledging_rate = 0; % average fraction of births that lead to fledges
	percent_nestling_disease_deaths = 0; % average fraction of nestling deaths caused by disease
end

% Stuff for calculating annual events:
annual_growths = zeros(1,floor(tf/yeardays)); % growth rate from each year
year_beginning = H0 + Hy2; % the adults we started with
annual_nestling_deaths = zeros(1,seasons); % mortalities from each year
annual_births = zeros(1,seasons); % births from each year
annual_births(1) = data(4,1);

% The daily loop:
for main = 2:tf % For each day specified
    nesteval = 0; % whether the end of the nesting stage has been evaluated
	imchance = lambda / adults; % base immigration chance on current number of adults

	% ANNUAL RESET
	if (day > yeardays)
		day = 1;
		annual_growths(1,year) = (adults + Hy2 + Hy1) / year_beginning; % growth over the past year
		year_beginning = adults + Hy2 + Hy1; % Resetting the year-beginning population
		adults = adults + Hy2; % Aging the 2nd year fledgelings
		Hy2 = Hy1; % Aging the 1st year fledgelings
		Hy1 = 0; % Resetting the new 1st year fledgelings
		% Setting up the new nests
		transfer = 0;
		for i = 1:adults % For each adult...
			if (rand > matefrac) % If the adult doesn't mate...
				transfer = transfer + 1; % Transfer one from mating adults to non-mating adults
			end
		end
		if (floor(adults/2) < adults/2) % If there's an odd number of mating adults...
			transfer = transfer + 1; % Transfer one more to non-mating
		end
		adults = adults - transfer;
		Hn = Hn + transfer;
		newnests = floor(adults/2); % new nests created
		nests = nests + newnests;
		pop = zeros(5,newnests); % Resetting population matrix for the adults that mate
		Hn = adults - newnests * 2; % Keeping track of the non-mating adults
		pop(1,:) = 2; % 2 parents for each nest
		% Generating a random number of babies for each adult
		for i = 1:length(pop)
			pop(2,i) = max(0,floor(0.5+normrnd(avgeggs,stdeveggs))); % Random number of susceptible hatchlings for every adult hawk
        end
		year = year + 1;
		annual_births(year) = sum(pop(2,:)); % Recording the new babies
        births = births + annual_births(year);
	end
	
	% NESTING PERIOD
	if (day < nestdays)
		for i = 1:length(pop) % For each nest...
            % Infections due to food
			if (pop(1,i) == 2) % If there are 2 parents...
				if (pop(2,i)) % If there are susceptible babies...
					for j = 1:max(0,(floor(0.5+normrnd(avgfood,stdevfood)))) % For each food item brought in...
						if (rand < idoveprob) % If the food item was infected...
							for k = 1:pop(2,i) % For each susceptible baby...
								if (rand < ichance) % If you get infected from the food...
									pop(2,i) = pop(2,i) - 1; % Go from susceptible...
									pop(3,i) = pop(3,i) + 1; % ... into latent
                                    infections = infections + 1;
								end
                            end
                            infected_food = infected_food + 1;
                        end
                        total_food = total_food + 1;
					end
                end
            end
            % Baby mortality
            if (pop(5,i)) % If there are recovered babies...
                subtraction = 0;
				for j = 1:pop(5,i) % For each recovered baby...
					if (rand < muY) % If they die from natural causes...
                        subtraction = subtraction + 1;
					end
                end
                pop(5,i) = pop(5,i) - subtraction;
                baby_natural_deaths = baby_natural_deaths + subtraction;
            end
			if (pop(4,i)) % If there are infected babies...
				for j = 1:pop(4,i) % For each infected baby...
                    sub1 = 0;
                    sub2 = 0;
                    event = rand;
					if (event < muY) % If they die from natural causes...
						sub1 = sub1 + 1;
                    elseif (event < muY + d) % If they die from disease-related causes...
                        sub2 = sub2 + 1;
                    end
                    pop(4,i) = pop(4,i) - sub1 - sub2;
                    baby_natural_deaths = baby_natural_deaths + sub1;
                    disease_deaths = disease_deaths + sub2;
				end
            end
			if (pop(3,i)) % If there are latent babies...
                subtraction = 0;
				for j = 1:pop(3,i) % For each latent baby...
					if (rand < muY) % If they die from natural causes...
						subtraction = subtraction + 1;
					end
                end
                pop(3,i) = pop(3,i) - subtraction;
                baby_natural_deaths = baby_natural_deaths + subtraction;
            end
			if (pop(2,i)) % If there are susceptible babies...
                subtraction = 0;
				for j = 1:pop(2,i) % For each susceptible baby...
					if (rand < muY) % If they die from natural causes...
						subtraction = subtraction + 1;
					end
                end
                pop(2,i) = pop(2,i) - subtraction;
                baby_natural_deaths = baby_natural_deaths + subtraction;
            end
            % Infection class shifting
			if (pop(4,i)) % If there are infected babies...
				for j = 1:pop(4,i) % For each infected baby...
					if (rand < iperiod) % If you move out of the infected period...
						pop(4,i) = pop(4,i) - 1; % Go from infected...
						pop(5,i) = pop(5,i) + 1; % ... into recovered
                        recoveries = recoveries + 1;
					end
				end
			end
			if (pop(3,i)) % If there are latent babies...
				for j = 1:pop(3,i) % For each latent baby...
					if (rand < latency) % If you move out of the latent period...
						pop(3,i) = pop(3,i) - 1; % Go from latent...
						pop(4,i) = pop(4,i) + 1; % ... into infectious
					end
				end
            end
			% Nesting adult mortality
            if (pop(1,i) == 2) % If there are 2 parents...
                subtraction = 0;
                for j = 1:2 % For each parent...
                    if (rand < muH) % If an adult dies (repeat since the other parent might die, too)...
                        subtraction = subtraction + 1;
                        baby_natural_deaths = baby_natural_deaths + sum(pop(3:5,i)); % All the babies die, too
                        pop(2,i) = 0;
                        pop(3,i) = 0;
                        pop(4,i) = 0;
                    end
                end
                pop(1,i) = pop(1,i) - subtraction;
                adult_deaths = adult_deaths + subtraction;
			elseif (pop(1,i) == 1) % If there's one parent...
				if (rand < muH) % If the adult dies...
					pop(1,i) = 0;
                    adult_deaths = adult_deaths + 1;
				end
			end
			% Immigration
			process = 1; % whether to continue the process
			while(process) % While hawks are still potentially immigrating...
				if (rand < imchance) % If a hawk immigrates...
					Hn = Hn + 1; % A non-mating adult enters
					immigrations = immigrations + 1;
				else % If not...
					process = 0; % Stop repeating the process
				end
			end
		end
		% Other mortality
		if (Hy2) % If there are any 2nd year fledgelings...
			subtraction = 0;
			for i = 1:Hy2 % For each 2nd year fledgeling...
				if (rand < muHy2) % If a fledgeling dies naturally...
					subtraction = subtraction + 1;
				end
			end
			Hy2 = Hy2 - subtraction;
            second_year_deaths = second_year_deaths + subtraction;
		end
		if (Hn) % If there are any non-mating adults...
			subtraction = 0;
			for i = 1:Hn % For each non-mating adult...
				if (rand < muH) % If a non-mating adult dies naturally...
					subtraction = subtraction + 1;
				end
			end
			Hn = Hn - subtraction;
            adult_deaths = adult_deaths + subtraction;
		end
		adults = sum(pop(1,:)) + Hn; % total number of adults

	% END OF NESTING PERIOD
	elseif (day == nestdays && nesteval == 0) % If we're at the end of the nesting period...
		adults = sum(pop(1,:)) + Hn; % total number of adults
		fledges = sum(sum(pop(2:5,:))); % total number of surviving babies
		if (fledges) % If any babies fledged...
			for i = 1:length(pop) % For each nest...
				if (sum(pop(2:5,i))) % If there are any babies...
					successful_nests = successful_nests + 1; % Count the nest as a success
				end
			end
		end
		Hy1 = fledges; % Surviving babies become 1st year fledgelings
		annual_nestling_deaths(year) = annual_births(year) - fledges; % total nestling deaths this year
		pop(2:5,:) = 0; % Removing the babies from the population matrix
        nesteval = 1;

	% NON-NESTING PERIOD
    elseif (day > nestdays || nesteval == 1) % If we're past the nesting period or we just evaluated the end of the nesting period...
		if (adults) % If there are any adults...
			subtraction = 0;
			for i = 1:adults % For each adult hawk...
				if (rand < muH) % If the adult dies naturally...
					subtraction = subtraction + 1;
				end
			end
			adults = adults - subtraction;
            adult_deaths = adult_deaths + subtraction;
		end
		if (Hy1) % If there are any 1st year fledgelings...
			subtraction = 0;
			for i = 1:Hy1 % For each 1st year fledgeling...
				if (rand < muHy1) % If a fledgeling dies naturally...
					subtraction = subtraction + 1;
				end
			end
			Hy1 = Hy1 - subtraction;
            first_year_deaths = first_year_deaths + subtraction;
		end
		if (Hy2) % If there are any 2nd year fledgelings...
			subtraction = 0;
			for i = 1:Hy2 % For each 2nd year fledgeling...
				if (rand < muHy2) % If a fledgeling dies naturally...
					subtraction = subtraction + 1;
				end
			end
			Hy2 = Hy2 - subtraction;
            second_year_deaths = second_year_deaths + subtraction;
		end
		process = 1; % whether to continue the process
		while(process) % While hawks are still potentially immigrating...
			if (rand < imchance) % If a hawk immigrates...
				Hn = Hn + 1; % A non-mating adult enters
				immigrations = immigrations + 1;
			else % If not...
				process = 0; % Stop repeating the process
			end
		end
	end
	day = day + 1;
	
	% Updating the data file
	data(:,main) = [adults; Hy2; Hy1; sum(pop(2,:)); sum(pop(3,:)); sum(pop(4,:)); sum(pop(5,:))];
end

% Final result display order (remove ';' for clarity):
adult_deaths; % 1
second_year_deaths; % 2
first_year_deaths; % 3
births;  % 4
immigrations; % 5
nests; % 6
successful_nests; % 7
percent_successful_nests = successful_nests / nests; % 8
baby_natural_deaths; % 9
infections; % 10
recoveries; % 11
disease_deaths; % 12
total_food; % 13
infected_food; % 14
if (total_food)
	percent_infected_food = infected_food / total_food; % 15
else
	percent_infected_food = -1;
end
if (tf >= nestdays && sum(annual_births) && disease_deaths+baby_natural_deaths)
	avg_fledging_rate = (births - baby_natural_deaths - disease_deaths) / births; % 16
	percent_nestling_disease_deaths = disease_deaths / (disease_deaths + baby_natural_deaths); % 17
else
	avg_fledging_rate = -1;
	percent_nestling_disease_deaths = -1;
end
if (tf >= yeardays && mean(annual_growths))
	avg_annual_growth_rate = mean(annual_growths); % 18
else
	avg_annual_growth_rate = -1;
end

results = [adult_deaths, second_year_deaths, first_year_deaths, births, immigrations, nests, successful_nests, ...
	percent_successful_nests, baby_natural_deaths, infections, recoveries, disease_deaths, total_food, infected_food, ...
	percent_infected_food, avg_fledging_rate, percent_nestling_disease_deaths, avg_annual_growth_rate];

% Plotting the results
if (flag == 1 || flag == 3)
	t = [1:tf]; % days for plotting
	figure;
    hold on;
    stairs(t,data(1,:),'b');
    stairs(t,data(2,:),'g');
    stairs(t,data(3,:),'r');
    stairs(t,data(4,:),'c');
    stairs(t,data(5,:),'m');
    stairs(t,data(6,:),'y');
    stairs(t,data(7,:),'k');
	legend('Adults','2nd Year Fledgelings','1st Year Fledgelings','Susceptible','Latent','Infected','Recovered',0);
	xlabel('time (days)');
	ylabel('hawk population');
	% title('Markov process for hawk population');
end
if (flag == 2 || flag == 3)
	t = [1:tf]; % days for plotting
	figure;
	hold on;
	total_adults = sum(data(1:3,:)); % total number of adult classes
	total_babies = sum(data(4:7,:)); % total number of nestling classes
	stairs(t,total_adults,'b');
	stairs(t,total_babies,'g');
	legend('Total Adults','Total Nestlings',0);
	xlabel('time (days)');
	ylabel('hawk population');
	% title('Markov process for hawk population, combined classes');
end