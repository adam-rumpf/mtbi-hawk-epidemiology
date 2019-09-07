function dx=newmodel(tf,x)

global alpha beta muh lambda2 gamma muj dj sigma rho

dx=zeros(4,1);

dx(1)= alpha*x(2)+alpha*x(4)-muh*x(1)+lambda2/x(1);
dx(2)= (beta*x(1))-muj*x(2)-(rho*sigma)*x(2)-alpha*x(2);
%91% of the prey identified in urban nest were birds estes mannan
%8.9 prey items per day delivered to nest estes mannan
dx(3)=(rho*sigma)*x(2)-gamma*x(3)-muj*x(3)-dj*x(3);
dx(4)=gamma*x(3)-muj*x(4)-alpha*x(4);