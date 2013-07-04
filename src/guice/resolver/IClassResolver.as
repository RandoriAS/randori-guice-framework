/**
 * Created with IntelliJ IDEA.
 * User: mlabriola
 * Date: 7/1/13
 * Time: 11:16 PM
 * To change this template use File | Settings | File Templates.
 */
package guice.resolver {
import guice.reflection.TypeDefinition;

public interface IClassResolver {
	function resolveProxy(proxy:TypeDefinition, circularDependencyMap:CircularDependencyMap):TypeDefinition;

	function resolveClassName(qualifiedClassName:String, circularDependencyMap:CircularDependencyMap, resolveRuntimeDependencyies:Boolean = true):TypeDefinition;
}
}
