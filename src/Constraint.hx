

import Strength;
import Variable;

@:enum
abstract Op(Int) from Int to Int {
    var GEQ = 1;
    var LEQ = 2;
}

class AbstractConstraint {

    public var hashcode:Int;
    public var strength:Strength;
    public var weight:Float;
    public var expression:Expression;
    public var variable:Variable;

    public var is_edit_constraint:Bool = false;
    public var is_stay_constraint:Bool = false;
    public var is_inequality:Bool = false;
    public var is_required (get,never) : Bool;
        function get_is_required() return strength == Strength.required;

    var tag:String = '';

    public function new(?_strength:Strength, _weight:Float=1.0) {

        hashcode = C.inc();
        weight = _weight;
        strength = Strength.required;
        if(_strength != null) {
            strength = _strength;
        }

    } //new

    function toString() {
        var s = '';
        if(tag != '') s += '$tag:';
        return '$s$strength {$weight} ($expression)';
    }

} //AbstractConstraint

class EditConstraint extends AbstractConstraint {
    public function new(cv:Variable, ?_strength:Strength, _weight:Float=1.0) {
        super(_strength, _weight);
        variable = cv;
        expression = new Expression(variable, -1, variable.value);
        is_edit_constraint = true;
        tag = 'edit';
    }
}

class StayConstraint extends AbstractConstraint {
    public function new(cv:Variable, ?_strength:Strength, _weight:Float=1.0) {
        super(_strength, _weight);
        variable = cv;
        expression = new Expression(variable, -1, variable.value);
        is_stay_constraint = true;
        tag = 'stay';
    }
}

class Constraint extends AbstractConstraint {
    public function new( cle:Expression, ?_strength:Strength, _weight:Float=1.0) {
        super(_strength, _weight);
        expression = cle;
    }
}

class Inequality extends Constraint {

    public function new(a1:Dynamic, a2:Dynamic, a3:Dynamic, a4:Dynamic, a5:Dynamic ) {

        var a1IsExp = Std.is(a1, Expression);
        var a3IsExp = Std.is(a3, Expression);
        var a1IsVar = Std.is(a1, AbstractVariable);
        var a3IsVar = Std.is(a3, AbstractVariable);
        var a1IsNum = Std.is(a1, Float);
        var a3IsNum = Std.is(a3, Float);

        // (cle || number), op, cv
        if((a1IsExp || a1IsNum) && a3IsNum) {
            var cle:Expression = a1; var op:Op = a2; var cv:AbstractVariable = a3;
            var _strength:Strength = a4; var _weight:Float = a5;

            super(cle.clone(), _strength, _weight);

            if(op == Op.LEQ) {
                expression.multiply_me(-1);
                expression.add_variable(cv);
            } else if(op == Op.GEQ) {
                expression.add_variable(cv, -1);
            } else {
                throw "Constraint.Inequality: Invalid operator in c.Inequality constructor";
            }
        }

        else

        // cv, op, (cle || number)
        if (a1IsVar && (a3IsExp || a3IsNum)) {

            var cle:Expression = a3; var op:Op = a2; var cv:AbstractVariable = a1;
            var _strength:Strength = a4; var _weight:Float = a5;

            super(cle.clone(), _strength, _weight);

            if(op == Op.GEQ) {
                expression.multiply_me(-1);
                expression.add_variable(cv);
            } else if(op == Op.LEQ) {
                expression.add_variable(cv, -1);
            } else {
                throw "Constraint.Inequality: Invalid operator in c.Inequality constructor";
            }

        }

        else

        // cle, op, num

        if(a1IsExp && a3IsNum) {
            var cle1:Expression = a1; var op:Op = a2; var cle2:Expression = a3;
            var _strength:Strength = a4; var _weight:Float = a5;

            super(cle1.clone(), _strength, _weight);

            if(op == Op.LEQ) {
                expression.multiply_me(-1);
                expression.add_expr(cle2.clone());
            } else if(op == Op.GEQ) {
                expression.add_expr(cle2.clone(), -1);
            } else {
                throw "Constraint.Inequality: Invalid operator in c.Inequality constructor";
            }

            return;
        }

        else

        // num, op, cle

        if (a1IsNum && a3IsExp) {
            var cle1:Expression = a3; var op:Op = a2; var cle2:Expression = a1;
            var _strength:Strength = a4; var _weight:Float = a5;

            super(cle1.clone(), _strength, _weight);

            if(op == Op.GEQ) {
                expression.multiply_me(-1);
                expression.add_expr(cle2.clone());
            } else if(op == Op.LEQ) {
                expression.add_expr(cle2.clone(), -1);
            } else {
                throw "Constraint.Inequality: Invalid operator in c.Inequality constructor";
            }

            return;
        }

        else

        // cle op cle

        if (a1IsExp && a3IsExp) {
            var cle1:Expression = a1; var op:Op = a2; var cle2:Expression = a3;
            var _strength:Strength = a4; var _weight:Float = a5;

            super(cle2.clone(), _strength, _weight);

            if(op == Op.GEQ) {
                expression.multiply_me(-1);
                expression.add_expr(cle1.clone());
            } else if(op == Op.LEQ) {
                expression.add_expr(cle1.clone(), -1);
            } else {
                throw "Constraint.Inequality: Invalid operator in c.Inequality constructor";
            }

        }

        else

        //cle

        if(a1IsExp) {
            super(a1, a2, a3);
        }

        else

        if((a2:Op) == Op.GEQ ) {
            super( new Expression(a3), a4, a5);
            expression.multiply_me(-1);
            expression.add_variable(a1);
        }

        else if((a2:Op) == Op.LEQ) {
            super(new Expression(a3), a4, a5);
            expression.add_variable(a1, -1);
        } else {
            throw "Constraint.Inequality: Invalid operator in c.Inequality constructor";
        }

    } //new

    override function toString() {
        return super.toString() + ' >= 0) id: $hashcode';
    }

} //Inequality


class Equation extends Constraint {

    public function new(a1:Dynamic, a2:Dynamic, ?a3:Dynamic, ?a4:Dynamic) {
        if(Std.is(a1, Expression) && (a2 == null || Std.is(a2, Strength))) {

            super(a1, a2, a3);

        } else if(Std.is(a1,AbstractVariable) && Std.is(a2, Expression)) {

            var cv:AbstractVariable = a1; var cle:Expression = a2;
            super( cle.clone(), a3, a4 );
            expression.add_variable(cv, -1);

        } else if(Std.is(a1, AbstractVariable) && Std.is(a2, Float)) {

            var cv:AbstractVariable = a1; var val:Float = a2;
            super(new Expression(new Variable({value:val})), a3, a4);
            expression.add_variable(cv, -1);

        } else if(Std.is(a1,Expression) && Std.is(a2, AbstractVariable)) {

            var cle:Expression = a1; var cv:AbstractVariable = a2;
            super(cle.clone(), a3, a4);
            expression.add_variable(cv, -1);

        } else if(
            (Std.is(a1, Expression) || Std.is(a1, AbstractVariable) || Std.is(a1, Float))
            &&
            (Std.is(a2, Expression) || Std.is(a2, AbstractVariable) || Std.is(a2, Float))
        ) {
            if(Std.is(a1, Expression)) {
                a1 = (a1:Expression).clone();
            } else {
                a1 = new Expression(a1);
            }

            if(Std.is(a2, Expression)) {
                a2 = (a2:Expression).clone();
            } else {
                a2 = new Expression(a2);
            }

            super(a1, a3, a4);
            expression.add_expr(a2, -1);
        } else {
            throw "Bad initializer to Equation";
        }

    } //new

    override function toString() {
        return super.toString() + ' = 0)';
    }


} //Equation



