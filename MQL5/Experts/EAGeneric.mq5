//+------------------------------------------------------------------+
//|                                                    EAGeneric.mq5 |
//|                                                   Thiago Tavares |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Thiago Tavares"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Utils.mqh>
#include <LadinoHiLo.mqh>
#include <LogPanel.mqh>
//#include <Telegram.mqh>

//+ INPUTS MACD
input bool        In_Usar_MACD = true; // MACD - Usar o MACD para tomada de decisão
input int         Inp_Signal_MACD_PeriodSlow  = 24; // MACD - Média Lenta
input int         Inp_Signal_MACD_PeriodFast  = 12; // MACD - Sinal
input int         Inp_Signal_MACD_PeriodSignal= 9;  // MACD - Média Rápida

//+ INPUTS HILO
input bool        In_Usar_HILO = true; // HiLo - Usar o HiLo para tomada de decisão
input int         Inp_HILO_Period  = 4; // HiLo - Período do HiLo

input double      OP_TakeProfit  = 10.0; // Operação - Take Profit
input double      OP_StopLoss    = 3.0;  // Operação - Stop Loss


//Variables:
static int BARS;
LogPanel _logs;
//CCustomBot bot;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   EventSetTimer(60); 

   ChartSetInteger(0, CHART_SHOW_GRID, false);
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
   ChartSetInteger(0, CHART_AUTOSCROLL, true);
   
   _logs.inicializar();

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
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