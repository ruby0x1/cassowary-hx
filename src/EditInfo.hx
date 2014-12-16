
import Variable;

typedef EditInfoArgs = {
    var constraint:Constraint;
    var edit_plus:SlackVariable;
    var edit_minus:SlackVariable;
    var prev_edit:Float;
    var index:Int;
}

class EditInfo {

    var constraint:Constraint;
    var edit_plus:SlackVariable;
    var edit_minus:SlackVariable;
    var prev_edit:Float;
    var index:Int;

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