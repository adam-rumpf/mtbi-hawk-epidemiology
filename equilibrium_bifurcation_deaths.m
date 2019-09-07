% This script creates a plot of the value (if it exists) of H* for the Cooper's hawk model.
% We're varying d (now in terms of the disease death percentage).
%
% Last revised 7/27/11, 10:36pm

% Fixed parameters
muH = 1 / (365*5); % natural adult deaths
muj = 0.36 / (365*2); % natural baby deaths
d = 0.41 / 40; % disease deaths
lambda = 1; % adult hawk immigration rate
b = (3.44 / 365 / 2) * (2/3) * 0.835; % average hatchlings per hawk
delta = 8.9; % food brought in per adult hawk
rho = (1/3) * (1/10); % chance that you get infected from eating infected food
alpha = 1 / (365*2); % fledgeling -> adult conversions per hawk
sigma = 0.38*0.14 + 0.47*0.5 + 0.15*0.9; % dove infection rate based on our research
ifood = delta*rho*sigma; % overall rate of infections due to food
x = ifood + muj + alpha;
z = muj + alpha;

% Calculating the H* values
ds = linspace(0,1,100); % d values to check
Hstars = zeros(2,length(ds)); % matrix to hold H* values
for i = 1:length(ds) % For every d value...
	d = ds(i) / 40;
	gamma = (1 - (40*d)) / 40; % infected -> recovered conversions per hawk
	y = muj + d + gamma;
	denominator = muH*x*y*z - alpha*b*(y*z + gamma*ifood); % denominator of H*
	numerator = lambda * x * y * z; % numerator of H*
	if (denominator*numerator > 0) % If this gives us an H* that actually exists...
		Hstars(1,i) = sqrt(numerator/denominator); % the positive H*
		Hstars(2,i) = -sqrt(numerator/denominator); % the negative H*
	end
end

% Graphing
plot(ds,Hstars,'k.');
xlabel('fraction of infections which result in death');
ylabel('H*');
% title('Bifurcation of equilibrium based on d');