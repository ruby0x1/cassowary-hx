package cassowary;

class Error {
    public static var ConstraintNotFound =
        'ConstraintNotFound: Tried to remove a constraint never added to the tableu';
    public static var Internal  =
        'InternalError: An error has occured in Cassowary';
    public static var NonExpression =
        'NonExpression: The resulting expression would be non';
    public static var NotEnoughStays =
        'NotEnoughStays: There are not enough stays to give specific values to every variable';
    public static var RequiredFailure =
        'RequiredFailure: A required constraint cannot be satisfied';
    public static var TooDifficult =
        'TooDifficult: The constraints are too difficult to solve';
}