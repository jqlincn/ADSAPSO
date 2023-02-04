function ADSAPSO(Global)
% <algorithm> <A>
% k    ---  5  --- Number of re-evaluated solutions
% beta --- 0.5 --- Percentage of Dropout

%------------------------------- Reference --------------------------------
% J. Lin, C. He, and R. Cheng, Adaptive dropout for high-dimensional 
% expensive multiobjective optimization[J]. Complex & Intelligent Systems, 
% vol. 8, no. 1, pp. 271¨C285, 2022.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2018-2019 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

% This function is written by Jianqing Lin
    warning('off')
    
    %% Parameter setting
    [k,beta] = Global.ParameterSet(5,0.5);
    Init_Num = 500;     % Initial number of solutions
    N_a      = 200;     % The number of solutions for building surrogate models
    
    %% Generate initial population
    PopDec       = repmat((Global.upper - Global.lower),Init_Num, 1) .* lhsdesign(Init_Num, Global.D) + repmat(Global.lower, Init_Num, 1);  % lhs design
    Population   = INDIVIDUAL(PopDec);
    
    %% Optimization
    while Global.NotTermination(Population)
        Offspring  = Operator(Global,Population,Global.N,k,beta,N_a);
        Offspring  = INDIVIDUAL(Offspring);
        Population = [Population,Offspring];
    end
end