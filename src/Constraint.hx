
import Strength;

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

        hashcode = Luxe.utils.uniqueid();
        weight = _weight;
        strength = Strength.required;
        if(_strength != null) {
            strength = _strength;
        }

    } //new

    function toString() return '$tag: $strength {$weight} ($expression)';

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
    public function new() {

    }
}




