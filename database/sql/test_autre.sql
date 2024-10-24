-- create or replace function formula.insert_op(operators varchar[], op varchar)
-- returns varchar[]
-- language plpgsql
-- as $$
-- declare 
--     symbols varchar[] := array['^', '>', '<', '*', '/', '+', '-', ''] ; 
--     prio integer[] :=array[4,3,3,2,2,1,1,0] ;
--     n integer ;
--     i integer := 1 ;
-- begin 
--     n := array_length(operators, 1) ; 
--     if n = 0 then return array[op] ; end if ;
--     while i < n + 1 and prio[array_position(symbols, operators[i])] >= prio[array_position(symbols, op)] loop
--         i := i + 1 ;
--     end loop ;
--     --operators = operators[:k] + [op] + operators[k:]
--     operators := array_cat(array_cat(operators[1:i-1], array[op]::varchar[]), operators[i:n]) ;
--     return operators ; 
-- end ;
-- $$ ; 

-- create or replace function formula.resize_array(tab text[], len_sb integer, new_size integer)
-- returns text[]
-- language plpgsql 
-- as $$ 
-- declare 
--     resized text[];
--     n integer ; 
--     n_sub integer ; 
--     i integer;
--     j integer;
-- begin 
--     n = array_length(tab, 1) ;
--     n_sub = (n/len_sb)::integer ; 
--     resized := array_fill(''::text, array[n_sub*new_size]) ;
--     for i in 0..n_sub-1 loop
--         resized[i*new_size+1:i*new_size+len_sb] := tab[i*len_sb+1:i*len_sb+len_sb] ;
--     end loop ;
--     return resized ; 
-- end ;
-- $$ ; 

-- create or replace function formula.write_formula(expr varchar)
-- returns varchar[]
-- language plpgsql
-- as $$
-- declare 
--     pat varchar := '[\+\-\*\/\^\(\)\>\<]' ;
--     operators varchar[] ;
--     op varchar ;
--     args varchar[] ;
--     calc text[] := array_fill(''::text, array[50]);
--     calc_length integer[] := array_fill(0, array[5]) ; 
--     calc_sb_len integer := 10 ;
--     last_op text[] := array_fill(''::text, array[50]) ;
--     last_op_length integer[] := array_fill(0, array[5]) ; 
--     last_op_sb_len integer := 10 ;
--     len integer ; 
--     idx integer := 1 ; 
--     flag_op boolean[] := array[false]::boolean[] ;
--     i integer := 1 ;
--     j integer := 1 ;
--     car char ;
--     prioritized varchar ;
-- begin 
--     -- fonction qui réécrit une formule sous forme lisibles sans ambiguités je sais plus comment ça s'appelle mais 
--     -- on a a+b*c qui devient a b c * +
--     args := array_fill(''::text, array[length(expr)]) ; 
--     for i in 1..length(expr) loop 
--         car := substr(expr, i, 1) ;
--         if car ~ pat then 
--             args[j] := trim(args[j]) ;
--             if args[j] != '' then 
--                 j := j + 1 ;
--             end if ;
--             args[j] := car ;
--             j := j + 1 ;
--         else 
--             args[j] := args[j] || car ;
--         end if ;
--     end loop ;
--     args := args[1:j] ;
--     raise notice 'args finale %', args ;
--     for i in 1..j-1 loop 
--         raise notice 'args %', args[i] ;
--         if args[i] = '(' then 
--             len := array_length(calc, 1) ; 
--             if len < (idx + 1)*calc_sb_len then 
--                 calc := array_cat(calc, array_fill(''::text, array[calc_sb_len])) ;
--                 calc_length := array_append(calc_length, 0) ;
--             else 
--                 calc[idx*calc_sb_len+1:(idx+1)*calc_sb_len] = array_fill(''::text, array[calc_sb_len]) ;
--                 calc_length[idx+1] := 0 ;
--             end if ; 
--             flag_op := array_append(flag_op, false) ;
--             len := array_length(last_op, 1) ;
--             if len < (idx + 1)*last_op_sb_len then
--                 last_op := array_cat(last_op, array_fill(''::text, array[last_op_sb_len])) ;
--                 last_op_length := array_append(last_op_length, 0) ;
--             else
--                 last_op[idx*last_op_sb_len+1:(idx+1)*last_op_sb_len] = array_fill(''::text, array[last_op_sb_len]) ;
--                 last_op_length[idx+1] := 0 ;
--             end if ;
--             idx := idx + 1 ; 
--         elseif args[i] = ')' then 
--             if calc_length[idx] + last_op_length[idx] > calc_sb_len then 
--                 calc := formula.resize_array(calc, calc_sb_len, 2*(calc_length[idx] + last_op_length[idx])) ;
--                 calc_sb_len := 2*(calc_length[idx] + last_op_length[idx]) ;
--             end if ; 
--             raise notice 'là1' ;
--             if 1 <= last_op_length[idx] then
--                 calc[(idx-1)*calc_sb_len+calc_length[idx]+1:(idx-1)*calc_sb_len+calc_length[idx]+last_op_length[idx]] := last_op[(idx-1)*last_op_sb_len+1:(idx-1)*last_op_sb_len+last_op_length[idx]] ;
--                 calc_length[idx] := calc_length[idx] + last_op_length[idx] ;
--             end if ;
--             if calc_length[idx] + calc_length[idx - 1] > calc_sb_len then 
--                 calc := formula.resize_array(calc, calc_sb_len, 2*(calc_length[idx] + calc_length[idx-1])) ;
--                 calc_sb_len := 2*(calc_length[idx] + calc_length[idx-1]) ;
--             end if ; 
--             raise notice 'calc_length %', calc_length ;
--             raise notice 'là % < %', (idx-2)*calc_sb_len+calc_length[idx-1]+1, (idx-2)*calc_sb_len+calc_length[idx-1]+calc_length[idx] ;
--             calc[(idx-2)*calc_sb_len+calc_length[idx-1]+1:(idx-2)*calc_sb_len+calc_length[idx-1]+calc_length[idx]] := calc[(idx-1)*calc_sb_len+1:(idx-1)*calc_sb_len+calc_length[idx]] ;
--             calc_length[idx-1] := calc_length[idx-1] + calc_length[idx] ;
--             flag_op = array_remove(flag_op, flag_op[idx]) ;
--             idx := idx - 1 ;
--         elseif not args[i] ~ pat then 
--             if calc_length[idx]+1 > calc_sb_len then 
--                 calc := formula.resize_array(calc, calc_sb_len, 2*(calc_length[idx]+1)) ;
--                 calc_sb_len := 2*(calc_length[idx]+1) ;
--             end if ;
--             calc[(idx-1)*calc_sb_len+calc_length[idx]+1] := args[i];
--             calc_length[idx] := calc_length[idx] + 1 ;
--         else 
--             if last_op_length[idx] > 0 then 
--                 prioritized := last_op[(idx-1)*last_op_sb_len+1] ;
--             else 
--                 prioritized := '' ;
--                 flag_op[idx] := false ;
--             end if ;
--             if last_op_length[idx] + 1 > last_op_sb_len then 
--                 last_op := formula.resize_array(last_op, last_op_sb_len, 2*(last_op_length[idx]+1)) ;
--                 last_op_sb_len := 2*(last_op_length[idx]+1) ;
--             end if ;
--             -- raise notice 'last_op %, args %', last_op, args[i] ;
--             -- raise notice 'idx %', idx ; 
--             last_op[(idx-1)*last_op_sb_len+1:idx*last_op_sb_len] := formula.insert_op(last_op[(idx-1)*last_op_sb_len+1:idx*last_op_sb_len], args[i]) ;
--             last_op_length[idx] := last_op_length[idx] + 1 ;
--             if prioritized = last_op[(idx-1)*last_op_sb_len+1] then 
--                 flag_op[idx] := true ;
--             end if ;
--             if flag_op[idx] then 
--                 if calc_length[idx] + 1 > calc_sb_len then 
--                     calc := formula.resize_array(calc, calc_sb_len, 2*(calc_length[idx]+1)) ;
--                     calc_sb_len := 2*(calc_length[idx]+1) ;
--                 end if ;
--                 calc[(idx-1)*calc_sb_len+calc_length[idx]+1] := last_op[(idx-1)*last_op_sb_len+1] ;
--                 last_op[(idx-1)*last_op_sb_len+1:idx*last_op_sb_len-1] := last_op[(idx-1)*last_op_sb_len+2:idx*last_op_sb_len] ;
--                 last_op_length[idx] := last_op_length[idx] - 1 ;
--                 calc_length[idx] := calc_length[idx] + 1 ;
--                 flag_op[idx] := false ;
--             end if ;
--         end if ;
--         raise notice 'idx %, calc %', idx, calc ;
--         raise notice 'last_op %', last_op ;
--         raise notice 'calc_length %, last_op_length %', calc_length, last_op_length ;
--     end loop ;
--     if calc_length[idx] + last_op_length[idx] > calc_sb_len then 
--         calc := formula.resize_array(calc, calc_sb_len, (calc_length[idx] + last_op_length[idx])+1) ;
--     end if ;
--     if 1 <= last_op_length[idx] then 
--         calc[(idx-1)*calc_sb_len+calc_length[idx]+1:(idx-1)*calc_sb_len+calc_length[idx]+last_op_length[idx]] := last_op[(idx-1)*last_op_sb_len+1:(idx-1)*last_op_sb_len+last_op_length[idx]] ;
--     end if ; 
--     raise notice 'calc final %', calc ;
--     return calc[(idx-1)*calc_sb_len+1:calc_length[idx]] ; 
-- end ;
-- $$ ;

-- create or replace function formula.calc_incertitudes(calc varchar[])
-- returns record
-- language plpgsql
-- as $$
-- declare 
--     query text ;
--     i integer ;
--     deb integer ;
--     fin integer ;  
--     n integer ;
--     val1 real ;
--     incert1 real ;
--     val2 real ;
--     incert2 real ;
--     calc_val real[] ;
--     calc_incert real[] ; 
--     new varchar ;
--     pat varchar := '[\+\-\*\/\^\>\<]' ;
--     new_val real; 
--     new_incert real; 
--     result record ; 
-- begin 
--     n = array_length(calc, 1) ;
--     calc_val := array_fill(0.0, array[n]) ;
--     calc_incert := array_fill(0.0, array[n]) ;
--     deb := 1 ;
--     fin := 0 ;
--     if n = 1 then return result ;end if ;
--     if n = 0 then return result ; end if ;
--     i := 1 ;
--     while i < n+1 loop
--         new := calc[i] ;
--         i:=i+1 ;
--         if new ~ pat then 
--             -- On récupère les deux valeurs de calcul
--             val1 := calc_val[fin-1] ;
--             incert1 := calc_incert[fin-1] ;

--             val2 := calc_val[fin] ;
--             incert2 := calc_incert[fin] ;
            
--             fin := fin - 1 ;
--             -- On calcule à chaque fois les incertitudes relatives et les valeurs réelles 
--             case
--             when new = '+' then 
--                 -- somme des incertitudes
--                 new_val := val1 + val2 ;
--                 new_incert := (incert1*val1 + incert2*val2)/(val1 + val2) ;
--             when new = '-' then 
--                 new_val := val1 - val2 ;
--                 new_incert := (incert1*val1 + incert2*val2)/(val1 + val2) ;
--             when new = '*' then
--                 new_val := val1 * val2 ;
--                 new_incert := sqrt(incert1^2 + incert2^2) ;
--             when new = '/' then
--                 new_val := val1 / val2 ;
--                 new_incert := sqrt(incert1^2 + incert2^2) ;
--             when new = '^' then
--                 new_val := val1 ^ val2 ;
--                 new_incert := abs(val2) * incert1 ;
--             when new = '>' then
--                 new_val := (val1 > val2)::int::real ;
--                 new_incert := 0.0 ;
--             when new = '<' then
--                 new_val := (val1 < val2)::int::real ;
--                 new_incert := 0.0 ;
--             end case ;
--             calc_val[fin] := new_val ;
--             calc_incert[fin] := new_incert ;
--         else
--             if regexp_matches(new, '^[0-9]+(\.[0-9]+)?$') is not null then 
--                 val1 := new::real ;
--                 incert1 := 0.0 ;
--             else
--                 select into val1 val from inp_out where name = new ;
--                 select into incert1 incert from inp_out where name = new ;
--             end if ; 
--             fin := fin + 1 ;
--             calc_val[fin] := val1 ;
--             calc_incert[fin] := incert1 ;
            
--         end if ;
--         raise notice 'new %', new ;
--         raise notice 'calc_val %', calc_val ;
--         raise notice 'calc_incert %', calc_incert ;
--     end loop ; 
--     raise notice 'val %', calc_val[fin] ;
--     raise notice 'incert %', calc_incert[fin] ;
--     select into result calc_val[fin] as val, calc_incert[fin] as incert;
--     -- result.val := calc_val[fin] ;
--     -- result.incert := calc_incert[fin] ;
--     return result ;
-- end ;
-- $$ ;

-- -- def write_formula(expr, dico, var = set(), c = 0):
-- --     if c > 20 : 
-- --         return
-- --     print(expr)
-- --     operators = ['+', '-', '*', '/', '^', '>', '<', '(', ')']
-- --     args = re.split(r'([\+\-\/\*\>\<\^\(\)])', expr)
-- --     args = [arg.strip() for arg in args]
-- --     print("Mais Non ?", args)
-- --     i = 0
-- --     calc = [[]]
-- --     idx = 0 
-- --     last_op = [[]]
-- --     flag_op = [False]
-- --     for i in range(len(args)) : 
-- --         print('argument', args[i])
-- --         # print(i, flag_op)
-- --         if args[i] == '(' :
-- --             calc.append([])
-- --             flag_op.append(False)
-- --             last_op.append([])
-- --             idx += 1
-- --         elif args[i] == ')' : 
-- --             # query = eval_sum(query, dico, var)
-- --             calc[idx] = calc[idx] + last_op[idx]
-- --             calc[idx-1].append(calc.pop(idx))
-- --             flag_op.pop(idx)
-- --             last_op.pop(idx)
-- --             idx -= 1
-- --         elif args[i] in var :
-- --             calc[idx].append(args[i])
-- --         elif args[i] in dico : 
-- --             written_formula = write_formula(dico[args[i]], dico, var, c=c+1)
-- --             if is_number(written_formula) :
-- --                 calc[idx].append(written_formula)
-- --             else : 
-- --                 calc[idx].append('('+written_formula + ')')
-- --             print("written formula", calc[idx][-1])
-- --         elif args[i] in operators :
-- --             try : 
-- --                 prioriorized = last_op[idx][0]
-- --             except : 
-- --                 flag_op[idx] = False
-- --                 prioriorized = None
-- --             last_op[idx] = insert_op(last_op[idx], args[i])
-- --             if prioriorized == last_op[idx][0] :
-- --                 flag_op[idx] = True
-- --             if flag_op[idx] :
-- --                 calc[idx].append(last_op[idx].pop(0))
-- --                 flag_op[idx] = False
-- --         elif args[i] :
-- --             calc[idx].append(args[i])
-- --     calc[idx] += last_op[idx]

-- --     print('calc', calc)
-- --     def formula_from_calc(calc) :
-- --         if not isinstance(calc, list) : 
-- --             return calc
        
-- --         if len(calc) == 1 : 
-- --             return formula_from_calc(calc[0])
-- --         args = [] 
-- --         args.append(calc.pop(0))
-- --         if isinstance(args[0], list) :
-- --             args[0] = formula_from_calc(args[0])
-- --             if not is_number(args[0]) : 
-- --                 args[0] = '(' + args[0] + ')'
-- --         while len(calc) > 0 : 
-- --             new = calc.pop(0)
-- --             if isinstance(new, list) :
-- --                 new = formula_from_calc(new)
-- --                 if not is_number(new) : 
-- --                     new = '(' + new + ')'
-- --             if new in operators :
-- --                 arg2 = args.pop()
-- --                 arg = args.pop()
-- --                 op = new
-- --                 if arg == 'pi' : 
-- --                     arg = str(pi)
-- --                 if arg2 == 'pi' : 
-- --                     arg2 = str(pi)
-- --                 print('hihi', arg, arg2, op)
                
-- --                 if is_number(arg) and is_number(arg2) : 
-- --                     if op == '+' :
-- --                         print("bonjour")
-- --                         arg=  str(float(arg) + float(arg2))
-- --                     elif op == '-' : 
-- --                         arg= str(float(arg) - float(arg2))
-- --                     elif op == '*' : 
-- --                         arg= str(float(arg) * float(arg2))
-- --                     elif op == '/' : 
-- --                         arg= str(float(arg) / float(arg2))
-- --                     elif op == '^' : 
-- --                         arg= str(float(arg) ** float(arg2))
-- --                     elif op == '>' : 
-- --                         arg= str(float(float(arg) > float(arg2)))
-- --                     elif op == '<' : 
-- --                         arg += str(float(float(arg) < float(arg2)))
-- --                 else :
-- --                     print("euh", arg, op, arg2)
-- --                     arg = arg + op + arg2
-- --                     if op == '/' and arg == arg2 : 
-- --                         arg = '1'
-- --                     elif op =='*' and arg == arg2 : 
-- --                         arg = '('+arg+')^2'
                    
-- --                 args.append(arg)
-- --             else :
-- --                 args.append(new)
-- --             print('args', args)
-- --         return args[0]
-- --     final_expr = formula_from_calc(calc)
-- --     return final_expr


-- -- Test 

-- create or replace function formula.state_function(sum real[], new_val real, new_incert real)
-- returns real[]
-- language plpgsql
-- as $$
-- declare 
--     sum_val real := sum[1] ;
--     sum_incert real := sum[2] ;
-- begin 
--     if sum is null then 
--         return array[new_val, new_incert] ;
--     end if ;
--     return array[sum_val + new_val, 
--             (sum_incert*sum_val + new_incert*new_val)/(sum_val + new_val)
--             ] ;
-- end ;
-- $$ ; 

-- create or replace function formula.final_function(state real[])
-- returns ___.res 
-- language plpgsql
-- as $$
-- declare 
--     res ___.res ;
-- begin 
--     select into res state[1] as val, state[2] as incert ;
--     return res ;
-- end ;
-- $$ ;

-- create or replace aggregate formula.sum_incert(val real, incert real)
-- (
--     sfunc = formula.state_function,
--     stype = real[],
--     finalfunc = formula.final_function
-- ) ;

-- do $$
-- declare 
--     expr varchar := '((a+b)*c+d^(e>f))' ;
--     operators varchar[] := array['^', '+', '-'] ; 
--     array_test varchar[] := array['a', '+', 'b', '*', 'c'] ;
--     test varchar[] ;
--     items record ;
-- begin
--     operators := formula.insert_op(operators, '*') ;
--     raise notice 'operators %', operators ;
--     array_test := formula.resize_array(array_test::text[], 1, 2) ; 
--     raise notice 'array_test %', array_test ;
--     select into test formula.write_formula(expr) ;
--     raise notice 'test %', test ;
--     -- create temp table inp_out(name text, val real, incert real) ;
--     -- insert into inp_out values('a', 1.0, 0.1) ;
--     -- insert into inp_out values('b', 2.0, 0.2) ;
--     -- insert into inp_out values('c', 3.0, 0.3) ;
--     -- insert into inp_out values('d', 4.0, 0.4) ;
--     -- insert into inp_out values('e', 5.0, 0.5) ;
--     -- insert into inp_out values('f', 6.0, 0.6) ;
--     items := formula.calc_incertitudes(test) ;
--     raise notice 'items %', items ;
    
-- end ;
-- $$ ;
-- select formula.sum_incert(val, incert) from inp_out ;
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

create or replace function api.get_histo_data(p_model varchar, bloc_name varchar default null)
returns table(bloc_name varchar, name varchar, val real, incert real)
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
    sum_values record;
    id_loop integer;

begin
    create temp table res (
        bloc_name varchar,
        name varchar,
        val real,
        incert real
    )
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
            gas as (select name, formula.sum_incert((result_ss_blocs).val, (result_ss_blocs).incert) as j
            from in_use where id = id_loop and name = any(names) group by name),
            exploit as (select name, formula.sum_incert((result_ss_blocs).val, (result_ss_blocs).incert) as j
            from in_use where id = id_loop and name like '%_e' group by name),
            constr as (select name, formula.sum_incert((result_ss_blocs).val, (result_ss_blocs).incert) as j
            from in_use where id = id_loop and name like '%_c' group by name)
            insert into 

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
    gas as (select name, formula.sum_incert((result_ss_blocs).val, (result_ss_blocs).incert) as j
    from in_use where id = any(ss_blocs_array) and name = any(names) group by name),
    exploit as (select name, formula.sum_incert((result_ss_blocs).val, (result_ss_blocs).incert) as j
    from in_use where id = any(ss_blocs_array) and name like '%_e' group by name),
    constr as (select name, formula.sum_incert((result_ss_blocs).val, (result_ss_blocs).incert) as j
    from in_use where id = any(ss_blocs_array) and name like '%_c' group by name)
    select into sum_values jsonb_object_agg(gas.name, gas.j) as gas, jsonb_object_agg(exploit.name, exploit.j) as exploit, 
    jsonb_object_agg(constr.name, constr.j) as constr from gas, exploit, constr;

    raise notice 'sum_values %', sum_values;
    -- Add the result to the JSONB object
    res := jsonb_set(res, array['total'], sum_values.gas, true);
    res := jsonb_set(res, array['total'], sum_values.exploit, true);
    res := jsonb_set(res, array['total'], sum_values.constr, true);

    return res;
end;
$$;

select api.get_histo_data('test_model') ;

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
gas as (select name, formula.sum_incert((result_ss_blocs).val, (result_ss_blocs).incert) as j
from in_use where id = 4 and name in ('n2o_e', 'ch4_e', 'co2_e') group by name),
exploit as (select name, formula.sum_incert((result_ss_blocs).val, (result_ss_blocs).incert) as j
from in_use where id = 4 and name like '%_e' group by name),
constr as (select name, formula.sum_incert((result_ss_blocs).val, (result_ss_blocs).incert) as j
from in_use where id = 4 and name like '%_c' group by name)
SELECT 
    gas.name, gas.j, exploit.name, exploit.j, constr.name, constr.j
    -- jsonb_object_agg(exploit.name, exploit.j) AS exploit,
    -- jsonb_object_agg(constr.name, constr.j) AS constr
FROM 
    gas
left join exploit on true 
left join constr on true 
;