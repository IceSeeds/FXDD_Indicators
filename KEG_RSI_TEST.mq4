#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#define OBJ_NAME "KEG_RSI_OBJ_"

#define VOLA     70

int  i_object  = 0;
long l_chartID = ChartID();
double d_digits = 0;

string str_comment = "";

double d_highest;
double d_lowest;

string str_high = OBJ_NAME + "highest";
string str_low = OBJ_NAME + "lowest";
string str_period = OBJ_NAME + "period";

double tmp_high;
double tmp_low;

double d_width;

int OnInit()
{
   d_digits = MathPow( 10, Digits() - 1 );
   
   lineCreate();
   
   return INIT_SUCCEEDED;
}


int OnCalculate( const int       rates_total,
                 const int       prev_calculated,
                 const datetime  &time[],
                 const double    &open[],
                 const double    &high[],
                 const double    &low[],
                 const double    &close[],
                 const long      &tick_volume[],
                 const long      &volume[],
                 const int       &spread[] )
{
    TaskSetMinPeriod();
    
    //volatility();
    //WeekBora();
    
    //Comment( getRSI( "USDJPY", PERIOD_M30, 14 ) );
    
    getHigh_Low();
    if( tmp_high != d_highest || tmp_low != d_lowest )
        lineMove();
    tmp_high = d_highest;
    tmp_low  = d_lowest;
    
    
    d_width = ( d_highest - d_lowest ) * d_digits;
    d_width = NormalizeDouble( d_width, Digits() );
        
    
    Comment( d_width );
    
    //Comment( str_comment );
    
    return rates_total;
}
void TaskSetMinPeriod()
{
    static datetime s_lastset_mintime;
    datetime temptime = iTime( Symbol(), PERIOD_M30 ,0 );

    if( temptime == s_lastset_mintime )
        return;
    s_lastset_mintime = temptime;

    // ----- 処理はこれ以降に追加 -----------
    //Alert( "ok" );
    lineMove();

    if( d_width <= VOLA )
    {
        double d_rsi = getRSI( Symbol(), PERIOD_CURRENT, 14 );
        arrow( d_rsi );        
    }
        
}
bool lineMove()
{
    ObjectMove( str_high, 0, Time[0], d_highest );
    ObjectMove( str_low, 0, Time[0], d_lowest );
    ObjectMove( str_period, 0, Time[14], Close[0] );
    
    return true;
}

bool lineCreate()
{
    if( !ObjectCreate( str_high, OBJ_HLINE, 0, Time[0], d_highest ) )
        return false;
    if( !ObjectCreate( str_low, OBJ_HLINE, 0, Time[0], d_lowest ) )
        return false;
    if( !ObjectCreate( str_period, OBJ_VLINE, 0, Time[14], Close[0] ) )
        return false;
    
    return true;
}


bool getHigh_Low()
{
    
    d_highest = iHigh( Symbol(), 0, iHighest( Symbol(), 0, MODE_HIGH, 14 ) );
    d_lowest  = iLow( Symbol(), 0, iLowest( Symbol(), 0, MODE_LOW, 14 ) );
    
    str_comment = "high : " + (string)d_highest + "\nlow  : " + (string)d_lowest;
    
    return true;
}

double getRSI( string str_symbol, int i_timeframe, int i_period )
{
    double d_rsi;
    d_rsi = iRSI( str_symbol, i_timeframe, i_period, PRICE_CLOSE, 0 );
    d_rsi = NormalizeDouble( d_rsi, 3 );
    
    return d_rsi;
}

bool arrow( double d_rsi )
{
    if( d_rsi >= 70 )
    {
        if( !create( true ) )
            return false;
    }else if( d_rsi <= 30 ){
        if( !create( false ) )
            return false;
    }
    if( d_rsi >= 80 )
    {
        if( !create( true, true ) )
            return false;
    }else if( d_rsi <= 20 ){
        if( !create( false, true ) )
            return false;
    }
    
    return true;
}


bool create( int high_low, int strongest = false )
{
    string str_name;
    double d_point;
    int i_pips = 100;
    
    if( high_low )
        d_point = 100 * Point;
    else
        d_point = -( 100 * Point );
        
    while( true )
    {
        str_name = OBJ_NAME + (string)i_object;
        
        if( !ObjectCreate( l_chartID, str_name, OBJ_ARROW, 0, Time[0], Close[0] + d_point ) )
        {
            if( GetLastError() == ERR_OBJECT_ALREADY_EXISTS ){
                i_object++;
            }else{
                return false;
            }
        }else{
            break;
        }
    }
    ObjectSetInteger( l_chartID, str_name, OBJPROP_WIDTH, 1 );
    ObjectSetInteger( l_chartID, str_name, OBJPROP_BACK, false );
    ObjectSetInteger( l_chartID, str_name, OBJPROP_SELECTABLE, false );
    ObjectSetInteger( l_chartID, str_name, OBJPROP_HIDDEN, true );
    ObjectSetInteger( l_chartID, str_name, OBJPROP_ANCHOR, ANCHOR_TOP );
    
    if( high_low )
    {
        ObjectSetInteger( l_chartID, str_name, OBJPROP_COLOR, clrDeepSkyBlue );
        ObjectSetInteger( l_chartID, str_name, OBJPROP_ARROWCODE, 238 );
        
    }else{
        ObjectSetInteger( l_chartID, str_name, OBJPROP_COLOR, clrDeepSkyBlue );
        ObjectSetInteger( l_chartID, str_name, OBJPROP_ARROWCODE, 236 );
    }
    
    if( strongest )
    {
        PlaySound("ok.wav");
        ObjectSetInteger( l_chartID, str_name, OBJPROP_COLOR, clrDeepPink );  
        ObjectSetInteger( l_chartID, str_name, OBJPROP_WIDTH, 4 );
    }
    
    return true;
}



/*
    dekinai...
*/
double d_vola = 0;
int period = 5;
bool volatility()
{
    double avarage = 0;
    for( int i = 1; period <= i; i++ )
    {
        d_vola = iHigh( Symbol(), PERIOD_D1, i ) - iLow( Symbol(), PERIOD_D1, i );
        d_vola = NormalizeDouble( d_vola, Digits() );
        d_vola *= d_digits;
        
        avarage += d_vola;
    }
    avarage /= period;
    

    Comment( avarage );
    
    return true;
}

//38.68
double d_HL;
double BoraAve = 0;
int i_period_vola = 5;
bool WeekBora()
{
   double d_average = 0 ;
   
   for( int i = 1; i_period_vola >= i; i++ )
   {
      d_HL  = NormalizeDouble( iHigh( Symbol(), PERIOD_D1, i ), Digits() ) - NormalizeDouble( iLow( Symbol(), PERIOD_D1, i ), Digits() );
      d_HL *= d_digits; 
      
      //d_verage += NormalizeDouble( d_HL, Digits()) ;
   }
   BoraAve = d_verage / i_period_vola ;
   
   Comment( BoraAve );
     
   //Alert( BoraAve ); 
   return true;
}
