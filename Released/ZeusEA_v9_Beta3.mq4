#property copyright "Copyright © 2019, Kimbert Bartiquel"
#property description "Zeus EA - Forex Robot"
#property link "mailto:admin@zeus-ea.com"
#property strict

#include <stdlib.mqh>
#include <stderror.mqh>
#include <WinUser32.mqh>

#define A 1 //All (Basket + Hedge)
#define B 2 //Basket
#define H 3 //Hedge
#define T 4 //Ticket
#define P 5 //Pending

//+-----------------------------------------------------------------+
//| External Parameters Set                                         |
//+-----------------------------------------------------------------+
enum TypeExitOnZones
  {
   ExitZoneDisable=0,    //Disable
   ExitZoneOpposite=1,   //Opposite Only
   ExitZoneAll=2,        //All Position Type
   
  };
enum TypeForce
  {
   fDisable=3,   //Disable
   fUptrend=0,   //UP Trend
   fDowntrend=1, //DOWN Trend
   
  };
enum TypeMomentumFilterIndicator
  {
   MomentumTypeDisable=0,   //Disable
   MomentumTypeRSI=1,       //RSI
   MomentumTypeStoch=2,    //Stochastic
   
  };
enum TypeMomentumFilter
  {
   MomentumDisable=0,   //Disable
   MomentumZonesOnly=1,   //Zones Only
   MomentumZonesIgnored=2, //Zones Invalidate
   MomentumZonesFiltered=3, //Zones Filtered
   
  };
enum TypeEntry
  {
   Disable=0,   //Disable
   Normal=1,   //(Enable) Normal
   Counter=2,  //(Enable) Counter
  };
enum TypeScalping
  {
   ScalpingDisable=0,   //Default
   ScalpingManual=1,    //Manual TP
   ScalpingAuto=2,      //Smart TP
   
  };
enum TypeXEntry
  {
   DisablXe=0,   //Disable
   EnableX=1,   //Enable
  };
  
enum TypeSREntry
  {
   DisableSR=0,  //Disable
   EnableSR=1,   //Enable
   
  };
 enum TypeTimeFrame
  {
   h1=PERIOD_H1,  //Period H1
   h4=PERIOD_H4,  //Period H4
   d1=PERIOD_D1,  //Periold D1
  };
  
 enum TypeTradingDays
  {
   Type0=0, //All Days
   Type1=1, //Mon-Tue 
   Type2=2, //Mon-Wed
   Type3=3, //Mon-Thur
   Type4=4, //Mon-Fri
  };
 enum TradingSessions
  {
   Session1=0, //All Sessions
   Session2=1, //London/New York
   Session3=2, //Sydney/Tokyo

  };
                                                                      

// Setting this to true will close all open orders immediately
 bool     EmergencyCloseAll   = false;
 extern string generalsettings = "";                                                                    //========GENERAL SETTINGS========
 // Enter a unique number to identify this EA
 extern int      EANumber            = 1;                                                               //EA Number
 extern  string   TradeComment        = "Zeus";                                                         //Trade Comment                     
// Setting this to true will stop the EA trading after any open trades have been closed
 extern bool  ShutDown = false;                                                                         //ShutDown
 extern int CutlossOnShutdownProfit = -2;                                                               //Shutdown Exit Profit
 extern int MaxEntryTrades=4;                                                                           //Max Entries (All Pairs)
 extern bool   CorrelatedPairRestrict=false;                                                            //Filter w/ Correlated Symbol
 
// percent of account balance lost before trading stops
 double   StopTradePercent    = 10;                                                                     //Stop Trading Percentage Lost
// set to true for nano "penny a pip" account (contract size is $10, 000)
 bool     NanoAccount         = false;
// Percentage of account you want to trade on this pair
extern double   PortionPC           = 100;                                                              //Account Portion
// If Basket open: 0=no Portion change;1=allow portion to increase; -1=allow increase and decrease 
 int      PortionChange      = 1;            
// Percent of portion for max drawdown level.
 extern double   MaxDDPercent        = 100;                                                             //Equity Protecion (%)
// Maximum allowed spread while placing trades
 double   MaxSpread           = 5;

// Stop/Limits for entry if true, Buys/Sells if false
bool     B3Traditional       = false;                      
// Market condition 0=uptrend 1=downtrend 2=range 3=off
extern  TypeForce   ForceMarketCond     = fDisable;                              //Force Trend        

extern string   LabelLS             = "";                                       //========LOT SIZE SET========
extern double   Lot                 = 0.01;                                     //Lot Size
extern double   Multiplier          = 1.3;                                      //Multiplier      
double   POSLPips            = 30;                                              //Power Stoploss
                              
extern string entryDescriptionLabel = "";                                        //========Entries========
// 0 = Off, 1 = will base entry on CCI indicator, 2 = will trade in reverse
extern bool     UseAnyEntry         = false;                                     //Use Any Entry
extern TypeEntry      MAEntry             = Counter;                             //EMA ENTRY      
extern TypeEntry      SREntry             = EnableSR;                            //Fractal Entry 
extern TypeEntry      BollingerEntry      = Disable;                             //BB ENTRY    
 
extern string   LabelMA             = "";                                        //========MA Setup========   
extern int       MAPeriod           = 100;                                       //Period
extern double    MADistance         = 10;                                        //Ranging Distance
extern double    MAShfit            = 0;                                         //Shift

extern string   LabelSR         = "";                                             //========Fractal Setup========                                                           
extern double  EntryATRMult = 0;                                                  //ATR Offset Mult                           
extern int     BAR_TO_START_SCAN_FROM=2;                                          //Shift
extern double     SRMinimumDistance =20;                                          //Min Distance
int EntryATRBars = 24;    
                                     
extern string   LabelBBS            = "";                                         //========BB Setup========
extern int      BollPeriod          =10;                                          //Period
extern double   BollDistance        = 2;                                          //Distance
extern double   BollDeviation       = 2.0;                                        //Deviation

extern string   LabelFilter            = "";                                       //========Trading Filter========
extern  TypeMomentumFilterIndicator momentumFilterIndicator =    MomentumTypeStoch;//Filter Indicator
extern TypeMomentumFilter      momentumFilterType  = MomentumZonesOnly ;           //Filter Type
extern string stochasticSetting="20,1,1";                                          //Stoch K,D,Slowing
extern string rsiSetting =14;                                                      //RSI Period
extern TypeTimeFrame MomentumTypeFrame = h4;                                       //Filter TimeFrame  
extern int    momentumShift = 1;                                                   //Filter Shift                           
extern string    stochasticZones       = "80,20";                                  //Overbought/sold
extern TypeExitOnZones exitOnZones  =ExitZoneDisable;                              //Zone Force Exit
extern int      exitOnMaxLevel         =1;                                         //Max Levels To Exit
extern bool     allowPositionSeries   =true;                                       //Allow Position Type Series



extern string TradingDaysL = "";                                                   //========Trading Days/Time========
extern TypeTradingDays TradingDays =Type4;                                         //Trading Days
extern int  TimeToStop = 8;                                                        //Last Day Stop Time (GMT)
extern TradingSessions tradingSession= Session1;                                   //Trading Sessions   
int hourStarSession2 = 8;
int hourEndSession2 = 20;
int hourStarSession3 = 21;
int hourEndSession3 = 7;
extern string    labelscalping            = "";                                    //========Initial Trade Exit========
extern TypeScalping UseScalping  = ScalpingAuto;                                   //Take Profit                                  
extern double    ScalpingManualTP = 10;                                            //Manual TP Pips   
extern bool      useTrailingStopLvl1 = true;                                       //Use Trailing Stop
extern double    TrailingStopLv1             = 2;                                  //Trailing Stop
extern double    TrailingStartLv1            = 8;                                  //Trailing Start
extern double    TrailingStepLv1             = 0.2;                                //Trailing Step

extern string    labelBasketExit            = "";                                  //========Basket Exit======= 
extern double    ProfitPotClosePercent = 30;                                       //Target %
extern double    ProfitTargetReducer = 10;                                         //Target Reduce %
extern int       ProfitReduceStartLevel  =3;                                       //Target Reduce Start
extern int      BreakEvenTrade      = 5;                                           //Breakeven Trade level
extern double   BEPlusPips          = 1;                                           //Breakeven Pips Added

                                                                              
extern string   LabelTS             = "";                                           //========Trading Settings========
extern int      MaxTrades           = 8;                                            //Max Levels
extern int      EntryDelay          = 2000;                                         //Entry Delay   
extern string   SetCountArray       = "3,2";                                        //Level Array
extern bool     AutoCal             = true ;                                        //Auto Calculate
double   AutoCalMult         = 1.5;                                         
extern string   GridSetArray        = "25,35,50";                                   //Level Ranges
extern string   TP_SetArray         = "50,70,100";                                  //Level Take Profits

double MinimumGrid=25;                                                              //Minimum acceptable grid
double MaximumGrid=50;                                                              //Maximum acceptable grid

extern string   LabelNews=  "";                                                    //========News Filter========
extern  int AfterNewsStop=10;                                                      //Indent after, Minutes
extern  int BeforeNewsStop=10;                                                     //Indent before, Minutes
extern bool NewsLight= false;                                                      // Enable Light
extern bool NewsMedium=false;                                                      // Enable Medium
extern bool NewsHard=true;                                                         // Enable Hard
extern int  offset=3;                                                              // GMT Offset
string NewsSymb="";
extern bool  DrawLines=true;                                                       // Draw lines on the chart
bool  Next           = true;      // Draw only the future of news line
bool  Signal         = false;      // Signals on the upcoming news

color highc          = clrRed;     // Colour important news
color mediumc        = clrBlue;    // Colour medium news
color lowc           = clrLime;    // The color of weak news
int   Style          = 2;          // Line style
int   Upd            = 86400;      // Period news updates in seconds

bool  Vhigh          = false;
bool  Vmedium        = false;
bool  Vlow           = false;
int   MinBefore=0;
int   MinAfter=0;

int NomNews=0;
string NewsArr[4][1000];
int Now=0;
datetime LastUpd;
string str1;
double CheckNews=0;



string    LabelHS            = "";                                          
// Enter the Symbol of the same/correlated pair EXACTLY as used by your broker.
string   HedgeSymbol         = "";                                            
// Number of days for checking Hedge Correlation
int      CorrPeriod          = 30;                                            
// Turns DD hedge on/off
bool     UseHedge            = false;                                         
// DD = start hedge at set DD;Level = Start at set level
string   DDorLevel           = "DD";                                     
// DD Percent or Level at which Hedge starts
double   HedgeStart          = 5;                                         
// Hedge Lots = Open Lots * hLotMult
double   hLotMult            = 0.8;                                            
// DD Hedge maximum pip loss - also hedge trailing stop
double   hMaxLossPips        = 5;                                              
// true = fixed SL at hMaxLossPips
bool     hFixedSL            = false;                                        
// Hedge Take Profit
double   hTakeProfit         = 5;                                           
// Increase to HedgeStart to stop early re-entry of the hedge
double   hReEntryPC          = 1;                                           
// True = use RSI/MA calculation for next grid order
bool     UseSmartGrid        = false;                                                 


string   LabelTssl             = "";                                                                              
bool     UseStopLoss         = false;                                             
// Pips for fixed StopLoss from BE, 0=off
double   SLPips              = 30;                                                
string LabelTssl_3 ="";                                                          
bool     UseTrailingStop   = false;                                               
// Pips for trailing stop loss from BE + TSLPips: +ve = fixed trail; -ve = reducing trail; 0=off
double   TSLPips             = 2;                                                
// Minimum trailing stop pips if using reducing TS
double   TSLPipsMin          = 0.2;                                              
// Transmits a SL in case of internet loss
bool     UsePowerOutSL       = false;

// Close trades in FIFO order
bool     UseFIFO             = false;                                             
// Money Management
 bool     UseMM               = false;
// Adjusts MM base lot for large accounts
 double   LAF                 = 0.5;

// True = will close the oldest open trade after CloseTradesLevel is reached
  bool     UseCloseOldest      = false;      //Close Oldest Trade
// will start closing oldest open trade at this level
  int      CloseTradesLevel    = 5;          //Level - Start Closing Oldest 
// Will close the oldest trade whether it has potential profit or not
  bool     ForceCloseOldest    = true;       //Force Close Oldest
// Maximum number of oldest trades to close
  int      MaxCloseTrades      = 4;          //Max Close Trades
// After Oldest Trades have closed, Forces Take Profit to BE +/- xx Pips
  double   CloseTPPips         = 10;         //Close TP Pips
// Force Take Profit to BE +/- xx Pips
  double   ForceTPPips         = 0;         //Froce TP Pips
// Ensure Take Profit is at least BE +/- xx Pips
  double   MinTPPips           = 0;         //Min TP Pips
// Reduces ProfitTarget by a percentage over time and number of levels open


 string   LabelGS             = "Grid Settings:";
// Auto calculation of TakeProfit and Grid size;

 string   LabelATRTFr         = "0:Chart, 1:M1, 2:M5, 3:M15, 4:M30, 5:H1, 6:H4, 7:D1, 8:W1, 9:MN1";
// TimeFrame for ATR calculation
 int      ATRTF               = 0;
// Number of periods for the ATR calculation
 int      ATRPeriods          = 21;
// Widens/Squishes Grid on increments/decrements of .1
 double   GAF                 = 1.0;


// True = Trailing Stop will stop at BE;False = Hedge will continue into profit
  bool     StopTrailAtBE       = true;                                           //Trailing Stop At Breakeven
// False = Trailing Stop is Fixed;True = Trailing Stop will reduce after BE is reached
  bool     ReduceTrailStop     = false;                                            //Reduce Trailing Stop




 string   LabelSG             = "Smart Grid Settings:";
 string   LabelSGTF           = "0:Chart, 1:M1, 2:M5, 3:M15, 4:M30, 5:H1, 6:H4, 7:D1, 8:W1, 9:MN1";
// Timeframe for RSI calculation - should be less than chart TF.
 int      RSI_TF              = 3;
// Period for RSI calculation
 int      RSI_Period          = 14;
// 0=close, 1=open, 2=high, 3=low, 4=HL/2, 5=HLC/3 6=HLCC/4
 int      RSI_Price           = 0;
// Period for MA of RSI calculation
 int      RSI_MA_Period       = 10;
// 0=Simple MA, 1=Exponential MA, 2=Smoothed MA, 3=Linear Weighted MA
 int      RSI_MA_Method       = 0;
 
 

 string   LabelOS             = "Other Settings:";
// true = Recoup any Hedge/CloseOldest losses: false = Use original profit target.
 bool     RecoupClosedLoss    = true;
// Largest Assumed Basket size.  Lower number = higher start lots
 int      Level               = 7;
// Adjusts opening and closing orders by "slipping" this amount
       int      slip                = 5;
// true = will save equity statistics
 bool     SaveStats           = false;
// seconds between stats entries - off by default
 int      StatsPeriod         = 3600;
// true for backtest - false for forward/live to ACCUMULATE equity traces
 bool     StatsInitialise     = true;

 string   LabelUE             = "Email Settings:";
 bool     UseEmail            = false;
 string   LabelEDD            = "At what DD% would you like Email warnings (Max: 49, Disable: 0)?";
 double   EmailDD1            = 20;
 double   EmailDD2            = 30;
 double   EmailDD3            = 40;
 string   LabelEH             = "Number of hours before DD timer resets";
// Minimum number of hours between emails
 double   EmailHours          = 24;

 string   LabelDisplay        = "Used to Adjust Overlay";
// Turns the display on and off
 bool     displayOverlay      = true;
// Turns off copyright and icon
 bool     displayLogo         = false;
// Turns off the CCI display
 bool     displayCCI          = false;
// Show BE, TP and TS lines
 bool     displayLines        = true;
// Moves display left and right
 int      displayXcord        = 10;
// Moves display up and down
 int      displayYcord        = 22;
// Moves CCI display left and right
 int      displayCCIxCord     = 10;
//Display font
 string   displayFont         = "Typewriter";
// Changes size of display characters
 int      displayFontSize     = 8;
// Changes space between lines
 int      displaySpacing      = 18;
// Ratio to increase label width spacing
 double   displayRatio        = 1;
// default color of display characters
 color    displayColor        = clrGray;
 color    bgColor             =Black;
// default color of profit display characters
 color    displayColorProfit  = Green;
// default color of loss display characters
 color    displayColorLoss    = OrangeRed;
// default color of ForeGround Text display characters
 color    displayColorFGnd    = White;

 bool     Debug               = false;

 string   LabelOpt            = "These values can only be used while optimizing";
// Set to true if you want to be able to optimize the grid settings.
 bool     UseGridOpt          = false;
 
 double   EntryOffset         = 1; 
// These values will replace the normal SetCountArray, 
// GridSetArray and TP_SetArray during optimization.
// The default values are the same as the normal array defaults
// REMEMBER:
// There must be one more value for GridArray and TPArray
// than there is for SetArray
 int      SetArray1           = 4;
 int      SetArray2           = 4;
 int      SetArray3           = 0;
 int      SetArray4           = 0;
 int      GridArray1          = 25;
 int      GridArray2          = 50;
 int      GridArray3          = 100;
 int      GridArray4          = 0;
 int      GridArray5          = 0;
 int      TPArray1            = 50;
 int      TPArray2            = 100;
 int      TPArray3            = 200;
 int      TPArray4            = 0;
 int      TPArray5            = 0;

//+-----------------------------------------------------------------+
//| Internal Parameters Set                                         |
//+-----------------------------------------------------------------+
int         ca;
int         Magic, hMagic;
int         CbT, CpT, ChT;
double      Pip, hPip;
int         POSLCount;
double      SLbL;
int         Moves;
double      MaxDD;
double      SLb;
int         AccountType;
double      StopTradeBalance;
double      InitialAB;
bool        Testing, Visual;
bool        AllowTrading;
bool        EmergencyWarning;
double      MaxDDPer;
int         Error;
int         Set1Level, Set2Level, Set3Level, Set4Level;
int         EmailCount;
string      sTF;
datetime    EmailSent;
int         GridArray[, 2];
double      Lots[], MinLotSize, LotStep;
int         LotDecimal, LotMult, MinMult;
bool        PendLot;
string      CS, UAE;
int         HolShutDown;
datetime    HolArray[, 4];
datetime    HolFirst, HolLast, NextStats, OTbF;
double      RSI[];
int         Digit[, 2], TF[10]={0, 1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

double      Email[3];
double      PbC, PhC, hDDStart, PbMax, PbMin, PhMax, PhMin, LastClosedPL, ClosedPips, SLh, hLvlStart, StatLowEquity, StatHighEquity;
datetime    EETime;
int         hActive, EECount, TbF, CbC, CaL, FileHandle;
bool        TradesOpen, FileClosed, HedgeTypeDD, hThisChart, hPosCorr, dLabels, FirstRun;
string      FileName, ID, StatFile;
double      TPb, StopLevel, TargetPips, LbF, bTS, PortionBalance;

//addition by kim
double FirstLevelLot;
double previousBalance=0;
double highestdd =0;
bool MaximizeProfitTemp = false;

double TrueLotSize  = 0;
int TotalOrders = 0;
bool ShutDownTemp=false;
bool isActivated = false;

bool isStopLossUsed = false;
bool isTrailingStopUsed = false;
bool AllowTradingTemp=true;
bool TradingHaultByMaxEntry = false;

double OldHigh,OldLow;

//trading days variables
bool TradeOnMonday   =   false;                                             
bool TradeOnTuesday  =   false;                                           
bool TradeOnWednesday=   false;                                           
bool TradeOnThursday =   false;                                      
bool TradeOnFriday   =   false;   
      
//stochastic variables
int StochKPeriod,StochDPeriod,StochSPeriod; 
int stochOverBought,stochOverSold;       
bool overBought = false;
bool overSold =   false;             

//First level Trailing Stop
double   TrallB = 0;
double   TrallS = 0;
int      slippage=30;
int points;  
string SLBuyName = "ZeusBUY_SL";   
string SLSellName = "ZeusSELL_SL";        
double ProfitTotal=0;
//tell if its just closed and opened order on the same bar
bool justOpenedOrder = false;
bool justClosedOrder = false;
bool wasBuy=false;
bool wasSell=false;

//+-----------------------------------------------------------------+
//| expert initialization function                                  |
//+-----------------------------------------------------------------+

int init()
{  

 

   //check demo
   if(!IsTesting()){
    checkDemoOrLive();
    }
    
   //Trading Days
   if(TradingDays==0){
      TradeOnMonday   =   true;                                             
      TradeOnTuesday  =   true;                                           
      TradeOnWednesday=   true;                                           
      TradeOnThursday =   true;                                      
      TradeOnFriday   =   true;
   }else if(TradingDays==1){
      TradeOnMonday   =   true;                                             
      TradeOnTuesday  =   true;                                           
   }else if(TradingDays==2){
      TradeOnMonday   =   true;                                             
      TradeOnTuesday  =   true;                                           
      TradeOnWednesday=   true;                                           
      TradeOnThursday =   false;                                      
      TradeOnFriday   =   false;
   }else if(TradingDays==3){
      TradeOnMonday   =   true;                                             
      TradeOnTuesday  =   true;                                           
      TradeOnWednesday=   true;                                           
      TradeOnThursday =   true;                                   
      TradeOnFriday   =   false;
   }else if(TradingDays==4){
      TradeOnMonday   =   true;                                             
      TradeOnTuesday  =   true;                                           
      TradeOnWednesday=   true;                                           
      TradeOnThursday =   true;                                      
      TradeOnFriday   =   true;
   }
   //NEWS CODE
   if(StringLen(NewsSymb)>1)str1=NewsSymb;
   else str1=Symbol();

   Vhigh=NewsHard;
   Vmedium=NewsMedium;
   Vlow=NewsLight;
   
   MinBefore=BeforeNewsStop;
   MinAfter=AfterNewsStop;
   
   //Stochastic array
   string resultStoch[];
   string resultZone[];
   string sep=",";         
   ushort u_sep =StringGetCharacter(sep,0);
   StringSplit(stochasticSetting,u_sep, resultStoch);
   StochKPeriod = StringToInteger(resultStoch[0]);
   StochDPeriod = StringToInteger(resultStoch[1]);
   StochSPeriod = StringToInteger(resultStoch[2]);
   
   StringSplit(stochasticZones,u_sep, resultZone);
   stochOverBought = StringToInteger(resultZone[0]);
   stochOverSold = StringToInteger(resultZone[1]);

   OldHigh =0; //reset resistance
   OldLow=0; //reset resistance
  //Draw Rectangle Background
   DrawRectangle();
   ShutDownTemp =ShutDown;
   ChartSetInteger(0, CHART_SHOW_GRID, false);
   CS = "";     // To display comments while testing, simply use CS = .... and
   Comment(CS);                        // it will be displayed by the line at the end of the start() block.
   CS = "";
   Testing = IsTesting();
   Visual = IsVisualMode();
   FirstRun = true;
   AllowTrading = true;
   //set first level lot to initial lot
   FirstLevelLot  = Lot;
   //buot buot
   TrueLotSize = Lot;
   if (EANumber < 1)
      EANumber = 1;

   if (Testing)
      EANumber = 0;

   Magic = GenerateMagicNumber();
   hMagic = JenkinsHash((string)Magic);
   FileName = "B3_" + (string)Magic + ".dat";

   if (Debug)
   {
      Print("Magic Number: ", DTS(Magic, 0));
      Print("Hedge Number: ", DTS(hMagic, 0));
      Print("FileName: ", FileName);
   }

   Pip = Point;

   if (Digits % 2 == 1)
      Pip *= 10;

   if (NanoAccount)
      AccountType = 10;
   else
      AccountType = 1;
      
   //|--------------------------------------------------|
   //|       Auto Calculation of Grid array and tp      |
   //|--------------------------------------------------|
   
   if(AutoCal){
   
   double GridTP_;
   double GridATRRangeMinimum_ = 25;
   double GridATR_ = iATR(Symbol(), PERIOD_H1, ATRPeriods, 0) / Pip;
   
   double GridATRMult = AutoCalMult; 
   double GridRangeMult = 1.5; 
   
   double set1Mult= GridATRMult;
   double set2Mult= GridATRMult* GridRangeMult;
   double set3Mult= GridATRMult* GridRangeMult * GridRangeMult;
   
   int GridSet_1 = (int)MathMax(GridATRRangeMinimum_,(GridATR_*set1Mult));
   int GridSet_2 = (int)MathMax(GridATRRangeMinimum_,(GridATR_*set2Mult));
   int GridSet_3 = (int)MathMax(GridATRRangeMinimum_,(GridATR_*set3Mult));
   
   int TPSet_1 = GridSet_1*2;
   int TPSet_2 = GridSet_2*2;
   int TPSet_3 = GridSet_3*2;
   
   
   GridSetArray = GridSet_1+","+GridSet_2+","+GridSet_3;
   TP_SetArray = TPSet_1+","+TPSet_2+","+TPSet_3;
   
   Print("(Auto) Grid Set Array: ",GridSetArray);
   Print("(Auto) TP Set Array: ",TP_SetArray);
   
      
   }
   //|--------------------------------------------------|
   //|      Pips/Digits conversion                      |
   //|--------------------------------------------------|
 
   EntryOffset = ND(EntryOffset * Pip, Digits);
   BollDistance = ND(BollDistance * Pip, Digits);
   POSLPips = ND(POSLPips * Pip, Digits);
   hMaxLossPips = ND(hMaxLossPips * Pip, Digits);
   hTakeProfit = ND(hTakeProfit * Pip, Digits);
   CloseTPPips = ND(CloseTPPips * Pip, Digits);
   ForceTPPips = ND(ForceTPPips * Pip, Digits);
   MinTPPips = ND(MinTPPips * Pip, Digits);
   BEPlusPips = ND(BEPlusPips * Pip, Digits);
   SLPips = ND(SLPips * Pip, Digits);
   TSLPips = ND(TSLPips * Pip, Digits);
   TSLPipsMin = ND(TSLPipsMin * Pip, Digits);
   MADistance  = ND(MADistance * Pip, Digits);
   SRMinimumDistance =  ND(SRMinimumDistance * Pip, Digits);
   TrailingStopLv1 = TrailingStopLv1*10;
   TrailingStartLv1 = TrailingStartLv1*10;
   TrailingStepLv1 = TrailingStepLv1*10;


   StopTradePercent /= 100;
   PortionPC /= 100;

   InitialAB = AccountBalance();
   StopTradeBalance = InitialAB * (1 - StopTradePercent);

   if (Testing)
      ID = "ZeusTest.";
   else
      ID = DTS(Magic, 0) + ".";

   HideTestIndicators(true);

   MinLotSize = MarketInfo(Symbol(), MODE_MINLOT);

   if (MinLotSize > Lot)
   {
      Print("Lot is less than minimum lot size permitted for this account");
      AllowTrading = false;
   }

   LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   double MinLot = MathMin(MinLotSize, LotStep);
   LotMult = (int)ND(MathMax(Lot, MinLotSize) / MinLot, 0);
   MinMult = LotMult;
   Lot = MinLot;

   if (MinLot < 0.01)
      LotDecimal = 3;
   else if (MinLot < 0.1)
      LotDecimal = 2;
   else if (MinLot < 1)
      LotDecimal = 1;
   else
      LotDecimal = 0;

   FileHandle = FileOpen(FileName, FILE_BIN|FILE_READ);

   if (FileHandle != -1)
   {
      TbF = FileReadInteger(FileHandle, LONG_VALUE);
      FileClose(FileHandle);
      Error = GetLastError();

      if (OrderSelect(TbF, SELECT_BY_TICKET))
      {
         OTbF = OrderOpenTime();
         LbF = OrderLots();
         LotMult = (int)MathMax(1, LbF / MinLot);
         PbC = FindClosedPL(B);
         PhC = FindClosedPL(H);
         TradesOpen = true;

         if (Debug)
            Print(FileName, " File Read: ", TbF, " Lots: ", DTS(LbF, LotDecimal));
      }
      else
      {
         FileDelete(FileName);
         TbF = 0;
         OTbF = 0;
         LbF = 0;
         Error = GetLastError();

         if (Error == ERR_NO_ERROR)
         {
            if (Debug)
               Print(FileName, " File Deleted");
         }
         else
            Print("Error ", Error, " (", ErrorDescription(Error), ") deleting file ", FileName);
      }
   }

   GlobalVariableSet(ID + "LotMult", LotMult);

   if (Debug)
      Print("MinLotSize: ", DTS(MinLotSize, 2), " LotStep: ", DTS(LotStep, 2), " MinLot: ", DTS(MinLot, 2), " StartLot: ", DTS(Lot, 2), " LotMult: ", DTS(LotMult, 0), " Lot Decimal: ", DTS(LotDecimal, 0));

   EmergencyWarning = EmergencyCloseAll;

   if (IsOptimization())
      Debug = false;

   if (UseAnyEntry)
      UAE = "||";
   else
      UAE = "&&";

   if (ForceMarketCond < 0 || ForceMarketCond > 3)
      ForceMarketCond = 3;

   if (MAEntry < 0 || MAEntry > 2)
      MAEntry = 0;

   if (BollingerEntry < 0 || BollingerEntry > 2)
      BollingerEntry = 0;

   ArrayResize(Digit, 6);

   for (int Index = 0; Index < ArrayRange(Digit, 0); Index++)
   {
      if (Index > 0)
         Digit[Index, 0] = (int)MathPow(10, Index);

      Digit[Index, 1] = Index;

      if (Debug)
         Print("Digit: ", Index, " [", Digit[Index, 0], ", ", Digit[Index, 1], "]");
   }

   LabelCreate();
 
   //+-----------------------------------------------------------------+
   // Display Warning                                                  |
   //+-----------------------------------------------------------------+
   
  double pairATR = iATR(Symbol(), PERIOD_H1, ATRPeriods, 0) / Pip;
  if(pairATR>32){
        Alert("Woolah!\nYou are trying to trade on a High Volatility Pair!\nYou can continue if you feel like you are a HOKAGE\nor you have the best strategy \nlike the PROFESSOR.");
     
  }else{
  
  }
  
  
   dLabels = false;

   //+-----------------------------------------------------------------+
   //| Set Lot Array                                                   |
   //+-----------------------------------------------------------------+
   ArrayResize(Lots, MaxTrades);
   
     for (int Index = 0; Index < MaxTrades; Index++)
      {
         if (Index == 0 || Multiplier < 1)
            Lots[Index] = Lot;
         else
            Lots[Index] = ND(MathMax(Lots[Index - 1] * Multiplier, Lots[Index - 1] + LotStep), LotDecimal);
   
        Print("Lot Size for level ", DTS(Index + 1, 0), " : ", DTS(Lots[Index] * MathMax(LotMult, 1), LotDecimal));
      }

   if (Multiplier < 1)
      Multiplier = 1;

   //+-----------------------------------------------------------------+
   //| Set Grid and TP array                                           |
   //+-----------------------------------------------------------------+
   int GridSet = 0, GridTemp, GridTP, GridIndex = 0, GridLevel = 0, GridError = 0;

   ArrayResize(GridArray, MaxTrades);

   if (IsOptimization() && UseGridOpt)
   {
      if (SetArray1 > 0)
      {
         SetCountArray = DTS(SetArray1, 0);
         GridSetArray = DTS(GridArray1, 0);
         TP_SetArray = DTS(TPArray1, 0);
      }

      if (SetArray2 > 0 || (SetArray1 > 0 && GridArray2 > 0))
      {
         if (SetArray2 > 0)
            SetCountArray = SetCountArray + "," + DTS(SetArray2, 0);

         GridSetArray = GridSetArray + "," + DTS(GridArray2, 0);
         TP_SetArray = TP_SetArray + "," + DTS(TPArray2, 0);
      }

      if (SetArray3 > 0 || (SetArray2 > 0 && GridArray3 > 0))
      {
         if (SetArray3 > 0)
            SetCountArray = SetCountArray + "," + DTS(SetArray3, 0);

         GridSetArray = GridSetArray + "," + DTS(GridArray3, 0);
         TP_SetArray = TP_SetArray + "," + DTS(TPArray3, 0);
      }

      if (SetArray4 > 0 || (SetArray3 > 0 && GridArray4 > 0))
      {
         if (SetArray4 > 0)
            SetCountArray = SetCountArray + "," + DTS(SetArray4, 0);

         GridSetArray = GridSetArray + "," + DTS(GridArray4, 0);
         TP_SetArray = TP_SetArray + "," + DTS(TPArray4, 0);
      }

      if (SetArray4 > 0 && GridArray5 > 0)
      {
         GridSetArray = GridSetArray + "," + DTS(GridArray5, 0);
         TP_SetArray = TP_SetArray + "," + DTS(TPArray5, 0);
      }
   }

   while (GridIndex < MaxTrades)
   {
      if (StringFind(SetCountArray, ",") == -1 && GridIndex == 0)
      {
         GridError = 1;
         break;
      }
      else
         GridSet = StrToInteger(StringSubstr(SetCountArray, 0, StringFind(SetCountArray, ",")));

      if (GridSet > 0)
      {
         SetCountArray = StringSubstr(SetCountArray, StringFind(SetCountArray, ",") + 1);
         GridTemp = StrToInteger(StringSubstr(GridSetArray, 0, StringFind(GridSetArray, ",")));
         GridSetArray = StringSubstr(GridSetArray, StringFind(GridSetArray, ",") + 1);
         GridTP = StrToInteger(StringSubstr(TP_SetArray, 0, StringFind(TP_SetArray, ",")));
         TP_SetArray = StringSubstr(TP_SetArray, StringFind(TP_SetArray, ",") + 1);
      }
      else
         GridSet = MaxTrades;

      if (GridTemp == 0 || GridTP == 0)
      {
         GridError = 2;
         break;
      }

      for (GridLevel = GridIndex; GridLevel <= MathMin(GridIndex + GridSet - 1, MaxTrades - 1); GridLevel++)
      {
         GridArray[GridLevel, 0] = GridTemp;
         GridArray[GridLevel, 1] = GridTP;

         if (IsTesting())
            Print("GridArray ", (GridLevel + 1), ": [", GridArray[GridLevel, 0], ", ", GridArray[GridLevel, 1], "]");
      }

      GridIndex = GridLevel;
   }

   if (GridError > 0 || GridArray[0, 0] == 0 || GridArray[0, 1] == 0)
   {
      if (GridError == 1)
         Print("Grid Array Error. Each value should be separated by a comma.");
      else
         Print("Grid Array Error. Check that there is one more 'Grid' and 'TP' entry than there are 'Set' numbers - separated by commas.");

      AllowTrading = false;
   }

   //+-----------------------------------------------------------------+
   //| Set SmartGrid parameters                                        |
   //+-----------------------------------------------------------------+
   if (UseSmartGrid)
   {
      ArrayResize(RSI, RSI_Period + RSI_MA_Period);
      ArraySetAsSeries(RSI, true);
   }

   //+---------------------------------------------------------------+
   //| Initialize Statistics                                         |
   //+---------------------------------------------------------------+
   if (SaveStats)
   {
      StatFile = "B3" + Symbol() + "_" + (string)Period() + "_" + (string)EANumber + ".csv";
      NextStats = TimeCurrent();
      Stats(StatsInitialise, false, AccountBalance() * PortionPC, 0);
   }
      //NEW FILTER
   if(!IsTesting()){
      NewsFilter();
   }

   getProfit(); //display profit
      
   DrawRectangle_Resize();
   return (0);
}

//+-----------------------------------------------------------------+
//| expert deinitialization function                                |
//+-----------------------------------------------------------------+
int deinit()
{
   switch (UninitializeReason())
   {
      case REASON_REMOVE:
      case REASON_CHARTCLOSE:
      case REASON_CHARTCHANGE:
         if (CpT > 0)
         {
            while (CpT > 0)
               CpT -= ExitTrades(P, displayColorLoss, "Robot Removed");
         }

         GlobalVariablesDeleteAll(ID);
      case REASON_RECOMPILE:
      case REASON_PARAMETERS:
      case REASON_ACCOUNT:

         Comment("");
   }
   if(!IsTesting()){
               LabelDelete();
         } 
   ObjectsDeleteAll(0,OBJ_VLINE);
   return (0);
}

//+-----------------------------------------------------------------+
//| expert start function                                           |
//+-----------------------------------------------------------------+
int start()
{
   
   int      CbB          =0;     // Count buy
   int      CbS          =0;     // Count sell
   int      CpBL         =0;     // Count buy limit
   int      CpSL         =0;     // Count sell limit
   int      CpBS         =0;     // Count buy stop
   int      CpSS         =0;     // Count sell stop
   double   LbB          =0;     // Count buy lots
   double   LbS          =0;     // Count sell lots
   double   LbT          =0;     // total lots out
   double   OPpBL        =0;     // Buy limit open price
   double   OPpSL        =0;     // Sell limit open price
   double   SLbB         =0;     // stop losses are set to zero if POSL off
   double   SLbS         =0;     // stop losses are set to zero if POSL off
   double   BCb = 0, BCh = 0, BCa;   // Broker costs (swap + commission)
   double   ProfitPot    =0;     // The Potential Profit of a basket of Trades
   double   PipValue, PipVal2, ASK, BID;
   double   OrderLot;
   double   OPbL = 0, OPhO = 0;  // last open price
   datetime OTbL = 0;            // last open time
   datetime OTbO = 0, OThO = 0;
   double   g2, tp2, Entry, RSI_MA = 0, LhB = 0, LhS = 0, LhT, OPbO = 0;
   int      Ticket = 0, ChB = 0, ChS = 0, IndEntry = 0, TbO = 0, ThO = 0;
   double   Pb = 0, Ph = 0, PaC, PbPips = 0, PbTarget, DrawDownPC = 0, BEb = 0, BEh = 0, BEa = 0;
   bool     BuyMe = false, SellMe = false, Success, SetPOSL;
   string   IndicatorUsed;
    
   
   MqlDateTime date;
   datetime    time            = iTime(Symbol(), PERIOD_CURRENT, 0);
   datetime    LocalTime       = TimeLocal();
   datetime    BrokerTime      = TimeCurrent();
    
   TimeToStruct(time, date);

   static datetime Time0;  
   bool newBar  = Time0 < Time[0];
   if(newBar){
     Time0 = Time[0];
     //reset this last order opened and closed on new bar
     justOpenedOrder = false;
     justClosedOrder = false;
   }
  

   
  //Trading sessions
  bool allowTradingOnSession=false;
  if(tradingSession==0){
      allowTradingOnSession=true;
  }else if(tradingSession==1){        // london/new york
      int h=TimeHour(TimeGMT());
      if(h>=hourStarSession2 && h<=hourEndSession2){
          allowTradingOnSession=true;
      }
  }else if(tradingSession==2){        // sydney/tokyo
      int h=TimeHour(TimeGMT());
      if(h>=hourStarSession3 || h<=hourEndSession3){
          allowTradingOnSession=true;
      }
  }
  //-------------------------------------------------|
  //Momentum Filter                                  |
  //--------------------------------------------------
  //STOCHASTIC
  if(momentumFilterIndicator==2){
       double stoc_0 = iStochastic(Symbol(), MomentumTypeFrame, StochKPeriod, StochDPeriod, StochSPeriod, MODE_LWMA, 1, 0, momentumShift);
   	if(stoc_0>stochOverBought ){
	       overBought = true;
	       overSold =false;
   	}
   	else if(stoc_0<stochOverSold  ){
   	   overBought = false;
   	   overSold =true;
   	}else{
   	   //accept entry here
   	   overBought = false;
   	   overSold =false;
   	}
  }
  //RSI
  if(momentumFilterIndicator==1){
      double rsi_0 = iRSI(Symbol(),MomentumTypeFrame,rsiSetting,PRICE_CLOSE,momentumShift);
 
   	if(rsi_0>stochOverBought ){
	       overBought = true;
	       overSold =false;
   	}
   	else if(rsi_0<stochOverSold  ){
   	   overBought = false;
   	   overSold =true;
   	}else{
   	   //accept entry here
   	   overBought = false;
   	   overSold =false;
   	}
  }
    
   //Breakout Support and resistance draw
   if(SREntry>0 && ShutDown==false && AllowTrading == true){
        //draw support and resistance
         drawResistance(getUpperFractalBar(Period(), BAR_TO_START_SCAN_FROM));
         drawSupport(getLowerFractalBar(Period(),BAR_TO_START_SCAN_FROM));
   }
   else{
       ObjectDelete("Z_Resistance");
       ObjectDelete("Z_Support");
   }
   
   //+-----------------------------------------------------------------+
   //| Count Open Orders, Lots and Totals                              |
   //+-----------------------------------------------------------------+
   PipVal2 = MarketInfo(Symbol(), MODE_TICKVALUE) / MarketInfo(Symbol(), MODE_TICKSIZE);
   PipValue = PipVal2 * Pip;
   StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
   ASK = ND(MarketInfo(Symbol(), MODE_ASK), (int)MarketInfo(Symbol(), MODE_DIGITS));
   BID = ND(MarketInfo(Symbol(), MODE_BID), (int)MarketInfo(Symbol(), MODE_DIGITS));

   if (ASK == 0 || BID == 0)
      return (0);

   for (int Order = 0; Order < OrdersTotal(); Order++)
   {
      if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
         continue;

      int Type = OrderType();

      if (OrderMagicNumber() == hMagic)
      {
         Ph += OrderProfit();
         BCh += OrderSwap() + OrderCommission();
         BEh += OrderLots() * OrderOpenPrice();

         if (OrderOpenTime() < OThO || OThO == 0)
         {
            OThO = OrderOpenTime();
            ThO = OrderTicket();
            OPhO = OrderOpenPrice();
         }

         if (Type == OP_BUY)
         {
            ChB++;
            LhB += OrderLots();
         }
         else if (Type == OP_SELL)
         {
            ChS++;
            LhS += OrderLots();
         }

         continue;
      }

      if (OrderMagicNumber() != Magic || OrderSymbol() != Symbol())
         continue;

      if (OrderTakeProfit() > 0)
         ModifyOrder(OrderOpenPrice(), OrderStopLoss());

      if (Type <= OP_SELL)
      {
         Pb += OrderProfit();
         BCb += OrderSwap() + OrderCommission();
         BEb += OrderLots() * OrderOpenPrice();

         if (OrderOpenTime() >= OTbL)
         {
            OTbL = OrderOpenTime();
            OPbL = OrderOpenPrice();
         }

         if (OrderOpenTime() < OTbF || TbF == 0)
         {
            OTbF = OrderOpenTime();
            TbF = OrderTicket();
            LbF = OrderLots();
         }

         if (OrderOpenTime() < OTbO || OTbO == 0)
         {
            OTbO = OrderOpenTime();
            TbO = OrderTicket();
            OPbO = OrderOpenPrice();
         }

         if (UsePowerOutSL && ((POSLPips > 0 && OrderStopLoss() == 0) || (POSLPips == 0 && OrderStopLoss() > 0)))
            SetPOSL = true;

         if (Type == OP_BUY)
         {
            CbB++;
            LbB += OrderLots();
            continue;
         }
         else
         {
            CbS++;
            LbS += OrderLots();
            continue;
         }
      }
      else
      {
         if (Type == OP_BUYLIMIT)
         {
            CpBL++;
            OPpBL = OrderOpenPrice();
            continue;
         }
         else if (Type == OP_SELLLIMIT)
         {
            CpSL++;
            OPpSL = OrderOpenPrice();
            continue;
         }
         else if (Type == OP_BUYSTOP)
            CpBS++;
         else
            CpSS++;
      }
   }
   
   CbT = CbB + CbS;
   LbT = LbB + LbS;
   Pb = ND(Pb + BCb, 2);
   ChT = ChB + ChS;
   LhT = LhB + LhS;
   Ph = ND(Ph + BCh, 2);
   CpT = CpBL + CpSL + CpBS + CpSS;
   BCa = BCb + BCh;
   TotalOrders = CbT;
    //+-----------------------------------------------------------------+
	//| Check Weekday Trading                                           |
	//+-----------------------------------------------------------------+
	bool StopThisTime = TimeHour(TimeGMT()) >= TimeToStop && TradingDays>0;
   if (((date.day_of_week==1 && TradeOnMonday==false)||(date.day_of_week==2 && TradeOnTuesday==false)||(date.day_of_week==3 && TradeOnWednesday==false)||
    (date.day_of_week==4 && TradeOnThursday==false)||(date.day_of_week==5 && TradeOnFriday==false)) && StopThisTime == true){
       ShutDown = true;
    }
    if(date.day_of_week==1 && ShutDownTemp==false && !TradingHaultByMaxEntry){
      DrawRectangle();
      ShutDown= false;
      ObjDel("ZeusLStop");
      ObjDel("ZeusLExpt");
      ObjDel("ZeusLResm");
      LabelCreate();
      DrawRectangle_Resize();
    }
     
    //total orders reached maximum and its not shutdown mode and this pair's orders =0
    if((MaxEntryTrades<=getTotalTrades() || (CorrelatedPairRestrict && haveCorrelated())) 
      && ShutDown ==false && CbT==0 ){
          AllowTrading = false;
          TradingHaultByMaxEntry = true;
    }else{
          AllowTrading = true;
          if(TradingHaultByMaxEntry){
                  DrawRectangle();
                  AllowTrading = true;
                  ObjDel("ZeusLStop");
                  ObjDel("ZeusLExpt");
                  ObjDel("ZeusLResm");
                  LabelCreate();
                  DrawRectangle_Resize();
                  OldHigh =0;
                  OldLow=0;
                  //Support and resistance
                  if(SREntry==1&&ShutDown==false){
                      // draw support and resistance
                       drawResistance(getUpperFractalBar(Period(), BAR_TO_START_SCAN_FROM));
                       drawSupport(getLowerFractalBar(Period(),BAR_TO_START_SCAN_FROM));  
                     }
                   else{
                    ObjectDelete("Z_Resistance");
                    ObjectDelete("Z_Support");
                   }

          }
          TradingHaultByMaxEntry =false;
    }

   //+-----------------------------------------------------------------+
   //| Calculate Min/Max Profit and Break Even Points                  |
   //+-----------------------------------------------------------------+
   if (LbT > 0)
   {
      BEb = ND(BEb / LbT, Digits);

      if (BCa < 0)
         BEb -= ND(BCa / PipVal2 / (LbB - LbS), Digits);

      if (Pb > PbMax || PbMax == 0)
         PbMax = Pb;

      if (Pb < PbMin || PbMin == 0)
         PbMin = Pb;

      if (!TradesOpen)
      {
         FileHandle = FileOpen(FileName, FILE_BIN|FILE_WRITE);

         if (FileHandle > -1)
         {
            FileWriteInteger(FileHandle, TbF);
            FileClose(FileHandle);
            TradesOpen = true;

            if (Debug)
               Print(FileName, " File Written: ", TbF);
         }
      }
   }
   else if (TradesOpen)
   {
      TPb = 0;
      PbMax = 0;
      PbMin = 0;
      OTbF = 0;
      TbF = 0;
      LbF = 0;
      PbC = 0;
      PhC = 0;
      PaC = 0;
      ClosedPips = 0;
      CbC = 0;
      CaL =0;
      bTS = 0;

      if (HedgeTypeDD)
         hDDStart = HedgeStart;
      else
         hLvlStart = HedgeStart;

      EmailCount = 0;
      EmailSent = 0;
      FileHandle = FileOpen(FileName, FILE_BIN|FILE_READ);

      if (FileHandle > -1)
      {
         FileClose(FileHandle);
         Error = GetLastError();
         FileDelete(FileName);
         Error = GetLastError();

         if (Error == ERR_NO_ERROR)
         {
            if (Debug)
               Print(FileName + " File Deleted");

            TradesOpen = false;
         }
         else
            Print("Error ", Error, " {", ErrorDescription(Error), ") deleting file ", FileName);
      }
      else
         TradesOpen = false;
   }

   if (LhT > 0)
   {
      BEh = ND(BEh / LhT, Digits);

      if (Ph > PhMax || PhMax == 0)
         PhMax = Ph;

      if (Ph < PhMin || PhMin == 0)
         PhMin = Ph;
   }
   else
   {
      PhMax = 0;
      PhMin = 0;
      SLh = 0;
   }
   
   //+-----------------------------------------------------------------+
   //| Check if trading is allowed                                     |
   //+-----------------------------------------------------------------+
   if (CbT == 0 && ChT == 0 && ShutDown)
   {
      if (CpT > 0)
      {
         ExitTrades(P, displayColorLoss, "Robot is shutting down");

         return (0);
      }

      if (AllowTrading)
      {
         AllowTrading = false;
      }


   }

   static bool LDelete;

     if (!AllowTrading)
   {
      if (!LDelete)
      {
         LDelete = true;
         LabelDelete();
         if(ShutDown){
          if (ObjectFind("ZeusLStop") == -1){
            CreateLabel("ZeusLStop", "SHUTDOWN MODE..", 10, 0, 0, 3, displayColorLoss);
            CreateLabel("ZeusLExpt", "RESET TO RESUME", 10, 0, 0, 6, displayColorLoss); 
           }
         }
         else{
         if (ObjectFind("ZeusLStop") == -1){
            
            CreateLabel("ZeusLStop", "Maximum Entries reached and/or have correlated pairs trading", 10, 0, 0, 3, displayColorLoss);
            
            }
 
      }}

      return (0);
   }
   else
   {
      LDelete = false;
      ObjDel("ZeusLStop");
      ObjDel("ZeusLExpt");
      ObjDel("ZeusLResm");
   }

   //+-----------------------------------------------------------------+
   //| Calculate Drawdown and Equity Protection                        |
   //+-----------------------------------------------------------------+
   double NewPortionBalance = ND(AccountBalance() * PortionPC, 2);

   if (CbT == 0 || PortionChange < 0 || (PortionChange > 0 && NewPortionBalance > PortionBalance))
      PortionBalance = NewPortionBalance;

   if (Pb + Ph < 0)
      DrawDownPC = -(Pb + Ph) / PortionBalance;

   if (!FirstRun && DrawDownPC >= MaxDDPercent / 100)
   {
      ExitTrades(A, displayColorLoss, "Equity StopLoss Reached");

      return (0);
   }

   if (-(Pb + Ph) > MaxDD)
      MaxDD = -(Pb + Ph);

   MaxDDPer = MathMax(MaxDDPer, DrawDownPC * 100);

   if (SaveStats)
      Stats(false, TimeCurrent() < NextStats, PortionBalance, Pb + Ph);

   //+-----------------------------------------------------------------+
   //| Calculate  Stop Trade Percent                                   |
   //+-----------------------------------------------------------------+
   double StepAB = InitialAB * (1 + StopTradePercent);
   double StepSTB = AccountBalance() * (1 - StopTradePercent);
   double NextISTB = StepAB * (1 - StopTradePercent);

   if (StepSTB > NextISTB)
   {
      InitialAB = StepAB;
      StopTradeBalance = StepSTB;
   }

   double InitialAccountMultiPortion = StopTradeBalance * PortionPC;

   //+-----------------------------------------------------------------+
   //| Calculation of Trend Direction                                  |
   //+-----------------------------------------------------------------+
   int Trend;
   string ATrend;
   double ima_0 = iMA(Symbol(), 0, MAPeriod, 0, MODE_EMA, PRICE_CLOSE, MAShfit);
   
   if (ForceMarketCond == 3)
   {
 
      if (BID > ima_0 && BID> ima_0 + MADistance)
         Trend = 0;
      else if (ASK < ima_0 && ASK < ima_0 - MADistance)
         Trend = 1;
      else
         Trend = 2;    
   }

   else
   {
      Trend = ForceMarketCond;

      if (Trend != 0 && BID > ima_0 + MADistance)
         ATrend = "U";

      if (Trend != 1 && ASK < ima_0 - MADistance )
         ATrend = "D";

      if (Trend != 2 && (BID < ima_0 + MADistance))
         ATrend="R";
   }
   


   //+-----------------------------------------------------------------+
   //| Hedge/Basket/ClosedTrades Profit Management                     |
   //+-----------------------------------------------------------------+
   double Pa = Pb;
   PaC = PbC + PhC;

   if (hActive == 1 && ChT == 0)
   {
      PhC = FindClosedPL(H);
      hActive = 0;

      return (0);
   }
   else if (hActive == 0 && ChT > 0)
      hActive = 1;

   if (LbT > 0)
   {
      if (PbC > 0 || (PbC < 0 && RecoupClosedLoss))
      {
         Pa += PbC;
         BEb -= ND(PbC / PipVal2 / (LbB - LbS), Digits);
      }

      if (PhC > 0 || (PhC < 0 && RecoupClosedLoss))
      {
         Pa += PhC;
         BEb -= ND(PhC / PipVal2 / (LbB - LbS), Digits);
      }

      if (Ph > 0 || (Ph < 0 && RecoupClosedLoss))
         Pa += Ph;
   }

   //+-----------------------------------------------------------------+
   //| Close oldest open trade after CloseTradesLevel reached          |
   //+-----------------------------------------------------------------+
   if (UseCloseOldest && CbT >= CloseTradesLevel && CbC < MaxCloseTrades)
   {
      if (!FirstRun && TPb > 0 && (ForceCloseOldest || (CbB > 0 && OPbO > TPb) || (CbS > 0 && OPbO < TPb)))
      {
         int Index = ExitTrades(T, DarkViolet, "Close Oldest Trade", TbO);

         if (Index == 1)
         {
            if (OrderSelect(TbO, SELECT_BY_TICKET))
            {                            // yoh check return
               PbC += OrderProfit() + OrderSwap() + OrderCommission();
               ca = 0;
               CbC++;

               return (0);
            }
            else
            {
               Print("OrderSelect error ", GetLastError());  // yoh

               return (0);
            }
         }
      }
   }

   //+-----------------------------------------------------------------+
   //| GRID CALCULATION                                                |
   //+-----------------------------------------------------------------+
   
   double GridTP;
     
   int Index = (int)MathMax(MathMin(CbT + CbC, MaxTrades) - 1, 0);
   g2 = GridArray[Index, 0];
   tp2 = GridArray[Index, 1];
   GridTP = GridArray[0, 1];

   g2 = ND(MathMax(g2 * GAF * Pip, Pip), Digits);
   tp2 = ND(tp2 * GAF * Pip, Digits);
   GridTP = ND(GridTP * GAF * Pip, Digits);
   
   //lot size codding
   if (CbT == 0){
      LotMult = MinMult;
   }

   //+-----------------------------------------------------------------+
   //| Calculate Take Profit                                           |
   //+-----------------------------------------------------------------+
   static double BCaL, BEbL;
   double nLots = LbB - LbS;

   if (CbT > 0 && (TPb == 0 || CbT + ChT != CaL || BEbL != BEb || BCa != BCaL || FirstRun))
   {
      string sCalcTP = "Set New TP:  BE: " + DTS(BEb, Digits);
      double NewTP = 0, BasePips;
      CaL = CbT + ChT;
      BCaL = BCa;
      BEbL = BEb;
      BasePips = ND(Lot * LotMult * GridTP * (CbT + CbC) / nLots, Digits);

      if (CbB > 0)
      {
         if (ForceTPPips > 0)
         {
            NewTP = BEb + ForceTPPips;
            sCalcTP = sCalcTP + " +Force TP (" + DTS(ForceTPPips, Digits) + ") ";
         }
         else if (CbC > 0 && CloseTPPips > 0)
         {
            NewTP = BEb + CloseTPPips;
            sCalcTP = sCalcTP + " +Close TP (" + DTS(CloseTPPips, Digits) + ") ";
         }
         else if (BEb + BasePips > OPbL + tp2)
         {
            NewTP = BEb + BasePips;
            sCalcTP = sCalcTP + " +Base TP: (" + DTS(BasePips, Digits) + ") ";
         }
         else
         {
            NewTP = OPbL + tp2;
            sCalcTP = sCalcTP + " +Grid TP: (" + DTS(tp2, Digits) + ") ";
         }

         if (MinTPPips > 0)
         {
            NewTP = MathMax(NewTP, BEb + MinTPPips);
            sCalcTP = sCalcTP + " >Minimum TP: ";
         }


         if (BreakEvenTrade > 0 && CbT + CbC >= BreakEvenTrade)
         {
            NewTP = BEb + BEPlusPips;
            sCalcTP = sCalcTP + " >BreakEven: (" + DTS(BEPlusPips, Digits) + ") ";
         }

         sCalcTP = (sCalcTP + "Buy: TakeProfit: ");
      }
      else if (CbS > 0)
      {
         if (ForceTPPips > 0)
         {
            NewTP = BEb - ForceTPPips;
            sCalcTP = sCalcTP + " -Force TP (" + DTS(ForceTPPips, Digits) + ") ";
         }
         else if (CbC > 0 && CloseTPPips > 0)
         {
            NewTP = BEb - CloseTPPips;
            sCalcTP = sCalcTP + " -Close TP (" + DTS(CloseTPPips, Digits) + ") ";
         }
         else if (BEb + BasePips < OPbL - tp2)
         {
            NewTP = BEb + BasePips;
            sCalcTP = sCalcTP + " -Base TP: (" + DTS(BasePips, Digits) + ") ";
         }
         else
         {
            NewTP = OPbL - tp2;
            sCalcTP = sCalcTP + " -Grid TP: (" + DTS(tp2, Digits) + ") ";
         }

         if (MinTPPips > 0)
         {
            NewTP = MathMin(NewTP, BEb - MinTPPips);
            sCalcTP = sCalcTP + " >Minimum TP: ";
         }

         if (BreakEvenTrade > 0 && CbT + CbC >= BreakEvenTrade)
         {
            NewTP = BEb - BEPlusPips;
            sCalcTP = sCalcTP + " >BreakEven: (" + DTS(BEPlusPips, Digits) + ") ";
         }

         sCalcTP = (sCalcTP + "Sell: TakeProfit: ");
      }

      if (TPb != NewTP)
      {
         TPb = NewTP;

         if (nLots > 0)
            TargetPips = ND(TPb - BEb, Digits);
         else
            TargetPips = ND(BEb - TPb, Digits);

         Print(sCalcTP + DTS(NewTP, Digits));

         return (0);
      }
   }

   PbTarget = TargetPips / Pip;
   ProfitPot = ND(TargetPips * PipVal2 * MathAbs(nLots), 2);

   if (CbB > 0)
      PbPips = ND((BID - BEb) / Pip, 1);

   if (CbS > 0)
      PbPips = ND((BEb - ASK) / Pip, 1);

   BEa = BEb;
   if (!FirstRun && TPb > 0)
   {
      if ((nLots > 0 && BID >= TPb) || (nLots < 0 && ASK <= TPb))
      {
         ExitTrades(A, displayColorProfit, "Profit Target Reached @ " + DTS(TPb, Digits));

         return (0);
      }
   }
   //+-----------------------------------------------------------------+
   //| Check for and Delete hanging pending orders                     |
   //+-----------------------------------------------------------------+
   if (CbT == 0 && !PendLot)
   {
      PendLot = true;

      for (int Order = OrdersTotal() - 1; Order >= 0; Order--)
      {
         if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
            continue;

         if (OrderMagicNumber() != Magic || OrderType() <= OP_SELL)
            continue;
            
         if (ND(OrderLots(), LotDecimal) > ND(Lots[0] * LotMult, LotDecimal))
         {
            PendLot = false;

            while (IsTradeContextBusy())
               Sleep(100);

            if (IsStopped())
               return (-1);

            Success = OrderDelete(OrderTicket());

            if (Success)
            {
               PendLot = true;

               if (Debug)
                  Print("Delete pending > Lot");
            }
         }
      }

      return (0);
   }
   else if ((CbT > 0 || (CbT == 0 && CpT > 0 && !B3Traditional)) && PendLot)
   {
      PendLot = false;

      for (int Order = OrdersTotal() - 1; Order >= 0; Order--)
      {
         if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
            continue;

         if (OrderMagicNumber() != Magic || OrderType() <= OP_SELL)
            continue;

         if (ND(OrderLots(), LotDecimal) == ND(Lots[0] , LotDecimal))
         {
            PendLot = true;

            while (IsTradeContextBusy())
               Sleep(100);

            if (IsStopped())
               return (-1);

            Success = OrderDelete(OrderTicket());

            if (Success)
            {
               PendLot = false;

               if (Debug)
                  Print("Delete pending = Lot");
            }
         }
      }

      return (0);
   }

   //+-----------------------------------------------------------------+
   //| Check ca, Breakeven Trades and Emergency Close All              |
   //+-----------------------------------------------------------------+
   switch (ca)
   {
      case B:
         if (CbT == 0 && CpT == 0)
            ca = 0;

         break;
      case H:
         if (ChT == 0)
            ca = 0;

         break;
      case A:
         if (CbT == 0 && CpT == 0 && ChT == 0)
            ca = 0;

         break;
      case P:
         if (CpT == 0)
            ca = 0;

         break;
      case T:
         break;
      default:
         break;
   }

   if (ca > 0)
   {
      ExitTrades(ca, displayColorLoss, "Close All (" + DTS(ca, 0) + ")");

      return (0);
   }
   else if (CbT == 0 && ChT > 0)
   {
      ExitTrades(H, displayColorLoss, "Basket Closed");

      return (0);
   }
   else if (EmergencyCloseAll)
   {
      ExitTrades(A, displayColorLoss, "Emergency Close-All-Trades");
      EmergencyCloseAll = false;

      return (0);
   }
 

   //+-----------------------------------------------------------------+
   //| Power Out Stop Loss Protection                                  |
   //+-----------------------------------------------------------------+
   if (SetPOSL)
   {
      if (UsePowerOutSL && POSLPips > 0)
      {
         double POSL = MathMin(PortionBalance * (MaxDDPercent + 1) / 100 / PipVal2 / LbT, POSLPips);
         SLbB = ND(BEb - POSL, Digits);
         SLbS = ND(BEb + POSL, Digits);
      }
      else
      {
         SLbB = 0;
         SLbS = 0;
      }

      for (int Order = 0; Order < OrdersTotal(); Order++)
      {
         if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
            continue;

         if (OrderMagicNumber() != Magic || OrderSymbol() != Symbol() || OrderType() > OP_SELL)
            continue;

         if (OrderType() == OP_BUY && OrderStopLoss() != SLbB)
         {
            Success = ModifyOrder(OrderOpenPrice(), SLbB, Purple);

            if (Debug && Success)
               Print("Order ", OrderTicket(), ": Sync POSL Buy");
         }
         else if (OrderType() == OP_SELL && OrderStopLoss() != SLbS)
         {
            Success = ModifyOrder(OrderOpenPrice(), SLbS, Purple);

            if (Debug && Success)
               Print("Order ", OrderTicket(), ": Sync POSL Sell");
         }
      }
   
   }
   //+-----------------------------------------------------------------+  << This must be the first Entry check.
   //| Moving Average Indicator for Order Entry                        |  << Add your own Indicator Entry checks
   //+-----------------------------------------------------------------+  << after the Moving Average Entry.
   if (MAEntry > 0 && CbT == 0 && CpT < 2  && allowTradingOnSession && CheckNews==0)
   {
      if ((BID > ima_0 + MADistance) && (!B3Traditional || (B3Traditional && Trend != 2))) 
      {
         if (MAEntry == 1)
         {
            if (ForceMarketCond != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
               BuyMe = true;
            else
               BuyMe = false;

            if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               SellMe = false;
         }
         else if (MAEntry == 2)
         {
            if (ForceMarketCond != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
               SellMe = true;
            else
               SellMe = false;

            if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               BuyMe = false;
         }
         
         
         
      }
      else if ((ASK < ima_0 - MADistance ) && (!B3Traditional || (B3Traditional && Trend != 2)))
      {
         if (MAEntry == 1)
         {
            if (ForceMarketCond != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
               SellMe = true;
            else
               SellMe = false;

            if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               BuyMe = false;
         }
         else if (MAEntry == 2)
         {
            if (ForceMarketCond != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
               BuyMe = true;
            else
               BuyMe = false;

            if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               SellMe = false;
         }
      }
      else if (B3Traditional && Trend == 2)
      {
         if (ForceMarketCond != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
            BuyMe = true;

         if (ForceMarketCond != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
            SellMe = true;
      }
      else
      {
         BuyMe = false;
         SellMe = false;
      }

      if (IndEntry > 0)
         IndicatorUsed = IndicatorUsed + UAE;

      IndEntry++;
      IndicatorUsed = IndicatorUsed + " MA ";
   }
  
 
 
   //+----------------------------------------------------------------+
   //| BREAKOUT  order entry                                          |
   //+----------------------------------------------------------------+
   
    if (SREntry>0 && CbT == 0 && CpT < 2 && allowTradingOnSession  && CheckNews==0){
       bool resitanceExist =false;
       bool supportExist = false;
     
       if(ObjectFind("Z_Resistance")>=0){
         resitanceExist = true;
       }
        if(ObjectFind("Z_Support")>=0){
         supportExist = true;
       }
       
      double bHi = ObjectGet("Z_Resistance", OBJPROP_PRICE1);
      double bLo = ObjectGet("Z_Support", OBJPROP_PRICE1);
      
      double srDistance = bHi-bLo;
      
 
      if (BID > bHi && resitanceExist  && supportExist && SRMinimumDistance<=srDistance )
      {
         
         if (SREntry == 1 )
         {
            if (ForceMarketCond != 1 && (UseAnyEntry || IndEntry==0 || (!UseAnyEntry && IndEntry>0 && BuyMe)))
               BuyMe = true;
            else
               BuyMe = false;
   
            if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               SellMe = false;
         }
         else if (SREntry == 2)
         {
            if (ForceMarketCond != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
               SellMe = true;
            else
               SellMe = false;
   
            if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               BuyMe = false;
         }
      }
      else if (ASK<bLo && supportExist  && resitanceExist &&  SRMinimumDistance<=srDistance)
      {
       
         if (SREntry == 1)
         {
            if (ForceMarketCond != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
               SellMe = true;
            else
               SellMe = false;
   
            if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               BuyMe = false;
         }
         else if (SREntry == 2)
         {
            if (ForceMarketCond != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
               BuyMe = true;
            else
               BuyMe = false;
   
            if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               SellMe = false;
         }
      }
      else if (!UseAnyEntry && IndEntry > 0)
      {
         BuyMe = false;
         SellMe = false;
      }
      //remove lines when an order is triggered
      if( SellMe){   
         ObjectDelete("Z_Support");
      }
      if(BuyMe){

          
           ObjectDelete("Z_Resistance");
      }
    
      if (IndEntry > 0){
            IndicatorUsed = IndicatorUsed + UAE;}

          IndEntry++;
          IndicatorUsed = IndicatorUsed + " S&R ";
    }
   //+----------------------------------------------------------------+
   //| Bollinger Band Indicator for Order Entry                       |
   //+----------------------------------------------------------------+
   if (BollingerEntry > 0 && CbT == 0 && CpT < 2 && allowTradingOnSession  && CheckNews==0 )
   {
      double ma = iMA(Symbol(), 0, BollPeriod, 0, MODE_SMA, PRICE_OPEN, 0);
      double stddev = iStdDev(Symbol(), 0, BollPeriod, 0, MODE_SMA, PRICE_OPEN, 0);
      double bup = ma + (BollDeviation * stddev);
      double bdn = ma - (BollDeviation * stddev);
      double bux = bup + BollDistance;
      double bdx = bdn - BollDistance;

      if (ASK < bdx && !justClosedOrder && !justOpenedOrder)
      {
         if (BollingerEntry == 1)
         {
            if (ForceMarketCond != 1 && (UseAnyEntry || IndEntry==0 || (!UseAnyEntry && IndEntry>0 && BuyMe)))
               BuyMe = true;
            else
               BuyMe = false;

            if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               SellMe = false;
         }
         else if (BollingerEntry == 2)
         {
            if (ForceMarketCond != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
               SellMe = true;
            else
               SellMe = false;

            if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               BuyMe = false;
         }
      }
      else if (BID > bux && !justClosedOrder && !justOpenedOrder)
      {
         if (BollingerEntry == 1)
         {
            if (ForceMarketCond != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
               SellMe = true;
            else
               SellMe = false;

            if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               BuyMe = false;
         }
         else if (BollingerEntry == 2)
         {
            if (ForceMarketCond != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
               BuyMe = true;
            else
               BuyMe = false;

            if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               SellMe = false;
         }
      }
      else if (!UseAnyEntry && IndEntry > 0)
      {
         BuyMe = false;
         SellMe = false;
      }
      //tell the ea that its just opened an order
      if(BuyMe||SellMe)justOpenedOrder=true;
      
      if (IndEntry > 0)
         IndicatorUsed = IndicatorUsed + UAE;

      IndEntry++;
      IndicatorUsed = IndicatorUsed + " BBands ";
      
   }
      //+-----------------------------------------------------------------+  
      //| ORDER FILTER                                                    |
      //+-----------------------------------------------------------------+ 
      
     //Stochastic && RSI filter
     if(!overBought && !overSold && momentumFilterType == 1){  //ZONES ONLY SELL
  
            SellMe = false;
            BuyMe  = false;

     }  
     else if(overBought && BuyMe && momentumFilterType==3){ //filter with zones BUY
           BuyMe =false;

     }else if(overSold && SellMe && momentumFilterType==3){ //filter with zones SELL
           SellMe =false;

     }else if((overBought || overSold) && momentumFilterType==2){ //Zones Invalidate
            BuyMe =false;
            SellMe = false;
     }else{
        //continue trading nothing happens
     }
          
      
   	
   //+-----------------------------------------------------------------+
	//| FILTER ORDER TYPE SERIES                                        |
	//+-----------------------------------------------------------------+
	
   if(BuyMe&&wasBuy && !allowPositionSeries){
      BuyMe =false;
   }
   if(SellMe&&wasSell && !allowPositionSeries){
      SellMe  =false;
   }
   
   
   //+-----------------------------------------------------------------+  << This must be the last Entry check before
   //| UseAnyEntry Check && Force Market Condition Buy/Sell Entry      |  << the Trade Selection Logic. Add checks for
   //+-----------------------------------------------------------------+  << additional indicators before this block.
   if ((!UseAnyEntry && IndEntry > 1 && BuyMe && SellMe) || FirstRun)
   {
      BuyMe = false;
      SellMe = false;
   }

   if (ForceMarketCond < 2 && IndEntry == 0 && CbT == 0 && !FirstRun)
   {
      if (ForceMarketCond == 0)
         BuyMe = true;
      else if (ForceMarketCond == 1)
         SellMe = true;

      IndicatorUsed = " FMC ";
   }
   //+-----------------------------------------------------------------+ << This must be the last
	//| RECORD LAST ORDER TYPE                                          | << This must be the last
	//+-----------------------------------------------------------------+ << This must be the last
   
   if(BuyMe){
         wasBuy = true;
         wasSell = false;
	}
	if(SellMe){
	      wasSell=true;
	      wasBuy = false;
	}
   

   //+-----------------------------------------------------------------+
   //| Trade Selection Logic                                           |
   //+-----------------------------------------------------------------+
   OrderLot = LotSize(Lots[StrToInteger(DTS(MathMin(CbT + CbC, MaxTrades - 1), 0))] * LotMult);
   
   double OPbN = 0;

   if (CbT == 0 && CpT < 2 && !FirstRun)
   {
            
         if (BuyMe)
         {
            Ticket = SendOrder(Symbol(), OP_BUY, OrderLot, 0, slip, Magic, Blue,TradeComment);

            if (Ticket > 0 && Debug)
               Print("Indicator Entry - (", IndicatorUsed, ") Buy");
         }
         else if (SellMe)
         {
            Ticket = SendOrder(Symbol(), OP_SELL, OrderLot, 0, slip, Magic, displayColorLoss,TradeComment);

            if (Ticket > 0 && Debug)
               Print("Indicator Entry - (", IndicatorUsed, ") Sell");
         }
         

      if (Ticket > 0)
         return (0);
   }
   else if (TimeCurrent() - EntryDelay > OTbL && CbT + CbC < MaxTrades && !FirstRun)
   {

      if (CbB > 0)
      {
         if (OPbL > ASK)
            Entry = OPbL - (MathRound((OPbL - ASK) / g2) + 1) * g2;
         else
            Entry = OPbL - g2;

         if (CpBL == 0)
         {
            if (ASK - Entry <= StopLevel)
               Entry = OPbL - (MathFloor((OPbL - ASK + StopLevel) / g2) + 1) * g2;

            Ticket = SendOrder(Symbol(), OP_BUYLIMIT, OrderLot, Entry - ASK, 0, Magic, SkyBlue,TradeComment);

            if (Ticket > 0 && Debug)
               Print("BuyLimit grid");
         }
         else if (CpBL == 1 && Entry - OPpBL > g2 / 2 && ASK - Entry > StopLevel)
         {
            for (int Order = OrdersTotal() - 1; Order >= 0; Order--)
            {
               if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
                  continue;

               if (OrderMagicNumber() != Magic || OrderSymbol() != Symbol() || OrderType() != OP_BUYLIMIT)
                  continue;

               Success = ModifyOrder(Entry, 0, SkyBlue);

               if (Success && Debug)
                  Print("Mod BuyLimit Entry");
            }
         }
      }
      else if (CbS > 0)
      {
         if (BID > OPbL)
            Entry = OPbL + (MathRound((-OPbL + BID) / g2) + 1) * g2;
         else
            Entry = OPbL + g2;

         if (CpSL == 0)
         {
            if (Entry - BID <= StopLevel)
               Entry = OPbL + (MathFloor((-OPbL + BID + StopLevel) / g2) + 1) * g2;

            Ticket = SendOrder(Symbol(), OP_SELLLIMIT, OrderLot, Entry - BID, 0, Magic, Coral,TradeComment);

            if (Ticket > 0 && Debug)
               Print("SellLimit grid");
         }
         else if (CpSL == 1 && OPpSL - Entry > g2 / 2 && Entry - BID > StopLevel)
         {
            for (int Order = OrdersTotal() - 1; Order >= 0; Order--)
            {
               if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
                  continue;

               if (OrderMagicNumber() != Magic || OrderSymbol() != Symbol() || OrderType() != OP_SELLLIMIT)
                  continue;

               Success = ModifyOrder(Entry, 0, Coral);

               if (Success && Debug)
                  Print("Mod SellLimit Entry");
            }
         }
      }

      if (Ticket > 0)
         return (0);
   }
 

   //+-----------------------------------------------------------------+
   //| Display Overlay Code                                            |
   //+-----------------------------------------------------------------+
   string dMess = "";

   if (true)
   {
      if (true)
      {
         color Colour;
         int dDigits;

         ObjSetTxt("ZeusVTime", TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS));
         DrawLabel("ZeusVSTAm", InitialAccountMultiPortion, 167, 2, displayColorLoss);
         
         
         //DRAW ZONES
         
        if(overBought){
          ObjSetTxt("ZeusZone", "Overbought Zone", 5, displayColorProfit);
        }else if(overSold){
         ObjSetTxt("ZeusZone", "Oversold Zone",5, displayColorLoss);
        }else{
          ObjSetTxt("ZeusZone", "",5, displayColorLoss);
        }
        


         DrawLabel("ZeusVPBal", PortionBalance, 167);

         if (DrawDownPC > 0.4)
            Colour = displayColorLoss;
         else if (DrawDownPC > 0.3)
            Colour = Orange;
         else if (DrawDownPC > 0.2)
            Colour = Yellow;
         else if (DrawDownPC > 0.1)
            Colour = displayColorProfit;
         else
            Colour = displayColor;

         DrawLabel("ZeusVDrDn", DrawDownPC * 100, 315, 2, Colour);

         if (UseHedge && HedgeTypeDD)
            ObjSetTxt("ZeusVhDDm", DTS(hDDStart * 100, 2));
         else if (UseHedge && !HedgeTypeDD)
         {
            DrawLabel("ZeusVhLvl", CbT + CbC, 90, 0);
            ObjSetTxt("ZeusVhLvT", DTS(hLvlStart, 0));
         }
          ObjSetTxt("ZeusVSLot", DTS(Lot * LotMult, 2));;
           
         if (ProfitPot >= 0)
            DrawLabel("ZeusVPPot", ProfitPot, 190);
         else
         {
            ObjSetTxt("ZeusVPPot", DTS(ProfitPot, 2), 0, displayColorLoss);
            dDigits = Digit[ArrayBsearch(Digit, (int)-ProfitPot, WHOLE_ARRAY, 0, MODE_ASCEND), 1];
            ObjSet("ZeusVPPot", 186 - dDigits * 7);
         }

         if (Pb >= 0)
         {
            DrawLabel("ZeusVPnPL", Pb, 190, 2, displayColorProfit);
            ObjSetTxt("ZeusVPPip", DTS(PbPips, 1), 0, displayColorProfit);
            ObjSet("ZeusVPPip", 229);
         }
         else
         {
            ObjSetTxt("ZeusVPnPL", DTS(Pb, 2), 0, displayColorLoss);
            dDigits = Digit[ArrayBsearch(Digit, (int)-Pb, WHOLE_ARRAY, 0, MODE_ASCEND), 1];
            ObjSet("ZeusVPnPL", 186 - dDigits * 7);
            ObjSetTxt("ZeusVPPip", DTS(PbPips, 1), 0, displayColorLoss);
            ObjSet("ZeusVPPip", 225);
         }

         if (PbMax >= 0)
            DrawLabel("ZeusVPLMx", PbMax, 190, 2, displayColorProfit);
         else
         {
            ObjSetTxt("ZeusVPLMx", DTS(PbMax, 2), 0, displayColorLoss);
            dDigits = Digit[ArrayBsearch(Digit, (int)-PbMax, WHOLE_ARRAY, 0, MODE_ASCEND), 1];
            ObjSet("ZeusVPLMx", 186 - dDigits * 7);
         }

         if (PbMin < 0)
            ObjSet("ZeusVPLMn", 225);
         else
            ObjSet("ZeusVPLMn", 229);

         ObjSetTxt("ZeusVPLMn", DTS(PbMin, 2), 0, displayColorLoss);

         if (CbT + CbC < BreakEvenTrade && CbT + CbC < MaxTrades)
            Colour = displayColor;
         else if (CbT + CbC < MaxTrades)
            Colour = displayColor;
         else
            Colour = displayColorLoss;

         if (CbB > 0)
         {
            ObjSetTxt("ZeusLType", "Buy:");
            DrawLabel("ZeusVOpen", CbB, 207, 0, Colour);
         }
         else if (CbS > 0)
         {
            ObjSetTxt("ZeusLType", "Sell:");
            DrawLabel("ZeusVOpen", CbS, 207, 0, Colour);
         }
         else
         {
            ObjSetTxt("ZeusLType", "");
            ObjSetTxt("ZeusVOpen", DTS(0, 0), 0, Colour);
            ObjSet("ZeusVOpen", 207);
         }

         ObjSetTxt("ZeusVLots", DTS(LbT, 2));
         ObjSetTxt("ZeusVMxDD", DTS(MaxDD,2), 0);
         ObjSetTxt("ZeusVDDPC", DTS(MaxDDPer,2), 0);


         if (Trend == 0 &&  CheckNews==0)
         {
            ObjSetTxt("ZeusLTrnd", "UP Trend", 8, displayColorProfit);
         }
         else if (Trend == 1  && CheckNews==0)
         {
           
            ObjSetTxt("ZeusLTrnd", "DOWN Trend", 8, displayColorLoss);
         }
         else if (Trend == 2  && CheckNews==0)
         {
            ObjSetTxt("ZeusLTrnd", "Trend is Ranging", 8, Orange);
            
         }else if(CheckNews>0){
         
            ObjSetTxt("ZeusLTrnd", "NEWS TIME", 8, displayColorLoss);
         }
         
         
      }

      if (displayLines)
      {
         if (BEb > 0)
         {
            if (ObjectFind("ZeusLBELn") == -1)
               CreateLine("ZeusLBELn", DodgerBlue, 1, 0);

            ObjectMove("ZeusLBELn", 0, Time[1], BEb);
         }
         else
            ObjDel("ZeusLBELn");


         if (TPb > 0)
         {
            if (ObjectFind("ZeusLTPLn") == -1)
               CreateLine("ZeusLTPLn", Gold, 1, 0);
            
            ObjectMove("ZeusLTPLn", 0, Time[1], TPb);
            
  
            // exit basket display
            
            if (ObjectFind("ZeusExit") == -1)
                CreateLine("ZeusExit", Gold, 1,2);    
         
            
            double TPa_1,displayProfitPot;
            
            if(CbT<ProfitReduceStartLevel){
                  displayProfitPot=ProfitPot*(ProfitPotClosePercent/100);
            }else{
                  displayProfitPot=ProfitPot*(ProfitTargetReducer/100);
            }
                
            if (CbB>0)
                  TPa_1=BEa+(displayProfitPot/(PipVal2*MathAbs(nLots)));
            else if (CbS>0)
                  TPa_1=BEa-(displayProfitPot/(PipVal2*MathAbs(nLots)));

            ObjectMove("ZeusExit", 0, Time[1], TPa_1); 

             
         }
         
         else if (TPb > 0 && nLots != 0)
         {
            if (ObjectFind("ZeusLTPLn") == -1)
               CreateLine("ZeusLTPLn", Gold, 1, 0);

            ObjectMove("ZeusLTPLn", 0, Time[1], TPb);
         }
         else
           {
             ObjDel("ZeusLTPLn");
             ObjDel("ZeusExit");
           }
           

         if (OPbN > 0)
         {
            if (ObjectFind("ZeusLOPLn") == -1)
               CreateLine("ZeusLOPLn", Red, 1, 4);

            ObjectMove("ZeusLOPLn", 0, Time[1], OPbN);
         }
         else
            ObjDel("ZeusLOPLn");



         if (bTS > 0)
         {
            if (ObjectFind("ZeusLTSbT") == -1)
               CreateLine("ZeusLTSbT", Gold, 1, 3);

            ObjectMove("ZeusLTSbT", 0, Time[1], bTS);
         }
         else
            ObjDel("ZeusLTSbT");

         if (hActive == 1 && BEa > 0)
         {
            if (ObjectFind("ZeusLNBEL") == -1)
               CreateLine("ZeusLNBEL", Crimson, 1, 0);

            ObjectMove("ZeusLNBEL", 0, Time[1], BEa);
         }
         else
            ObjDel("ZeusLNBEL");


         if (SLb > 0)
         {
            if (ObjectFind("ZeusLTSLn") == -1)
               CreateLine("ZeusLTSLn", Gold, 1, 2);

            ObjectMove("ZeusLTSLn", 0, Time[1], SLb);
         }
         else
            ObjDel("ZeusLTSLn");

         if (hThisChart&&BEh > 0)
         {
            if (ObjectFind("ZeusLhBEL") == -1)
               CreateLine("ZeusLhBEL", SlateBlue, 1, 0);

            ObjectMove("ZeusLhBEL", 0, Time[1], BEh);
         }
         else
            ObjDel("ZeusLhBEL");

         if (hThisChart && SLh > 0)
         {
            if (ObjectFind("ZeusLhSLL") == -1)
               CreateLine("ZeusLhSLL", SlateBlue, 1, 3);

            ObjectMove("ZeusLhSLL", 0, Time[1], SLh);
         }
         else
            ObjDel("ZeusLhSLL");
      }
      else
      {
         ObjDel("ZeusLBELn");
         ObjDel("ZeusLTPLn");
         ObjDel("ZeusLOPLn");
         ObjDel("ZeusLSLbT");
         ObjDel("ZeusLTSbT");
         ObjDel("ZeusLNBEL");
         ObjDel("ZeusLMPLn");
         ObjDel("ZeusLTSLn");
         ObjDel("ZeusLhBEL");
         ObjDel("ZeusLhSLL");
        
      }

      if (Debug)
      {
         string dSpace;

         for (int Index = 0; Index <= 175; Index++)
            dSpace = dSpace + " ";

         dMess = "\n\n" + dSpace + "Ticket   Magic     Type Lots OpenPrice  Costs  Profit  Potential";

         for (int Order = 0; Order < OrdersTotal(); Order++)
         {
            if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
               continue;

            if (OrderMagicNumber() != Magic && OrderMagicNumber() != hMagic)
               continue;

            dMess = (dMess + "\n" + dSpace + " " + (string)OrderTicket() + "  " + DTS(OrderMagicNumber(), 0) + "   " + (string)OrderType());
            dMess = (dMess + "   " + DTS(OrderLots(), LotDecimal) + "  " + DTS(OrderOpenPrice(), Digits));
            dMess = (dMess + "     " + DTS(OrderSwap() + OrderCommission(), 2));
            dMess = (dMess + "    " + DTS(OrderProfit() + OrderSwap() + OrderCommission(), 2));

            if (OrderMagicNumber() != Magic)
               continue;
            else if (OrderType() == OP_BUY)
               dMess = (dMess + "      " + DTS(OrderLots() * (TPb - OrderOpenPrice()) * PipVal2 + OrderSwap() + OrderCommission(), 2));
            else if (OrderType() == OP_SELL)
               dMess = (dMess + "      " + DTS(OrderLots() * (OrderOpenPrice() - TPb) * PipVal2 + OrderSwap() + OrderCommission(), 2));
         }

         if (!dLabels)
         {
            dLabels = true;
            CreateLabel("ZeusLPipV", "Pip Value", 0, 2, 0, 0);
            CreateLabel("ZeusVPipV", "", 0, 2, 100, 0);
            CreateLabel("ZeusLDigi", "Digits Value", 0, 2, 0, 1);
            CreateLabel("ZeusVDigi", "", 0, 2, 100, 1);
            ObjSetTxt("ZeusVDigi", DTS(Digits, 0));
            CreateLabel("ZeusLPoin", "Point Value", 0, 2, 0, 2);
            CreateLabel("ZeusVPoin", "", 0, 2, 100, 2);
            ObjSetTxt("ZeusVPoin", DTS(Point, Digits));
            CreateLabel("ZeusLSprd", "Spread Value", 0, 2, 0, 3);
            CreateLabel("ZeusVSprd", "", 0, 2, 100, 3);
            CreateLabel("ZeusLBid", "Bid Value", 0, 2, 0, 4);
            CreateLabel("ZeusVBid", "", 0, 2, 100, 4);
            CreateLabel("ZeusLAsk", "Ask Value", 0, 2, 0, 5);
            CreateLabel("ZeusVAsk", "", 0, 2, 100, 5);
            CreateLabel("ZeusLLotP", "Lot Step", 0, 2, 200, 0);
            CreateLabel("ZeusVLotP", "", 0, 2, 300, 0);
            ObjSetTxt("ZeusVLotP", DTS(MarketInfo(Symbol(), MODE_LOTSTEP), LotDecimal));
            CreateLabel("ZeusLLotX", "Lot Max", 0, 2, 200, 1);
            CreateLabel("ZeusVLotX", "", 0, 2, 300, 1);
            ObjSetTxt("ZeusVLotX", DTS(MarketInfo(Symbol(), MODE_MAXLOT), 0));
            CreateLabel("ZeusLLotN", "Lot Min", 0, 2, 200, 2);
            CreateLabel("ZeusVLotN", "", 0, 2, 300, 2);
            ObjSetTxt("ZeusVLotN", DTS(MarketInfo(Symbol(), MODE_MINLOT), LotDecimal));
            CreateLabel("ZeusLLotD", "Lot Decimal", 0, 2, 200, 3);
            CreateLabel("ZeusVLotD", "", 0, 2, 300, 3);
            ObjSetTxt("ZeusVLotD", DTS(LotDecimal, 0));
            CreateLabel("ZeusLAccT", "Account Type", 0, 2, 200, 4);
            CreateLabel("ZeusVAccT", "", 0, 2, 300, 4);
            ObjSetTxt("ZeusVAccT", DTS(AccountType, 0));
            CreateLabel("ZeusLPnts", "Pip", 0, 2, 200, 5);
            CreateLabel("ZeusVPnts", "", 0, 2, 300, 5);
            ObjSetTxt("ZeusVPnts", DTS(Pip, Digits));
            CreateLabel("ZeusLTicV", "Tick Value", 0, 2, 400, 0);
            CreateLabel("ZeusVTicV", "", 0, 2, 500, 0);
            CreateLabel("ZeusLTicS", "Tick Size", 0, 2, 400, 1);
            CreateLabel("ZeusVTicS", "", 0, 2, 500, 1);
            ObjSetTxt("ZeusVTicS", DTS(MarketInfo(Symbol(), MODE_TICKSIZE), Digits));
            CreateLabel("ZeusLLev", "Leverage", 0, 2, 400, 2);
            CreateLabel("ZeusVLev", "", 0, 2, 500, 2);
            ObjSetTxt("ZeusVLev", DTS(AccountLeverage(), 0) + ":1");
            CreateLabel("ZeusLSGTF", "SmartGrid", 0, 2, 400, 3);

            if (UseSmartGrid)
               CreateLabel("ZeusVSGTF", "True", 0, 2, 500, 3);
            else
               CreateLabel("ZeusVSGTF", "False", 0, 2, 500, 3);

            CreateLabel("ZeusLCOTF", "Close Oldest", 0, 2, 400, 4);

            if (UseCloseOldest)
               CreateLabel("ZeusVCOTF", "True", 0, 2, 500, 4);
            else
               CreateLabel("ZeusVCOTF", "False", 0, 2, 500, 4);

            CreateLabel("ZeusLUHTF", "Hedge", 0, 2, 400, 5);

            if (UseHedge && HedgeTypeDD)
               CreateLabel("ZeusVUHTF", "DrawDown", 0, 2, 500, 5);
            else if (UseHedge && !HedgeTypeDD)
               CreateLabel("ZeusVUHTF", "Level", 0, 2, 500, 5);
            else
               CreateLabel("ZeusVUHTF", "False", 0, 2, 500, 5);
         }

         ObjSetTxt("ZeusVPipV", DTS(PipValue, 2));
         ObjSetTxt("ZeusVSprd", DTS(ASK-BID, Digits));
         ObjSetTxt("ZeusVBid", DTS(BID, Digits));
         ObjSetTxt("ZeusVAsk", DTS(ASK, Digits));
         ObjSetTxt("ZeusVTicV", DTS(MarketInfo(Symbol(), MODE_TICKVALUE), Digits));
      }

      if (EmergencyWarning)
      {
         if (ObjectFind("ZeusLClos") == -1)
            CreateLabel("ZeusLClos", "", 5, 0, 0, 25, displayColorLoss);

         ObjSetTxt("ZeusLClos", "WARNING: EmergencyCloseAll is TRUE", 5, displayColorLoss);
      }
      else if (ShutDown)
      {
         if (ObjectFind("ZeusLClos") == -1)
            CreateLabel("ZeusLClos", "", 5, 0, 0, 25, displayColorLoss);

         ObjSetTxt("ZeusLClos", "Trading will stop when this basket closes.", 5, displayColorLoss);
      }
      else if (HolShutDown != 1)
         ObjDel("ZeusLClos");
    }
   
   
   //+-----------------------------------------------------------------+
   //| Exit Basket                                                      |
   //+-----------------------------------------------------------------+
    //Calculate percentage from profit potential you can live with
    double ProfitToLive;
    if(UseScalping>0 && CbT==1){
            ProfitToLive = ProfitPot; 
    }else{
          if(CbT>=ProfitReduceStartLevel){ //reduce the target at this level
             ProfitToLive = (ProfitTargetReducer/100) * ProfitPot; 
          }else{
             ProfitToLive = (ProfitPotClosePercent/100) * ProfitPot; 
          }
    }
    //double ProfitToLive = (ProfitPotClosePercent/100) * ProfitPot; 
    if (ProfitToLive<Pb){
           bool closedByProfitReducer = CbT>=ProfitReduceStartLevel;
           double profitPercent=0;
           if(closedByProfitReducer){
               profitPercent = ProfitTargetReducer;
           }else{
               profitPercent = ProfitPotClosePercent;
           }
           ExitTrades(A, displayColorProfit, "Profit Reached "+profitPercent+" %" );
           
     }
   //+-----------------------------------------------------------------+
   //| Exit On Shutdown                                                |
   //+-----------------------------------------------------------------+
   if(ShutDown)
    {
             if(CutlossOnShutdownProfit<Pb)
             {
                ExitTrades(A, displayColorProfit, "Shutdown and reached > "+CutlossOnShutdownProfit);
             }
    }
    
   
   //+-----------------------------------------------------------------+  
   //| EXIT ON ZONES                                                    |
   //+-----------------------------------------------------------------+ 
    if (exitOnZones==1){ // exit on overbought/sold zone
     if(overBought && CbB<=exitOnMaxLevel && CbB>0){ 
        ExitTrades(A, DarkViolet, "overBought");
     }else if(overSold && CbS<=exitOnMaxLevel && CbS>0){ 
        ExitTrades(A, DarkViolet, "overSold");
     }
    }
    if (exitOnZones==2){ // exit all
     if((overBought || overSold) && CbT<=exitOnMaxLevel && CbT>0){ 
        ExitTrades(A, DarkViolet, "overBought");
     }
    }

   //+-----------------------------------------------------------------+
	//| Level 1 Take Profits                                              |
	//+-----------------------------------------------------------------+
	
     double atrTP = iATR(Symbol(),PERIOD_H1,14,1)*1.5;
     int atrTP_Pips = (int) (atrTP/Pip);
     double atrTP_Points  = ND(atrTP_Pips * Pip, Digits);
	
   if(UseScalping==1 &&(                                 //Manual TP                              
           (CbB==1 && BID> BEb+ScalpingManualTP) || 
           (CbS==1 && ASK< BEb-ScalpingManualTP) 
           )) { //manual tp
           
    ExitTrades(A, displayColorProfit, "of Manual at "+int((ScalpingManualTP)/Pip)+ " Pips " ); 
         
   }else if(UseScalping ==2 && (                        //Smart TP
           (CbB==1 && BID> BEb+(atrTP_Points)) || 
           (CbS==1 && ASK< BEb-(atrTP_Points)) 
           )) {
    ExitTrades(A, displayColorProfit, "of Auto TP at "+int((MADistance*0.6)/Pip)+ " Pips " );  
   
   }else if(useTrailingStopLvl1){                      //Trailing
     TrailingInitialEntry();
   }else{
      //do nothing
   }
   
 
   //+-----------------------------------------------------------------+
	//|   DISPLAY TRADING SESSION                                       |
	//+--------------------------------------------------------------
	
	if(allowTradingOnSession){
	    ObjSetTxt("ZeusActive", "Trading Session", 5, displayColorProfit);
	}else{
	  
	    ObjSetTxt("ZeusActive", "Non-trading Session", 5, displayColorLoss);
	}
   //NEW FILTER
   if(!IsTesting()){
      NewsFilter();
   }

   getProfit(); //display profit
   
   
   
   WindowRedraw();
   FirstRun = false;
   Comment(CS, dMess);

   return (0);
}


//+-----------------------------------------------------------------+
//| Check Lot Size Funtion                                          |
//+-----------------------------------------------------------------+
double LotSize(double NewLot)
{
   NewLot = ND(NewLot, LotDecimal);
   NewLot = MathMin(NewLot, MarketInfo(Symbol(), MODE_MAXLOT));
   NewLot = MathMax(NewLot, MinLotSize);

   return (NewLot);
}


//+-----------------------------------------------------------------+
//| Open Order Funtion                                              |
//+-----------------------------------------------------------------+
int SendOrder(string OSymbol, int OCmd, double OLot, double OPrice, int OSlip, int OMagic, color OColor = CLR_NONE, string comment = "")
{
   if (FirstRun)
      return (-1);

   int Ticket = 0;
   int Tries = 0;
   int OType = (int)MathMod(OCmd, 2);
   double OrderPrice;

   if (AccountFreeMarginCheck(OSymbol, OType, OLot) <= 0 || GetLastError() == ERR_NOT_ENOUGH_MONEY)
      return (-1);
   else if (MaxSpread > 0 && MarketInfo(OSymbol, MODE_SPREAD) * Point / Pip > MaxSpread)
      return (-1);

   while (Tries < 5)
   {
      Tries ++;

      while (IsTradeContextBusy())
         Sleep(100);

      if (IsStopped())
         return (-1);
      else if (OType == 0)
         OrderPrice = ND(MarketInfo(OSymbol, MODE_ASK) + OPrice, (int)MarketInfo(OSymbol, MODE_DIGITS));
      else
         OrderPrice = ND(MarketInfo(OSymbol, MODE_BID) + OPrice, (int)MarketInfo(OSymbol, MODE_DIGITS));
     
      int totalOrders =  TotalOrders+1;
      if(!UseStopLoss){
           comment = comment+ " Lvl "+totalOrders;
      }else{
           comment = comment+ " SingleTrade";
      }
      
      Ticket = OrderSend(OSymbol, OCmd, OLot, OrderPrice, OSlip, 0, 0, comment, OMagic, 0, OColor);

      if (Ticket < 0)
      {
         Error = GetLastError();

         if (Error != 0)
            Print("Error ", Error, "(", ErrorDescription(Error), ") opening order - ",
                  "  Symbol: ", OSymbol, "  TradeOP: ", OCmd, "  OType: ", OType,
                  "  Ask: ", DTS(MarketInfo(OSymbol, MODE_ASK), Digits),
                  "  Bid: ", DTS(MarketInfo(OSymbol, MODE_BID), Digits),
                  "  OPrice: ", DTS(OPrice, Digits), "  Price: ", DTS(OrderPrice, Digits),
                  "  Lots: ", DTS(OLot, 2));

         switch (Error)
         {
            case ERR_TRADE_DISABLED:
               AllowTrading = false;
               Print("Broker has disallowed EAs on this account");
               Tries = 5;
               break;
            case ERR_OFF_QUOTES:
            case ERR_INVALID_PRICE:
               Sleep(5000);
            case ERR_PRICE_CHANGED:
            case ERR_REQUOTE:
               RefreshRates();
            case ERR_SERVER_BUSY:
            case ERR_NO_CONNECTION:
            case ERR_BROKER_BUSY:
            case ERR_TRADE_CONTEXT_BUSY:
               Tries++;
               break;
            case 149://ERR_TRADE_HEDGE_PROHIBITED:
               if (Debug)
                  Print("Hedge trades are not supported on this pair");

               UseHedge = false;
               Tries = 5;
               break;
            default:
               Tries = 5;
         }
      }
      else
      {
         break;
      }
   }

   return (Ticket);
}


//+-----------------------------------------------------------------+
//| Modify Order Function                                           |
//+-----------------------------------------------------------------+
bool ModifyOrder(double OrderOP, double OrderSL, color Color = CLR_NONE)
{
   bool Success = false;
   int Tries = 0;

   while (Tries < 5 && !Success)
   {
      Tries++;

      while (IsTradeContextBusy())
         Sleep(100);

      if (IsStopped())
         return (false);//(-1)

      Success = OrderModify(OrderTicket(), OrderOP, OrderSL, 0, 0, Color);

      if (!Success)
      {
         Error = GetLastError();

         if (Error > 1)
         {
            Print("Error ", Error, " (", ErrorDescription(Error), ") modifying order ", OrderTicket(), "  Ask: ", Ask, 
                  "  Bid: ", Bid, "  OrderPrice: ", OrderOP, "  StopLevel: ", StopLevel, "  SL: ", OrderSL, "  OSL: ", OrderStopLoss());

            switch (Error)
            {
               case ERR_TRADE_MODIFY_DENIED:
                  Sleep(10000);
               case ERR_OFF_QUOTES:
               case ERR_INVALID_PRICE:
                  Sleep(5000);
               case ERR_PRICE_CHANGED:
               case ERR_REQUOTE:
                  RefreshRates();
               case ERR_SERVER_BUSY:
               case ERR_NO_CONNECTION:
               case ERR_BROKER_BUSY:
               case ERR_TRADE_CONTEXT_BUSY:
               case ERR_TRADE_TIMEOUT:
                  Tries++;
                  break;
               default:
                  Tries = 5;
                  break;
            }
         }
         else
            Success = true;
      }
      else
         break;
   }

   return (Success);
}


//+-------------------------------------------------------------------------+
//| Exit Trade Function - Type: All Basket Hedge Ticket Pending             |
//+-------------------------------------------------------------------------+
int ExitTrades(int Type, color Color, string Reason, int OTicket = 0)
{
   static int OTicketNo;
   bool Success;
   int Tries = 0, Closed = 0, CloseCount = 0;
   int CloseTrades[, 2];
   double OPrice;
   string s;
   ca = Type;

   if (Type == T)
   {
      if (OTicket == 0)
         OTicket = OTicketNo;
      else
         OTicketNo = OTicket;
   }

   for (int Order = OrdersTotal() - 1; Order >= 0; Order--)
   {
      if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
         continue;

      if (Type == B && OrderMagicNumber() != Magic)
         continue;
      else if (Type == H && OrderMagicNumber() != hMagic)
         continue;
      else if (Type == A && OrderMagicNumber() != Magic && OrderMagicNumber() != hMagic)
         continue;
      else if (Type == T && OrderTicket() != OTicket)
         continue;
      else if (Type == P && (OrderMagicNumber() != Magic || OrderType() <= OP_SELL))
         continue;

      ArrayResize(CloseTrades, CloseCount + 1);
      CloseTrades[CloseCount, 0] = (int)OrderOpenTime();
      CloseTrades[CloseCount, 1] = OrderTicket();
      CloseCount++;
   }

   if (CloseCount > 0)
   {
      if (!UseFIFO)
         ArraySort(CloseTrades, WHOLE_ARRAY, 0, MODE_DESCEND);
      else if (CloseCount != ArraySort(CloseTrades))
         Print("Error sorting CloseTrades Array");

      for (int Order = 0; Order < CloseCount; Order++)
      {
         if (!OrderSelect(CloseTrades[Order, 1], SELECT_BY_TICKET))
            continue;

         while (IsTradeContextBusy())
            Sleep(100);

         if (IsStopped())
            return (-1);
         else if (OrderType() > OP_SELL)
            Success = OrderDelete(OrderTicket(), Color);
         else
         {
            if (OrderType() == OP_BUY)
               OPrice = ND(MarketInfo(OrderSymbol(), MODE_BID), (int)MarketInfo(OrderSymbol(), MODE_DIGITS));
            else
               OPrice = ND(MarketInfo(OrderSymbol(), MODE_ASK), (int)MarketInfo(OrderSymbol(), MODE_DIGITS));

            Success = OrderClose(OrderTicket(), OrderLots(), OPrice, slip, Color);
         }

         if (Success)
            Closed++;
         else
         {
            Error = GetLastError();
            Print("Error ", Error, " (", ErrorDescription(Error), ") closing order ", OrderTicket());

            switch (Error)
            {
               case ERR_NO_ERROR:
               case ERR_NO_RESULT:
                  Success = true;
                  break;
               case ERR_OFF_QUOTES:
               case ERR_INVALID_PRICE:
                  Sleep(5000);
               case ERR_PRICE_CHANGED:
               case ERR_REQUOTE:
                  RefreshRates();
               case ERR_SERVER_BUSY:
               case ERR_NO_CONNECTION:
               case ERR_BROKER_BUSY:
               case ERR_TRADE_CONTEXT_BUSY:
                  Print("Attempt ", (Tries + 1), " of 5: Order ", OrderTicket(), " failed to close. Error:", ErrorDescription(Error));
                  Tries++;
                  break;
               case ERR_TRADE_TIMEOUT:
               default:
                  Print("Attempt ", (Tries + 1), " of 5: Order ", OrderTicket(), " failed to close. Fatal Error:", ErrorDescription(Error));
                  Tries = 5;
                  ca = 0;
                  break;
            }
         }
      }

      if (Closed == CloseCount || Closed == 0)
         ca = 0;
   }
   else
      ca = 0;

   if (Closed > 0)
   {
      if (Closed != 1)
         s = "s";
         
      //tell ea that it just closed an order   
      justClosedOrder = true;
     
      Print("Closed ", Closed, " position", s, " because ", Reason);

     
   }

   return (Closed);
}


//+-----------------------------------------------------------------+
//| Find Hedge Profit                                               |
//+-----------------------------------------------------------------+
double FindClosedPL(int Type)
{
   double ClosedProfit = 0;

   if (Type == B && UseCloseOldest)
      CbC = 0;

   if (OTbF > 0)
   {
      for (int Order = OrdersHistoryTotal() - 1; Order >= 0; Order--)
      {
         if (!OrderSelect(Order, SELECT_BY_POS, MODE_HISTORY))
            continue;

         if (OrderOpenTime() < OTbF)
            continue;

         if (Type == B && OrderMagicNumber() == Magic && OrderType() <= OP_SELL)
         {
            ClosedProfit += OrderProfit() + OrderSwap() + OrderCommission();

            if (UseCloseOldest)
               CbC++;
         }

         if (Type == H && OrderMagicNumber() == hMagic)
            ClosedProfit += OrderProfit() + OrderSwap() + OrderCommission();
      }
   }

   return (ClosedProfit);
}


//+-----------------------------------------------------------------+
//| Check Correlation                                               |
//+-----------------------------------------------------------------+
double CheckCorr()
{
   double BaseDiff, HedgeDiff, BasePow = 0, HedgePow = 0, Mult = 0;

   for (int Index = CorrPeriod - 1; Index >= 0; Index--)
   {
      BaseDiff = iClose(Symbol(), 1440, Index) - iMA(Symbol(), 1440, CorrPeriod, 0, MODE_SMA, PRICE_CLOSE, Index);
      HedgeDiff = iClose(HedgeSymbol, 1440, Index) - iMA(HedgeSymbol, 1440, CorrPeriod, 0, MODE_SMA, PRICE_CLOSE, Index);
      Mult += BaseDiff * HedgeDiff;
      BasePow += MathPow(BaseDiff, 2);
      HedgePow += MathPow(HedgeDiff, 2);
   }

   if (BasePow * HedgePow > 0)
      return (Mult / MathSqrt(BasePow * HedgePow));

   return (0);
}


//+------------------------------------------------------------------+
//|  Save Equity / Balance Statistics                                |
//+------------------------------------------------------------------+
void Stats(bool NewFile, bool IsTick, double Balance, double DrawDown)
{
   double Equity = Balance + DrawDown;
   datetime TimeNow = TimeCurrent();

   if (IsTick)
   {
      if (Equity < StatLowEquity)
         StatLowEquity = Equity;

      if (Equity > StatHighEquity)
         StatHighEquity = Equity;
   }
   else
   {
      while (TimeNow >= NextStats)
         NextStats += StatsPeriod;

      int StatHandle;

      if (NewFile)
      {
         StatHandle = FileOpen(StatFile, FILE_WRITE|FILE_CSV, ',');
         Print("Stats " + StatFile + " " + (string)StatHandle);
         FileWrite(StatHandle, "Date", "Time", "Balance", "Equity Low", "Equity High", TradeComment);
      }
      else
      {
         StatHandle = FileOpen(StatFile, FILE_READ|FILE_WRITE|FILE_CSV, ',');
         FileSeek(StatHandle, 0, SEEK_END);
      }

      if (StatLowEquity == 0)
      {
         StatLowEquity = Equity;
         StatHighEquity = Equity;
      }

      FileWrite(StatHandle, TimeToStr(TimeNow, TIME_DATE), TimeToStr(TimeNow, TIME_SECONDS), DTS(Balance, 0), DTS(StatLowEquity, 0), DTS(StatHighEquity, 0));
      FileClose(StatHandle);

      StatLowEquity = Equity;
      StatHighEquity = Equity;
   }
}


//+-----------------------------------------------------------------+
//| Magic Number Generator                                          |
//+-----------------------------------------------------------------+
int GenerateMagicNumber()
{
   if (EANumber > 99)
      return (EANumber);

   return (JenkinsHash((string)EANumber + "_" + Symbol() + "__" + (string)Period()));
}


int JenkinsHash(string Input)
{
   int MagicNo = 0;

   for (int Index = 0; Index < StringLen(Input); Index++)
   {
      MagicNo += StringGetChar(Input, Index);
      MagicNo += (MagicNo << 10);
      MagicNo ^= (MagicNo >> 6);
   }

   MagicNo += (MagicNo << 3);
   MagicNo ^= (MagicNo >> 11);
   MagicNo += (MagicNo << 15);

   return (MathAbs(MagicNo));
}


//+-----------------------------------------------------------------+
//| Normalize Double                                                |
//+-----------------------------------------------------------------+
double ND(double Value, int Precision)
{
   return (NormalizeDouble(Value, Precision));
}


//+-----------------------------------------------------------------+
//| Double To String                                                |
//+-----------------------------------------------------------------+
string DTS(double Value, int Precision)
{
   return (DoubleToStr(Value, Precision));
}


//+-----------------------------------------------------------------+
//| Create Label Function (OBJ_LABEL ONLY)                          |
//+-----------------------------------------------------------------+
void CreateLabel(string Name, string Text, int FontSize, int Corner, int XOffset, double YLine, color Colour = CLR_NONE, string Font = "")
{
   double XDistance = 0, YDistance = 0;

   if (Font == "")
      Font = displayFont;

   FontSize += displayFontSize;
   YDistance = displayYcord + displaySpacing * YLine;

   if (Corner == 0)
      XDistance = displayXcord + (XOffset * displayFontSize / 9 * displayRatio);
   else if (Corner == 1)
      XDistance = displayCCIxCord + XOffset * displayRatio;
   else if (Corner == 2)
      XDistance = displayXcord + (XOffset * displayFontSize / 9 * displayRatio);
   else if (Corner == 3)
   {
      XDistance = XOffset * displayRatio;
      YDistance = YLine;
   }
   else if (Corner == 5)
   {
      XDistance = XOffset * displayRatio;
      YDistance = 14 * YLine;
      Corner = 1;
   }

   if (Colour == CLR_NONE)
      Colour = displayColor;

   ObjectCreate(Name, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(Name, Text, FontSize, Font, Colour);
   ObjectSet(Name, OBJPROP_CORNER, Corner);
   ObjectSet(Name, OBJPROP_XDISTANCE, XDistance);
   ObjectSet(Name, OBJPROP_YDISTANCE, YDistance);
}


//+-----------------------------------------------------------------+
//| Create Line Function (OBJ_HLINE ONLY)                           |
//+-----------------------------------------------------------------+
void CreateLine(string Name, color Colour, int Width, int Style)
{
   ObjectCreate(Name, OBJ_HLINE, 0, 0, 0);
   ObjectSet(Name, OBJPROP_COLOR, Colour);
   ObjectSet(Name, OBJPROP_WIDTH, Width);
   ObjectSet(Name, OBJPROP_STYLE, Style);
   ObjectSet(Name, OBJPROP_BACK, true);
}


//+------------------------------------------------------------------+
//| Draw Label Function (OBJ_LABEL ONLY)                             |
//+------------------------------------------------------------------+
void DrawLabel(string Name, double Value, int XOffset, int Decimal = 2, color Colour = CLR_NONE)
{
   int dDigits = Digit[ArrayBsearch(Digit, (int)Value, WHOLE_ARRAY, 0, MODE_ASCEND), 1];
   ObjectSet(Name, OBJPROP_XDISTANCE, displayXcord + (XOffset - 7 * dDigits) * displayFontSize / 9 * displayRatio);
   ObjSetTxt(Name, DTS(Value, Decimal), 0, Colour);
}


//+-----------------------------------------------------------------+
//| Object Set Function                                             |
//+-----------------------------------------------------------------+
void ObjSet(string Name, int XCoord)
{
   ObjectSet(Name, OBJPROP_XDISTANCE, displayXcord + XCoord * displayFontSize / 9 * displayRatio);
}


//+-----------------------------------------------------------------+
//| Object Set Text Function                                        |
//+-----------------------------------------------------------------+
void ObjSetTxt(string Name, string Text, int FontSize = 0, color Colour = CLR_NONE, string Font = "")
{
   FontSize += displayFontSize;

   if (Font == "")
      Font = displayFont;

   if (Colour == CLR_NONE)
      Colour = displayColor;

   ObjectSetText(Name, Text, FontSize, Font, Colour);
}


//+------------------------------------------------------------------+
//| Delete Overlay Label Function                                    |
//+------------------------------------------------------------------+
void LabelDelete()
{
   for (int Object = ObjectsTotal(); Object >= 0; Object--)
   {
      if (StringSubstr(ObjectName(Object), 0, 4) == "Zeus")
         ObjectDelete(ObjectName(Object));
   }
}


//+------------------------------------------------------------------+
//| Delete Object Function                                           |
//+------------------------------------------------------------------+
void ObjDel(string Name)
{
   if (ObjectFind(Name) != -1)
      ObjectDelete(Name);
}


//+-----------------------------------------------------------------+
//| Create Object List Function                                     |
//+-----------------------------------------------------------------+
void LabelCreate()
{
   if (displayOverlay && ((Testing && Visual) || !Testing))
   {
      int dDigits;
      string ObjText;
      color ObjClr;
      CreateLabel("ZeusVMNum","Contact: admin@zeus-ea.com", 8 - displayFontSize, 5, 5, 1, displayColorFGnd, "Tahoma");
      CreateLabel("ZeusLCopy", "Zeus EA © " + DTS(Year(), 0) + ", Kimbert Bartiquel", 10 - displayFontSize, 3, 5, 3, Silver, "Arial");
      if(isActivated && !IsDemo()){
        CreateLabel("ZeusName", "Zeus EA (Live)", 5, 0, 0, 1,White);
      }else
         {
       if(IsDemo()) {
          CreateLabel("ZeusName", "Zeus EA (Demo)", 5, 0, 0, 1,White);
       }else {
            CreateLabel("ZeusName", "Zeus EA (Disabled)", 5, 0, 0, 1,White);
        }
       
     }
   

      CreateLabel("ZeusLEPPC", "EQ Protection:", 0, 0, 0,3);
      dDigits=Digit[ArrayBsearch(Digit, (int)MaxDDPercent, WHOLE_ARRAY, 0, MODE_ASCEND), 1];
      CreateLabel("ZeusVEPPC", DTS(MaxDDPercent, 2), 0, 0, 167 - 7 * dDigits, 3);
      CreateLabel("ZeusPEPPC", "%", 0, 0, 200, 3);
      CreateLabel("ZeusLAPPC", "Acc Portion:", 0, 0, 0,4);
      dDigits=Digit[ArrayBsearch(Digit, (int)(PortionPC * 100), WHOLE_ARRAY, 0, MODE_ASCEND), 1];
      CreateLabel("ZeusVAPPC", DTS(PortionPC * 100, 2), 0, 0, 167 - 7 * dDigits, 4);
      CreateLabel("ZeusPAPPC", "%", 0, 0, 200, 4);
      CreateLabel("ZeusLPBal", "Portion Bal:", 0, 0, 0, 5);
      CreateLabel("ZeusVPBal", "", 0, 0, 167, 5);
      
      CreateLabel("ZeusLSLot", "Starting Lot Size:", 0, 0, 0, 7);
      CreateLabel("ZeusVSLot", "", 0, 0, 190,7);

      CreateLabel("ZeusLPPot", "Profit Potential:", 0, 0, 0, 8);
      CreateLabel("ZeusVPPot", "", 0, 0, 190, 8);
      
      
      CreateLabel("ZeusLPnPL", "Portion P/L / Pips:", 0, 0, 0, 9);
      CreateLabel("ZeusVPnPL", "", 0, 0, 190, 9);
      CreateLabel("ZeusSPnPL", "/", 0, 0, 220, 9);
      CreateLabel("ZeusVPPip", "", 0, 0, 229, 9);
      
      CreateLabel("ZeusLPLMM", "Profit/Loss Max/Min:", 0, 0, 0, 10);
      CreateLabel("ZeusVPLMx", "", 0, 0, 190, 10);
      CreateLabel("ZeusSPLMM", "/", 0, 0, 220, 10);
      CreateLabel("ZeusVPLMn", "", 0, 0, 225, 10);
      CreateLabel("ZeusLOpen", "Open Trades / Lots:", 0, 0, 0, 11);
      CreateLabel("ZeusLType", "", 0, 0, 170, 11);
      CreateLabel("ZeusVOpen", "", 0, 0, 207, 11);
      CreateLabel("ZeusSOpen", "/", 0, 0, 220, 11);
      CreateLabel("ZeusVLots", "", 0, 0, 229, 11);

      
      CreateLabel("ZeusProfit", "Profit so far:",0, 0, 0,13);
      CreateLabel("ZeusProfitV", "",0, 0, 107,13);

      CreateLabel("ZeusLMxDD", "Max DD:", 0, 0, 0, 14);
      CreateLabel("ZeusVMxDD", "", 0, 0, 107, 14);
      
      CreateLabel("ZeusLDDPC", "Max DD %:", 0, 0, 0, 15);
      CreateLabel("ZeusVDDPC", "", 0, 0, 107, 15);
      CreateLabel("ZeusPDDPC", "%", 0, 0, 140, 15);
      
      CreateLabel("ZeusWebsite", "www.zeus-ea.com",1, 0, 0, 17,White);

      CreateLabel("ZeusLTrnd", "", 8 - displayFontSize, 5,5, 3);
      CreateLabel("ZeusActive", "", 8 - displayFontSize, 5, 5, 5);
      CreateLabel("ZeusZone", "", 8 - displayFontSize, 5, 5, 7);

   }

}
//+-----------------------------------------------------------------+
//| TOTOAL TRADES ON ACCOUNT                                        |
//+-----------------------------------------------------------------+

int getTotalTrades(){
  int total=0;
    
  for(int i=OrdersTotal()-1;i>=0;i--)
   {
    OrderSelect(i, SELECT_BY_POS);
    if((OrderType()==OP_BUY || OrderType()==OP_SELL)&& 
      (StringFind( OrderComment(),"1",0)>=0 || 
         StringFind( OrderComment(),"Single",0)>=0)) { 
         total=total+1;
      }
   }
   return total;
}

bool haveCorrelated(){
   bool toReturn=false;
   string Curr1 =StringSubstr(Symbol(),3,3);
   string Curr2 =StringSubstr(Symbol(),0,3);
   
   for(int i=OrdersTotal()-1;i>=0;i--)
      {
       OrderSelect(i, SELECT_BY_POS);
       if((StringFind( OrderSymbol(),Curr1,0)>=0 || StringFind( OrderSymbol(),Curr2,0)>=0) && OrderSymbol()!=Symbol()) { 
            toReturn=true;
            break;
         }
      }
return toReturn;
}

//+-----------------------------------------------------------------+
//| BREAKOUT Strategy Methods                                       |
//+-----------------------------------------------------------------+
int getUpperFractalBar(int timeframe, int starting_bar) {
	for(int bar = starting_bar; bar < Bars; bar++)
		if(isUpperFractal(timeframe, bar)) return(bar);
	return (-1);
}

bool isUpperFractal(int timeframe, int bar) {
	for(int offset = -2; offset <= 2; offset++)
		if( (offset != 0) && (iHigh(Symbol(), timeframe, bar + offset) > iHigh(Symbol(), timeframe, bar)) ) return(false);
	return (true);
}

int getLowerFractalBar(int timeframe, int starting_bar) {
	for(int bar = starting_bar; bar < Bars; bar++)
		if(isLowerFractal(timeframe, bar)) return(bar);
	return (-1);
}

bool isLowerFractal(int timeframe, int bar) {
	for(int offset = -2; offset <= 2; offset++)
		if( (offset != 0) && (iLow(Symbol(), timeframe, bar + offset) < iLow(Symbol(), timeframe, bar)) ) return(false);
	return (true);
}

void drawResistance(int bar_index) {
	if(bar_index > 0){
	double HIGH = iHigh(Symbol(),Period(), bar_index);
	if(Bid<HIGH && OldHigh!=HIGH){
	   drawTrendLine("Z_Resistance", HIGH);
	   OldHigh = HIGH;
	  }
	}
}

void drawSupport(int bar_index) {
	if(bar_index > 0) {
	double LOW =iLow(Symbol(), Period(), bar_index);
	if(Ask>LOW && OldLow!=LOW){
	   drawTrendLine("Z_Support",LOW);
	   OldLow = LOW;
	   }
	}
}


void drawTrendLine(string object_name, double price) {
	
	if(TotalOrders==0)
	  {
         ObjectDelete(object_name);
	      double a = iATR(Symbol(),PERIOD_H1,24,1);
	      int b = (int) (a*EntryATRMult/Pip);
	      double c = ND(b * Pip, Digits);

	      if(object_name=="Z_Resistance"){
	      ObjectCreate(object_name, OBJ_HLINE, 0, Time[0],  price+c, Time[Bars - 1], price+c);
	      }else{
	       ObjectCreate(object_name, OBJ_HLINE, 0, Time[0],  price-c, Time[Bars - 1], price-c);
	      }
	   	
	      ObjectSet(object_name, OBJPROP_COLOR, clrBurlyWood);
	      ObjectSet(object_name, OBJPROP_STYLE, STYLE_DOT);
	        ObjectSet(object_name, OBJPROP_BACK, true);
	      
	  }
}

void TrailingInitialEntry(){

    double OOP,SL;
   int b=0,s=0,tip,TicketB=0,TicketS=0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && StringFind(OrderComment(),"Lvl 1",0)>0)
           {
            tip = OrderType();
            OOP = NormalizeDouble(OrderOpenPrice(),Digits);
            if(tip==OP_BUY)
              {
               b++;
               TicketB=OrderTicket();
               if(TrailingStopLv1>0)
                 {
                  SL=NormalizeDouble(Bid-TrailingStopLv1*Point,Digits);
                  if(SL>=OOP+TrailingStartLv1*Point && (TrallB==0 || TrallB+TrailingStepLv1*Point<SL)) TrallB=SL;
                 }
              }
            if(tip==OP_SELL)
              {
               s++;
               TicketS=OrderTicket();
               if(TrailingStopLv1>0)
                 {
                  SL=NormalizeDouble(Ask+TrailingStopLv1*Point,Digits);
                  if(SL<=OOP-TrailingStartLv1*Point && (TrallS==0 || TrallS-TrailingStepLv1*Point>SL)) TrallS=SL;
                 }
              }
           }
        }
     }
   if(b!=0)
     {
      if(TrallB!=0)
        {
         DrawHline(SLBuyName,TrallB,clrBlue,1);
         if(Bid<=TrallB)
           {
            if(OrderSelect(TicketB,SELECT_BY_TICKET))
               if(OrderProfit()>0){
                  OrderClose(TicketB,OrderLots(),NormalizeDouble(Ask,Digits),slippage,clrRed);
                  ExitTrades(A, displayColorProfit, "of Trailing stop" ); 
                  }
           }
        }
     }
   else {TrallB=0;ObjectDelete(SLBuyName);}
   if(s!=0)
     {
      if(TrallS!=0)
        {
         DrawHline(SLSellName,TrallS,clrRed,1);
         if(Ask>=TrallS)
           {
            if(OrderSelect(TicketS,SELECT_BY_TICKET))
               if(OrderProfit()>0){
                  ExitTrades(A, displayColorProfit, "of Trailing stop" ); 
                  }
                     
           }
        }
     }
   else {TrallS=0;ObjectDelete(SLSellName);}


}
void DrawHline(string name,double a,color clr,int WIDTH)
  {
   if(ObjectFind(name)!=-1) ObjectDelete(name);
   ObjectCreate(name,OBJ_HLINE,0,0,a,0,0,0,0);
   ObjectSet(name,OBJPROP_COLOR,clr);
   ObjectSet(name,OBJPROP_STYLE,2);
   ObjectSet(name,OBJPROP_WIDTH,WIDTH);
  }
  

//+-----------------------------------------------------------------+
//                         NEWS FILTER                              |
//+-----------------------------------------------------------------+
 

//+-----------------------------------------------------------------+
//+-----------------------------------------------------------------+
  
void NewsFilter(){
 
   if(AfterNewsStop>0)
     {
      if(TimeCurrent()-LastUpd>=Upd){ 
           UpdateNews();LastUpd=TimeCurrent();
      }
      WindowRedraw();
      //---Draw a line on the chart news--------------------------------------------
      if(DrawLines)
        {
         for(int i=0;i<NomNews;i++)
           {
            string Name=StringSubstr(TimeToStr(TimeNewsFunck(i),TIME_MINUTES)+"_"+NewsArr[1][i]+"_"+NewsArr[3][i],0,63);
            if(NewsArr[3][i]!="")if(ObjectFind(Name)==0)continue;
            if(StringFind(str1,NewsArr[1][i])<0)continue;
            if(TimeNewsFunck(i)<TimeCurrent() && Next)continue;

            color clrf = clrNONE;
            if(Vhigh && StringFind(NewsArr[2][i],"High")>=0)clrf=highc;
            if(Vmedium && StringFind(NewsArr[2][i],"Moderate")>=0)clrf=mediumc;
            if(Vlow && StringFind(NewsArr[2][i],"Low")>=0)clrf=lowc;

            if(clrf==clrNONE)continue;

            if(NewsArr[3][i]!="")
              {
               ObjectCreate(Name,0,OBJ_VLINE,TimeNewsFunck(i),0);
               ObjectSet(Name,OBJPROP_COLOR,clrf);
               ObjectSet(Name,OBJPROP_STYLE,Style);
               ObjectSetInteger(0,Name,OBJPROP_BACK,true);
              }
           }
        }
      //---------------event Processing------------------------------------
      int i;
      CheckNews=0;
      for(i=0;i<NomNews;i++)
        {
         int power=0;
         if(Vhigh && StringFind(NewsArr[2][i],"High")>=0)power=1;
         if(Vmedium && StringFind(NewsArr[2][i],"Moderate")>=0)power=2;
         if(Vlow && StringFind(NewsArr[2][i],"Low")>=0)power=3;
         if(power==0)continue;
         if(TimeCurrent()+MinBefore*60>TimeNewsFunck(i) && TimeCurrent()-MinAfter*60<TimeNewsFunck(i) && StringFind(str1,NewsArr[1][i])>=0)
           {
            CheckNews=1;
            break;
           }
         else CheckNews=0;

        }
      if(CheckNews==1 && i!=Now && Signal) { Alert("In ",(int)(TimeNewsFunck(i)-TimeCurrent())/60," minutes released news ",NewsArr[1][i],"_",NewsArr[3][i]);Now=i;}
/***  ***/
     }

   if(CheckNews>0)
     {


     }else{
      // We are out of scope of the news release (No News)

     }

}  
//+------------------------------------------------------------------+
//////////////////////////////////////////////////////////////////////////////////
// Download CBOE page source code in a text variable
// And returns the result
//////////////////////////////////////////////////////////////////////////////////
string ReadCBOE()
  {

   string cookie=NULL,headers;
   char post[],result[];     string TXT="";
   int res;
//--- to work with the server, you must add the URL "https://www.google.com/finance"  
//--- the list of allowed URL (Main menu-> Tools-> Settings tab "Advisors"): 
   string google_url="http://ec.forexprostools.com/?columns=exc_currency,exc_importance&importance=1,2,3&calType=week&timeZone=15&lang=1";
//--- 
   ResetLastError();
//--- download html-pages
   int timeout=5000; //--- timeout less than 1,000 (1 sec.) is insufficient at a low speed of the Internet
   res=WebRequest("GET",google_url,cookie,NULL,timeout,post,0,result,headers);
//--- error checking
   if(res==-1)
     {
      Print("WebRequest error, err.code  =",GetLastError());
      MessageBox("You must add the address ' "+google_url+"' in the list of allowed URL tab 'Advisors' "," Error ",MB_ICONINFORMATION);
      //--- You must add the address ' "+ google url"' in the list of allowed URL tab 'Advisors' "," Error "
     }
   else
     {
      //--- successful download
      //PrintFormat("File successfully downloaded, the file size in bytes  =%d.",ArraySize(result)); 
      //--- save the data in the file
      int filehandle=FileOpen("news-log.html",FILE_WRITE|FILE_BIN);
      //--- ïðîâåðêà îøèáêè 
      if(filehandle!=INVALID_HANDLE)
        {
         //---save the contents of the array result [] in file 
         FileWriteArray(filehandle,result,0,ArraySize(result));
         //--- close file 
         FileClose(filehandle);

         int filehandle2=FileOpen("news-log.html",FILE_READ|FILE_BIN);
         TXT=FileReadString(filehandle2,ArraySize(result));
         FileClose(filehandle2);
        }else{
         Print("Error in FileOpen. Error code =",GetLastError());
        }
     }

   return(TXT);
  }
//+------------------------------------------------------------------+
datetime TimeNewsFunck(int nomf)
  {
   string s=NewsArr[0][nomf];
   string time=StringConcatenate(StringSubstr(s,0,4),".",StringSubstr(s,5,2),".",StringSubstr(s,8,2)," ",StringSubstr(s,11,2),":",StringSubstr(s,14,4));
   return((datetime)(StringToTime(time) + offset*3600));
  }
//////////////////////////////////////////////////////////////////////////////////
void UpdateNews()
  {
   string TEXT=ReadCBOE();
   int sh = StringFind(TEXT,"pageStartAt>")+12;
   int sh2= StringFind(TEXT,"</tbody>");
   TEXT=StringSubstr(TEXT,sh,sh2-sh);

   sh=0;
   while(!IsStopped())
     {
      sh = StringFind(TEXT,"event_timestamp",sh)+17;
      sh2= StringFind(TEXT,"onclick",sh)-2;
      if(sh<17 || sh2<0)break;
      NewsArr[0][NomNews]=StringSubstr(TEXT,sh,sh2-sh);

      sh = StringFind(TEXT,"flagCur",sh)+10;
      sh2= sh+3;
      if(sh<10 || sh2<3)break;
      NewsArr[1][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      if(StringFind(str1,NewsArr[1][NomNews])<0)continue;

      sh = StringFind(TEXT,"title",sh)+7;
      sh2= StringFind(TEXT,"Volatility",sh)-1;
      if(sh<7 || sh2<0)break;
      NewsArr[2][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      if(StringFind(NewsArr[2][NomNews],"High")>=0 && !Vhigh)continue;
      if(StringFind(NewsArr[2][NomNews],"Moderate")>=0 && !Vmedium)continue;
      if(StringFind(NewsArr[2][NomNews],"Low")>=0 && !Vlow)continue;

      sh=StringFind(TEXT,"left event",sh)+12;
      int sh1=StringFind(TEXT,"Speaks",sh);
      sh2=StringFind(TEXT,"<",sh);
      if(sh<12 || sh2<0)break;
      if(sh1<0 || sh1>sh2)NewsArr[3][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      else NewsArr[3][NomNews]=StringSubstr(TEXT,sh,sh1-sh);

      NomNews++;
      if(NomNews==300)break;
     }
  }
//+------------------------------------------------------------------+

//+-----------------------------------------------------------------+
//| DRAWING DASHBOARD                                               |
//+-----------------------------------------------------------------+
void DrawRectangle_Resize(){
    int y_dist;//,x_dist,x_size,y_size,x_1;
    
    int x_dist=ObjectGetInteger(ChartID(),"ZeusVPLMn",OBJPROP_XDISTANCE);
    y_dist=ObjectGetInteger(ChartID(),"ZeusWebsite",OBJPROP_YDISTANCE);
    ObjectSetInteger(ChartID(),"ZeusRect",OBJPROP_XSIZE,x_dist+60);//270
    ObjectSetInteger(ChartID(),"ZeusRect",OBJPROP_YSIZE,y_dist);//410
}
void DrawRectangle() {
    ChartSetInteger(ChartID(),CHART_FOREGROUND,0,false);
    ObjectCreate(ChartID(),"ZeusRect",OBJ_RECTANGLE_LABEL,0,0,0) ;
    ObjectSetInteger(ChartID(),"ZeusRect",OBJPROP_BGCOLOR,bgColor);
    ObjectSetInteger(ChartID(),"ZeusRect",OBJPROP_XDISTANCE,0);
    ObjectSetInteger(ChartID(),"ZeusRect",OBJPROP_YDISTANCE,30);
    ObjectSetInteger(ChartID(),"ZeusRect",OBJPROP_BACK,false);
    ObjectSetInteger(ChartID(),"ZeusRect",OBJPROP_BORDER_TYPE,BORDER_RAISED);
    
   
    
}
bool CheckAccountNumber(){

   string headers;
   char post[], result[];
      int res = WebRequest("GET", "http://www.zeus-ea.com/contents/accountnumbers.txt", "", NULL, 10000, post, ArraySize(post), result, headers);
      bool toReturn = false;
      if(StringFind( CharArrayToString(result),AccountNumber(),0)>=0){toReturn = true;}
      
   return toReturn;
}

bool CheckAccountName(){

   string headers;
   char post[], result[];
   
      int res = WebRequest("GET", "http://www.zeus-ea.com/contents/accountnames.txt", "", NULL, 10000, post, ArraySize(post), result, headers);
      
      bool toReturn = false;
      if(StringFind( CharArrayToString(result),AccountName(),0)>=0){toReturn = true;
      }
      
 return toReturn;
}
void getProfit(){
   double Profit = 0;
      for (int i=0; i<OrdersHistoryTotal(); i++) {
       if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
         if((OrderMagicNumber()==Magic)
          && OrderSymbol() == Symbol() && (OrderType() == OP_BUY || OrderType() == OP_SELL ) ){
          
            double p = (OrderProfit() + OrderSwap() + OrderCommission());
            Profit = Profit+p;
         }
       }
     }
    ProfitTotal =Profit;
    if(ProfitTotal>=0){
        ObjSetTxt("ZeusProfitV", DTS(ProfitTotal,2), 0, Green);
    }else{
        ObjSetTxt("ZeusProfitV", DTS(ProfitTotal,2), 0, OrangeRed);
    }
 
}
void checkDemoOrLive(){   
   bool isAccountSaved = lookUpAccount();
   if(IsDemo() || isAccountSaved || CheckAccountNumber() || CheckAccountName() ){
   
      if(!IsDemo()){
      saveAccount();
      } 
      isActivated = true;
      // account activated then save except demo, the purpose is that when the Web API got problem existing users will not get affected
   }else{
      Print("Account is disabled in this robot. Please contact support");
      isActivated = false;
      MessageBox("Account '"+AccountName()+"' is disabled in this robot. Please contact support.","Robot Message",48);
      ExpertRemove();
   }  
}
//when account is already activated, save it
void saveAccount(){
  string accountNumFile=AccountNumber()+".txt";
   int Handle;
   Handle = FileOpen(accountNumFile, FILE_WRITE|FILE_TXT, ',');
   FileWrite(Handle, AccountNumber());
   FileClose(Handle);
}
//look up if account is already saved.
bool lookUpAccount(){
   bool toReturn = false;
   string accountNumFile=AccountNumber()+".txt";
   int Handle;
   Handle = FileOpen(accountNumFile, FILE_READ|FILE_WRITE|FILE_TXT, ',');
   string a =FileReadString(Handle,100);
   FileClose(Handle);
   if(StringFind(a,AccountNumber(),0)>=0)
     {
      toReturn = true;
     }
   else
     {
      FileDelete(accountNumFile);
     }
   return toReturn;
}
//

  //+---------------------------------------------------------------------+
//|                             TODO
//|                    - REMOVE PROFIT MAXIMIZER                          |
//|                    - ADD EXIT BASKET WITH REDUCER %                   |
//|                    - CHANGE AUTOCAL                                   |
//|                    - CHANGE BE                                        |
//+-----------------------------------------------------------------------+

//+---------------------------------------------------------------------+
//|                                Changelog
//| 8.6.209 KIM - Optimized for readable Inputs & Removed Unnecessary   |
//|             - Added Scalping Feature or Auto Closing Feature        |
//|             - Added Auto Enabling Profit Maximiser After Scalping   |
//|               is disabled on specific levels                        |
//|             - Removed Telegram Feature because of Samok2x           |
//+---------------------------------------------------------------------+