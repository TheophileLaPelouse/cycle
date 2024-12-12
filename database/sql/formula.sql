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
    elseif new_val is null then 
        return sum ;
    end if ;
    if sum_val + new_val = 0 then 
        return array[0.0, 0.0] ;
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
    links_up2 integer[] ;
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
    c integer := 1 ; 
begin 
    select into b_typ_fils b_type from ___.bloc where id = id_bloc ;
    select into links_up array_agg(api.link.up) from api.link where down = id_bloc and model = model_bloc ;
    select into links_up array_agg(id order by (st_area(geom_ref)) asc) from api.bloc 
    where id = any(links_up) ; 
    -- -- --raise  notice 'id_bloc = %', (select name from ___.bloc where id = id_bloc) ;  
    -- -- --raise  notice 'links_up = %', links_up ;
    if array_length(links_up, 1) = 0 or links_up is null then 
        return false ;
    else 
    n = array_length(links_up, 1) ;
    i = 1; 
    while i < n+1 loop
        up_ = links_up[i] ;
        -- -- --raise  notice 'up_ = %', up_ ;
        select into b_typ b_type from ___.bloc where id = up_ ;
        -- -- --raise  notice 'b_typ = %', b_typ ;

        select into colnames outputs from api.input_output where b_type = b_typ ;

        if b_typ::varchar = 'lien' then 
            select into links_up2 array_agg(api.link.up) from api.link where down = up_ and model = model_bloc 
            and 'lien' != (select b_type from api.bloc where id = api.link.up)::varchar  ;
            select into links_up2 array_agg(id order by (st_area(geom_ref)) asc) from api.bloc 
            where id = any(links_up2) ;
            links_up := array_cat(links_up, links_up2) ;  
            
            n := array_length(links_up, 1) ;
        end if ;
        -- -- --raise  notice 'links_up2 = %', links_up ;
        -- -- --raise  notice 'colnames = %', colnames ;
        if colnames is not null then 
        foreach col in array colnames loop
            query = 'select '||col||' from ___.'||b_typ||'_bloc where id = $1 ;' ;
            execute query into inp_col using up_ ;
            -- -- --raise  notice 'inp_col = %', inp_col ;
            if inp_col is not null then 
                if col like '%_s' then 
                    if left(col, -2) in (select unnest(inputs) from api.input_output where b_type = b_typ_fils) then
                        col := left(col, -2) ;
                    elseif left(col, -2)||'_e' in (select unnest(inputs) from api.input_output where b_type = b_typ_fils) then 
                        col := left(col, -2)||'_e' ;
                    end if ;
                end if ;
                -- -- --raise  notice 'col = %', col ;
                if col in (select unnest(inputs) from api.input_output where b_type = b_typ_fils) then 
                    -- -- --raise  notice 'Bonjour ?' ;
                    if not exists(select 1 from inp_out where name = col) then 
                        insert into inp_out(name, val) values (col, inp_col) ;
                        flag := true ;
                    else 
                        update inp_out set val = inp_col where name = col and (val is null or b_typ = 'source') ;
                        if found then 
                            flag := true ;
                    end if ;
                    -- update inp_out set val = inp_col where name = col and val is null ;
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

create or replace function formula.read_formula(formula text)
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
    select into to_return array_agg(elem) from unnest(list) as elem where elem !~ '^[0-9]*(\.[0-9]+)?$'  ;
    return to_return ;
end ;
$$ ;

create or replace function formula.prio(op varchar)
returns integer
language plpgsql
as $$
begin
    if op = '^' then return 4 ;
    elseif op = '>' then return 3 ;
    elseif op = '<' then return 3 ;
    elseif op = '*' then return 2 ;
    elseif op = '/' then return 2 ;
    elseif op = '+' then return 1 ;
    elseif op = '-' then return 1 ;
    else return 0 ;
    end if ;
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
        for j in 1..len_sb loop
            resized[i*new_size+j] := tab[i*len_sb+j] ;
        end loop ;
        -- resized[i*new_size+1:i*new_size+len_sb] := tab[i*len_sb+1:i*len_sb+len_sb] ;
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
    k integer ;
    symbols varchar[] := array['^', '>', '<', '*', '/', '+', '-', ''] ; 
    prio integer[] :=array[4,3,3,2,2,1,1,0] ;
    temp_op varchar ;
    temp_op2 varchar ;
    k2 integer ;
    shift integer ;
begin 
    -- fonction qui réécrit une formule sous forme lisibles sans ambiguités : Notation polonaise inversée 
    -- on a (a+b)*c qui devient a b + * alors que a+b*c devient a b c * + -> plus besoin de parenthèses
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
    --raise  notice 'args finale %', args ;
    for i in 1..j loop 
        --raise  notice'args %', args[i] ;
        if args[i] = '(' then 
            len := array_length(calc, 1) ; 
            if len < (idx + 1)*calc_sb_len then 
                calc := array_cat(calc, array_fill(''::text, array[calc_sb_len])) ;
                calc_length := array_append(calc_length, 0) ;
            else 
                for k in 1..calc_sb_len loop 
                    calc[idx*calc_sb_len+k] := '' ;
                end loop ;
                -- calc[idx*calc_sb_len+1:(idx+1)*calc_sb_len] = array_fill(''::text, array[calc_sb_len]) ;
                calc_length[idx+1] := 0 ;
            end if ; 
            flag_op := array_append(flag_op, false) ;
            len := array_length(last_op, 1) ;
            if len < (idx + 1)*last_op_sb_len then
                last_op := array_cat(last_op, array_fill(''::text, array[last_op_sb_len])) ;
                last_op_length := array_append(last_op_length, 0) ;
            else
                for k in 1..last_op_sb_len loop 
                    last_op[idx*last_op_sb_len+k] := '' ;
                end loop ;
                -- last_op[idx*last_op_sb_len+1:(idx+1)*last_op_sb_len] = array_fill(''::text, array[last_op_sb_len]) ;
                last_op_length[idx+1] := 0 ;
            end if ;
            idx := idx + 1 ; 
        elseif args[i] = ')' then 
            if calc_length[idx] + last_op_length[idx] > calc_sb_len then 
                calc := formula.resize_array(calc, calc_sb_len, 2*(calc_length[idx] + last_op_length[idx])) ;
                calc_sb_len := 2*(calc_length[idx] + last_op_length[idx]) ;
            end if ; 
            -- -- --raise  notice 'là1' ;
            if 1 <= last_op_length[idx] then
                for k in 1..last_op_length[idx] loop 
                    calc[(idx-1)*calc_sb_len+calc_length[idx]+k] := last_op[(idx-1)*last_op_sb_len+k] ;
                end loop ;
                -- calc[(idx-1)*calc_sb_len+calc_length[idx]+1:(idx-1)*calc_sb_len+calc_length[idx]+last_op_length[idx]] := last_op[(idx-1)*last_op_sb_len+1:(idx-1)*last_op_sb_len+last_op_length[idx]] ;
                calc_length[idx] := calc_length[idx] + last_op_length[idx] ;
            end if ;
            if calc_length[idx] + calc_length[idx - 1] > calc_sb_len then 
                calc := formula.resize_array(calc, calc_sb_len, 2*(calc_length[idx] + calc_length[idx-1])) ;
                calc_sb_len := 2*(calc_length[idx] + calc_length[idx-1]) ;
            end if ; 
            -- -- --raise  notice 'calc_length %', calc_length ;
            -- -- --raise  notice 'là % < %', (idx-2)*calc_sb_len+calc_length[idx-1]+1, (idx-2)*calc_sb_len+calc_length[idx-1]+calc_length[idx] ;
            for k in 1..calc_length[idx] loop 
                calc[(idx-2)*calc_sb_len+calc_length[idx-1]+k] := calc[(idx-1)*calc_sb_len+k] ;
            end loop ;
            -- calc[(idx-2)*calc_sb_len+calc_length[idx-1]+1:(idx-2)*calc_sb_len+calc_length[idx-1]+calc_length[idx]] := calc[(idx-1)*calc_sb_len+1:(idx-1)*calc_sb_len+calc_length[idx]] ;
            calc_length[idx-1] := calc_length[idx-1] + calc_length[idx] ;
            flag_op = array_remove(flag_op, flag_op[idx]) ;
            idx := idx - 1 ;
        elseif not args[i] ~ pat and not args[i] = '' then 
            if calc_length[idx]+1 > calc_sb_len then 
                calc := formula.resize_array(calc, calc_sb_len, 2*(calc_length[idx]+1)) ;
                calc_sb_len := 2*(calc_length[idx]+1) ;
            end if ;
            calc[(idx-1)*calc_sb_len+calc_length[idx]+1] := args[i];
            calc_length[idx] := calc_length[idx] + 1 ;
        elseif args[i] ~ pat then
            if args[i] = '-' and args[i-1] ~ pat then 
                if calc_length[idx]+1 > calc_sb_len then 
                    calc := formula.resize_array(calc, calc_sb_len, 2*(calc_length[idx]+1)) ;
                    calc_sb_len := 2*(calc_length[idx]+1) ;
                end if ;
                calc[(idx-1)*calc_sb_len+calc_length[idx]+1] := '0';
                calc_length[idx] := calc_length[idx] + 1 ;
            end if ;

            -- if last_op_length[idx] > 0 then 
            --     prioritized := last_op[(idx-1)*last_op_sb_len+1] ;
            -- else 
            --     prioritized := '' ;
            --     flag_op[idx] := false ;
            -- end if ;
            if last_op_length[idx] + 1 > last_op_sb_len then 
                last_op := formula.resize_array(last_op, last_op_sb_len, 2*(last_op_length[idx]+1)) ;
                last_op_sb_len := 2*(last_op_length[idx]+1) ;
            end if ;
            -- -- --raise  notice 'last_op %, args %', last_op, args[i] ;
            -- -- --raise  notice 'idx %', idx ; 

            k2 := 0 ;
            -- --raise  notice'last_op to modif %', last_op[(idx-1)*last_op_sb_len+1:idx*last_op_sb_len] ;
            for k in 1..last_op_length[idx] loop 
                --raise  notice'k %, last_op %, k2 %', k, last_op[(idx-1)*last_op_sb_len+k], k2 ;
                -- --raise  notice'args %', args[i] ;
                -- --raise  notice'prio %', formula.prio(last_op[(idx-1)*last_op_sb_len+k]) < formula.prio(args[i]) ;
                if k2 > k then 
                    --raise  notice'temp_op %', temp_op ;
                    temp_op2 := last_op[(idx-1)*last_op_sb_len+k] ;
                    --raise  notice'temp_op2 %', temp_op2 ;
                    last_op[(idx-1)*last_op_sb_len+k] := temp_op ; 
                    temp_op := temp_op2 ;
                    k2 := k2 + 1 ;
                elseif formula.prio(last_op[(idx-1)*last_op_sb_len+k]) < formula.prio(args[i]) then 
                    shift = k ; 
                    temp_op := last_op[(idx-1)*last_op_sb_len+k] ;
                    last_op[(idx-1)*last_op_sb_len+k] := args[i] ;
                    k2 := k+2 ; -- k2 = k + 1 dans la boucle suivante
                end if ; 
            end loop ;
            k2 := k2 - 1 ; -- k2 incrémenté une fois de plus car dans la boucle
            --raise  notice 'après la boucle k %, k2 %, temp_op %', last_op_length[idx], k2, temp_op ; 
            if k2 > last_op_length[idx] then 
                last_op[(idx-1)*last_op_sb_len+k2] := temp_op ;
            else 
                last_op[(idx-1)*last_op_sb_len+last_op_length[idx]+1] := args[i] ;
                shift := last_op_length[idx] + 1 ;
            end if ; 
            flag_op[idx] := (shift is not null and shift != 1) ;
            last_op_length[idx] := last_op_length[idx] + 1 ;
            -- --raise  notice'last_op modified %', last_op[(idx-1)*last_op_sb_len+1:(idx-1)*last_op_sb_len+last_op_length[idx]] ;
            -- --raise  notice'length after insert %', last_op_length ;
            -- à tester
            -- last_op[(idx-1)*last_op_sb_len+1:idx*last_op_sb_len] := formula.insert_op(last_op[(idx-1)*last_op_sb_len+1:idx*last_op_sb_len], args[i]) ;

            if flag_op[idx] then 
                if calc_length[idx] + shift > calc_sb_len then 
                    calc := formula.resize_array(calc, calc_sb_len, 2*(calc_length[idx]+shift)) ;
                    calc_sb_len := 2*(calc_length[idx]+shift) ;
                end if ;
                for k in 1..shift-1 loop 
                    calc[(idx-1)*calc_sb_len+calc_length[idx]+k] := last_op[(idx-1)*last_op_sb_len+k] ;
                end loop ;
                -- calc[(idx-1)*calc_sb_len+calc_length[idx]+1] := last_op[(idx-1)*last_op_sb_len+1] ;
                for k in 1..last_op_length[idx]-(shift-1) loop 
                    last_op[(idx-1)*last_op_sb_len+k] := last_op[(idx-1)*last_op_sb_len+k+shift-1] ;
                end loop ;
                -- last_op[(idx-1)*last_op_sb_len+1:idx*last_op_sb_len-1] := last_op[(idx-1)*last_op_sb_len+2:idx*last_op_sb_len] ;
                last_op_length[idx] := last_op_length[idx] - (shift-1) ;
                calc_length[idx] := calc_length[idx] + shift-1 ;
                flag_op[idx] := false ;
            end if ;
        end if ;
        --raise  notice 'idx %', idx ;
        --raise  notice 'calc %', calc[(idx-1)*calc_sb_len+1:(idx-1)*calc_sb_len+calc_length[idx]] ;
        --raise  notice'last_op %', last_op[(idx-1)*last_op_sb_len+1:(idx-1)*last_op_sb_len+last_op_length[idx]] ;
        --raise  notice'calc_length %, last_op_length %', calc_length, last_op_length ;
    end loop ;
    if calc_length[idx] + last_op_length[idx] > calc_sb_len then 
        calc := formula.resize_array(calc, calc_sb_len, (calc_length[idx] + last_op_length[idx])+1) ;
    end if ;
    if 1 <= last_op_length[idx] then 
        for k in 1..last_op_length[idx] loop 
            calc[(idx-1)*calc_sb_len+calc_length[idx]+k] := last_op[(idx-1)*last_op_sb_len+k] ;
        end loop ;
        -- calc[(idx-1)*calc_sb_len+calc_length[idx]+1:(idx-1)*calc_sb_len+calc_length[idx]+last_op_length[idx]] := last_op[(idx-1)*last_op_sb_len+1:(idx-1)*last_op_sb_len+last_op_length[idx]] ;
        calc_length[idx] := calc_length[idx] + last_op_length[idx] ;
    end if ; 
    -- --raise  notice'expr début %', expr ; 
    -- --raise  notice'calc final %', calc[(idx-1)*calc_sb_len+1:calc_length[idx]] ;
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
    to_debug varchar[] ; 
    new varchar ;
    pat varchar := '[\+\-\*\/\^\>\<]' ;
    new_val real; 
    new_incert real; 
    result ___.res ; 
begin 
    n = array_length(calc, 1) ;
    --raise  notice 'n %', n ;
    calc_val := array_fill(0.0, array[n]) ;
    calc_incert := array_fill(0.0, array[n]) ;
    to_debug := array_fill(''::varchar, array[n]) ;
    deb := 1 ;
    fin := 0 ;
    if n = 0 then return result ; end if ;
    i := 1 ;
    --raise  notice 'calc %', calc ;
    query := '' ;
    while i < n+1 loop
        new := calc[i] ;
        i:=i+1 ;
        if new ~ pat then 
            -- --raise  notice 'on a un pattern %' , new ; 
            -- On récupère les deux valeurs de calcul
            val1 := calc_val[fin-1] ;
            incert1 := calc_incert[fin-1] ;

            val2 := calc_val[fin] ;
            incert2 := calc_incert[fin] ;

            to_debug[fin-1] := to_debug[fin-1] || ' ' || new || ' ' || to_debug[fin] ;
            -- --raise  notice 'val1 = %, incert1 = %, val2 = %, incert2 = %', val1, incert1, val2, incert2;
            fin := fin - 1 ;
            -- On calcule à chaque fois les incertitudes relatives et les valeurs réelles 
            case
            when new = '+' then 
                -- somme des incertitudes
                new_val := val1 + val2 ;
                -- --raise  notice 'ici 7, val1 = %, incert1 = %, val2 = %, incert2 = %', val1, incert1, val2, incert2;
                if val1 + val2 = 0 then 
                    new_incert := 0.0 ;
                else 
                    new_incert := (incert1*val1 + incert2*val2)/(val1 + val2) ;
                end if ;
                
                -- --raise  notice 'ici 8, val1 = %, incert1 = %, val2 = %, incert2 = %', val1, incert1, val2, incert2;
            when new = '-' then 
                -- --raise  notice 'ici 6, val1 = %, incert1 = %, val2 = %, incert2 = %', val1, incert1, val2, incert2;
                new_val := val1 - val2 ;
                -- --raise  notice 'ici 5, val1 = %, incert1 = %, val2 = %, incert2 = %', val1, incert1, val2, incert2;
                if val1 - val2 = 0 then 
                    new_incert := 0.0 ;
                else 
                    new_incert := (incert1*val1 + incert2*val2)/(val1 - val2) ;
                end if ;
            when new = '*' then
                new_val := val1 * val2 ;
                new_incert := sqrt(incert1^2 + incert2^2) ;
            when new = '/' then
                -- --raise  notice 'ici 1, val1 = %, incert1 = %, val2 = %, incert2 = %', val1, incert1, val2, incert2;
                if val2 = 0 then 
                    new_val = null ;
                else 
                    new_val := val1 / val2 ;
                end if ;
                -- new_val := val1 / val2 ;
                -- --raise  notice 'ici 2, val1 = %, incert1 = %, val2 = %, incert2 = %', val1, incert1, val2, incert2;
                new_incert := sqrt(incert1^2 + incert2^2) ;
            when new = '^' then
                raise  notice 'ici 3, val1 = %, incert1 = %, val2 = %, incert2 = %', val1, incert1, val2, incert2;
                new_val := val1 ^ val2 ;
                raise  notice 'ici 4, val1 = %, incert1 = %, val2 = %, incert2 = %', val1, incert1, val2, incert2;   
                new_incert := abs(val2) * incert1 ;
            when new = '>' then
                -- --raise  notice 'ici 11, val1 = %, incert1 = %, val2 = %, incert2 = %', val1, incert1, val2, incert2;   
                new_val := (val1 > val2)::int::real ;
                -- --raise  notice 'là2 ?' ;
                new_incert := 0.0 ;
            when new = '<' then
                -- --raise  notice 'ici 11, val1 = %, incert1 = %, val2 = %, incert2 = %', val1, incert1, val2, incert2;   
                new_val := (val1 < val2)::int::real ;
                -- --raise  notice 'là ?' ; 
                new_incert := 0.0 ;
            end case ;
            -- --raise  notice 'ici 9, val1 = %, incert1 = %', new_val, new_incert; 
            calc_val[fin] := new_val ;
            -- --raise  notice 'ici 10, val1 = %, incert1 = %', new_val, new_incert; 
            calc_incert[fin] := new_incert ;
            -- --raise  notice 'vent'  ;
        elseif new != '' then
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
            to_debug[fin] := new ;
            
        end if ;
        raise  notice 'new %', new ;
        raise  notice 'calc_val %', calc_val[:fin] ;
        raise  notice 'calc_incert %', calc_incert[:fin] ;
        raise  notice 'already calculated %', to_debug[:fin] ;
        raise  notice 'suite %', calc[i:i+10] ; 
    end loop ; 
    -- raise  notice 'val %', calc_val[fin] ;
    -- raise  notice 'incert %', calc_incert[fin] ;
    --raise   notice 'to_debug %', to_debug ;
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
    colnames varchar[] ;
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

    -- select into colnames array_agg(name) from inp_out ; 
    args := formula.read_formula(rightside) ;

    select into notnowns distinct array_agg(distinct elem) 
    from unnest(args) as elem 
    left join inp_out on name = elem 
    where (val is null and name = elem) 
    or (elem not in (select name from inp_out) and not elem ~ '[0-9].*');
    -- select into notnowns array_agg(name) from inp_out where val is null and name in (select unnest(args)) ;
    --raise  notice 'args = %', args ;
    --raise  notice 'unknowns = %', notnowns ;
    --raise  notice 'unknwons is unknown %', (select jsonb_object_agg(name, val is null)) from inp_out where name = any(notnowns) ;

    if array_length(notnowns, 1) > 0 then
        if exists (select 1 from ___.results where name = to_calc and ___.results.formula = formul and id = id_bloc) then
            update ___.results set val=null, unknowns = notnowns where name = to_calc and ___.results.formula = formul and id = id_bloc ;
        else 
            insert into ___.results(id, name, detail_level, formula, unknowns) values (id_bloc, to_calc, detail_level, formul, notnowns) ;
        end if ; 
    else 
        -- -- --raise  notice 'calc %', formula.write_formula(rightside) ;
        result := formula.calc_incertitudes(formula.write_formula(rightside)) ;
        
        if exists (select 1 from ___.results where name = to_calc and ___.results.formula = formul and id = id_bloc) then 
            update ___.results set val = result, unknowns = null where name = to_calc and ___.results.formula = formul and id = id_bloc ;
        else
            insert into ___.results(id, name, detail_level, val, formula) values (id_bloc, to_calc, detail_level, result, formul) ;
        end if ; 
        -- On update inp_out pour les futurs calculs si besoin 
        if not exists(select 1 from inp_out where name = to_calc) then 
            insert into inp_out(name, val, incert) values (to_calc, result.val, result.incert) ;
        else
            update inp_out set val = result.val, incert = result.incert where name = to_calc and val is null;
        end if ;
        return ;
    end if ;
end ;
$$ ;


create or replace function api.calculate_bloc(id_bloc integer, model_bloc text, on_update boolean default false)
returns varchar
language plpgsql as
$$
declare  
    b_typ ___.bloc_type ;
    concr boolean ;
    to_calc varchar ;
    detail_fifo integer ; 
    data_ varchar ; 
    bil varchar ;
    args varchar[] ; 
    f varchar ;
    detail integer ;
    c integer ; 
    result real ;
    colnames varchar[] ;
    col varchar ; 
    not_calculable_cols varchar[] := array['prod_e']::varchar[] ;
    query text ;
    items record ; 
    flag boolean := true ;
    tic timestamp ;
    tac timestamp ;
    type_ varchar ; 
    inp_out_exists boolean ;
    is_known boolean ;
    is_in_bilan boolean ;
    incertitude real ;
    duree_vie real ;
begin 
    -- --raise  notice E'\nOn calcul pour %\n', (select name from ___.bloc where id = id_bloc) ;
    if (select b_type from ___.bloc where id = id_bloc) = 'source' then 
        -- --raise  notice 'qe_s source = %', (select qe_s from ___.source_bloc where id = id_bloc) ;
    end if ;
    -- -- --raise  notice 'id_bloc = %, model_bloc = %', id_bloc, model_bloc ;
    -- tic := clock_timestamp() ;
    select into b_typ b_type from ___.bloc where id = id_bloc and model = model_bloc ;
    select into concr concrete from api.input_output where b_type = b_typ ;
    if not concr then 
        return 'No calculation for link or sur_bloc' ;
    end if ;
    if exists(select 1 from api.input_output where b_type = b_typ and 'd_vie'=any(inputs)) then 
        query := 'select d_vie from api.'||b_typ||'_bloc where id = $1 ;' ;
        execute query into duree_vie using id_bloc ;
    else
        duree_vie := 0.0 ;
    end if ;
    -- -- --raise  notice 'b_typ = %', b_typ ;
    
    -- inp_out est une table qui contient toutes les valeurs qui pourraient servir pour appliquer une formule.
    create temp table inp_out(name varchar, val real, incert real default 0) on commit drop; 
    -- -- --raise  notice 'b_typ = %', b_typ ;
    -- -- --raise  notice 'input_output = %', (select inputs from api.input_output where b_type = b_typ) ;
    select array_agg(column_name) into colnames from information_schema.columns, api.input_output  
    where table_name = b_typ||'_bloc' and table_schema = '___' and 
    b_type = b_typ and (column_name = any(inputs) or column_name = any(outputs)) ;
    -- -- --raise  notice 'colnames = %', colnames ;
    foreach col in array colnames loop
        if not col=any(not_calculable_cols) then  
            select data_type from information_schema.columns where table_name = b_typ||'_bloc' and column_name = col limit 1 into type_ ; 
            --raise  notice 'name %, type = %', col, type_ ;
            if type_ = 'USER-DEFINED' then
                query := 'select '''||col||''' as name, '||col||'_fe::real as val from api.'||b_typ||'_bloc where id = $1 ; '  ; 
                raise notice 'query = %, argument %', query, id_bloc ;
                execute query into items using id_bloc ;
                -- --raise  notice 'ICI à vérifier' ;
                query := 'select incert from api.'||col||'_type_table where fe = $1 ;'; 
                raise notice 'query2 = %', query ;
                execute query into incertitude using items.val ;
            else 
                if type_ = 'boolean' then 
                    query := 'select '''||col||''' as name, '||col||'::int::real as val from ___.'||b_typ||'_bloc where id = $1 ; '  ; 
                else
                    query := 'select '''||col||''' as name, '||col||'::real as val from ___.'||b_typ||'_bloc where id = $1 ; '  ; 
                end if ; 
                execute query into items using id_bloc ;
                incertitude := 0.0 ;
            end if ;
            insert into inp_out(name, val, incert) values (items.name, items.val, incertitude) ;
        --raise  notice 'items = %', items ;
        end if ;
    end loop ;
    insert into inp_out(name, val, incert) select name, val, incert from ___.global_values ;
    flag := api.recup_entree(id_bloc, model_bloc) ;
    -- -- --raise  notice 'flag = %', flag ;
    -- -- --raise  notice 'inp_out = %', (select jsonb_object_agg(name, val) from inp_out) ;
    if not flag and on_update then
        drop table inp_out ;
        return 'No new entry' ;
    end if ;  

    create temp table bilan(leftside varchar, calc_with varchar[], formula varchar, detail_level integer) on commit drop;
    
    with bloc_formula as (select formula, detail_level from api.formulas where name in (select unnest(default_formulas) from api.input_output where b_type = b_typ))
    insert into bilan(leftside, calc_with, formula, detail_level) 
    select trim(both ' ' from split_part(formula, '=', 1)), formula.read_formula(split_part(formula, '=', 2)), formula, detail_level from bloc_formula ;

    -- for items in (select * from bilan) loop
    --     -- --raise  notice 'items bilan = %', items ;
    -- end loop ;

    create temp table known_data(leftside varchar, detail_level integer default null, known boolean default false) on commit drop;
    -- On ajoute les données connues dans known_data (typiquement tbentrant qui pourrait être calculé par une autre formules)
    for to_calc in (select leftside from bilan) loop
        insert into known_data(leftside, known, detail_level) select name, true, 7 from inp_out where val is not null and name = to_calc ;
    end loop ; 
    -- On pourrait tout ajouter d'un coup mais ça fait un gros knwown_data et optimiser des fois c'est bien.
    -- create temp table results(name varchar, detail_level integer, val real) on commit drop ; 
    tac := clock_timestamp() ;
    
    for data_, args, detail in (select leftside, calc_with, detail_level from bilan) loop
        -- -- --raise  notice E'data_ = %, args = %, detail= %\n', data_, args, detail ;
        create temp table treatment_lifo(id serial primary key, value varchar) ; 
        create temp table fifo(id serial primary key, value varchar) ; 
        insert into fifo(value) values (data_) ;
        c := 0 ; 
        -- On fait un parcours de graph en profondeur avec treatment_lifo pour calculer les inconnus (le graphs représente le système d'équations)
        -- A noter que le système est très simple de type a = f(b), b = g(c)... On ne résout pas de sytème type a = f(a, b), b = g(a, b). (l'amélioration pourrait se faire)
        while c < 10000 and (select count(*) from fifo) > 0 loop
            c := c + 1 ;
            to_calc := formula.pop('fifo') ;
            is_known := (to_calc in (select leftside from known_data where known = true and detail_level=detail)) ;
            is_in_bilan := (to_calc in (select leftside from bilan where detail_level = detail)) ;
            -- raise  notice 'to_calc = %, is_known = %, is_in_bilan = %', to_calc, is_known, is_in_bilan ;
            if (not is_known or is_known is null) and is_in_bilan then
                insert into treatment_lifo(value) values (to_calc) ;
                if not exists(select 1 from known_data where leftside = to_calc and detail_level = detail) then
                    insert into known_data(leftside, known, detail_level) values (to_calc, true, detail) ;
                end if ;
                insert into fifo(value) select elem from unnest(args) as elem where elem not in (select leftside from known_data where known = true) ;
            end if ;
            -- raise  notice 'fifo_calc = %', (select jsonb_object_agg(id, value) from fifo) ;
            -- raise  notice 'c = %, to_calc = %', c, to_calc ;
            -- raise  notice 'known_data = %', (select leftside from known_data where leftside = to_calc and detail_level=detail) ;
        end loop ;
        raise notice 'knwn_datas %', (select jsonb_object_agg(leftside, detail_level) from known_data) ;
        if c = 10000 then 
            --raise  exception 'Too many iterations' ;
        end if ;
    
        c := 0 ; 
        raise  notice 'treatment_lifo = %', (select jsonb_object_agg(id, value) from treatment_lifo) ;
        while c < 10000 and (select count(*) from treatment_lifo) > 0 loop
            c := c + 1 ;
            to_calc := formula.pop('treatment_lifo', true) ;
            for f in (select formula from bilan where leftside = to_calc and detail_level=detail) loop
                -- -- --raise  notice 'f = %', f ;
                -- update tableau ___.result et inp_out
                perform formula.calculate_formula(f, id_bloc, detail, to_calc) ;
                -- insert into ___.results(id, name, detail_level, val, formula) values (id_bloc, to_calc, detail, result, f) ;
            end loop ;
            update inp_out set val = (___.results.val).val, incert = (___.results.val).incert from ___.results 
            where inp_out.name = to_calc 
            and ___.results.name = to_calc and ___.results.id = id_bloc and ___.results.detail_level = detail 
            and detail = (select max(detail_level) from known_data where leftside = to_calc) ;
            -- -- --raise  notice 'to_calc = %, result = %', to_calc, (select val from inp_out where name = to_calc) ;
        end loop ;
        if c = 10000 then 
            --raise  exception 'Too many iterations' ;
        end if ;
        drop table fifo ;
        drop table treatment_lifo ;
    end loop ;
    
    -- update b_typ_bloc 
    foreach col in array colnames loop
        select data_type from information_schema.columns where table_name = b_typ||'_bloc' and column_name = col limit 1 into type_ ; 
        if type_ = 'boolean' then 
            query := 'update ___.'||b_typ||'_bloc set '||col||' = (select val from inp_out where name = '''||col||''' and val is not null)::int::boolean 
            where id = '||id_bloc||' and '||col||' is null;' ; 
            execute query ;
        elseif type_ != 'USER-DEFINED' then 
            query := 'update ___.'||b_typ||'_bloc set '||col||' = (select val from inp_out where name = '''||col||''' and val is not null) 
            where id = '||id_bloc||' and '||col||' is null;' ; 
            execute query ;
        end if ;
    end loop ;
    drop table inp_out ;
    drop table bilan ;
    drop table known_data ;
    foreach to_calc in array array['co2_e', 'co2_c', 'ch4_e', 'ch4_c', 'n2o_e', 'n2o_c']::varchar[] loop
        if to_calc not in (select name from ___.results where id = id_bloc) then
            insert into ___.results(id, name, val) values (id_bloc, to_calc, row(0, 0)::___.res) ;
        end if ;
    end loop ;
    update ___.results set d_vie = duree_vie where id = id_bloc ;
    tac := clock_timestamp() ;
    -- -- --raise  notice 'Time to calculate = %', tac - tic ;
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
    c integer ; 
    count integer ; 
begin
-- Recalcul les émissions en fonction des liens entre les blocs.
    -- --raise  notice 'On update les blocs pour %', (select name from ___.bloc where id = id_bloc) ;
    create temp table fifo2(id serial primary key, value integer) on commit drop;
    for downs in (select down from api.link where up = id_bloc and model = model_name)
    loop
        insert into fifo2(value) values (downs) ;
    end loop;
    select into count count(*) from fifo2 ;
    if deleted then
        delete from api.link where up = id_bloc and model = model_name ;
    end if ;
    c := 0 ;
    while c < count and c < 1000
    loop
        c := c + 1 ;
        -- --raise  notice 'c = % count = %', c, count ;
        -- --raise  notice 'fifo2 = %', (select array_agg(value) from fifo2) ;
        select into new_up value from fifo2 where id = c ;
        -- --raise  notice 'new_up = %', new_up ;
        if deleted then 
        -- On doit tout recalculer donc on_update = False pour être sûr de refaire tout le calcul
            perform api.calculate_bloc(new_up, model_name, false) ; 
        else 
        -- On doit tout recalculer si il y a eu des modifications
            perform api.calculate_bloc(new_up, model_name, true) ;
        end if ; 
        perform api.update_results_ss_bloc(new_up, (select sur_bloc from ___.bloc where id = new_up)) ; 
        -- -- --raise  notice 'downs = %', (select array_agg(down) from api.link where up = new_up and model = model_name) ;
        for downs in (select down from api.link where up = new_up and model = model_name)
        loop
            if downs not in (select value from fifo2) then 
                insert into fifo2(value) values (downs) ;
                count := count + 1 ;
            end if ;
        end loop ;
        -- --raise  notice 'count final = %', count ;
    end loop ;
    if c = 100 then 
        --raise  exception 'Too many iterations' ;
    end if ;
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
    s_an ___.res ;
    s_intrant_an ___.res ;
    keys varchar[] := array['co2_e', 'co2_c', 'ch4_e', 'ch4_c', 'n2o_e', 'n2o_c'] ;
    k varchar ;
    f varchar ; 
    res ___.res ;
    res_intrant ___.res ;
    res_an ___.res ;
    res_intrant_an ___.res ;
    items record ;
    flag boolean := true ;
    flag_intrant boolean := false ;
    detail_l integer ; 
    details integer[] ; 
    n_sb boolean;
	b_typ ___.bloc_type ;
    concr boolean ;
begin   
    if (select b_type from ___.bloc where id = id_bloc) = 'sur_bloc' then 
        -- --raise  notice E'\n Là faut regarder attentivement \n' ;
    end if ;
    foreach k in array keys loop
        -- -- --raise  notice E'\nk = %', k ;
        select array_length(ss_blocs, 1) > 0 into n_sb from ___.bloc where id = id_bloc ;
        if n_sb is null or not n_sb then
            with somme as (select formula.sum_incert((val).val, (val).incert) as val from ___.results where name = k and id = id_bloc and detail_level = 6)
            update ___.results set result_ss_blocs_intrant = (select somme.val from somme) where name = k and id = id_bloc ;

            with max_detail as (select max(detail_level) as max_detail from ___.results 
            where name = k and id = id_bloc and val is not null and detail_level < 6), 
            somme as (select formula.sum_incert((val).val, (val).incert) as val from ___.results, max_detail 
            where name = k and id = id_bloc and detail_level = max_detail.max_detail)
            update ___.results set result_ss_blocs = (select somme.val from somme) 
            where name = k and id = id_bloc ;

            if k like '%_c' then 
            -- On met un coalesce au cas où d_vie soit nul et sinon ça ne va pas changer quoi que ce soit comme on va se référer à ce qui ne concerne pas d_vie
                update ___.results set 
                    result_ss_blocs_intrant_an = row(coalesce((result_ss_blocs_intrant).val/d_vie, 0.0), coalesce((result_ss_blocs_intrant).incert, 0.0))::___.res, 
                    result_ss_blocs_an = row(coalesce((result_ss_blocs).val/d_vie, 0.0), coalesce((result_ss_blocs).incert, 0.0))::___.res  
                    where name = k and id = id_bloc ;
            elseif k like '%_e' then 
                update ___.results set 
                    result_ss_blocs_intrant_an = coalesce(result_ss_blocs_intrant, row(0.0, 0.0)::___.res), 
                    result_ss_blocs_an = coalesce(result_ss_blocs, row(0.0, 0.0)::___.res) where name = k and id = id_bloc ;
            end if ;

        else
            flag := true ;
            flag_intrant := true ;
            s := row(0, 0)::___.res ;
            s_intrant := row(0, 0)::___.res ;
            s_an := row(0, 0)::___.res ;
            s_intrant_an := row(0, 0)::___.res ;
            for sb in (select unnest(ss_blocs) from ___.bloc where id = id_bloc) loop 
                select into b_typ b_type from api.bloc where id = sb ;
                select into concr concrete from api.input_output where b_type = b_typ ;
                -- --raise  notice 'sb = %, b_typ = %, concr = %', sb, b_typ, concr ;
                if concr or b_typ = 'sur_bloc' then
                    -- On part du principe que les sous blocs sont cleans 
                    select into items result_ss_blocs_intrant from ___.results where name = k and id = sb and detail_level = 6 
                    and result_ss_blocs_intrant is not null ;
                    res_intrant.val := (items.result_ss_blocs_intrant).val ;
                    res_intrant.incert := (items.result_ss_blocs_intrant).incert ;
                    select into items result_ss_blocs from ___.results where name = k and id = sb and result_ss_blocs is not null ;
                    res.val := (items.result_ss_blocs).val ;
                    res.incert := (items.result_ss_blocs).incert ;
                    select into items result_ss_blocs_an from ___.results where name = k and id = sb and result_ss_blocs is not null ;
                    res_an.val := (items.result_ss_blocs_an).val ;
                    res_an.incert := (items.result_ss_blocs_an).incert ;
                    select into items result_ss_blocs_intrant_an from ___.results where name = k and id = sb and detail_level = 6 
                    and result_ss_blocs_intrant is not null ;
                    res_intrant_an.val := (items.result_ss_blocs_intrant_an).val ;
                    res_intrant_an.incert := (items.result_ss_blocs_intrant_an).incert ;
                    -- --raise  notice 'res = %, res_intrant = %', res, res_intrant ;
                    -- Pour la suite normalement si ce qui concerne result_ss_blocs est null alors si on rajoute d_vie c'est pareil. (d_vie est nulle que si un bloc n'a pas de valeur de constuction et donc on est bon)
                    if res_intrant is not null then 
                        s_intrant := ___.add(s_intrant, res_intrant) ;
                        s_intrant_an := ___.add(s_intrant_an, res_intrant_an) ;
                    else 
                        flag_intrant := false ;
                    end if ;
                    if res is not null then 
                        s := ___.add(s, res) ; 
                        s_an := ___.add(s_an, res_an) ;                    
                    else 
                        flag := false ;
                    end if ;
                end if ;
            end loop ;
            if flag then 
                -- --raise  notice 's = %', s ;
                if not exists(select 1 from ___.results where name = k and id = id_bloc) then
                    insert into ___.results(id, name, result_ss_blocs, result_ss_blocs_an) values (id_bloc, k, s, s_an) ;
                else
                    update ___.results set result_ss_blocs = s, result_ss_blocs_an = s_an where name = k and id = id_bloc ;
                end if ;
            else 
                with max_detail as (select max(detail_level) as max_detail from ___.results 
                where name = k and id = id_bloc and val is not null and detail_level < 6), 
                somme as (select formula.sum_incert((val).val, (val).incert) as val from ___.results, max_detail 
                where name = k and id = id_bloc and detail_level = max_detail.max_detail)
                update ___.results set result_ss_blocs = (select somme.val from somme) 
                where name = k and id = id_bloc ;

                if k like '%_c' then 
                    update ___.results set 
                        result_ss_blocs_an = row(coalesce((result_ss_blocs).val/d_vie, 0.0), coalesce((result_ss_blocs).incert, 0.0))::___.res  
                        where name = k and id = id_bloc ;
                elseif k like '%_e' then 
                    update ___.results set 
                        result_ss_blocs_an = coalesce(result_ss_blocs, row(0.0, 0.0)::___.res) 
                        where name = k and id = id_bloc ;
                end if ;
            end if ;
            if flag_intrant then 
                if not exists(select 1 from ___.results where name = k and id = id_bloc) then
                    insert into ___.results(id, name, result_ss_blocs_intrant, result_ss_blocs_intrant_an, detail_level)
                    values (id_bloc, k, s_intrant, s_intrant_an, 6) ;
                else
                    update ___.results set result_ss_blocs_intrant = s_intrant, result_ss_blocs_intrant_an = s_intrant_an 
                    where name = k and id = id_bloc ;
                end if ;
            else 
                with somme as (select formula.sum_incert((val).val, (val).incert) as val from ___.results where name = k and id = id_bloc and detail_level = 6)
                update ___.results set result_ss_blocs_intrant = (select somme.val from somme) where name = k and id = id_bloc ;

                if k like '%_c' then 
                    update ___.results set 
                        result_ss_blocs_intrant_an = row(coalesce((result_ss_blocs_intrant).val/d_vie, 0.0), coalesce((result_ss_blocs_intrant).incert, 0.0))::___.res
                        where name = k and id = id_bloc ;
                elseif k like '%_e' then 
                    update ___.results set 
                        result_ss_blocs_intrant_an = coalesce(result_ss_blocs_intrant, row(0.0, 0.0)::___.res) 
                        where name = k and id = id_bloc ;
                end if ;
            end if ;
        end if ;
    end loop ;
    -- --raise  notice 'what the bloc %', (select name from ___.bloc where id = id_bloc) ;
    -- --raise  notice 'Results for sur_bloc : %', (select json_object_agg(name, result_ss_blocs) from ___.results where id = id_bloc) ;
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
    b_typ ___.bloc_type ;
    concr boolean ;
    c integer ;

begin
    -- --raise  notice 'On update les résultats des sur_blocs %', (select name from ___.bloc where id = id_bloc) ;
    -- --raise  notice 'old_sur_bloc = %', (select name from ___.bloc where id = old_sur_bloc) ;
    b_typ := (select b_type from ___.bloc where id = id_bloc) ;
    select into concr concrete from api.input_output where b_type = b_typ ;
    if not concr and b_typ != 'sur_bloc' then 
        return ;
    end if ;
    perform api.get_results_ss_bloc(id_bloc) ;
    if deleted then
        update ___.results set val = null, result_ss_blocs = null, result_ss_blocs_intrant = null where id = id_bloc ;
        -- -- --raise  notice 'Results deleted' ;
    end if ;
    if old_sur_bloc is null then 
        return ;
    end if ;
    create temp table fifo(id serial primary key, value integer) on commit drop ;
    insert into fifo(value) values (old_sur_bloc) ;
    sb := id_bloc ;
    c := 0 ;
    while (select count(*) from fifo) > 0 and c < 10000 loop 
        c := c + 1 ;
        container := formula.pop('fifo')::integer ;
        -- --raise  notice 'sb = %, container = %', (select name from ___.bloc where id = sb), (select name from ___.bloc where id = container) ;
        perform api.get_results_ss_bloc(container) ;
        sb := container ;
        select into container sur_bloc from ___.bloc where id = sb and sur_bloc != sb;
        -- --raise  notice 'sb2 = %, container2 = %', (select name from ___.bloc where id = sb), (select name from ___.bloc where id = container) ;
        if container is not null then 
            insert into fifo(value) values (container) ;
        end if ;
    end loop ;
    if c = 10000 then 
        --raise  exception 'Too many iterations' ;
    end if ;
    drop table fifo ; 
end ;
$$ ;




create view api.results as 
with 
useable as (select * from ___.results where val is not null and formula is not null), 
unsuable as (select * from ___.results where val is null and formula is not null), 
norm_lvl_max as (select id, name, max(detail_level) as max_lvl from useable where detail_level < 6 group by id, name), 
in_use as (select distinct useable.id, useable.name, useable.detail_level, useable.formula, co2_eq 
from useable
join norm_lvl_max on useable.id = norm_lvl_max.id and useable.name = norm_lvl_max.name
where ___.add(result_ss_blocs, result_ss_blocs_intrant) is not null 
and (useable.detail_level = norm_lvl_max.max_lvl or useable.detail_level = 6)
),
results as (select id, name, co2_eq, co2_eq_an from ___.results), 
exploit as (select distinct id, name, co2_eq from ___.results where name like '%_e'), 
constr as (select distinct id, name, co2_eq from ___.results where name like '%_c'),
res_exploit as (select id, name, formula.sum_incert((co2_eq).val, (co2_eq).incert) as co2_eq from exploit group by id, name),
res_constr as (select id, name, formula.sum_incert((co2_eq).val, (co2_eq).incert) as co2_eq from constr group by id, name ), 
res_expl_and_constr as (select id, name, formula.sum_incert((co2_eq_an).val, (co2_eq_an).incert) as co2_eq_an from results group by id, name)

select ___.results.id, ___.bloc.name, model, jsonb_build_object(
    'data', jsonb_agg(
        jsonb_build_object(
            'name', ___.results.name,
            'formula', ___.results.formula,
            'result', ___.add(___.results.result_ss_blocs, ___.results.result_ss_blocs_intrant),
            'co2_eq', ___.results.co2_eq, 
            'co2_eq_an', ___.results.co2_eq_an,
            'detail', ___.results.detail_level, 
            'unknown', ___.results.unknowns,
            'in use', case when ___.results.id = in_use.id and ___.results.name = in_use.name 
            and ___.results.detail_level = in_use.detail_level then true else false end
        )
        )
    ) as res, 
    row(max((res_exploit.co2_eq).val), max((res_exploit.co2_eq).incert))::___.res as co2_eq_e, -- il fallait juste une fonction d'aggrégat
    row(max((res_constr.co2_eq).val), max((res_constr.co2_eq).incert))::___.res as co2_eq_c, 
    row(max((res_expl_and_constr.co2_eq_an).val), max((res_expl_and_constr.co2_eq_an).incert))::___.res as co2_eq_ce
from ___.results
join ___.bloc on ___.bloc.id = ___.results.id
left join in_use on ___.results.id = in_use.id and 
___.results.name = in_use.name and ___.results.detail_level = in_use.detail_level
left join res_exploit on ___.results.id = res_exploit.id and ___.results.name = res_exploit.name
left join res_constr on ___.results.id = res_constr.id and ___.results.name = res_constr.name
left join res_expl_and_constr on ___.results.id = res_expl_and_constr.id and ___.results.name = res_expl_and_constr.name
-- where ___.results.formula is not null 
group by ___.results.id, model, ___.bloc.name;


create or replace function api.get_histo_data2(blocs_name varchar[])
returns jsonb
language plpgsql
as $$
declare
    query text;
    names varchar[] := array['n2o_c', 'n2o_e', 'ch4_c', 'ch4_e', 'co2_c', 'co2_e'];
    b_name varchar;
    item record ; 
    concr boolean;
    js1 jsonb;
    blocs integer[] ; 
    id_loop integer;
    js2 jsonb;
    res jsonb := '{}';
    k text ;
begin
    select into blocs array_agg(id) from ___.bloc where name = any(blocs_name) ;
    if array_length(blocs, 1) = 0 or blocs is null then 
        return jsonb_build_object(
        'total', jsonb_build_object(
        'ch4_c', to_jsonb(row(0, 0)::___.res),
        'ch4_e', to_jsonb(row(0, 0)::___.res),
        'co2_c', to_jsonb(row(0, 0)::___.res),
        'co2_e', to_jsonb(row(0, 0)::___.res),
        'n2o_c', to_jsonb(row(0, 0)::___.res),
        'n2o_e', to_jsonb(row(0, 0)::___.res),
        'co2_eq_c', to_jsonb(row(0, 0)::___.res),
        'co2_eq_e', to_jsonb(row(0, 0)::___.res),
        'co2_eq_ce', to_jsonb(row(0, 0)::___.res)
        )
        );
    end if ;
    foreach id_loop in array blocs loop
        select into item name, b_type from ___.bloc where id = id_loop;
        b_name := item.name ;
        select into concr concrete from api.input_output where b_type = item.b_type;
        if concr or item.b_type = 'sur_bloc' then 
            -- Calculate the sum of the values for the specified names
            with results as (
                select name, ___.add(result_ss_blocs, result_ss_blocs_intrant) as result
                from ___.results where id = id_loop and name = any(names) 
                and ___.add(result_ss_blocs, result_ss_blocs_intrant) is not null
            )
            select into js1 jsonb_object_agg(name, result) from results; 

            foreach k in array names loop
                if not js1 ? k or js1->k is null then
                    js1 := jsonb_set(js1, array[k], to_jsonb(row(0, 0)::___.res), true);
                end if;
            end loop;

            -- --raise  notice 'js1 = %', js1;
            with results as (
            select name, co2_eq, co2_eq_an 
            from ___.results where id = id_loop and name = any(names) 
            ), 
            exploit as (select distinct name, co2_eq from results where name like '%_e'),
            constr as (select distinct name, co2_eq from results where name like '%_c'), 
            exploit_and_constr as (select distinct name, co2_eq_an from results),
            json_eq as (select jsonb_build_object(
                'co2_eq_e', formula.sum_incert(coalesce((exploit.co2_eq).val, 0), coalesce((exploit.co2_eq).incert, 0)),
                'co2_eq_c', formula.sum_incert(coalesce((constr.co2_eq).val, 0), coalesce((constr.co2_eq).incert, 0))
                ) as json_eq
                from exploit
                full join constr on exploit.name = constr.name 
            ), 
            json_eq_ce as (select jsonb_build_object(
                'co2_eq_ce', formula.sum_incert(coalesce((exploit_and_constr.co2_eq_an).val, 0), coalesce((exploit_and_constr.co2_eq_an).incert, 0))
                ) as json_eq_ce
                from exploit_and_constr
            )
            select into js2 jsonb_build_object(
                'co2_eq_e', (json_eq.json_eq)->'co2_eq_e',
                'co2_eq_c', (json_eq.json_eq)->'co2_eq_c',
                'co2_eq_ce', (json_eq_ce.json_eq_ce)->'co2_eq_ce'
            )
            from json_eq, json_eq_ce;

            if not js2 ? 'co2_eq_e' then
                js2 := jsonb_set(js2, array['co2_eq_e'], to_jsonb(row(0, 0)::___.res), true);
            end if;
            if not js2 ? 'co2_eq_c' then
                js2 := jsonb_set(js2, array['co2_eq_c'], to_jsonb(row(0, 0)::___.res), true);
            end if;
            if not js2 ? 'co2_eq_ce' then
                js2 := jsonb_set(js2, array['co2_eq_ce'], to_jsonb(row(0, 0)::___.res), true);
            end if;

            --raise  notice 'js2 = %', js2;
            --raise  notice 'js1 = %', js1;
            if js1 is null then 
                js1 := '{}';
            end if;
            if js2 is null then 
                js2 := '{}';
            end if;
            res := jsonb_set(res, array[b_name], js1||js2, true);
        end if;
    end loop;

    with results as (
        select distinct name, ___.add(result_ss_blocs, result_ss_blocs_intrant) as result, co2_eq 
        from ___.results where id = any(blocs) and name = any(names) 
        and ___.add(result_ss_blocs, result_ss_blocs_intrant) is not null
    ),
    results_sum as (select name, formula.sum_incert((result).val, (result).incert) as result from results group by name)
    select into js1 jsonb_object_agg(name, result) from results_sum; 

    foreach k in array names loop
        if not js1 ? k or js1->k is null then
            js1 := jsonb_set(js1, array[k], to_jsonb(row(0, 0)::___.res), true);
        end if;
    end loop;

    -- --raise  notice 'js1 = %', js1;
    with results as (
    select name, co2_eq, co2_eq_an 
    from ___.results where id = any(blocs) and name = any(names) 
    ), 
    exploit as (select distinct name, co2_eq from results where name like '%_e'),
    constr as (select distinct name, co2_eq from results where name like '%_c'), 
    exploit_and_constr as (select distinct name, co2_eq_an from results),
    json_eq as (select jsonb_build_object(
        'co2_eq_e', formula.sum_incert(coalesce((exploit.co2_eq).val, 0), coalesce((exploit.co2_eq).incert, 0)),
        'co2_eq_c', formula.sum_incert(coalesce((constr.co2_eq).val, 0), coalesce((constr.co2_eq).incert, 0))
        ) as json_eq
        from exploit
        full join constr on exploit.name = constr.name 
    ), 
    json_eq_ce as (select jsonb_build_object(
        'co2_eq_ce', formula.sum_incert(coalesce((exploit_and_constr.co2_eq_an).val, 0), coalesce((exploit_and_constr.co2_eq_an).incert, 0))
        ) as json_eq_ce
        from exploit_and_constr
    )
    select into js2 jsonb_build_object(
        'co2_eq_e', (json_eq.json_eq)->'co2_eq_e',
        'co2_eq_c', (json_eq.json_eq)->'co2_eq_c',
        'co2_eq_ce', (json_eq_ce.json_eq_ce)->'co2_eq_ce'
    )
    from json_eq, json_eq_ce;

    if not js2 ? 'co2_eq_e' then
        js2 := jsonb_set(js2, array['co2_eq_e'], to_jsonb(row(0, 0)::___.res), true);
    end if;
    if not js2 ? 'co2_eq_c' then
        js2 := jsonb_set(js2, array['co2_eq_c'], to_jsonb(row(0, 0)::___.res), true);
    end if;
    if not js2 ? 'co2_eq_ce' then
        js2 := jsonb_set(js2, array['co2_eq_ce'], to_jsonb(row(0, 0)::___.res), true);
    end if;

    --raise  notice 'js2 = %', js2;
    --raise  notice 'js1 = %', js1;
    if js1 is null then 
        js1 := '{}';
    end if;
    if js2 is null then 
        js2 := '{}';
    end if;
    res := jsonb_set(res, array['total'], js1||js2, true);
    return res ; 
end ;
$$ ;


create or replace function api.get_histo_data(p_model varchar, bloc_name varchar default null)
returns jsonb
language plpgsql
as $$
declare
    query text;
    id_bloc integer;
    ss_blocs_array integer[];
    names varchar[] := array['n2o_c', 'n2o_e', 'ch4_c', 'ch4_e', 'co2_c', 'co2_e'];
    b_name varchar;
    item record ; 
    concr boolean;
    js1 jsonb;
    id_loop integer;
    js2 jsonb;
    res jsonb := '{}';
    k text ;
begin

    select into id_bloc id from api.bloc where name = bloc_name limit 1; -- limit 1 normally useless
    -- -- --raise  notice 'id_bloc = %', id_bloc;
    if id_bloc is null then
        select into ss_blocs_array array_agg(id) from ___.bloc where model = p_model and sur_bloc is null;
    else 
        select into ss_blocs_array array_agg(id) from ___.bloc where model = p_model and sur_bloc = id_bloc;
    end if;
    -- -- --raise  notice 'ss_blocs_array = %', ss_blocs_array;
    -- Loop through each bloc id

    if array_length(ss_blocs_array, 1) = 0 or ss_blocs_array is null then 
        return jsonb_build_object(
        'total', jsonb_build_object(
        'ch4_c', to_jsonb(row(0, 0)::___.res),
        'ch4_e', to_jsonb(row(0, 0)::___.res),
        'co2_c', to_jsonb(row(0, 0)::___.res),
        'co2_e', to_jsonb(row(0, 0)::___.res),
        'n2o_c', to_jsonb(row(0, 0)::___.res),
        'n2o_e', to_jsonb(row(0, 0)::___.res),
        'co2_eq_c', to_jsonb(row(0, 0)::___.res),
        'co2_eq_e', to_jsonb(row(0, 0)::___.res),
        'co2_eq_ce', to_jsonb(row(0, 0)::___.res)
        )
        );
    end if ;

    foreach id_loop in array ss_blocs_array loop
        -- Get the bloc name
        select into item name, b_type from ___.bloc where id = id_loop;
        b_name := item.name ;
        select into concr concrete from api.input_output where b_type = item.b_type;
        if concr or item.b_type = 'sur_bloc' then 
            -- Calculate the sum of the values for the specified names
            with results as (
                select name, ___.add(result_ss_blocs, result_ss_blocs_intrant) as result, co2_eq 
                from ___.results where id = id_loop and name = any(names) 
                and ___.add(result_ss_blocs, result_ss_blocs_intrant) is not null
            )
            select into js1 jsonb_object_agg(name, result) from results; 

            foreach k in array names loop
                if not js1 ? k or js1->k is null then
                    js1 := jsonb_set(js1, array[k], to_jsonb(row(0, 0)::___.res), true);
                end if;
            end loop;

            -- --raise  notice 'js1 = %', js1;
            with results as (
            select name, co2_eq, co2_eq_an 
            from ___.results where id = id_loop and name = any(names) 
            ), 
            exploit as (select distinct name, co2_eq from results where name like '%_e'),
            constr as (select distinct name, co2_eq from results where name like '%_c'), 
            exploit_and_constr as (select distinct name, co2_eq_an from results),
            json_eq as (select jsonb_build_object(
                'co2_eq_e', formula.sum_incert(coalesce((exploit.co2_eq).val, 0), coalesce((exploit.co2_eq).incert, 0)),
                'co2_eq_c', formula.sum_incert(coalesce((constr.co2_eq).val, 0), coalesce((constr.co2_eq).incert, 0))
                ) as json_eq
                from exploit
                full join constr on exploit.name = constr.name 
            ), 
            json_eq_ce as (select jsonb_build_object(
                'co2_eq_ce', formula.sum_incert(coalesce((exploit_and_constr.co2_eq_an).val, 0), coalesce((exploit_and_constr.co2_eq_an).incert, 0))
                ) as json_eq_ce
                from exploit_and_constr
            )
            select into js2 jsonb_build_object(
                'co2_eq_e', (json_eq.json_eq)->'co2_eq_e',
                'co2_eq_c', (json_eq.json_eq)->'co2_eq_c',
                'co2_eq_ce', (json_eq_ce.json_eq_ce)->'co2_eq_ce'
            )
            from json_eq, json_eq_ce;

            if not js2 ? 'co2_eq_e' then
                js2 := jsonb_set(js2, array['co2_eq_e'], to_jsonb(row(0, 0)::___.res), true);
            end if;
            if not js2 ? 'co2_eq_c' then
                js2 := jsonb_set(js2, array['co2_eq_c'], to_jsonb(row(0, 0)::___.res), true);
            end if;
            if not js2 ? 'co2_eq_ce' then
                js2 := jsonb_set(js2, array['co2_eq_ce'], to_jsonb(row(0, 0)::___.res), true);
            end if;

            --raise  notice 'js2 = %', js2;
            --raise  notice 'js1 = %', js1;
            if js1 is null then 
                js1 := '{}';
            end if;
            if js2 is null then 
                js2 := '{}';
            end if;
            res := jsonb_set(res, array[b_name], js1||js2, true);
        end if;
    end loop;

    with results as (
        select distinct name, ___.add(result_ss_blocs, result_ss_blocs_intrant) as result, co2_eq 
        from ___.results where id = any(ss_blocs_array) and name = any(names) 
        and ___.add(result_ss_blocs, result_ss_blocs_intrant) is not null
    ),
    results_sum as (select name, formula.sum_incert((result).val, (result).incert) as result from results group by name)
    select into js1 jsonb_object_agg(name, result) from results_sum; 

    foreach k in array names loop
        if not js1 ? k or js1->k is null then
            js1 := jsonb_set(js1, array[k], to_jsonb(row(0, 0)::___.res), true);
        end if;
    end loop;

    --raise  notice 'js1 = %', js1;
    
    with results as (
    select name, co2_eq, co2_eq_an 
    from ___.results where id = any(ss_blocs_array) and name = any(names) 
    ), 
    exploit as (select distinct name, co2_eq from results where name like '%_e'),
    constr as (select distinct name, co2_eq from results where name like '%_c'), 
    exploit_and_constr as (select distinct name, co2_eq_an from results),
    json_eq as (select jsonb_build_object(
        'co2_eq_e', formula.sum_incert(coalesce((exploit.co2_eq).val, 0), coalesce((exploit.co2_eq).incert, 0)),
        'co2_eq_c', formula.sum_incert(coalesce((constr.co2_eq).val, 0), coalesce((constr.co2_eq).incert, 0))
        ) as json_eq
        from exploit
        full join constr on exploit.name = constr.name 
    ), 
    json_eq_ce as (select jsonb_build_object(
        'co2_eq_ce', formula.sum_incert(coalesce((exploit_and_constr.co2_eq_an).val, 0), coalesce((exploit_and_constr.co2_eq_an).incert, 0))
        ) as json_eq_ce
        from exploit_and_constr
    )
    select into js2 jsonb_build_object(
        'co2_eq_e', (json_eq.json_eq)->'co2_eq_e',
        'co2_eq_c', (json_eq.json_eq)->'co2_eq_c',
        'co2_eq_ce', (json_eq_ce.json_eq_ce)->'co2_eq_ce'
    )
    from json_eq, json_eq_ce;

    if not js2 ? 'co2_eq_e' then
        js2 := jsonb_set(js2, array['co2_eq_e'], to_jsonb(row(0, 0)::___.res), true);
    end if;
    if not js2 ? 'co2_eq_c' then
        js2 := jsonb_set(js2, array['co2_eq_c'], to_jsonb(row(0, 0)::___.res), true);
    end if;
    if not js2 ? 'co2_eq_ce' then
        js2 := jsonb_set(js2, array['co2_eq_ce'], to_jsonb(row(0, 0)::___.res), true);
    end if;
    --raise  notice 'js2 = %', js2;
    --raise  notice 'js1 = %', js1;
    res := jsonb_set(res, array['total'], js1||js2, true);
    --raise  notice 'res = %', res;
    if res is null then 
        return jsonb_build_object(
        'total', jsonb_build_object(
        'ch4_c', to_jsonb(row(0, 0)::___.res),
        'ch4_e', to_jsonb(row(0, 0)::___.res),
        'co2_c', to_jsonb(row(0, 0)::___.res),
        'co2_e', to_jsonb(row(0, 0)::___.res),
        'n2o_c', to_jsonb(row(0, 0)::___.res),
        'n2o_e', to_jsonb(row(0, 0)::___.res),
        'co2_eq_c', to_jsonb(row(0, 0)::___.res),
        'co2_eq_e', to_jsonb(row(0, 0)::___.res),
        'co2_eq_ce', to_jsonb(row(0, 0)::___.res)
        )
        );
    end if ;
    return res;
end;
$$;


create or replace function api.get_results4csv(model_name varchar, path varchar) 
-- Ne fonctionne pas pour le moment mais le but serait de faire plein de csv et de renvoyer les chemins
returns text[]
language plpgsql
as $$
declare
    id_bloc integer;
    res jsonb := '{}';
    path_id varchar;
    paths text[] ;
    c int := 1 ; 
    name_bloc varchar ;
    query text ;
    n int ; 
begin
    n = (select count(*) from ___.bloc where model = model_name) +1;
    --raise  notice 'n = %', n ;
    paths = array_fill(''::text, array[n]) ; 
    for name_bloc in (select name from ___.bloc where model = model_name) loop
        res := api.get_histo_data(model_name, name_bloc);
        -- name_bloc := (select name from ___.bloc where id = id_bloc) ;
        path_id := path || name_bloc || '.json';
        paths[c] := path_id ;
        c := c + 1 ;
        --raise  notice 'Ici commence le testing' ;
        --raise  notice 'name_blocs = %', name_bloc ;
        --raise  notice 'res %', res ;
        -- --raise  notice 'res1 % ', (select res->name_bloc from res) ;
        --raise  notice 'res2 % ', res->name_bloc ;
        --raise  notice 'res3 % ', res->quote_literal(name_bloc) ;
        --raise  notice 'res4 % ', (select res->name_bloc) ;
        query := 'copy (select 
         res->''' || name_bloc || '''->''n2o_c''->>''val'' as n2o_c, res->''' || name_bloc || '''->''n2o_c''->>''incert'' as n2o_c_incert,
         res->''' || name_bloc || '''->''n2o_e''->>''val'' as n2o_e, res->''' || name_bloc || '''->''n2o_e''->>''incert'' as n2o_e_incert,
         res->''' || name_bloc || '''->''ch4_c''->>''val'' as ch4_c, res->''' || name_bloc || '''->''ch4_c''->>''incert'' as ch4_c_incert,
         res->''' || name_bloc || '''->''ch4_e''->>''val'' as ch4_e, res->''' || name_bloc || '''->''ch4_e''->>''incert'' as ch4_e_incert,
         res->''' || name_bloc || '''->''co2_c''->>''val'' as co2_c, res->''' || name_bloc || '''->''co2_c''->>''incert'' as co2_c_incert,
         res->''' || name_bloc || '''->''co2_e''->>''val'' as co2_e, res->''' || name_bloc || '''->''co2_e''->>''incert'' as co2_e_incert,
         res->''' || name_bloc || '''->''co2_eq_c''->>''val'' as co2_eq_c, res->''' || name_bloc || '''->''co2_eq_c''->>''incert'' as co2_eq_c_incert,
         res->''' || name_bloc || '''->''co2_eq_e''->>''val'' as co2_eq_e, res->''' || name_bloc || '''->''co2_eq_e''->>''incert'' as co2_eq_e_incert
         ) to ' || quote_literal(path_id) || ' with (format csv, header)';
        -- query := 'copy (select 
        --     $1->$2->''n2o_c''->>''val'' as n2o_c, $1->$2->''n2o_c''->>''incert'' as n2o_c_incert,
        --     $1->$2->''n2o_e''->>''val'' as n2o_e, $1->$2->''n2o_e''->>''incert'' as n2o_e_incert,
        --     $1->$2->''ch4_c''->>''val'' as ch4_c, $1->$2->''ch4_c''->>''incert'' as ch4_c_incert,
        --     $1->$2->''ch4_e''->>''val'' as ch4_e, $1->$2->''ch4_e''->>''incert'' as ch4_e_incert,
        --     $1->$2->''co2_c''->>''val'' as co2_c, $1->$2->''co2_c''->>''incert'' as co2_c_incert,
        --     $1->$2->''co2_e''->>''val'' as co2_e, $1->$2->''co2_e''->>''incert'' as co2_e_incert,
        --     $1->$2->''co2_eq_c''->>''val'' as co2_eq_c, $1->$2->''co2_eq_c''->>''incert'' as co2_eq_c_incert,
        --     $1->$2->''co2_eq_e''->>''val'' as co2_eq_e, $1->$2->''co2_eq_e''->>''incert'' as co2_eq_e_incert
        --     ) to '||quote_literal(path_id)||' with (format csv, header)' ;
        execute query ;
    end loop;
    res := api.get_histo_data(model_name, null);
    path_id := path || 'total.json';
    paths[c] := path_id ;
    query := 'copy (select 
        $1->''total''->''n2o_c''->>''val'' as n2o_c, $1->''total''->''n2o_c''->>''incert'' as n2o_c_incert,
        $1->''total''->''n2o_e''->>''val'' as n2o_e, $1->''total''->''n2o_e''->>''incert'' as n2o_e_incert,
        $1->''total''->''ch4_c''->>''val'' as ch4_c, $1->''total''->''ch4_c''->>''incert'' as ch4_c_incert,
        $1->''total''->''ch4_e''->>''val'' as ch4_e, $1->''total''->''ch4_e''->>''incert'' as ch4_e_incert,
        $1->''total''->''co2_c''->>''val'' as co2_c, $1->''total''->''co2_c''->>''incert'' as co2_c_incert,
        $1->''total''->''co2_e''->>''val'' as co2_e, $1->''total''->''co2_e''->>''incert'' as co2_e_incert,
        $1->''total''->''co2_eq_c''->>''val'' as co2_eq_c, $1->''total''->''co2_eq_c''->>''incert'' as co2_eq_c_incert,
        $1->''total''->''co2_eq_e''->>''val'' as co2_eq_e, $1->''total''->''co2_eq_e''->>''incert'' as co2_eq_e_incert
        ) to '||quote_literal(path_id)||' with (format csv, header)' ;
    execute query using res ;
    return paths ;
end;
$$;

-- select api.get_results4csv('model_1', 'C:\Users\theophile.mounier\AppData\Roaming\QGIS\QGIS3\profiles\default\python\plugins\cycle\database\sql\bonjour\') ;