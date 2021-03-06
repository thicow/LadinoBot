//+------------------------------------------------------------------+
//|                                                 BandsBThiago.mq5 |
//|                                                   Thiago Tavares |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Thiago Tavares"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
CTrade    trade;
static int BARS;
void OnTick()
  {
//---
   string entry = "";
   double Ask=NormalizeDouble(SymbolInfoDouble(Symbol(),SYMBOL_ASK),_Digits);
   double Bid=NormalizeDouble(SymbolInfoDouble(Symbol(),SYMBOL_BID),_Digits);
   
   MqlRates PriceInfo[];
   ArraySetAsSeries(PriceInfo, true);
   
   int PriceData = CopyRates(Symbol(),Period(),0,3,PriceInfo);
   
   double UpperBandArray[];
   double LowerBandArray[];
   
   ArraySetAsSeries(UpperBandArray, true);
   ArraySetAsSeries(LowerBandArray, true);
   
   int BollingerBandsDefinetion = iBands(Symbol(), _Period, 20,2,2,PRICE_CLOSE);
   CopyBuffer(BollingerBandsDefinetion, 1,0,3,UpperBandArray);
   CopyBuffer(BollingerBandsDefinetion, 2,0,3,LowerBandArray);
   
   double myUpperBandValue=UpperBandArray[0];
   double myLowerBandValue=LowerBandArray[0];
   
   double myLastUpperBandValue=UpperBandArray[1];
   double myLastLowerBandValue=LowerBandArray[1];

   double myLastUpperBandValue2=UpperBandArray[2];
   double myLastLowerBandValue2=LowerBandArray[2];
   
   

   
   if(IsNewBar()){
      if(PriceInfo[1].close > myLastLowerBandValue && PriceInfo[2].close<myLastLowerBandValue2
         && PriceInfo[2].close < PriceInfo[2].open //candle de baixa
         && PriceInfo[1].close > PriceInfo[1].open //candle de alta
      ){
      //compra
         entry = "buy";
      }
      
      if(PriceInfo[1].close < myLastUpperBandValue && PriceInfo[2].close>myLastUpperBandValue2
         && PriceInfo[2].close > PriceInfo[2].open //candle de alta
         && PriceInfo[1].close < PriceInfo[1].open //candle de baixa
      ){
      //compra
         entry = "sell";
      }
      
      if(entry =="sell" && PositionsTotal() <1){
         double valPoint = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
         double stop = 0.0;
         double target = 0.0;
         stop = NormalizeDouble(PriceInfo[1].high, 2);
         if(_Symbol == "WDOF19"){
            target = NormalizeDouble((Bid - 4), 2);
         } else if(_Symbol == "WINZ18"){
            target = NormalizeDouble((Bid - 50), 2);
         } else {
            target = NormalizeDouble(Bid - ((PriceInfo[1].low - Bid)*2),2);
         }
         trade.Sell(1,_Symbol, Bid, stop, target,NULL);
         PlaySound("\\Files\\Sounds\\LASER.wav");
         
      }
    /*  Alert("We already have a Sell position!!!"); */
      if(entry =="buy" && PositionsTotal() <1){
         double valPoint = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);

         double stop = 0.0;
         double target = 0.0;
         stop = NormalizeDouble(PriceInfo[1].low, 2);
         if(_Symbol == "WDOF19"){
            target = NormalizeDouble((Ask + 4), 2);
         } else if(_Symbol == "WINZ18"){
            target = NormalizeDouble((Ask + 50), 2);
         } else {
            target = NormalizeDouble(Ask + ((Ask - PriceInfo[1].low)*2),2);
         }

         trade.Buy(1,_Symbol, Ask, stop, target,NULL);

         PlaySound("\\Files\\Sounds\\LASER.wav");
      }
      Comment("Entry Signal: ", entry);
   
   }
   
   
   
  }
//+------------------------------------------------------------------+



bool IsNewBar()
   {
      if(BARS!=Bars(_Symbol,_Period))
        {
            BARS=Bars(_Symbol,_Period);
            return(true);
        }
      return(false);
   }