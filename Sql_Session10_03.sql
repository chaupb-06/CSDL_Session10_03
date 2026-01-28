-- Bảng employees
create table employees (
    id serial primary key,
    name varchar(100),
    position varchar(50),
    salary numeric
);

-- Bảng log
create table employees_log (
    employee_id int,
    operation varchar(10),
    old_data jsonb,
    new_data jsonb,
    change_time timestamp
);

-- Function trigger
create or replace function log_employee()
returns trigger as $$
begin
    if tg_op = 'INSERT' then
        insert into employees_log
        values (new.id, 'INSERT', null, to_jsonb(new), now());
        return new;
    elsif tg_op = 'UPDATE' then
        insert into employees_log
        values (new.id, 'UPDATE', to_jsonb(old), to_jsonb(new), now());
        return new;
    else
        insert into employees_log
        values (old.id, 'DELETE', to_jsonb(old), null, now());
        return old;
    end if;
end;
$$ language plpgsql;

-- Trigger
create trigger trg_log_employees
after insert or update or delete on employees
for each row
execute function log_employee();

-- Test
insert into employees (name, position, salary) values ('A', 'Dev', 1000);
update employees set salary = 1200 where id = 1;
delete from employees where id = 1;

select * from employees_log;
