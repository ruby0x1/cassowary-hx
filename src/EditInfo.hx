
import Variable;
import Constraint;

typedef EditInfoArgs = {
    var constraint:AbstractConstraint;
    var edit_plus:SlackVariable;
    var edit_minus:SlackVariable;
    var prev_edit:Float;
    var index:Int;
}

class EditInfo {

    public var constraint:AbstractConstraint;
    public var edit_plus:SlackVariable;
    public var edit_minus:SlackVariable;
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