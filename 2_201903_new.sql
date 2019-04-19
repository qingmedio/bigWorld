select count(1) from hi_app_dc.app_prod_offer_03_1;
select count(1) from hi_app_dc.app_prod_offer_09_1;

select * from hi_app_dc.app_prod_offer_03_1 where prod_inst_id=102026166773
 ---�п�����ҿ�� 
drop table hi_app_dc.app_prod_offer_03_2;
create table hi_app_dc.app_prod_offer_03_2 as
select a.*,b.prod_inst_id main_prod_inst_id,b.prod_create_date main_prod_create_date
  from hi_app_dc.app_prod_offer_03_1  a 
 join (select * from (select a1.*,
   row_number()over(partition by offer_inst_id order by prod_inst_state, prod_create_date) rownum1
 from hi_app_dc.app_prod_offer_03_1 a1
  where term_type_id in(36,37,67,69)) a2
  where rownum1=1)b
  on a.offer_inst_id=b.offer_inst_id;
 --û����������� (�����ж������һ��)
insert into  hi_app_dc.app_prod_offer_03_2 
select a.*,b.prod_inst_id main_prod_inst_id,b.prod_create_date main_prod_create_date
  from hi_app_dc.app_prod_offer_03_1  a 
  join (select prod_inst_id,prod_create_date,offer_inst_id,
  row_number()over(partition by offer_inst_id order by prod_inst_state,prod_create_date) rownum1
       from hi_app_dc.app_prod_offer_03_1 
  where zhufu_type=1 )b
  on a.offer_inst_id=b.offer_inst_id
  left join hi_app_dc.app_prod_offer_03_2  c
  on a.prod_inst_id=c.prod_inst_id
  where c.prod_inst_id is null
  and b.rownum1=1;
---�������������������ĸ� 
insert into  hi_app_dc.app_prod_offer_03_2 
select a.*,
       b.prod_inst_id     main_prod_inst_id,
       b.prod_create_date main_prod_create_date
  from hi_app_dc.app_prod_offer_03_1 a 
  join (select *
          from (select prod_inst_id,
                       prod_create_date,
                       offer_inst_id,
                       row_number() over(partition by offer_inst_id order by (case when term_type_id=75 then 0 else 1 end),
                       prod_inst_state ,prod_create_date) rownum1
                  from hi_app_dc.app_prod_offer_03_1) bb
         where bb.rownum1 = 1) b
    on a.offer_inst_id = b.offer_inst_id
  left join hi_app_dc.app_prod_offer_03_2 c
    on a.prod_inst_id = c.prod_inst_id
 where c.prod_inst_id is null;  
--�ں�1������2����C
drop table hi_app_dc.app_prod_offer_03_3;
create table hi_app_dc.app_prod_offer_03_3 as
select a.*,'�ں�' offer_type
  from hi_app_dc.app_prod_offer_03_2 a
 where iscombo=1
union all 
select * from (
select a.*,'����' offer_type
  from hi_app_dc.app_prod_offer_03_2 a
 where iscombo=0
 and not exists(select 1 from hi_app_dc.tmp_zlh_offer_temp b
 where a.offer_inst_id=b.offer_inst_id
 and from_unixtime(unix_timestamp(exp_date), 'yyyyMM') > '201902'
 and b.term_type_id=75)) aa
 where  exists(select 1 from hi_app_dc.tmp_zlh_offer_temp c
 where aa.offer_inst_id=c.offer_inst_id
 and from_unixtime(unix_timestamp(exp_date), 'yyyyMM') > '201902'
 and (c.term_type_id in(36,37,67,69)or c.prod_id ='880010007') ) 
union all 
select * from (
select a.*,'��C' offer_type
  from hi_app_dc.app_prod_offer_03_2 a
 where iscombo=0
 and not exists(select 1 from hi_app_dc.tmp_zlh_offer_temp b
 where a.offer_inst_id=b.offer_inst_id
 and from_unixtime(unix_timestamp(exp_date), 'yyyyMM') > '201902'
 and( b.term_type_id in(36,37,67,69)or b.prod_id ='880010007') )) aa
 where exists(select 1 from hi_app_dc.tmp_zlh_offer_temp c
 where aa.offer_inst_id=c.offer_inst_id
 and from_unixtime(unix_timestamp(exp_date), 'yyyyMM') > '201902'
 and c.term_type_id=75) ;
  
 insert into hi_app_dc.app_prod_offer_03_3
 select a.*,'����' from hi_app_dc.app_prod_offer_03_2 a
 left join hi_app_dc.app_prod_offer_03_3 b
 on a.prod_inst_id=b.prod_inst_id
 where b.prod_inst_id is null;
 --�ϴ��ײͱ�־ ��
 drop table hi_app_dc.app_prod_offer_03_4;
create table hi_app_dc.app_prod_offer_03_4 as
select a.*,'�ں�' last_offer_type
  from hi_app_dc.app_prod_offer_03_3 a
 where last_iscombo=1
union all 
select * from (
select a.*,'����' last_offer_type
  from hi_app_dc.app_prod_offer_03_3 a
 where last_iscombo=0
 and not exists(select 1 from hi_app_dc.tmp_zlh_offer_temp b
 where a.last_offer_inst_id=b.offer_inst_id
 and from_unixtime(unix_timestamp(exp_date), 'yyyyMM') > '201902'
 and b.term_type_id=75)) aa
 where  exists(select 1 from hi_app_dc.tmp_zlh_offer_temp c
 where aa.last_offer_inst_id=c.offer_inst_id
 and from_unixtime(unix_timestamp(exp_date), 'yyyyMM') > '201902'
 and (c.term_type_id in(36,37,67,69)or c.prod_id ='880010007') ) 
union all 
select * from (
select a.*,'��C' last_offer_type
  from hi_app_dc.app_prod_offer_03_3 a
 where last_iscombo=0
 and not exists(select 1 from hi_app_dc.tmp_zlh_offer_temp b
 where a.last_offer_inst_id=b.offer_inst_id
 and from_unixtime(unix_timestamp(exp_date), 'yyyyMM') > '201902'
 and( b.term_type_id in(36,37,67,69)or b.prod_id ='880010007') )) aa
 where exists(select 1 from hi_app_dc.tmp_zlh_offer_temp c
 where aa.last_offer_inst_id=c.offer_inst_id
 and from_unixtime(unix_timestamp(exp_date), 'yyyyMM') > '201902'
 and c.term_type_id=75) ;
 
 insert into hi_app_dc.app_prod_offer_03_4
 select a.*,'����' from hi_app_dc.app_prod_offer_03_3 a
 left join hi_app_dc.app_prod_offer_03_4 b
 on a.prod_inst_id=b.prod_inst_id
 where b.prod_inst_id is null; 
  
truncate table hi_app_dc.app_prod_offer_03_END ;
--1������-ȫ
INSERT INTO hi_app_dc.app_prod_offer_03_END 
select t.*,0,0 from (
select a.*,(case when a.iscombo=1 then '����-ȫ�ں�' else '����-ȫ��Ʒ' end)offer_change_flag
  from hi_app_dc.app_prod_offer_03_4 a
 where from_unixtime(unix_timestamp(a.prod_create_date), 'yyyyMM')= '201902'
   and from_unixtime(unix_timestamp(a.offer_inst_eff_date), 'yyyyMM') >='201902'      
   and not exists (select *
          from hi_app_dc.app_prod_offer_03_4 b
         where a.offer_inst_id = b.offer_inst_id
           and from_unixtime(unix_timestamp(b.prod_create_date),'yyyyMM') < '201902')
union all
select a.*,(case when a.iscombo=1 then '������-ȫ�ں�' else '������-ȫ��Ʒ' end)offer_change_flag
  from hi_app_dc.app_prod_offer_03_4 a
 where from_unixtime(unix_timestamp(a.prod_create_date), 'yyyyMM')= '201903'
   and from_unixtime(unix_timestamp(a.offer_inst_eff_date), 'yyyyMM') >='201903'      
   and not exists (select *
          from hi_app_dc.app_prod_offer_03_4 b
         where a.offer_inst_id = b.offer_inst_id
and from_unixtime(unix_timestamp(b.prod_create_date),'yyyyMM') < '201903')) t;
---2������-��
insert into hi_app_dc.app_prod_offer_03_END
select aa.* ,0,0 from (
select a.*,'����-����Ա' offer_change_flag
  from hi_app_dc.app_prod_offer_03_4 a
   where a.iscombo = 1 
 and from_unixtime(unix_timestamp(a.offer_inst_eff_date), 'yyyyMM') ='201902' 
 and from_unixtime(unix_timestamp(a.memb_eff_date), 'yyyyMM') ='201902'     
 and from_unixtime(unix_timestamp(a.main_prod_create_date), 'yyyyMM') ='201902'   )aa
 left join hi_app_dc.app_prod_offer_03_END b
 on aa.prod_inst_Id=b.prod_inst_id
 where b.prod_inst_id is null
 union all
  select aa.*,0,0
    from (select a.*, '������-����Ա' offer_change_flag
            from hi_app_dc.app_prod_offer_03_4 a
           where a.iscombo = 1
             and from_unixtime(unix_timestamp(a.offer_inst_eff_date),'yyyyMM') = '201903'
             and from_unixtime(unix_timestamp(a.memb_eff_date), 'yyyyMM') = '201903'
 and from_unixtime(unix_timestamp(a.main_prod_create_date), 'yyyyMM') ='201903' ) aa
   left join hi_app_dc.app_prod_offer_03_END b
   on aa.prod_inst_Id = b.prod_inst_id
   where b.prod_inst_id is null;
--����-�û�3���������ײ���ʷ
insert into hi_app_dc.app_prod_offer_03_END
select aa.*, 0, 0
  from (select a.*, '����-��װ�³�Ա' offer_change_flag
          from hi_app_dc.app_prod_offer_03_4 a
         where from_unixtime(unix_timestamp(a.offer_inst_eff_date),'yyyyMM') < '201902'
         and from_unixtime(unix_timestamp(a.offer_inst_create_date),'yyyyMM') < '201902'
           and from_unixtime(unix_timestamp(a.memb_eff_date), 'yyyyMM') >= '201903'
           and from_unixtime(unix_timestamp(a.prod_create_date),'yyyyMM') >= '201902') aa
   left join hi_app_dc.app_prod_offer_03_END b
   on aa.prod_inst_Id = b.prod_inst_id
   where b.prod_inst_id is null;
 --����-��������Ա�������ײͣ��û���ʷ���ײ���ʷ
insert into hi_app_dc.app_prod_offer_03_END
select p.*
  from (select aa.*, 0, 0
          from (select a.*, '����-����Ա��װ' offer_change_flag
                  from hi_app_dc.app_prod_offer_03_4 a
                 where from_unixtime(unix_timestamp(a.offer_inst_exp_date),
                                     'yyyyMM') >= '201903'
                 and from_unixtime(unix_timestamp(a.offer_inst_create_date),'yyyyMM') < '201902'
                   and from_unixtime(unix_timestamp(a.memb_exp_date),
                                     'yyyyMM') >= '201903'
                   and from_unixtime(unix_timestamp(a.prod_create_date),
                                     'yyyyMM') < '201902') aa
          join hi_app_dc.app_prod_offer_02_4 b
            on aa.prod_inst_Id = b.prod_inst_id
         and aa.prod_inst_Id = b.main_prod_inst_id
         where aa.offer_inst_id!=b.offer_inst_id) p
  left join hi_app_dc.app_prod_offer_03_END b
    on p.prod_inst_Id = b.prod_inst_id
 where b.prod_inst_id is null; 
---��ʧ 2�²����2�³�������ʧ��
--״̬������������Ա������
insert into hi_app_dc.app_prod_offer_03_END
  select a2.*,0,0
    from (select a1.*
            from (select a.*,
                         (case
                           when a.iscombo = 1 then
                            '��ʧ-�ں�'
                           else
                            '��ʧ-��Ʒ'
                         end) offer_change_flag
                    from hi_app_dc.app_prod_offer_03_4 a
                   where from_unixtime(unix_timestamp(a.offer_inst_create_date),
                                       'yyyyMM') < '201903'
                     and from_unixtime(unix_timestamp(a.offer_inst_exp_date),
                                       'yyyyMM') <= '201903'
                     and from_unixtime(unix_timestamp(a.memb_eff_date),
                                       'yyyyMM') <= '201903'
                     and from_unixtime(unix_timestamp(prod_inst_state_date),
                                       'yyyyMM') = '201903'
                     and prod_inst_state != 100000
                     and exists
                   (select 1
                            from hi_app_dc.app_prod_offer_03_4 b
                           where a.main_prod_inst_Id = b.prod_inst_Id
                             and b.prod_inst_state != 100000)) a1
           where not exists
           (select 1
                    from hi_app_dc.app_prod_offer_03_4 b
                   where a1.offer_inst_id = b.offer_inst_id
                     and b.prod_inst_state = 100000
                     and b.term_type_id in (36, 37, 67, 69))) a2
    left join hi_app_dc.app_prod_offer_03_END b
      on a2.prod_inst_Id = b.prod_inst_id
   where b.prod_inst_id is null; 
 --���������ײ�û�б仯��
insert into hi_app_dc.app_prod_offer_03_END
select p.*
  from (select aa.*, 0, 0
          from (select a.*, '����' offer_change_flag
                  from hi_app_dc.app_prod_offer_03_4 a) aa
           join hi_app_dc.app_prod_offer_02_4 b
            on aa.prod_inst_Id = b.prod_inst_id
           and aa.offer_inst_id = b.offer_inst_id) p
  left join hi_app_dc.app_prod_offer_03_END b
    on p.prod_inst_Id = b.prod_inst_id
 where b.prod_inst_id is null;
--����-�Ǻ�������Ա�������ײͣ��û���ʷ���ײ���ʷ
insert into hi_app_dc.app_prod_offer_03_END
select p.*
  from (select aa.*, 0, 0
          from (select a.*, '����-������Ա��װ' offer_change_flag
                  from hi_app_dc.app_prod_offer_03_4 a
                 where from_unixtime(unix_timestamp(a.offer_inst_exp_date),'yyyyMM') >= '201903'
                   and from_unixtime(unix_timestamp(a.memb_exp_date), 'yyyyMM') >= '201903'
                   and from_unixtime(unix_timestamp(a.prod_create_date),'yyyyMM') < '201902') aa
          join hi_app_dc.app_prod_offer_02_4 b
            on aa.prod_inst_Id = b.prod_inst_id
           where aa.offer_inst_Id != b.offer_inst_id
         and aa.prod_inst_id != b.main_prod_inst_id) p
  left join hi_app_dc.app_prod_offer_03_END b
    on p.prod_inst_Id = b.prod_inst_id
 where b.prod_inst_id is null;
--21��װ
insert into hi_app_dc.app_prod_offer_03_END
  select aa.*,0,0
    from (select a.*,
                 concat('��װ-', last_offer_type, '->',offer_type) offer_change_flag
            from hi_app_dc.app_prod_offer_03_4 a
           where from_unixtime(unix_timestamp(a.offer_inst_create_date),
                               'yyyyMM') = '201902'
             and from_unixtime(unix_timestamp(a.offer_inst_eff_date),
                               'yyyyMM') >= '201902'
             and from_unixtime(unix_timestamp(a.memb_create_date), 'yyyyMM') =
                 '201902'
             and from_unixtime(unix_timestamp(a.memb_eff_date), 'yyyyMM') >=
                 '201902'
             and last_offer_inst_id is not null) aa
left join hi_app_dc.app_prod_offer_03_END b
on aa.prod_inst_Id = b.prod_inst_id
where b.prod_inst_id is null;
--21 ��c��>��c  ����������ͬһ�û�
insert into hi_app_dc.app_prod_offer_03_end
  select aa.*,0,0
    from (select a.*,
                 concat('����װ-',last_offer_type,'->', offer_type) offer_change_flag
            from hi_app_dc.app_prod_offer_03_4 a
           where from_unixtime(unix_timestamp(a.offer_inst_create_date),
                               'yyyyMM') = '201903'
             and from_unixtime(unix_timestamp(a.offer_inst_eff_date),
                               'yyyyMM') >= '201903'
             and from_unixtime(unix_timestamp(a.memb_create_date), 'yyyyMM') =
                 '201903'
             and from_unixtime(unix_timestamp(a.memb_eff_date), 'yyyyMM') >=
                 '201903'
             and last_offer_inst_id is not null) aa
left join hi_app_dc.app_prod_offer_03_end b
on aa.prod_inst_Id = b.prod_inst_id
where b.prod_inst_id is null;
---�ϸ���û�к����ײͣ��������
insert into hi_app_dc.app_prod_offer_03_END
select aa.*,'����-�ϸ����ޱ�����',0,0 from(
select a.*
  from hi_app_dc.app_prod_offer_03_4 a
  left join hi_app_dc.app_prod_offer_03_END b
    on a.prod_inst_id = b.prod_inst_id
 where b.prod_inst_id is null 
 and a.memb_eff_date>=a.offer_inst_eff_date )aa
 left join hi_app_dc.app_prod_offer_02_4 b
 on aa.prod_inst_Id=b.prod_inst_id
 where b.prod_inst_id is null;   
---���������ײ�ID����,���ϸ��µ����ײ�ʵ����������µ��ײͿǲ�������--�������
insert into hi_app_dc.app_prod_offer_03_END
select p.*,'����-��װ',0,0
  from (select a.*
          from hi_app_dc.app_prod_offer_03_4 a
          join (select *
                 from hi_app_dc.app_prod_offer_02_4 bb
                where exists (select 1
                         from hi_app_dc.tmp_zlh_offer_temp c
                      where from_unixtime(unix_timestamp(c.offer_inst_exp_date),'yyyyMMdd') <= '20190301'
                          and bb.offer_inst_id = c.offer_inst_id
                          and bb.prod_inst_id = c.prod_inst_id)) b
            on a.prod_inst_Id = b.prod_inst_id
         where a.offer_inst_id != b.offer_inst_id
           and from_unixtime(unix_timestamp(a.offer_inst_eff_date), 'yyyyMM') <
               '201903'
           and a.memb_eff_date >= a.offer_inst_eff_date) p
  left join hi_app_dc.app_prod_offer_03_END b
    on p.prod_inst_Id = b.prod_inst_id
 where b.prod_inst_id is null; 
--4.�ײ�IDʧЧ,��������Ա״̬������û�ж����κ����ײ�(��ʧ)���ʷ�
insert into hi_app_dc.app_prod_offer_03_END
select prod.*,
       a.offer_inst_id,
       a.offer_id,
       a.offer_name,
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
       a.charge,
       null,
       a.offer_inst_id,
       a.offer_id,
       a.offer_name,
       a.offer_inst_create_date,
       a.offer_inst_eff_date,
       a.offer_inst_exp_date,
       a.offer_inst_status_cd,
       a.memb_eff_date,
       a.memb_exp_date,
       a.memb_status_cd,
       a.productname,
       a.brand_type,
       a.iscombo,
       a.charge,
       a.main_prod_inst_id,
       a.main_prod_create_date,
       a.offer_type,
       null,
       '����-���ʷ�',
       0,
       0
  from (select a1.*
          from hi_app_dc.app_prod_offer_02_4 a1
          left join hi_app_dc.app_prod_offer_03_4 a2
            on a1.prod_inst_Id = a2.prod_inst_id
         where a2.offer_inst_id is null) a
  join (select prod_inst_id,
               acc_num,
               prod_inst_state,
               prod_inst_state_date,
               first_finish_date    prod_create_date,
               zhufu_type,
               prod_name,
               term_type_id,
               acct_id,
               2                    st_flag
          from hi_dm_dc.DM_IBSS_HUB_PRDINST_BASE_M
         where month_no_ = 201903
           and prod_inst_state = 100000) prod
    on a.prod_inst_id = prod.prod_inst_id
  left join hi_app_dc.app_prod_offer_03_END b
    on a.prod_inst_Id = b.prod_inst_id
 where b.prod_inst_id is null;      
insert into hi_app_dc.app_prod_offer_03_END
  select a.*,'����-����',0,0
    from hi_app_dc.app_prod_offer_03_4 a
left join hi_app_dc.app_prod_offer_03_END b
on a.prod_inst_Id = b.prod_inst_id
where b.prod_inst_id is null; 


select aa.* from(
select a.*
  from hi_app_dc.app_prod_offer_03_4 a
  left join hi_app_dc.app_prod_offer_03_END b
    on a.prod_inst_id = b.prod_inst_id
 where b.prod_inst_id is null 
 and a.memb_eff_date >=a.offer_inst_eff_date )aa
   join hi_app_dc.app_prod_offer_02_4 b
 on aa.prod_inst_Id=b.prod_inst_id limit 5;
 
select prod_inst_id,count(1) from hi_app_dc.app_prod_offer_03_END group by prod_inst_id having count(1)>1 limit 5;;
select count(1),offer_change_flag from hi_app_dc.app_prod_offer_03_END group by offer_change_flag order by offer_change_flag;

select offer_inst_id from(
select count(1),offer_inst_id,
offer_change_flag from hi_app_dc.app_prod_offer_03_END group by offer_change_flag,offer_inst_id)tt
group by offer_inst_id having count(1)>1 limit 5;;
  
select 2,prod_inst_id,offer_id,offer_name,offer_inst_id,memb_eff_date,memb_exp_date,offer_inst_eff_date,offer_inst_exp_date
 from hi_app_dc.app_prod_offer_02_4 where offer_inst_id in(109201537324)
  union all 
select 3,prod_inst_id,offer_id,offer_name,offer_inst_id,memb_eff_date,memb_exp_date,offer_inst_eff_date,offer_inst_exp_date
 from hi_app_dc.app_prod_offer_03_4 where prod_inst_id in(109201537324)


 
 select * from hi_app_dc.app_prod_offer_03_END  where  offer_inst_id in(109201537324)  

--���1
--
select offer_inst_id from (
select offer_inst_id,offer_change_type from hi_app_dc.app_prod_offer_03_END where offer_change_type like '%����%'
group by offer_inst_id,offer_change_type) aa group by offer_inst_id limit 5;
  

---������
hive -e "select concat_ws(',',
                 cast(prod_inst_id as string),
                 cast(offer_inst_id as string),
                 cast(offer_id as string),
                 regexp_replace(regexp_replace(offer_name, ',', '-'),
                                ',',
                                '-'),
                 nvl(cast(iscombo as string), '-'),
                 nvl(offer_type, '-'),
                 nvl(cast(last_offer_id as string), '-'),
                 nvl(regexp_replace(regexp_replace(last_offer_name, ',', '-'),
                                    ',',
                                    '-'),
                     '-'),
                 nvl(cast(last_iscombo as string), '-'),
                 nvl(last_offer_type, '-'),
                 nvl(offer_change_flag, '-')) wsd
  from (select a.prod_inst_id,
               a.offer_inst_id,
               a.offer_id,
               a.offer_name,
               a.iscombo,
               a.offer_type,
               a.last_offer_id,
               a.last_offer_name,
               a.last_iscombo,
               a.last_offer_type,
               a.offer_change_flag,
               row_number() over(partition by a.offer_change_flag) rownum1
          from hi_app_dc.app_prod_offer_03_end a
            join (select main_prod_inst_id from hi_app_dc.app_prod_offer_03_end
group by main_prod_inst_id)      b
            on a.prod_inst_id = b.main_prod_inst_id
         where a.offer_change_flag is not null) tt
 where rownum1 < 51
">testvv.csv

iconv -f UTF-8 -c  -t GBK testvv.csv > testbb.csv  
