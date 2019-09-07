% Produces a 3D surface plot of the combinations of beta, sigma, and d that cause a real H*.
% Above the surface we have no real H*.
% On the surface we have an impossible H* (zero denominator).
% Below the surface we have a positive H*.
%
% Last revised 7/26/11, 2:46pm

% Fixed parameters:
muH = 1 / (365*5); % natural adult deaths
muj = 0.36 / (365*2); % natural baby deaths
lambda = 1; % adult hawk immigration rate
delta = 8.9; % food brought in per adult hawk
doveprob = 0.83; % fraction of food that is doves
rho = (1/3)*(1/10); % chance that you get infected from eating infected food
% gamma = 0.59 / 45; % recovery rate
alpha = 1 / (365*2); % fledgeling -> adult conversions per hawk

% ds = linspace(0,0.025,26); % d values to try
 ds = linspace(0,0.02,21);
sigmas = linspace(0,1,21); % sigma values to try
betas = zeros(length(ds),length(sigmas)); % corresponding beta value

% Calculating the beta that corresponds to every sigma/d for the H* denominator to equal 0:
for i = 1:length(ds) % For every d value...
	gamma = (1 - (40*ds(i))) / 40;
	for j = 1:length(sigmas) % For every sigma value...
		ifood = delta * doveprob * rho * sigmas(j);
		betas(i,j) = (1/(alpha*(muj^2+alpha*muj+muj*ds(i)+muj*gamma+alpha*gamma+gamma*ifood)))* ...
			(muH*(ifood*muj^2+ifood*muj*alpha+ifood*ds(i)*muj+ifood*ds(i)*alpha+gamma*ifood*muj+ ...
			alpha*gamma*ifood+muj^3+2*muj^2*alpha+muj^2*ds(i)+2*muj*ds(i)*alpha+muj^2*gamma+ ...
			2*alpha*muj*gamma+alpha^2*muj+alpha^2*ds(i)+alpha^2*gamma));
		% if (betas(i,j) > 0.002)
			% betas(i,j) = 0.002;
		% end
	end
end

% Graphing:
surf(sigmas,ds,betas);
xlabel('\sigma');
ylabel('d');
zlabel('\beta');
% title('Boundary of the real H* region as a function of d, sigma, and beta');

% Views:
% 55,330 for ortho
% 90,0 for beta vs d
% 0,0 for beta vs sigma

% Graphing:
% figure;
% hold on;
% subplot(2,2,1);
	% surf(ds,sigmas,betas);
	% view(0,0);
	% xlabel('d');
	% zlabel('beta');
	% title('beta versus d');
% subplot(2,2,2);
	% surf(ds,sigmas,betas);
	% xlabel('d');
	% ylabel('sigma');
	% zlabel('beta');
	% title('Boundary of the real H* region as a function of d, sigma, and beta');
% subplot(2,2,3);
	% surf(ds,sigmas,betas);
	% view(0,90);
	% xlabel('d');
	% ylabel('sigma');
	% title('sigma versus d');
% subplot(2,2,4);
	% surf(ds,sigmas,betas);
	% view(90,0);
	% ylabel('sigma');
	% zlabel('beta');
	% title('beta versus sigma');