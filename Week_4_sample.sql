/* Filter data for mkt segment Automobile*/

with Automobile_mkt as (
     select distinct C_CUSTKEY
     from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
     where trim(upper(C_MKTSEGMENT))=trim(upper('automobile'))
     ),

/* Filter for priority "Urgent" orders */

     urgent_orders as (
     select
           O_ORDERKEY,
           Automobile_mkt.C_CUSTKEY,
           O_TOTALPRICE,
           O_ORDERDATE
     from  SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
     inner join Automobile_mkt
               on SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS.O_CUSTKEY=Automobile_mkt.C_CUSTKEY                
     where trim(upper(O_ORDERPRIORITY)) like trim(upper('%urgent'))            
     ),
         
   /* find the last urgent order date and sum to 3 top spent orders for each customer*/  

     last_urgent_order as (
     select 
          C_CUSTKEY,
          O_ORDERKEY,
          O_TOTALPRICE,
          O_ORDERDATE,
          max(O_ORDERDATE) over (partition by C_CUSTKEY order by O_ORDERDATE desc)  as  last_urgent_order_date,
          rank() over(partition by C_CUSTKEY order by O_TOTALPRICE desc) as pricerank
     from urgent_orders    
     ),      
      
    highest_dollar_orders as (
    select
          C_CUSTKEY,
          any_value(last_urgent_order_date) as last_urgent_order_date,
          listagg(O_ORDERKEY,',') as ORDER_NUMBERS,
          sum(O_TOTALPRICE) as TOTAL_SPENT
    from last_urgent_order
    where pricerank<4
    group by 1    
    ), 
    
  /* partkey sales data*/     

    part_order_data as(
    select
          O_ORDERKEY,
          C_CUSTKEY,
          L_PARTKEY,
          L_QUANTITY,
          L_EXTENDEDPRICE
    from urgent_orders
    inner join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM
              on urgent_orders.O_ORDERKEY=SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM.L_ORDERKEY
    where SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.LINEITEM.L_PARTKEY is not null
    ),
    
    top_three_parts as (
    select 
          C_CUSTKEY, 
          L_PARTKEY,
          L_QUANTITY,
          L_EXTENDEDPRICE,
          rank() over (partition by C_CUSTKEY order by L_EXTENDEDPRICE desc) as part_price_rank,
         case 
             when PART_PRICE_RANK=1 then 'PART_1_KEY'
             when PART_PRICE_RANK=2 then 'PART_2_KEY'
             else 'PART_3_KEY'
         end as key_value,
         case 
             when PART_PRICE_RANK=1 then 'PART_1_QUANTITY'
             when PART_PRICE_RANK=2 then 'PART_2_QUANTITY'
             else 'PART_3_QUANTITY'
             end as qnty_value,
         case 
             when PART_PRICE_RANK=1 then 'PART_1_TOTAL_SPENT'
             when PART_PRICE_RANK=2 then 'PART_2_TOTAL_SPENT'
             else 'PART_3_TOTAL_SPENT'
         end as totalspent_value
  from part_order_data
  where L_PARTKEY is not null
  qualify (part_price_rank)<4
  ),
 
  top_three_parts_pivot as (
  select 
       * exclude PART_PRICE_RANK 
  from top_three_parts
  pivot(sum(L_PARTKEY) FOR key_value IN ('PART_1_KEY','PART_2_KEY','PART_3_KEY') )    
  pivot(sum(L_QUANTITY) FOR qnty_value IN ('PART_1_QUANTITY','PART_2_QUANTITY','PART_3_QUANTITY')) 
  pivot(sum(L_EXTENDEDPRICE) FOR totalspent_value IN ('PART_1_TOTAL_SPENT','PART_2_TOTAL_SPENT','PART_3_TOTAL_SPENT'))  
  ),

  /* get one row per customer */

  top_three_parts_final as (
  select c_custkey ,
         max($2) as PART_1_KEY,
         max($3) as PART_2_KEY,
         max($4) as PART_3_KEY,
         max($5) as PART_1_QUANTITY,
         max($6) as PART_2_QUANTITY,
         max($7) as PART_3_QUANTITY,
         max($8) as PART_1_TOTAL_SPENT,
         max($9) as PART_2_TOTAL_SPENT,
         max($10) as PART_3_TOTAL_SPENT
   from top_three_parts_pivot   
   group by 1
   )
  
   select 
        highest_dollar_orders.C_CUSTKEY as C_CUSTKEY,
        highest_dollar_orders.last_urgent_order_date as LAST_ORDER_DATE,
        highest_dollar_orders.ORDER_NUMBERS as ORDER_NUMBERS,
        highest_dollar_orders.TOTAL_SPENT as TOTAL_SPENT, 
        top_three_parts_final.PART_1_KEY,
        top_three_parts_final.PART_1_QUANTITY,
        top_three_parts_final.PART_1_TOTAL_SPENT,
        top_three_parts_final.PART_2_KEY,
        top_three_parts_final.PART_2_QUANTITY,
        top_three_parts_final.PART_2_TOTAL_SPENT,
        top_three_parts_final.PART_3_KEY,
        top_three_parts_final.PART_3_QUANTITY,
        top_three_parts_final.PART_3_TOTAL_SPENT
   from highest_dollar_orders
   inner join top_three_parts_final
             on 
             highest_dollar_orders.C_CUSTKEY=top_three_parts_final.C_CUSTKEY
   order by LAST_ORDER_DATE desc


