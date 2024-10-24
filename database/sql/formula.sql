drop schema if exists formula cascade;
create schema formula;

create or replace function formula.state_function(sum real[], new_val real, new_incert real)
returns real[]
language plpgsql
as $$
declare 
    sum_val real := sum[1] ;
    sum_incert real := sum[2] ;
begin 
    if sum is null then 
        return array[new_val, new_incert] ;
    end if ;
    return array[sum_val + new_val, 
            (sum_incert*sum_val + new_incert*new_val)/(sum_val + new_val)
            ] ;
end ;
$$ ; 

create or replace function formula.final_function(state real[])
returns ___.res 
language plpgsql
as $$
declare 
    res ___.res ;
begin 
    select into res state[1] as val, state[2] as incert ;
    return res ;
end ;
$$ ;

create or replace aggregate formula.sum_incert(val real, incert real)
(
    sfunc = formula.state_function,
    stype = real[],
    finalfunc = formula.final_function
) ;

create or replace function formula.pop(fifo varchar, lifo_or_fifo boolean default false) 
returns varchar 
language plpgsql as
$$
declare 
    idx_m integer ; 
    val varchar ;
    query text ;
begin
    if not lifo_or_fifo then
        query := 'select min(id) from '||fifo||';' ;
        execute query into idx_m ;
    else 
        query := 'select max(id) from '||fifo||';' ;
        execute query into idx_m ;
    end if ; 
    query := 'select value from '||fifo||' where id = '||idx_m||' ;' ;
    execute query into val; 
    query := 'delete from '||fifo||' where id = '||idx_m||' ;' ;
    execute query ; 
    return val ; 
end ;
$$ ; 

create or replace function api.recup_entree(id_bloc integer, model_bloc text)
returns boolean
language plpgsql as
$$
declare
    links_up integer[] ;
    b_typ_fils ___.bloc_type ; 
    b_typ ___.bloc_type ;
    query text ;
    colnames varchar[] ;
    col varchar ;
    inp_col real ;
    up_ integer ;
    flag boolean := false ;
    n integer ;
    i integer ; 
begin 
    select into b_typ_fils b_type from ___.bloc where id = id_bloc ;
    select into links_up array_agg(api.link.up) from api.link where down = id_bloc and model = model_bloc ;    
    raise notice 'links_up = %', links_up ;
    if array_length(links_up, 1) = 0 or links_up is null then 
        return false ;
    else 
    n = array_length(links_up, 1) ;
    i = 1; 
    while i < n+1 loop
        up_ = links_up[i] ;
        raise notice 'up_ = %', up_ ;
        select into b_typ b_type from ___.bloc where id = up_ ;
        raise notice 'b_typ = %', b_typ ;
        select array_agg(column_name) into colnames from information_schema.columns, api.input_output  
        where table_name = b_typ||'_bloc' and table_schema = 'api' and 
        b_type = b_typ and column_name = any(outputs) ;

        if b_typ::varchar = 'lien' or b_typ::varchar = 'link' then 
            select into links_up array_cat(links_up, array_agg(api.link.up)) from api.link where down = up_ and model = model_bloc ;
            n := array_length(links_up, 1) ;
        end if ;
        raise notice 'links_up2 = %', links_up ;
        raise notice 'colnames = %', colnames ;
        if colnames is not null then 
        foreach col in array colnames loop
            query = 'select '||col||' from ___.'||b_typ||'_bloc where id = $1 ;' ;
            execute query into inp_col using up_ ;
            -- raise notice 'inp_col = %', inp_col ;
            if inp_col is not null then 
                if col like '%_s' then 
                    if left(col, -2) in (select unnest(inputs) from api.input_output where b_type = b_typ_fils) then 
                        update inp_out set val = inp_col where name = left(col, -2) and val is null ;
                        if found then 
                            flag := true ;
                        end if ;
                    elseif left(col, -2)||'_e' in (select unnest(inputs) from api.input_output where b_type = b_typ_fils) then 
                        update inp_out set val = inp_col where name = left(col, -2)||'_e' and val is null;
                        if found then 
                            flag := true ;
                        end if ;
                    end if ;
                end if ;
                if col in (select unnest(inputs) from api.input_output where b_type = b_typ_fils) then
                    update inp_out set val = inp_col where name = col and val is null;
                    if found then 
                        flag := true ;
                    end if ;

                end if ;
            end if ;
        end loop ;
        end if ;
        i := i + 1 ;
    end loop ;
    end if ;
    return flag ;
end ;
$$ ;

create or replace function formula.read_formula(formula text, colnames varchar[])
returns varchar[]
language plpgsql as
$$
declare 
    list varchar[] ;
    to_return varchar[] ;
    pat text ;
begin
    pat := '[\+\-\*\/\^\(\)\<\>]' ; 
    formula := regexp_replace(formula,  '[^0-9a-zA-Z\+\-\*\/\^\(\)\.\>\<\=\_]', '', 'g');
    list := regexp_split_to_array(formula, pat) ;
    select into to_return array_agg(elem) from unnest(list) as elem where elem = any(colnames) ;
    return to_return ;
end ;
$$ ;

create or replace function formula.insert_op(operators varchar[], op varchar)
returns varchar[]
language plpgsql
as $$
declare 
    symbols varchar[] := array['^', '>', '<', '*', '/', '+', '-', ''] ; 
    prio integer[] :=array[4,3,3,2,2,1,1,0] ;
    n integer ;
    i integer := 1 ;
begin 
    n := array_length(operators, 1) ; 
    if n = 0 then return array[op] ; end if ;
    while i < n + 1 and prio[array_position(symbols, operators[i])] >= prio[array_position(symbols, op)] loop
        i := i + 1 ;
    end loop ;
    --operators = operators[:k] + [op] + operators[k:]
    operators := array_cat(array_cat(operators[1:i-1], array[op]::varchar[]), operators[i:n]) ;
    return operators ; 
end ;
$$ ; 

create or replace function formula.resize_array(tab text[], len_sb integer, new_size integer)
returns text[]
language plpgsql 
as $$ 
declare 
    resized text[];
    n integer ; 
    n_sub integer ; 
    i integer;
    j integer;
begin 
    n = array_length(tab, 1) ;
    n_sub = (n/len_sb)::integer ; 
    resized := array_fill(''::text, array[n_sub*new_size]) ;
    for i in 0..n_sub-1 loop
        resized[i*new_size+1:i*new_size+len_sb] := tab[i*len_sb+1:i*len_sb+len_sb] ;
    end loop ;
    return resized ; 
end ;
$$ ; 

create or replace function formula.write_formula(expr varchar)
returns varchar[]
language plpgsql
as $$
declare 
    pat varchar := '[\+\-\*\/\^\(\)\>\<]' ;
    operators varchar[] ;
    op varchar ;
    args varchar[] ;
    calc text[] := array_fill(''::text, array[50]);
    calc_length integer[] := array_fill(0, array[5]) ; 
    calc_sb_len integer := 10 ;
    last_op text[] := array_fill(''::text, array[50]) ;
    last_op_length integer[] := array_fill(0, array[5]) ; 
    last_op_sb_len integer := 10 ;
    len integer ; 
    idx integer := 1 ; 
    flag_op boolean[] := array[false]::boolean[] ;
    i integer := 1 ;
    j integer := 1 ;
    car char ;
    prioritized varchar ;
begin 
    -- fonction qui réécrit une formule sous forme lisibles sans ambiguités je sais plus comment ça s'appelle mais 
    -- on a a+b*c qui devient a b c * +
    args := array_fill(''::text, array[length(expr)]) ; 
    for i in 1..length(expr) loop 
        car := substr(expr, i, 1) ;
        if car ~ pat then 
            args[j] := trim(args[j]) ;
            if args[j] != '' then 
                j := j + 1 ;
            end if ;
            args[j] := car ;
            j := j + 1 ;
        else 
            args[j] := args[j] || car ;
        end if ;
    end loop ;
    args := args[1:j] ;
    raise notice 'args finale %', args ;
    for i in 1..j-1 loop 
        raise notice 'args %', args[i] ;
        if args[i] = '(' then 
            len := array_length(calc, 1) ; 
            if len < (idx + 1)*calc_sb_len then 
                calc := array_cat(calc, array_fill(''::text, array[calc_sb_len])) ;
                calc_length := array_append(calc_length, 0) ;
            else 
                calc[idx*calc_sb_len+1:(idx+1)*calc_sb_len] = array_fill(''::text, array[calc_sb_len]) ;
                calc_length[idx+1] := 0 ;
            end if ; 
            flag_op := array_append(flag_op, false) ;
            len := array_length(last_op, 1) ;
            if len < (idx + 1)*last_op_sb_len then
                last_op := array_cat(last_op, array_fill(''::text, array[last_op_sb_len])) ;
                last_op_length := array_append(last_op_length, 0) ;
            else
                last_op[idx*last_op_sb_len+1:(idx+1)*last_op_sb_len] = array_fill(''::text, array[last_op_sb_len]) ;
                last_op_length[idx+1] := 0 ;
            end if ;
            idx := idx + 1 ; 
        elseif args[i] = ')' then 
            if calc_length[idx] + last_op_length[idx] > calc_sb_len then 
                calc := formula.resize_array(calc, calc_sb_len, 2*(calc_length[idx] + last_op_length[idx])) ;
                calc_sb_len := 2*(calc_length[idx] + last_op_length[idx]) ;
            end if ; 
            raise notice 'là1' ;
            if 1 <= last_op_length[idx] then
                calc[(idx-1)*calc_sb_len+calc_length[idx]+1:(idx-1)*calc_sb_len+calc_length[idx]+last_op_length[idx]] := last_op[(idx-1)*last_op_sb_len+1:(idx-1)*last_op_sb_len+last_op_length[idx]] ;
                calc_length[idx] := calc_length[idx] + last_op_length[idx] ;
            end if ;
            if calc_length[idx] + calc_length[idx - 1] > calc_sb_len then 
                calc := formula.resize_array(calc, calc_sb_len, 2*(calc_length[idx] + calc_length[idx-1])) ;
                calc_sb_len := 2*(calc_length[idx] + calc_length[idx-1]) ;
            end if ; 
            raise notice 'calc_length %', calc_length ;
            raise notice 'là % < %', (idx-2)*calc_sb_len+calc_length[idx-1]+1, (idx-2)*calc_sb_len+calc_length[idx-1]+calc_length[idx] ;
            calc[(idx-2)*calc_sb_len+calc_length[idx-1]+1:(idx-2)*calc_sb_len+calc_length[idx-1]+calc_length[idx]] := calc[(idx-1)*calc_sb_len+1:(idx-1)*calc_sb_len+calc_length[idx]] ;
            calc_length[idx-1] := calc_length[idx-1] + calc_length[idx] ;
            flag_op = array_remove(flag_op, flag_op[idx]) ;
            idx := idx - 1 ;
        elseif not args[i] ~ pat then 
            if calc_length[idx]+1 > calc_sb_len then 
                calc := formula.resize_array(calc, calc_sb_len, 2*(calc_length[idx]+1)) ;
                calc_sb_len := 2*(calc_length[idx]+1) ;
            end if ;
            calc[(idx-1)*calc_sb_len+calc_length[idx]+1] := args[i];
            calc_length[idx] := calc_length[idx] + 1 ;
        else 
            if last_op_length[idx] > 0 then 
                prioritized := last_op[(idx-1)*last_op_sb_len+1] ;
            else 
                prioritized := '' ;
                flag_op[idx] := false ;
            end if ;
            if last_op_length[idx] + 1 > last_op_sb_len then 
                last_op := formula.resize_array(last_op, last_op_sb_len, 2*(last_op_length[idx]+1)) ;
                last_op_sb_len := 2*(last_op_length[idx]+1) ;
            end if ;
            -- raise notice 'last_op %, args %', last_op, args[i] ;
            -- raise notice 'idx %', idx ; 
            last_op[(idx-1)*last_op_sb_len+1:idx*last_op_sb_len] := formula.insert_op(last_op[(idx-1)*last_op_sb_len+1:idx*last_op_sb_len], args[i]) ;
            last_op_length[idx] := last_op_length[idx] + 1 ;
            if prioritized = last_op[(idx-1)*last_op_sb_len+1] then 
                flag_op[idx] := true ;
            end if ;
            if flag_op[idx] then 
                if calc_length[idx] + 1 > calc_sb_len then 
                    calc := formula.resize_array(calc, calc_sb_len, 2*(calc_length[idx]+1)) ;
                    calc_sb_len := 2*(calc_length[idx]+1) ;
                end if ;
                calc[(idx-1)*calc_sb_len+calc_length[idx]+1] := last_op[(idx-1)*last_op_sb_len+1] ;
                last_op[(idx-1)*last_op_sb_len+1:idx*last_op_sb_len-1] := last_op[(idx-1)*last_op_sb_len+2:idx*last_op_sb_len] ;
                last_op_length[idx] := last_op_length[idx] - 1 ;
                calc_length[idx] := calc_length[idx] + 1 ;
                flag_op[idx] := false ;
            end if ;
        end if ;
        raise notice 'idx %, calc %', idx, calc ;
        raise notice 'last_op %', last_op ;
        raise notice 'calc_length %, last_op_length %', calc_length, last_op_length ;
    end loop ;
    if calc_length[idx] + last_op_length[idx] > calc_sb_len then 
        calc := formula.resize_array(calc, calc_sb_len, (calc_length[idx] + last_op_length[idx])+1) ;
    end if ;
    if 1 <= last_op_length[idx] then 
        calc[(idx-1)*calc_sb_len+calc_length[idx]+1:(idx-1)*calc_sb_len+calc_length[idx]+last_op_length[idx]] := last_op[(idx-1)*last_op_sb_len+1:(idx-1)*last_op_sb_len+last_op_length[idx]] ;
    end if ; 
    raise notice 'calc final %', calc ;
    return calc[(idx-1)*calc_sb_len+1:calc_length[idx]] ; 
end ;
$$ ;

create or replace function formula.calc_incertitudes(calc varchar[])
returns record
language plpgsql
as $$
declare 
    query text ;
    i integer ;
    deb integer ;
    fin integer ;  
    n integer ;
    val1 real ;
    incert1 real ;
    val2 real ;
    incert2 real ;
    calc_val real[] ;
    calc_incert real[] ; 
    new varchar ;
    pat varchar := '[\+\-\*\/\^\>\<]' ;
    new_val real; 
    new_incert real; 
    result ___.res ; 
begin 
    n = array_length(calc, 1) ;
    calc_val := array_fill(0.0, array[n]) ;
    calc_incert := array_fill(0.0, array[n]) ;
    deb := 1 ;
    fin := 0 ;
    if n = 0 then return result ; end if ;
    i := 1 ;
    while i < n+1 loop
        new := calc[i] ;
        i:=i+1 ;
        if new ~ pat then 
            -- On récupère les deux valeurs de calcul
            val1 := calc_val[fin-1] ;
            incert1 := calc_incert[fin-1] ;

            val2 := calc_val[fin] ;
            incert2 := calc_incert[fin] ;
            
            fin := fin - 1 ;
            -- On calcule à chaque fois les incertitudes relatives et les valeurs réelles 
            case
            when new = '+' then 
                -- somme des incertitudes
                new_val := val1 + val2 ;
                new_incert := (incert1*val1 + incert2*val2)/(val1 + val2) ;
            when new = '-' then 
                new_val := val1 - val2 ;
                new_incert := abs((incert1*val1 + incert2*val2)/(val1 - val2)) ;
            when new = '*' then
                new_val := val1 * val2 ;
                new_incert := sqrt(incert1^2 + incert2^2) ;
            when new = '/' then
                new_val := val1 / val2 ;
                new_incert := sqrt(incert1^2 + incert2^2) ;
            when new = '^' then
                new_val := val1 ^ val2 ;
                new_incert := abs(val2) * incert1 ;
            when new = '>' then
                new_val := (val1 > val2)::int::real ;
                new_incert := 0.0 ;
            when new = '<' then
                new_val := (val1 < val2)::int::real ;
                new_incert := 0.0 ;
            end case ;
            calc_val[fin] := new_val ;
            calc_incert[fin] := new_incert ;
        else
            if regexp_matches(new, '^[0-9]+(\.[0-9]+)?$') is not null then 
                val1 := new::real ;
                incert1 := 0.0 ;
            else
                select into val1 val from inp_out where name = new ;
                select into incert1 incert from inp_out where name = new ;
            end if ; 
            fin := fin + 1 ;
            calc_val[fin] := val1 ;
            calc_incert[fin] := incert1 ;
            
        end if ;
        -- raise notice 'new %', new ;
        -- raise notice 'calc_val %', calc_val ;
        -- raise notice 'calc_incert %', calc_incert ;
    end loop ; 
    raise notice 'val %', calc_val[fin] ;
    raise notice 'incert %', calc_incert[fin] ;
    select into result calc_val[fin] as val, calc_incert[fin] as incert;
    return result ;
    
end ;
$$ ;

create or replace function formula.calculate_formula(formula text, id_bloc integer, detail_level integer, to_calc varchar)
returns void
language plpgsql as
$$
declare 
    pat varchar := '[\+\-\*\/\^\(\)\>\<]' ;
    rightside text ; 
    operators varchar[] ;
    op varchar ;
    args varchar[] ;
    arg varchar ;
    queries text[] := array['', '', '', '', '', '']::text[] ;
    len integer ;
    to_cast boolean[] := array[false, false, false, false, false]::boolean[] ;
    idx integer ;
    query text ;
    val_arg real ;
    i integer ; 
    j integer := 1 ;
    flag boolean := true ;
    notnowns varchar[] := array[]::varchar[] ; 
    formul text ;
    tic timestamp ;
    tac timestamp ;
    result ___.res ;
begin 
    formul := regexp_replace(formula, '[^0-9a-zA-Z\+\-\*\/\^\(\)\.\>\<\=\_]', '', 'g');
    formul := regexp_replace(formula, '\*\*', '^', 'g') ;
    rightside := split_part(formul, '=', 2) ;
    select into notnowns distinct array_agg(distinct elem) 
    from unnest(args) as elem 
    left join inp_out on name = elem 
    where (val is null and name = elem) 
    or (elem not in (select name from inp_out) and not elem ~ '[0-9].*');
    -- select into notnowns array_agg(name) from inp_out where val is null and name in (select unnest(args)) ;
    raise notice 'unknowns = %', notnowns ;
    if array_length(notnowns, 1) > 0 then
        if exists (select 1 from ___.results where name = to_calc and ___.results.formula = formul and id = id_bloc) then
            update ___.results set val=null, unknowns = notnowns where name = to_calc and ___.results.formula = formul and id = id_bloc ;
        else 
            insert into ___.results(id, name, detail_level, formula, unknowns) values (id_bloc, to_calc, detail_level, formul, notnowns) ;
        end if ; 
    else 
        result := formula.calc_incertitudes(formula.write_formula(rightside)) ;
        if exists (select 1 from ___.results where name = to_calc and ___.results.formula = formul and id = id_bloc) then 
            update ___.results set val = result, unknowns = null where name = to_calc and ___.results.formula = formul and id = id_bloc ;
        else
            insert into ___.results(id, name, detail_level, val, formula) values (id_bloc, to_calc, detail_level, result, formul) ;
        end if ; 
        -- On update inp_out pour les futurs calculs si besoin 
        update inp_out set val = result.val where name = to_calc and val is null;
        return ;
    end if ;
end ;
$$ ;


-- create or replace function formula.calculate_formula(formula text, id_bloc integer, detail_level integer, to_calc varchar)
-- returns void
-- language plpgsql as
-- $$
-- declare 
--     pat varchar := '[\+\-\*\/\^\(\)\>\<]' ;
--     rightside text ; 
--     operators varchar[] ;
--     op varchar ;
--     args varchar[] ;
--     arg varchar ;
--     queries text[] := array['', '', '', '', '', '']::text[] ;
--     len integer ;
--     to_cast boolean[] := array[false, false, false, false, false]::boolean[] ;
--     idx integer ;
--     query text ;
--     val_arg real ;
--     i integer ; 
--     j integer := 1 ;
--     flag boolean := true ;
--     result real ;
--     notnowns varchar[] := array[]::varchar[] ; 
--     formul text ;
--     tic timestamp ;
--     tac timestamp ;
-- begin
--     -- formul := replace(formula, ' ', '') ;
--     formul := regexp_replace(formula, '[^0-9a-zA-Z\+\-\*\/\^\(\)\.\>\<\=\_]', '', 'g');
--     formul := regexp_replace(formula, '\*\*', '^', 'g') ;
--     raise notice 'formula = %', formul ;
--     rightside := '('||split_part(formul, '=', 2)||')' ;
--     -- On met entre parenthèse parce que le code parcours la formule en fonction des parenthèses
--     select into operators array_agg(match[1]) from regexp_matches(rightside,  '(\s*[\+\-\*\/\^\(\)\>\<]\s*)', 'g') as match ;
--     raise notice 'operators = %', operators ;
--     raise notice 'rightside = %', rightside ;
--     select into args array_remove(regexp_split_to_array(rightside, pat), '') ;
--     raise notice 'args = %', args ;
--     idx := 1 ;
--     query := '' ;
--     len := array_length(queries, 1) ;
--     -- On regarde si les arguments de la formule sont connus.
--     select into notnowns distinct array_agg(distinct elem) 
--     from unnest(args) as elem 
--     left join inp_out on name = elem 
--     where (val is null and name = elem) 
--     or (elem not in (select name from inp_out) and not elem ~ '[0-9].*');
--     -- select into notnowns array_agg(name) from inp_out where val is null and name in (select unnest(args)) ;
--     raise notice 'unknowns = %', notnowns ;
--     if array_length(notnowns, 1) > 0 then
--         if exists (select 1 from ___.results where name = to_calc and ___.results.formula = formul and id = id_bloc) then
--             update ___.results set val=null, unknowns = notnowns where name = to_calc and ___.results.formula = formul and id = id_bloc ;
--         else 
--             insert into ___.results(id, name, detail_level, formula, unknowns) values (id_bloc, to_calc, detail_level, formul, notnowns) ;
--         end if ; 
--     else 
--         -- On parcours la formule en fonction des parenthèses pour créer une requête SQL de calcul qui correspond à la formule
--         for i in 1..array_length(operators, 1) loop
--             raise notice 'query = %', query ;
--             raise notice 'queries = %', queries ;
--             raise notice 'i = %, j = %, op = %, arg = %', i, j, operators[i], args[j] ;
            
--             if regexp_matches(args[j], '^[0-9]+(\.[0-9]+)?$') is not null then 
--                 val_arg := args[j]::real ;
--             else
--                 select into val_arg val from inp_out where name = args[j] ;
--             end if ; 
--             raise notice 'val_arg = %', val_arg ;
--             op = operators[i] ;
--             if op = '(' then 
--                 if idx > len then 
--                     queries := array_append(queries, '') ;
--                     to_cast := array_append(to_cast, false) ;
--                 end if ; 
--                 raise notice 'query avant ( = %', query ;
--                 query := query||op ; 
--                 queries[idx] := query ; 
                
--                 if operators[i+1] != '(' then 
--                     query := query||val_arg ;
--                     j := j + 1 ;
--                 end if ;
--                 idx := idx + 1 ;
--             elseif operators[i+1] = '(' then 
--                 query := query||op ;
--             elseif op = '>' or op = '<' then 
--                 query := query||op||val_arg ; 
--                 j := j + 1 ;
--                 to_cast[idx] := true ;
--             elseif op = ')' then
--                 raise notice 'query above here = %', query ;
--                 query := query||op ;
--                 if to_cast[idx] then 
--                     query := query||'::int::real' ; -- boolean to real
--                     to_cast[idx] := false ;
--                 raise notice 'query here = %', query ;
--                 end if ;
--                 idx := idx - 1 ;
--                 -- query := queries[idx]||query ;
--             else
                
--                 query := query||op||val_arg ;
--                 j := j + 1 ;
--             end if ;
--         end loop ;
--         raise notice 'query = %', query ;
--         execute 'select '||query into result ;
--         if exists (select 1 from ___.results where name = to_calc and ___.results.formula = formul and id = id_bloc) then 
--             update ___.results set val = result, unknowns = null where name = to_calc and ___.results.formula = formul and id = id_bloc ;
--         else
--             insert into ___.results(id, name, detail_level, val, formula) values (id_bloc, to_calc, detail_level, result, formul) ;
--         end if ; 
--         -- On update inp_out pour les futurs calculs si besoin 
--         update inp_out set val = result where name = to_calc and val is null;
--     end if ;
--     return ;
-- end ;
-- $$ ;

create or replace function api.calculate_bloc(id_bloc integer, model_bloc text, on_update boolean default false)
returns varchar
language plpgsql as
$$
declare  
    b_typ ___.bloc_type ;
    concr boolean ;
    to_calc varchar ;
    data_ varchar ; 
    bil varchar ;
    args varchar[] ; 
    f varchar ;
    detail integer ;
    c integer ; 
    result real ;
    colnames varchar[] ;
    col varchar ; 
    query text ;
    items record ; 
    flag boolean := true ;
    tic timestamp ;
    tac timestamp ;
    type_ varchar ; 
    inp_out_exists boolean ;
begin 
    -- raise notice 'id_bloc = %, model_bloc = %', id_bloc, model_bloc ;
    -- tic := clock_timestamp() ;
    select into b_typ b_type from ___.bloc where id = id_bloc and model = model_bloc ;
    select into concr concrete from api.input_output where b_type = b_typ ;
    if not concr then 
        return 'No calculation for link or sur_bloc' ;
    end if ;
    -- raise notice 'b_typ = %', b_typ ;
    
    -- inp_out est une table qui contient toutes les valeurs qui pourraient servir pour appliquer une formule.
    create temp table inp_out(name varchar, val real, incert real default 0) on commit drop; 
    -- raise notice 'b_typ = %', b_typ ;
    -- raise notice 'input_output = %', (select inputs from api.input_output where b_type = b_typ) ;
    select array_agg(column_name) into colnames from information_schema.columns, api.input_output  
    where table_name = b_typ||'_bloc' and table_schema = '___' and 
    b_type = b_typ and (column_name = any(inputs) or column_name = any(outputs)) ;
    -- raise notice 'colnames = %', colnames ;
    foreach col in array colnames loop
        select data_type from information_schema.columns where table_name = b_typ||'_bloc' and column_name = col limit 1 into type_ ; 
        if type_ = 'USER-DEFINED' then 
            query := 'select '''||col||''' as name, '||col||'_fe::real as val from api.'||b_typ||'_bloc where id = $1 ; '  ; 
            execute query into items using id_bloc ;
        else 
            query := 'select '''||col||''' as name, '||col||'::real as val from ___.'||b_typ||'_bloc where id = $1 ; '  ; 
            execute query into items using id_bloc ;
        end if ;
        insert into inp_out(name, val) values (items.name, items.val) ;
        -- raise notice 'items = %', items ;
    end loop ;
    insert into inp_out(name, val, incert) select name, val, incert from ___.global_values ;
    flag := api.recup_entree(id_bloc, model_bloc) ;
    if not flag and on_update then
        drop table inp_out ;
        return 'No new entry' ;
    end if ;  

    create temp table bilan(leftside varchar, calc_with varchar[], formula varchar, detail_level integer) on commit drop;
    
    with bloc_formula as (select formula, detail_level from api.formulas where name in (select unnest(default_formulas) from api.input_output where b_type = b_typ))
    insert into bilan(leftside, calc_with, formula, detail_level) 
    select trim(both ' ' from split_part(formula, '=', 1)), formula.read_formula(split_part(formula, '=', 2), colnames), formula, detail_level from bloc_formula ;

    -- for items in (select * from bilan) loop
    --     raise notice 'items bilan = %', items ;
    -- end loop ;

    create temp table known_data(leftside varchar, known boolean default false) on commit drop;
    insert into known_data(leftside, known) select name, val is not null from inp_out ;

    -- create temp table results(name varchar, detail_level integer, val real) on commit drop ; 
    tac := clock_timestamp() ;
    for data_, args in (select leftside, calc_with from bilan) loop
        create temp table fifo(id serial primary key, value varchar) ; 
        create temp table treatment_lifo(id serial primary key, value varchar) ; 

        insert into fifo(value) values (data_) ;
        c := 0 ; 
        -- On fait un parcours de graph en profondeur avec treatment_lifo pour calculer les inconnus (le graphs représente le système d'équations)
        -- A noter que le système est très simple de type a = f(b), b = g(c)... On ne résout pas de sytème type a = f(a, b), b = g(a, b). (l'amélioration pourrait se faire)
        while c < 10000 and (select count(*) from fifo) > 0 loop
            c := c + 1 ;
            to_calc := formula.pop('fifo') ;
            -- raise notice 'to_calc = %', to_calc ;
            -- raise notice 'known_data = %', (select known from known_data where leftside = to_calc) ;
            if (to_calc not in (select leftside from known_data where known = true)) and (to_calc in (select leftside from bilan)) then 
                insert into treatment_lifo(value) values (to_calc) ;
                update known_data set known = true where leftside = to_calc ;
                insert into fifo(value) select elem from unnest(args) as elem where elem not in (select leftside from known_data where known = true) ;
            end if ;
        end loop ;
        if c = 10000 then 
            raise exception 'Too many iterations' ;
        end if ;
        c := 0 ; 
        while c < 10000 and (select count(*) from treatment_lifo) > 0 loop
            c := c + 1 ;
            to_calc := formula.pop('treatment_lifo', true) ;
            for f, detail in (select formula, detail_level from bilan where leftside = to_calc) loop
                raise notice 'f = %', f ;
                -- update tableau ___.result et inp_out
                perform formula.calculate_formula(f, id_bloc, detail, to_calc) ;
                raise notice 'result = %', result ;
                -- insert into ___.results(id, name, detail_level, val, formula) values (id_bloc, to_calc, detail, result, f) ;
            end loop ;
            with max_detail as (select max(detail_level) as max_detail from ___.results
            where name = to_calc and id = id_bloc and val is not null)
            update inp_out set val = (___.results.val).val from ___.results, max_detail 
            where inp_out.name = to_calc and ___.results.id = id_bloc and detail = max_detail ; 
        end loop ;
        if c = 10000 then 
            raise exception 'Too many iterations' ;
        end if ;
        drop table fifo ;
        drop table treatment_lifo ;
    end loop ;
    -- update b_typ_bloc 
    foreach col in array colnames loop
        query := 'update ___.'||b_typ||'_bloc set '||col||' = (select val from inp_out where name = '''||col||''' and val is not null) 
        where id = '||id_bloc||' and '||col||' is null;' ; 
        execute query ;
    end loop ;
    drop table inp_out ;
    drop table bilan ;
    drop table known_data ;
    foreach to_calc in array array['co2_e', 'co2_c', 'ch4_e', 'ch4_c', 'n2o_e', 'n2o_c']::varchar[] loop
        if to_calc not in (select name from ___.results where id = id_bloc) then
            insert into ___.results(id, name, val) values (id_bloc, to_calc, row(0, 0)::___.res) ;
        end if ;
    end loop ;
    tac := clock_timestamp() ;
    raise notice 'Time to calculate = %', tac - tic ;
    return 'Calculation done' ;
end ;
$$ ;

create or replace function api.update_calc_bloc(id_bloc integer, model_name varchar, deleted boolean default false)
returns void
language plpgsql
as $$
declare
    downs integer ;
    new_up integer ; 
begin
-- Recalcul les émissions en fonction des liens entre les blocs.
    create temp table fifo2(id serial primary key, value integer) on commit drop;
    for downs in (select down from api.link where up = id_bloc and model = model_name)
    loop
        insert into fifo2(value) values (downs) ;
    end loop;
    if deleted then
        delete from api.link where up = id_bloc and model = model_name ;
    end if ;
    while (select count(*) from fifo2) > 0
    loop
        new_up := formula.pop('fifo2', true) ;
        if deleted then 
        -- On doit tout recalculer donc on_update = False pour être sûr de refaire tout le calcul
            perform api.calculate_bloc(new_up, model_name, false) ; 
        else 
        -- On doit tout recalculer si il y a eu des modifications
            perform api.calculate_bloc(new_up, model_name, true) ;
        end if ; 
        perform api.update_results_ss_bloc(new_up, id_bloc) ; 
        for downs in (select down from api.link where up = new_up and model = model_name)
        loop
            insert into fifo2(value) values (downs) ;
        end loop ;
    end loop ;
    drop table fifo2 ; 
end ;
$$ ;

create or replace function api.get_results_ss_bloc(id_bloc integer)
returns varchar 
language plpgsql as
$$
declare 
    sb integer ;
    s ___.res ; 
    s_intrant ___.res ;
    keys varchar[] := array['co2_e', 'co2_c', 'ch4_e', 'ch4_c', 'n2o_e', 'n2o_c'] ;
    k varchar ;
    f varchar ; 
    res ___.res ;
    res_intrant ___.res ;
    items record ;
    flag boolean := true ;
    flag_intrant boolean := false ;
    detail_l integer ; 
    details integer[] ; 
    n_sb boolean;
	b_typ ___.bloc_type ;
    concr boolean ;
begin   
    foreach k in array keys loop
        select array_length(ss_blocs, 1) > 0 into n_sb from ___.bloc where id = id_bloc ;
        if n_sb is null or not n_sb then
            with somme as (select formula.sum_incert((val).val, (val).incert) as val from ___.results where name = k and id = id_bloc and detail_level = 6)
            update ___.results set result_ss_blocs_intrant = (select somme.val from somme) where name = k and id = id_bloc ;
            update ___.results set result_ss_blocs = (select val from ___.results where name = k and id = id_bloc and val is not null 
            and detail_level < 6 order by detail_level desc limit 1) 
            where name = k and id = id_bloc ;
        else
            flag := true ;
            flag_intrant := true ;
            s := row(0, 0)::___.res ;
            s_intrant := row(0, 0)::___.res ;
            for sb in (select unnest(ss_blocs) from ___.bloc where id = id_bloc) loop 
                select into b_typ b_type from api.bloc where id = sb ;
                select into concr concrete from api.input_output where b_type = b_typ ;
                if concr or b_typ = 'sur_bloc' then
                    -- On part du principe que les sous blocs sont cleans 
                    select into items result_ss_blocs_intrant from ___.results where name = k and id = sb and detail_level = 6 and result_ss_blocs is not null ;
                    res_intrant.val := (items.result_ss_blocs_intrant).val ;
                    res_intrant.incert := (items.result_ss_blocs_intrant).incert ;
                    select into items result_ss_blocs from ___.results where name = k and id = sb and result_ss_blocs is not null ;
                    res.val := (items.result_ss_blocs).val ;
                    res.incert := (items.result_ss_blocs).incert ;
                    if res_intrant is not null then 
                        s_intrant.incert := (s_intrant.incert*s_intrant.val + res_intrant.incert*res_intrant.val)/(s_intrant.val + res_intrant.val) ;
                        s_intrant.val := s_intrant.val + res_intrant.val ;
                    else 
                        flag_intrant := false ;
                    end if ;
                    if res is not null then 
                        s.incert := (s.incert*s.val + res.incert*res.val)/(s.val + res.val) ;
                        s.val := s.val + res.val ;
                    else 
                        flag := false ;
                    end if ;
                end if ;
            end loop ;
            if flag then 
                update ___.results set result_ss_blocs = s where name = k and id = id_bloc ;
            else 
                update ___.results set result_ss_blocs = (select val from ___.results where name = k and id = id_bloc and val is not null 
                and detail_level < 6 order by detail_level desc limit 1) 
                where name = k and id = id_bloc ;
            end if ;
            if flag_intrant then 
                update ___.results set result_ss_blocs_intrant = s_intrant where name = k and id = id_bloc ;
            else 
                
                with somme as (select formula.sum_incert((val).val, (val).incert) as val from ___.results where name = k and id = id_bloc and detail_level = 6)
                update ___.results set result_ss_blocs_intrant = (select somme.val from somme) where name = k and id = id_bloc ;
            end if ;
        end if ;
    end loop ;
    return 'Results for ss_blocs updated' ;
end ;
$$ ;

create or replace function api.update_results_ss_bloc(id_bloc integer, old_sur_bloc integer, deleted boolean default false)
returns void
language plpgsql as
$$
declare 
    container integer ;
    sb integer ; 
    keys varchar[] := array['co2_e', 'co2_c', 'ch4_e', 'ch4_c', 'n2o_e', 'n2o_c'] ;
    k varchar ;
    f varchar ;
    n_sb boolean;
    s_old ___.res ;
    s_new ___.res ;
    test record ; 
    new_res ___.res ;
    tic timestamp ; 
    tac timestamp ; 
    continue boolean[] := array[true, true] ; 
begin   
    create temp table old_results(id integer, name varchar, result_ss_blocs ___.res, result_ss_blocs_intrant ___.res) on commit drop ;
    insert into old_results(id, name, result_ss_blocs, result_ss_blocs_intrant) 
    select id, name, result_ss_blocs, result_ss_blocs_intrant from ___.results where id = id_bloc ;
    
    perform api.get_results_ss_bloc(id_bloc) ;
    if deleted then
        update ___.results set val = null, result_ss_blocs = null, result_ss_blocs_intrant = null where id = id_bloc ;
        -- raise notice 'Results deleted' ;
    end if ;
    if old_sur_bloc is null then 
        drop table old_results ;
        return ;
    end if ;
    create temp table fifo(id serial primary key, value varchar) on commit drop ;

    insert into fifo(value) values (old_sur_bloc) ;
    sb := id_bloc ;
    while (select count(*) from fifo) > 0 loop
        raise notice 'old_results = %', (select result_ss_blocs from old_results where name = 'co2_e' and id = sb and result_ss_blocs is not null) ;
        raise notice 'new_results = %', (select result_ss_blocs from ___.results where name = 'co2_e' and id = sb and result_ss_blocs is not null) ;
        container := formula.pop('fifo')::integer ;
        raise notice 'container = %, sb = %', container, sb ;
        
        foreach k in array keys loop
            select into s_old result_ss_blocs from old_results where name = k and id = sb and result_ss_blocs is not null ;
            select into test result_ss_blocs from ___.results where name = k and id = sb and result_ss_blocs is not null ;
            s_new.val := (test.result_ss_blocs).val ;
            s_new.incert := (test.result_ss_blocs).incert ;
            -- select into s_new result_ss_blocs from ___.results where name = k and id = sb and result_ss_blocs is not null ;
            -- Je sais pas pouquoi la ligne d'au dessus ne marche pas
            if s_new is null then
                update ___.results set result_ss_blocs = (select val from ___.results where name = k and id = container and val is not null 
                and detail_level < 6 order by detail_level desc limit 1) 
                where name = k and id = container ;
            elseif s_new is not null and s_old is null then 
                perform api.get_results_ss_bloc(container) ;
            elseif s_new is not null and s_new != s_old then
                select into new_res result_ss_blocs from ___.results where name = k and id = container and result_ss_blocs is not null ;
                new_res.incert := (s_new.incert*s_new.val + new_res.incert*new_res.val + s_old.incert*s_old.val)/(s_new.val + new_res.val - s_old.val) ;
                new_res.val := s_new.val + new_res.val - s_old.val ;
                update ___.results set result_ss_blocs = new_res where name = k and id = container ;
            else 
                continue[1] := false ;
            end if ;
            select into s_old result_ss_blocs_intrant from old_results where name = k and id = sb and result_ss_blocs_intrant is not null ;
            select into s_new result_ss_blocs_intrant from ___.results where name = k and id = sb and result_ss_blocs_intrant is not null ;
            if s_new is null then
                with somme as (select formula.sum_incert((val).val, (val).incert) as val from ___.results where name = k and id = container and detail_level = 6)
                update ___.results set result_ss_blocs_intrant = (select somme.val from somme) where name = k and id = container ;
            elseif s_new is not null and s_old is null then
                perform api.get_results_ss_bloc(container) ;
            elseif s_new is not null and s_new != s_old then
                select into new_res result_ss_blocs_intrant from ___.results where name = k and id = container and result_ss_blocs is not null ;
                new_res.incert := (s_new.incert*s_new.val + new_res.incert*new_res.val + s_old.incert*s_old.val)/(s_new.val + new_res.val - s_old.val) ;
                new_res.val := s_new.val + new_res.val - s_old.val ;
                update ___.results set result_ss_blocs_intrant = new_res where name = k and id = container ;
            else 
                continue[2] := false ;
            end if ;

            if continue[1] or continue[2] then 
                insert into fifo(value) select sur_bloc from api.bloc where id = container ;
                sb := container ;
                continue := array[true, true] ;
            end if ; 
        end loop ;
    end loop ;
    drop table fifo ;
    drop table old_results ;
    return ;
end ;
$$ ;


create view api.results as
with ranked_results as (
    select id, formula, name, detail_level, result_ss_blocs, co2_eq,
           row_number() over (partition by id, name order by detail_level desc) as rank,
           max(detail_level) over (partition by id) as max_detail_level
    from ___.results
    where formula is not null and result_ss_blocs is not null
),
in_use as (
    select id, formula, name, detail_level, result_ss_blocs, co2_eq
    from ranked_results
    where (max_detail_level < 6 and rank = 1) or (max_detail_level = 6 and rank <= 2)
),
exploit as (select name, id, co2_eq, formula from in_use where name like '%_e'),
constr as (select name, id, co2_eq, formula from in_use where name like '%_c')
select ___.results.id, ___.bloc.name, model, jsonb_build_object(
    'data', jsonb_agg(
        jsonb_build_object(
            'name', ___.results.name,
            'formula', ___.results.formula,
            'result', ___.results.result_ss_blocs,
            'co2_eq', ___.results.co2_eq, 
            'detail', ___.results.detail_level, 
            'unknown', ___.results.unknowns,
            'in use', case when ___.results.id = in_use.id and ___.results.name = in_use.name 
            and ___.results.detail_level = in_use.detail_level then true else false end
        )
        )
    ) as res, 
    formula.sum_incert((exploit.co2_eq).val, (exploit.co2_eq).incert) as co2_eq_e, 
    formula.sum_incert((constr.co2_eq).val, (constr.co2_eq).incert) as co2_eq_c
from ___.results
join ___.bloc on ___.bloc.id = ___.results.id
left join in_use on ___.results.id = in_use.id and 
___.results.name = in_use.name and ___.results.detail_level = in_use.detail_level
left join exploit on ___.results.id = exploit.id and ___.results.name = exploit.name and ___.results.formula = exploit.formula
left join constr on ___.results.id = constr.id and ___.results.name = constr.name and ___.results.formula = constr.formula
where ___.results.formula is not null 
group by ___.results.id, model, ___.bloc.name;


create or replace function api.get_histo_data(p_model varchar, bloc_name varchar default null)
returns jsonb 
language plpgsql
as $$
declare
    query text;
    id_bloc integer;
    res jsonb := '{}';
    gaz jsonb;
    exploitation jsonb;
    construction jsonb;
    ss_blocs_array integer[];
    names varchar[] := array['n2o_c', 'n2o_e', 'ch4_c', 'ch4_e', 'co2_c', 'co2_e'];
    b_name varchar;
    item record ; 
    concr boolean;
    sum_values record;
    id_loop integer;
    total_values jsonb;
begin
    select into id_bloc id from api.bloc where name = bloc_name limit 1; -- limit 1 normally useless
    raise notice 'id_bloc = %', id_bloc;
    if id_bloc is null then
        select into ss_blocs_array array_agg(id) from ___.bloc where model = p_model and sur_bloc is null;
    else 
        select into ss_blocs_array array_agg(id) from ___.bloc where model = p_model and sur_bloc = id_bloc;
    end if;
    raise notice 'ss_blocs_array = %', ss_blocs_array;
    -- Loop through each bloc id
    if array_length(ss_blocs_array, 1) = 0 or ss_blocs_array is null then
        ss_blocs_array := array[id_bloc];
    end if;
    if array[1] is null then
        return '{"total": {"ch4_c": 0, "ch4_e": 0, "co2_c": 0, "co2_e": 0, "n2o_c": 0, "n2o_e": 0, "co2_eq_c": 0, "co2_eq_e": 0}';
    end if;

    foreach id_loop in array ss_blocs_array loop
        -- Get the bloc name
        select into item name, b_type from ___.bloc where id = id_loop;
        b_name := item.name ;
        select into concr concrete from api.input_output where b_type = item.b_type;
        if concr or item.b_type = 'sur_bloc' then 
            -- Calculate the sum of the values for the specified names
            with ranked_results as (
                select id, formula, name, detail_level, result_ss_blocs, co2_eq,
                    row_number() over (partition by id, name order by detail_level desc) as rank,
                    max(detail_level) over (partition by id) as max_detail_level
                from ___.results
                where formula is not null and result_ss_blocs is not null
            ),
            in_use as (
                select id, formula, name, detail_level, result_ss_blocs, co2_eq
                from ranked_results
                where (max_detail_level < 6 and rank = 1) or (max_detail_level = 6 and rank <= 2)
            ),
            -- select into sum_values jsonb_build_object(
            --     'n2o_c', coalesce(formula.sum_incert(case when name = 'n2o_c' then result_ss_blocs.val, result_ss_blocs.incert end), 0),
            --     'n2o_e', coalesce(formula.sum_incert(case when name = 'n2o_e' then result_ss_blocs.val, result_ss_blocs.incert end), 0),
            --     'ch4_c', coalesce(formula.sum_incert(case when name = 'ch4_c' then result_ss_blocs.val, result_ss_blocs.incert end), 0),
            --     'ch4_e', coalesce(formula.sum_incert(case when name = 'ch4_e' then result_ss_blocs.val, result_ss_blocs.incert end), 0),
            --     'co2_c', coalesce(formula.sum_incert(case when name = 'co2_c' then result_ss_blocs.val, result_ss_blocs.incert end), 0),
            --     'co2_e', coalesce(formula.sum_incert(case when name = 'co2_e' then result_ss_blocs.val, result_ss_blocs.incert end), 0),
            --     'co2_eq_e', coalesce(formula.sum_incert(case when name like '%_e' then co2_eq.val, co2_eq.incert end), 0),
            --     'co2_eq_c', coalesce(formula.sum_incert(case when name like '%_c' then co2_eq.val, co2_eq.incert end), 0)
            -- ) from in_use where id = id_loop;
            gas as (select name, formula.sum_incert((result_ss_blocs).val, (result_ss_blocs).incert) as j
            from in_use where id = id_loop and name = any(names)),
            exploit as (select name, formula.sum_incert((result_ss_blocs).val, (result_ss_blocs).incert) as j
            from in_use where id = id_loop and name like '%_e'),
            constr as (select name, formula.sum_incert((result_ss_blocs).val, (result_ss_blocs).incert) as j
            from in_use where id = id_loop and name like '%_c')
            select into sum_values jsonb_agg(gas.name, gas.j) as gas, jsonb_agg(exploit.name, exploit.j) as exploit, 
            jsonb_agg(constr.name, constr.j) as constr from gas, exploit, constr;

            -- Add the result to the JSONB object
            res := jsonb_set(res, array[b_name], sum_values.gas, true);
            res := jsonb_set(res, array[b_name], sum_values.exploit, true);
            res := jsonb_set(res, array[b_name], sum_values.constr, true);
        end if;
    end loop;

    with ranked_results as (
        select id, formula, name, detail_level, result_ss_blocs, co2_eq,
            row_number() over (partition by id, name order by detail_level desc) as rank,
            max(detail_level) over (partition by id) as max_detail_level
        from ___.results
        where formula is not null and result_ss_blocs is not null
    ),
    in_use as (
        select id, formula, name, detail_level, result_ss_blocs, co2_eq
        from ranked_results
        where (max_detail_level < 6 and rank = 1) or (max_detail_level = 6 and rank <= 2)
    ),
    -- select into total_values jsonb_build_object(
    --     'n2o_c', coalesce(formula.sum_incert(case when name = 'n2o_c' then result_ss_blocs.val, result_ss_blocs.incert end), 0),
    --     'n2o_e', coalesce(formula.sum_incert(case when name = 'n2o_e' then result_ss_blocs.val, result_ss_blocs.incert end), 0),
    --     'ch4_c', coalesce(formula.sum_incert(case when name = 'ch4_c' then result_ss_blocs.val, result_ss_blocs.incert end), 0),
    --     'ch4_e', coalesce(formula.sum_incert(case when name = 'ch4_e' then result_ss_blocs.val, result_ss_blocs.incert end), 0),
    --     'co2_c', coalesce(formula.sum_incert(case when name = 'co2_c' then result_ss_blocs.val, result_ss_blocs.incert end), 0),
    --     'co2_e', coalesce(formula.sum_incert(case when name = 'co2_e' then result_ss_blocs.val, result_ss_blocs.incert end), 0),
    --     'co2_eq_e', coalesce(formula.sum_incert(case when name like '%_e' then co2_eq.val, co2_eq.incert end), 0),
    --     'co2_eq_c', coalesce(formula.sum_incert(case when name like '%_c' then co2_eq.val, co2_eq.incert end), 0)
    -- ) from ___.results where id = any(ss_blocs_array);
    gas as (select name, formula.sum_incert((result_ss_blocs).val, (result_ss_blocs).incert) as j
    from in_use where id = id_loop and name = any(names)),
    exploit as (select name, formula.sum_incert((result_ss_blocs).val, (result_ss_blocs).incert) as j
    from in_use where id = id_loop and name like '%_e'),
    constr as (select name, formula.sum_incert((result_ss_blocs).val, (result_ss_blocs).incert) as j
    from in_use where id = id_loop and name like '%_c')
    select into sum_values jsonb_agg(gas.name, gas.j) as gas, jsonb_agg(exploit.name, exploit.j) as exploit, 
    jsonb_agg(constr.name, constr.j) as constr from gas, exploit, constr;

    -- Add the result to the JSONB object
    res := jsonb_set(res, array['total'], sum_values.gas, true);
    res := jsonb_set(res, array['total'], sum_values.exploit, true);
    res := jsonb_set(res, array['total'], sum_values.constr, true);

    return res;
end;
$$;