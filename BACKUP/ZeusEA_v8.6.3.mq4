#property copyright "Copyright © 2019, Kimbert Bartiquel"
#property description "Zeus EA - Forex Robot"
#property link "mailto:kbartiquel@yahoo.com"
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
enum TypeForce
  {
   fDisable=3,   //Disable
   fUptrend=0,   //UP Trend
   fDowntrend=1, //DOWN Trend
   
  };
enum TypeRSI
  {
   RSIDisable=0,   //Disable
   RSIZonesOnly=1,   //Zones Only
   RSIZonesIgnored=2, //Zones Ignored
   RISIZonesFiltered=3, //Zones Filtered
   
  };
enum TypeEntry
  {
   Disable=0,   //Disable
   Normal=1,   //(Enable) Normal
   Counter=2,  //(Enable) Counter
   
  };

 enum TypeTimeFrame
  {
   h1=PERIOD_H1,   //Period  H1
   h4=PERIOD_H4,  //Period H4
   d1=PERIOD_D1,  //Periold D1
  };

 string   Version_8_2       = "EA Settings:";                         

// Setting this to true will close all open orders immediately
 bool     EmergencyCloseAll   = false;
 extern string generalsettings = "";                                                                    //========GENERAL SETTINGS========
 // Enter a unique number to identify this EA
 extern int      EANumber            = 1;                                                               //EA Number
 extern  string   TradeComment        = "Zeus";                                                         //Trade Comment                                                     //First Level Comment                                    
// Setting this to true will stop the EA trading after any open trades have been closed
 extern bool  ShutDown = false;                                                                         //ShutDown
 extern int CutlossOnShutdownProfit = -2;                                                               //Shutdown Exit Profit
 extern int MaxEntryTrades=3;                                                                           //Max First Entries (All Pairs)
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
// Will shutdown over holiday period 
 bool     UseHolidayShutdown  = true;
// List of holidays, each seperated by a comma, [day]/[mth]-[day]/[mth], dates inclusive
 string   Holidays            = "18/12-01/01";
// will sound alarms
 bool     PlaySounds          = false;
// Alarm sound to be played
 string   AlertSound          = "Alert.wav";

// Stop/Limits for entry if true, Buys/Sells if false
 extern bool     B3Traditional       = true;                                                      //Traditional
// Market condition 0=uptrend 1=downtrend 2=range 3=off
extern  TypeForce   ForceMarketCond     = fDisable;                                         //Force Trend                                             
// true = ANY entry can be used to open orders, false = ALL entries used to open orders
extern bool     UseAnyEntry         = false;                                               //Use Any Entry
extern string entryDescriptionLabel = "";                                                  //========ENTRY TYPES========
// 0 = Off, 1 = will base entry on CCI indicator, 2 = will trade in reverse


extern TypeEntry      BollingerEntry      = Normal;           //BB ENTRY
extern TypeEntry      MAEntry           = Disable;           //MA ENTRY     
extern bool      SREntry =            false;             //S&R Entry                                                                 
int      CCIEntry            = 0;
// 0 = Off, 1 = will base entry on Stoch, 2 = will trade in reverse
 int      StochEntry          = 0;
// 0 = Off, 1 = will base entry on MACD, 2 = will trade in reverse
 int      MACDEntry           = 0;
 

 extern string   LabelBBS            = "";                                              //========BB ENTRY SETUP========
 // 0 = Off, 1 = will base entry on BB, 2 = will trade in reverse

// Period for Bollinger
 extern int      BollPeriod          =10;                                                 //Period
// Up/Down spread
 extern double   BollDistance        = 2;                                                 //Distance
// Standard deviation multiplier for channel
extern double   BollDeviation       = 2.0;                                                //Deviation

extern string   LabelMA             = "";                            //========MA ENTRY SETUP========   
// 0 = Off, 1 = will base entry on MA channel, 2 = will trade in reverse

extern string   LabelMA2 = "";                                                         //(H4 = 100, H1 = 400,D = 20)
  extern int      MAPeriod            = 20;                                           //Period
// Distance from MA to be treated as Ranging Market   
extern  double   MADistance          = 10;                                             //Minium Distance
extern double    MADistanceMax       =100;                                             //Maximum Distance

 extern string   LabelSR         = "";                                              //========S&R ENTRY SETUP========
 //In pips, used in conjunction with logic to offset first trade entry
 extern double   EntryOffset         = 5;                                           //Entry Offset
extern double BAR_TO_START_SCAN_FROM=2;                                             //Bars To Start Scan
extern double    SRDistance = 60;                                                   //Distance
extern bool      SRRemoveOnTrade = false;                                           //Remove on Trade


 extern string   LabelRSIFilter         = "";                                      //========RSI FILTER========
 extern TypeRSI   useRSIFilter         =  RSIDisable;                                //RSI FILTER
 extern int      overBoughtZone         = 70;                                      //Overbought Zone
 extern int      overSoldZone           = 30;                                      //Oversold Zone



 string   LabelCCI            = "CCI Entry Settings:";                                 //========CCI SETUP========  
// Period for CCI calculation
 int      CCIPeriod           = 14;


  
  string   LabelSto            = "Stochastic Entry Settings:";                      //========Stoch SETUP========  
// Determines Overbought and Oversold Zones
 int      BuySellStochZone    = 20;
// Stochastic KPeriod
 int      KPeriod             = 10;
// Stochastic DPeriod
 int      DPeriod             = 2;
// Stochastic Slowing
  int      Slowing             = 2;

  string   LabelMACD           = "MACD Entry Settings:";                          //========MACD SETUP========  
  string   LabelMACDTF         = "0:Chart, 1:M1, 2:M5, 3:M15, 4:M30, 5:H1, 6:H4, 7:D1, 8:W1, 9:MN1";
// Time frame for MACD calculation
  int      MACD_TF             = 0;
// MACD EMA Fast Period
  int      FastPeriod          = 12;
// MACD EMA Slow Period
  int      SlowPeriod          = 26;
// MACD EMA Signal Period
  int      SignalPeriod        = 9;
// 0=close, 1=open, 2=high, 3=low, 4=HL/2, 5=HLC/3 6=HLCC/4
  int      MACDPrice           = 0;


 extern string TradingDays = "";                                                          //========TRADING DAYS/TIME========
 extern bool TradeOnMonday   =   true;                                                    // Trade on Monday
 extern bool TradeOnTuesday  =   true;                                                    // Trade on Tuesday
 extern bool TradeOnWednesday=   false;                                                    // Trade on Wednesday
 extern bool TradeOnThursday =   false;                                                   // Trade on Thursday
 extern bool TradeOnFriday   =   false;                                                   // Trade on Friday
 extern int  TimeToStop = 16;                                                             // Stop Trading Time (24-hour Local)


extern string   LabelLS             = "";                                            //========LOT SIZE SETTINGS========
// Money Management
 bool     UseMM               = false;
// Adjusts MM base lot for large accounts
 double   LAF                 = 0.5;
// Starting lots if Money Management is off
extern double   Lot                 = 0.01;                                           //Lot Size
// Multiplier on each level
extern double   Multiplier          = 1.3;                                            //Multiplier
 bool   ConsiderLotStep = false;                                                      //Consider LotStep



 
extern string    labelBasketExit            = "";                                    //========EXIT SETTINGS========
bool      useBasketExit  = true;                                            
bool      autOnProfitMaximiser = true;  
extern double    ProfitPotClosePercent = 30;                                         //Exit Basket On Gain %
extern int       TrailingAtLevel = 4;                                                //Profit Trailing At Level                
extern bool     UseEarlyExit        = false;                                         //Time Based Early Exit

extern string   LavelPt             = "";                                           //========PROFIT TRALING SETTINGS========                   
// Turns on TP move and Profit Trailing Stop Feature
 bool     MaximizeProfit      = false;                                             
// Locks in Profit at this percent of Total Profit Potential
extern double   ProfitSet           = 10;                                                  //Profit Set %
// Moves TP this amount in pips
extern double   MoveTP              = 10;                                                  //Move TP
// Number of times you want TP to move before stopping movement
extern int      TotalMoves          = 6;                                                   //Total Moves


extern string    labelscalping            = "";                                      //========LVL 1 SCALPING SETTINGS========

extern bool UseScalping  = false;                                                     //Use Scalping
//First Level TP (Points) to start scalping                                          
extern double    ProfitCloseFirstLevel = 10;                                         //First Level TP (Pips)                                      
//Step of trailing stop or distance between SL before creating another SL


extern string   LabelTS             = "";                                             //========TRADING SETTINGS========

// Maximum number of trades to place (stops placing orders when reaches MaxTrades)
extern int      MaxTrades           = 10;                                             //Max Levels
// Close All level, when reaches this level, doesn't wait for TP to be hit
extern int      BreakEvenTrade      = 6;                                             //Breakeven Trade level
// Pips added to Break Even Point before BE closure
extern double   BEPlusPips          = 1;                                              //Breakeven Pips Added

extern string   LabelGrid           = "";                                             //========LEVEL SETTINGS========
// True = use RSI/MA calculation for next grid order
extern bool     UseSmartGrid        = false;                                           //Smart Grid    
// Time Grid in seconds, to avoid opening of lots of levels in fast market
extern int      EntryDelay          = 2000;                                            //Entry Delay   
// Specifies number of open trades in each block (separated by a comma)
extern string   SetCountArray       = "3,2";                                          //Level Array
// Specifies number of pips away to issue limit order (separated by a comma)
extern string   GridSetArray        = "25,35,50";                                     //Level Ranges
// Take profit for each block (separated by a comma)
extern string   TP_SetArray         = "50,70,100";                                    //Level Take Profits

extern string   LabelTssl             = "";                                               //========SINGLE TRADE (w/ Stop Loss)========                                 
extern bool     UseStopLoss         = false;                                               //Use Single Trade
// Pips for fixed StopLoss from BE, 0=off
extern double   SLPips              = 30;                                                 //Stop Loss Pips
extern string LabelTssl_3 ="";                                                            //-If false, Profit traling enabled as default-
extern bool     UseTrailingStop   = false;                                                //Use Trailing Stop
// Pips for trailing stop loss from BE + TSLPips: +ve = fixed trail; -ve = reducing trail; 0=off
extern double   TSLPips             = 1.7;                                                //Trailing Stop Pips
// Minimum trailing stop pips if using reducing TS
extern double   TSLPipsMin          = 0.2;                                                //Trailing Step Pips
// Transmits a SL in case of internet loss
 bool     UsePowerOutSL       = false;
// Power Out Stop Loss in pips
 double   POSLPips            = 600;
// Close trades in FIFO order
 bool     UseFIFO             = false;



 string   closeOldestLabell             = "";                                        //========OLDEST TRADES SETTINGS========
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

// Number of Hours to wait before EE over time starts
  double   EEStartHours        = 3;                                           //Early Exit Start Hours                                         
// true = StartHours from FIRST trade: false = StartHours from LAST trade
 bool     EEFirstTrade        = true;                                           //Start From First Trade
// Percentage reduction per hour (0 = OFF)
 double   EEHoursPC           = 0.5;                                           //% Reduction/Hour
// Number of Open Trades before EE over levels starts
 int      EEStartLevel        = 5;                                             //Start level
// Percentage reduction at each level (0 = OFF)
 double   EELevelPC           = 10;                                             //% Reduction/level
// true = Will allow the basket to close at a loss : false = Minimum profit is Break Even
 bool     EEAllowLoss         = false;                                          //Allow Loss

 string   LabelGS             = "Grid Settings:";
// Auto calculation of TakeProfit and Grid size;
 bool     AutoCal             = false;
 string   LabelATRTFr         = "0:Chart, 1:M1, 2:M5, 3:M15, 4:M30, 5:H1, 6:H4, 7:D1, 8:W1, 9:MN1";
// TimeFrame for ATR calculation
 int      ATRTF               = 0;
// Number of periods for the ATR calculation
 int      ATRPeriods          = 21;
// Widens/Squishes Grid on increments/decrements of .1
 double   GAF                 = 1.0;








extern string    LabelHS            = "";                                      //========HEDGE SETTINGS========       
// Enter the Symbol of the same/correlated pair EXACTLY as used by your broker.
extern  string   HedgeSymbol         = "";                                             //Symbol
// Number of days for checking Hedge Correlation
extern  int      CorrPeriod          = 30;                                             //Correlated period
// Turns DD hedge on/off
 extern bool     UseHedge            = false;                                          //Use Hedge
// DD = start hedge at set DD;Level = Start at set level
extern  string   DDorLevel           = "DD";                                           //DD or Level
// DD Percent or Level at which Hedge starts
extern  double   HedgeStart          = 5;                                              //Hedge Start
// Hedge Lots = Open Lots * hLotMult
 extern double   hLotMult            = 0.8;                                            //Hedge Lot Multiplier
// DD Hedge maximum pip loss - also hedge trailing stop
extern double   hMaxLossPips        = 20;                                             //Hedge Max Pip Loss
// true = fixed SL at hMaxLossPips
extern  bool     hFixedSL            = false;                                          //Hedge Fixed SL
// Hedge Take Profit
extern  double   hTakeProfit         = 30;                                             //Hedge TP
// Increase to HedgeStart to stop early re-entry of the hedge
extern  double   hReEntryPC          = 5;                                              //Hedge Re-entry
// True = Trailing Stop will stop at BE;False = Hedge will continue into profit
extern  bool     StopTrailAtBE       = true;                                           //Trailing Stop At Breakeven
// False = Trailing Stop is Fixed;True = Trailing Stop will reduce after BE is reached
 extern bool     ReduceTrailStop     = false;                                            //Reduce Trailing Stop







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
 bool     displayLogo         = true;
// Turns off the CCI display
 bool     displayCCI          = true;
// Show BE, TP and TS lines
 bool     displayLines        = true;
// Moves display left and right
 int      displayXcord        = 10;
// Moves display up and down
 int      displayYcord        = 22;
// Moves CCI display left and right
 int      displayCCIxCord     = 10;
//Display font
 string   displayFont         = "Verdana";
// Changes size of display characters
 int      displayFontSize     = 10;
// Changes space between lines
 int      displaySpacing      = 14;
// Ratio to increase label width spacing
 double   displayRatio        = 1;
// default color of display characters
 color    displayColor        = clrDimGray;
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
bool overBought = false;
bool overSold =   false;
bool SREntryTemp=false;
//+-----------------------------------------------------------------+
//| expert initialization function                                  |
//+-----------------------------------------------------------------+
int init()
{
   //check demo
   checkDemoOrLive();
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
   MaximizeProfitTemp = MaximizeProfit;
   SREntryTemp = SREntry;
   
   if(UseStopLoss){
      MaxTrades =1;
      isStopLossUsed = true;
   //if using trailing stop
      if(UseTrailingStop ){
            isTrailingStopUsed = true;
            useBasketExit = false;
            MaximizeProfit = false;
      }else{
            TSLPips =0; //trailing stop is off
            TrailingAtLevel = 0;
            MaximizeProfit = true;
            isTrailingStopUsed = false;
          }
    }else{
        MaximizeProfit =false; 
        isStopLossUsed = false;
    }

   
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

   MoveTP = ND(MoveTP * Pip, Digits);
   EntryOffset = ND(EntryOffset * Pip, Digits);
   SRDistance = ND(SRDistance*Pip,Digits);
   MADistance = ND(MADistance * Pip, Digits);
   MADistanceMax =  ND(MADistanceMax * Pip, Digits);
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

   if (UseHedge)
   {
      if (HedgeSymbol == "")
         HedgeSymbol = Symbol();

      if (HedgeSymbol == Symbol())
         hThisChart = true;
      else
         hThisChart = false;

      hPip = MarketInfo(HedgeSymbol, MODE_POINT);
      int hDigits = (int)MarketInfo(HedgeSymbol, MODE_DIGITS);

      if (hDigits % 2 == 1)
         hPip *= 10;

      if (CheckCorr() > 0.9 || hThisChart)
         hPosCorr = true;
      else if (CheckCorr() < -0.9)
         hPosCorr = false;
      else
      {
         AllowTrading = false;
         UseHedge = false;
         Print("The specified Hedge symbol (", HedgeSymbol, ") is not closely correlated with ", Symbol());
      }

      if (StringSubstr(DDorLevel, 0, 1) == "D" || StringSubstr(DDorLevel, 0, 1) == "d")
         HedgeTypeDD = true;
      else if (StringSubstr(DDorLevel, 0, 1) == "L" || StringSubstr(DDorLevel, 0, 1) == "l")
         HedgeTypeDD = false;
      else
         UseHedge = false;

      if (HedgeTypeDD)
      {
         HedgeStart /= 100;
         hDDStart = HedgeStart;
      }
   }

   StopTradePercent /= 100;
   ProfitSet /= 100;
   EEHoursPC /= 100;
   EELevelPC /= 100;
   hReEntryPC /= 100;
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

   if (CCIEntry < 0 || CCIEntry > 2)
      CCIEntry = 0;

   if (BollingerEntry < 0 || BollingerEntry > 2)
      BollingerEntry = 0;

   if (StochEntry < 0 || StochEntry > 2)
      StochEntry = 0;

   if (MACDEntry < 0 || MACDEntry > 2)
      MACDEntry = 0;

   if (MaxCloseTrades == 0)
      MaxCloseTrades = MaxTrades;

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
   dLabels = false;

   //+-----------------------------------------------------------------+
   //| Set Lot Array                                                   |
   //+-----------------------------------------------------------------+
   ArrayResize(Lots, MaxTrades);
   
   //+-----------------------------------------------------------------+
   //| Buot buot set lot array                                         |
   //+-----------------------------------------------------------------+
    if(ConsiderLotStep){
            for (int Index = 0; Index < MaxTrades; Index++)
         {
            if (Index == 0 ){
               Lots[Index] = TrueLotSize;
               }
            else{
                   Lots[Index] = ND(Lots[Index - 1] * Multiplier, LotDecimal);
                   if(Lots[Index]==Lots[Index - 1]){ //same lot size
                        Lots[Index] = ND(Lots[Index - 1]*2,2); //make it double
                   }
               }
           Print("Lot Size for level ", DTS(Index + 1, 0), " : ", DTS(Lots[Index],LotDecimal));
         }
     } else{
        for (int Index = 0; Index < MaxTrades; Index++)
         {
            if (Index == 0 || Multiplier < 1)
               Lots[Index] = Lot;
            else
               Lots[Index] = ND(MathMax(Lots[Index - 1] * Multiplier, Lots[Index - 1] + LotStep), LotDecimal);
  
           Print("Lot Size for level ", DTS(Index + 1, 0), " : ", DTS(Lots[Index] * MathMax(LotMult, 1), LotDecimal));
         }
     
     
     }


   if (Multiplier < 1)
      Multiplier = 1;

   //+-----------------------------------------------------------------+
   //| Set Grid and TP array                                           |
   //+-----------------------------------------------------------------+
   int GridSet = 0, GridTemp, GridTP, GridIndex = 0, GridLevel = 0, GridError = 0;

   if (!AutoCal)
   {
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

            if (Debug)
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
   }
   else
   {
      while (GridIndex < 4)
      {
         GridSet = StrToInteger(StringSubstr(SetCountArray, 0, StringFind(SetCountArray, ",")));
         SetCountArray = StringSubstr(SetCountArray, StringFind(SetCountArray, DTS(GridSet, 0)) + 2);

         if (GridIndex == 0 && GridSet < 1)
         {
            GridError = 1;
            break;
         }

         if (GridSet > 0)
            GridLevel += GridSet;
         else if (GridLevel < MaxTrades)
            GridLevel = MaxTrades;
         else
            GridLevel = MaxTrades + 1;

         if (GridIndex == 0)
            Set1Level = GridLevel;
         else if (GridIndex == 1 && GridLevel <= MaxTrades)
            Set2Level = GridLevel;
         else if (GridIndex == 2 && GridLevel <= MaxTrades)
            Set3Level = GridLevel;
         else if (GridIndex == 3 && GridLevel <= MaxTrades)
            Set4Level = GridLevel;

         GridIndex++;
      }

      if (GridError == 1 || Set1Level == 0)
      {
         Print("Error setting up Grid Levels. Check that the SetCountArray contains valid numbers separated by commas.");
         AllowTrading = false;
      }
   }

   //+-----------------------------------------------------------------+
   //| Set holidays array                                              |
   //+-----------------------------------------------------------------+
   if (UseHolidayShutdown)
   {
      int HolTemp = 0, NumHols, NumBS = 0, HolCounter = 0;
      string HolTempStr;

      if (StringFind(Holidays, ",", 0) == -1)
         NumHols = 1;
      else
      {
         NumHols = 1;

         while (HolTemp != -1)
         {
            HolTemp = StringFind(Holidays, ",", HolTemp + 1);

            if (HolTemp != -1)
               NumHols++;
         }
      }

      HolTemp = 0;

      while (HolTemp != -1)
      {
         HolTemp = StringFind(Holidays, "/", HolTemp + 1);

         if (HolTemp != -1)
            NumBS++;
      }

      if (NumBS != NumHols * 2)
      {
         Print("Holidays Error, number of back-slashes (", NumBS, ") should be equal to 2* number of Holidays (", NumHols, ", and separators should be commas.");
         AllowTrading = false;
      }
      else
      {
         HolTemp = 0;
         ArrayResize(HolArray, NumHols);

         while (HolTemp != -1)
         {
            if (HolTemp == 0)
               HolTempStr = StringTrimLeft(StringTrimRight(StringSubstr(Holidays, 0, StringFind(Holidays, ",", HolTemp))));
            else
               HolTempStr = StringTrimLeft(StringTrimRight(StringSubstr(Holidays, HolTemp + 1, StringFind(Holidays, ",", HolTemp + 1) - 
                                                                                               StringFind(Holidays, ",", HolTemp) - 1)));

            HolTemp = StringFind(Holidays, ",", HolTemp + 1);
            HolArray[HolCounter, 0] = StrToInteger(StringSubstr(StringSubstr(HolTempStr, 0, StringFind(HolTempStr, "-", 0)), 
                                      StringFind(StringSubstr(HolTempStr, 0, StringFind(HolTempStr, "-", 0)), "/") + 1));
            HolArray[HolCounter, 1] = StrToInteger(StringSubstr(StringSubstr(HolTempStr, 0, StringFind(HolTempStr, "-", 0)), 0, 
                                      StringFind(StringSubstr(HolTempStr, 0, StringFind(HolTempStr, "-", 0)), "/")));
            HolArray[HolCounter, 2] = StrToInteger(StringSubstr(StringSubstr(HolTempStr, StringFind(HolTempStr, "-", 0) + 1), 
                                      StringFind(StringSubstr(HolTempStr, StringFind(HolTempStr, "-", 0) + 1), "/") + 1));
            HolArray[HolCounter, 3] = StrToInteger(StringSubstr(StringSubstr(HolTempStr, StringFind(HolTempStr, "-", 0) + 1), 0, 
                                      StringFind(StringSubstr(HolTempStr, StringFind(HolTempStr, "-", 0) + 1), "/")));
            HolCounter++;
         }
      }

      for (HolTemp = 0; HolTemp < HolCounter; HolTemp++)
      {
         datetime Start1, Start2, Temp0, Temp1, Temp2, Temp3;

         for (int Item1 = HolTemp + 1; Item1 < HolCounter; Item1++)
         {
            Start1 = HolArray[HolTemp, 0] * 100 + HolArray[HolTemp, 1];
            Start2 = HolArray[Item1, 0] * 100 + HolArray[Item1, 1];

            if (Start1 > Start2)
            {
               Temp0 = HolArray[Item1, 0];
               Temp1 = HolArray[Item1, 1];
               Temp2 = HolArray[Item1, 2];
               Temp3 = HolArray[Item1, 3];
               HolArray[Item1, 0] = HolArray[HolTemp, 0];
               HolArray[Item1, 1] = HolArray[HolTemp, 1];
               HolArray[Item1, 2] = HolArray[HolTemp, 2];
               HolArray[Item1, 3] = HolArray[HolTemp, 3];
               HolArray[HolTemp, 0] = Temp0;
               HolArray[HolTemp, 1] = Temp1;
               HolArray[HolTemp, 2] = Temp2;
               HolArray[HolTemp, 3] = Temp3;
            }
         }
      }

      if (Debug)
      {
         for (HolTemp = 0; HolTemp < HolCounter; HolTemp++)
            Print("Holidays - From: ", HolArray[HolTemp, 1], "/", HolArray[HolTemp, 0], " - ", HolArray[HolTemp, 3], "/", HolArray[HolTemp, 2]);
      }
   }

   //+-----------------------------------------------------------------+
   //| Set email parameters                                            |
   //+-----------------------------------------------------------------+
   if (UseEmail)
   {
      if (Period() == 43200)
         sTF = "MN1";
      else if (Period() == 10800)
         sTF = "W1";
      else if (Period() == 1440)
         sTF = "D1";
      else if (Period() == 240)
         sTF = "H4";
      else if (Period() == 60)
         sTF = "H1";
      else if (Period() == 30)
         sTF = "M30";
      else if (Period() == 15)
         sTF = "M15";
      else if (Period() == 5)
         sTF = "M5";
      else if (Period() == 1)
         sTF = "M1";

      Email[0] = MathMax(MathMin(EmailDD1, MaxDDPercent - 1), 0) / 100;
      Email[1] = MathMax(MathMin(EmailDD2, MaxDDPercent - 1), 0) / 100;
      Email[2] = MathMax(MathMin(EmailDD3, MaxDDPercent - 1), 0) / 100;
      ArraySort(Email, WHOLE_ARRAY, 0, MODE_ASCEND);

      for (int z = 0; z <= 2; z++)
      {
         for (int Index = 0; Index <= 2; Index++)
         {
            if (Email[Index] == 0)
            {
               Email[Index] = Email[Index + 1];
               Email[Index + 1] = 0;
            }
         }

         if (Debug)
            Print("Email [", (z + 1), "] : ", Email[z]);
      }
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
         if (!Testing)
            LabelDelete();

         Comment("");
   }

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
   
   //scalping on first level (0)
   if (UseScalping){ScalpFirstLevel();}
   //get RSI Filter
   double RSIValue = iRSI(Symbol(),0,14,PRICE_CLOSE,0);
 
	if(RSIValue>overBoughtZone){
	   overBought = true;
	   overSold =false;
	}
	else if(RSIValue<overSoldZone){
	   overBought = false;
	   overSold =true;
	}else{
	   //accept entry here
	   overBought = false;
	   overSold =false;
	}

   //Support and resistance draw
   if(SREntry&&ShutDown==false && AllowTrading == true){
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
	bool StopThisTime = TimeHour(TimeLocal()) >= TimeToStop;
   if (((date.day_of_week==1 && TradeOnMonday==false)||(date.day_of_week==2 && TradeOnTuesday==false)||(date.day_of_week==3 && TradeOnWednesday==false)||
    (date.day_of_week==4 && TradeOnThursday==false)||(date.day_of_week==5 && TradeOnFriday==false)) && StopThisTime == true){
       ShutDown = true;
    }
    if(date.day_of_week==1 && ShutDownTemp==false){
      DrawRectangle();
      ShutDown= false;
      AllowTrading = true;
      ObjDel("ZeusLStop");
      ObjDel("ZeusLExpt");
      ObjDel("ZeusLResm");
      LabelCreate();
      DrawRectangle_Resize();
    }
    //total orders reached maximum and its not shutdown mode and this pair's orders =0
    if(MaxEntryTrades<=getTotalTrades() && ShutDown ==false && CbT==0){
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
                  if(SREntry&&ShutDown==false){
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
         Print("Robot has shut down. Set ShutDown = 'false' to resume trading");

         if (PlaySounds)
            PlaySound(AlertSound);

         AllowTrading = false;
      }

      if (UseEmail && EmailCount < 4&& !Testing)
      {
         SendMail("EA", "Robot has shut down on " + Symbol() + " " + sTF + ". To resume trading, change ShutDown to false.");
         Error = GetLastError();

         if (Error > 0)
            Print("Error ", Error, " (", ErrorDescription(Error), ") sending email");
         else
            EmailCount = 4;
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
            
            CreateLabel("ZeusLStop", "Maximum Entries from all pairs reached.", 10, 0, 0, 3, displayColorLoss);
            
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

      if (PlaySounds)
         PlaySound(AlertSound);

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
   double ima_0 = iMA(Symbol(), 0, MAPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
   
   // bid 300
   //ima = 0 + 100
   //ima max = 0+200
  // if bid > 100= yes
  // if bid<=200 = yes
   
   if (ForceMarketCond == 3)
   {
      if (BID > ima_0 + MADistance)
         Trend = 0;
      else if (ASK < ima_0 - MADistance)
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
   //| ATR for Auto Grid Calculation and Grid Set Block                |
   //+-----------------------------------------------------------------+
   double GridTP;

   if (AutoCal)
   {
      double GridATR = iATR(NULL, TF[ATRTF], ATRPeriods, 0) / Pip;

      if ((CbT + CbC > Set4Level) && Set4Level > 0)
      {
         g2 = GridATR * 12;    //GS*2*2*2*1.5
         tp2 = GridATR * 18;   //GS*2*2*2*1.5*1.5
      }
      else if ((CbT + CbC > Set3Level) && Set3Level > 0)
      {
         g2 = GridATR * 8;     //GS*2*2*2
         tp2 = GridATR * 12;   //GS*2*2*2*1.5
      }
      else if ((CbT + CbC > Set2Level) && Set2Level > 0)
      {
         g2 = GridATR * 4;     //GS*2*2
         tp2 = GridATR * 8;    //GS*2*2*2
      }
      else if ((CbT + CbC > Set1Level) && Set1Level > 0)
      {
         g2 = GridATR * 2;     //GS*2
         tp2 = GridATR * 4;    //GS*2*2
      }
      else
      {
         g2 = GridATR;
         tp2 = GridATR * 2;
      }

      GridTP = GridATR * 2;
   }
   else
   {
      int Index = (int)MathMax(MathMin(CbT + CbC, MaxTrades) - 1, 0);
      g2 = GridArray[Index, 0];
      tp2 = GridArray[Index, 1];
      GridTP = GridArray[0, 1];
   }

   g2 = ND(MathMax(g2 * GAF * Pip, Pip), Digits);
   tp2 = ND(tp2 * GAF * Pip, Digits);
   GridTP = ND(GridTP * GAF * Pip, Digits);

   //+-----------------------------------------------------------------+
   //| Money Management and Lot size coding                            |
   //+-----------------------------------------------------------------+
   if (UseMM)
   {
      if (CbT > 0)
      {
         if (GlobalVariableCheck(ID + "LotMult"))
            LotMult = (int)GlobalVariableGet(ID + "LotMult");

         if (LbF != LotSize(Lots[0] * LotMult))
         {
            LotMult = (int)(LbF / Lots[0]);
            GlobalVariableSet(ID + "LotMult", LotMult);
            Print("LotMult reset to " + DTS(LotMult, 0));
         }
      }
      else if (CbT == 0)
      {
         double Contracts, Factor, Lotsize;
         Contracts = PortionBalance / 10000;

         if (Multiplier <= 1)
            Factor = Level;
         else
            Factor = (MathPow(Multiplier, Level) - Multiplier) / (Multiplier - 1);

         Lotsize = LAF * AccountType * Contracts / (1 + Factor);
         LotMult = (int)MathMax(MathFloor(Lotsize / Lot), MinMult);
         GlobalVariableSet(ID + "LotMult", LotMult);
      }
   }
   else if (CbT == 0)
      LotMult = MinMult;

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

         NewTP += MoveTP * Moves;

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

         NewTP -= MoveTP * Moves;

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

   //+-----------------------------------------------------------------+
   //| Adjust BEb/TakeProfit if Hedge is active                        |
   //+-----------------------------------------------------------------+
   double hAsk = MarketInfo(HedgeSymbol, MODE_ASK);
   double hBid = MarketInfo(HedgeSymbol, MODE_BID);
   double hSpread = hAsk - hBid;

   if (hThisChart)
      nLots += LhB - LhS;

   double TPa = 0, PhPips;

   if (hActive == 1)
   {
      if (nLots == 0)
      {
         BEa = 0;
         TPa = 0;
      }
      else if (hThisChart)
      {
         if (nLots > 0)
         {
            if (CbB > 0)
               BEa = ND((BEb * LbT - (BEh - hSpread) * LhT) / (LbT - LhT), Digits);
            else
               BEa = ND(((BEb - (ASK - BID)) * LbT - BEh * LhT) / (LbT - LhT), Digits);

            TPa = ND(BEa + TargetPips, Digits);
         }
         else
         {
            if (CbS > 0)
               BEa = ND((BEb * LbT - (BEh + hSpread) * LhT) / (LbT - LhT), Digits);
            else
               BEa = ND(((BEb + ASK - BID) * LbT - BEh * LhT) / (LbT - LhT), Digits);

            TPa = ND(BEa - TargetPips, Digits);
         }
      }

      if (ChB > 0)
         PhPips = ND((hBid - BEh) / hPip, 1);

      if (ChS > 0)
         PhPips = ND((BEh - hAsk) / hPip, 1);
   }
   else
   {
      BEa = BEb;
      TPa = TPb;
   }

   //+-----------------------------------------------------------------+
   //| Calculate Early Exit Percentage                                 |
   //+-----------------------------------------------------------------+
   double EEpc = 0, EEStartTime = 0, TPaF;

   if (UseEarlyExit && CbT > 0)
   {
      datetime EEopt;

      if (EEFirstTrade)
         EEopt = OTbF;
      else
         EEopt = OTbL;

      if (DayOfWeek() < TimeDayOfWeek(EEopt))
         EEStartTime = 2 * 24 * 3600;

      EEStartTime += EEopt + EEStartHours * 3600;

      if (EEHoursPC > 0 && TimeCurrent() >= EEStartTime)
         EEpc = EEHoursPC * (TimeCurrent() - EEStartTime) / 3600;

      if (EELevelPC > 0 && (CbT + CbC) >= EEStartLevel)
         EEpc += EELevelPC * (CbT + CbC - EEStartLevel + 1);

      EEpc= 1 - EEpc;

      if (!EEAllowLoss && EEpc < 0)
         EEpc = 0;

      PbTarget *= EEpc;
      TPaF = ND((TPa - BEa) * EEpc + BEa, Digits);

      if (displayOverlay && displayLines && (hActive != 1 || (hActive == 1 && hThisChart)) && (!Testing || (Testing && Visual)) && 
          EEpc < 1 && (CbT + CbC + ChT > EECount || EETime != Time[0]) && 
          ((EEHoursPC > 0 && EEopt + EEStartHours * 3600 < Time[0]) || (EELevelPC > 0 && CbT + CbC >= EEStartLevel)))
      {
         EETime = Time[0];
         EECount = CbT + CbC + ChT;

         if (ObjectFind("ZeusLEELn") < 0)
         {
            ObjectCreate("ZeusLEELn", OBJ_TREND, 0, 0, 0);
            ObjectSet("ZeusLEELn", OBJPROP_COLOR, Yellow);
            ObjectSet("ZeusLEELn", OBJPROP_WIDTH, 1);
            ObjectSet("ZeusLEELn", OBJPROP_STYLE, 0);
            ObjectSet("ZeusLEELn", OBJPROP_RAY, false);
         }

         if (EEHoursPC > 0)
            ObjectMove("ZeusLEELn", 0, (datetime)(MathFloor(EEopt / 3600 + EEStartHours) * 3600), TPa);
         else
            ObjectMove("ZeusLEELn", 0, (datetime)(MathFloor(EEopt / 3600) * 3600), TPaF);

         ObjectMove("ZeusLEELn", 1, Time[1], TPaF);

         if (ObjectFind("ZeusVEELn") < 0)
         {
            ObjectCreate("ZeusVEELn", OBJ_TEXT, 0, 0, 0);
         
            ObjectSet("ZeusVEELn", OBJPROP_COLOR, Yellow);
            ObjectSet("ZeusVEELn", OBJPROP_WIDTH, 1);
            ObjectSet("ZeusVEELn", OBJPROP_STYLE, 0);
         }

         ObjSetTxt("ZeusVEELn", "              " + DTS(TPaF, Digits), -1, Yellow);
         ObjectSet("ZeusVEELn", OBJPROP_PRICE1, TPaF + 2 * Pip);
         ObjectSet("ZeusVEELn", OBJPROP_TIME1, Time[1]);
      }
      else if ((!displayLines || EEpc == 1 || (!EEAllowLoss && EEpc == 0) || (EEHoursPC > 0 && EEopt + EEStartHours * 3600 >= Time[0])))
      {
         ObjDel("ZeusLEELn");
         ObjDel("ZeusVEELn");
      }
   }
   else
   {
      TPaF = TPa;
      EETime = 0;
      EECount = 0;
      ObjDel("ZeusLEELn");
      ObjDel("ZeusVEELn");
   }

   //+-----------------------------------------------------------------+
   //| Maximize Profit with Moving TP and setting Trailing Profit Stop |
   //+-----------------------------------------------------------------+
   double TPbMP = 0;

   if (MaximizeProfit)
   {
      if (CbT == 0)
      {
         SLbL = 0;
         Moves = 0;
         SLb = 0;
      }

      if (!FirstRun && CbT > 0)
      {
         if (Pb + Ph < 0 && SLb > 0)
            SLb = 0;

         if (SLb > 0 && ((nLots > 0 && BID < SLb) || (nLots < 0 && ASK > SLb)))
         {
            ExitTrades(A, displayColorProfit, "Profit Trailing Stop Reached (" + DTS(ProfitSet * 100, 2) + "%)");

            return (0);
         }

         if (PbTarget > 0)
         {
            TPbMP = ND(BEa + (TPa - BEa) * ProfitSet, Digits);

            if ((nLots > 0 && BID > TPbMP) || (nLots < 0 && ASK < TPbMP))
               SLb = TPbMP;
         }

         if (SLb > 0 && SLb != SLbL && MoveTP > 0 && TotalMoves > Moves)
         {
            TPb = 0;
            Moves++;

            if (Debug)
               Print("MoveTP");

            SLbL = SLb;

            if (PlaySounds)
               PlaySound(AlertSound);

            return (0);
         }
      }
   }

   if (!FirstRun && TPaF > 0)
   {
      if ((nLots > 0 && BID >= TPaF) || (nLots < 0 && ASK <= TPaF))
      {
         ExitTrades(A, displayColorProfit, "Profit Target Reached @ " + DTS(TPaF, Digits));

         return (0);
      }
   }

   double bSL = 0;

   if (!FirstRun && UseStopLoss)
   {
      if (SLPips > 0)
      {
         if (nLots > 0)
         {
            bSL = BEa - SLPips;

            if (BID <= bSL)
            {
               ExitTrades(A, displayColorProfit, "Stop Loss Reached");

               return (0);
            }
         }
         else if (nLots < 0)
         {
            bSL = BEa + SLPips;

            if (ASK >= bSL)
            {
               ExitTrades(A, displayColorProfit, "Stop Loss Reached");

               return (0);
            }
         }
      }

      if (TSLPips != 0)
      {
         if (nLots > 0)
         {
            if (TSLPips > 0 && BID > BEa + TSLPips)
               bTS = MathMax(bTS, BID - TSLPips);

            if (TSLPips < 0 && BID > BEa - TSLPips)
               bTS = MathMax(bTS, BID - MathMax(TSLPipsMin, -TSLPips * (1 - (BID - BEa + TSLPips) / (-TSLPips * 2))));

            if (bTS > 0 && BID <= bTS)
            {
               ExitTrades(A, displayColorProfit, "Trailing Stop Reached");

               return (0);
            }
         }
         else if (nLots < 0)
         {
            if (TSLPips > 0 && ASK < BEa - TSLPips)
            {
               if (bTS > 0)
                  bTS = MathMin(bTS, ASK + TSLPips);
               else
                  bTS = ASK + TSLPips;
            }

            if (TSLPips < 0 && ASK < BEa + TSLPips)
               bTS = MathMin(bTS, ASK + MathMax(TSLPipsMin, -TSLPips * (1 - (BEa - ASK + TSLPips) / (-TSLPips * 2))));

            if (bTS > 0 && ASK >= bTS)
            {
               ExitTrades(A, displayColorProfit, "Trailing Stop Reached");

               return (0);
            }
         }
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
          //buot buot addition
         double buot2 = LotMult;
         if(ConsiderLotStep){buot2 = 1;}
         if (ND(OrderLots(), LotDecimal) > ND(Lots[0] * buot2, LotDecimal))
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
   //| Check Holiday Shutdown                                          |
   //+-----------------------------------------------------------------+
   if (UseHolidayShutdown)
   {
      if (HolShutDown > 0 && TimeCurrent() >= HolLast && HolLast > 0)
      {
         Print("Trading has resumed after the ", TimeToStr(HolFirst, TIME_DATE), " - ", TimeToStr(HolLast, TIME_DATE), " holidays.");
         HolShutDown = 0;
         LabelDelete();
         LabelCreate();

         if (PlaySounds)
            PlaySound(AlertSound);
      }

      if (HolShutDown == 3)
      {
         if (ObjectFind("ZeusLStop") == -1)
            CreateLabel("ZeusLStop", "Trading has been paused on this pair for the holidays.", 10, 0, 0, 3, displayColorLoss);

         if (ObjectFind("ZeusLResm") == -1)
            CreateLabel("ZeusLResm", "Trading will resume trading after " + TimeToStr(HolLast, TIME_DATE) + ".", 10, 0, 0, 9, displayColorLoss);

         return (0);
      }
      else if ((HolShutDown == 0 && TimeCurrent() >= HolLast) || HolFirst == 0)
      {
         for (int Index = 0; Index < ArraySize(HolArray); Index++)
         {
            HolFirst = StrToTime((string)Year() + "." + (string)HolArray[Index, 0] + "." + (string)HolArray[Index, 1]);
            HolLast = StrToTime((string)Year() + "." + (string)HolArray[Index, 2] + "." + (string)HolArray[Index, 3] + " 23:59:59");

            if (TimeCurrent() < HolFirst)
            {
               if (HolFirst > HolLast)
                  HolLast = StrToTime(DTS(Year() + 1, 0) + "." + (string)HolArray[Index, 2] + "." + (string)HolArray[Index, 3] + " 23:59:59");

               break;
            }

            if (TimeCurrent() < HolLast)
            {
               if (HolFirst > HolLast)
                  HolFirst = StrToTime(DTS(Year() - 1, 0) + "." + (string)HolArray[Index, 0] + "." + (string)HolArray[Index, 1]);

               break;
            }

            if (TimeCurrent() > HolFirst && HolFirst > HolLast)
            {
               HolLast = StrToTime(DTS(Year() + 1, 0) + "." + (string)HolArray[Index, 2] + "." + (string)HolArray[Index, 3] + " 23:59:59");

               if (TimeCurrent() < HolLast)
                  break;
            }
         }

         if (TimeCurrent() >= HolFirst && TimeCurrent() <= HolLast)
         {
            Comment("");
            HolShutDown = 1;
         }
      }
      else if (HolShutDown == 0 && TimeCurrent() >= HolFirst && TimeCurrent() < HolLast)
         HolShutDown = 1;

      if (HolShutDown == 1 && CbT == 0)
      {
         Print("Trading has been paused for holidays (", TimeToStr(HolFirst, TIME_DATE), " - ", TimeToStr(HolLast, TIME_DATE), ")");

         if (CpT > 0)
         {
            int y = ExitTrades(P, displayColorLoss, "Holiday Shutdown");

            if (y == CpT)
               ca = 0;
         }

         HolShutDown = 2;
         ObjDel("ZeusLClos");
      }
      else if (HolShutDown == 1)
      {
         if (ObjectFind("ZeusLClos") == -1)
            CreateLabel("ZeusLClos", "", 5, 0, 0, 23, displayColorLoss);

         ObjSetTxt("ZeusLClos", "Trading will pause for holidays when this basket closes", 5);
      }

      if (HolShutDown == 2)
      {
         LabelDelete();

         if (PlaySounds)
            PlaySound(AlertSound);

         HolShutDown = 3;
      }

      if (HolShutDown == 3)
      {
         if (ObjectFind("ZeusLStop") == -1)
            CreateLabel("ZeusLStop", "Trading has been paused on this pair due to holidays.", 10, 0, 0, 3, displayColorLoss);

         if (ObjectFind("ZeusLResm") == -1)
            CreateLabel("ZeusLResm", "Trading will resume after " + TimeToStr(HolLast, TIME_DATE) + ".", 10, 0, 0, 9, displayColorLoss);

         Comment("");

         return (0);
      }
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
   if (MAEntry > 0 && CbT == 0 && CpT < 2)
   {
      if (((BID > ima_0 + MADistance) ) && (!B3Traditional || (B3Traditional && Trend != 2))) //for BUY
      {
         if (MAEntry == 1 && (BID<=ima_0+MADistanceMax))
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
         if (MAEntry == 1 && (ASK>=ima_0-MADistanceMax))
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
   //| CCI of 5M, 15M, 30M, 1H for Market Condition and Order Entry      |
   //+----------------------------------------------------------------+
   double cci_01 = 0;
   double cci_02 = 0;
   double cci_03 = 0;
   double cci_04 = 0;
   double cci_11 = 0;
   double cci_12 = 0;
   double cci_13 = 0;
   double cci_14 = 0;

   if (CCIEntry > 0)
   {
      cci_01 = iCCI(Symbol(), PERIOD_M5, CCIPeriod, PRICE_CLOSE, 0);
      cci_02 = iCCI(Symbol(), PERIOD_M15, CCIPeriod, PRICE_CLOSE, 0);
      cci_03 = iCCI(Symbol(), PERIOD_M30, CCIPeriod, PRICE_CLOSE, 0);
      cci_04 = iCCI(Symbol(), PERIOD_H1, CCIPeriod, PRICE_CLOSE, 0);
      cci_11 = iCCI(Symbol(), PERIOD_M5, CCIPeriod, PRICE_CLOSE, 1);
      cci_12 = iCCI(Symbol(), PERIOD_M15, CCIPeriod, PRICE_CLOSE, 1);
      cci_13 = iCCI(Symbol(), PERIOD_M30, CCIPeriod, PRICE_CLOSE, 1);
      cci_14 = iCCI(Symbol(), PERIOD_H1, CCIPeriod, PRICE_CLOSE, 1);
   }

   if (CCIEntry > 0 && CbT == 0 && CpT < 2)
   {
      if (cci_11 > 0 && cci_12 > 0 && cci_13 > 0 && cci_14 > 0 && cci_01 > 0 && cci_02 > 0 && cci_03 > 0 && cci_04 > 0)
      {
         if (ForceMarketCond == 3)
            Trend = 0;

         if (CCIEntry == 1)
         {
            if (ForceMarketCond != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
               BuyMe = true;
            else
               BuyMe = false;

            if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               SellMe = false;
         }
         else if (CCIEntry == 2)
         {
            if (ForceMarketCond != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
               SellMe = true;
            else
               SellMe = false;

            if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               BuyMe = false;
         }
      }
      else if (cci_11 < 0 && cci_12 < 0 && cci_13 < 0 && cci_14 < 0 && cci_01 < 0 && cci_02 < 0 && cci_03 < 0 && cci_04 < 0)
      {
         if (ForceMarketCond == 3)
            Trend = 1;

         if (CCIEntry == 1)
         {
            if (ForceMarketCond != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
               SellMe = true;
            else
               SellMe = false;

            if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               BuyMe = false;
         }
         else if (CCIEntry == 2)
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

      if (IndEntry > 0)
         IndicatorUsed = IndicatorUsed + UAE;

      IndEntry++;
      IndicatorUsed = IndicatorUsed + " CCI ";
   }

   //+----------------------------------------------------------------+
   //| Bollinger Band Indicator for Order Entry                       |
   //+----------------------------------------------------------------+
   if (BollingerEntry > 0 && CbT == 0 && CpT < 2)
   {
      double ma = iMA(Symbol(), 0, BollPeriod, 0, MODE_SMA, PRICE_OPEN, 0);
      double stddev = iStdDev(Symbol(), 0, BollPeriod, 0, MODE_SMA, PRICE_OPEN, 0);
      double bup = ma + (BollDeviation * stddev);
      double bdn = ma - (BollDeviation * stddev);
      double bux = bup + BollDistance;
      double bdx = bdn - BollDistance;

      if (ASK < bdx)
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
      else if (BID > bux)
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

      if (IndEntry > 0)
         IndicatorUsed = IndicatorUsed + UAE;

      IndEntry++;
      IndicatorUsed = IndicatorUsed + " BBands ";
   }
   
   //+----------------------------------------------------------------+
   //| BREAKOUT  order entry                                          |
   //+----------------------------------------------------------------+
   
    if (SREntryTemp && CbT == 0 && CpT < 2){
       bool resitanceExist =false;
       bool supportExist = false;
       if(ObjectFind("Z_Resistance")>=0){
         resitanceExist = true;
       }
        if(ObjectFind("Z_Support")>=0){
         supportExist = true;
       }
      double bHi = ObjectGet("Z_Resistance", OBJPROP_PRICE1)+EntryOffset;
      double bLo = ObjectGet("Z_Support", OBJPROP_PRICE1)-EntryOffset;
      double PriceHiLoDistance = bHi-bLo;

      
    
      if (BID > bHi && resitanceExist && supportExist && SRDistance < PriceHiLoDistance && Trend == 1)
      {  
         if(SRRemoveOnTrade){
         ObjectDelete("Z_Resistance");
         }else{
          
           // SREntryTemp = false;
         }
         
            BuyMe = true;
       
         
         
         
      }
     
      else if (ASK<bLo && supportExist && resitanceExist && SRDistance < PriceHiLoDistance && Trend == 0)
      {
        
          if(SRRemoveOnTrade){
         
          ObjectDelete("Z_Support");}
          else{
        //  SREntryTemp = false;
          }
          
           SellMe = true;
         

       
      }
      else  {
               BuyMe = false;
               SellMe = false;
              // MAEntry=0;
               Print(MAEntry);
            //   SREntryTemp = true;
      }

            
          if (IndEntry > 0){
            IndicatorUsed = IndicatorUsed + UAE;}

          IndEntry++;
          IndicatorUsed = IndicatorUsed + " S&R ";
    }
   

   //+----------------------------------------------------------------+
   //| Stochastic Indicator for Order Entry                           |
   //+----------------------------------------------------------------+
   if (StochEntry > 0 && CbT == 0 && CpT < 2)
   {
      int zoneBUY = BuySellStochZone;
      int zoneSELL = 100 - BuySellStochZone;
      double stoc_0 = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, MODE_LWMA, 1, 0, 1);
      double stoc_1 = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, MODE_LWMA, 1, 1, 1);

      if (stoc_0 < zoneBUY && stoc_1 < zoneBUY)
      {
         if (StochEntry == 1)
         {
            if (ForceMarketCond !=1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
               BuyMe = true;
            else
               BuyMe = false;

            if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               SellMe = false;
         }
         else if (StochEntry == 2)
         {
            if (ForceMarketCond != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
               SellMe = true;
            else
               SellMe = false;

            if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               BuyMe = false;
         }
      }
      else if (stoc_0 > zoneSELL && stoc_1 > zoneSELL)
      {
         if (StochEntry == 1)
         {
            if (ForceMarketCond != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
               SellMe = true;
            else
               SellMe = false;

            if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               BuyMe = false;
         }
         else if (StochEntry == 2)
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

      if (IndEntry > 0)
         IndicatorUsed = IndicatorUsed + UAE;

      IndEntry++;
      IndicatorUsed = IndicatorUsed + " Stoch ";
   }

   //+----------------------------------------------------------------+
   //| MACD Indicator for Order Entry                                 |
   //+----------------------------------------------------------------+
   if (MACDEntry > 0 && CbT == 0 && CpT < 2)
   {
      double MACDm = iMACD(NULL, TF[MACD_TF], FastPeriod, SlowPeriod, SignalPeriod, MACDPrice, 0, 0);
      double MACDs = iMACD(NULL, TF[MACD_TF], FastPeriod, SlowPeriod, SignalPeriod, MACDPrice, 1, 0);

      if (MACDm > MACDs)
      {
         if (MACDEntry == 1)
         {
            if (ForceMarketCond != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
               BuyMe = true;
            else
               BuyMe = false;

            if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               SellMe = false;
         }
         else if (MACDEntry == 2)
         {
            if (ForceMarketCond != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
               SellMe = true;
            else
               SellMe = false;

            if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               BuyMe = false;
         }
      }
      else if (MACDm < MACDs)
      {
         if (MACDEntry == 1)
         {
            if (ForceMarketCond != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
               SellMe = true;
            else
               SellMe = false;

            if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               BuyMe = false;
         }
         else if (MACDEntry == 2)
         {
            if (ForceMarketCond != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
               BuyMe = true;
            else
               BuyMe = false;

            if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
               SellMe = false;
         }
      }
      else if (!UseAnyEntry && IndEntry>0)
      {
           BuyMe = false;
         SellMe = false;
      }

      if (IndEntry > 0)
         IndicatorUsed = IndicatorUsed + UAE;

      IndEntry++;
      IndicatorUsed = IndicatorUsed + " MACD ";
   }
   
  // RSIDisable=0,   //Disable
   //RSIZonesOnly=1,   //Zones Only
  // RSIZonesIgnored=2, //Zones Ignored
 //  RISIZonesFiltered=3, //Zones Filtered
 
 
    //disabllow Trading if filtered with RSI
//     if(overBought && BuyMe && useRSIFilter){
        //    BuyMe =false;
  //   }
    // if(overSold && SellMe && useRSIFilter){
           // SellMe = false;
    // }
     
   
     if((!overBought && !overSold) && useRSIFilter == 1){  //ZONES ONLY
            BuyMe =false;
            SellMe = false;
     }else if(overBought && BuyMe && useRSIFilter==3){ //filter with zones BUY
           BuyMe =false;
     }else if(overSold && SellMe && useRSIFilter==3){ //filter with zones SELL
           SellMe =false;
     }else if((overBought || overSold) && useRSIFilter==2){ //Zones Ignored
            BuyMe =false;
            SellMe = false;
     }else{
        //continue trading nothing happens
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



   //+-----------------------------------------------------------------+
   //| Trade Selection Logic                                           |
   //+-----------------------------------------------------------------+
   //Buot buot addition
   if(ConsiderLotStep){
    OrderLot = LotSize(Lots[StrToInteger(DTS(MathMin(CbT + CbC, MaxTrades - 1), 0))]);
   }else{
    OrderLot = LotSize(Lots[StrToInteger(DTS(MathMin(CbT + CbC, MaxTrades - 1), 0))] * LotMult);
    }
  

   double OPbN = 0;

   if (CbT == 0 && CpT < 2 && !FirstRun)
   {
      //added by kimoy gwapo
      //count total oders before trading new
      if (B3Traditional)
      {
      
         if (BuyMe)
         {
            if (CpBS == 0 && CpSL == 0 && ((Trend != 2 || MAEntry == 0) || (Trend == 2 && MAEntry == 1)))
            {
               Entry = g2 - MathMod(ASK, g2) + EntryOffset;

               if (Entry > StopLevel)
               {
                  Ticket = SendOrder(Symbol(), OP_BUYSTOP, OrderLot, Entry, 0, Magic, CLR_NONE,TradeComment);

                  if (Ticket > 0)
                  {
                     if (Debug)
                        Print("Indicator Entry - (", IndicatorUsed, ") BuyStop MC = ", Trend);

                     CpBS++;
                  }
               }
            }

         }

         if (SellMe)
         {

            if (CpSS == 0 && CpBL == 0 && ((Trend != 2 || MAEntry == 0) || (Trend == 2 && MAEntry == 1)))
            {
               Entry = MathMod(BID, g2) + EntryOffset;

               if (Entry > StopLevel)
               {
                  Ticket = SendOrder(Symbol(), OP_SELLSTOP, OrderLot, -Entry, 0, Magic, CLR_NONE,TradeComment);

                  if (Ticket > 0 && Debug)
                     Print("Indicator Entry - (", IndicatorUsed, ") SellStop MC = ", Trend);
               }
            }
         }
      }
      else
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
         
        
      }

      if (Ticket > 0)
         return (0);
   }
   else if (TimeCurrent() - EntryDelay > OTbL && CbT + CbC < MaxTrades && !FirstRun)
   {
      if (UseSmartGrid)
      {
         if (RSI[1] != iRSI(NULL, TF[RSI_TF], RSI_Period, RSI_Price, 1))
            for (int Index = 0; Index < RSI_Period + RSI_MA_Period; Index++)
               RSI[Index] = iRSI(NULL, TF[RSI_TF], RSI_Period, RSI_Price, Index);
         else RSI[0] = iRSI(NULL, TF[RSI_TF], RSI_Period, RSI_Price, 0);
            RSI_MA = iMAOnArray(RSI, 0, RSI_MA_Period, 0, RSI_MA_Method, 0);
      }

      if (CbB > 0)
      {
         if (OPbL > ASK)
            Entry = OPbL - (MathRound((OPbL - ASK) / g2) + 1) * g2;
         else
            Entry = OPbL - g2;

         if (UseSmartGrid)
         {
            if (ASK < OPbL - g2)
            {
               if (RSI[0] > RSI_MA)
               {
                  Ticket = SendOrder(Symbol(), OP_BUY, OrderLot, 0, slip, Magic, Blue, TradeComment);

                  if (Ticket > 0 && Debug)
                     Print("SmartGrid Buy RSI: ", RSI[0], " > MA: ", RSI_MA);
               }

               OPbN = 0;
            }
            else
               OPbN = OPbL - g2;
         }
         else if (CpBL == 0)
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

         if (UseSmartGrid)
         {
            if (BID > OPbL + g2)
            {
               if (RSI[0] < RSI_MA)
               {
                  Ticket = SendOrder(Symbol(), OP_SELL, OrderLot, 0, slip, Magic, displayColorLoss,TradeComment);

                  if (Ticket > 0 && Debug)
                     Print("SmartGrid Sell RSI: ", RSI[0], " < MA: ", RSI_MA);
               }

               OPbN = 0;
            }
            else
               OPbN = OPbL + g2;
         }
         else if (CpSL == 0)
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
   //| Hedge Trades Set-Up and Monitoring                              |
   //+-----------------------------------------------------------------+
   if ((UseHedge && CbT > 0) || ChT>0)
   {
      int hLevel = CbT + CbC;

      if (HedgeTypeDD)
      {
         if (hDDStart == 0 && ChT > 0)
            hDDStart = MathMax(HedgeStart, DrawDownPC + hReEntryPC);

         if (hDDStart > HedgeStart && hDDStart > DrawDownPC + hReEntryPC)
            hDDStart = DrawDownPC + hReEntryPC;

         if (hActive == 2)
         {
            hActive = 0;
            hDDStart = MathMax(HedgeStart, DrawDownPC + hReEntryPC);
         }
      }

      if (hActive == 0)
      {
         if (!hThisChart && ((hPosCorr && CheckCorr() < 0.9) || (!hPosCorr&&CheckCorr() > -0.9)))
         {
            if (ObjectFind("ZeusLhCor") == -1)
               CreateLabel("ZeusLhCor", "Correlation with the hedge pair has dropped below 90%.", 0, 0, 190, 10, displayColorLoss);
         }
         else
            ObjDel("ZeusLhCor");

         if (hLvlStart>hLevel + 1 || (!HedgeTypeDD && hLvlStart == 0))
            hLvlStart = MathMax(HedgeStart, hLevel + 1);

         if ((HedgeTypeDD && DrawDownPC > hDDStart) || (!HedgeTypeDD && hLevel >= hLvlStart))
         {
            OrderLot = LotSize(LbT * hLotMult);

            if ((CbB > 0 && !hPosCorr) || (CbS > 0 && hPosCorr))
            {
               Ticket = SendOrder(HedgeSymbol, OP_BUY, OrderLot, 0, slip, hMagic, MidnightBlue,TradeComment);

               if (Ticket > 0)
               {
                  if (hMaxLossPips > 0)
                     SLh = hAsk - hMaxLossPips;

                  if (Debug)
                     Print("Hedge Buy: Stoploss @ ", DTS(SLh, Digits));
               }
            }

            if ((CbB > 0 && hPosCorr) || (CbS > 0 && !hPosCorr))
            {
               Ticket = SendOrder(HedgeSymbol, OP_SELL, OrderLot, 0, slip, hMagic, Maroon,TradeComment);

               if (Ticket > 0)
               {
                  if (hMaxLossPips > 0)
                     SLh = hBid + hMaxLossPips;

                  if (Debug)
                     Print("Hedge Sell: Stoploss @ ", DTS(SLh, Digits));
               }
            }

            if (Ticket > 0)
            {
               hActive = 1;

               if (HedgeTypeDD)
                  hDDStart += hReEntryPC;

               hLvlStart = hLevel + 1;

               return (0);
            }
         }
      }
      else if (hActive == 1)
      {
         if (HedgeTypeDD && hDDStart > HedgeStart && hDDStart < DrawDownPC + hReEntryPC)
            hDDStart = DrawDownPC + hReEntryPC;

         if (hLvlStart == 0)
         {
            if (HedgeTypeDD)
               hLvlStart = hLevel + 1;
            else
               hLvlStart = MathMax(HedgeStart, hLevel + 1);
         }

         if (hLevel >= hLvlStart)
         {
            OrderLot = LotSize(Lots[CbT + CbC - 1] * LotMult * hLotMult);

            if (OrderLot > 0 && ((CbB > 0 && !hPosCorr) || (CbS > 0 && hPosCorr)))
            {
               Ticket = SendOrder(HedgeSymbol, OP_BUY, OrderLot, 0, slip, hMagic, MidnightBlue,TradeComment);

               if (Ticket > 0 && Debug)
                  Print("Hedge Buy");
            }

            if (OrderLot > 0 && ((CbB > 0 && hPosCorr) || (CbS > 0 && !hPosCorr)))
            {
               Ticket = SendOrder(HedgeSymbol, OP_SELL, OrderLot, 0, slip, hMagic, Maroon,TradeComment);

               if (Ticket > 0 && Debug)
                  Print("Hedge Sell");
            }

            if (Ticket > 0)
            {
               hLvlStart = hLevel + 1;

               return (0);
            }
         }

         int Index = 0;

         if (!FirstRun && hMaxLossPips > 0)
         {
            if (ChB > 0)
            {
               if (hFixedSL)
               {
                  if (SLh == 0)
                     SLh = hBid - hMaxLossPips;
               }
               else
               {
                  if (SLh == 0 || (SLh < BEh && SLh < hBid - hMaxLossPips))
                     SLh = hBid - hMaxLossPips;
                  else if (StopTrailAtBE && hBid - hMaxLossPips >= BEh)
                     SLh = BEh;
                  else if (SLh >= BEh && !StopTrailAtBE)
                  {
                     if (!ReduceTrailStop)
                        SLh = MathMax(SLh, hBid - hMaxLossPips);
                     else
                        SLh = MathMax(SLh, hBid - MathMax(StopLevel, hMaxLossPips * (1 - (hBid - hMaxLossPips - BEh) / (hMaxLossPips * 2))));
                  }
               }

               if (hBid <= SLh)
                  Index = ExitTrades(H, DarkViolet, "Hedge StopLoss");
            }
            else if (ChS > 0)
            {
               if (hFixedSL)
               {
                  if (SLh == 0)
                     SLh = hAsk + hMaxLossPips;
               }
               else
               {
                  if (SLh == 0 || (SLh > BEh && SLh > hAsk + hMaxLossPips))
                     SLh = hAsk + hMaxLossPips;
                  else if (StopTrailAtBE && hAsk + hMaxLossPips <= BEh)
                     SLh = BEh;
                  else if (SLh <= BEh && !StopTrailAtBE)
                  {
                     if (!ReduceTrailStop)
                        SLh = MathMin(SLh, hAsk + hMaxLossPips);
                     else
                        SLh = MathMin(SLh, hAsk + MathMax(StopLevel, hMaxLossPips * (1 - (BEh - hAsk - hMaxLossPips) / (hMaxLossPips * 2))));
                  }
               }

               if (hAsk >= SLh)
                  Index = ExitTrades(H, DarkViolet, "Hedge StopLoss");
            }
         }

         if (Index == 0 && hTakeProfit > 0)
         {
            if (ChB > 0 && hBid > OPhO + hTakeProfit)
               Index = ExitTrades(T, DarkViolet, "Hedge TakeProfit reached", ThO);

            if (ChS > 0 && hAsk < OPhO - hTakeProfit)
               Index = ExitTrades(T, DarkViolet, "Hedge TakeProfit reached", ThO);
         }

         if (Index > 0)
         {
            PhC = FindClosedPL(H);

            if (Index == ChT)
            {
               if (HedgeTypeDD)
                  hActive = 2;
               else
                  hActive = 0;
            }
            return (0);
         }
      }
   }

   //+-----------------------------------------------------------------+
   //| Check DD% and send Email                                        |
   //+-----------------------------------------------------------------+
   if ((UseEmail || PlaySounds) && !Testing)
   {
      if (EmailCount < 2 && Email[EmailCount] > 0 && DrawDownPC > Email[EmailCount])
      {
         GetLastError();

         if (UseEmail)
         {
            SendMail("Drawdown warning", "Drawdown has exceeded " + DTS(Email[EmailCount] * 100, 2) + "% on " + Symbol() + " " + sTF);
            Error = GetLastError();

            if (Error > 0)
               Print("Email DD: ", DTS(DrawDownPC * 100, 2), " Error: ", Error, " (", ErrorDescription(Error), ")");
            else if (Debug)
               Print("DrawDown Email sent for ", Symbol(), " ", sTF, "  DD: ", DTS(DrawDownPC * 100, 2));
            EmailSent = TimeCurrent();
            EmailCount++;
         }

         if (PlaySounds)
            PlaySound(AlertSound);
      }
      else if (EmailCount > 0 && EmailCount < 3 && DrawDownPC < Email[EmailCount] && TimeCurrent() > EmailSent + EmailHours * 3600)
         EmailCount--;
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
          ObjSetTxt("ZeusZone", "Overbought Zone", 10, displayColorProfit);
        }else if(overSold){
         ObjSetTxt("ZeusZone", "Oversold Zone", 10, displayColorLoss);
        }else{
          ObjSetTxt("ZeusZone", "", 10, displayColorLoss);
        }
         

         if (UseHolidayShutdown)
         {
            ObjSetTxt("ZeusVHolF", TimeToStr(HolFirst, TIME_DATE));
            ObjSetTxt("ZeusVHolT", TimeToStr(HolLast, TIME_DATE));
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
         //buot buot
         if(!ConsiderLotStep){ ObjSetTxt("ZeusVSLot", DTS(Lot * LotMult, 2));}
         else{
            }ObjSetTxt("ZeusVSLot", DTS(TrueLotSize , 2));
            
        

         if (ProfitPot >= 0)
            DrawLabel("ZeusVPPot", ProfitPot, 190);
         else
         {
            ObjSetTxt("ZeusVPPot", DTS(ProfitPot, 2), 0, displayColorLoss);
            dDigits = Digit[ArrayBsearch(Digit, (int)-ProfitPot, WHOLE_ARRAY, 0, MODE_ASCEND), 1];
            ObjSet("ZeusVPPot", 186 - dDigits * 7);
         }

         if (UseEarlyExit && EEpc < 1)
         {
            if (ObjectFind("ZeusSEEPr") == -1)
               CreateLabel("ZeusSEEPr", "/", 0, 0, 220, 12);

            if (ObjectFind("ZeusVEEPr") == -1)
               CreateLabel("ZeusVEEPr", "", 0, 0, 229, 12);

            ObjSetTxt("ZeusVEEPr", DTS(PbTarget * PipValue * MathAbs(LbB - LbS), 2));
         }
         else
         {
            ObjDel("ZeusSEEPr");
            ObjDel("ZeusVEEPr");
         }

         if (SLb > 0)
            DrawLabel("ZeusVPrSL", SLb, 190, Digits);
         else if (bSL > 0)
            DrawLabel("ZeusVPrSL", bSL, 190, Digits);
         else if (bTS > 0)
            DrawLabel("ZeusVPrSL", bTS, 190, Digits);
         else
            DrawLabel("ZeusVPrSL", 0, 190, 2);

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
            Colour = Orange;
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
         ObjSetTxt("ZeusVMove", DTS(Moves, 0));
         DrawLabel("ZeusVMxDD", MaxDD, 107);
         DrawLabel("ZeusVDDPC", MaxDDPer, 229);

         if (Trend == 0)
         {
             
    
           
            ObjSetTxt("ZeusLTrnd", "UP Trend", 10, displayColorProfit);

            if (ObjectFind("ZeusATrnd") == -1)
               CreateLabel("ZeusATrnd", "", 0, 0, 160, 22, displayColorProfit, "Wingdings");

            ObjectSetText("ZeusATrnd", "é", displayFontSize + 9, "Wingdings", displayColorProfit);
            ObjSet("ZeusATrnd", 160);
            ObjectSet("ZeusATrnd", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 22);

            if (StringLen(ATrend) > 0)
            {
               if (ObjectFind("ZeusAATrn") == -1)
                  CreateLabel("ZeusAATrn", "", 0, 0, 200, 22, displayColorProfit, "Wingdings");

               if (ATrend == "D")
               {
                  ObjectSetText("ZeusAATrn", "ê", displayFontSize + 9, "Wingdings", displayColorLoss);
                  ObjectSet("ZeusAATrn", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 22 + 5);
               }
               else if (ATrend == "R")
               {
                  ObjSetTxt("ZeusAATrn", "R", 10, Orange);
                  ObjectSet("ZeusAATrn", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 22);
               }
            }
            else
               ObjDel("ZeusAATrn");
         }
         else if (Trend == 1)
         {
             
         
           
            ObjSetTxt("ZeusLTrnd", "DOWN Trend", 10, displayColorLoss);

            if (ObjectFind("ZeusATrnd") == -1)
               CreateLabel("ZeusATrnd", "", 0, 0, 210, 22, displayColorLoss, "WingDings");

            ObjectSetText("ZeusATrnd", "ê", displayFontSize + 9, "Wingdings", displayColorLoss);
            ObjSet("ZeusATrnd", 210);
            ObjectSet("ZeusATrnd", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 22 + 5);

            if (StringLen(ATrend) > 0)
            {
               if (ObjectFind("ZeusAATrn") == -1)
                  CreateLabel("ZeusAATrn", "", 0, 0, 250, 22, displayColorProfit, "Wingdings");

               if (ATrend == "U")
               {
                  ObjectSetText("ZeusAATrn", "é", displayFontSize + 9, "Wingdings", displayColorProfit);
                  ObjectSet("ZeusAATrn", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 22);
               }
               else if (ATrend == "R")
               {
                  ObjSetTxt("ZeusAATrn", "R", 10, Orange);
                  ObjectSet("ZeusAATrn", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 22);
               }
            }
            else
               ObjDel("ZeusAATrn");
         }
         else if (Trend == 2)
         {
            ObjSetTxt("ZeusLTrnd", "Trend is Ranging", 10, Orange);
            ObjDel("ZeusATrnd");

            if (StringLen(ATrend) > 0)
            {
               if (ObjectFind("ZeusAATrn") == -1)
                  CreateLabel("ZeusAATrn", "", 0, 0, 220, 22, displayColorProfit, "Wingdings");

               if (ATrend == "U")
               {
                  ObjectSetText("ZeusAATrn", "é", displayFontSize + 9, "Wingdings", displayColorProfit);
                  ObjectSet("ZeusAATrn", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 22);
               }
               else if (ATrend == "D")
               {
                  ObjectSetText("ZeusAATrn", "ê", displayFontSize + 8, "Wingdings", displayColorLoss);
                  ObjectSet("ZeusAATrn", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 22 + 5);
               }
            }
            else
               ObjDel("ZeusAATrn");
         }

         if (PaC != 0)
         {
            if (ObjectFind("ZeusLClPL") == -1)
               CreateLabel("ZeusLClPL", "Closed P/L", 0, 0, 312, 11);

            if (ObjectFind("ZeusVClPL") == -1)
               CreateLabel("ZeusVClPL", "", 0, 0, 327, 12);

            if (PaC >= 0)
               DrawLabel("ZeusVClPL", PaC, 327, 2, displayColorProfit);
            else
            {
               ObjSetTxt("ZeusVClPL", DTS(PaC, 2), 0, displayColorLoss);
               dDigits = Digit[ArrayBsearch(Digit, (int)-PaC, WHOLE_ARRAY, 0, MODE_ASCEND), 1];
               ObjSet("ZeusVClPL", 323 - dDigits * 7);
            }
         }
         else
         {
            ObjDel("ZeusLClPL");
            ObjDel("ZeusVClPL");
         }
         

         if (hActive == 1)
         {
            if (ObjectFind("ZeusLHdge") == -1)
               CreateLabel("ZeusLHdge", "Hedge", 0, 0, 323, 13);

            if (ObjectFind("ZeusVhPro") == -1)
               CreateLabel("ZeusVhPro", "", 0, 0, 312, 14);

            if (Ph >= 0)
               DrawLabel("ZeusVhPro", Ph, 312, 2, displayColorProfit);
            else
            {
               ObjSetTxt("ZeusVhPro", DTS(Ph, 2), 0, displayColorLoss);
               dDigits = Digit[ArrayBsearch(Digit, (int)-Ph, WHOLE_ARRAY, 0, MODE_ASCEND), 1];
               ObjSet("ZeusVhPro", 308 - dDigits * 7);
            }

            if (ObjectFind("ZeusVhPMx") == -1)
               CreateLabel("ZeusVhPMx", "", 0, 0, 312, 15);

            if (PhMax >= 0)
               DrawLabel("ZeusVhPMx", PhMax, 312, 2, displayColorProfit);
            else
            {
               ObjSetTxt("ZeusVhPMx", DTS(PhMax, 2), 0, displayColorLoss);
               dDigits = Digit[ArrayBsearch(Digit, (int)-PhMax, WHOLE_ARRAY, 0, MODE_ASCEND), 1];
               ObjSet("ZeusVhPMx", 308 - dDigits * 7);
            }

            if (ObjectFind("ZeusShPro") == -1)
               CreateLabel("ZeusShPro", "/", 0, 0, 342, 15);

            if (ObjectFind("ZeusVhPMn") == -1)
               CreateLabel("ZeusVhPMn", "", 0, 0, 351, 15, displayColorLoss);

            if (PhMin < 0)
               ObjSet("ZeusVhPMn", 347);
            else
               ObjSet("ZeusVhPMn", 351);

            ObjSetTxt("ZeusVhPMn", DTS(PhMin, 2), 0, displayColorLoss);

            if (ObjectFind("ZeusLhTyp") == -1)
               CreateLabel("ZeusLhTyp", "", 0, 0, 292, 16);

            if (ObjectFind("ZeusVhOpn") == -1)
               CreateLabel("ZeusVhOpn", "", 0, 0, 329, 16);

            if (ChB > 0)
            {
               ObjSetTxt("ZeusLhTyp", "Buy:");
               DrawLabel("ZeusVhOpn", ChB, 329, 0);
            }
            else if (ChS > 0)
            {
               ObjSetTxt("ZeusLhTyp", "Sell:");
               DrawLabel("ZeusVhOpn", ChS, 329, 0);
            }
            else
            {
               ObjSetTxt("ZeusLhTyp", "");
               ObjSetTxt("ZeusVhOpn", DTS(0, 0));
               ObjSet("ZeusVhOpn", 329);
            }

            if (ObjectFind("ZeusShOpn") == -1)
               CreateLabel("ZeusShOpn", "/", 0, 0, 342, 16);

            if (ObjectFind("ZeusVhLot") == -1)
               CreateLabel("ZeusVhLot", "", 0, 0, 351, 16);

            ObjSetTxt("ZeusVhLot", DTS(LhT, 2));
         }
         else
         {
            ObjDel("ZeusLHdge");
            ObjDel("ZeusVhPro");
            ObjDel("ZeusVhPMx");
            ObjDel("ZeusShPro");
            ObjDel("ZeusVhPMn");
            ObjDel("ZeusLhTyp");
            ObjDel("ZeusVhOpn");
            ObjDel("ZeusShOpn");
            ObjDel("ZeusVhLot");
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


         if (TPa > 0)
         {
            if (ObjectFind("ZeusLTPLn") == -1)
               CreateLine("ZeusLTPLn", Gold, 1, 0);
            
            ObjectMove("ZeusLTPLn", 0, Time[1], TPa);
            
            if(useBasketExit){
            
            if (ObjectFind("ZeusExit") == -1)
                CreateLine("ZeusExit", Gold, 1,2);    
         
                
            double TPa_1,displayProfitPot;
            displayProfitPot=ProfitPot*(ProfitPotClosePercent/100);
                    
                    
            if (CbB>0)
                  TPa_1=BEa+(displayProfitPot/(PipVal2*MathAbs(nLots)));
            else if (CbS>0)
                  TPa_1=BEa-(displayProfitPot/(PipVal2*MathAbs(nLots)));

            ObjectMove("ZeusExit", 0, Time[1], TPa_1); 
            }
            else
              {
                ObjDel("ZeusExit");
              }
             
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

         if (bSL > 0)
         {
            if (ObjectFind("ZeusLSLbT") == -1)
               CreateLine("ZeusLSLbT", Red, 1, 3);

            ObjectMove("ZeusLSLbT", 0, Time[1], bSL);
         }
         else
            ObjDel("ZeusLSLbT");

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

         if (TPbMP > 0)
         {
            if (ObjectFind("ZeusLMPLn") == -1)
               CreateLine("ZeusLMPLn", Gold, 1, 4);

            ObjectMove("ZeusLMPLn", 0, Time[1], TPbMP);
         }
         else
            ObjDel("ZeusLMPLn");

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

      if (CCIEntry && displayCCI)
      {
         if (cci_01 > 0 && cci_11 > 0)
            ObjectSetText("ZeusVCm05", "Ù", displayFontSize + 6, "Wingdings", displayColorProfit);
         else if (cci_01 < 0 && cci_11 < 0)
            ObjectSetText("ZeusVCm05", "Ú", displayFontSize + 6, "Wingdings", displayColorLoss);
         else
            ObjectSetText("ZeusVCm05", "Ø", displayFontSize + 6, "Wingdings", Orange);

         if (cci_02 > 0 && cci_12 > 0)
            ObjectSetText("ZeusVCm15", "Ù", displayFontSize + 6, "Wingdings", displayColorProfit);
         else if (cci_02 < 0 && cci_12 < 0)
            ObjectSetText("ZeusVCm15", "Ú", displayFontSize + 6, "Wingdings", displayColorLoss);
         else
            ObjectSetText("ZeusVCm15", "Ø", displayFontSize + 6, "Wingdings", Orange);

         if (cci_03 > 0 && cci_13 > 0)
            ObjectSetText("ZeusVCm30", "Ù", displayFontSize + 6, "Wingdings", displayColorProfit);
         else if (cci_03 < 0 && cci_13 < 0)
            ObjectSetText("ZeusVCm30", "Ú", displayFontSize + 6, "Wingdings", displayColorLoss);
         else
            ObjectSetText("ZeusVCm30", "Ø", displayFontSize + 6, "Wingdings", Orange);

         if (cci_04 > 0 && cci_14 > 0)
            ObjectSetText("ZeusVCm60", "Ù", displayFontSize + 6, "Wingdings", displayColorProfit);
         else if (cci_04 < 0 && cci_14 < 0)
            ObjectSetText("ZeusVCm60", "Ú", displayFontSize + 6, "Wingdings", displayColorLoss);
         else
            ObjectSetText("ZeusVCm60", "Ø", displayFontSize + 6, "Wingdings", Orange);
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
   
   // Auto Enable Profit Maximiser A
    if(MaximizeProfitTemp==false && isStopLossUsed==false && AllowTrading==true){
    if(TotalOrders>=TrailingAtLevel){
         useBasketExit = false;
         MaximizeProfit = true;
         string ObjText;
         color ObjClr;
         ObjText = "Profit Trailing is ON (Auto)";
         ObjClr = displayColorProfit;
         CreateLabel("ZeusLPrMx", ObjText, 0, 0, 0, 11, ObjClr);
      }
      else {
             useBasketExit = true;
             MaximizeProfit = false;
             string ObjText;
             color ObjClr;
             ObjText = "Profit Trailing is OFF";
             ObjClr = displayColorLoss;
             CreateLabel("ZeusLPrMx", ObjText, 0, 0, 0, 11, ObjClr);
      }
    }
   
   //+-----------------------------------------------------------------+
   //| Buot2x Addition -  Exit Basket                          |
   //+-----------------------------------------------------------------+
   if (useBasketExit){
    //Calculate percentage from profit potential you can live with
    double ProfitToLive = (ProfitPotClosePercent/100) * ProfitPot; 
    //Close or Exit all trades from this symbol if under use basket exit
    if (ProfitToLive<Pb){
           ExitTrades(A, displayColorProfit, "Profit Reached "+ProfitPotClosePercent+"%" );
     }
    }
    
   //+-----------------------------------------------------------------+
	//| CUT LOSS WHEN SHUTDOWN                                           |
	//+-----------------------------------------------------------------+
	
    if(ShutDown)
    {
             if(CutlossOnShutdownProfit<Pb)
             {
                ExitTrades(A, displayColorProfit, "Shutdown and reached > "+CutlossOnShutdownProfit);
             }
    }
   
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
         if (PlaySounds)
            PlaySound(AlertSound);

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

      Print("Closed ", Closed, " position", s, " because ", Reason);

      if (PlaySounds)
         PlaySound(AlertSound);
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
      CreateLabel("ZeusVMNum","Contact: kbartiquel@yahoo.com", 8 - displayFontSize, 5, 5, 1, displayColorFGnd, "Tahoma");

      if (displayLogo)
      {
         CreateLabel("ZeusLCopy", "Zeus © " + DTS(Year(), 0) + ", Kimbert Bartiquel", 10 - displayFontSize, 3, 5, 3, Silver, "Arial");
      }
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
    
      CreateLabel("ZeusLine1", "=========================", 0, 0, 0, 3);
      CreateLabel("ZeusLEPPC", "Equity Protection:", 0, 0, 0,4);
      dDigits=Digit[ArrayBsearch(Digit, (int)MaxDDPercent, WHOLE_ARRAY, 0, MODE_ASCEND), 1];
      CreateLabel("ZeusVEPPC", DTS(MaxDDPercent, 2), 0, 0, 167 - 7 * dDigits, 4);
      CreateLabel("ZeusPEPPC", "%", 0, 0, 193, 4);
 
      CreateLabel("ZeusWebsite", "www.zeus-ea.com",1, 0, 0, 8,White);
      CreateLabel("ZeusLAPPC", "Account Portion:", 0, 0, 0, 5);
      dDigits=Digit[ArrayBsearch(Digit, (int)(PortionPC * 100), WHOLE_ARRAY, 0, MODE_ASCEND), 1];
      CreateLabel("ZeusVAPPC", DTS(PortionPC * 100, 2), 0, 0, 167 - 7 * dDigits, 5);
      CreateLabel("ZeusPAPPC", "%", 0, 0, 193, 5);
      CreateLabel("ZeusLPBal", "Portion Balance:", 0, 0, 0, 6);
      CreateLabel("ZeusVPBal", "", 0, 0, 167, 6);
      
      if (UseMM)
      {
         ObjText = "Money Management is ON";
         ObjClr = displayColorProfit;
      }
      else
      {
       //  ObjText = "Money Management is OFF";
         ObjClr = displayColorLoss;
      }

      CreateLabel("ZeusLMMOO", ObjText, 0, 0, 0, 7, ObjClr);

      if (UsePowerOutSL)
      {
         ObjText = "Power-Off StopLoss is ON";
         ObjClr = displayColorProfit;
      }
      else
      {
         ObjText = "Power-Off StopLoss is OFF";
         ObjClr = displayColorLoss;
      }

   //  CreateLabel("ZeusLPOSL", ObjText, 0, 0, 0, 8, ObjClr);
    // CreateLabel("ZeusLDrDn", "Draw Down %:", 0, 0, 228, 8);
    //  CreateLabel("ZeusVDrDn", "", 0, 0, 25, 8);
      
     
      if (UseHedge)
      {
         if (HedgeTypeDD)
         {
            CreateLabel("ZeusLhDDn", "Hedge", 0, 0, 0, 8);
            CreateLabel("ZeusShDDn", "/", 0, 0, 152, 8);
            CreateLabel("ZeusVhDDm", "", 0, 0, 157, 8);
         }
         else
         {
            CreateLabel("ZeusLhLvl", "Hedge Level:", 0, 0, 0, 8);
            CreateLabel("ZeusVhLvl", "", 0, 0, 90, 8);
            CreateLabel("ZeusShLvl", "/", 0, 0, 100, 8);
            CreateLabel("ZeusVhLvT", "", 0, 0, 106, 8);
         }
      }else {
          ObjClr = displayColorLoss;
         // CreateLabel("ZeusLhDDn", "Hedging is OFF", 0, 0, 0, 8,ObjClr);
      }

      CreateLabel("ZeusLine2", "=========================", 0, 0, 0, 9);
      CreateLabel("ZeusLSLot", "Starting Lot Size:", 0, 0, 0, 10);
      CreateLabel("ZeusVSLot", "", 0, 0, 130, 10);

      if (MaximizeProfit)
      {
         ObjText = "Profit Trailing is ON";
         ObjClr = displayColorProfit;
      }
      else
      {
         ObjText = "Profit Trailing is OFF";
         ObjClr = displayColorLoss;
      }

      CreateLabel("ZeusLPrMx", ObjText, 0, 0, 0, 11, ObjClr);
      CreateLabel("ZeusLBask", "Basket", 0, 0, 200, 11);
      CreateLabel("ZeusLPPot", "Profit Potential:", 0, 0, 30, 12);
      CreateLabel("ZeusVPPot", "", 0, 0, 190, 12);
      CreateLabel("ZeusLPrSL", "Profit Trailing Stop:", 0, 0, 30, 13);
      CreateLabel("ZeusVPrSL", "", 0, 0, 190, 13);
      CreateLabel("ZeusLPnPL", "Portion P/L / Pips:", 0, 0, 30, 14);
      CreateLabel("ZeusVPnPL", "", 0, 0, 190, 14);
      CreateLabel("ZeusSPnPL", "/", 0, 0, 220, 14);
      CreateLabel("ZeusVPPip", "", 0, 0, 229, 14);
      CreateLabel("ZeusLPLMM", "Profit/Loss Max/Min:", 0, 0, 30, 15);
      CreateLabel("ZeusVPLMx", "", 0, 0, 190, 15);
      CreateLabel("ZeusSPLMM", "/", 0, 0, 220, 15);
      CreateLabel("ZeusVPLMn", "", 0, 0, 225, 15);
      CreateLabel("ZeusLOpen", "Open Trades / Lots:", 0, 0, 30, 16);
      CreateLabel("ZeusLType", "", 0, 0, 170, 16);
      CreateLabel("ZeusVOpen", "", 0, 0, 207, 16);
      CreateLabel("ZeusSOpen", "/", 0, 0, 220, 16);
      CreateLabel("ZeusVLots", "", 0, 0, 229, 16);
      CreateLabel("ZeusLMvTP", "Move TP by:", 0, 0, 0, 17);
      CreateLabel("ZeusVMvTP", DTS(MoveTP / Pip, 0), 0, 0, 100, 17);
      CreateLabel("ZeusLMves", "# Moves:", 0, 0, 150, 17);
      CreateLabel("ZeusVMove", "", 0, 0, 229, 17);
      CreateLabel("ZeusSMves", "/", 0, 0, 242, 17);
      CreateLabel("ZeusVMves", DTS(TotalMoves, 0), 0, 0, 249, 17);
      CreateLabel("ZeusLMxDD", "Max DD:", 0, 0, 0, 18);
      CreateLabel("ZeusVMxDD", "", 0, 0, 107, 18);
      CreateLabel("ZeusLDDPC", "Max DD %:", 0, 0, 150, 18);
      CreateLabel("ZeusVDDPC", "", 0, 0, 229, 18);
      CreateLabel("ZeusPDDPC", "%", 0, 0, 257, 18);
      //buot2x
     // CreateLabel("ZeusContact", "Contact: Kbartiquel@yahoo.com",1, 0, 0, 20,White);

     // if (ForceMarketCond < 3)
        // CreateLabel("ZeusLFMCn", "Market trend is forced", 0, 0, 0, 19);

      CreateLabel("ZeusLTrnd", "", 0, 0, 0, 22);
      CreateLabel("ZeusZone", "", 0, 0, 0, 24);
      CreateLabel("ZeusMAMax", "", 0, 0, 0, 26);

      if (CCIEntry > 0 && displayCCI)
      {
         CreateLabel("ZeusLCCIi", "CCI", 2, 1, 12, 1);
         CreateLabel("ZeusLCm05", "m5", 2, 1, 25, 2.2);
         CreateLabel("ZeusVCm05", "Ø", 6, 1, 0, 2, Orange, "Wingdings");
         CreateLabel("ZeusLCm15", "m15", 2, 1, 25, 3.4);
         CreateLabel("ZeusVCm15", "Ø", 6, 1, 0, 3.2, Orange, "Wingdings");
         CreateLabel("ZeusLCm30", "m30", 2, 1, 25, 4.6);
         CreateLabel("ZeusVCm30", "Ø", 6, 1, 0, 4.4, Orange, "Wingdings");
         CreateLabel("ZeusLCm60", "h1", 2, 1, 25, 5.8);
         CreateLabel("ZeusVCm60", "Ø", 6, 1, 0, 5.6, Orange, "Wingdings");
      }

      if (UseHolidayShutdown)
      {
        // CreateLabel("ZeusLHols", "Next Holiday Period", 0, 0, 240, 2);
       //  CreateLabel("ZeusLHolD", "From: (yyyy.mm.dd) To:", 0, 0, 232, 3);
         //CreateLabel("ZeusVHolF", "", 0, 0, 232, 4);
         //CreateLabel("ZeusVHolT", "", 0, 0, 300, 4);
      }
   }

}

//get total orders on current symbol with magic
int getTotalOrders(int buy, int sell){
  buy =0; sell=0;
  int total=MathMax(buy,sell);
  Print("Total orders:"+ total);
return total;   
}

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

/*
Close gaining trades based on firstLevelTPPoints
*/

//Scalp first level
void ScalpFirstLevel()
{
  for(int i=OrdersTotal()-1;i>=0;i--)
   {
    OrderSelect(i, SELECT_BY_POS);
    double ProfitInPoitns = OrderProfit()/OrderLots();
    bool result = false;
    double tpfirstlevel = ProfitCloseFirstLevel*10;
    if(FirstLevelLot==OrderLots() && Symbol() == OrderSymbol()) 
                { 
        if ( OrderType() == OP_BUY )  
        //BUY 
        {
        
          if(ProfitInPoitns>tpfirstlevel)
             { 
                  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 1, Red );
                  if(result)Print("Closed ", 1, " position", " because Profit Reached "+ProfitCloseFirstLevel+" Pips TP");
             }      
            
       }
       if ( OrderType() == OP_SELL )
       //SELL
       {
          if(ProfitInPoitns>tpfirstlevel )
                  { //means gaining
                    result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 1, Red );
                    if(result)Print("Closed ", 1, " position", " because Profit Reached "+ProfitCloseFirstLevel+" Pips TP");
                 }
       }
          
      }
   }
     return;   
     
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
	ObjectDelete(object_name);
	if(TotalOrders==0)
	  {
	   	ObjectCreate(object_name, OBJ_HLINE, 0, Time[0], price, Time[Bars - 1], price);
	      ObjectSet(object_name, OBJPROP_COLOR, clrBurlyWood);
	      ObjectSet(object_name, OBJPROP_STYLE, STYLE_DOT);
	  }

}


void DrawRectangle_Resize(){
    int y_dist;//,x_dist,x_size,y_size,x_1;
    
    int x_dist=ObjectGetInteger(ChartID(),"ZeusPDDPC",OBJPROP_XDISTANCE);
    //x_size=ObjectGetInteger(ChartID(),"AiskoLabeline1",OBJPROP_WIDTH);
    y_dist=ObjectGetInteger(ChartID(),"ZeusPDDPC",OBJPROP_YDISTANCE);

    //x_1=x_dist+x_size;
    //Print("x_dist",x_dist," x_size",x_size," y_dist",y_dist," y_size",y_size);
    ObjectSetInteger(ChartID(),"ZeusRect",OBJPROP_XSIZE,x_dist+30);//270
    ObjectSetInteger(ChartID(),"ZeusRect",OBJPROP_YSIZE,y_dist);//410
}
void DrawRectangle() {
    ChartSetInteger(ChartID(),CHART_FOREGROUND,0,false);
    
    ObjectCreate(ChartID(),"ZeusRect",OBJ_RECTANGLE_LABEL,0,0,0) ;

    ObjectSetInteger(ChartID(),"ZeusRect",OBJPROP_BGCOLOR,clrBurlyWood);
    ObjectSetInteger(ChartID(),"ZeusRect",OBJPROP_BORDER_TYPE,DRAW_FILLING);

    int x_dist=ObjectGetInteger(ChartID(),"ZeusLTime",OBJPROP_XDISTANCE);
    ObjectSetInteger(ChartID(),"ZeusRect",OBJPROP_XDISTANCE,0);
    ObjectSetInteger(ChartID(),"ZeusRect",OBJPROP_YDISTANCE,30);
    ObjectSetInteger(ChartID(),"ZeusRect",OBJPROP_BACK,false);
    
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
   if(StringFind( CharArrayToString(result),AccountName(),0)>=0){toReturn = true;}
   
return toReturn;
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

//+---------------------------------------------------------------------+
//|                                Changelog
//| 8.6.209 KIM - Optimized for readable Inputs & Removed Unnecessary   |
//|             - Added Scalping Feature or Auto Closing Feature        |
//|             - Added Auto Enabling Profit Maximiser After Scalping   |
//|               is disabled on specific levels                        |
//|             - Removed Telegram Feature because of Samok2x           |
//+---------------------------------------------------------------------+