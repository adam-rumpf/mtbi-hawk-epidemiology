% Figures out the relationship between d and beta to have a real H*.
% In the plot produced, any d/beta pairing below the line produces a real H*.
% On the line is an impossible H* (division by zero).
% Above the line is an imaginary H* (square root of a negative).
%
% Last revised 7/26/11, 2:44pm

% Fixed parameters
muH = 1 / (365*5); % natural adult deaths
muj = 0.36 / (365*2); % natural baby deaths
lambda = 1; % adult hawk immigration rate
delta = 8.9; % food brought in per adult hawk
rho = (1/3)*(1/10); % chance that you get infected from eating infected food
% gamma = 0.59 / 45; % infected -> recovered conversions per hawk
alpha = 1 / (365*2); % fledgeling -> adult conversions per hawk

% ds = linspace(0,0.025,100); % d values to evaluate
 ds = linspace(0,0.02,100);
sigmas = linspace(0,1,6); % sigma values to evaluate
betas = zeros(length(sigmas),length(ds)); % space to hold the beta values

% Calculating the beta that corresponds to every d for the H* denominator to equal 0
for j = 1:length(sigmas) % For every sigma value...
	for i = 1:length(ds) % For every d value...
		gamma = (1 - (40*ds(i))) / 40;
		ifood = delta*rho*sigmas(j); % overall rate of infections due to food
		betas(j,i) = (1/(alpha*(muj^2+alpha*muj+muj*ds(i)+muj*gamma+alpha*gamma+gamma*ifood)))* ...
			(muH*(ifood*muj^2+ifood*muj*alpha+ifood*ds(i)*muj+ifood*ds(i)*alpha+gamma*ifood*muj+ ...
			alpha*gamma*ifood+muj^3+2*muj^2*alpha+muj^2*ds(i)+2*muj*ds(i)*alpha+muj^2*gamma+ ...
			2*alpha*muj*gamma+alpha^2*muj+alpha^2*ds(i)+alpha^2*gamma));
	end
end

% r = delta * rho;
% beta_limit = (muH*(r*muj^2+r*muj*alpha+r*d*muj+r*d*alpha+r*gamma*muj+r*alpha*gamma))/(alpha*r*gamma)
% beta_1 = betas(end)

% Plotting
plot(ds,betas);
ylabel('\beta');
xlabel('d');
legend('\sigma=0.0','\sigma=0.2','\sigma=0.4','\sigma=0.6','\sigma=0.8','\sigma=1.0',0);
% title('Boundary of the real H* region as a function of d and beta');