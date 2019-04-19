--取全量核心套餐 
DROP TABLE hi_app_dc.tmp_zlh_offer_temp;
create table hi_app_dc.tmp_zlh_offer_temp as
select R.*, B1.PRODUCTNAME, B1.BRAND_TYPE, B1.ISMAIN,B1.ISCOMBO,nvl(cast( B1.CHARGE as int),0)CHARGE
            from (select *
                    from hi_dm_dc.DM_IBSS_HUB_OFFER_PROD_INST_REL_M
                   where month_no_ = 201903
                   and datediff(exp_date,eff_date)>0
                   and datediff(offer_inst_exp_date,offer_inst_eff_date)>0) r
            join (select *
                   from hi_dim_dc.tmp_zlh_offer_group
                   where ismain=1) b1
                   on r.offer_id = b1.offer_id;  
---取上月新增的核心套餐 （包括2月 1日后生效的）
其他1        
固话10      =1
ITV 100     = 324
手机1000    = 75
宽带10000    in 36,37,67,69
term_type_id in(324,75,36,37,67,69)  

DROP TABLE hi_app_dc.tmp_zlh_offer_temp_1;
create table hi_app_dc.tmp_zlh_offer_temp_1 as
 select offer_inst_id,iscombo,
        sum(case
              when term_type_id in (36, 37, 67, 69) then
               10000
              when term_type_id = 75 then
               1000
              when term_type_id = 324 then
               100
              when term_type_id = 1 then
               10
              else
               1
            end) card_flag
   from (select prod_inst_id, offer_inst_id, term_type_id,iscombo
           FROM hi_app_dc.tmp_zlh_offer_temp
          where from_unixtime(unix_timestamp(exp_date), 'yyyyMM') > '201902'
              and not(prod_inst_status_cd != 100000 
                 and from_unixtime(unix_timestamp(prod_inst_stop_rent_date), 'yyyyMMdd')<20190301
                 and from_unixtime(unix_timestamp(prod_inst_status_date), 'yyyyMM') <201903)
                 and offer_id !=100010003012 --排除翼校通 
          group by prod_inst_id, offer_inst_id, term_type_id,iscombo) t
  group by offer_inst_id,iscombo;   
--1、取当月新增用户，主套餐取下个月最新套餐时间的那个；
drop table hi_app_dc.tmp_zlh_prod_offer;
create table hi_app_dc.tmp_zlh_prod_offer as
 select a.*,
         b.OFFER_INST_ID,
         b.OFFER_ID,
         b.OFFER_NAME,
         b.OFFER_INST_CREATE_DATE,
         b.offer_inst_eff_date,
         b.offer_inst_exp_date,
         b.OFFER_INST_STATUS_CD,
         b.CREATE_DATE            memb_create_date,
         b.EFF_DATE               memb_EFF_DATE,
         b.exp_date               memb_exp_date,
         b.status_cd memb_STATUS_CD,
         b.status_date       memb_status_date,
         b.productname,
         b.brand_type,
         b.iscombo,
         b.charge,b.card_flag
    from (select prod_inst_id,
                 acc_num,
                 prod_inst_state,
                 prod_inst_state_date,
                 first_finish_date prod_create_date,
                 zhufu_type,
                 prod_name,
                 term_type_id,
                 acct_id,
                 (case
                   when prod_inst_state != 110000 and
                        from_unixtime(unix_timestamp(create_date), 'yyyyMM') =
                        '201903' then
                    1 --新增
                   when prod_inst_state != 110000 and
                        from_unixtime(unix_timestamp(create_date), 'yyyyMM') <
                        '201903' then
                    2 --维系
                   when prod_inst_state = 110000 and
                        from_unixtime(unix_timestamp(prod_inst_state_date),
                                      'yyyyMM') = 201903 then
                    3 --当月流失
                   else
                    4
                 end) st_flag
            from hi_dm_dc.DM_IBSS_HUB_PRDINST_BASE_M
           where month_no_ = 201903
                 and from_unixtime(unix_timestamp(first_finish_date),
                                    'yyyyMM') = 201903) a
    join(select *
  from (select t.*,
               nvl(f.card_flag, 0) card_flag,
               row_number() over(partition by prod_inst_id order by t.iscombo desc, f.card_flag desc,
               nvl(charge,0) desc,OFFER_INST_CREATE_DATE desc) rownum1
          FROM hi_app_dc.tmp_zlh_offer_temp t
          left join hi_app_dc.tmp_zlh_offer_temp_1 f
            on t.offer_inst_id = f.offer_inst_id
         where from_unixtime(unix_timestamp(eff_date), 'yyyyMM') >= '201903'
           and from_unixtime(unix_timestamp(offer_inst_eff_date), 'yyyyMM') >=
               '201903'
           and exp_date>'2019-03-01' ---2月有当时拆的
           and offer_inst_exp_date>'2019-03-01') BBB
 where rownum1 = 1)b
      on a.prod_inst_id = b.prod_inst_id;
 --往月用户，套餐取当月生肖套餐 
insert into hi_app_dc.tmp_zlh_prod_offer
  select a.*,
         b.OFFER_INST_ID,
         b.OFFER_ID,
         b.OFFER_NAME,
         b.OFFER_INST_CREATE_DATE,
         b.offer_inst_eff_date,
         b.offer_inst_exp_date,
         b.OFFER_INST_STATUS_CD,
         b.CREATE_DATE            memb_create_date,
         b.EFF_DATE               memb_EFF_DATE,
         b.exp_date               memb_exp_date,
         b.status_cd              memb_STATUS_CD,
         b.status_date            memb_status_date,
         b.productname,
         b.brand_type,
         b.iscombo,
         b.charge,
         b.card_flag
    from (select prod_inst_id,
                 acc_num,
                 prod_inst_state,
                 prod_inst_state_date,
                 first_finish_date prod_create_date,
                 zhufu_type,
                 prod_name,
                 term_type_id,
                 acct_id,
                 (case
                   when prod_inst_state != 110000 and
                        from_unixtime(unix_timestamp(create_date), 'yyyyMM') =
                        '201903' then
                    1 --新增
                   when prod_inst_state != 110000 and
                        from_unixtime(unix_timestamp(create_date), 'yyyyMM') <
                        '201903' then
                    2 --维系
                   when prod_inst_state = 110000 and
                        from_unixtime(unix_timestamp(prod_inst_state_date),
                                      'yyyyMM') = 201903 then
                    3 --当月流失
                   else
                    4
                 end) st_flag
            from hi_dm_dc.DM_IBSS_HUB_PRDINST_BASE_M
           where month_no_ = 201903 
            and from_unixtime(unix_timestamp(first_finish_date), 'yyyyMM') < 201903
            and not (prod_inst_state != 100000 and
        from_unixtime(unix_timestamp(stop_rent_date), 'yyyyMM') < 201903 and
        from_unixtime(unix_timestamp(prod_inst_state_date), 'yyyyMM') <
        201903)) a    
       join (select *
            from (select t.*,
                         nvl(f.card_flag, 0) card_flag,
                         row_number() over(partition by prod_inst_id order by t.iscombo desc,
                         f.card_flag desc,nvl(charge,0) desc,OFFER_INST_CREATE_DATE desc) rownum1
                    FROM hi_app_dc.tmp_zlh_offer_temp t
                    left join hi_app_dc.tmp_zlh_offer_temp_1 f
                      on t.offer_inst_id = f.offer_inst_id
                   where from_unixtime(unix_timestamp(eff_date), 'yyyyMM') <=
                         '201903'
                     and from_unixtime(unix_timestamp(offer_inst_eff_date),
                                       'yyyyMM') <= '201903'
                     and exp_date>'2019-03-01' ---2月有当时拆的
                     and offer_inst_exp_date>'2019-03-01') BBB
           where rownum1 = 1) b
      on a.prod_inst_id = b.prod_inst_id;
--select * from hi_app_dc.tmp_zlh_prod_offer where prod_inst_id=103074943896 or offer_inst_id=109917953291
--如过主套餐订购了ITV :(510001678,109040000010,100010002411,100010002183，100010003528 )和（100010005216,500000529)
--则把套餐实例的offer_id和offer_name改成（100010005216,500000529)的
--100010005216 	WiFi宽带40元/月
---500000529 	WiFi宽带40元/月(2018)
DROP TABLE hi_app_dc.tmp_zlh_itv;
create table hi_app_dc.tmp_zlh_itv as
select *from (
select a.offer_id,
       a.offer_name,
       a.prod_inst_id,a.offer_inst_id,
       a.eff_date,
       a.exp_date, 
       b.offer_id            new_offer_id,
       b.offer_name          new_offer_name, 
       b.eff_date new_eff_date,
       b.exp_date new_exp_date,b.charge,
       row_number() over(partition by a.prod_inst_id order by a.iscombo desc,nvl(b.charge,0) desc, a.OFFER_INST_CREATE_DATE desc) rownum1
  from (select *
          from hi_app_dc.tmp_zlh_offer_temp a
         where offer_id in
               (510001678, 109040000010, 100010002411, 100010002183,100010003528)
           and from_unixtime(unix_timestamp(eff_date), 'yyyyMM') <= '201903'
           and from_unixtime(unix_timestamp(exp_date), 'yyyyMMdd') >'20190301'
           and from_unixtime(unix_timestamp(offer_inst_eff_date), 'yyyyMM') <='201903'
           and from_unixtime(unix_timestamp(offer_inst_exp_date), 'yyyyMMdd') >'20190301') a
  join (select prod_inst_id,offer_id,offer_name,eff_date,exp_date,charge
          from hi_app_dc.tmp_zlh_offer_temp b
         where offer_id in (100010005216, 500000529)
           and from_unixtime(unix_timestamp(eff_date), 'yyyyMM') <= '201903'
           and from_unixtime(unix_timestamp(exp_date), 'yyyyMMdd') >'20190301'
           and from_unixtime(unix_timestamp(offer_inst_eff_date), 'yyyyMM') <='201903'
           and from_unixtime(unix_timestamp(offer_inst_exp_date), 'yyyyMMdd') >'20190301') b
    on a.prod_inst_id = b.prod_inst_id) tt where rownum1=1; 
    
insert overwrite table hi_app_dc.tmp_zlh_prod_offer
select a.prod_inst_id,
       a.acc_num,
       a.prod_inst_state,
       a.prod_inst_state_date,
       a.prod_create_date,
       a.zhufu_type,
       a.prod_name,
       a.term_type_id,
       a.acct_id,
       a.st_flag,
       a.offer_inst_id,
       (case when b.prod_inst_id is not null and a.offer_id in (510001678, 109040000010, 100010002411, 100010002183,100010003528)
               then b.new_offer_id else a.offer_id end),
       (case when b.prod_inst_id is not null and a.offer_id in (510001678, 109040000010, 100010002411, 100010002183,100010003528)
            then b.new_offer_name else a.offer_name end),
       a.offer_inst_create_date,
       a.offer_inst_eff_date,
       a.offer_inst_exp_date,
       a.offer_inst_status_cd,
       a.memb_create_date,
       a.memb_eff_date,
       a.memb_exp_date,
       a.memb_status_cd,
       a.memb_status_date,
       a.productname,
       a.brand_type,
       a.iscombo,
       a.charge,a.card_flag
  from hi_app_dc.tmp_zlh_prod_offer a
   left join  hi_app_dc.tmp_zlh_itv b
   on a.prod_inst_id=b.prod_inst_id
   and a.offer_inst_id = b.offer_inst_id;
    
   select * from  hi_app_dc.tmp_zlh_offer_temp where prod_inst_id=823076004934;
   select * from  hi_app_dc.tmp_zlh_prod_offer where prod_inst_id=823076004934;
   select * from  hi_app_dc.tmp_zlh_itv where prod_inst_id=823076004934;
---2、上次主套餐

drop table hi_app_dc.app_prod_offer_03_1;
create table hi_app_dc.app_prod_offer_03_1 as
select t.prod_inst_id,t.acc_num,t.prod_inst_state,t.prod_inst_state_date,t.prod_create_date,
t.zhufu_type,t.prod_name,t.term_type_id,t.acct_id,t.st_flag,t.offer_inst_id,t.offer_id ,
t.offer_name ,t.offer_inst_create_date ,t.offer_inst_eff_date,t.offer_inst_exp_date,
t.offer_inst_status_cd ,t.memb_create_date ,t.memb_eff_date,t.memb_exp_date,t.memb_status_cd ,
t.memb_status_date ,t.productname,t.brand_type ,t.iscombo,t.charge ,t.card_flag,t.last_offer_inst_id ,
t.last_offer_id,t.last_offer_name,t.last_offer_create_date ,t.last_offer_eff_date,t.last_offer_exp_date,
t.last_offer_state ,t.last_memb_eff_date ,t.last_memb_exp_date ,t.last_memb_state,t.last_product_name,
t.last_brand_type,t.last_iscombo ,t.last_charge       
from( select a.*,
        b.OFFER_INST_ID last_OFFER_INST_ID,
        b.OFFER_ID  last_offer_id,
        b.OFFER_NAME last_offer_name,
        b.OFFER_INST_CREATE_DATE last_OFFER_CREATE_DATE,
        b.offer_inst_eff_date last_offer_eff_date,
        b.offer_inst_exp_date last_offer_exp_date,
        b.OFFER_INST_STATUS_CD last_offer_state,
        b.EFF_DATE               last_memb_EFF_DATE,
        b.exp_date               last_memb_exp_date,
        b.status_cd              last_memb_STAte,
        b.productname last_product_name,
        b.brand_type last_brand_type,
        b.iscombo last_iscombo,
        b.charge last_charge,
       row_number() over(partition by a.prod_inst_id order by b.exp_date desc,b.iscombo desc,b.OFFER_INST_CREATE_DATE desc,nvl(b.charge,0) desc) rownum1 
   from hi_app_dc.tmp_zlh_prod_offer a
    join (select t.* 
           FROM hi_app_dc.tmp_zlh_offer_temp t
          where from_unixtime(unix_timestamp(eff_date), 'yyyyMM') <'201903'
          and from_unixtime(unix_timestamp(exp_date), 'yyyyMMdd') <='20190301'
          and iscombo=1)b
     on a.prod_inst_id = b.prod_inst_id
     where datediff(a.memb_eff_date, b.exp_date)>-25 and datediff(a.memb_eff_date, b.exp_date)<25 
     ) 
     t where rownum1=1;
 
     
     
insert into  hi_app_dc.app_prod_offer_03_1
select t.prod_inst_id,t.acc_num,t.prod_inst_state,t.prod_inst_state_date,t.prod_create_date,
t.zhufu_type,t.prod_name,t.term_type_id,t.acct_id,t.st_flag,t.offer_inst_id,t.offer_id ,
t.offer_name ,t.offer_inst_create_date ,t.offer_inst_eff_date,t.offer_inst_exp_date,
t.offer_inst_status_cd ,t.memb_create_date ,t.memb_eff_date,t.memb_exp_date,t.memb_status_cd ,
t.memb_status_date ,t.productname,t.brand_type ,t.iscombo,t.charge ,t.card_flag,t.last_offer_inst_id ,
t.last_offer_id,t.last_offer_name,t.last_offer_create_date ,t.last_offer_eff_date,t.last_offer_exp_date,
t.last_offer_state ,t.last_memb_eff_date ,t.last_memb_exp_date ,t.last_memb_state,t.last_product_name,
t.last_brand_type,t.last_iscombo ,t.last_charge  from 
( select a.*,
        b.OFFER_INST_ID last_OFFER_INST_ID,
        b.OFFER_ID  last_offer_id,
        b.OFFER_NAME last_offer_name,
        b.OFFER_INST_CREATE_DATE last_OFFER_CREATE_DATE,
        b.offer_inst_eff_date last_offer_eff_date,
        b.offer_inst_exp_date last_offer_exp_date,
        b.OFFER_INST_STATUS_CD last_offer_state,
        b.EFF_DATE               last_memb_EFF_DATE,
        b.exp_date               last_memb_exp_date,
        b.status_cd              last_memb_STAte,
        b.productname last_product_name,
        b.brand_type last_brand_type,
        b.iscombo last_iscombo,
        b.charge last_charge,
       row_number() over(partition by a.prod_inst_id order by b.exp_date desc,b.iscombo desc,b.OFFER_INST_CREATE_DATE desc,nvl(a.charge,0) desc) rownum1 
   from hi_app_dc.tmp_zlh_prod_offer a
   left join  hi_app_dc.app_prod_offer_03_1 c
   on a.prod_inst_id=c.prod_inst_id
    join (select t.* 
           FROM hi_app_dc.tmp_zlh_offer_temp t
          where from_unixtime(unix_timestamp(eff_date), 'yyyyMM') <'201903'
          and from_unixtime(unix_timestamp(exp_date), 'yyyyMMdd') <='20190301'
          and iscombo=0)b
     on a.prod_inst_id = b.prod_inst_id
     where datediff(a.memb_eff_date, b.exp_date)>-25 and datediff(a.memb_eff_date, b.exp_date)<25
     and c.prod_inst_id is null
     ) t where rownum1=1;
     
 
insert into hi_app_dc.app_prod_offer_03_1
select a.*,null,null,null,null,null,null,null,null,null,null,null,null,null,null
from hi_app_dc.tmp_zlh_prod_offer a
where not exists(select 1 from hi_app_dc.app_prod_offer_03_1 b
where a.prod_inst_id=b.prod_inst_id);

select offer_id,offer_name,count(1) from hi_app_dc.app_prod_offer_03_1 where 
group by offer_id,offer_name
select count(1) from hi_app_dc.app_prod_offer_03_1 ;
select count(1) from hi_app_dc.app_prod_offer_1;


SELECT *FROM (
select a.offer_id,
       b.offer_id old_offer_id,
       from_unixtime(unix_timestamp(a.MEMB_EXP_DATE), 'yyyyMM'),
       from_unixtime(unix_timestamp(B.MEMB_EXP_DATE), 'yyyyMM'),
       a.offer_name, 
       b.offer_name old_offer_NAME,
       count(1)CC
  from hi_app_dc.tmp_zlh_prod_offer a
  join hi_app_dc.app_prod_offer_09_1 b
    on a.prod_inst_id = b.prod_inst_id
 where a.offer_inst_id != b.offer_inst_id
 group by a.offer_id,
          a.offer_name,
          b.offer_id,
          b.offer_name,
          from_unixtime(unix_timestamp(a.MEMB_EXP_DATE), 'yyyyMM'),
       from_unixtime(unix_timestamp(B.MEMB_EXP_DATE), 'yyyyMM'))TT WHERE TT.CC>100;       

 select count(1)
  from hi_app_dc.tmp_zlh_prod_offer a
  join hi_app_dc.app_prod_offer_09_1 b
    on a.prod_inst_id = b.prod_inst_id
 where a.offer_inst_id != b.offer_inst_id
 -- and from_unixtime(unix_timestamp(a.prod_create_date), 'yyyyMM')>201902
 and a.term_type_id in(324,75,36,37,67,69) limit 100; 
 
select a.prod_inst_id,a.acc_num,
       a.offer_id,
       a.offer_name,a.offer_inst_id,a.memb_eff_date,a.memb_exp_date,
       b.offer_id     old_offer_id,
       b.offer_name     old_offer_id,b.offer_inst_id,b.memb_eff_date,b.memb_exp_date
  from hi_app_dc.tmp_zlh_prod_offer a
  join hi_app_dc.app_prod_offer_09_1 b
    on a.prod_inst_id = b.prod_inst_id
 where a.offer_inst_id != b.offer_inst_id 
 and a.term_type_id in (75) 
 and from_unixtime(unix_timestamp(a.prod_create_date), 'yyyyMM')>201903
 and a.term_type_id in(324,75,36,37,67,69) limit 100; 
  

select from_unixtime(unix_timestamp(a.stop_rent_date), 'yyyyMM'),
       prod_inst_state,
       prod_inst_Id
  from hi_dm_dc.DM_IBSS_HUB_PRDINST_BASE_M a
 where month_no_ = 201903
   and term_type_id in (36, 37, 67, 69)
   and from_unixtime(unix_timestamp(a.stop_rent_date), 'yyyyMM') > 201902
   and not exists (select 1
          from hi_app_dc.tmp_zlh_prod_offer b
         where a.prod_inst_id = b.prod_inst_id) limit 5;
