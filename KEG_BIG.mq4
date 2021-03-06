#property copyright "Copyright 2021 03/19, IceSeed."
#property version   "1.01"
#property strict
#property indicator_chart_window

#define OBJ_NAME     "KEG_BIG_STAR"
#define CROSS_CANDLE 60    //十字判断のpips
#define COVER_CANDLE 0.4   //被せローソクの割合

struct DATA
{
    double d_open;
    double d_close;
    double d_high;
    double d_low;
    double d_body;         //実体
    double d_up_beard;     //上髭
    double d_down_beard;   //下髭
    int    i_type;         //陰:陽
};

DATA first; //３本前
DATA midd;  //２本前
DATA end;   //１本前

datetime g_t_keepCandle; // ローソクの切り替わり
int      g_i_object = 0; // オブジェクトのカウント

int count = 0;

int OnInit()
{
   return INIT_SUCCEEDED;
}

void OnDeinit( const int reason )
{
   if( reason != REASON_CHARTCHANGE )
      ObjectsDeleteAll( ChartID(), OBJ_NAME );
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
   if( Time[0] != g_t_keepCandle )
   {
      g_t_keepCandle = Time[0];
      
      getData( 3, first.d_open, first.d_close, first.d_high, first.d_low, first.i_type, first.d_body, first.d_up_beard, first.d_down_beard );
      BIG_STAR();
      Comment( "Count : " + (string)count );
   }
   
   return rates_total;
}

/* メインロジック */
void BIG_STAR()
{
   if( first.i_type == 0 ) return;
   
   getData( 2, midd.d_open,  midd.d_close,  midd.d_high,  midd.d_low, midd.i_type, midd.d_body, midd.d_up_beard, midd.d_down_beard );
   getData( 1, end.d_open,   end.d_close,   end.d_high,   end.d_low,  end.i_type,  end.d_body,  end.d_up_beard,  end.d_down_beard );
   
   double d_bread = end.i_type == 1 ? end.d_down_beard : end.d_up_beard;
   
   if( first.i_type == midd.i_type )                   return;
   if( ( first.d_body * COVER_CANDLE ) > midd.d_body ) return;
   if( midd.i_type != end.i_type || end.i_type == 0 )  return;
   if( ( midd.d_body * COVER_CANDLE ) > d_bread )      return;
   
   Alert( "GOOOOOOOOOOOOOOOOD" );
   create( end.i_type );
   count++;
}

/**
 * 四本値と実体、ヒゲを取得
*/
void getData( int i, double &d_open, double &d_close, double &d_high, double &d_low, int &i_type, double &d_body, double &d_up_beard, double &d_down_beard )
{
   d_open  = Open[i];
   d_close = Close[i];
   d_high  = High[i];
   d_low   = Low[i];
    
   d_body  = MathAbs( d_open - d_close );
   
   if( getCrossCandle( d_open, d_close ) )
      i_type = 0;
   else
      i_type = d_open < d_close ? 1 : -1;

   d_up_beard   = i_type == 1 ? d_high - d_close : d_high  - d_open;
   d_down_beard = i_type == 1 ? d_open - d_low   : d_close - d_low;
}
/**
 * 十字を判断
*/
bool getCrossCandle( double d_open, double d_close )
{
   if( MathAbs( d_open - d_close ) < ( CROSS_CANDLE * Point ) )
      return true;
   else
      return false;
}

/**
 * 矢印オブジェクトを生成
*/
void create( int i_type )
{
   string str_name;
   
   /* 名前被りを回避 */
   while( true )
   {
      str_name = OBJ_NAME + (string)g_i_object;
     
      if( !ObjectCreate( ChartID(), str_name, OBJ_ARROW, 0, Time[1], Close[0] ) )
      {
         if( GetLastError() == ERR_OBJECT_ALREADY_EXISTS )
             g_i_object++;
         else
             return;
      }else
         break;
   }

   int   i_code  = i_type == 1 ? 233 : 234;
   color c_color = i_type == 1 ? clrAqua : clrDeepPink;
   ObjectSetInteger( ChartID(), str_name, OBJPROP_ARROWCODE, i_code );
   ObjectSetInteger( ChartID(), str_name, OBJPROP_COLOR,     c_color );
}



/*
 * メインロジック
 * 処理が早いver
 *
*/
void BIG_STAR_FIST()
{
   if( first.i_type == 0 ) return;
   
   getData( 2, midd.d_open,  midd.d_close,  midd.d_high,  midd.d_low, midd.i_type, midd.d_body, midd.d_up_beard, midd.d_down_beard );
   
   if( first.i_type == midd.i_type )          return;
   if( ( first.d_body * COVER_CANDLE ) > midd.d_body ) return;
   
   getData( 1, end.d_open, end.d_close, end.d_high, end.d_low, end.i_type, end.d_body, end.d_up_beard, end.d_down_beard );
   
   if( midd.i_type != end.i_type || end.i_type == 0 ) return;
   
   double d_bread = end.i_type == 1 ? end.d_down_beard : end.d_up_beard;
   if( ( midd.d_body * COVER_CANDLE ) > d_bread ) return;
   
   Alert( "GOOOOOOOOOOOOOOOOD" );
   create( end.i_type );
}
