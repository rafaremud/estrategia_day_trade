//+--------------------------------------------------------+//
//                                                          //
// ALGORITMO PROJETADO PARA OPERAR - WDO se "tick1" = 0.001 //
//                                   WIN se "tick1" = 5     //
//                                                          //
//+--------------------------------------------------------+//
#property copyright "TRUE LIFE"
#property link "https://www.youtube.com/channel/UCWXAaWwCHnf7SLEAzOReoCQ"
#property version "1.00"


#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
CTrade trade;
CSymbolInfo simbol;
enum e_sn
  {
   nao = 0, // Não
   sim = 1 // Sim
  };
enum e_av
  {
   porc = 0, //Porcentagem
   pont = 1 //Pontuação
  };
enum e_sup
  {
   pri = 0, //PRIMEIRA
   seg = 1 //SEGUNDA
  };
  
  
  
e_sn painel = nao;
input group "CONFIGURAÇÕES"
ulong MagicNumber = 1234;
//NÚMERO MÁGICO DO ROBÔ
ulong DesvioOrderm = 100;
ENUM_ORDER_TYPE_FILLING ProcessoOrdem = ORDER_FILLING_RETURN;
input int Pmedia = 20;
//PERÍODO DA MÉDIA MÓVEL EXPONENCIAL
ENUM_MA_METHOD Mmedia = MODE_EMA; //TIPO DA MÉDIA MÓVEL

// "AMPLITUDE 1"
double AmplMin = 1;                          //Amplitude Mínima
double Ampmax1 = 30;                         //Amplitude Máxima
double lt1amp1 = 1;                          //Lote 1ª Entrada
double lt2amp1 = 0;                          //Lote 2ª Entrada
double lt3amp1 = 0;                          //Lote 3ª Entrada
double lt4amp1 = 0;                          //Lote 4ª Entrada
// "AMPLITUDE 2"
double Ampmin2 = 70;                         //Amplitude Mínima
double Ampmax2 = 100;                        //Amplitude Máxima
double lt1amp2 = 1;                          //Lote 1ª Entrada
double lt2amp2 = 0;                          //Lote 2ª Entrada
double lt3amp2 = 0;                          //Lote 3ª Entrada
double lt4amp2 = 0;                          //Lote 4ª Entrada
// "AMPLITUDE 3"
double Ampmin3 = 100;                        //Amplitude Mínima
double Ampmax3 = 200;                        //Amplitude Máxima
double lt1amp3 = 1;                          //Lote 1ª Entrada
double lt2amp3 = 0;                          //Lote 2ª Entrada
double lt3amp3 = 0;                          //Lote 3ª Entrada
double lt4amp3 = 0;                          //Lote 4ª Entrada
// "AMPLITUDE 4"
double Ampmin4 = 30;                         //Amplitude Mínima
double Ampmax4 = 6000000;                    //Amplitude Máxima
double lt1amp4 = 1;                          //Lote 1ª Entrada
double lt2amp4 = 0;                          //Lote 2ª Entrada
double lt3amp4 = 0;                          //Lote 3ª Entrada
double lt4amp4 = 0;                          //Lote 4ª Entrada
double Lote1;                                //Lote 1ª Entrada
double Lote2;                                //Lote 2ª Entrada
double Lote3;                                //Lote 3ª Entrada
double Lote4;                                //Lote 4ª Entrada
double RpT = 1;                              //Reais por Tick do ativo
double tickmedia = 1;                        //Ticks da média para operar
double tick1 = 0.001;                        //Generalização de Ativos
double tick2 = 0.25;                         //Segunda entrada, baseado na primeira
double tick3 = 0.5;                          //Terceira entrada, baseado na primeira
double tick4 = 0.75;                         //Quarta entrada, baseado na primeira
input double alvo1 = 1;                      //RETORNO
double alvo2 = 0.25;                         //Alvo de segunda
double alvo3 = -1;                           //Alvo de terceira TICK
double alvo4 = -1;                           //Alvo de quarta TICK
input double stop = 1.0;                     //RISCO
input int barras1 = 20;                      //QTD. DE CANDLESTICKS ACIMA OU ABAIXO DA MÉDIA MÓVEL
bool e1c = false;
bool e1v = false;


MqlTick ultimoTick;
MqlRates rates[];
MqlRates Dia[];
MqlDateTime horaAtual;
bool PosicaoAberta;
bool OrdemPendente;
bool operolac = true;
bool operolav = true;
//Normalizar preços com digitos
double PC;
double SL1;
double TP1;
double TP2;
double TP3;
double TP4;
double RE1;
double RE2;
double RE3;
double TP;
double SL;
double pcreque;
double PAberto;
bool BE1 = false;
bool BE2 = false;
bool BE3 = false;
//horario: Abertura e Fechamento
//horario: Abertura e Fechamento
input group "HORÁRIO DE INÍCIO DAS OPERAÇÕES"
input int HorOperar = 9;                        //HORA
input int MinOperar = 0;                        //MINUTOS
int SecOperar = 0;
input group "HORÁRIO DE TÉRMINO DAS OPERAÇÕES"
input int HorParar = 17;                        //HORA
input int MinParar = 25;                        //MINUTOS
double ArrayMA[];
double ValorMA;
string negociar;
double ampl;
double posAlvo;


double posStop;
int Cbarras;
int x;
double perda;
bool venda = false;
bool compra = false;
int lowlowX;
double lowlow;
int highhighX;
double highhigh;
double cont = 0;
double barrar;
double naooperabarra;
double compras;
double vendas;
bool BEAtivo = false;
double UltTick;
string symba;
double lotsa,pricea;
ENUM_ORDER_TYPE typea;
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
int OnInit()
  {
   ArraySetAsSeries(rates, true);
   ArraySetAsSeries(Dia, true);
   ArraySetAsSeries(ArrayMA,true);
//Volume da ordem pode ser processado por partes
   trade.SetTypeFilling(ProcessoOrdem);
   trade.SetDeviationInPoints(DesvioOrderm);
   trade.SetExpertMagicNumber(MagicNumber);
   simbol.Name(_Symbol); // Define o símbolo que vai ser usado pela classe.
   simbol.Refresh(); // Recupera as especificações do símbolo
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
void OnTick()
  {


   TimeToStruct(TimeCurrent(), horaAtual);
   int MAPropriedades = iMA(_Symbol,_Period,Pmedia,0,Mmedia,PRICE_CLOSE);
   CopyBuffer(MAPropriedades,0,0,100,ArrayMA);
   ValorMA = NormalizeDouble(ArrayMA[0],_Digits);
   if(!SymbolInfoTick(_Symbol,ultimoTick))
     {
      Alert("Erro ao obter informações de preço", GetLastError());
      return;
     }
   if(!simbol.RefreshRates())
     {
      Alert("Erro ao copiar dados do simbol.RefreshRates ", GetLastError());
      return;
     }
   UltTick = NormalizeDouble((simbol.Bid()+simbol.Ask())/2,_Digits);
   if(CopyRates(_Symbol,_Period,0,100,rates) < 0)
     {
      Alert("Erro ao copiar dados do MqlRates ", GetLastError());
      return;
     }
   if(CopyRates(_Symbol,PERIOD_D1,0,2,Dia) < 0)
     {
      Alert("Erro ao copiar dados do MqlRates ", GetLastError());
      return;
     }
   if(painel == sim)
     {
      PAINELdeInf();
     }
// Comment("Posições: ", Posicoes()," vendas: ",vendas," compras: ",compras);
   symba = _Symbol;
   lotsa = lt1amp1+lt2amp1+lt3amp1+lt4amp1;
   if((rates[1].low > ArrayMA[1]) && (simbol.Ask() <= (ValorMA+tickmedia*tick1)))
     {
      typea = ORDER_TYPE_BUY;
      pricea = NormalizeDouble(simbol.Ask(), _Digits);
     }


   if((rates[1].high < ArrayMA[1]) && (simbol.Bid() >= (ValorMA-tickmedia*tick1
                                                       )))
     {
      typea = ORDER_TYPE_SELL;
      pricea = NormalizeDouble(simbol.Bid(), _Digits);
     }
   pcreque = UltTick;
   contagem();
   if(BEAtivo == false && rates[1].low > ArrayMA[1])
     {
      ampl = rates[highhighX].high - ArrayMA[0];
     }
   if(BEAtivo == false && rates[1].high < ArrayMA[1])
     {
      ampl = ArrayMA[0] - rates[lowlowX].low;
     }

//COMPRA 1ª
   if(HoraNegociacao() &&
      ((rates[1].close > ArrayMA[1]) && (simbol.Ask() <= (ValorMA+tickmedia*tick1
                                                         ))) &&
      (contagem() >= barras1) &&
      CheckMoneyForTrade() == true &&
      Posicoes() == 0 &&
      Ordens() == 0 &&
      ampl > AmplMin &&
      ampl <= Ampmax4
     )
     {
      if((ampl > AmplMin) && (ampl <= Ampmax1))
        {
         Lote1 = lt1amp1;
         Lote2 = lt2amp1;
         Lote3 = lt3amp1;
         Lote4 = lt4amp1;
        }
      if((ampl > Ampmin2) && (ampl <= Ampmax2))
        {
         Lote1 = lt1amp2;


         Lote2 = lt2amp2;
         Lote3 = lt3amp2;
         Lote4 = lt4amp2;
        }
      if((ampl > Ampmin3) && (ampl <= Ampmax3))
        {
         Lote1 = lt1amp3;
         Lote2 = lt2amp3;
         Lote3 = lt3amp3;
         Lote4 = lt4amp3;
        }
      if((ampl > Ampmin4) && (ampl <= Ampmax4))
        {
         Lote1 = lt1amp4;
         Lote2 = lt2amp4;
         Lote3 = lt3amp4;
         Lote4 = lt4amp4;
        }
      Print("TENTOU COMPRAR---------------------------------");
      barrar = contagem();
      BE1 = false;
      PC = NormalizeDouble(simbol.Ask(), _Digits);
      trade.Buy(Lote1,_Symbol, PC, NULL, NULL, "ENTRADA");
      operolac = false;
     }
//VENDA 1ª
   if(HoraNegociacao() &&
      ((rates[1].close < ArrayMA[1]) && (simbol.Bid() >= (ValorMA-tickmedia*tick1
                                                         ))) &&
      (contagem() >= barras1) &&
      CheckMoneyForTrade() == true &&
      Posicoes() == 0 &&
      Ordens() == 0 &&
      ampl > AmplMin &&
      ampl <= Ampmax4
     )
     {
      Print(" lt1: ",Lote1," lt2: ",Lote2," lt3: ",Lote3," lt4: ",Lote4," ampl: "
            ,ampl);
      if((ampl > AmplMin) && (ampl <= Ampmax1))
        {
         Lote1 = lt1amp1;
         Lote2 = lt2amp1;
         Lote3 = lt3amp1;
         Lote4 = lt4amp1;
        }
      if((ampl > Ampmin2) && (ampl <= Ampmax2))
        {



         Lote1 = lt1amp2;
         Lote2 = lt2amp2;
         Lote3 = lt3amp2;
         Lote4 = lt4amp2;
        }
      if((ampl > Ampmin3) && (ampl <= Ampmax3))
        {
         Lote1 = lt1amp3;
         Lote2 = lt2amp3;
         Lote3 = lt3amp3;
         Lote4 = lt4amp3;
        }
      if((ampl > Ampmin4) && (ampl <= Ampmax4))
        {
         Lote1 = lt1amp4;
         Lote2 = lt2amp4;
         Lote3 = lt3amp4;
         Lote4 = lt4amp4;
        }
      Print(" lt1: ",Lote1," lt2: ",Lote2," lt3: ",Lote3," lt4: ",Lote4," ampl: "
            ,ampl);
      Print("TENTOU VENDER---------------------------------");
      barrar = contagem();
      BE1 = false;
      PC = NormalizeDouble(simbol.Bid(), _Digits);
      trade.Sell(Lote1,_Symbol, PC, NULL, NULL, "ENTRADA");
      operolav = false;
     }
   if(operolac == false && Posicoes() == 1)
     {
      posCompra();
      operolac = true;
      BEAtivo = true;
     }
   if(operolav == false && Posicoes() == 1)
     {
      posVenda();
      operolav = true;
      BEAtivo = true;
     }

   if(BEAtivo == true)
     {
      BECV();
     }


   if(BEAtivo == true && ((Ordens() >= 1 && Posicoes() == 0)))
      // || (Posicoes() == 1 && Ordens() == 0)
     {
      while(Ordens() >= 1 && Posicoes() == 0)
        {
         DeleteOrdens();
         Print("Tentou Deletar Ordens, Num Magic: ",MagicNumber);
        }
      BEAtivo = false;
     }

  }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
bool CheckMoneyForTrade()
  {
//inicia variavel margem e também define margem livre
   double margin,free_margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
// define margem e verifica
//--- chamamos a função de verificação
   if(!OrderCalcMargin(typea,symba,lotsa,pricea,margin))
     {
      //--- algo deu errado, informamos e retornamos false
      Print("Error in ",__FUNCTION__," code=",GetLastError());
      return(false);
     }
//--- se não houver fundos suficientes para realizar a operação
   if(margin>free_margin)
     {
      //--- informamos sobre o erro e retornamos false
      Print("Not enough money for ",EnumToString(typea)," ",lotsa," ",symba,
            " Error code=",GetLastError());
      return(false);
     }
//--- a verificação foi realizada com sucesso
   return(true);
  }



int Posicoes()
  {
//Verifica Posição Aberta Somente Nessa Ativo Nesse Robo
   int contPosicao = 0;
   compras = 0;
   vendas = 0;
   for(int i = PositionsTotal()-1; i>=0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      string symbol = PositionGetString(POSITION_SYMBOL);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if(symbol == _Symbol && magic == MagicNumber)
        {
         contPosicao = contPosicao + 1;
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
           {
            compras = compras + 1;
           }
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
           {
            vendas = vendas + 1;
           }
        }
     }
   return(contPosicao);
  }

int Ordens()
  {
//Verifica se tem Ordens Pendentes
   int contOrdens = 0;
   for(int i = OrdersTotal()-1; i>=0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      string symbol = OrderGetString(ORDER_SYMBOL);
      ulong magic = OrderGetInteger(ORDER_MAGIC);
      if(symbol == _Symbol && magic == MagicNumber)
        {
         contOrdens = contOrdens + 1;
        }
     }



   return(contOrdens);
  }

void posCompra()
  {
   operolac = true;
   BEAtivo = true;
   for(int i = PositionsTotal()-1; i>=0; i--)
     {
      string symbol = PositionGetSymbol(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if(symbol == _Symbol && magic == MagicNumber)
        {
         PAberto = PositionGetDouble(POSITION_PRICE_OPEN);
        }
     }
   PC = NormalizeDouble(PAberto, _Digits);
   ampl = rates[highhighX].high - PC;
//normalizando o preço
   double tamanho = tick1;
   double ajustetp1 = MathRound((PC + ampl*alvo1)/tamanho)*tamanho;
   double ajustetp2 = MathRound((PC + ampl*alvo2)/tamanho)*tamanho;
   double ajustetp3 = MathRound((PC + alvo3*tick1)/tamanho)*tamanho;
   double ajustetp4 = MathRound((PC + alvo4*tick1)/tamanho)*tamanho;
   double ajustesl = MathRound((PC - ampl*stop)/tamanho)*tamanho;
   double ajustere1 = MathRound((PC - ampl*tick2)/tamanho)*tamanho;
   double ajustere2 = MathRound((PC - ampl*tick3)/tamanho)*tamanho;
   double ajustere3 = MathRound((PC - ampl*tick4)/tamanho)*tamanho;
   RE1 = NormalizeDouble(ajustere1, _Digits);
//mathround-> arredonda para um numero inteiro aqui a divisão do preço pelo tick do mercado
   RE2 = NormalizeDouble(ajustere2, _Digits);
   RE3 = NormalizeDouble(ajustere3, _Digits);
   SL1 = NormalizeDouble(ajustesl, _Digits);
   TP1 = NormalizeDouble(ajustetp1, _Digits);



   TP2 = NormalizeDouble(ajustetp2, _Digits);
   TP3 = NormalizeDouble(ajustetp3, _Digits);
   TP4 = NormalizeDouble(ajustetp4, _Digits);
   TP = TP1;
   SL = SL1;
   PositionMod();
//Reentradas
   trade.BuyLimit(Lote2,RE1,_Symbol,SL1,TP2,ORDER_TIME_DAY,0,"reentra 1ª");
   trade.BuyLimit(Lote3,RE2,_Symbol,SL1,TP3,ORDER_TIME_DAY,0,"reentra 2ª");
   trade.BuyLimit(Lote4,RE3,_Symbol,SL1,TP4,ORDER_TIME_DAY,0,"reentra 3ª");
   Print("AMPL: ",ampl," PC: ",PC," A1: ",TP1," A2: ",TP2," A3: ",TP3," A4: ",TP4
         ," R1: ",RE1," R2: ",RE2," R3: ",RE3);
  }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
void posVenda()
  {
   operolav = true;
   BEAtivo = true;
   for(int i = PositionsTotal()-1; i>=0; i--)
     {
      string symbol = PositionGetSymbol(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if(symbol == _Symbol && magic == MagicNumber)
        {
         PAberto = PositionGetDouble(POSITION_PRICE_OPEN);
        }
     }
   PC = NormalizeDouble(PAberto, _Digits);
   ampl = PC - rates[lowlowX].low;
//normalizando o preço
   double tamanho = tick1;
   double ajustetp1 = MathRound((PC - ampl*alvo1)/tamanho)*tamanho;
   double ajustetp2 = MathRound((PC - ampl*alvo2)/tamanho)*tamanho;
   double ajustetp3 = MathRound((PC - alvo3*tick1)/tamanho)*tamanho;
   double ajustetp4 = MathRound((PC - alvo4*tick1)/tamanho)*tamanho;
   double ajustesl = MathRound((PC + ampl*stop)/tamanho)*tamanho;
   double ajustere1 = MathRound((PC + ampl*tick2)/tamanho)*tamanho;
   double ajustere2 = MathRound((PC + ampl*tick3)/tamanho)*tamanho;
   double ajustere3 = MathRound((PC + ampl*tick4)/tamanho)*tamanho;



   RE1 = NormalizeDouble(ajustere1, _Digits);
//mathround-> arredonda para um numero inteiro aqui a divisão do preço pelo tick do mercado
   RE2 = NormalizeDouble(ajustere2, _Digits);
   RE3 = NormalizeDouble(ajustere3, _Digits);
   SL1 = NormalizeDouble(ajustesl, _Digits);
   TP1 = NormalizeDouble(ajustetp1, _Digits);
   TP2 = NormalizeDouble(ajustetp2, _Digits);
   TP3 = NormalizeDouble(ajustetp3, _Digits);
   TP4 = NormalizeDouble(ajustetp4, _Digits);
   TP = TP1;
   SL = SL1;
   PositionMod();
//Reentradas
   trade.SellLimit(Lote2,RE1,_Symbol,SL1,TP2,ORDER_TIME_DAY,0,"reentra 1ª");
   trade.SellLimit(Lote3,RE2,_Symbol,SL1,TP3,ORDER_TIME_DAY,0,"reentra 2ª");
   trade.SellLimit(Lote4,RE3,_Symbol,SL1,TP4,ORDER_TIME_DAY,0,"reentra 3ª");
   Print("AMPL: ",ampl," PC: ",PC," A1: ",TP1," A2: ",TP2," A3: ",TP3," A4: ",TP4
         ," R1: ",RE1," R2: ",RE2," R3: ",RE3);
  }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
void PositionMod()
  {
   for(int i = PositionsTotal()-1; i>=0; i--)
     {
      string symbol = PositionGetSymbol(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if(symbol == _Symbol && magic == MagicNumber)
        {
         ulong PositionTicket = PositionGetInteger(POSITION_TICKET);
         trade.PositionModify(PositionTicket,SL,TP);
        }
     }
  }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
void BECV()
  {
   if(BE1 == false && Ordens() == 2 && Posicoes() == 2)
     {



      BE1 = true;
      Print(" ********** TENTATIVA DE BE_CV 1 REALIZADA ********** ");
      TP1 = TP2;
      TP = TP2;
      PositionMod();
      BE2 = false;
     }
   if(BE2 == false && Ordens() == 1 && Posicoes() == 3)
     {
      BE2 = true;
      Print(" ********** TENTATIVA DE BE_CV 2 REALIZADA ********** ");
      TP1 = TP3;
      TP = TP3;
      PositionMod();
      BE3 = false;
     }
   if(BE3 == false && Ordens() == 0 && Posicoes() == 4)
     {
      BE3 = true;
      Print(" ********** TENTATIVA DE BE_CV 3 REALIZADA ********** ");
      TP1 = TP4;
      TP = TP4;
      PositionMod();
      BEAtivo = false;
     }
  }
//Horario das Negociações
bool HoraNegociacao()
  {
   TimeToStruct(TimeCurrent(), horaAtual);



   if(((horaAtual.hour == HorOperar && horaAtual.min == MinOperar &&
        horaAtual.sec >= SecOperar) ||
       (horaAtual.hour == HorOperar && horaAtual.min > MinOperar) ||
       (horaAtual.hour > HorOperar)) &&
      ((horaAtual.hour == HorParar && horaAtual.min < MinParar) ||
       horaAtual.hour < HorParar)
     )
     {
      negociar = "PAI tá ON";
      return true;
     }
   else
     {
      Fechaposicao();
      DeleteOrdens();
      negociar = "PAI tá OFF";
      Lote1 = 0;
      Lote2 = 0;
      Lote3 = 0;
      Lote4 = 0;
      BEAtivo = false;
      return false;
     }
  }
//Fechamento de Posição
void Fechaposicao()
  {
   for(int i = PositionsTotal()-1; i>=0; i--)
     {
      string symbol = PositionGetSymbol(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if(symbol == _Symbol && magic == MagicNumber)
        {
         ulong PositionTicket = PositionGetTicket(i);
         if(trade.PositionClose(PositionTicket, DesvioOrderm))
           {
            Print("Posição Fechada sem Falha. ResultRetCode= ",
                  trade.ResultRetcode(), "RetCodeDescription= ", trade.ResultRetcodeDescription());
           }
         else
           {
            Print("Posição Fechada COM Falha. ResultRetCode= ",
                  trade.ResultRetcode(), "RetCodeDescription= ", trade.ResultRetcodeDescription());
           }
        }
     }
  }



//Deletar Ordens Fora do Horario de Negociação
void DeleteOrdens()
  {
   for(int i = OrdersTotal()-1; i>=0; i--)
     {
      string symbol = OrderGetString(ORDER_SYMBOL);
      ulong magic = OrderGetInteger(ORDER_MAGIC);
      if(symbol == _Symbol && magic == MagicNumber)
        {
         ulong ticket = OrderGetTicket(i);
         if(trade.OrderDelete(ticket))
           {
            Print("Ordem Deletada sem Falha. ResultRetCode= ",
                  trade.ResultRetcode(), "RetCodeDescription= ", trade.ResultRetcodeDescription());
           }
         else
           {
            Print("Ordem Deletada COM Falha. ResultRetCode= ",
                  trade.ResultRetcode(), "RetCodeDescription= ", trade.ResultRetcodeDescription());
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
double MetaGanhoPerda()
  {
   double ResultadoDia;
   int Contador;
   MqlDateTime MGPData;
   TimeCurrent(MGPData);
   ResultadoDia = 0;
   perda = 0;
   HistorySelect(iTime(_Symbol,PERIOD_D1,0),iTime(_Symbol,PERIOD_D1,0)+
                 PeriodSeconds(PERIOD_D1));
// HistorySelect(0,TimeCurrent());
   int MGPDTotal = HistoryDealsTotal();
   ulong MGPTicket = 0;
   for(Contador = 0; Contador < MGPDTotal; Contador ++)
     {
      if((MGPTicket = HistoryDealGetTicket(Contador))>0 &&
         HistoryDealGetInteger(MGPTicket,DEAL_MAGIC) == MagicNumber &&
         HistoryDealGetString(MGPTicket,DEAL_SYMBOL) == _Symbol)



        {
         double MGPProfit = HistoryDealGetDouble(MGPTicket,DEAL_PROFIT);
         ENUM_DEAL_ENTRY MGPEntry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(
                                       MGPTicket,DEAL_ENTRY);
         if(MGPEntry == DEAL_ENTRY_OUT)
           {
            ResultadoDia = ResultadoDia + MGPProfit;
            if(MGPProfit < 0)
              {
               perda = perda + MGPProfit;
              }
            else
              {
               perda = 0;
              }
           }
        }
     }
   return(ResultadoDia);
  }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,0,-1); // Remove o painel do gráfico, se existir
   printf("Expert desligado pelo motivo: ",reason);
   Sleep(1000); // Por isso é necessário aguardar a remoção completa
  }




//CONTAGEM SEM PAVIL
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
int contagem()
  {
   Cbarras = 0;
   lowlow = 1000000;
   lowlowX = 0;
   highhigh = 0;
   highhighX = 0;
   if((rates[1].high < ArrayMA[1]) && (rates[1].time >= Dia[0].time))
     {
      for(x=1; x<=99; x++)
        {
         if((rates[x].high < ArrayMA[x]) && (rates[x].time >= Dia[0].time))
           {
            if(rates[x].low < lowlow)
              {
               lowlow = rates[x].low;
               lowlowX = x;
              }
            Cbarras = Cbarras + 1;
           }
         else
            break;
        }
     }
   if((rates[1].low > ArrayMA[1]) && (rates[1].time >= Dia[0].time))
     {
      for(x=1; x<=99; x++)
        {
         if((rates[x].low>ArrayMA[x]) && (rates[x].time >= Dia[0].time))
           {
            if(rates[x].high > highhigh)
              {
               highhigh = rates[x].high;
               highhighX = x;
              }
            Cbarras = Cbarras + 1;
           }
         else
            break;
        }
     }
   if(barrar == Cbarras)

     {
      Cbarras = 0;
     }
   else
     {
      barrar = 5000;
     }
   return(Cbarras);
  }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
void PAINELdeInf()
  {
//////////////// PAINEL \\\\\\\\\\\\\\\\\\\
   datetime tempo = iTime(_Symbol,_Period,0)+PeriodSeconds(_Period)-TimeCurrent
                    (); // Tempo: Abertura da barra + segundos no periodo - hora atual
   ObjectCreate(0,"painel",OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,"painel",OBJPROP_XDISTANCE,5);
   ObjectSetInteger(0,"painel",OBJPROP_YDISTANCE,20);
   ObjectSetInteger(0,"painel",OBJPROP_XSIZE,240);
   ObjectSetInteger(0,"painel",OBJPROP_YSIZE,265);
   ObjectSetInteger(0,"painel",OBJPROP_BGCOLOR,clrWhite);
   ObjectSetInteger(0,"painel",OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,"painel",OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,"painel",OBJPROP_COLOR,clrBlack);
   ObjectSetInteger(0,"painel",OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,"painel",OBJPROP_WIDTH,3);
   ObjectSetInteger(0,"painel",OBJPROP_BACK,false);
   ObjectSetString(0,"p11",OBJPROP_FONT,"Courier New");
   ObjectSetInteger(0,"p11",OBJPROP_COLOR,clrBlack);
   ObjectCreate(0,"p11",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"p11",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"p11",OBJPROP_YDISTANCE,25+(0*20));
   ObjectSetString(0,"p11",OBJPROP_TEXT,"Expert....... "); // Texto a ser exibido
   ObjectSetString(0,"p111",OBJPROP_FONT,"Courier New");
   ObjectSetInteger(0,"p111",OBJPROP_COLOR,clrBlue);
   ObjectCreate(0,"p111",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"p111",OBJPROP_XDISTANCE,120);
   ObjectSetInteger(0,"p111",OBJPROP_YDISTANCE,25+(0*20));
   ObjectSetString(0,"p111",OBJPROP_TEXT,"EMA-20"); // Texto a ser exibido
   ObjectSetString(0,"p12",OBJPROP_FONT,"Courier New");

   ObjectSetInteger(0,"p12",OBJPROP_COLOR,clrBlack);
   ObjectCreate(0,"p12",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"p12",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"p12",OBJPROP_YDISTANCE,25+(1*20));
   ObjectSetString(0,"p12",OBJPROP_TEXT,"Magic Number. "); // Texto a ser exibido
   ObjectSetString(0,"p122",OBJPROP_FONT,"Courier New");
   ObjectSetInteger(0,"p122",OBJPROP_COLOR,clrBlue);
   ObjectCreate(0,"p122",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"p122",OBJPROP_XDISTANCE,120);
   ObjectSetInteger(0,"p122",OBJPROP_YDISTANCE,25+(1*20));
   ObjectSetString(0,"p122",OBJPROP_TEXT,IntegerToString(MagicNumber));
// Texto a ser exibido
   ObjectSetString(0,"p13",OBJPROP_FONT,"Courier New");
   ObjectSetInteger(0,"p13",OBJPROP_COLOR,clrBlack);
   ObjectCreate(0,"p13",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"p13",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"p13",OBJPROP_YDISTANCE,25+(2*20));
   ObjectSetString(0,"p13",OBJPROP_TEXT,"By........... "); // Texto a ser exibido
   ObjectSetString(0,"p133",OBJPROP_FONT,"Courier New");
   ObjectSetInteger(0,"p133",OBJPROP_COLOR,clrBlue);
   ObjectCreate(0,"p133",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"p133",OBJPROP_XDISTANCE,120);
   ObjectSetInteger(0,"p133",OBJPROP_YDISTANCE,25+(2*20));
   ObjectSetString(0,"p133",OBJPROP_TEXT,"TRUELIFE co."); // Texto a ser exibido
   ObjectSetString(0,"1",OBJPROP_FONT,"Courier New");
   ObjectSetInteger(0,"1",OBJPROP_COLOR,clrBlack);
   ObjectCreate(0,"1",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"1",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"1",OBJPROP_YDISTANCE,105+(0*20));
   ObjectSetString(0,"1",OBJPROP_TEXT,"BAR TIME..... "); // Texto a ser exibido
   ObjectSetString(0,"11",OBJPROP_FONT,"Courier New");
   ObjectSetInteger(0,"11",OBJPROP_COLOR,clrBlue);
   ObjectCreate(0,"11",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"11",OBJPROP_XDISTANCE,120);
   ObjectSetInteger(0,"11",OBJPROP_YDISTANCE,105+(0*20));
   ObjectSetString(0,"11",OBJPROP_TEXT,TimeToString(tempo,TIME_SECONDS));
// Texto a ser exibido
   ObjectSetString(0,"2",OBJPROP_FONT,"Courier New");
   ObjectSetInteger(0,"2",OBJPROP_COLOR,clrBlack);
   ObjectCreate(0,"2",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"2",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"2",OBJPROP_YDISTANCE,105+(1*20));
   ObjectSetString(0,"2",OBJPROP_TEXT,"DAY PROFIT... "); // Texto a ser exibido
   ObjectSetString(0,"22",OBJPROP_FONT,"Courier New");
   ObjectSetInteger(0,"22",OBJPROP_COLOR,clrBlue);
   ObjectCreate(0,"22",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"22",OBJPROP_XDISTANCE,120);
   ObjectSetInteger(0,"22",OBJPROP_YDISTANCE,105+(1*20));

   ObjectSetString(0,"22",OBJPROP_TEXT,DoubleToString(MetaGanhoPerda(),1));
// Texto a ser exibido
   ObjectSetString(0,"3",OBJPROP_FONT,"Courier New");
   ObjectSetInteger(0,"3",OBJPROP_COLOR,clrBlack);
   ObjectCreate(0,"3",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"3",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"3",OBJPROP_YDISTANCE,105+(2*20));
   ObjectSetString(0,"3",OBJPROP_TEXT,"PROFIT....... "); // Texto a ser exibido
   ObjectSetString(0,"33",OBJPROP_FONT,"Courier New");
   ObjectSetInteger(0,"33",OBJPROP_COLOR,clrBlue);
   ObjectCreate(0,"33",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"33",OBJPROP_XDISTANCE,120);
   ObjectSetInteger(0,"33",OBJPROP_YDISTANCE,105+(2*20));
   ObjectSetString(0,"33",OBJPROP_TEXT,DoubleToString(AccountInfoDouble(
                      ACCOUNT_PROFIT),1)); // Texto a ser exibido
   ObjectSetString(0,"4",OBJPROP_FONT,"Courier New");
   ObjectSetInteger(0,"4",OBJPROP_COLOR,clrBlack);
   ObjectCreate(0,"4",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"4",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"4",OBJPROP_YDISTANCE,105+(3*20));
   ObjectSetString(0,"4",OBJPROP_TEXT,"SITUAÇÃO..... "); // Texto a ser exibido
   ObjectSetString(0,"44",OBJPROP_FONT,"Courier New");
   ObjectSetInteger(0,"44",OBJPROP_COLOR,clrBlue);
   ObjectCreate(0,"44",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"44",OBJPROP_XDISTANCE,120);
   ObjectSetInteger(0,"44",OBJPROP_YDISTANCE,105+(3*20));
   ObjectSetString(0,"44",OBJPROP_TEXT,negociar); // Texto a ser exibido
   ObjectSetString(0,"p21",OBJPROP_FONT,"Courier New");
   ObjectSetInteger(0,"p21",OBJPROP_COLOR,clrBlack);
   ObjectCreate(0,"p21",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"p21",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"p21",OBJPROP_YDISTANCE,200+(0*20));
   ObjectSetString(0,"p21",OBJPROP_TEXT,"Amplitude.... "); // Texto a ser exibido
   ObjectSetString(0,"p211",OBJPROP_FONT,"Courier New");
   ObjectSetInteger(0,"p211",OBJPROP_COLOR,clrBlue);
   ObjectCreate(0,"p211",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"p211",OBJPROP_XDISTANCE,120);
   ObjectSetInteger(0,"p211",OBJPROP_YDISTANCE,200+(0*20));
   ObjectSetString(0,"p211",OBJPROP_TEXT,DoubleToString(ampl,_Digits));
// Texto a ser exibido
   ObjectSetString(0,"p22",OBJPROP_FONT,"Courier New");
   ObjectSetInteger(0,"p22",OBJPROP_COLOR,clrBlack);
   ObjectCreate(0,"p22",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"p22",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"p22",OBJPROP_YDISTANCE,200+(1*20));
   ObjectSetString(0,"p22",OBJPROP_TEXT,"Stop $....... "); // Texto a ser exibido
   ObjectSetString(0,"p222",OBJPROP_FONT,"Courier New");
   ObjectSetInteger(0,"p222",OBJPROP_COLOR,clrBlue);
   ObjectCreate(0,"p222",OBJ_LABEL,0,0,0);


   ObjectSetInteger(0,"p222",OBJPROP_XDISTANCE,120);
   ObjectSetInteger(0,"p222",OBJPROP_YDISTANCE,200+(1*20));
   ObjectSetString(0,"p222",OBJPROP_TEXT,DoubleToString(RpT*(Lote1*ampl*stop +
                   Lote2*(ampl*stop-ampl*tick2) + Lote3*(ampl*stop-ampl*tick3))/tick1,_Digits));
// Texto a ser exibido
   ObjectSetString(0,"p23",OBJPROP_FONT,"Courier New");
   ObjectSetInteger(0,"p23",OBJPROP_COLOR,clrBlack);
   ObjectCreate(0,"p23",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"p23",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"p23",OBJPROP_YDISTANCE,200+(2*20));
   ObjectSetString(0,"p23",OBJPROP_TEXT,"Distância.... "); // Texto a ser exibido
   ObjectSetString(0,"p233",OBJPROP_FONT,"Courier New");
   ObjectSetInteger(0,"p233",OBJPROP_COLOR,clrBlue);
   ObjectCreate(0,"p233",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"p233",OBJPROP_XDISTANCE,120);
   ObjectSetInteger(0,"p233",OBJPROP_YDISTANCE,200+(2*20));
   ObjectSetString(0,"p233",OBJPROP_TEXT,DoubleToString(UltTick-ValorMA,_Digits
                                                       )); // Texto a ser exibido
   ObjectSetString(0,"p24",OBJPROP_FONT,"Courier New");
   ObjectSetInteger(0,"p24",OBJPROP_COLOR,clrBlack);
   ObjectCreate(0,"p24",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"p24",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"p24",OBJPROP_YDISTANCE,200+(3*20));
   ObjectSetString(0,"p24",OBJPROP_TEXT,"Contagem..... "); // Texto a ser exibido
   ObjectSetString(0,"p244",OBJPROP_FONT,"Courier New");
   ObjectSetInteger(0,"p244",OBJPROP_COLOR,clrBlue);
   ObjectCreate(0,"p244",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"p244",OBJPROP_XDISTANCE,120);
   ObjectSetInteger(0,"p244",OBJPROP_YDISTANCE,200+(3*20));
   ObjectSetString(0,"p244",OBJPROP_TEXT,IntegerToString(contagem(),1));
// Texto a ser exibido
  }
//+------------------------------------------------------------------+








































//+------------------------------------------------------------------+
