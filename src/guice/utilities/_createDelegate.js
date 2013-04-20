if (scope == null || func == null)
    return func;

//dont double wrap
if(func.scope==scope && func.func==func)
    return func;

//create the cache in the scope of the object holding the function to which you are delegating
//this prevents our cache from causing GC issues as everything should be resolvable albeit circular references
var ar = scope.$delegateCache;
if ( !ar ) {
    ar = scope.$delegateCache = [];
} else {
    for ( var i=0; i<ar.length; i++ ) {
        if ( ar[i].func == func ) {
            return ar[i];
        }
    }
}

var delegate = function () {
    return func.apply(scope, arguments);
};

delegate.func = func;
delegate.scope = scope;

ar.push( delegate );

return delegate;
