

import Tableau;
import Variable;
import Constraint;


typedef ChangeInfo = {name:String, c:Float};

class SimplexSolver extends Tableau {

    public var auto_solve = true;


    var stay_minus_error_vars : Array<AbstractVariable>;
    var stay_plus_error_vars : Array<AbstractVariable>;
    var error_vars:Map<AbstractConstraint, Array<AbstractVariable>>;
    var marker_vars:Map<AbstractConstraint, AbstractVariable>;

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
        changed = [];
        error_vars = new Map();
        marker_vars = new Map();

        objective = new ObjectiveVariable({name:"Z"});
        edit_var_map = new Map();
        edit_var_list = [];

        rows.set(objective, Expression.empty());
        edit_var_stack = [0];
        C.logv("objective expr == " + rows.get(objective));
    }

    public function add(list:Array<Constraint>) {
        for(c in list) {
            add_constraint(c);
        }
        return this;
    }

    function add_edit_constraint(cn:AbstractConstraint, eplus_eminus:Array<AbstractVariable>, prev_edit_const:Float ) {
        var i = Lambda.count(edit_var_map);

        var cv_eplus = eplus_eminus[0];
        var cv_eminus = eplus_eminus[1];

        C.log("new c.EditInfo(" + cn + ", " + cv_eplus + ", " +
                          cv_eminus + ", " + prev_edit_const + ", " +
                          i +")");

        var ei : EditInfo = new EditInfo({
            constraint: cn, edit_plus: cv_eplus, edit_minus: cv_eminus,
            prev_edit: prev_edit_const, index: i
        });

        edit_var_map.set(cn.variable, ei);
        edit_var_list[i] = { v:cn.variable, info:ei };
    }


    public function add_constraint(cn:AbstractConstraint) {
        C.fnenter('addConstraint: ' + cn);
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
            add_edit_constraint(cn , _eplus_eminus, prev_edit_const);
        }

        if(auto_solve) {
            optimize(objective);
            set_external_variables();
        }
        return this;
    } //add_constraint

    public function add_edit_var(v:Variable, ?_strength:Strength, ?_weight:Float=1.0) {
        C.fnenter("addEditVar: " + v.val + " @ " + _strength + " {" + _weight + "}");

        if(_strength == null) _strength = Strength.strong;
        return add_constraint(new EditConstraint(v, _strength, _weight));

    } //add_edit_var

    public function begin_edit() {
        var size = Lambda.count(edit_var_map);
        if(size == 0) C.log("_editVarMap.size = 0");
        infeasible_rows.splice(0, infeasible_rows.length);
        reset_stay_constants();
        edit_var_stack[edit_var_stack.length] = size;
        return this;
    } //begin_edit

    public function end_edit() {
        var size = Lambda.count(edit_var_map);
        if(size == 0) C.log("_editVarMap.size = 0");
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
        C.log('addPointStays: ' + Std.string(points));

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
        return add_constraint(new StayConstraint(v, _strength, _weight));
    } //add_stay

    public function remove_constraint(cn:AbstractConstraint) {
        C.fnenter('removeConstraintInternal: ' + cn);
        C.logv(this);

        needs_solving = true;
        reset_stay_constants();

        var zrow = rows.get(objective);
        var evars = error_vars.get(cn);
        C.logv('evars == ' + Std.string(evars));

        if(evars != null) {
            for(cv in evars) {
                var expr = rows.get(cv);
                if(expr == null) {
                    zrow.add_variable(cv, -cn.weight * cn.strength.symbolic_weight.value, objective, this);
                } else { //expr == null
                    zrow.add_expr(expr, -cn.weight * cn.strength.symbolic_weight.value, objective, this);
                } //expr != null
            } //each evars

            C.logv('now evars == ' + Std.string(evars));
        } //evars != null

        var marker = marker_vars.get(cn);
        marker_vars.remove(cn);
        if(marker == null) {
            throw "Constraint not found in removeConstraintInternal";
        }

        C.logv('Looking to remove var $marker');

        if(rows.get(marker) == null) {
            var col = columns.get(marker);
            C.logv('Must pivot -- columns are $col');
            var exitvar:AbstractVariable = null;
            var minratio = 0.0;

            for(v in col) {
                if(v.is_restricted) {
                    var expr = rows.get(v);
                    var coeff = expr.coefficient_for(marker);
                    C.logv('Marker ${marker}\'s coefficient in $expr is $coeff');
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
                C.logv('exitvar is still null');
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
            if(evars == null) throw "evars == null";
            var cei = edit_var_map.get(cn.variable);
            remove_column(cei.edit_minus);
            edit_var_map.remove(cn.variable);
        }

        if(evars != null) {
            //:note: type errors...
            // error_vars.remove(evars);
        }

        if(auto_solve) {
            optimize(objective);
            set_external_variables();
        }

        return this;

    } //remove_constraint

    public function resolve_array(new_edit_constants:Array<Float>) {
        C.fnenter('resolveArray' + new_edit_constants);
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
        C.fnenter('resolve()');
        dual_optimize();
        set_external_variables();
        infeasible_rows.splice(0, infeasible_rows.length);
        reset_stay_constants();
    } //resolve

    public function suggest_value(v:AbstractVariable, x:Float) {
        C.log('suggestValue(${v.val}, $x)');
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
                throw "set_edited_value: error " + e;
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
                throw "Error in addVar -- required failure is impossible";
            }

            C.logv('added initial stay on $v');
        }
        return this;
    } //add_var

    public override function get_internal_info() {
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
        var bstr = super.get_internal_info();
            bstr += "\n_stayPlusErrorVars: ";
            bstr += Std.string(stay_plus_error_vars);
            bstr += "\n_stayMinusErrorVars: ";
            bstr += Std.string(stay_minus_error_vars);
            bstr += "\n";
            bstr += "_editVarMap:\n" + Std.string(edit_var_map);
            bstr += "\n";
        return bstr;
    }

    public function add_with_artificial_variable(expr:Expression) {
        C.fnenter('addWithArtificialVariable: $expr');
        var av = new SlackVariable({ value:++artificial_counter, prefix:'a' });
        var az = new ObjectiveVariable({ name:'az' });
        var azrow : Expression = expr.clone();
        C.logv('before addRows:\n' + this);
        add_row(az, azrow);
        add_row(av, expr);
        C.logv('after addRows:\n' + this);
        optimize(az);
        var az_tableau_row = rows.get(az);
        C.logv("azTableauRow.constant == " + az_tableau_row.constant);
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
        C.fnenter('tryAddingDirectly: $expr');
        var subject = choose_subject(expr);
        if(subject == null) {
            C.fnexit('returning false');
            return false;
        }
        expr.new_subject(subject);
        if(columns_has_key(subject)) {
            substitute_out(subject, expr);
        }
        add_row(subject, expr);
        C.fnexit('returning true');
        return true;
    } //try_adding_directly

    public function choose_subject(expr:Expression) {
        C.fnenter('chooseSubject: $expr');
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

        var coeff = 0.0;
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
        C.fnenter('deltaEditConstant: $delta, $plus_error_var, $minus_error_var');

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
            C.log('column_vars is null -- Tableau is $this');
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
        C.fnenter('dualOptimize:');

        var zrow = rows.get(objective);
        while(infeasible_rows.length > 0) {
            var exitvar = infeasible_rows.shift();
            var entryvar:AbstractVariable = null;
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

    public function new_expression(cn:AbstractConstraint, eplus_eminus:Array<AbstractVariable>, prev_edit_const:Array<Float> ) {
        C.fnenter('newExpression: $cn' );
        C.logv('cn.isInequality == ' +cn.is_inequality);
        C.logv('cn.required == ' +cn.is_required);

        var cnexpr = cn.expression;
        var expr = Expression.from_constant(cnexpr.constant);
        var slackvar = new SlackVariable();
        var dummyvar = new DummyVariable();
        var eminus = new SlackVariable();
        var eplus = new SlackVariable();
        var cnterms = cnexpr.terms;

        cnexpr.each(function(v,c){
            var e = rows.get(v);
            if(e == null) {
                expr.add_variable(v, c);
            } else {
                expr.add_expr(e, c);
            }
        });

        if(cn.is_inequality) {
            C.logv('is_inequality, adding slack');
            ++slack_counter;
            slackvar = new SlackVariable({value:slack_counter, prefix:'s'});
            expr.set_variable(slackvar, -1);
            marker_vars.set(cn, slackvar);

            if(!cn.is_required) {
                ++slack_counter;
                eminus = new SlackVariable({value:slack_counter, prefix:'em'});
                expr.set_variable(eminus,1);
                var zrow = rows.get(objective);
                zrow.set_variable(eminus, cn.strength.symbolic_weight.value*cn.weight);
                insert_error_var(cn, eminus);
                note_added(eminus, objective);
            }

        } else {

            if(cn.is_required) {
                C.logv('Equality, required');
                ++dummy_counter;
                dummyvar = new DummyVariable({ value:dummy_counter, prefix:'d' });
                eplus_eminus[0] = dummyvar;
                eplus_eminus[1] = dummyvar;
                prev_edit_const[0] = cnexpr.constant;
                expr.set_variable(dummyvar, 1);
                marker_vars.set(cn, dummyvar);
                C.logv('Adding dummyVar == d${dummy_counter}');
            } else {
                C.logv('Equality, not required');
                slack_counter++;
                eplus = new SlackVariable({value:slack_counter, prefix:'ep'});
                eminus = new SlackVariable({value:slack_counter, prefix:'em'});
                expr.set_variable(eplus,-1);
                expr.set_variable(eminus,1);
                marker_vars.set(cn, eplus);
                var zrow = rows.get(objective);
                C.log(zrow.str());
                var swcoeff = cn.strength.symbolic_weight.value * cn.weight;
                if(swcoeff == 0) {
                    C.logv('cn == $cn');
                    C.logv('adding $eplus and $eminus with swcoeff $swcoeff');
                }
                zrow.set_variable(eplus, swcoeff);
                note_added(eplus, objective);
                zrow.set_variable(eminus, swcoeff);
                note_added(eminus, objective);

                insert_error_var(cn, eminus);
                insert_error_var(cn, eplus);

                if(cn.is_stay_constraint) {
                    stay_plus_error_vars.push(eplus);
                    stay_minus_error_vars.push(eminus);
                } else if(cn.is_edit_constraint) {
                    eplus_eminus[0] = eplus;
                    eplus_eminus[1] = eminus;
                    prev_edit_const[0] = cnexpr.constant;
                }
            }

        } //is_inequality

        if(expr.constant < 0) expr.multiply_me(-1);
        C.fnexit('returning $expr');
        return expr;

    } //new_expression

    public function optimize(zvar:ObjectiveVariable) {
        C.fnenter('optimize: ${zvar.val}');
        C.logv(this);
        optimize_count++;

        var zrow = rows.get(zvar);
        if(zrow == null) throw "zrow is null";

        var entryvar:AbstractVariable = null;
        var exitvar:AbstractVariable = null;
        var objectivecoeff:Float;

        while(true) {

            objectivecoeff = 0.0;

            for(v in zrow.terms.keys()) {
                var c = zrow.terms.get(v);
                if(v.is_pivotable && c < objectivecoeff) {
                    objectivecoeff = c;
                    entryvar = v;
                    break;
                }
            }

            if(objectivecoeff >= -C.epsilon) return;

            C.log('entryVar: $entryvar objectiveCoeff: $objectivecoeff');

            var minratio = max_float;
            var columnvars = columns.get(entryvar);
            var r = 0.0;

            for(v in columnvars) {
                C.logv('Checking ${v.val}');
                if(v.is_pivotable) {
                    var expr = rows.get(v);
                    var coeff = expr.coefficient_for(entryvar);
                    C.logv('pivotable, coeff = $coeff');
                    if(coeff < 0) {
                        r = -expr.constant / coeff;
                        if(r < minratio || (C.approx(r, minratio) && v.hashcode < exitvar.hashcode)) {
                            minratio = r;
                            exitvar = v;
                        }
                    }
                }
            } //each columnvar

            if(minratio == max_float) {
                throw "Objective function is unbounded in optimize";
            }

            pivot(entryvar, exitvar);

            C.logv(this);

        } //while
    } //optimize

    public function pivot(entryvar:AbstractVariable, exitvar:AbstractVariable) {
        C.log('pivot:  $entryvar $exitvar');

        if(entryvar == null) C.log("pivot: entryvar is null");
        if(exitvar == null) C.log("pivot: exitvar is null");

        var expr = remove_row(exitvar);
        expr.change_subject(exitvar, entryvar);
        substitute_out(entryvar, expr);
        add_row(entryvar, expr);
    }

    function reset_stay_constants() {
        C.log('_resetStayConstants');
        var spev = stay_plus_error_vars;
        var l = spev.length;
        for(i in 0 ... l) {
            var expr = rows.get(spev[i]);
            if(expr == null) {
                expr = rows.get(stay_minus_error_vars[i]);
            }
            if(expr != null) {
                expr.constant = 0;
            }
        }
    }

    var changed:Array<ChangeInfo>;
    var callbacks:Array< Array<ChangeInfo>->Void >;

    function set_external_variables() {
        C.fnenter('_setExternalVariables:' );
        C.logv(this);
        var _changed:Array<{name:String, c:Float}> = [];

        for(v in external_parametric_vars) {
            if(rows.get(v) != null) {
                C.log('error: variable $v in external_parametric_vars is basic');
            } else {
                v.value = 0;
                _changed.push({name:v.name, c:0});
            }
        }

        for(v in external_rows) {
            var expr = rows.get(v);
            if(v.value != expr.constant) {
                v.value = expr.constant;
                changed.push({name:v.name,c:expr.constant});
            }
        }

        changed = _changed;
        needs_solving = false;
        inform_callbacks();
        onsolved();
    }

    function inform_callbacks() {
        if(callbacks == null) return;
        for(fn in callbacks) {
            fn(changed);
        }
    }

    public function add_callback(fn:Array<ChangeInfo>->Void) {
        if(callbacks == null) callbacks = [];
        callbacks.push(fn);
    }

    function onsolved() {

    }

    public function insert_error_var(cn:AbstractConstraint, avar:AbstractVariable) {
        C.fnenter('insertErrorVar:$cn, ${avar.value}');
        var constraint_set = error_vars.get(cn); //:note:changed to cn, as that was wrong?
        if(constraint_set == null) {
            constraint_set = []; C.inc();
            error_vars.set(cn, constraint_set);
        }
        constraint_set.push(avar);
    }

    static var max_float = Math.pow(2,52);

} //SimplexSolver


