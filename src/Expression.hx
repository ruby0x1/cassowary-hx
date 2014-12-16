
import Variable;

class Expression {

    public var is_constant (get,never):Bool;
    function get_is_constant() return Lambda.count(terms) == 0;

    public var terms : Map<AbstractVariable, Float>;

    public var constant : Float = 0.0;
    public function new( cvar:AbstractVariable, _value:Float=1.0, _constant:Float=0.0) {
        terms = new Map();
        constant = _constant;
        if(cvar != null) {
            set_variable(cvar, _value);
        }
    }

    public function init_from_hash(_constant:Float, t:Map<AbstractVariable, Float>) {
        constant = _constant;
        terms = new Map();
        for(v in t.keys()) terms.set(v, t.get(v));
        return this;
    }

    public function each(cb:AbstractVariable->Float->Void) {
        for(clv in terms.keys()) {
            var coeff = terms.get(clv);
            cb(clv, coeff);
        }
    }

    public function multiply_me(x:Float) {
        constant *= x;
        each(function(clv:AbstractVariable, coeff:Float){
            terms.set(clv, coeff * x);
        });
        return this;
    }

    public function clone() {
        var e = Expression.empty();
        return e.init_from_hash(constant, terms);
    }

    public function times(x:Float) {
        return clone().multiply_me(x);
    }

    public function timese(x:Expression) {
        if(is_constant) {
            return x.times(constant);
        } else if(x.is_constant) {
            return times(x.constant);
        } else {
            throw Error.NonExpression;
        }
    }

    public function plus(expr:Expression) {
        return clone().add_expr(expr,1);
    }

    public function plusv(cvar:Variable) {
        return clone().add_variable(cvar, 1);
    }

    public function minus(expr:Expression) {
        return clone().add_expr(expr,-1);
    }

    public function minusv(cvar:Variable) {
        return clone().add_variable(cvar, -1);
    }

    public function divide(x:Float) {
        if(Math.abs(x) < 0.000001) throw Error.NonExpression;
        return times(1/x);
    }

    public function dividee(x:Expression) {
        if(!x.is_constant) throw Error.NonExpression;
        return times(1/x.constant);
    }

    public function add_expr(expr:Expression, n:Float=1, ?subject:AbstractVariable, ?solver:Tableau) {
        constant += (n * expr.constant);
        expr.each(function(clv, coeff){
            add_variable(clv, coeff*n, subject, solver);
        });
        return this;
    }

    public function add_variable(v:AbstractVariable, cd:Float=1.0, ?subject:AbstractVariable, ?solver:Tableau) {
        var coeff = terms.get(v);
        if(coeff != null) {
            var new_coeff = coeff+cd;
            if(new_coeff == 0 || (Math.abs(new_coeff) < 0.000001)) {
                if(solver != null) {
                    solver.note_removed(v, subject);
                }
                terms.remove(v);
            } else {
                set_variable(v, new_coeff);
            }
        } else {
            if(!(Math.abs(cd) < 0.000001)) {
                set_variable(v, cd);
                if(solver != null) {
                    solver.note_added(v, subject);
                }
            }
        }

        return this;
    }

    public function set_variable(v:AbstractVariable, c:Float) {
        terms.set(v, c);
        return this;
    }

    public function any_pivotable_variable() {
        if(is_constant) throw "Expression: any_pivotable_variable called on a constant";

        var rv = null;
        for(clv in terms.keys()) {
            if(clv.is_pivotable) {
                rv = clv;
                break;
            }
        }

        return rv;

    } //any_pivotable_variable

    public function substitute_out(outvar:AbstractVariable, expr:Expression, ?subject:AbstractVariable, ?solver:Tableau) {
        var multiplier = terms.get(outvar);
        terms.remove(outvar);
        constant += (multiplier * expr.constant);

        expr.each(function(clv, coeff){
            var old_coeff = terms.get(clv);
            if(old_coeff != null) {
                var new_coeff = old_coeff + multiplier * coeff;
                if(Math.abs(new_coeff) < 0.000001) {
                    solver.note_removed(clv, subject);
                    terms.remove(clv);
                } else {
                    terms.set(clv, new_coeff);
                }
            } else {
                terms.set(clv, multiplier*coeff);
                if(solver != null) {
                    solver.note_added(clv, subject);
                }
            }
        });
    }

    public function change_subject(old_subject:AbstractVariable, nsubj:AbstractVariable) {
        set_variable(old_subject, new_subject(nsubj));
    }

    public function new_subject(subject:AbstractVariable) {
        var reciprocal = 1 / terms.get(subject);
        terms.remove(subject);
        multiply_me(-reciprocal);
        return reciprocal;
    }

    public function terms_equals(other:Map<AbstractVariable, Float>) {
        if(terms == other) return true;
        if( Lambda.count(terms) != Lambda.count(other)) return false;
        for(clv in terms.keys()) {
            var found=false;
            for(oclv in other.keys()) {
                if(oclv == clv) found = true;
            }
            if(!found) return false;
        }
        return true;
    }

    public function str() {
        return '{ constant: $constant, terms: ${Std.string(terms)} }';
    }
    function toString() {
        var bstr = '';
        var needsplus = false;
        if(!C.approx(constant,0) || is_constant) {
            bstr += constant;
            if(is_constant) {
                return bstr;
            } else {
                needsplus = true;
            }
        }
        each(function(clv,coeff){
            if(needsplus) bstr += ' + ';
            bstr += coeff + '*' + clv.value;
            needsplus = true;
        });
        return bstr;
    }

    public function equals(other:Expression) {
        if(this == other) return true;
        return (other.constant == constant && terms_equals(other.terms));
    }

    public function coefficient_for(clv:AbstractVariable) {
        var c = terms.get(clv);
        return c == null ? 0 : c;
    }

    public function Plus(e1:Expression, e2:Expression) {
        return e1.plus(e2);
    }

    public function Minus(e1:Expression, e2:Expression) {
        return e1.minus(e2);
    }

    public function Times(e1:Expression, e2:Float) {
        return e1.times(e2);
    }

    public function Timese(e1:Expression, e2:Expression) {
        return e1.timese(e2);
    }

    public function Divide(e1:Expression, e2:Float) {
        return e1.divide(e2);
    }

    public function Dividee(e1:Expression, e2:Expression) {
        return e1.dividee(e2);
    }

    public static function empty(){ return new Expression(null, 1, 0); }
    public static function from_constant(cons:Float){ return new Expression(null,0,cons); }
    public static function from_value(v:Float){ return new Expression(null, v, 0); }
    public static function from_variable(v:AbstractVariable){ return new Expression(v,1,0); }
}
