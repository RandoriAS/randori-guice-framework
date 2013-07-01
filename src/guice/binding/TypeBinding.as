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
package guice.binding {
import guice.Injector;
import guice.reflection.TypeDefinition;
import guice.resolver.CircularDependencyMap;
import guice.resolver.ClassResolver;

public class TypeBinding extends AbstractBinding {
	private var typeDefinition:TypeDefinition;
	private var dependencyDefinition:TypeDefinition;
	private var classResolver:ClassResolver;
	private var isProxiedDefinition:Boolean = false;
		
	override public function getTypeName():String {
		return typeDefinition.getClassName();
	}

	override public function getScope():int {
		return Scope.Instance;
	}

	override public function provide(injector:Injector):Object {
		//This one is temporary to get us up and going with interfaces... we will deal with it later

		if ( isProxiedDefinition ) {
			this.dependencyDefinition = classResolver.resolveProxy( this.dependencyDefinition, new CircularDependencyMap() );
		}

		return injector.buildClass( dependencyDefinition, new CircularDependencyMap() );
	}

	public function TypeBinding(typeDefinition:TypeDefinition, dependencyDefinition:TypeDefinition, classResolver:ClassResolver ) {
		this.typeDefinition = typeDefinition;
		this.dependencyDefinition = dependencyDefinition;
		this.classResolver = classResolver;

		if ( dependencyDefinition.isProxy ) {
			isProxiedDefinition = true;
		}
	}
}
}