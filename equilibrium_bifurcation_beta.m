% This script creates a plot of the value (if it exists) of H* for the Cooper's hawk model.
% We're varying beta.
%
% Last revised 7/27/11, 10:41pm

% Fixed parameters
muH = 1 / (365*5); % natural adult deaths
muj = 0.36 / (365*2); % natural baby deaths
d = 0.41 / 40; % disease deaths
lambda = 1; % adult hawk immigration rate
delta = 8.9; % food brought in per adult hawk
rho = (1/3) * (1/10); % chance that you get infected from eating infected food
alpha = 1 / (365*2); % fledgeling -> adult conversions per hawk
sigma = 0.38*0.14 + 0.47*0.5 + 0.15*0.9; % dove infection rate based on our research
ifood = delta*rho*sigma; % overall rate of infections due to food
d = 0.41 / 40; % disease death rate
gamma = 0.59 / 40; % recovery rate
x = ifood + muj + alpha;
y = muj + d + gamma;
z = muj + alpha;

% Calculating the H* values
betas = linspace(0.0005,0.0035,100); % beta values to check
Hstars = zeros(2,length(betas)); % matrix to hold H* values
for i = 1:length(betas) % For every d value...
	denominator = muH*x*y*z - alpha*betas(i)*(y*z + gamma*ifood); % denominator of H*
	numerator = lambda * x * y * z; % numerator of H*
	if (denominator*numerator > 0) % If this gives us an H* that actually exists...
		Hstars(1,i) = sqrt(numerator/denominator); % the positive H*
		Hstars(2,i) = -sqrt(numerator/denominator); % the negative H*
	end
end

% Graphing
plot(betas,Hstars,'k.');
xlabel('\beta');
ylabel('H*');
% title('Bifurcation of equilibrium based on \beta');