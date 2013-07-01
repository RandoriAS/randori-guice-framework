/***
 * Copyright 2013 LTN Consulting, Inc. /dba Digital Primates®
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * 
 * @author Michael Labriola <labriola@digitalprimates.net>
 */
package guice.resolver {
import guice.loader.SynchronousClassLoader;
import guice.reflection.TypeDefinition;
import guice.reflection.TypeDefinitionFactory;

import randori.webkit.page.Window;

public class ClassResolver {
	private var loader:SynchronousClassLoader;
	private var factory:TypeDefinitionFactory;

	public function resolveProxy( proxy:TypeDefinition, circularDependencyMap:CircularDependencyMap ):TypeDefinition {
		return resolveClassName( proxy.getClassName(), circularDependencyMap, true );
	}

	public function resolveClassName( qualifiedClassName:String, circularDependencyMap:CircularDependencyMap, resolveRuntimeDependencyies:Boolean = true ):TypeDefinition {
		var td:TypeDefinition = factory.getDefinitionForName( qualifiedClassName );

		if ( td.isProxy ) {

			Window.console.log("Resolving Proxy");

			if ( circularDependencyMap[ qualifiedClassName ] ) {
				throw new Error("Circular Reference While Resolving Name : " + qualifiedClassName );
			}

			//Add this to a circular dependency map so we can ensure we don't try to resolve this
			//class again in this stack
			circularDependencyMap[ qualifiedClassName ] = true;

			var classDefinition:String = loader.loadClass(qualifiedClassName);

			//Before we load it into memory, check on the super class and see if we need to load *that*
			//into memory. We may *NOT* have an inherit if we dont inherit from anything, that is just fine
			resolveParentClassFromDefinition(qualifiedClassName,classDefinition, circularDependencyMap);

			//Now, add a stub of the definition into memory. We do this because this 'class' could
			//have static requirements meaning that it could require other loading as it enters memory
			//by creating a stub, we can do deal with that first
			addDefinition( getStubDefinition(qualifiedClassName, classDefinition) );

			//Get a reference to the newly added stub
			td = factory.getDefinitionForName( qualifiedClassName );

			if ( td.builtIn ) {
				throw new Error(qualifiedClassName + " was not built with the Randori compiler or has not been decorated prior to injection ");
			}

			//Resolve any classes it references in its own code execution
			resolveStaticDependencies(td, circularDependencyMap );

			//Remove from the circular dependency map, we are all done dealing with this one
			delete circularDependencyMap[ qualifiedClassName ];

			//Now, Load the WHOLE class into memory... we did this all for statics
			addDefinition(classDefinition);

			//Get a reference to the newly added type
			td = factory.getDefinitionForName( qualifiedClassName );

			if ( resolveRuntimeDependencyies ) {
				resolveRuntimeDependencies( td );
			}
		} else if ( td.pending ) {
			throw new Error("Circular Reference While Resolving Partial Class : " + qualifiedClassName );
		}

		return td;
	}

	private function resolveStaticDependencies(type:TypeDefinition, circularDependencyMap:CircularDependencyMap ):void {
		var classDependencies:Vector.<String> = type.getStaticDependencies();

		for ( var i:int=0; i<classDependencies.length; i++) {
			resolveClassName(classDependencies[i], circularDependencyMap );
		}
	}

	private function resolveRuntimeDependencies(type:TypeDefinition ):void {
		var classDependencies:Vector.<String> = type.getRuntimeDependencies();

		for ( var i:int=0; i<classDependencies.length; i++) {
			//These are runtime dependencies, therefore we should be able to resolve each in its own circular stack
			resolveClassName(classDependencies[i], new CircularDependencyMap() );
		}
	}

	private function getStubDefinition( qualifiedClassName:String, classDefinition:String ):String {
		var stubDefinition:String = "";
		var escapedClassName:String = qualifiedClassName.replace(".", "\." );

		var preambleExpression:String = "(^[\\W\\w]+?)" + escapedClassName;
		var classNameExpression:String = escapedClassName + ".className = [\\w\\W]+?\\\";";
		var dependenciesExpression:String = escapedClassName + ".getClassDependencies[\\w\\W]+?};";

		var preambleResult:Array = classDefinition.match(preambleExpression);
		var classNameResult:Array = classDefinition.match(classNameExpression);
		var dependencyResult:Array = classDefinition.match(dependenciesExpression);

		if (preambleResult != null && preambleResult.length > 1 ) {
			stubDefinition += preambleResult[1];
			stubDefinition += "\n";
		}

		//Add a constructor
		stubDefinition += ( qualifiedClassName + " = function() {}\n" );
		//Add a incomplete flag
		stubDefinition += ( qualifiedClassName + ".pending = true;\n" );

		//Add the classname
		if (classNameResult != null) {
			stubDefinition += classNameResult[0];
			stubDefinition += "\n";
		}

		//Add the dependencies
		if (dependencyResult != null) {
			stubDefinition += dependencyResult[0];
			stubDefinition += "\n";
		}

		return stubDefinition;
	}

	private function resolveParentClassFromDefinition( qualifiedClassName:String, classDefinition:String, circularDependencyMap:CircularDependencyMap ):void {
		//\$inherit\(net.digitalprimates.service.LabelService,([\w\W]*?)\)
		var inheritString:String = "\\$inherit\\(";
		inheritString += qualifiedClassName;
		inheritString += ",\\s*(.*?)\\)";
		var inheritResult:Array = classDefinition.match(inheritString);

		//Do we inherit from anything?
		if (inheritResult != null) {
			//Resolve the parent class first
			resolveClassName(inheritResult[1],circularDependencyMap);
		}
	}

	[JavaScriptCode(file="_addDefinition.js")]
	private function addDefinition( definitionText:String ):void {
	}

	public function ClassResolver( loader:SynchronousClassLoader, factory:TypeDefinitionFactory ) {
		this.loader = loader;
		this.factory = factory;
	}
}
}