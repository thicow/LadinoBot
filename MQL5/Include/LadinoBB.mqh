//+------------------------------------------------------------------+
//|                                                     LadinoBB.mqh |
//|                                                   Rodrigo Landim |
//|                                        http://www.emagine.com.br |
//+------------------------------------------------------------------+
#property copyright "Rodrigo Landim"
#property link      "http://www.emagine.com.br"
#property version   "1.00"

class LadinoBB {
   private:
      int BBHandle;
   public:
      LadinoBB();
      ~LadinoBB();
      bool inicializar(ENUM_TIMEFRAMES periodo);
      double topo(int n = 0);
      double meio(int n = 0);
      double fundo(int n = 0);
};
//+------------------------------------------------------------------+
LadinoBB::LadinoBB() {
   BBHandle = 10;
}

LadinoBB::~LadinoBB() {
};
//+------------------------------------------------------------------+
bool LadinoBB::inicializar(ENUM_TIMEFRAMES periodo = PERIOD_CURRENT) {
   BBHandle = iBands(Symbol(), periodo, 20,0,2,PRICE_CLOSE);
   if(BBHandle == INVALID_HANDLE) {
      Print("Erro ao criar indicador Bollinger Bands.");
      return false;
   }
   ChartIndicatorAdd(ChartID(), 0, BBHandle); 
   return true;
}

double LadinoBB::topo(int n = 0) {
   double mm[1];
   if(CopyBuffer(BBHandle,1,n,1,mm) != 1) {
      Print("CopyBuffer from iMA failed, no data");
      return 0;
   }
   return NormalizeDouble(mm[0], 2) ;
}

double LadinoBB::meio(int n = 0) {
   double mm[1];
   if(CopyBuffer(BBHandle,0,n,1,mm) != 1) {
      Print("CopyBuffer from iMA failed, no data");
      return 0;
   }
   return NormalizeDouble(mm[0], 2) ;
}

double LadinoBB::fundo(int n = 0)  {
   double mm[1];
   if(CopyBuffer(BBHandle,2,n,1,mm) != 1) {
      Print("CopyBuffer from iMA failed, no data");
      return 0;
   }
   return NormalizeDouble(mm[0], 2) ;
}
