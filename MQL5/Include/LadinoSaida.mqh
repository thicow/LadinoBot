//+------------------------------------------------------------------+
//|                                                    LadinoBot.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <LadinoCandlestick.mqh>
#include <LadinoSR.mqh>
#include <LadinoEntrada.mqh>

class LadinoSaida: public LadinoEntrada {
   private:
      int _MMT1Handle, _MMT2Handle, _MMT3Handle;
   public:
      TIPO_STOP tipoStopAtual();
      double pegarPosicaoStop(SINAL_POSICAO posicao);
      bool eTakeProfitT1(TIPO_OBJETIVO condicao);
      bool eTakeProfitT2(TIPO_OBJETIVO condicao);
      bool eTakeProfitT3(TIPO_OBJETIVO condicao);
      double pegarValorFibo(TIPO_OBJETIVO condicao, double preco);

      double pegarTakeProfitFibo(SINAL_POSICAO tendencia, ENUM_TEMPO_GRAFICO tempo, TIPO_OBJETIVO condicao, double preco);
      void adicionarTakeProfitFibo(SINAL_POSICAO tendencia, TIPO_OBJETIVO condicao, double preco, double posicao, double vol);
      void configurarTakeProfit(SINAL_POSICAO tendencia, double preco);
      double pegarProximoObjetivoVolume();
      void verificarObjetivoFixo();
      void executarBreakEven();
      void modificarStop();
      void executarObjetivo(SINAL_POSICAO tendencia);
      bool verificarSaida();
      void verificarCruzamentoMediaBB();
      void verificarSaidaBBRSI();
      double getMMT1(int pos);
      double getMMT2(int pos);
      double getMMT3(int pos);
      
};

TIPO_STOP LadinoSaida::tipoStopAtual() {
   if (operacaoAtual == SITUACAO_OBJETIVO1)
      return getObjetivoStop1();
   else if (operacaoAtual == SITUACAO_OBJETIVO2)
      return getObjetivoStop2();
   else if (operacaoAtual == SITUACAO_OBJETIVO3)
      return getObjetivoStop3();
   else
      return getStopInicial();
}

double LadinoSaida::pegarPosicaoStop(SINAL_POSICAO posicao) {
   //DADOS_SR dados[];
   double posicaoStop = 0;
   TIPO_STOP tipoStop = tipoStopAtual();
   switch (tipoStop) {
      case STOP_FIXO:
         if (posicao == COMPRADO)
            posicaoStop = _precoCompra - getStopFixo();
         else if (posicao == VENDIDO)
            posicaoStop = _precoVenda + getStopFixo();
         break;
      case STOP_T1_TOPO_FUNDO:
         if (posicao == COMPRADO)
            posicaoStop = t1SuporteAtual;
         else if (posicao == VENDIDO)
            posicaoStop = t1ResistenciaAtual;
         break;
      case STOP_T2_TOPO_FUNDO:
         if (posicao == COMPRADO)
            posicaoStop = t2SuporteAtual;
         else if (posicao == VENDIDO)
            posicaoStop = t2ResistenciaAtual;
         break;
      case STOP_T3_TOPO_FUNDO:
         if (posicao == COMPRADO)
            posicaoStop = t3SuporteAtual;
         else if (posicao == VENDIDO)
            posicaoStop = t3ResistenciaAtual;
         break;
      case STOP_T1_HILO:
         posicaoStop = t1hilo.posicaoAtual();
         break;
      case STOP_T2_HILO:
         posicaoStop = t2hilo.posicaoAtual();
         break;
      case STOP_T3_HILO:
         posicaoStop = t3hilo.posicaoAtual();
         break;
      case STOP_T1_VELA_ATENRIOR:
         if (posicao == COMPRADO)
            posicaoStop = t1VelaAnterior.minima;
         else if (posicao == VENDIDO)
            posicaoStop = t1VelaAnterior.maxima;
         break;
      case STOP_T2_VELA_ATENRIOR:
         if (posicao == COMPRADO)
            posicaoStop = t2VelaAnterior.minima;
         else if (posicao == VENDIDO)
            posicaoStop = t2VelaAnterior.maxima;
         break;
      case STOP_T3_VELA_ATENRIOR:
         if (posicao == COMPRADO)
            posicaoStop = t3VelaAnterior.minima;
         else if (posicao == VENDIDO)
            posicaoStop = t3VelaAnterior.maxima;
         break;
      case STOP_T1_VELA_ATUAL:
         if (posicao == COMPRADO)
            posicaoStop = t1VelaAtual.minima;
         else if (posicao == VENDIDO)
            posicaoStop = t1VelaAtual.maxima;
         break;
      case STOP_T2_VELA_ATUAL:
         if (posicao == COMPRADO)
            posicaoStop = t2VelaAtual.minima;
         else if (posicao == VENDIDO)
            posicaoStop = t2VelaAtual.maxima;
         break;
      case STOP_T3_VELA_ATUAL:
         if (posicao == COMPRADO)
            posicaoStop = t3VelaAtual.minima;
         else if (posicao == VENDIDO)
            posicaoStop = t3VelaAtual.maxima;
         break;
   }
   if (posicao == COMPRADO) {
      if (operacaoAtual == SITUACAO_ABERTA || operacaoAtual == SITUACAO_BREAK_EVEN)
         posicaoStop -= getStopExtra();
      else
         posicaoStop -= getAumentoStopExtra();
   }
   else if (posicao == VENDIDO) {
      if (operacaoAtual == SITUACAO_ABERTA || operacaoAtual == SITUACAO_BREAK_EVEN)
         posicaoStop += getStopExtra();
      else
         posicaoStop += getAumentoStopExtra();
   }
   return posicaoStop;
}


bool LadinoSaida::eTakeProfitT1(TIPO_OBJETIVO condicao) {
   return (
      condicao == OBJETIVO_T1_FIBO_0382 ||
      condicao == OBJETIVO_T1_FIBO_0618 ||
      condicao == OBJETIVO_T1_FIBO_1000 ||
      condicao == OBJETIVO_T1_FIBO_1382 ||
      condicao == OBJETIVO_T1_FIBO_1618 ||
      condicao == OBJETIVO_T1_FIBO_2000 ||
      condicao == OBJETIVO_T1_FIBO_2618
   );
}

bool LadinoSaida::eTakeProfitT2(TIPO_OBJETIVO condicao) {
   return (
      condicao == OBJETIVO_T2_FIBO_0382 ||
      condicao == OBJETIVO_T2_FIBO_0618 ||
      condicao == OBJETIVO_T2_FIBO_1000 ||
      condicao == OBJETIVO_T2_FIBO_1382 ||
      condicao == OBJETIVO_T2_FIBO_1618 ||
      condicao == OBJETIVO_T2_FIBO_2000 ||
      condicao == OBJETIVO_T2_FIBO_2618
   );
}

bool LadinoSaida::eTakeProfitT3(TIPO_OBJETIVO condicao) {
   return (
      condicao == OBJETIVO_T3_FIBO_0382 ||
      condicao == OBJETIVO_T3_FIBO_0618 ||
      condicao == OBJETIVO_T3_FIBO_1000 ||
      condicao == OBJETIVO_T3_FIBO_1382 ||
      condicao == OBJETIVO_T3_FIBO_1618 ||
      condicao == OBJETIVO_T3_FIBO_2000 ||
      condicao == OBJETIVO_T3_FIBO_2618
   );
}


double LadinoSaida::pegarValorFibo(TIPO_OBJETIVO condicao, double preco) {
   double retorno = 0;
   switch (condicao) {
      case OBJETIVO_T1_FIBO_0382:
      case OBJETIVO_T2_FIBO_0382:
      case OBJETIVO_T3_FIBO_0382:
         retorno = preco * 0.382;
         break;
      case OBJETIVO_T1_FIBO_0618:
      case OBJETIVO_T2_FIBO_0618:
      case OBJETIVO_T3_FIBO_0618:
         retorno = preco * 0.618;
         break;
      case OBJETIVO_T1_FIBO_1000:
      case OBJETIVO_T2_FIBO_1000:
      case OBJETIVO_T3_FIBO_1000:
         retorno = preco;
         break;
      case OBJETIVO_T1_FIBO_1382:
      case OBJETIVO_T2_FIBO_1382:
      case OBJETIVO_T3_FIBO_1382:
         retorno = preco * 1.382;
         break;
      case OBJETIVO_T1_FIBO_1618:
      case OBJETIVO_T2_FIBO_1618:
      case OBJETIVO_T3_FIBO_1618:
         retorno = preco * 1.618;
         break;
      case OBJETIVO_T1_FIBO_2000:
      case OBJETIVO_T2_FIBO_2000:
      case OBJETIVO_T3_FIBO_2000:
         retorno = preco * 2;
         break;
      case OBJETIVO_T1_FIBO_2618:
      case OBJETIVO_T2_FIBO_2618:
      case OBJETIVO_T3_FIBO_2618:
         retorno = preco * 2.618;
         break;
      default:
         retorno = 0;
         break;
   }
   return retorno;
}

double LadinoSaida::pegarTakeProfitFibo(SINAL_POSICAO tendencia, ENUM_TEMPO_GRAFICO tempo, TIPO_OBJETIVO condicao, double preco) {
   double suporteAtual = 0;
   double resistenciaAtual = 0;
   DADOS_SR dados[];
   if (tempo == T1) {
      t1sr.atualizar(dados);
      suporteAtual = t1sr.suporteAtual(dados);
      resistenciaAtual = t1sr.resistenciaAtual(dados);
   }
   else if (tempo == T2) {
      t2sr.atualizar(dados);
      suporteAtual = t2sr.suporteAtual(dados);
      resistenciaAtual = t2sr.resistenciaAtual(dados);
   }
   else if (tempo == T3) {
      t3sr.atualizar(dados);
      suporteAtual = t3sr.suporteAtual(dados);
      resistenciaAtual = t3sr.resistenciaAtual(dados);
   }
   
   double variacao = MathAbs(resistenciaAtual - suporteAtual);
   variacao = pegarValorFibo(condicao, variacao);
   if (variacao > 0) {
      if (tendencia == COMPRADO)
         return suporteAtual + variacao;
      else if (tendencia == VENDIDO)
         return resistenciaAtual - variacao;
   }
   return 0;
}

void LadinoSaida::adicionarTakeProfitFibo(SINAL_POSICAO tendencia, TIPO_OBJETIVO condicao, double preco, double posicao, double vol) {

   double tp = 0;
   if (condicao == OBJETIVO_FIXO) {
      if (posicao > 0) {
         if (tendencia == COMPRADO)
            tp = preco + posicao;
         else if (tendencia == VENDIDO)
            tp = preco - posicao;
      }
   }
   else if (eTakeProfitT1(condicao)) {
      tp = pegarTakeProfitFibo(tendencia, T1, condicao, preco);      
   }
   else if (eTakeProfitT2(condicao)) {
      tp = pegarTakeProfitFibo(tendencia, T2, condicao, preco);      
   }
   else if (eTakeProfitT3(condicao)) {
      tp = pegarTakeProfitFibo(tendencia, T3, condicao, preco);
   }
   if (tp != 0) {
      if (vol > 0) {
         if (tendencia == COMPRADO)
            this.comprarTP(vol, tp);
         else if (tendencia == VENDIDO)
            this.venderTP(vol, tp);
      }
      else if (vol < 0) {
         if (tendencia == COMPRADO)
            this.venderTP(MathAbs(vol), tp);
         else if (tendencia == VENDIDO)
            this.comprarTP(MathAbs(vol), tp);
      }
   }
}

void LadinoSaida::configurarTakeProfit(SINAL_POSICAO tendencia, double preco) {
   adicionarTakeProfitFibo(tendencia, getObjetivoCondicao1(), preco, getObjetivoPosicao1(), getObjetivoVolume1());
   adicionarTakeProfitFibo(tendencia, getObjetivoCondicao2(), preco, getObjetivoPosicao2(), getObjetivoVolume2());
   adicionarTakeProfitFibo(tendencia, getObjetivoCondicao3(), preco, getObjetivoPosicao3(), getObjetivoVolume3());
}


double LadinoSaida::pegarProximoObjetivoVolume() {
   if (operacaoAtual == SITUACAO_ABERTA || operacaoAtual == SITUACAO_BREAK_EVEN)
      return getObjetivoVolume1();
   else if (operacaoAtual == SITUACAO_OBJETIVO1)
      return getObjetivoVolume2();
   else if (operacaoAtual == SITUACAO_OBJETIVO2)
      return getObjetivoVolume3();
   else 
      return 0;
}


void LadinoSaida::verificarObjetivoFixo() {
   double preco = this.getPrecoEntrada();
   if (this.getPosicaoAtual() == COMPRADO) {
      if (operacaoAtual == SITUACAO_ABERTA || operacaoAtual == SITUACAO_BREAK_EVEN)
         preco += getObjetivoPosicao1();
      else if (operacaoAtual == SITUACAO_OBJETIVO1) 
         preco += getObjetivoPosicao2();
      else if (operacaoAtual == SITUACAO_OBJETIVO2)
         preco += getObjetivoPosicao3();
      if (_precoCompra >= preco)
         alterarOperacaoAtual();
   }
   else if (this.getPosicaoAtual() == VENDIDO) {
      if (operacaoAtual == SITUACAO_ABERTA || operacaoAtual == SITUACAO_BREAK_EVEN)
         preco -= getObjetivoPosicao1();
      else if (operacaoAtual == SITUACAO_OBJETIVO1) 
         preco -= getObjetivoPosicao2();
      else if (operacaoAtual == SITUACAO_OBJETIVO2)
         preco -= getObjetivoPosicao3();
      if (_precoVenda <= preco)
         alterarOperacaoAtual();
   }
}



void LadinoSaida::verificarCruzamentoMediaBB() {
   double preco = _precoCompra;
   if (this.getPosicaoAtual() == COMPRADO) {
      double t1MM = pegarMMT1();
     double mediaBB = t1BB.meio();
     double mediaT1 = pegarMMT1();
     double topoBB = t1BB.topo();
      if (operacaoAtual == SITUACAO_ABERTA || operacaoAtual == SITUACAO_BREAK_EVEN){
        /*if(t1NovaVela){
            double media2 = getMMT1(2);
            double media1 = getMMT1(1);
            if(t1VelaAnterior.fechamento < media2 
            && t1VelaAtual.fechamento < media1){
               alterarOperacaoAtual();
               this.finalizarPosicao();            
            }
        } else*/ if(getSaidaPaulaComprado() == COMPRADO_SAIDA_PAULA_TOPO && (preco + 0.6) > topoBB){
            alterarOperacaoAtual();
            
            //this.finalizarPosicao();
            

        } else if(getSaidaPaulaComprado() == COMPRADO_SAIDA_PAULA_MEDIA && preco > mediaBB){
            alterarOperacaoAtual();
            this.finalizarPosicao();
            //this.parcialPosicao(preco, -1);
            /* this.venderTP(1, preco);
             this.setStopFixo(t1VelaAnterior.minima);*/
        }
      }else if(t1NovaVela && operacaoAtual == SITUACAO_OBJETIVO1){
         if(preco > topoBB){
            this.finalizarPosicao();
             //this.venderTP(1, preco);
         }
      }
      /*else
      if(t1VelaAnterior.abertura > getMMT1(1) && t1VelaAnterior.fechamento > getMMT1(1)){
      }else{
         this.finalizarPosicao();
      }*/
      /*if(operacaoAtual == SITUACAO_OBJETIVO1){
         if(t1VelaAnterior.fechamento > t1hilo.posicaoAtual() || verificarTendenciaMACD(3) == ALTA
         || t1MACD.signal(3) < t1MACD.signal(2)
         || t1MACD.main(3) < t1MACD.main(2)
         ){
            //tem q manter isso ai
         }else{
          this.finalizarPosicao();
         }
      }*/
   }
   else if (this.getPosicaoAtual() == VENDIDO) {
      double t1MM = pegarMMT1();
       double mediaBB = t1BB.meio();
        double fundoBB = t1BB.fundo();
      if (operacaoAtual == SITUACAO_ABERTA || operacaoAtual == SITUACAO_BREAK_EVEN){
       
        /*if(t1NovaVela){
           double macd4 = t1MACD.main(4);
           double macd3 = t1MACD.main(3);
           double macd2 = t1MACD.main(2);
           double macd1 = t1MACD.main(1);
           if(macd4<macd3 && macd3 < macd2 && macd2< macd1){
            escreverLog("VENDIDO e MACD Subindo.. Sair x");
               alterarOperacaoAtual();
               this.finalizarPosicao();
           }
        }
*/

        if(getSaidaPaulaVendido() == VENDIDO_SAIDA_PAULA_FUNDO && (preco - 0.6) < fundoBB ){
         alterarOperacaoAtual();
         //this.finalizarPosicao();
        }
        else if(getSaidaPaulaVendido() == VENDIDO_SAIDA_PAULA_MEDIA && preco < mediaBB){
         alterarOperacaoAtual();
         this.finalizarPosicao();
         /*this.comprarTP(1, preco);
         this.setStopFixo(t1VelaAnterior.maxima);*/
        }
      }else if(t1NovaVela && operacaoAtual == SITUACAO_OBJETIVO1){
         if(preco < fundoBB){
            //this.finalizarPosicao();
            this.comprarTP(1, preco);
         }
      }
      //if (_precoVenda <= preco)
        // alterarOperacaoAtual();
   }
}


void LadinoSaida::verificarSaidaBBRSI() {
   double preco = _precoCompra;
   if (this.getPosicaoAtual() == COMPRADO) {
      double t1MM = pegarMMT1();
     double mediaBB = t1BB.meio();
     double mediaT1 = pegarMMT1();
     double topoBB = t1BB.topo();
      if (operacaoAtual == SITUACAO_ABERTA || operacaoAtual == SITUACAO_BREAK_EVEN){
        if(getSaidaPaulaComprado() == COMPRADO_SAIDA_PAULA_TOPO && (preco + 0.6) > topoBB){
            alterarOperacaoAtual();
        } else if(getSaidaPaulaComprado() == COMPRADO_SAIDA_PAULA_MEDIA && preco > mediaBB){
         if(t1RSI.main(1) > topoBB){
            alterarOperacaoAtual();
            this.finalizarPosicao();
         }
           
        }
      }
   }
   else if (this.getPosicaoAtual() == VENDIDO) {
      double t1MM = pegarMMT1();
       double mediaBB = t1BB.meio();
        double fundoBB = t1BB.fundo();
      if (operacaoAtual == SITUACAO_ABERTA || operacaoAtual == SITUACAO_BREAK_EVEN){
       

        if(getSaidaPaulaVendido() == VENDIDO_SAIDA_PAULA_FUNDO && (preco - 0.6) < fundoBB ){
         alterarOperacaoAtual();
         //this.finalizarPosicao();
        }
        else if(getSaidaPaulaVendido() == VENDIDO_SAIDA_PAULA_MEDIA && preco < mediaBB){
         if(t1RSI.main(1) < fundoBB){
            alterarOperacaoAtual();
            this.finalizarPosicao();
         }
        }
      }
      //if (_precoVenda <= preco)
        // alterarOperacaoAtual();
   }
}

void LadinoSaida::executarBreakEven() {
   if (this.getPosicaoAtual() == COMPRADO) {
      //if (operacaoAtual == SITUACAO_ABERTA && BreakEven > 0 && precoCompra >= (_trade.getPrecoEntrada() + BreakEven)) {
      if (getBreakEven() > 0 && _precoCompra >= (this.getPrecoEntrada() + getBreakEven())) {
         if (operacaoAtual == SITUACAO_ABERTA)
            operacaoAtual = SITUACAO_BREAK_EVEN;
         double sl = this.getPrecoEntrada() + getBreakEvenValor();
         if (sl > this.getStopLoss()) {
            if (this.modificarPosicao(sl, 0))
               escreverLog("Moving Stop to BreakEven in " + IntegerToString((int)this.getStopLoss()));
            else
               escreverLog("Could not change Stop! Current StopLoss=" + IntegerToString((int)this.getStopLoss()));
         }
      }
   }
   else if (this.getPosicaoAtual() == VENDIDO) {
      //if (operacaoAtual == SITUACAO_ABERTA && BreakEven > 0 && precoVenda <= (_trade.getPrecoEntrada() - BreakEven)) {      
      if (getBreakEven() > 0 && _precoVenda <= (this.getPrecoEntrada() - getBreakEven())) {      
         if (operacaoAtual == SITUACAO_ABERTA)
            operacaoAtual = SITUACAO_BREAK_EVEN;
         double sl = this.getPrecoEntrada() - getBreakEvenValor();
         if (sl < this.getStopLoss()) {
            if (this.modificarPosicao(sl, 0))
               escreverLog("Moving Stop to BreakEven in " + IntegerToString((int)this.getStopLoss()));
            else
               escreverLog("Could not change Stop! Current StopLoss=" + IntegerToString((int)this.getStopLoss()));
         }
      }
   }
}

void LadinoSaida::modificarStop() {
   double tickMinimo = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   if (this.getPosicaoAtual() == COMPRADO) {
      double sl = pegarPosicaoStop(COMPRADO);
      sl = sl - MathMod(sl, tickMinimo);
      if (sl > this.getStopLoss() && sl < _precoCompra) {
         if (this.modificarPosicao(sl, 0))
            escreverLog("STOP changed to " + IntegerToString((int)this.getStopLoss()));
         else
            escreverLog("Could not change Stop! Current StopLoss=" + IntegerToString((int)this.getStopLoss()));
      }
   }
   else if (this.getPosicaoAtual() == VENDIDO) {
      double sl = pegarPosicaoStop(VENDIDO);
      sl = sl - MathMod(sl, tickMinimo);
      if (sl < this.getStopLoss() && sl > _precoVenda) {
         if (this.modificarPosicao(sl, 0))
            escreverLog("STOP changed to " + IntegerToString((int)this.getStopLoss()));
         else
            escreverLog("Could not change Stop! Current StopLoss=" + IntegerToString((int)this.getStopLoss()));
      }
   }
}


bool LadinoSaida::verificarSaida() {
   
   atualizarPreco();
   
   carregarVelaT1();
   carregarVelaT2();
   carregarVelaT3();
   
   if(t1NovaVela)
      atualizarSR(_negociacaoAtual);
   if(t2NovaVela)
      _t2TendenciaHiLo = t2hilo.tendenciaAtual();
   if(t3NovaVela)
      _t3TendenciaHiLo = t3hilo.tendenciaAtual();
      
   executarBreakEven();
   
   if (t1NovaVela) {
      desenharLinhaTendencia();
      modificarStop();
   }

   TIPO_OBJETIVO objetivo = OBJETIVO_NENHUM;
   if (operacaoAtual == SITUACAO_ABERTA || operacaoAtual == SITUACAO_BREAK_EVEN)
      objetivo = getObjetivoCondicao1();
   else if (operacaoAtual == SITUACAO_OBJETIVO1)
      objetivo = getObjetivoCondicao2();
   else if (operacaoAtual == SITUACAO_OBJETIVO2)
      objetivo = getObjetivoCondicao3();
    
   if (objetivo == OBJETIVO_FIXO) {
      verificarObjetivoFixo();
   }  
   else if (objetivo == OBJETIVO_ROMPIMENTO_LT) {   
      verificarRompimentoLTB();
      verificarRompimentoLTA();
   }else if (objetivo == OBJETIVO_BB_CRUZA_MEDIA) {   
      //verificarCruzamentoMediaBB();
      verificarSaidaBBRSI();
   }
   
   /*if(t1NovaVela && this.getPosicaoAtual() == COMPRADO){
      if(t1VelaAnterior.maxima < t1BB.fundo(1)){
         qtFechamentoOpostoOperacao++;
      }
           
   }
   
   if(t1NovaVela && this.getPosicaoAtual() == VENDIDO){
      if(t1VelaAnterior.maxima > t1BB.topo(1)){
         qtFechamentoOpostoOperacao++;
      }
           
   }
   
   if(qtFechamentoOpostoOperacao > 1){
      this.finalizarPosicao();
   }*/
   
   double precoOperacao = this.precoOperacaoAtual();
   if (getGanhoMaximoPosicao() > 0 && precoOperacao > getGanhoMaximoPosicao())
      this.finalizarPosicao();
   
   //ObjectSetString(0, labelPosicaoAtual, OBJPROP_TEXT, StringFormat("%.2f", precoOperacao));
   //ObjectSetString(0, labelPosicaoGeral, OBJPROP_TEXT, StringFormat("%.2f", this.precoAtual()));
   atualizarPosicao(precoOperacao, this.precoAtual());
   return false;
}

void LadinoSaida::executarObjetivo(SINAL_POSICAO tendencia) {
   if (getObjetivoCondicao1() == OBJETIVO_ROMPIMENTO_LT) {   
      double volume = pegarProximoObjetivoVolume();
      if (volume > 0) {
         if (executarAumento(tendencia, volume))
            alterarOperacaoAtual();
      }
      else
         alterarOperacaoAtual();
   }
}



double LadinoSaida::getMMT1(int pos = 0) {
   double mm[1];
   if(CopyBuffer(_MMT1Handle,0,pos,1,mm) != 1) {
      Print("CopyBuffer from iMA failed, no data");
      return 0;
   }
   return mm[0];
}

double LadinoSaida::getMMT2(int pos = 0) {
   double mm[1];
   if(CopyBuffer(_MMT2Handle,0,pos,1,mm) != 1) {
      Print("CopyBuffer from iMA failed, no data");
      return 0;
   }
   return mm[0];
}

double LadinoSaida::getMMT3(int pos = 0) {
   double mm[1];
   if(CopyBuffer(_MMT3Handle,0,pos,1,mm) != 1) {
      Print("CopyBuffer from iMA failed, no data");
      return 0;
   }
   return mm[0];
}
