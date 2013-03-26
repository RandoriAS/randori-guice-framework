if (scope == null || func == null)
    return func;
var delegate = function () {
    return func.apply(scope, arguments);
};
delegate.func = func;
delegate.scope = scope;

return delegate;
