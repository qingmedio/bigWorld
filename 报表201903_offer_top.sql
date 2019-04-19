
hive -e "select concat_ws(',',latn_id,cast(cur_amount as string),'0','0',
cast(new_amount as string),
cast(new_amount1 as string),
cast(new_amount2 as string),
cast(new_amount3 as string),
cast(new_amount4 as string),
cast(change_amount as string),
cast(change_amount1 as string),
cast(change_amount1p as string),
cast(change_amount2 as string),
cast(change_amount2p as string),
cast(change_amount3 as string),
cast(change_amount3p as string),
cast(exist_amount as string),
cast(exist_amount1 as string),
cast(exist_amount1p as string),
cast(exist_amount20 as string),
cast(exist_amount2 as string),
cast(exist_amount3 as string),
cast(exist_amount4 as string), 
cast(exist_amount22 as string),
cast(lost_amount1 as string),
cast(lost_amount11 as string),
cast(change_amount4 as string)) ws from (
select latn_id,
       cur_amount,
       new_amount,
       new_amount1,
       new_amount2,
       new_amount3,new_amount4,
       change_amount,
       change_amount1,
       change_amount1 - change_amount11 change_amount1p,
       change_amount2,
       change_amount2 - change_amount22 change_amount2p,
       change_amount3,
       change_amount3 - change_amount33 change_amount3p, change_amount4,
       exist_amount,exist_amount1,exist_amount1-exist_amount11 exist_amount1p,exist_amount20,exist_amount2,
       exist_amount3,exist_amount4,exist_amount22,
       lost_amount1,lost_amount11
  from (select a.latn_id,sum(a.offer_amount)cur_amount,
  sum(case when a.offer_change_flag like '%新增%'then a.offer_amount else 0 end) new_amount,
sum(case when a.offer_change_flag like '新增-主成员%'then a.offer_amount else 0 end) new_amount1,
sum(case when a.offer_change_flag like '新增-全%'then a.offer_amount else 0 end) new_amount2,
sum(case when a.offer_change_flag like '待新增-主成员%'then a.offer_amount else 0 end) new_amount3,
sum(case when a.offer_change_flag like '待新增-全%'then a.offer_amount else 0 end) new_amount4,
sum(case when a.offer_change_flag like '改装%' and a.offer_change_flag not like '改装-%->其他' then a.offer_amount else 0 end) change_amount,
sum(case when a.offer_change_flag like '改装-%->单C%'then a.offer_amount else 0 end) change_amount1,
sum(case when a.offer_change_flag like '改装-%->单C%'then nvl(a.last_offer_amount,0) else 0 end) change_amount11,
sum(case when a.offer_change_flag like '改装-%->单宽%'then a.offer_amount else 0 end) change_amount2,
sum(case when a.offer_change_flag like '改装-%->单宽%'then nvl(a.last_offer_amount,0) else 0 end) change_amount22,
sum(case when a.offer_change_flag like '改装-%->融合%'then a.offer_amount else 0 end) change_amount3,
sum(case when a.offer_change_flag like '改装-%->融合%'then nvl(a.last_offer_amount,0) else 0 end) change_amount33,
sum(case when a.offer_change_flag like '存量%'then a.offer_amount else 0 end) exist_amount,
sum(case when a.offer_change_flag ='存量'or a.offer_change_flag like '待改%' then a.offer_amount else 0 end) exist_amount1,
sum(case when a.offer_change_flag ='存量'or a.offer_change_flag like '待改%' then nvl(last_offer_amount,0) else 0 end) exist_amount11,
sum(case when a.offer_change_flag like '存量-%'then nvl(a.offer_amount,0) else 0 end) exist_amount20,
sum(case when a.offer_change_flag like '存量-主成员改装'then nvl(a.offer_amount,0) else 0 end) exist_amount2, 
sum(case when a.offer_change_flag like '存量-改装'then nvl(a.offer_amount,0) else 0 end) exist_amount3, 
sum(case when a.offer_change_flag like '存量-裸资费'then nvl(a.offer_amount,0) else 0 end) exist_amount4, 
sum(case when a.offer_change_flag like '存量-%'then nvl(a.last_offer_amount,0) else 0 end) exist_amount22,
sum(case when a.offer_change_flag like '流失%'then a.offer_amount else 0 end) lost_amount1,
sum(case when a.offer_change_flag like '流失%'then nvl(a.last_offer_amount,0) else 0 end) lost_amount11,
sum(case when a.offer_change_flag like '%其他'then nvl(a.offer_amount,0) else 0 end) change_amount4
          from hi_app_dc.app_prod_offer_03_END_3 a  
           where  offer_Id in (100010008323,
                      500000203,
                      100010004526,
                      100010003528,
                      500001607,
                      100010005216,
                      109040000010,
                      500000211,
                      100010008321,
                      100010005205,
                      100010007530,
                      100010008348)
         group by a.latn_id) tt)tt1 order by ws ">testvv.csv 

iconv -f UTF-8 -c  -t GBK testvv.csv > testbb.csv
  
  
hive -e "select concat_ws(',',latn_id,cast(all_num as string),
cast (new_num as string),
cast (new_num1 as string),
cast (new_num2 as string),
cast (new_num3 as string),
cast (new_num4 as string),
cast (change_num as string),
cast (change_amount1 as string),
cast (change_amount2 as string),
cast (change_amount3 as string),
cast (exist_amount1 as string),
cast (exist_amount2 as string),
cast (exist_amount3 as string),
cast (exist_amount4 as string), 
cast (lost as string),
cast (change_amount4 as string))wssd from (
 select a.latn_id,count(1) all_num,sum(case when a.offer_change_flag like '%新增%'then 1 else 0 end) new_num,
sum(case when a.offer_change_flag like '新增-主成员%'then 1 else 0 end) new_num1, 
sum(case when a.offer_change_flag like '新增-全%'then 1 else 0 end) new_num2,
sum(case when a.offer_change_flag like '待新增-主成员%'then 1 else 0 end) new_num3, 
sum(case when a.offer_change_flag like '待新增-全%'then 1 else 0 end) new_num4, 
sum(case when a.offer_change_flag like '改装%' and a.offer_change_flag not like '改装-%->其他'then 1 else 0 end) change_num,
sum(case when a.offer_change_flag like '改装-%->单C%'then 1 else 0 end) change_amount1, 
sum(case when a.offer_change_flag like '改装-%->单宽%'then 1 else 0 end) change_amount2, 
sum(case when a.offer_change_flag like '改装-%->融合%'then 1 else 0 end) change_amount3, 
sum(case when a.offer_change_flag ='存量' or a.offer_change_flag like '待改%' then 1 else 0 end) exist_amount1, 
sum(case when a.offer_change_flag ='存量-主成员改装' then 1 else 0 end) exist_amount2, 
sum(case when a.offer_change_flag ='存量-改装' then 1 else 0 end) exist_amount3, 
sum(case when a.offer_change_flag ='存量-裸资费' then 1 else 0 end) exist_amount4,    
sum(case when a.offer_change_flag like '流失%'then 1 else 0 end) lost,
sum(case when a.offer_change_flag like '%其他'then 1 else 0 end) change_amount4 
          from hi_app_dc.app_prod_offer_03_END_3 a  
            where  offer_Id in (100010008323,
                      500000203,
                      100010004526,
                      100010003528,
                      500001607,
                      100010005216,
                      109040000010,
                      500000211,
                      100010008321,
                      100010005205,
                      100010007530,
                      100010008348)
         group by a.latn_id )t order by wssd">testvv.csv 

iconv -f UTF-8 -c  -t GBK testvv.csv > testbb.csv

select sum(offer_amount), latn_Id,count(1)
  from hi_app_dc.app_prod_offer_02_END_3 b
 where  offer_Id in (100010008323,
                      500000203,
                      100010004526,
                      100010003528,
                      500001607,
                      100010005216,
                      109040000010,
                      500000211,
                      100010008321,
                      100010005205,
                      100010007530,
                      100010008348)
 group by latn_Id order by latn_id
    

----取每种场景

---改套餐中1000以上的提供5个 实例 
hive -e "select concat_ws(',',cast(offer_id as string),regexp_replace(regexp_replace(offer_name, ',', '-'),',','-'),nvl(brand_type,''),
 cast(nvl(charge,0) as string),cast(nvl(last_offer_id,0) as string),
regexp_replace(regexp_replace(nvl(last_offer_name,''), ',', '-'),',','-'),offer_change_flag,
cast(cc_num as string),
cast(nvl(offer_amount,0) as string),cast(prod_inst_id as string),cast(nvl(last_offer_amount,0) as string)) cc
  from (select t.*,
       row_number() over(partition by t.offer_id, t.last_offer_id, t.offer_change_flag order by t.cc_num desc) rownum1
  from (select offer_id,
               offer_name,
               brand_type,
               nvl(charge, 0) charge,
               last_offer_id,
               last_offer_name,
               a.offer_change_flag,
               count(1) cc_num,
               sum(offer_amount) offer_amount,
               sum(last_offer_amount) last_offer_amount,prod_inst_id
          from hi_app_dc.app_prod_offer_03_END_3 a 
          -- where offer_change_flag like '改%'
         group by offer_id,
                  offer_name,
                  brand_type,
                  charge,
                  offer_change_flag,
                  last_offer_id,prod_inst_id,
                  last_offer_name ) t ) tt
 where rownum1 < 5">testvv.csv
 
 275003737109 
272072213524 
323074870288 
323024818548 
323058521110 
323077854462 
392040568591 
392072137147 
393081184696 


iconv -f UTF-8 -c  -t GBK testvv.csv > testbb.csv
