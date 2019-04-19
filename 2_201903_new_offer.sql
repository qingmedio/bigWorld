create table  hi_app_dc.app_prod_offer_03_END_1 as
select * from  hi_app_dc.app_prod_offer_03_END where 1=2;
select * from hi_app_dc.app_prod_offer_03_end_1 
where offer_change_flag='��װ-�ں�->����' limit 5;
select * from hi_app_dc.app_prod_offer_03_end_1 
where prod_inst_id=273097979732 limit 5;
   select* from  hi_app_dc.app_prod_offer_03_4 where prod_inst_id=102017016958
--�����2�µ���3�����ײͱ���ˣ���3�����ײ��Ƿ����2�µ����ײ�
truncate table hi_app_dc.app_prod_offer_03_5;
insert into hi_app_dc.app_prod_offer_03_5
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
         a.card_flag,
         b.offer_inst_id,
         c.offer_id,
         c.offer_name,
         c.offer_inst_create_date,
         c.offer_inst_eff_date,
         c.offer_inst_exp_date,
         c.offer_inst_status_cd,
         c.eff_date,
         c.exp_date,
         c.status_cd,
         c.productname,
         c.brand_type,
         c.iscombo,
         c.charge,
         a.main_prod_inst_id,
         a.main_prod_create_date,
         a.offer_type,
         b.offer_type,
         b.main_prod_inst_id
    from hi_app_dc.app_prod_offer_03_4 a
    join hi_app_dc.app_prod_offer_02_4 b
      on a.prod_inst_id = b.prod_inst_id
    left join (select * from(select offer_id,
                 offer_name,
                 offer_inst_create_date,
                 offer_inst_eff_date,
                 offer_inst_exp_date,
                 offer_inst_status_cd,
                 eff_date,
                 exp_date,
                 status_cd,
                 productname,
                 brand_type,
                 iscombo,
                 charge,
                 offer_inst_id,
                 prod_inst_id,
                 row_number() over(partition by offer_inst_id, prod_inst_id order by offer_inst_create_date desc) rownum1
            from hi_app_dc.tmp_zlh_offer_temp
           group by offer_id,
                 offer_name,
                 offer_inst_create_date,
                 offer_inst_eff_date,
                 offer_inst_exp_date,
                 offer_inst_status_cd,
                 eff_date,
                 exp_date,
                 status_cd,
                 productname,
                 brand_type,
                 iscombo,
                 charge,
                 offer_inst_id,
                 prod_inst_id)t1 where rownum1 = 1) c
      on b.prod_inst_id = c.prod_inst_id
     and b.offer_inst_id = c.offer_inst_id
   where from_unixtime(unix_timestamp(a.offer_inst_eff_date), 'yyyyMM') >= '201902' 
     and from_unixtime(unix_timestamp(a.memb_create_date), 'yyyyMM') ='201902'
     and from_unixtime(unix_timestamp(a.prod_create_date), 'yyyyMM') <'201902'
   and nvl(a.last_offer_inst_id,0) != nvl(b.offer_inst_id,1);
 --ȡ���µ��ϴ����ײ��� ��Ա=�������ײ͵�
insert into hi_app_dc.app_prod_offer_03_5
  select a.*, b.main_prod_inst_id last_main_prod_inst_Id
    from hi_app_dc.app_prod_offer_03_4 a
    left join (select offer_inst_id, main_prod_inst_id
                 from hi_app_dc.app_prod_offer_02_4
                group by offer_inst_id, main_prod_inst_id) b
      on a.last_offer_inst_Id = nvl(b.offer_inst_id,0)
      left join hi_app_dc.app_prod_offer_03_5 c
      on a.prod_inst_id=c.prod_inst_id
      where c.prod_inst_id is null
      and a.last_offer_inst_Id is not null;
 --���¸��˵ģ� select count(1) from hi_app_dc.app_prod_offer_03_END_1 where last_offer_inst_id is not null;
  select count(1) from hi_app_dc.app_prod_offer_03_END_1 where last_offer_inst_id is not null
  and from_unixtime(unix_timestamp(offer_inst_eff_date), 'yyyyMM') > '201902'
  and from_unixtime(unix_timestamp(memb_eff_date), 'yyyyMM') > '201902'
  union all 
  select count(1) from hi_app_dc.app_prod_offer_03_END_1 where last_main_prod_inst_id is not null

  select a.*, b.main_prod_inst_id last_main_prod_inst_Id
    from hi_app_dc.app_prod_offer_03_4 a
    left join (select offer_inst_id, main_prod_inst_id
                 from hi_app_dc.app_prod_offer_02_4
                group by offer_inst_id, main_prod_inst_id) b
      on a.last_offer_inst_Id = b.offer_inst_id 
      where a.prod_inst_id=342066046235
      and a.last_offer_inst_Id is not null;
      
insert into hi_app_dc.app_prod_offer_03_5
  select a.*, null last_main_prod_inst_Id
    from hi_app_dc.app_prod_offer_03_4 a
    left join hi_app_dc.app_prod_offer_03_5 c
      on a.prod_inst_id=c.prod_inst_id
      where c.prod_inst_id is null;

select count(1) from hi_app_dc.app_prod_offer_03_4;
select count(1),prod_inst_id from hi_app_dc.app_prod_offer_03_5
group by prod_inst_id having count(1)>1 limit 5;

truncate table hi_app_dc.app_prod_offer_03_END_1 ;
--1������-ȫ
INSERT INTO hi_app_dc.app_prod_offer_03_END_1 
select t.* from (
select a.*,(case when a.iscombo=1 then '����-ȫ�ں�' else '����-ȫ��Ʒ' end)offer_change_flag
  from hi_app_dc.app_prod_offer_03_5 a
 where from_unixtime(unix_timestamp(a.prod_create_date), 'yyyyMM')= '201902'
 and from_unixtime(unix_timestamp(a.memb_eff_date), 'yyyyMM') >='201902'
 and from_unixtime(unix_timestamp(a.offer_inst_eff_date), 'yyyyMM') >='201902'  
   and a.prod_inst_Id=a.main_prod_inst_Id
   and not exists (select *
          from hi_app_dc.app_prod_offer_03_4 b
         where a.offer_inst_id = b.offer_inst_id
           and from_unixtime(unix_timestamp(b.prod_create_date),'yyyyMM') < '201902')
union all
select a.*,(case when a.iscombo=1 then '������-ȫ�ں�' else '������-ȫ��Ʒ' end)offer_change_flag
  from hi_app_dc.app_prod_offer_03_5 a
 where from_unixtime(unix_timestamp(a.prod_create_date), 'yyyyMM')= '201903'
 and from_unixtime(unix_timestamp(a.memb_eff_date), 'yyyyMM') >='201903'
 and from_unixtime(unix_timestamp(a.offer_inst_eff_date), 'yyyyMM') >='201903' 
   and a.prod_inst_Id=a.main_prod_inst_Id
   and not exists (select *
          from hi_app_dc.app_prod_offer_03_4 b
         where a.offer_inst_id = b.offer_inst_id
and from_unixtime(unix_timestamp(b.prod_create_date),'yyyyMM') < '201903')) t;
---2������-��
insert into hi_app_dc.app_prod_offer_03_END_1
select aa.*  from (
select a.*,'����-����Ա' offer_change_flag
  from hi_app_dc.app_prod_offer_03_5 a
   where a.prod_inst_Id=a.main_prod_inst_Id
 and from_unixtime(unix_timestamp(a.offer_inst_eff_date), 'yyyyMM') >='201902' 
 and from_unixtime(unix_timestamp(a.memb_eff_date), 'yyyyMM') >='201902'     
 and from_unixtime(unix_timestamp(a.main_prod_create_date), 'yyyyMM') ='201902'   )aa
 left join hi_app_dc.app_prod_offer_03_END_1 b
 on aa.prod_inst_Id=b.prod_inst_id
 where b.prod_inst_id is null
 union all
  select aa.*
    from (select a.*, '������-����Ա' offer_change_flag
            from hi_app_dc.app_prod_offer_03_5 a
           where a.prod_inst_Id=a.main_prod_inst_Id
             and from_unixtime(unix_timestamp(a.offer_inst_eff_date),'yyyyMM') >= '201903'
             and from_unixtime(unix_timestamp(a.memb_eff_date), 'yyyyMM') >= '201903'
 and from_unixtime(unix_timestamp(a.main_prod_create_date), 'yyyyMM') ='201903' ) aa
   left join hi_app_dc.app_prod_offer_03_END_1 b
   on aa.offer_inst_Id = b.offer_inst_Id
   where b.offer_inst_Id is null;
--������������ǲ��Ƕ�����--11�����쳣���ݻ��߸����
select a.*, '������-����Ա' offer_change_flag
            from hi_app_dc.app_prod_offer_03_5 a
            where term_type_id in(36,37,67,69)
            and from_unixtime(unix_timestamp(a.prod_create_date), 'yyyyMM')>= '201902'
            and not exists(select 1 from hi_app_dc.app_prod_offer_03_END_1 b
            where a.prod_inst_id=b.prod_inst_id) limit 5;
---��ʧ 2�²����2�³�������ʧ��
--״̬������������Ա������
insert into hi_app_dc.app_prod_offer_03_END_1
  select a2.*
    from (select a1.*
            from (select a.*,
                         (case
                           when a.iscombo = 1 then
                            '��ʧ-�ں�'
                           else
                            '��ʧ-��Ʒ'
                         end) offer_change_flag
                    from hi_app_dc.app_prod_offer_03_5 a
                   where from_unixtime(unix_timestamp(a.offer_inst_create_date),
                                       'yyyyMM') < '201903'
                     and from_unixtime(unix_timestamp(a.offer_inst_exp_date),
                                       'yyyyMM') <= '201903'
                     and from_unixtime(unix_timestamp(a.memb_eff_date),
                                       'yyyyMM') <= '201903'
                     and a.prod_inst_Id=a.main_prod_inst_Id
                     and from_unixtime(unix_timestamp(prod_inst_state_date),
                                       'yyyyMM') = '201903'
                     and prod_inst_state != 100000) a1
           where not exists
           (select 1
                    from hi_app_dc.app_prod_offer_03_5 b
                   where a1.offer_inst_id = b.offer_inst_id
                     and b.prod_inst_state = 100000
                     and b.term_type_id in (36, 37, 67, 69))) a2
    left join hi_app_dc.app_prod_offer_03_END_1 b
   on a2.offer_inst_Id = b.offer_inst_Id
   where b.offer_inst_Id is null;
   
   
 --���������ײ�û�б仯�����������ʧ�ʹ���װ)
insert into hi_app_dc.app_prod_offer_03_END_1
select p.* from (select aa.*
          from (select a.*, '����' offer_change_flag
                  from hi_app_dc.app_prod_offer_03_5 a
                     where a.prod_inst_Id=a.main_prod_inst_Id) aa
           join hi_app_dc.app_prod_offer_02_4 b
            on aa.prod_inst_Id = b.prod_inst_id
           and aa.offer_inst_id = b.offer_inst_id) p
  left join hi_app_dc.app_prod_offer_03_END_1 b
   on p.offer_inst_Id = b.offer_inst_Id 
   where b.offer_inst_Id is null; 
   
insert into hi_app_dc.app_prod_offer_03_END_1
 select p.* from(select a.*, '����' offer_change_flag
           from hi_app_dc.app_prod_offer_03_5 a
          where a.prod_inst_Id = a.main_prod_inst_Id
            and from_unixtime(unix_timestamp(a.offer_inst_create_date),
                              'yyyyMM') < '201902'
            and from_unixtime(unix_timestamp(a.memb_create_date), 'yyyyMM') <
                '201902'
            and from_unixtime(unix_timestamp(a.prod_create_date), 'yyyyMM') <
                '201902') p
   left join hi_app_dc.app_prod_offer_03_END_1 b
     on p.offer_inst_Id = b.offer_inst_Id
  where b.offer_inst_Id is null;
   
--21��װ                                
insert into hi_app_dc.app_prod_offer_03_END_1
select aa.*
  from (select a.*, 
       (case when last_offer_type = '�ں�' and offer_type = '��C' then '��װ-����->��C'
         else  concat('��װ-', last_offer_type, '->', offer_type)
       end) offer_change_flag
  from hi_app_dc.app_prod_offer_03_5 a
 where from_unixtime(unix_timestamp(a.offer_inst_create_date), 'yyyyMM') >=
       '201902'
   and from_unixtime(unix_timestamp(a.memb_create_date), 'yyyyMM') >=
       '201902'
   and from_unixtime(unix_timestamp(a.prod_create_date), 'yyyyMM') <
       '201902'
   and last_offer_inst_id is not null
   and a.prod_inst_Id = a.last_main_prod_inst_Id
   and a.prod_inst_id = a.main_prod_inst_id
   and not (offer_type = '�ں�' and last_offer_type = '��C')
   and not exists (select 1
          from hi_app_dc.app_prod_offer_03_END_1 a1
         where a.last_offer_inst_id = a1.last_offer_inst_id
           and a1.offer_change_flag not like '��ʧ%')) aa
  left join hi_app_dc.app_prod_offer_03_END_1 b
   on aa.offer_inst_Id = b.offer_inst_Id 
   where b.offer_inst_Id is null; 
---������иĵģ����Ѿ�������Ա���ײ��ˣ�
---����>�������Ĳ�Ҫ �� 
insert into hi_app_dc.app_prod_offer_03_END_1
select aa.*
  from (select a.*,
               concat('��װ-',(case when last_offer_type='�ں�' then '����' else last_offer_type end),  '->', offer_type) offer_change_flag
          from hi_app_dc.app_prod_offer_03_5 a
         where from_unixtime(unix_timestamp(a.offer_inst_create_date),'yyyyMM') >= '201902'
           and from_unixtime(unix_timestamp(a.memb_create_date), 'yyyyMM') >='201902'
           and from_unixtime(unix_timestamp(a.prod_create_date), 'yyyyMM') <'201902'
           and prod_inst_id=main_prod_inst_id 
          --and not exists(select 1 from hi_app_dc.app_prod_offer_03_END_1 a1
         -- where a.last_offer_inst_id=a1.last_offer_inst_id 
          --and a1.offer_change_flag not like '��ʧ%')
          and offer_type like '��C' and term_type_id=75) aa
  left join hi_app_dc.app_prod_offer_03_END_1 b
   on aa.offer_inst_Id = b.offer_inst_Id 
   where b.offer_inst_Id is null;
   
insert into hi_app_dc.app_prod_offer_03_END_1
select aa.*
    from (select a.*,
               concat('��װ-',last_offer_type,  '->', offer_type) offer_change_flag
          from hi_app_dc.app_prod_offer_03_5 a
         where from_unixtime(unix_timestamp(a.offer_inst_create_date),
                             'yyyyMM') >= '201902'
           and from_unixtime(unix_timestamp(a.memb_create_date), 'yyyyMM') >=
               '201902'
           and from_unixtime(unix_timestamp(a.prod_create_date), 'yyyyMM') <
               '201902'
           and prod_inst_id=main_prod_inst_id 
          --and not exists(select 1 from hi_app_dc.app_prod_offer_03_END_1 a1
          --where a.last_offer_inst_id=a1.last_offer_inst_id 
          --and a1.offer_change_flag not like '��ʧ%')
          and offer_type in('�ں�', '����') and term_type_id in(36,37,67,69)) aa
  left join hi_app_dc.app_prod_offer_03_END_1 b
   on aa.offer_inst_Id = b.offer_inst_Id 
   where b.offer_inst_Id is null;
---������ǡ�������Ա��װ:���ײ�IDʧЧ,��������Ա״̬�����Ҽ������ײ�
insert into hi_app_dc.app_prod_offer_03_END_1 
 select p.*
  from (select aa.*
          from (select a.*, '����-����Ա��װ' offer_change_flag
                  from hi_app_dc.app_prod_offer_03_5 a join                   
                   hi_app_dc.app_prod_offer_02_4 b
                  on a.prod_inst_id=b.prod_inst_id
                  where a.offer_inst_id!=b.offer_inst_id
                  and a.prod_inst_id=a.main_prod_inst_id
                  and a.prod_inst_id=a.last_main_prod_inst_id
                  and from_unixtime(unix_timestamp(a.memb_eff_date),'yyyyMM') >= '201903' 
                  and from_unixtime(unix_timestamp(a.offer_inst_eff_date),'yyyyMM') < '201903' ) aa) p
  left join hi_app_dc.app_prod_offer_03_END_1 b
   on p.offer_inst_Id = b.offer_inst_Id 
   where b.offer_inst_Id is null; 
 --������ǡ�������-��װ���ײ�IDʧЧ����������Ա״̬�����������������ײ�
insert into hi_app_dc.app_prod_offer_03_END_1 
 select p.*
  from (select aa.*
          from (select a.*, '����-��װ' offer_change_flag
                  from hi_app_dc.app_prod_offer_03_5 a join                   
                   hi_app_dc.app_prod_offer_02_4 b
                  on a.prod_inst_id=b.prod_inst_id
                  where a.offer_inst_id!=b.offer_inst_id
                  and a.prod_inst_id=a.main_prod_inst_id
                  and a.prod_inst_id=a.last_main_prod_inst_id
                  and from_unixtime(unix_timestamp(a.memb_eff_date),'yyyyMM') < '201903'
                  and from_unixtime(unix_timestamp(a.offer_inst_eff_date),'yyyyMM') < '201903') aa) p
  left join hi_app_dc.app_prod_offer_03_END_1 b
   on p.offer_inst_Id = b.offer_inst_Id 
   where b.offer_inst_Id is null; 
--4.�ײ�IDʧЧ,��������Ա״̬������û�ж����κ����ײ�(��ʧ)���ʷ�
insert into hi_app_dc.app_prod_offer_03_END_1
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
       null,null,
       '����-���ʷ�'
  from (select a1.*
          from hi_app_dc.app_prod_offer_02_4 a1
          left join hi_app_dc.app_prod_offer_03_4 a2
            on a1.prod_inst_Id = a2.prod_inst_id
         where a2.offer_inst_id is null
         and a1.prod_inst_id=a1.main_prod_inst_id) a
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
  left join hi_app_dc.app_prod_offer_03_END_1 b 
    on a.offer_inst_id=b.offer_inst_id
 where b.offer_inst_id is null;     
 
---������������ں��ײͣ������ĺ����ײ;Ͳ�ȡ��
---�Ϻ��ĳ�Ա�ײ���ʧ�������п��������ײ�
insert into hi_app_dc.app_prod_offer_03_END_1
select a.*,'����'
    from hi_app_dc.app_prod_offer_03_5 a
left join hi_app_dc.app_prod_offer_03_END_1 b
on a.offer_inst_id = b.offer_inst_id
where b.offer_inst_id is null
and a.prod_inst_Id=a.main_prod_inst_Id limit 5; 
  

select prod_inst_id,count(1) from hi_app_dc.app_prod_offer_03_END_1 group by prod_inst_id
having count(1)>1 limit 5;
select offer_inst_id,count(1) from hi_app_dc.app_prod_offer_03_END_1 
group by offer_inst_id
having count(1)>1 limit 5;

select offer_change_flag,count(1)  from hi_app_dc.app_prod_offer_03_END_1 group by offer_change_flag
order by offer_change_flag;
 
select * from hi_app_dc.app_prod_offer_03_END_1
where offer_inst_id=750015465042
select count(1),offer_change_flag from hi_app_dc.app_prod_offer_03_END_1 group by offer_change_flag order by offer_change_flag;

select offer_inst_id from(
select count(1),offer_inst_id,
offer_change_flag from hi_app_dc.app_prod_offer_03_END_1 group by offer_change_flag,offer_inst_id)tt
group by offer_inst_id having count(1)>1 limit 5;;
  
select 2,prod_inst_id,offer_id,offer_name,offer_inst_id,memb_eff_date,memb_exp_date,offer_inst_eff_date,offer_inst_exp_date
 from hi_app_dc.app_prod_offer_02_4 where offer_inst_id in(109201537324)
  union all 
select 3,prod_inst_id,offer_id,offer_name,offer_inst_id,memb_eff_date,memb_exp_date,offer_inst_eff_date,offer_inst_exp_date
 from hi_app_dc.app_prod_offer_03_4 where prod_inst_id in(109201537324)


 
 select * from hi_app_dc.app_prod_offer_03_END_1  where  offer_inst_id in(109201537324)  

--���1
--
select offer_inst_id from (
select offer_inst_id,offer_change_type from hi_app_dc.app_prod_offer_03_END_1 where offer_change_type like '%����%'
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
          from hi_app_dc.app_prod_offer_03_END_1 a
            join (select main_prod_inst_id from hi_app_dc.app_prod_offer_03_END_1
group by main_prod_inst_id)      b
            on a.prod_inst_id = b.main_prod_inst_id
         where a.offer_change_flag is not null) tt
 where rownum1 < 51
">testvv.csv

iconv -f UTF-8 -c  -t GBK testvv.csv > testbb.csv  
