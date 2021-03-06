//+------------------------------------------------------------------+
//|                                             Zeus Thunderbolt.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
#include <stdlib.mqh>
#include <stderror.mqh>
#include <WinUser32.mqh>
//TODO: dili mugana ang close BE
#define A 1 //All (Basket + Hedge)
#define B 2 //Basket
#define H 3 //Hedge
#define T 4 //Ticket
#define P 5 //Pending

enum TypeNS
  {
   INVEST=0,   // Investing.com
   DAILYFX=1,  // Dailyfx.com
  };
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
 color    displayColor        = clrWhite;
// default color of profit display characters
 color    displayColorProfit  = Green;
// default color of loss display characters
 color    displayColorLoss    = OrangeRed;
// default color of ForeGround Text display characters
 color    displayColorFGnd    = White;

 // In pips, used in conjunction with logic to offset first trade entry
 extern string   labelStrat=                                                    "----------Entry Settings ------------";//-
 bool     SR_Entry            =true;                                            //Enable S/R Strategy
 extern double   EntryOffset           = 0;                                     //Offset (in pips)
 extern int      BAR_TO_START_SCAN_FROM =2;                                     //S/R Bar Start Scan
 extern int      EANumber = 1;                                                  //Magic Number


extern string   labelTrailing=                                                  "---------- Trade Management ------------";//-
extern double Risk= 2;                                                          //Risk Per Trade
extern double SL=15;                                                            //SL
extern double TP = 20 ;                                                         //TP
extern double    TrailingStop             = 1.5;                                //Trailing Stop
extern double    TrailingStart            = 1.5;                                //Trailing Start
extern double    TrailingStep             = 0.1;                                //Trailing Step

extern string TradeComment = "Zeus Thunderbolt";                                //Trade Comment

datetime lastbar_timeopen;

double       RiskLoss;
double       Lots;
double       lotDecimal;
double       ASK,BID,OldHigh,OldLow,TotalOrders;

bool         SELL,BUY;
double       maxDD=0;
double       maxDDPC=0;
double       ProfitTotal=0;
double       LOT;
//+---------------------------------+
//|   Trailing and Exits var                  |
//+---------------------------------+
double       TrallB = 0;
double       TrallS = 0;
int          slippage=30;
int          slip = 5;
string       SLBuyName = "BUY_SL";   
string       SLSellName = "SELL_SL"; 
bool         UseFIFO             = false; 
int          ca;

double       buyprice;
bool         result;
double       pips;
int          err;
int          Error;
int          Magic;
double       MADistance = 10;
int          Trend;
int OnInit()
  {
 //  Magic = GenerateMagicNumber();
   Magic=1;
   double ticksize=MarketInfo(Symbol(),MODE_TICKSIZE);
   
   MADistance  = ND(MADistance * Point, Digits);
   
   if(ticksize==0.00001 || Point==0.01){  
      pips=ticksize*10;
   }
   else{ 
      pips=ticksize;
   }
    
   SL = SL*10;
   TP = TP*10;
   
   TrailingStop = TrailingStop*10;
   TrailingStart = TrailingStart*10;
   TrailingStep = TrailingStep*10;

   
   labelCreateDashboard();
   lotDecimal = getLotDecimal();
   DrawRectangle();
   getProfit();
   
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
	deleteLines();
   LabelDelete();

  }
 void LabelDelete()
{
   for (int Object = ObjectsTotal(); Object >= 0; Object--)
   {
      if (StringSubstr(ObjectName(Object), 0, 4) == "Zeus")
         ObjectDelete(ObjectName(Object));
   }
}

void OnTick()
  {  
  
   ASK = ND(MarketInfo(Symbol(), MODE_ASK), (int)MarketInfo(Symbol(), MODE_DIGITS));
   BID = ND(MarketInfo(Symbol(), MODE_BID), (int)MarketInfo(Symbol(), MODE_DIGITS));

  
   //+-----------------------------------------------------------------+
   //| Calculation of Trend Direction                                  |
   //+-----------------------------------------------------------------+

   double ima_0 = iMA(Symbol(), 0, 20, 0, MODE_EMA, PRICE_CLOSE, 0);
   
   if (BID > ima_0 && BID> ima_0 + MADistance)
      Trend = 0;
   else if (ASK < ima_0 && ASK < ima_0 - MADistance)
      Trend = 1;
   else
      Trend = 2;    
   
     ManageTrade();
     maxDrawdown();
     getProfit();
     ObjSetTxt("ZeusBalanceV", DTS(AccountBalance(),2), 0, CLR_NONE);
     ObjSetTxt("ZeusLotV", getLot(), 0, CLR_NONE);
     Trailing();
     
     
     
     
   return;
  }
//+-----------------------------------------------------------------+
//| TRAILING STOP VIRTUAL                                           |
//+-----------------------------------------------------------------+
void Trailing(){

    double OOP,SL;
   int b=0,s=0,tip,TicketB=0,TicketS=0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol())
           {
            tip = OrderType();
            OOP = NormalizeDouble(OrderOpenPrice(),Digits);
            if(tip==OP_BUY)
              {
               b++;
               TicketB=OrderTicket();
               if(TrailingStop>0)
                 {
                  SL=NormalizeDouble(Bid-TrailingStop*Point,Digits);
                  if(SL>=OOP+TrailingStart*Point && (TrallB==0 || TrallB+TrailingStep*Point<SL)) TrallB=SL;
                 }
              }
            if(tip==OP_SELL)
              {
               s++;
               TicketS=OrderTicket();
               if(TrailingStop>0)
                 {
                  SL=NormalizeDouble(Ask+TrailingStop*Point,Digits);
                  if(SL<=OOP-TrailingStart*Point && (TrallS==0 || TrallS-TrailingStep*Point>SL)) TrallS=SL;
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
                  ExitTrades(A,displayColorProfit, "of Trailing stop" ); 
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

     
   }

   return (Closed);
}

//+-----------------------------------------------------------------+
//| MANAGE TRADE HERE                                               |
//+-----------------------------------------------------------------+
void deleteLines(){
    ObjectDelete("Z_Resistance");
    ObjectDelete("Z_Support");
}
void BreakoutStrategy(){
   TotalOrders = OrdersTotal();
   //+----------------------------------------------------------------+
   //| Breakout Order Entry                                           |
   //+----------------------------------------------------------------+
   if (SR_Entry && TotalOrders ==0 && Trend!=2)
   {
      double bHi = ObjectGet("Z_Resistance", OBJPROP_PRICE1)+EntryOffset*_Point;
      double bLo = ObjectGet("Z_Support", OBJPROP_PRICE1)-EntryOffset*_Point;
      
    
      if (Bid > bHi && bHi >0.01)
      {  
         ObjectDelete("Z_Resistance");
         BUY = true; SELL = false;
      }
     
      else if (Ask<bLo && bLo >0.01)
      {
         ObjectDelete("Z_Support");
         BUY = false; SELL = true;
       
      }
      else{
         BUY =false; SELL = false;
      }  
      
      //take orders
     double AskLo_dif = Ask-bLo; //difference from LOW and Ask price
     double BidHi_dif = bHi-Bid; //diference from HIG and Bid price
      if(BUY){
         int ticket;
         ticket = SendOrder(Symbol(),OP_BUY,getLot(),0,0,Ask-SL*_Point,Ask+TP*_Point,Magic,clrBisque,TradeComment);

           if(ticket>=0){
               LOT = getLot();
           }
           
           
           //int ticket2 = OrderSend(Symbol(), OP_SELLSTOP, 
           //            getLot()*2,                              //Lot
           //            Bid-(SL/2)*_Point,                       //price
           //            0,                                       //SLip
           //            Ask+TP*_Point,                           //SL
           //            Ask-SL*_Point,                           //TP
           //            TradeComment,                            //Comment   
           //            12920192,                                //Magic
           //            0, clrBisque);                           //COLOR

      }
     if(SELL) {
       int ticket;
       ticket = SendOrder(Symbol(),OP_SELL,getLot(),0,0,Bid+SL*_Point,Bid-TP*_Point,Magic,clrBisque,TradeComment);
           if(ticket>=0){
               LOT = getLot();
           }        
      }
  }
}
void closeOrders(){
  int total = OrdersTotal();
  for(int i=total-1;i>=0;i--)
  {
    OrderSelect(i, SELECT_BY_POS);
    int type   = OrderType();

    bool result = false;
    
    switch(type)
    {
      //Close opened long positions
      case OP_BUY       : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
                          break;
      
      //Close opened short positions
      case OP_SELL      : result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
                          
    }
    
    if(result == false)
    {
      Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
    }  
  }
}

void ManageTrade()
  {  


  //draw support and resistance
   drawResistance(getUpperFractalBar(Period(), BAR_TO_START_SCAN_FROM));
   drawSupport(getLowerFractalBar(Period(), BAR_TO_START_SCAN_FROM));
	
 //run breakout trades
  BreakoutStrategy();
  return;
}



//+----------------------------------------------------------------+
//| Trailing stops                                               |
//+----------------------------------------------------------------+

void ModifyStopLoss(double ldStopLoss) {
  bool fm;
  fm=OrderModify(OrderTicket(),OrderOpenPrice(),ldStopLoss,OrderTakeProfit(),0,CLR_NONE);
}

void maxDrawdown(){
   double Profit = 0;
      for (int i=0; i<OrdersTotal(); i++) {
       if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if((OrderMagicNumber()==Magic )
             && OrderSymbol() == Symbol() && (OrderType() == OP_BUY || OrderType() == OP_SELL )){
            Profit = Profit+ OrderProfit();
         }
       }
     }
   if(Profit<maxDD){
          maxDD=Profit;
          maxDDPC = ND((maxDD/AccountBalance())*100,2);
          ObjSetTxt("ZeusDDV",  DTS(maxDD,2), 0, CLR_NONE);
          ObjSetTxt("ZeusDDPcV",  DTS(maxDDPC,2)+" %", 0, CLR_NONE);
     }
   
}
void getProfit(){
   double Profit = 0;
      for (int i=0; i<OrdersHistoryTotal(); i++) {
       if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
         if((OrderMagicNumber()==Magic )
          && OrderSymbol() == Symbol() && (OrderType() == OP_BUY || OrderType() == OP_SELL ) ){
            double p = (OrderProfit() + OrderSwap() + OrderCommission());
            Profit = Profit+p;
         }
       }
     }
    ProfitTotal = ND(Profit,2);
    ObjSetTxt("ZeusProfitV", DTS(ProfitTotal,2), 0, CLR_NONE);
}
double getLot(){
   double l;
   double tick=MarketInfo(Symbol(),MODE_TICKVALUE);
   double minlot=MarketInfo(Symbol(),MODE_MINLOT);
   double maxlot=MarketInfo(Symbol(),MODE_MAXLOT);
   double spread=MarketInfo(Symbol(),MODE_SPREAD);
   RiskLoss=(Risk/100)*AccountBalance();
   l=RiskLoss/((SL)*tick);
   Print(l);
   l=NormalizeDouble(l,2);
   Print(l);

   return  0.10;
}
int getLotDecimal(){
   int LotDecimal=3;
   double LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   double MinLotSize = MarketInfo(Symbol(), MODE_MINLOT);
   double MinLot = MathMin(MinLotSize, LotStep);
   if (MinLot < 0.01)
      LotDecimal = 3;
   else if (MinLot < 0.1)
      LotDecimal = 2;
   else if (MinLot < 1)
      LotDecimal = 1;
   else
      LotDecimal = 0;  
  
   return LotDecimal;
 }
bool isNewBar()
{
    static datetime bartime=0; 
    datetime currbar_time=iTime(Symbol(),Period(),0);
    if(bartime!=currbar_time)
    {
       bartime=currbar_time;
       lastbar_timeopen=bartime;
       return (true);
     }
    return (false);
}
string DTS(double Value, int Precision)
{
   return (DoubleToStr(Value, Precision));
}
double ND(double Value, int Precision)
{
   return (NormalizeDouble(Value, Precision));
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

void drawResistance2(int bar_index) {
	if(bar_index > 0){
	double HIGH = iHigh(Symbol(), PERIOD_H1, bar_index);
	   drawTrendLine("Z_Resistance2", HIGH);
	}
}

void drawSupport2(int bar_index) {
	if(bar_index > 0) {
	double LOW =iLow(Symbol(), PERIOD_H1, bar_index);
	drawTrendLine("Z_Support2",LOW);
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

int SendOrder(string OSymbol, int OCmd, double OLot, double OPrice, int OSlip,double OSl, double OTp, int OMagic, color OColor = CLR_NONE, string comment = "")
{
   int Error;
   int Ticket = 0;
   int Tries = 0;
   int OType = (int)MathMod(OCmd, 2);
   double OrderPrice;

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
     
      
      Ticket = OrderSend(OSymbol, OCmd, OLot, OrderPrice, OSlip, OSl, OTp, comment, OMagic, 0, OColor);
    

      if (Ticket < 0)
      {
         Error = GetLastError();
         switch (Error)
         {
            case ERR_TRADE_DISABLED:
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


void ObjSetTxt(string Name, string Text, int FontSize = 0, color Colour = CLR_NONE, string Font = "")
{
   FontSize += displayFontSize;

   if (Font == "")
      Font = displayFont;

   if (Colour == CLR_NONE)
      Colour = displayColor;

   ObjectSetText(Name, Text, FontSize, Font, Colour);
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
void labelCreateDashboard(){
      CreateLabel("ZeusName", "Zeus Thunderbolt", 5, 0, 0, 1,White);
      CreateLabel("ZeusLine1", "=========================", 0, 0, 0, 3);
      CreateLabel("ZeusBalance", "Account Balance", 0, 0, 0,4);
      CreateLabel("ZeusBalanceV", AccountBalance(), 0, 0, 140, 4);
      
      CreateLabel("ZeusRisk", "Risk Per Trade", 0, 0, 0,5);
      CreateLabel("ZeusRiskV", Risk +"%", 0, 0, 140, 5);
      
      CreateLabel("ZeusLot", "Lot Size", 0, 0, 0,6);
      CreateLabel("ZeusLotV", getLot(), 0, 0, 140, 6);
      
      CreateLabel("ZeusDD", "Max DD:", 0, 0, 0,7);
      CreateLabel("ZeusDDV", "0", 0, 0, 140, 7);
       CreateLabel("ZeusDDPc", "Max DD %:", 0, 0, 0,8);
       CreateLabel("ZeusDDPcV", "0%", 0, 0, 140, 8);

       CreateLabel("ZeusProfit", "Profit:",0, 0, 0,9);
       CreateLabel("ZeusProfitV", "0",0, 0, 140,9);
     
       DrawRectangle();DrawRectangle_Resize();
}
void DrawRectangle_Resize(){
    int y_dist;//,x_dist,x_size,y_size,x_1;
    
    int x_dist=ObjectGetInteger(ChartID(),"ZeusProfitV",OBJPROP_XDISTANCE);
    //x_size=ObjectGetInteger(ChartID(),"AiskoLabeline1",OBJPROP_WIDTH);
    y_dist=ObjectGetInteger(ChartID(),"ZeusProfitV",OBJPROP_YDISTANCE);
  //  int x_dist2=ObjectGetInteger(ChartID(),"ZeusBalanceV",OBJPROP_XDISTANCE);

    //x_1=x_dist+x_size;
    //Print("x_dist",x_dist," x_size",x_size," y_dist",y_dist," y_size",y_size);
    ObjectSetInteger(ChartID(),"ZeusRect",OBJPROP_XSIZE,270);//270
    ObjectSetInteger(ChartID(),"ZeusRect",OBJPROP_YSIZE,y_dist);//410
}
void DrawRectangle() {
    ChartSetInteger(ChartID(),CHART_FOREGROUND,0,true);
    
    ObjectCreate(ChartID(),"ZeusRect",OBJ_RECTANGLE_LABEL,0,0,0) ;
    ObjectSetInteger(ChartID(),"ZeusRect",OBJPROP_BGCOLOR,clrDarkSlateBlue);
    ObjectSetInteger(ChartID(),"ZeusRect",OBJPROP_BORDER_TYPE,DRAW_FILLING);

    int x_dist=ObjectGetInteger(ChartID(),"ZeusName",OBJPROP_XDISTANCE);
    ObjectSetInteger(ChartID(),"ZeusRect",OBJPROP_XDISTANCE,0);
    ObjectSetInteger(ChartID(),"ZeusRect",OBJPROP_YDISTANCE,30);
    ObjectSet("ZeusRect",OBJPROP_BACK,true);

}

void checkDemoOrLive(){   
   if(IsDemo()){
 
   }else{
      Print("This is just a demo version, under alpha testing.");
      MessageBox("Live account is not allowed on this robot. Robot still under alpha version with further forward testing. Thanks!","Robot Message",48);
      ExpertRemove();
   }  
}


  

  