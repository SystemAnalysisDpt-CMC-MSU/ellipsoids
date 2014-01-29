function Data=genteststruct(inpNum)
% GENTESTSTRUCT generates a complex test structure using input number to
% guarantee a uniqueness
%
% Input:
%   regular:
%       inpNum: numeric[1,1] - input number
%
% Output:
%   Data: struct[1,1] - resulting structure
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-06-05 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
Data.dConf.gen.curRevision=19641;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%
%% ----------------------------------General settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% number of processor used (increase of this parameter may lead to speeding
% up some of blocks)
Data.dConf.gen.nProcessors=2;

%% Data.dConf.gen.input.database
Connectors(1).type='mym'; % matlab4b
Connectors(1).sourceName='production_1_8_all';
Connectors(1).hostName='model4a'; % dont forget to run putty!
Connectors(1).login='root';
Connectors(1).password='matlab4a';
%
Connectors(2).type='mym'; %penguin for pe funds
Connectors(2).sourceName='production_1_8_all';
Connectors(2).hostName='10.100.8.35';
Connectors(2).login='root';
Connectors(2).password='rico';
%
Data.dConf.gen.connectors=Connectors;
% the name of the configuration that is loaded from database
Data.dConf.gen.configurationNames={'sysrep_hor_3_15_maws_80_block_useexisting'};
Data.dConf.gen.configurationXmlFiles={inpNum};
%
%
% each configuration has a version (major and minor)
% describing its creation method
% RelVal has a major configuration version number,
% loading configurations with different major version numbers
% than Data.dConf.gen.configurationMajorVersion results in an error
Data.dConf.gen.configurationMajorVersion=1;
%
%
%penguin production database
Data.dConf.gen.input.gen.connector=2;
%
%
%assets to be TRADED - a subset of assets to be pulled from the database
%for future - time of historical database update by the Revolver based on
%data recorded intra-day
Data.dConf.gen.input.realtime.quotesFileName='quotes.mat';
Data.dConf.gen.input.realtime.quotesFieldNames={...
    'askPrice','askSize','bidPrice','bidSize','lastPrice','lastSize','midAvgPrice'...
    };
Data.dConf.gen.input.realtime.tradesFileName='trades.mat';
%
Data.dConf.gen.input.realtime.instHeatRateFileName='heatrate.mat';
%
%% Data.dConf.gen.cdefs.gen
%
Data.dConf.gen.cdefs.gen.instTypeName={'futures','call','put'};
Data.dConf.gen.cdefs.gen.instTypeCode={'Future','Call','Put'};
%
%
Data.dConf.gen.cdefs.gen.somethingDummy={'Future','Call','Put';...
    'Future2','Call1','3'};
%
%% Data.dConf.gen.cdefs.pairType
%relationships between pairs analyzed as a part of pair-wise method based
%on heat-rate modelling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ---------------------------------Backtest settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% a directory where the software stores transitional probability matrices
% of mean reversion estimates - BACKTEST mode
if ispc
    Data.dConf.backtest.output.gen.dumpDir='.\DumpBKT\';
else
    Data.dConf.backtest.output.gen.dumpDir='./DumpBKT/';
end

%a directory, where backtest stores its cached sqlqueries
Data.dConf.backtest.input.gen.dumpDir=['test' filesep 'DumpBKT' filesep];

Data.dConf.backtest.gen.isRecoveredFromDump=0;
% options of saving results of experiments (used in behavioral testing
% harness)
Data.dConf.backtest.gen.scenarioName='backtest_testing';
Data.dConf.backtest.gen.isSavedToDB=1; % save in database
Data.dConf.backtest.gen.isSavedToFile=1; % save in .exps file
% list of paths in from Data.dCalc.backtest.tradingAct that should be
% saved in universal structure of experiment
Data.dConf.backtest.gen.resPathList={'gen','portfolio','pair.positions','asset.positions'};
% directory in which results of experiments will be stored
%
Data.dConf.backtest.gen.resDir=['test' filesep '..' filesep '..' filesep 'EExplorer/Experiment_base' filesep];
%
%% backtest sharing setting
% if true, skip sharing,
Data.dConf.backtest.calc.sharing.isSharing=0;
Data.dConf.backtest.calc.sharing.sharingFolder=['test' filesep 'DumpBKT\share'];
% do perform some testing checks upon sharing,
Data.dConf.backtest.calc.sharing.isTestMode=0;

%% backtest sql caching setting

Data.dConf.backtest.input.database.sqlCaching.cacheDir=['test' filesep 'DumpBKT/sql' filesep];
Data.dConf.backtest.input.database.sqlCaching.isCaching=0;
%
%% Do not place on GUI

%
% minimal interval of non-missed quotes for pair to be admissible; this
% interval begins with first non-missed quote and ends at the last day when
% both assets of pair are not yet expired
%
%% Place on GUI
%defualt dates of subset of backtyest period to be run - has to be inside
%the total period specified earlier in the file. These dates can be changed
%on the screen, but will come back to default every time the system is
%re-started

%Data.dConf.backtest.calc.gen.startDate=datenum('01/1/2006');
%Data.dConf.backtest.calc.gen.endDate=datenum('08/1/2006');

%subest history and future term structures used for estimation - same
%relationships to overall history and screen changes as dates above
% backtest portion of transactiopn cost expected to be paid when exiting from
% position
%backtest number of times a year when gains are distributed to investors and assets
%under management reduced back to initial asset base
% probability for pair PnL outliers
%
%% Data.dConf.backtest.calc.missedQuotesRecovery
%

%% Data.dConf.backtest.calc.portfBkg
%
%
%% Data.dConf.backtest.calc.pairForecast
%
%
% if isTestMode is nonzero, then the following parameter determine the list
% of pairs that would be forecasted in special mode and such that only
% they would be tradable and may be saved in results of experiment and so
% on; selectedPairNames is cell array of strings and has two rows and
% nPairs columns, each column corresponds to each pair (or set of pairs),
% in each cell it is possible to set both commodity type (something like
% 'NG') and commodity type and year (something like 'NG7') and asset
% (something like 'NG7K'), moreover, it is possible for pair to set, say,
% commodity type versa some asset, for instance, {'PJM';'NG7K'}, then all
% pairs such that their first lag has PJM as underlying commodity and their
% second lag is exactly 'NG7K' would be selected; if this list is empty,
% then all pairs are tradable by default
%
% Remark: 1) If selectedPairNames is nonempty, i.e. we do select some pairs
%            as tradable, then logit regression would be estimated only for
%            these pairs only in the case forecastBasisMode (see below) is
%            equal to 'full'
%         2) The mode in which selected pairs are forecasted is determined
%            by the value of isTestMode parameter, the possible values are
%            as following:
%               a) 1 or 2 --- then the logit regression parameters are
%                  estimated only for selected pairs with given test mode
%               b) 3 --- then the logit regression parameters are estimated
%                  only for selected pairs with non-test mode
%         3) If forecastBasisMode (see below) is equal to 'full' and the
%            system does select some pairs, then forecasting basis used to
%            determine metrics of portfolio is constructed without
%            taking into account of cointegration constraints
Data.dConf.backtest.calc.pairForecast.gen.pair.selectedPairNames={};%...
%    [{'PJM';'PJM'} {'PJM';'NG'} {'PJM';'CL'} {'PJM';'HO'} {'PJM';'NYA'}...
%     {'NYA';'NG'} {'NYA';'NYA'} {'PJM';'NEPool'} {'NEPool';'NG'}...
%     {'NEPool';'CL'} {'NEPool';'HO'} {'NEPool';'NYA'} {'NEPool';'NEPool'}];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hedgeRatio method parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.coint.methods.hedgeRatio.param=[];

% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.coint.methods.cointBasis.param.isConstrApplied=true;
%matrix that determines drivers between different commodity types for
%equal maturities, 1 is set if first lag (row) is a driver for second
%lag (colum), 0 otherwise
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.coint.methods.cointBasis.param.constr.eqMaturityDriver=[...
...%NG  PJM   CL   HU   HO   NYA   NEPool
    %         0     1    0    0    0     1        1;... %NG
%         0     0    0    0    0     1        1;... %PJM
%         0     1    0    0    1     0        0;... %CL
%         0     0    0    0    0     0        0;... %HU
%         0     0    0    0    0     0        1;... %HO
%         0     0    0    0    0     0        0;... %NYA
%         0     0    0    0    0     0        0];   %NEPool
%constraint applied when month of given commodity type (typeId) is in
%the given range (monthNum); month contract drives all contracts of
%the same type and the same season and months from monthDriven list
% StIntratypeMonthDriver=struct('typeId',[],'monthNum',[],'monthDriven',[]);
%
% StIntratypeMonthDriver(1).typeId='NG';
% StIntratypeMonthDriver(1).monthNum=[11 12 1 2 3];
% StIntratypeMonthDriver(1).monthDriven=[11 12 1 2 3];
% %
% StIntratypeMonthDriver(2).typeId='NG';
% StIntratypeMonthDriver(2).monthNum=3;
% StIntratypeMonthDriver(2).monthDriven=4;
% %
% StIntratypeMonthDriver(3).typeId='NG';
% StIntratypeMonthDriver(3).monthNum=[4 5 6 7 8 9 10];
% StIntratypeMonthDriver(3).monthDriven=[4 5 6 7 8 9 10];
% %
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.coint.methods.cointBasis.param.constr.intratypeMonthDriver=StIntratypeMonthDriver;
%all pairs between two commodity types (i.e. for all combinations of
%maturities) are taken if 1 (this constraint override all preceding
%constraints in this case), otherwise only those pairs are constructed that
%are determined by preceding constraints above
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.coint.methods.cointBasis.param.constr.allPairs=[...
%     ...%NG  PJM   CL   HU   HO   NYA   NEPool
%         0     0    0    0    0     0        0;... %NG
%         0     0    0    0    0     0        0;... %PJM
%         0     0    1    0    0     0        0;... %CL
%         0     0    0    0    0     0        0;... %HU
%         0     0    0    0    0     0        0;... %HO
%         0     0    0    0    0     0        0;... %NYA
%         0     0    0    0    0     0        0];   %NEPool
%method for determining size of moving window used in cointegration
%framework
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.coint.methods.cointBasis.param.cointWindSize.curMethod='fixedDate';
%in this method the size of the moving window is determined as difference
%between the total number of historical observations and given subtrahend,
%if it is equal to 0, then we take the size of the moving window equal to
%the total number of historical observations
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.coint.methods.cointBasis.param.cointWindSize.methods.histMinusLast.param.subtrahend=0;
%in this method the size of the moving window is determined by fixed
%calendar date, i.e. the size of the window coincides with the number of
%available observations up to startDate
%Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.coint.methods.cointBasis.param.cointWindSize.methods.fixedDate.param.startDate=datenum('22-May-2007');
% in this method the size of the moving window is given explicitely
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.coint.methods.cointBasis.param.cointWindSize.methods.exact.param.windSize=1000;
%
% %% new prob calc settings
% number of lags in estimation of meanDec
Data.dConf.backtest.calc.pairForecast.meanDec.nLags=120+inpNum;
Data.dConf.realtime.calc.pairForecast.meanDec.nLags=120;
% aggr. size (number of lags in aggr. interval)
Data.dConf.backtest.calc.pairForecast.meanDec.aggrSize=30;
Data.dConf.realtime.calc.pairForecast.meanDec.aggrSize=30;
% number of points in empirical distribution of residuals
Data.dConf.backtest.calc.pairForecast.meanDec.nPoints=10;
Data.dConf.realtime.calc.pairForecast.meanDec.nPoints=10;
% use aux variable or not in creation of armaforecast class
Data.dConf.backtest.calc.pairForecast.meanDec.isUseAuxVar=0;
Data.dConf.realtime.calc.pairForecast.meanDec.isUseAuxVar=0;
% work with logitautoregress class or not (used in test script of
% armaforecast class)
Data.dConf.backtest.calc.pairForecast.meanDec.isUseLogitClass=1;
Data.dConf.realtime.calc.pairForecast.meanDec.isUseLogitClass=1;
%% Probability calculation settings
%
%method for determining size of moving window used in discrete
%approximation performed for estimation of transitional probabilities via
%multinomial logit regression
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.discrWindSize.curMethod='fixedDate';
%in this method the size of the moving window is determined as difference
%between the total number of historical observations and given subtrahend,
%if it is equal to 0, then we take the size of the moving window equal to
%the total number of historical observations
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.discrWindSize.methods.histMinusLast.param.subtrahend=0;
%in this method the size of the moving window is determined by fixed
%calendar date, i.e. the size of the window coincides with the number of
%available observations up to startDate
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.discrWindSize.methods.fixedDate.param.startDate=datenum('20-Feb-2007');
% in this method the size of the moving window is given explicitely
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.discrWindSize.methods.exact.param.windSize=250;
%determines mode for calculation of transitional probabilities matrix and
%use of already calculated one (if it exists); if it is 'calc', then matrix
%is calculated anyway, if it is 'request', then user is requested what to
%do, if it is 'useexisting', then user is not requested what to do, matrix
%is calculated only in the case when there is no calculated one that may be
%used, 'useexact' means almost the same as 'useexisting' save the existing
%matrix is used ONLY when its status is 1 (i.e. it was calculated for all
%groups)
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.probCalcMode='calc';%/{'calc','request','useexisting','useexact'}
%determines whether outliers in deviation from short-term trend (i.e.
%deviations that do not lie in the interval plus-minus 3*sigma from
%short-term trend) are truncated or not according to the probability
%partitioning constructed during discretization
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.isDevTruncated=false;
%maximum transition horizon used in forecasting
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.horizonList=[2 3 5 8 10 15 22];
%number of lags used in multilogit regression
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.nLags=25;
%ratio used for calculation of maximum adverse movement according to
%formula maxAdvMove=std2advMoveRatio*pairPriceStd;
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.std2advMoveRatio=3/4;
%window size for moving standard deviation calculation
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.stdWindowSize=40;
%probability level specifying the width of trading channel
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.channelProbWidth=0.8;
%probability distribution specifying the regimes- DO NOT EDIT
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.probPart=[0.05 0.05 nan 0.05 0 0.05 nan 0.05 0.05];
%Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.probPart=[0.1 0.1 nan 0.075 0 0.075 nan 0.1 0.1];
%window size for predictability error calculation
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.errWindowSize=100;
%size of shift (in days) that is used for predictability error calculation
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.errWindowShift=5;
%window size for probability matrices calculation
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.probWindowSize=5*250;
%window size for trend calculation in form of MA (when is fixed for all
%pairs
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.windSizeCalc.methods.fixed.maWindowSize=150;
%window calculation method
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.windSizeCalc.curMethod='fixed';%groupAndPairOptimal,groupOptimal,fixed
%
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.windSizeCalc.gen=[];
% minimal possible optimal window size for calc. MA (groups & pairs)
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.windSizeCalc.methods.groupAndPairOptimal.minWindowSize=6;
% maximal possible optimal window size for calc. MA (groups & pairs)
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.windSizeCalc.methods.groupAndPairOptimal.maxWindowSize=100;
% horizon for calculating metrics (groups & pairs)
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.windSizeCalc.methods.groupAndPairOptimal.horizon=5;
% minimal possible optimal window size for calc. MA (groups)
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.windSizeCalc.methods.groupOptimal.minWindowSize=6;
% maximal possible optimal window size for calc. MA (groups)
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.windSizeCalc.methods.groupOptimal.maxWindowSize=100;
% horizon for calculating metrics (groups)
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.windSizeCalc.methods.groupOptimal.horizon=5;
%window size for smoothing in form of MA appropriate is in [1,3]
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.maSmoothWindowSize=[];
%length (in days) of probability calculation period
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.probCalcPeriod=5;
%method of the transitional probabilities calculation - 'discrete' means we use
%discrete time series (cathegories) both for forecasted and observed values
%in multinomial logistic regresssion; 'semidiscrete' means we use discrete
%values (cathegories) for forecasted values and continuous values
%(normalized deviations from short-term trend) for observed time series
% Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.probCalcScheme='semidiscrete';%/{'discrete','semidiscrete'}
%weights for last days in multinomial logistic regression, temporarily unique for all
%pair types
Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.probGroup.curMethod='transProbGroups';
Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.probGroup.methods.transProbGroups.param.yearWeights=[0.05 0.1 0.175 0.275 0.4]+inpNum;
%method of the returns calculation - 'instant' means we use only one lags
%while 'full' means we forecast each horizon separately. Use full - for
%real-time. Get better quality returns!
Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.retCalcScheme='full';%/{'instant','full'}
%method of score processing - 'none' means that no processing of score is
%performed, 'pricecorridor' means that method based on change of
%current price corridor is used
Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.scoreProc.curMethod='priceCorridor';%/{'none','priceCorridor'}
%determines whether each price corridor have fixed center or it is
%determined at each iteration automatically (for backtest it is false,
%thus, the center is determined by the last price on which score is based)
Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.scoreProc.methods.priceCorridor.param.isCenterFixed=false;
%multiplier coefficient determining width of price corridor, that is
%calculated as pair bid-ask spread multiplied by its value
Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.scoreProc.methods.priceCorridor.param.corridorMultCoeff=...
    [1.5;1.5;1.5;1.5;1.5;1.5;1.5;1.5;1.5;1.5;1.5;1.5;1.5;1.5;1.5;1.5;1.5;1.5;1.5;1.5;1.5;1.5;1.5;1.5;1.5;1.5;1.5;1.5]+inpNum;
%names of regimes used for testing purposes
Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.regNames=...
    {'StrDevDown',...
    'DevDown',...
    'ModDevDown',...
    'Eq',...
    'ModDevUp',...
    'DevUp',...
    'StrDevUp'};

% method of choice of basis for forecasting of returns - 'auxBasis' means
% we use special auxiliary forecasting basis to calculate returns while
% 'full' means we forecast all yet non-expired pairs and 'cointConstr'
% means we forecast only those non-expired pairs for which cointegration
% constrains are true (see above for details)
%Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.forecastBasisMode='full';%/{'auxBasis','full','cointConstr'}
% parameters that may influence on probability matrix (saved in cache for
% filtering); if path includes as its part ".backtest." or ".realtime.",
% this part should be changed on ".(curMode).", path must be absolute,
% i.e. should start from "Data.dConf."
Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.probMatParamPaths={...
    'Data.dInput.configuration.configurationStruct.modules.generalProperties.modules.database',...
    'Data.dInput.configuration.configurationStruct.modules.generalProperties.gen.common.instMode',...
    'Data.dInput.configuration.configurationStruct.modules.forecastingProperties.modules.trendDev.methods.transProb.gen.common.className',...
    'Data.dInput.configuration.configurationStruct.modules.forecastingProperties.modules.trendDev.methods.transProb.gen.common.forecastPairMode',...
    'Data.dInput.configuration.configurationStruct.modules.forecastingProperties.modules.trendDev.methods.transProb.gen.common.outliersWindowSize',...
    'Data.dConf.gen.input.gen.typeId',...
    'Data.dConf.gen.input.gen.nHistTerms',...
    'Data.dConf.gen.input.gen.nMaxTTM',...
    'Data.dConf.gen.input.gen.nMinHistQuotes',...
    'Data.dConf.(curMode).calc.gen.nHistTerms',...
    'Data.dConf.(curMode).calc.gen.nMaxTTM',...
    'Data.dConf.(curMode).calc.pairForecast.gen.useAllHist',...
    'Data.dConf.(curMode).calc.pairForecast.gen.pair.typeComb',...
    'Data.dConf.(curMode).calc.pairForecast.methods.transProb.pair.prob.discrWindSize',...
    'Data.dConf.(curMode).calc.pairForecast.methods.transProb.pair.prob.isDevTruncated',...
    'Data.dConf.(curMode).calc.pairForecast.methods.transProb.pair.prob.horizonList',...
    'Data.dConf.(curMode).calc.pairForecast.methods.transProb.pair.prob.nLags',...
    'Data.dConf.(curMode).calc.pairForecast.methods.transProb.pair.prob.probPart',...
    'Data.dConf.(curMode).calc.pairForecast.methods.transProb.pair.prob.probWindowSize',...
    'Data.dConf.(curMode).calc.pairForecast.methods.transProb.pair.prob.windSizeCalc',...
    'Data.dConf.(curMode).calc.pairForecast.methods.transProb.pair.prob.maSmoothWindowSize',...
    'Data.dConf.(curMode).calc.pairForecast.methods.transProb.pair.prob.probCalcScheme',...
    'Data.dConf.(curMode).calc.pairForecast.methods.transProb.pair.prob.probGroup',...
    'Data.dConf.(curMode).calc.pairForecast.methods.transProb.pair.prob.retCalcScheme'};



%% ----------------- Score Statistics gathering
Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.scoreStats=struct;
Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.scoreStats.pairPriceStatNames={'scoreSigned','profit','risk','horizon'};
Data.dConf.backtest.calc.pairForecast.methods.transProb.pair.prob.scoreStats.pairPriceHorizonStatNames={'scoreSignedAll','profitAll','riskAll','channelWidthAll','riskMultAll'};

%% ----------------- Portfolio Generation settings
%% general constraints
%% 'pairSep' method scoring mechanism parameters -see mechansim description
%% for full picture
%


Data.dConf.backtest.calc.portfolioGen.methods.pairSepNew.strat.curMethod='advanced';
Data.dConf.backtest.calc.portfolioGen.methods.pairSepNew.strat.methods.advanced.func='advancedstrat';
Data.dConf.backtest.calc.portfolioGen.methods.pairSepNew.strat.methods.advanced.param.scoreLevel=4;
Data.dConf.backtest.calc.portfolioGen.methods.pairSepNew.strat.methods.simple.func='simplestrat';
Data.dConf.backtest.calc.portfolioGen.methods.pairSepNew.strat.methods.simple.param.scoreLevel=4;
Data.dConf.backtest.calc.portfolioGen.methods.pairSepNew.strat.methods.simple.param.corrLevel=0.4;

Data.dConf.backtest.calc.portfolioGen.methods.pairSepNew.gen.constrPairTypes=[0;0;0;0;0;1;0;0;0;0;0;0;0;0;0;0;1;0;0;0;0;0;1;0;0;0;0;0];

Data.dConf.backtest.calc.portfolioGen.methods.pairSepNew.gen.constrPercentLimit=0.6;
Data.dConf.backtest.calc.portfolioGen.methods.pairSepNew.gen.maxDiffDuration=[1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1];
Data.dConf.backtest.calc.portfolioGen.methods.pairSepNew.gen.capitalBaseRatio=0.15;
Data.dConf.backtest.calc.portfolioGen.methods.pairSepNew.gen.isInteger=1;
%
%% 'markowitz' method scoring mechanism parameters -see mechansim description
%% for full picture
%
Data.dConf.backtest.calc.portfolioGen.methods.markowitz.constr.constrGroup{1}={'PJM','NYA','NEPool'};
Data.dConf.backtest.calc.portfolioGen.methods.markowitz.constr.constrGroup{2}={'NG'};
Data.dConf.backtest.calc.portfolioGen.methods.markowitz.constr.constrGroup{3}={'CL','HU','HO'};
Data.dConf.backtest.calc.portfolioGen.methods.markowitz.constr.constrGroupNames={'Electricity','Gas','Oil'};
Data.dConf.backtest.calc.portfolioGen.methods.markowitz.constr.intragroupConstr=[0.45 0.15 0.15];
Data.dConf.backtest.calc.portfolioGen.methods.markowitz.constr.this2FollowingConstr=[0.65 0.65 0.3];
Data.dConf.backtest.calc.portfolioGen.methods.markowitz.constr.typeCriticalLiquidity=[20000 250 20000 200 200 200 200];
Data.dConf.backtest.calc.portfolioGen.methods.markowitz.constr.liquidityCostExp=1;
Data.dConf.backtest.calc.portfolioGen.methods.markowitz.constr.timePeriodExp=0.5;
Data.dConf.backtest.calc.portfolioGen.methods.markowitz.constr.criticalExposureTime=1;
Data.dConf.backtest.calc.portfolioGen.methods.markowitz.constr.capitalEffRatio=NaN;
Data.dConf.backtest.calc.portfolioGen.methods.markowitz.constr.cerRecalcFrequency=10;
Data.dConf.backtest.calc.portfolioGen.methods.markowitz.constr.spreadFraction=[0.5 0.5 0.5 1 1 0.5 0.5];

Data.dConf.backtest.calc.portfolioGen.methods.markowitz.portopt.riskAversion=40;

Data.dConf.backtest.calc.portfolioGen.methods.markowitz.portopt.stdWindowSize=35;

Data.dConf.backtest.calc.portfolioGen.methods.markowitz.portopt.capitalBaseMethod='byAssets';

Data.dConf.backtest.calc.portfolioGen.methods.markowitz.portopt.intportDelta=0;
Data.dConf.backtest.calc.portfolioGen.methods.markowitz.portopt.nonstatAversion=100;
Data.dConf.backtest.calc.portfolioGen.methods.markowitz.portopt.timeIndiffExp=0;
Data.dConf.backtest.calc.portfolioGen.methods.markowitz.portopt.timeHorizons=[2 3 5 8 10 15 22];
Data.dConf.backtest.calc.portfolioGen.methods.markowitz.portopt.riskCombSelectMethod='adaptiveBasisSharpe';
Data.dConf.backtest.calc.portfolioGen.methods.markowitz.portopt.riskAversionScnPrefix='RA=';
Data.dConf.backtest.calc.portfolioGen.methods.markowitz.portopt.timeIndiffExpScnPrefix='TIE=';
Data.dConf.backtest.calc.portfolioGen.methods.markowitz.portopt.assetGroupDistrMethod='byPairs';
end
function resChar=filesep()
resChar='/';
end