package cassowary;

import cassowary.Variable;
import cassowary.Constraint;

class EditInfo {

    public var constraint:AbstractConstraint;
    public var edit_plus:AbstractVariable;
    public var edit_minus:AbstractVariable;
    public var prev_edit:Float;
    public var index:Int;

    public inline function new(
        c:AbstractConstraint,
        ep:AbstractVariable,
        em:AbstractVariable,
        pe:Float,
        i:Int
    ) {
        constraint = c;
        edit_plus = ep;
        edit_minus = em;
        prev_edit = pe;
        index = i;
    }

    inline function toString() return
        "<cn=" + this.constraint +
           ", ep=" + edit_plus +
           ", em=" + edit_minus +
           ", pec=" + prev_edit +
           ", index=" + index
        + ">";
}