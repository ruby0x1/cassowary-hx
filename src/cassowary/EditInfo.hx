package cassowary;

import cassowary.Variable;
import cassowary.Constraint;

typedef EditInfoArgs = {
    var constraint:AbstractConstraint;
    var edit_plus:AbstractVariable;
    var edit_minus:AbstractVariable;
    var prev_edit:Float;
    var index:Int;
}

class EditInfo {

    public var constraint:AbstractConstraint;
    public var edit_plus:AbstractVariable;
    public var edit_minus:AbstractVariable;
    public var prev_edit:Float;
    public var index:Int;

    public function new( args:EditInfoArgs ) {
        constraint = args.constraint;
        edit_plus = args.edit_plus;
        edit_minus = args.edit_minus;
        prev_edit = args.prev_edit;
        index = args.index;
    }

    function toString() return
        "<cn=" + this.constraint +
           ", ep=" + edit_plus +
           ", em=" + edit_minus +
           ", pec=" + prev_edit +
           ", index=" + index
        + ">";
}