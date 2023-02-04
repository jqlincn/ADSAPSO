function Offspring = Operator(Global,Population,NP,k,beta,N_a)

%------------------------------- Copyright --------------------------------
% Copyright (c) 2018-2019 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------
 
% This function is written by Jianqing Lin
    
    %% Environmental Selection
    if size(Population,2) > N_a
        [Population,FrontNo,CrowdDis] = EnvironmentalSelection(Population,N_a);
    else
        [Population,FrontNo,CrowdDis] = EnvironmentalSelection(Population,size(Population,2));
    end

    %% Parameter setting     
    PopDec = Population.decs;
    D      = Global.D;
    M      = Global.M;
    N_s    = 50;        % The number of the well- and poorly performing solutions
    
    %% Solution Sort & Selection
    [~,index_FNCD] = sortrows([FrontNo;CrowdDis]',[1,-2]);
    Offspring_D    = PopDec(index_FNCD(1:k),:);
    
    Index_Well = index_FNCD(1:N_s);
    Index_Poor = index_FNCD(end-N_s+1:end);
    
    %% Statistics Mean Value
    Model_Dif      = mean(PopDec(Index_Well,:))-mean(PopDec(Index_Poor,:)); 
    Model_Dif_sort = sort(abs(Model_Dif),'descend');
    
    % Keep small probability for random dropout
    if rand > 0.2  
        Index_dif = find(abs(Model_Dif) >= Model_Dif_sort(ceil(beta*D)));
    else
        Index_dif = randi([1,D],1,ceil(beta*D));
    end
    
    %% Dropout d from D
    Decs_Surrogate = PopDec(:,Index_dif);
    Objs_Surrogate = Population.objs;
    
    %% Build RBF-Surrogate 
    for i = 1 : M
        RBF_para{i} = RBFCreate(Decs_Surrogate, Objs_Surrogate(:,i), 'cubic');
    end
   
    %% Reproduction
    Population      = EnvironmentalSelection(Population,NP);
    PopDec          = Population.decs;
    Pop_Surrogate   = Surrogate_individual(PopDec(:,Index_dif),Population.objs);
    Offspring_d     = Reproduction(Global,Pop_Surrogate,RBF_para,Index_dif);
    
    %% Replacement
    Offspring_d              = EnvironmentalSelection(Offspring_d,k);
    Offspring_D(:,Index_dif) = Offspring_d.decs;
    Offspring                = Offspring_D;
end