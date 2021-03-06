function varargout = msl_imana(what,varargin)
%function varargout = msl_imana(what,varargin)
% function motor sequence learning (msl) analysing imaging data
% ------------------------- General info ----------------------------------
baseDir ='/Users/eberlot/Documents/MATLAB/Projects/motor_sequence_learning/data';
surfDir = [baseDir '/surf'];
regname_Brodmann    = {'S1','M1','PMd','SPLa'};
regname_BG          = {'CaudateN','Putamen'};
nSeq = 12;
nSeq_trained = 6;
nRun = 8;
sn = 1:26;
% plotting styles
stySeq          = style.custom({'red','blue'},'markersize',6);
styReg          = style.custom({'green','blue','orange','magenta'},'markersize',6);
seqShadeErr     = style.custom({'red','blue'},'errorbars','shade','markersize',6);
blue            = [49,130,189]/255;
lightblue       = [158,202,225]/255;
red             = [222,45,38]/255;
lightred        = [251,177,168]/255;
seqShade        = style.custom({red,blue},'errorbars','shade','markertype','.');
seqShadeLight   = style.custom({lightred,lightblue},'errorbars','shade','markertype','.');
switch what
    case 'FIG:psc'
        % percent signal change
        parcelType = 'Brodmann';
        roi=1:4;
        sessN=1:3;
        vararginoptions(varargin,{'parcelType','sessN','roi'});
        
        T=load(fullfile(baseDir,sprintf('psc_%s.mat',parcelType)));
        figure
        indx=1;
        regLab = eval(sprintf('regname_%s',parcelType));
        T = normData(T,'psc');
        for r=roi
            subplot(1,numel(roi),indx)
            if numel(sessN)==4 % all sessions
                plt.line([T.sessN>3 T.sessN],T.normpsc,'split',T.seqType,'subset',T.roi==r,'leg',{'trained','untrained'},'leglocation','north','style',stySeq);
            elseif numel(sessN)==3 % sessions 1-3
                plt.line(T.sessN,T.normpsc,'split',T.seqType,'subset',T.roi==r&T.sessN<4,'leg',{'trained','untrained'},'leglocation','north','style',stySeq);
            elseif numel(sessN)==4 % sessions 3-4 (speed comparison)
                plt.line(T.sessN,T.normpsc,'split',T.seqType,'subset',T.roi==r&T.sessN>2,'leg',{'trained','untrained'},'leglocation','north','style',stySeq);
            end
            drawline(0,'dir','horz');
            plt.match('y');
            hold on;
            title(regLab{r});
            if r==1
                ylabel('Percent signal change');
                xlabel('Session');
            else
                ylabel('');
            end
            indx=indx+1;
        end
    case 'FIG:dist'
        % distances (dissimilarities) between sequences
        parcelType = 'Brodmann';
        roi=1:4;
        sessN=1:3;
        vararginoptions(varargin,{'parcelType','sessN','roi'});
        
        T=load(fullfile(baseDir,sprintf('dist_%s.mat',parcelType)));
        figure
        indx=1;
        regLab = eval(sprintf('regname_%s',parcelType));
        T = normData(T,'dist');
        for r=roi
            subplot(1,numel(roi),indx)
            if numel(sessN)==4 % all sessions
                plt.line([T.sessN>3 T.sessN],ssqrt(T.normdist),'split',T.seqType,'subset',T.roi==r,'leg',{'trained','untrained'},'leglocation','north','style',stySeq);
            elseif numel(sessN)==3 % sessions 1-3
                plt.line(T.sessN,ssqrt(T.normdist),'split',T.seqType,'subset',T.roi==r&T.sessN<4,'leg',{'trained','untrained'},'leglocation','north','style',stySeq);
            elseif numel(sessN)==2 % sessions 3-4 (speed comparison)
                plt.line(T.sessN,ssqrt(T.normdist),'split',T.seqType,'subset',T.roi==r&T.sessN>2,'leg',{'trained','untrained'},'leglocation','north','style',stySeq);
            end
            drawline(0,'dir','horz');
            plt.match('y');
            hold on;
            title(regLab{r});
            if r==1
                ylabel('Percent signal change');
                xlabel('Session');
            else
                ylabel('');
            end
            indx=indx+1;
        end
    case 'FIG:seqType_dist'
        % cosine dissimilarity between mean trained / untrained pattern
        sessN = 1:3;
        vararginoptions(varargin,{'sessN'});
        T = load(fullfile(baseDir,'seqType_cosine_Brodmann'));
        T = normData(T,'cos_seqType');
        figure
        if numel(sessN)==4 % all sessions
            plt.line([T.sessN>3 T.sessN],ssqrt(T.normcos_seqType),'split',T.roi,'leg',regname_Brodmann,'style',styReg);
        elseif numel(sessN)==3 % sessions 1-3
            plt.line(T.sessN,ssqrt(T.normcos_seqType),'subset',T.sessN<4,'split',T.roi ,'leg',regname_Brodmann,'style',styReg);
        elseif numel(sessN)==2 % sessions 3-4 (speed comparison)
            plt.line(T.sessN,T.normcos_seqType,'split',T.roi,'subset',T.sessN>2,'leg',regname_Brodmann,'style',styReg);
        end
        xlabel('Scan'); ylabel('Sequence type cosine dissimilarity');
    case 'FIG:MDS_dist'
        % multidimensional scaling plot on distances in PMd
        sessN = 1:3;
        T = load(fullfile(baseDir,'dist_cosine_sess'));
        RDM = mean(T.dist,1);
        sessV = kron((sessN)',ones(nSeq,1));
        Z1 = indicatorMatrix('identity_p',kron(ones(max(sessN),1),[ones(nSeq_trained,1);ones(nSeq_trained,1)*2]));
        Z2 = indicatorMatrix('identity_p',sessV);
        Z4 = indicatorMatrix('identity_p',kron(ones(max(sessN),1),(1:nSeq)'));
        [Y3,~,~]=rsa_classicalMDS(RDM,'mode','RDM','contrast',Z4);
        figure
        scatterplot3(Y3(:,1),Y3(:,2),Y3(:,3),'split',(kron(ones(max(sessN),1),[ones(6,1);ones(6,1)*2])),'markercolor',{'r','b'},'markerfill',{'r','b'});
        colS = {'r','b'};
        lineS = {'-','--','-.',':'};
        for i=1:2
            for j=1:max(sessN)
                hold on;
                indx=Z1(:,i)==1 & Z2(:,j)==1;
                line(Y3(indx,1),Y3(indx,2),Y3(indx,3),'LineStyle',lineS{j},'color',colS{i});
            end
        end;
    case 'FIG:act_profile'
        % activation profile for trained sequences in weeks 1 & 5 (paced)
        reg = 'M1';
        width = 15;
        sessN = [1,4];
        vararginoptions(varargin,{'reg'});
        switch reg
            case 'M1'
                from = [9 39];
                to = [19 105];
            case 'S1'
                from = [16 44];
                to = [38 102];
            case 'PMd'
                from = [-27 86];
                to = [6 82];
            case 'SPLa'
                from = [50 76];
                to = [114 121];
        end
        Y = cell(2,1);
        Yz = Y;
        for ss=1:numel(sessN)
            [Y{ss},~,~] = surf_cross_section(fullfile(surfDir,'fs_LR.164k.L.flat.surf.gii'),fullfile(surfDir,sprintf('sL.psc_trained.sess-%d.func.gii',sessN(ss))),'from',from,'to',to,'width',width);
            Yz{ss} = zscore(Y{ss});
        end
        figure
        traceplot(1:100,Yz{1}','errorfcn','nanstd','linecolor','b','linewidth',2,'patchcolor','b','transp',0.2);
        hold on;
        traceplot(1:100,Yz{2}','errorfcn','nanstd','linecolor','r','linewidth',2,'patchcolor','r','transp',0.2);
        drawline(0,'dir','horz'); title(sprintf('%s - sess-1-4 trained',reg));
    case 'FIG:PCM_correlation'
        % plot PCM correlation
        reg = 1:4;
        vararginoptions(varargin,{'reg','sessTr'});
        
        T=load(fullfile(baseDir,'PCM_corrModels.mat'));
        for r=reg
            t = getrow(T,T.roi==r);
            t.bayesEst_wm = bsxfun(@minus,t.bayesEst,mean(t.bayesEst,2));
            % reshape
            nModel          = size(t.bayesEst_wm,2);
            D.bayesEst      = t.bayesEst(:);
            D.bayesEst_wm   = t.bayesEst_wm(:);
            D.SN            = repmat(t.SN,nModel,1);
            D.sessTr        = repmat(t.sessTr,nModel,1);
            D.seqType       = repmat(t.seqType,nModel,1);
            D.model         = kron((1:nModel)',ones(size(t.bayesEst_wm,1),1));
            figure(1)
            subplot(1,numel(reg),find(r==reg))
            plt.line(D.model,D.bayesEst_wm,'split',[D.sessTr D.seqType],'subset',D.sessTr==1,'style',seqShade);
            hold on;
            style.use('SeqShade_light');
            plt.line(D.model,D.bayesEst_wm,'split',[D.sessTr D.seqType],'subset',D.sessTr==2,'style',seqShadeLight); legend off;
            drawline(0,'dir','horz');
            % here plot the peak lines
            tr = t.bayesEst_wm(t.sessTr==1 & t.seqType==1,:);
            [~,j]=max(mean(tr,1));
            drawline(mean(j),'dir','vert','color',red);
            utr = t.bayesEst_wm(t.sessTr==1&t.seqType==2,:);
            [~,j]=max(mean(utr,1));
            drawline(mean(j),'dir','vert','color',blue);
            xlabel('Model correlation'); ylabel('Evidence'); title(regname_Brodmann{r});
            t1 = gca;
            corrTick = linspace(min(t1.XTick),max(t1.XTick),11);
            set(gca,'XTickLabel',(0:.1:1),'XTick',corrTick);
        end
    case 'FIG:behaviour'
        % here plot behaviour
        T1 = load(fullfile(baseDir,'behaviour_training'));
        T2 = load(fullfile(baseDir,'behaviour_scanner'));
        T3 = load(fullfile(baseDir,'behaviour_tests'));
        figure
        subplot(131)
        plt.box(T3.day,T3.MT,'split',T3.seqType,'style',stySeq);
        title('behavior tests'); ylabel('Movement time (msec)'); xlabel('Test days');
        subplot(132)
        plt.box(T2.sessN,T2.MT,'split',T2.seqType,'plotall',0,'leg',{'trained','control'},'subset',T2.FoSEx==1,'style',stySeq);
        title('behavior in scanner'); ylabel(''); xlabel('Scanning days');
        subplot(133)
        plt.line([T1.day>6 T1.day],T1.MT,'style',seqShadeErr);
        xlabel('Training days'); title('training');  ylabel('');
        
    case 'PCM:corrModels'
        % assess correlation models for sequence pattern similarity across sessions
        runEffect   = 'random'; % random
        algorithm   = 'NR'; % minimize or NR
        reg         = 1:4;
        parcelType  = 'Brodmann';
        sessType    = 'transitions'; % options: relativeto1 or transitions
        sessTr      = 1:3;      % transitions
        corrLim     = [0 1];    % bounds for lower / upper correlation of models - change this to [-1 1]!!!
        nModel      = 30;       % number of correlation models (determines how fine grained the corr estimates are)
        withinCov   = 'individual'; % covariance type: individual or iid
        vararginoptions(varargin,{'reg','sessTr','algorithm','parcelType','withinCov','nModel','sessType'});
        AllSess=[];
        
        partV = kron((1:nRun)',ones(nSeq,1));
        condV = kron(ones(nRun,1),(1:nSeq)');
        seqIdx = (condV>6)+1;
        for str = sessTr % session transition
            AllReg = [];
            % construct models
            corrS = linspace(corrLim(1),corrLim(2),nModel); % correlation models to assess
            for c=1:length(corrS)
                M{c} = pcm_buildCorrModel('type','nonlinear','withinCov',withinCov,'numCond',2,'numItems',nSeq_trained,'r',corrS(c));
            end
            switch sessType
                case 'transitions'
                    sessN = [str str+1];
                case 'relativeto1'
                    sessN = [1 str+1];
            end
            B = cell(length(sessN),1);
            for ss=1:numel(sessN)
                B{ss}=load(fullfile(baseDir,'group',sprintf('betas_%s_sess%d.mat',parcelType,sessN(ss)))); % beta directory
            end
            for r = reg
                for st=1:2 % per seqType
                    tstart = tic;
                    condVec = cell(1,length(sn));
                    partVec = condVec; Data = condVec; % initialise
                    for p=1:length(sn)
                        for ss = 1:numel(sessN)
                            t = getrow(B{ss},B{ss}.SN==sn(p) & B{ss}.region==r);
                            beta = t.betaW{:}; % multivariately prewhitened betas
                            indx = seqIdx==st;
                            if ss == 1
                                condVec{p}  = condV(indx==1,:); % conditions
                                partVec{p}  = partV(indx==1,:);
                                Data{p}     = beta(indx==1,:);  % Data is N x P (cond x voxels) - no intercept
                            else
                                condVec{p}  = [condVec{p}; condV(indx==1,:)+6]; % treat 2nd session as additional conditions
                                partVec{p}  = [partVec{p}; partV(indx==1,:)+8];  % runs/partitions of 2nd session as additional runs
                                Data{p}     = [Data{p}; beta(indx==1,:)];  % Data is N x P (cond x voxels) - no intercept
                                condVec{p}  = condVec{p}-(min(condVec{p})-1); % to correct for untrained patterns - index from 1
                            end;
                        end; % session
                    end; % subj
                    % run the correlation model
                    T = msl_imana('PCM:corrModel_run','Data',Data,'model',M,'partV',partVec,'condV',condVec,'algorithm',algorithm,'runEffect',runEffect);
                    % other variables of interest
                    T.roi                   = ones(size(T.SN))*r;
                    T.regType               = ones(size(T.SN))*t.regType;
                    T.regSide               = ones(size(T.SN))*t.regSide;
                    T.seqType               = ones(size(T.SN))*st;
                    T.sessTr                = ones(size(T.SN))*str;
                    T = rmfield(T,'reg');
                    AllReg = addstruct(AllReg,T);
                    fprintf('Done modelType: %s seqType %d sess: %d-%d reg: %d/%d\n\n',withinCov,st,sessN(1),sessN(2),r,length(reg));
                    toc(tstart);
                end; % seqType
                fprintf('Done reg %d/%d:\tmodelType: %s \tsess: %d-%d\n\n',r,numel(reg),withinCov,sessN(1),sessN(2));
            end; % region
            fprintf('Done all:\tmodelType: %s \tsess: %d-%d\n\n\n\n',withinCov,sessN(1),sessN(2));
            AllSess = addstruct(AllSess,AllReg);
        end; % session transition
        % save output
        save(fullfile(baseDir,'PCM_corrModels.mat'),'-struct','AllSess');
    case 'PCM:corrModel_run'
        algorithm='NR';
        runEffect = 'random'; % random or fixed
        vararginoptions(varargin,{'Data','model','partV','condV','runEffect','algorithm'});
        [T,~] = pcm_fitModelGroup(Data,model,partV,condV,'runEffect',runEffect,'fitAlgorithm',algorithm,'fitScale',1);
        T.bayesEst = bsxfun(@minus,T.likelihood,T.likelihood(:,1)); % now relative to model with 0 correlation
        varargout{1}=T;
        
    case 'DIST:cosine_acr_sess'
        % calculate cosine distances across sessions - used in MDS_dist
        roi=3; %PMd
        sessN=1:3;
        parcelType = 'Brodmann';
        
        vararginoptions(varargin,{'roi','sessN','parcelType'});
        TT = []; NN = [];
        for ss=sessN
            T=load(fullfile(betaDir,'group',sprintf('betas_%s_sess%d.mat',parcelType,ss)));
            T.sessN = ones(size(T.SN))*ss;
            TT = addstruct(TT,T);
        end
        for s=sn
            for r=roi
                t = getrow(TT,TT.SN==s&TT.region==r);
            end
        end
        for r=roi
            for s=sn
                D = getrow(TT,TT.region==r & TT.SN==s);
                if max(sessN)==4
                    beta = [D.betaW{1}(1:96,:);D.betaW{2}(1:96,:);D.betaW{3}(1:96,:);D.betaW{4}(1:96,:)];
                    condV = [kron(ones(nRun,1),(1:12)');kron(ones(nRun,1),(13:24)');kron(ones(nRun,1),(25:36)');kron(ones(nRun,1),(37:48)')];
                elseif max(sessN)==3
                    beta = [D.betaW{1}(1:96,:);D.betaW{2}(1:96,:);D.betaW{3}(1:96,:)];
                    condV = [kron(ones(nRun,1),(1:12)');kron(ones(nRun,1),(13:24)');kron(ones(nRun,1),(25:36)')];
                else
                    error('wrong number of sessions!');
                end
                partV = repmat(kron((1:8)',ones(12,1)),max(sessN),1);
                G = pcm_estGCrossval(beta,partV,condV);
                dist = msl_imana('DIST:calc_cosine',G);
                N.dist = dist;
                N.sn = s;
                N.roi = r;
                NN = addstruct(NN,N);
            end
        end
        save(fullfile(baseDir,'dist_cosine_sess'),'-struct','NN');
    case 'DIST:calc_cosine'
        % calculate cosine distances
        G = varargin{1};
        numCond = size(G,1);
        % prep output matrix
        out = zeros(numCond,numCond);
        % calculate pairwise cosine distances
        for n = 1:numCond
            for nN = n+1:numCond
                if G(n,n)<0.00001 % regulize in case negative values in crossval G
                    G(n,n)=0.00001;
                end
                if G(nN,nN)<0.00001
                    G(nN,nN)=0.00001;
                end
                out(nN,n) = (1 - (G(n,nN)/sqrt(G(n,n)*G(nN,nN))))/2;
            end
        end
        % vectorize output matrix
        varargout{1} = rsa_vectorizeRDM(out);
    case 'DIST:cosine_seqType'
        % calculate cosine dissimilarity between mean trained / untrained
        reg = 1:4;
        sessN = 1:4;
        parcelType = 'Brodmann';
        vararginoptions(varargin,{'sn','reg','sessN','parcelType'});
        STAll= [];
        partVec = kron((1:nRun)',ones(nSeq,1));
        condVec = kron(ones(nRun,1),(1:nSeq)');
        for  ss = sessN
            D   = load(fullfile(betaDir,'group',sprintf('betas_%s_sess%d.mat',parcelType,ss)));
            if strcmp(regType,'all')
                reg = unique(D.regType(D.regSide==h))';
            end
            for roi = reg;
                sprintf('Done regions:');
                for s = sn;
                    t   = getrow(D,D.regType==roi & D.regSide==1 & D.SN==s);
                    data = t.betaW{1}(1:size(partVec,1),:);
                    % crossval second moment matrix
                    [G,~]     = pcm_estGCrossval(data,partVec,condVec);
                    C = msl_imana('DIST:calc_cosine',G);
                    C = rsa_squareRDM(C);
                    % average distance between trained / untrained
                    ST.cos_seqType  = sum(sum(triu(C(7:12,1:6))))/(6*5);
                    ST.sessN        = ss;
                    ST.roi          = roi;
                    ST.regType      = t.regType;
                    ST.regSide      = t.regSide;
                    ST.sn           = s;
                    STAll = addstruct(STAll,ST);
                end
                fprintf('%d.',roi);
            end
            fprintf('\nDone sess%d.\n',ss);
        end
        save(fullfile(baseDir,sprintf('seqType_cosine_%s.mat',parcelType)),'-struct','STAll');
    case 'DIST:calc_crossnobis'
        % calculate crossnobis distance of patterns between sequences
        roi = 1:4;
        sessN = 1:4;
        betaChoice = 'multiPW';
        parcelType = 'Brodmann';
        vararginoptions(varargin,{'sn','roi','sessN','betaChoice','parcelType'});
        
        Stats = [];
        for ss=sessN
            T = load(fullfile(betaDir,'group',sprintf('stats_%s_%s_sess%d.mat',parcelType,betaChoice,ss))); % loads region data (D)
            for s=sn
                for r=roi
                    R = getrow(T,T.regType==r & T.SN==s & T.regSide==h);
                    S.dist    = [R.dist_train; R.dist_untrain];
                    S.seqType = [1;2];
                    S.sn      = [s;s];
                    S.roi     = [r;r];
                    S.sessN   = [ss;ss];
                    Stats = addstruct(Stats,S);
                end
            end
        end
        % save structure
        save(fullfile(baseDir,sprintf('dist_%s',parcelType)),'-struct','Stats');
        
    case 'PSC:save'
        % percent signal change - as calculated on contrast maps from SPM
        roi = 1:4;
        sessN = 1:4;
        parcelType='Brodmann';
        vararginoptions(varargin,{'roi','sessN','parcelType'});
        
        Stats = [];
        for ss=sessN
            T = load(fullfile(betaDir,'group',sprintf('betas_%s_sess%d.mat',parcelType,ss))); % loads region data (T)
            for s=sn
                for r=roi
                    for h=hemi
                        R = getrow(T,T.regType==r & T.SN==s & T.regSide==1);
                        S.psc(1,:)  = nanmean(R.psc_train{1});
                        S.psc(2,:)  = nanmean(R.psc_untrain{1});
                        S.seqType   = [1;2];
                        S.sn        = repmat(R.SN,2,1);
                        S.roi       = repmat(R.region,2,1);
                        S.sessN     = repmat(ss,2,1);
                        % save into a new structure
                        Stats=addstruct(Stats,S);
                    end
                end
            end
            fprintf('Done session %d.\n',ss);
        end
        % save structure
        save(fullfile(baseDir,sprintf('psc_%s',parcelType)),'-struct','Stats');
    case 'BETA:extract'
        % extract betas from glm SPM.mat
        sessN = 1:4;
        roi = 1:8;
        parcelType = 'Brodmann'; % Brodmann, BG-striatum tesselsWB_162
        vararginoptions(varargin,{'sn','sessN','roi','parcelType'});
        for ss=sessN
            % harvest
            for s=sn % for each subj
                T=[];
                fprintf('\nSubject: %d\n',s) % output to user
                fprintf('Starting to extract betas...\n');
                tElapsed=tic;
                % load files
                load(fullfile(glmSessDir{ss},subj_name{s},'SPM.mat'));  % load subject's SPM data structure (SPM struct)
                load(fullfile(regDir,[subj_name{s} sprintf('_%s_regions.mat',parcelType)]));  % load subject's region parcellation (R)
                cd (fullfile(glmSessDir{ss},subj_name{s})); % maybe change back when remove glm
                % Add a few extra images
                %----task against rest
                O{1}=sprintf('psc_sess%d_TrainSeq.nii',ss); %psc trained
                O{2}=sprintf('psc_sess%d_UntrainSeq.nii',ss); %psc untrained
                oP=spm_vol(char(O));
                
                V = SPM.xY.VY;
                for r = roi % for each region
                    % get raw data for voxels in region
                    % determine if any voxels for that parcel
                    Y = region_getdata(V,R{r},'verbose',0);  % Data Y is N x P
                    data = region_getdata(oP,R{r}); % from added images
                    %     betaRaw = region_getdata(P,R{r});
                    % exclude any missing data in voxels
                    idx = find(Y(1,:));
                    % estimate region betas
                    [betaW,resMS,~,beta] = rsa.spm.noiseNormalizeBeta(Y(:,idx),SPM,'normmode','overall');
                    S.betaW                   = {betaW};                             % multivariate pw
                    S.betaUW                  = {bsxfun(@rdivide,beta,sqrt(resMS))}; % univariate pw
                    S.betaRAW                 = {beta};
                    S.resMS     = {resMS};
                    % info from maps for surface
                    S.psc_train         = {data(1,idx)};
                    S.psc_untrain       = {data(2,idx)};
                    % voxel position
                    S.volcoord = {R{r}.data(idx,:)'};
                    S.SN = s;
                    S.region = r;
                    T = addstruct(T,S);
                    fprintf('%d.',r);
                    clear idx Y data betaW beta resMS;
                    %fprintf('elapsed %d\n',telapsed);
                end
                dircheck(fullfile(betaDir,subj_name{s}));
                save(fullfile(betaDir,subj_name{s},sprintf('betas_%s_%s_sess%d.mat',parcelType,subj_name{s},ss)),'-struct','T');
                fprintf('\nDone beta extraction for sess%d-%s\n',ss,subj_name{s}); toc(tElapsed);
            end
        end
    case 'BETA:combineGroup'
        % combine individual subject beta structures into a group structure
        sessN=1:4;
        parcelType='Brodmann';
        vararginoptions(varargin,{'sessN','parcelType'});
        for ss=sessN
            fprintf('subjects added for sess-%d:\n',ss);
            T = [];
            for s=sn
                S=load(fullfile(betaDir,subj_name{s},sprintf('betas_%s_%s_sess%d',parcelType,subj_name{s},ss)));
                T=addstruct(T,S);
                fprintf('%d.',s);
            end
            save(fullfile(betaDir,'group',sprintf('betas_%s_sess%d.mat',parcelType,ss)),'-struct','T','-v7.3');
        end
    case 'BETA:stats'
        % statistics on betas
        sessN = 1:4;
        roi = 1:4;
        betaChoice = 'multi'; % take multivariately prewhitened betas for distance estimates
        parcelType = 'Brodmann'; % or Brodmann, tesselsWB_162
        vararginoptions(varargin,{'sn','sessN','roi','betaChoice','parcelType'});
        
        partV = kron((1:nRun)',ones(nSeq,1));
        condV = kron(ones(nRun,1),(1:nSeq)');
        for ss=sessN
            T = load(fullfile(betaDir,'group',sprintf('betas_%s_sess%d.mat',parcelType,ss))); % loads region data (T)
            To = [];
            % do stats
            for s = sn % for each subject
                fprintf('\nSubject: %d session: %d\n',s,ss)
                for r = roi % for each region
                    S = getrow(T,(T.SN==s & T.region==r)); % subject's region data
                    fprintf('%d.',r)
                    switch (betaChoice)
                        case 'uni'
                            betaW  = S.betaUW{1};
                        case 'multi'
                            betaW  = S.betaW{1};
                        case 'raw'
                            betaW  = S.betaRAW{1};
                    end
                    % crossval second moment matrix
                    [G,Sig]     = pcm_estGCrossval(betaW(1:size(partV,1),:),partV,condV);
                    So.IPM      = rsa_vectorizeIPM(G);
                    So.Sig      = rsa_vectorizeIPM(Sig);
                    So.IPMfull  = rsa_vectorizeIPMfull(G);
                    % squared distances
                    RDM = rsa.distanceLDC(betaW(1:size(partV,1),:),partV,condV);
                    RDM = rsa_squareRDM(RDM);
                    So.dist_trained = nanmean(rsa_vectorizeRDM(RDM(1:6,1:6)));
                    So.dist_untrained = nanmean(rsa_vectorizeRDM(RDM(7:12,7:12)));
                    % stats from additional images
                    So.psc_train = nanmean(S.psc_train{:});
                    So.psc_untrain = nanmean(S.psc_untrain{:});
                    % indexing fields
                    So.SN       = s;
                    So.region   = r;
                    % data structure
                    To = addstruct(To,So);
                end; % each region
            end; % each subject
            save(fullfile(betaDir,'group',sprintf('stats_%s_%sPW_sess%d.mat',parcelType,betaChoice,ss)),'-struct','To');
        end
        
    otherwise
        error('No such case!');
end
        