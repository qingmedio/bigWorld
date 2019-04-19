--1�������ʧ�ʹ��������õĵ�ǰ���ײ�ID�ͳ�Աȡ �ϸ��µ��ײͷѣ�
--2���������������ȡ�ϸ��£�����ͬ1
--3������Ǹ�װ�����ϸ����ײ�ID�����ϸ��µĳ�Ա��ȡ�ϸ����ײͷ�
select count(1) from hi_app_dc.app_prod_offer_03_END_1; 
select count(1) from hi_app_dc.app_prod_offer_03_END_2;
drop table hi_app_dc.app_prod_offer_03_END_2;
drop table hi_app_dc.app_prod_offer_03_END_3;
create table hi_app_dc.app_prod_offer_03_END_2 as
select p.*,a.amount offer_amount,b.amount last_offer_amount
 from (select * from hi_app_dc.app_prod_offer_03_END_1 where offer_change_flag not like '��װ%') p
  left  join (select f1.offer_inst_id, sum(nvl(f2.amount,0)) amount
                 from hi_app_dc.app_prod_offer_03_4 f1
                 join hi_app_dc.app_prod_offer_income_03 f2
                   on f1.prod_inst_id = f2.prod_inst_id
                group by f1.offer_inst_id) a
        on p.offer_inst_id=a.offer_inst_id
    left join (select t1.offer_inst_id, sum(nvl(t2.amount,0))  amount
                 from hi_app_dc.app_prod_offer_02_4 t1
                 join hi_app_dc.app_prod_offer_income_02 t2
                   on t1.prod_inst_id = t2.prod_inst_id
                group by t1.offer_inst_id) b
      on p.offer_inst_id = b.offer_inst_id
union all
select p.*,a.amount offer_amount,b.amount last_offer_amount
 from (select * from hi_app_dc.app_prod_offer_03_END_1 where offer_change_flag like '��װ%') p
   left join (select f1.offer_inst_id, sum(nvl(f2.amount,0)) amount
                 from hi_app_dc.app_prod_offer_03_4 f1
                 join hi_app_dc.app_prod_offer_income_03 f2
                   on f1.prod_inst_id = f2.prod_inst_id
                group by f1.offer_inst_id) a
        on p.offer_inst_id=a.offer_inst_id
    left join (select t1.offer_inst_id, sum(nvl(t2.amount,0))  amount
                 from hi_app_dc.app_prod_offer_02_4 t1
                 join hi_app_dc.app_prod_offer_income_02 t2
                   on t1.prod_inst_id = t2.prod_inst_id
                group by t1.offer_inst_id) b
      on p.last_offer_inst_id = b.offer_inst_id;   
--ȡ�û���ʡ�ķ���

create table hi_app_dc.app_prod_offer_03_END_3 as
select p.*,a.amount prod_amount,b.amount last_prod_amount,c.latn_id
 from hi_app_dc.app_prod_offer_03_END_2 p 
    left join (select f.prod_inst_id, sum(nvl(f.amount,0)) amount
                 from hi_app_dc.app_prod_offer_income_03 f 
                group by f.prod_inst_id) a
        on p.prod_inst_id=a.prod_inst_id
    left join (select t.prod_inst_id, sum(nvl(t.amount,0))  amount
                 from hi_app_dc.app_prod_offer_income_02 t
                group by t.prod_inst_id) b
      on p.prod_inst_id = b.prod_inst_id
      left join (select max(latn_id_) latn_id,offer_inst_id from hi_app_dc.tmp_zlh_offer_temp
group by offer_inst_id) c
on p.offer_inst_id=c.offer_inst_id;
 
select count(1) from hi_app_dc.app_prod_offer_03_END_1; 
select count(1) from hi_app_dc.app_prod_offer_03_END_2;
select count(1) from hi_app_dc.app_prod_offer_03_END_3;
 select count(1),sum(offer_amount) ,offer_change_flag from hi_app_dc.app_prod_offer_03_END_3 
 group by offer_change_flag order by offer_change_flag;
 --�����ϼ�	��0-10��	(10-20��	��3-50��	50����

drop table  hi_app_dc.app_prod_offer_03_END;
create table  hi_app_dc.app_prod_offer_03_END as  
select t.*, nvl((case when diff_amount>50 then '��>50'
when diff_amount<=50 and diff_amount>20 then '��(20-50]'
when diff_amount<=20 and diff_amount>10 then '��(10-20]'
when diff_amount<=10 and diff_amount>0 then '��(0-10]' 
when diff_amount<-50 then '��>50'
when diff_amount>=-50 and diff_amount<-20 then '��(20-50]'
when diff_amount>=-20 and diff_amount<-10 then '��(10-20]'
when diff_amount>=-10 and diff_amount<0 then '��(0-10]'
  else 'άϵ' end ),'άϵ')offer_change_type1
from(select a.*,nvl(a.offer_amount,0)-(case when offer_change_flag='��װ-����->��C' then 0 else nvl(a.last_offer_amount,0) end) diff_amount  
from  hi_app_dc.app_prod_offer_03_END_3 a
where offer_change_flag like '����%' or offer_change_flag like '��װ%')t
union all
select a.*,null,null  from  hi_app_dc.app_prod_offer_03_END_3 a
where offer_change_flag like '%����%' or offer_change_flag like '��ʧ%'
or  offer_change_flag  ='����'; 

hive -e "select concat_ws(',',latn_id,cast(cur_amount as string),'0','0',
cast(new_amount as string),
cast(new_amount1 as string),
cast(new_amount2 as string),
cast(new_amount3 as string),
cast(new_amount4 as string),
cast(change_amount as string),
cast(change_amount1 as string),
cast(change_amount11 as string),
cast(change_amount2 as string),
cast(change_amount22 as string),
cast(change_amount3 as string),
cast(change_amount33 as string),
cast(exist_amount as string),
cast(exist_amount1 as string),
cast(exist_amount11 as string),
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
       change_amount11,
       change_amount2,
       change_amount22,
       change_amount3,
       change_amount33, change_amount4,
       exist_amount,exist_amount1,exist_amount11,exist_amount20,exist_amount2,
       exist_amount3,exist_amount4,exist_amount22,
       lost_amount1,lost_amount11
  from (select a.latn_id,sum(a.offer_amount)cur_amount,
  sum(case when a.offer_change_flag like '%����%'then a.offer_amount else 0 end) new_amount,
sum(case when a.offer_change_flag like '����-����Ա%'then a.offer_amount else 0 end) new_amount1,
sum(case when a.offer_change_flag like '����-ȫ%'then a.offer_amount else 0 end) new_amount2,
sum(case when a.offer_change_flag like '������-����Ա%'then a.offer_amount else 0 end) new_amount3,
sum(case when a.offer_change_flag like '������-ȫ%'then a.offer_amount else 0 end) new_amount4,
sum(case when a.offer_change_flag like '��װ%' and a.offer_change_flag not like '��װ-%->����' then a.offer_amount else 0 end) change_amount,
sum(case when a.offer_change_flag like '��װ-%->��C%'then a.offer_amount else 0 end) change_amount1,
sum(case when a.offer_change_flag like '��װ-%->��C%'then nvl(a.diff_amount,0) else 0 end) change_amount11,
sum(case when a.offer_change_flag like '��װ-%->����%'then a.offer_amount else 0 end) change_amount2,
sum(case when a.offer_change_flag like '��װ-%->����%'then nvl(a.diff_amount,0) else 0 end) change_amount22,
sum(case when a.offer_change_flag like '��װ-%->�ں�%'then a.offer_amount else 0 end) change_amount3,
sum(case when a.offer_change_flag like '��װ-%->�ں�%'then nvl(a.diff_amount,0) else 0 end) change_amount33,
sum(case when a.offer_change_flag like '����%'then a.offer_amount else 0 end) exist_amount,
sum(case when a.offer_change_flag ='����'or a.offer_change_flag like '����%' then a.offer_amount else 0 end) exist_amount1,
sum(case when a.offer_change_flag ='����'or a.offer_change_flag like '����%' then nvl(diff_amount,0) else 0 end) exist_amount11,
sum(case when a.offer_change_flag like '����-%'then nvl(a.offer_amount,0) else 0 end) exist_amount20,
sum(case when a.offer_change_flag like '����-����Ա��װ'then nvl(a.offer_amount,0) else 0 end) exist_amount2, 
sum(case when a.offer_change_flag like '����-��װ'then nvl(a.offer_amount,0) else 0 end) exist_amount3, 
sum(case when a.offer_change_flag like '����-���ʷ�'then nvl(a.offer_amount,0) else 0 end) exist_amount4, 
sum(case when a.offer_change_flag like '����-%'then nvl(a.last_offer_amount,0) else 0 end) exist_amount22,
sum(case when a.offer_change_flag like '��ʧ%'then a.offer_amount else 0 end) lost_amount1,
sum(case when a.offer_change_flag like '��ʧ%'then nvl(a.last_offer_amount,0) else 0 end) lost_amount11,
sum(case when a.offer_change_flag like '%����'then nvl(a.offer_amount,0) else 0 end) change_amount4
          from hi_app_dc.app_prod_offer_03_END a   
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
 select a.latn_id,count(1) all_num,sum(case when a.offer_change_flag like '%����%'then 1 else 0 end) new_num,
sum(case when a.offer_change_flag like '����-����Ա%'then 1 else 0 end) new_num1, 
sum(case when a.offer_change_flag like '����-ȫ%'then 1 else 0 end) new_num2,
sum(case when a.offer_change_flag like '������-����Ա%'then 1 else 0 end) new_num3, 
sum(case when a.offer_change_flag like '������-ȫ%'then 1 else 0 end) new_num4, 
sum(case when a.offer_change_flag like '��װ%' and a.offer_change_flag not like '��װ-%->����'then 1 else 0 end) change_num,
sum(case when a.offer_change_flag like '��װ-%->��C%'then 1 else 0 end) change_amount1, 
sum(case when a.offer_change_flag like '��װ-%->����%'then 1 else 0 end) change_amount2, 
sum(case when a.offer_change_flag like '��װ-%->�ں�%'then 1 else 0 end) change_amount3, 
sum(case when a.offer_change_flag ='����' or a.offer_change_flag like '����%' then 1 else 0 end) exist_amount1, 
sum(case when a.offer_change_flag ='����-����Ա��װ' then 1 else 0 end) exist_amount2, 
sum(case when a.offer_change_flag ='����-��װ' then 1 else 0 end) exist_amount3, 
sum(case when a.offer_change_flag ='����-���ʷ�' then 1 else 0 end) exist_amount4,    
sum(case when a.offer_change_flag like '��ʧ%'then 1 else 0 end) lost,
sum(case when a.offer_change_flag like '%����'then 1 else 0 end) change_amount4 
          from hi_app_dc.app_prod_offer_03_END_3 a   
         group by a.latn_id )t order by wssd">testvv.csv 

iconv -f UTF-8 -c  -t GBK testvv.csv > testbb.csv
