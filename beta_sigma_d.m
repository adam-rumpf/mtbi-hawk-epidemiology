% Figures out the relationship between sigma and d to have a real H*.
% In the plot produced, any sigma/d pairing below the line produces a real H*.
% On the line is an impossible H* (division by zero).
% Above the line is an imaginary H* (square root of a negative).
%
% Last revised 7/26/11, 3:45pm

% Fixed parameters
muH = 1 / (365*5); % natural adult deaths
muj = 0.36 / (365*2); % natural baby deaths
lambda = 1; % adult hawk immigration rate
delta = 8.9; % food brought in per adult hawk
rho = (1/3)*(1/10); % chance that you get infected from eating infected food
% gamma = 0.59 / 45; % infected -> recovered conversions per hawk
alpha = 1 / (365*2); % fledgeling -> adult conversions per hawk

betas = linspace(0.001,0.003,6); % beta values to evaluate
sigmas = linspace(0,1,100); % sigma values to evaluate
ds = zeros(length(betas),length(sigmas));

% Calculating the d that corresponds to every sigma for the H* denominator to equal 0
for j = 1:length(betas)
	for i = 1:length(sigmas)
		ifood = delta*rho*sigmas(i);
		% ds(j,i) = (-1/(muH*ifood*muj+muH*ifood*alpha+muH*muj^2+2*muH*alpha*muj+muH*alpha^2-alpha*betas(j)*muj-betas(j)*alpha^2))* ...
			% (muH*ifood*muj^2+muH*ifood*muj*alpha+muH*gamma*ifood*muj+muH*gamma*ifood*alpha+muH*muj^3+2*muH*alpha*muj^2+ ...
			% muH*gamma*muj^2+2*muH*muj*gamma*alpha+muH*muj*alpha^2+muH*gamma*alpha^2-alpha*betas(j)*muj^2-betas(j)*muj*alpha^2- ...
			% alpha*betas(j)*muj*gamma-betas(j)*gamma*alpha^2-alpha*betas(j)*gamma*ifood);
		% if (ds(j,i) < 0 || ds(j,i) > 1)
			% ds(j,i) = 0;
		% end
		if (40*alpha*betas(j)*ifood)
			ds(j,i) = (-1/(40*alpha*betas(j)*ifood))*(40*muH*ifood*muj^2+40*muH*ifood*muj*alpha+muH*ifood*muj+muH*ifood*alpha+ ...
			40*muH*muj^3+80*muH*alpha*muj^2+muH*muj^2+2*muH*alpha*muj+40*muH*muj*alpha^2+muH*alpha^2-40*alpha*betas(j)*muj^2- ...
			40*betas(j)*muj*alpha^2-alpha*betas(j)*muj-betas(j)*alpha^2-alpha*betas(j)*ifood);
		end
		if (ds(j,i) < 0)
			ds(j,i) = 0;
		end
	end
end

% Plotting
plot(sigmas,ds);
ylabel('d');
xlabel('\sigma');
legend('\beta=0.0010','\beta=0.0014','\beta=0.0018','\beta=0.0022','\beta=0.0026','\beta=0.0030',0);
% title('Boundary of the real H* region as a function of sigma and d');