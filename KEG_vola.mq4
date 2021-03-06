#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

//--- input parameters
input int    Period        = 5 ;          //期間
//input Corner Original      = LeftUp ;   //座標の中心設定
input int    StrX          = 300 ;        //X軸
input int    StrY          = 10 ;         //Y軸
input int    BoraSize      = 12 ;         //文字サイズ
input color  Color         = clrWhite ;   //文字の色

#define NowCandle     0
#define DayBoraName   "vola_DayValue"
#define WeekBoraName  "vola_WeekValue"
#define LineName      "vola_Line"
#define toDayBoraName "vola_toDayBoraValue" 

double  BoraAve       = 0 ;
double  d_CandleHL    = 0 ;
double  CandleAve     = 0 ;
double  toDayBora     = 0 ;
double  DigitsValue   = 0 ;
double  Digit         = 0 ;
bool    checkLavel    = false;
bool    checkVola     = false;

class CVolatility
{
   public:
      bool CreateVolatility();
   protected:
      double WeekBora();
      double DayBora();
      double toDayBora();
      bool   textVV();
};

bool CVolatility::CreateVolatility()
{
   if( !checkVola )
   {
      DigitsValue = MathPow( 10, Digits() - 1 );
      if( !textVV() ) return false;
      checkLavel = true;
   }
   checkLavel = checkVola;
   if( !ObjectSetText( WeekBoraName,   StringFormat( "週足 ： %3.1f Pips", WeekBora() ),  BoraSize, "ＭＳ　ゴシック", Color ) ) return false;
   if( !ObjectSetText( DayBoraName,    StringFormat( "日足 ： %3.1f Pips", DayBora() ),   BoraSize, "ＭＳ　ゴシック", Color ) ) return false;
   if( !ObjectSetText( LineName,       "------------",                                   BoraSize, "ＭＳ　ゴシック", Color ) ) return false;
   if( !ObjectSetText( toDayBoraName,  StringFormat( "現在 ： %3.1f Pips", toDayBora() ), BoraSize, "ＭＳ　ゴシック", Color ) ) return false;
   
   return true;
}

double CVolatility::WeekBora()
{
   CandleAve = 0 ;
   
   for( int i = 1; Period >= i; i++ )
   {
      d_CandleHL   = ( NormalizeDouble( iHigh( Symbol(), PERIOD_W1, i ), Digits() )) - ( NormalizeDouble( iLow( Symbol(), PERIOD_W1, i ), Digits() )) ;
      d_CandleHL  *= DigitsValue ; 
      
      CandleAve += NormalizeDouble( d_CandleHL, Digits()) ;
   }
   BoraAve  = CandleAve / Period ;
   
   string WeekBoraStr = DoubleToStr( BoraAve, 2 ) ;
   double week = StringToDouble( WeekBoraStr );
   
   return week ;
}

double CVolatility::DayBora()
{
   CandleAve = 0 ;
   
   for( int i = 1; Period >= i; i++ )
   {
      d_CandleHL   = ( NormalizeDouble( iHigh( Symbol(), PERIOD_D1, i ), Digits() )) - ( NormalizeDouble( iLow( Symbol(), PERIOD_D1, i ), Digits() )) ;
      d_CandleHL  *= DigitsValue ; 
      
      CandleAve += NormalizeDouble( d_CandleHL, Digits()) ;
   }
   BoraAve  = CandleAve / Period ;
   
   string BoraStr = DoubleToStr( BoraAve, 2 ) ;
   double bora    = StringToDouble( BoraStr ); 
   
   return bora ;
}

/* 現在のボラティリティ */
double CVolatility::toDayBora()
{
   toDayBora  = NormalizeDouble( iHigh( Symbol(), PERIOD_D1, 0 ), Digits() ) - NormalizeDouble( iLow( Symbol(), PERIOD_D1, 0 ), Digits() ) ;
   toDayBora *= DigitsValue ;

   string toDayBoraStr = DoubleToString( toDayBora, 2 ) ;
   double toDay        = StringToDouble( toDayBoraStr );
   
   return toDay ;
}

bool CVolatility::textVV()
{
   if( !ObjectCreate( WeekBoraName,    OBJ_LABEL, 0, 0, 0 ) ) return false;
   if( !ObjectCreate( DayBoraName,     OBJ_LABEL, 0, 0, 0 ) ) return false;
   if( !ObjectCreate( LineName,        OBJ_LABEL, 0, 0, 0 ) ) return false;
   if( !ObjectCreate( toDayBoraName,   OBJ_LABEL, 0, 0, 0 ) ) return false;
   
/* ふぉんと崩れるからつかわん！ｗ
   ObjectSet( WeekBoraName,       OBJPROP_CORNER, Original ) ;
   ObjectSet( DayBoraName,        OBJPROP_CORNER, Original ) ;
   ObjectSet( LineName,           OBJPROP_CORNER, Original ) ;
   ObjectSet( toDayBoraName,      OBJPROP_CORNER, Original ) ;
*/ 
   ObjectSet( WeekBoraName,       OBJPROP_XDISTANCE, StrX ) ;
   ObjectSet( WeekBoraName,       OBJPROP_YDISTANCE, StrY ) ;
   ObjectSet( DayBoraName,        OBJPROP_XDISTANCE, StrX ) ;
   ObjectSet( DayBoraName,        OBJPROP_YDISTANCE, StrY + 25 ) ;
   ObjectSet( LineName,           OBJPROP_XDISTANCE, StrX ) ;
   ObjectSet( LineName,           OBJPROP_YDISTANCE, StrY + 45 ) ;
   ObjectSet( toDayBoraName,      OBJPROP_XDISTANCE, StrX ) ;
   ObjectSet( toDayBoraName,      OBJPROP_YDISTANCE, StrY + 65 ) ; 
   
   return true;
}

CVolatility vora;

int OnInit()
{
   vora.CreateVolatility();
   
   
   return INIT_SUCCEEDED;
}
void OnTick()
{
    vora.CreateVolatility();
}