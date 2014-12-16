

import Tableau;
import Variable;
import Constraint;

class SimplexSolver extends Tableau {

    public var auto_solve = true;


    var stay_minus_error_vars : Array<AbstractVariable>;
    var stay_plus_error_vars : Array<AbstractVariable>;
    var error_vars:Map<Constraint, Array<AbstractVariable>>;
    var marker_vars:Map<Constraint, Array<AbstractVariable>>;

    var objective:ObjectiveVariable;
    var edit_var_map:Map<AbstractVariable, EditInfo>;
    var edit_var_list:Array<{v:AbstractVariable, info:EditInfo}>;
    var edit_var_stack:Array<Int>;

    var slack_counter = 0;
    var artificial_counter = 0;
    var dummy_counter = 0;
    var needs_solving = false;
    var optimize_count = 0;

    public function new() {
        super();
        stay_plus_error_vars = [];
        stay_minus_error_vars = [];
        error_vars = new Map();
        marker_vars = new Map();

        objective = new ObjectiveVariable({name:"Z"});
        edit_var_map = new Map();
        edit_var_list = [];

        rows.set(objective, Expression.empty());
        edit_var_stack = [0];
        trace("objective expr == " + rows.get(objective));
    }

    public function add(list:Array<Constraint>) {
        for(c in list) {
            add_constraint(c);
        }
        return this;
    }

    function add_edit_constraint(cn:Constraint, eplus_eminus:Array<SlackVariable>, prev_edit_const:Float ) {
        var i = Lambda.count(edit_var_map);
        var cv_eplus = eplus_eminus[0];
        var cv_eminus = eplus_eminus[1];
        var ei : EditInfo = {
            constraint: cn, edit_plus: cv_eplus, edit_minus: cv_eminus,
            prev_edit: prev_edit_const, index: i
        }

        edit_var_map.set(cn.variable, ei);
        edit_var_list[i] = { v:cn.variable, info:ei };
    }


    public function add_constraint(cn:Constraint) {
        trace('SimplexSolver.add_constraint ' + cn);
            //output into these
        var _eplus_eminus = [];
        var _prev_edit_const = [];
            //from this
        var expr = new_expression( cn, _eplus_eminus, _prev_edit_const);
        var prev_edit_const:Float = _prev_edit_const[0];

        if(!try_adding_directly(expr)) {
            add_with_artificial_variable(expr);
        }

        needs_solving = true;
        if(cn.is_edit_constraint) {
            add_edit_constraint(cn , eplus_eminus, prev_edit_const);
        }

        if(auto_solve) {
            optimize(objective);
            set_external_variables();
        }
        return this;
    } //add_constraint

    public function add_edit_var(v:Variable, ?_strength:strength, ?_weight:Float=1.0) {
        trace("SimplexSolver.add_edit_var: " + v + " @ " + _strength + " {" + _weight + "}");

        if(_strength == null) _strength = Strength.strong;
        return add_constraint(new EditConstraint(cv, _strength, _weight));

    } //add_edit_var

    public function begin_edit() {
        var size = Lambda.count(edit_var_map);
        if(size == 0) trace("_editVarMap.size = 0");
        infeasible_rows.splice(0, infeasible_rows.length);
        reset_stay_constants();
        edit_variable_stack[edit_var_stack.length] = size;
        return this;
    } //begin_edit

    public function end_edit() {
        var size = Lambda.count(edit_var_map);
        if(size == 0) trace("_editVarMap.size = 0");
        resolve();
        edit_var_stack.pop();
        remove_edit_vars_to( edit_var_stack[edit_var_stack.length-1] );
        return this;
    } //end_edit

    public function remove_all_edit_vars() {
        return remove_edit_vars_to(0);
    } //remove_all_edit_vars

    public function remove_edit_vars_to(n:Int) {
        try{

            var evll = edit_var_list.length;
            for(x in n ... evll) {
                if(edit_var_list[x] != null) {
                    remove_constraint( edit_var_map.get(edit_var_list[x].v).constraint );
                }
            }

            edit_var_list.splice(n, edit_var_list.length);
            if(Lambda.count(edit_var_map) != n) throw "edit_var_map != n";

        } catch(e:Dynamic) {
            throw "SimplexSolver Constraint not found in remove_edit_vars_to";
        }
        return this;
    } //remove_edit_vars_to

    public function add_point_stays(points:Array<{x:Float,y:Float}>) {
        trace('SimplexSolver.add_point_stays ' + Std.string(points));

        var idx = 0;
        for(p in points) {
            add_stay(p.x, Strength.weak, Math.pow(2, idx));
            add_stay(p.y, Strength.weak, Math.pow(2, idx));
            idx++;
        }

        return this;
    } //add_point_stays

    public function add_stay(v:Variable, ?_strength:Strength, ?_weight:Float=1.0 ) {
        if(_strength == null) _strength = Strength.weak;
        return add_constraint(new StayConstraint(cv, _strength, _weight));
    } //add_stay

    public function remove_constraint(cn:Constraint) {
        trace('SimplexSolver.remove_constraint_internal ' + cn);
        trace(this);

        needs_solving = true;
        reset_stay_constants();

        var zrow = rows.get(objective);
        var evars = error_vars.get(cn);
        trace('evars == ' + Std.String(evars));

        if(evars != null) {
            for(cv in evars) {
                var expr = rows.get(cv);
                if(expr == null) {
                    zrow.add_variable(cv, -cn.weight * cn.strength.symbolic_weight.value, objective, this);
                } else { //expr == null
                    zrow.add_expr(expr, -cm.weight * cn.strength.symbolic_weight.value, objective, this);
                } //expr != null
            } //each evars

            trace('now evars == ' + Std.String(evars));
        } //evars != null

        var marker = marker_vars.get(cn);
        marker_vars.remove(cn);
        if(marker == null) {
            throw "Constraint not found in remove_constraint_internal";
        }

        trace('SimplexSolver.remove_constraint_internal looking to remove var $marker');

        if(rows.get(marker) == null) {
            var col = columns.get(marker);
            trace('SimplexSolver.remove_constraint_internal: must pivot -- columns are $col');
            var exitvar:AbstractVariable = null;
            var minratio = 0.0;

            for(v in col) {
                if(v.is_restricted) {
                    var expr = rows.get(v);
                    var coeff = expr.coefficient_for(marker);
                    trace('SimplexSolver.remove_constraint_internal: marker $marker coeff in $expr is coeff');
                    if(coeff < 0) {
                        var r = -expr.constant / coeff;
                        if( exitvar == null ||
                            r < minratio ||
                            (C.approx(r,minratio) && v.hashcode < exitvar.hashcode)
                        ) {
                            minratio = r;
                            exitvar = v;
                        } //if
                    } //coeff <0
                } //is_restricted
            } //each v in col

            if(exitvar == null) {
                trace('SimplexSolver.remove_constraint_internal: exitvar is still null');
                for(v in col) {
                    if(v.is_restricted) {
                        var expr = rows.get(v);
                        var coeff = expr.coefficient_for(marker);
                        var r = expr.constant / coeff;
                        if(exitvar == null || r < minratio) {
                            minratio = r;
                            exitvar = v;
                        }
                    }
                }//each v in col
            } //exitvar == null

            if(exitvar == null) {
                if(Lambda.count(col) == 0) {
                    remove_column(marker);
                } else {
                    for(v in col) {
                        if(v != objective) {
                            exitvar = v;
                            break;
                        }
                    } //each v in col
                } //count = 0
            } //exitvar != null

            if(exitvar != null) {
                pivot(marker, exitvar);
            } //exitvar != null

        } //rows.get(marker) != null


        if(rows.get(marker) != null) {
            var expr = remove_row(marker);
        }

        if(evars != null) {
            for(v in evars) {
                if(v != marker) remove_column(v);
            }
        }

        if(cn.is_stay_constraint) {
            if(evars != null) {
                for(i in 0 ... stay_plus_error_vars.length) {
                    evars.remove(stay_plus_error_vars[i]);
                    evars.remove(stay_minus_error_vars[i]);
                }
            }
        } else if(cn.is_edit_constraint) {
            if(evars == null) throw "SimplexSolver.remove_constraint_internal: evars == null";
            var cei = edit_var_map.get(cn.variable);
            remove_column(cei.edit_minus);
            edit_var_map.remove(cn.variable);
        }

        if(evars != null) {
            error_vars.remove(evars);
        }

        if(auto_solve) {
            optimize(objective);
            set_external_variables();
        }

        return this;

    } //remove_constraint

    public function resolve_array(new_edit_constants:Array<Float>) {
        trace('SimplexSolver.resolve_array ' + new_edit_constants);
        var l = new_edit_constants.length;
        for(v in edit_var_map.keys()) {
            var cei = edit_var_map.get(v);
            var i = cei.index;
            if(i < l) {
                suggest_value(v, new_edit_constants[i]);
            }
        }
        resolve();
    } //resolve_array

    public function resolve_pair(x:Float, y:Float) {
        suggest_value(edit_var_list[0].v, x);
        suggest_value(edit_var_list[1].v, y);
        resolve();
    } //resolve_pair

    public function resolve() {
        trace('SimplexSolver.resolve()');
        dual_optimize();
        set_external_variables();
        infeasible_rows.splice(0, infeasible_rows.length);
        reset_stay_constants();
    } //resolve

    public function suggest_value(v:Variable, x:Float) {
        trace('SimplexSolver.suggest_value: ($v , $x)');
        var cei = edit_var_map.get(v);
        if(cei == null) {
            throw "suggestValue for variable " + v + ", but var is not an edit variable";
        }
        var delta = x - cei.prev_edit;
        cei.prev_edit = x;
        delta_edit_constant(delta, cei.edit_plus, cei.edit_minus);
        return this;
    } //suggest_value

    public function solve() {
        if(needs_solving) {
            optimize(objective);
            set_external_variables();
        }
        return this;
    }

    public function set_edited_value(v:Variable, n:Float) {

        if( !( columns_has_key(v)||(rows.get(v) != null)  )) {
            v.value = n;
            return this;
        }

        if(!C.approx(n, v.value)) {
            add_edit_var(v);
            begin_edit();

            try{
                suggest_value(v , n);
            } catch(e:Dynamic) {
                throw "SimplexSolver.set_edited_value: error " + e;
            }

            end_edit();
        }

        return this;

    } //set_edited_value

    public function add_var(v:Variable) {
        if( !(columns_has_key(v) || (rows.get(v) != null)) ) {
            try{
                add_stay(v);
            } catch(e:Dynamic) {
                throw "SimplexSolver.add_var Error -- required failure is impossible";
            }

            trace('SimplexSolver.add_var added initial stay on $v');
        }
        return this;
    } //add_var

    public function get_internal_info() {
        var retstr = super.get_internal_info();
            retstr += "\nSolver info:\n";
            retstr += "Stay Error Variables: ";
            retstr += stay_plus_error_vars.length + stay_minus_error_vars.length;
            retstr += " (" + stay_plus_error_vars.length + " +, ";
            retstr += stay_minus_error_vars.length + " -)\n";
            retstr += "Edit Variables: " + Lambda.count(edit_var_map);
            retstr += "\n";
        return retstr;
    } //get_internal_info

    public function get_debug_info() {
        return toString() + get_internal_info() + '\n';
    }

    override function toString() {
        var bstr = super.toString();
            bstr += "\nstay_plus_error_vars: ";
            bstr += '[' + Std.string(stay_plus_error_vars) + ']';
            bstr += "\nstay_minus_error_vars: ";
            bstr += '[' + Std.string(stay_minus_error_vars) + ']';
            bstr += "\n";
            bstr += "edit_var_map:\n" + Std.string(edit_var_map);
            bstr += "\n";
        return bstr;
    }

    public function add_with_artificial_variable(expr:Expression) {
        trace('SimplexSolver.add_with_artificial_variable $expr');
        var av = new SlackVariable({ value:++artificial_counter, prefix:'a' });
        var az = new ObjectiveVariable({ name:'az' });
        var azrow : Expression = expr.clone();
        trace('before add_rows\n' + this);
        add_row(az, azrow);
        add_row(av, expr);
        trace('after add_rows\n' + this);
        optimize(az);
        var az_tableau_row = rows.get(az);
        trace("az_tableau_row.constant == " + az_tableau_row.constant);
        if(!C.approx(az_tableau_row.constant, 0)) {
            remove_row(az);
            remove_column(av);
            throw Error.RequiredFailure;
        }

        var e = rows.get(av);
        if(e != null) {
            if(e.is_constant) {
                remove_row(av);
                remove_row(az);
                return;
            }
            var entryvar = e.any_pivotable_variable();
            pivot(entryvar, av);
        }
        if(rows.get(av) != null) throw "rowExpression(av) != null";
        remove_column(av);
        remove_row(az);
    } //add_with_artificial_variable

    public function try_adding_directly(expr:Expression) {
        trace('SimplexSolver.try_adding_directly $expr');
        var subject = choose_subject(expr);
        if(subject == null) {
            trace('return false');
            return false;
        }
        expr.new_subject(subject);
        if(columns_has_key(subject)) {
            substitute_out(subject, expr);
        }
        add_row(subject, expr);
        trace('return true');
        return true;
    } //try_adding_directly

    public function choose_subject(expr:Expression) {
        trace('SimplexSolver.choose_subject $expr');
        var subject = null;
        var found_unrestricted = false;
        var found_new_restricted = false;
        var terms = expr.terms;
        var rv = null;

        for(v in terms.keys()) {
            var c = terms.get(v);
            if(found_unrestricted) {
                if(!v.is_restricted) {
                    if(!columns_has_key(v)) {
                        rv = v;
                        break;
                    }
                }
            } else {
                if(v.is_restricted) {
                    if(!found_new_restricted && !v.is_dummy && c < 0) {
                        var col = columns.get(v);
                        if(col == null || (col.length == 1 && columns_has_key(objective))) {
                            subject = v;
                            found_new_restricted = true;
                        }
                    }
                } else {
                    subject = v;
                    found_unrestricted = true;
                }
            } //else !found_unrestricted
        } //for each term

        if(rv != null) return rv;
        if(subject != null) return subject;

        var coeff = 0;
        var nrv = false;
        for(v in terms.keys()) {
            var c = terms.get(v);
            if(!v.is_dummy) { nrv = true; break; }
            if(!columns_has_key(v)) {
                subject = v;
                coeff = c;
            }
        } //for each

        if(nrv) return null;
        if(!C.approx(expr.constant,0)) {
            throw Error.RequiredFailure;
        }
        if(coeff > 0) {
            expr.multiply_me(-1);
        }

        return subject;

    } //choose_subject

    public function delta_edit_constant(delta:Float, plus_error_var:AbstractVariable, minus_error_var:AbstractVariable ) {
        trace('SimplexSolver.delta_edit_constant: $delta, $plus_error_var, $minus_error_var');

        var expr_plus = rows.get(plus_error_var);
        if(expr_plus != null) {
            expr_plus.constant += delta;
            if(expr_plus.constant < 0) {
                infeasible_rows.push(plus_error_var);
            }
            return;
        }

        var expr_minus = rows.get(minus_error_var);
        if(expr_minus != null) {
            expr_minus.constant += -delta;
            if(expr_minus.constant < 0) {
                infeasible_rows.push(minus_error_var);
            }
            return;
        }

        var column_vars = columns.get(minus_error_var);
        if(column_vars == null) {
            trace('column_vars is null -- Tableau is $this');
        } else {
            for(basicvar in column_vars) {
                var expr = rows.get(basicvar);
                var c = expr.coefficient_for(minus_error_var);
                expr.constant += (c*delta);
                if(basicvar.is_restricted && expr.constant < 0) {
                    infeasible_rows.push(basicvar);
                }
            }
        } //

    } //delta_edit_constant

    public function dual_optimize() {
        trace('SimplexSolver.dual_optimize');

        var zrow = rows.get(objective);
        while(infeasible_rows.length > 0) {
            var exitvar = infeasible_rows.shift();
            var entryvar = null;
            var expr = rows.get(exitvar);
            if(expr != null) {
                if(expr.constant < 0) {
                    var ratio = max_float;
                    var r = 0.0;
                    var terms = expr.terms;
                    expr.each(function(v,cd){
                        if(cd > 0 && v.is_pivotable) {
                            var zc = zrow.coefficient_for(v);
                            r = zc / cd;
                            if(r < ratio || (C.approx(r,ratio) && v.hashcode < entryvar.hashcode)) {
                                entryvar = v;
                                ratio = r;
                            }
                        }
                    });
                    if(ratio == max_float) {
                        throw "ratio == max_float in dual_optimize";
                    }
                    pivot(entryvar, exitvar);
                }
            }
        }
    } //dual_optimize

    static var max_float = Math.pow(2,52);

} //SimplexSolver


