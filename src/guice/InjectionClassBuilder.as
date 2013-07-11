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
package guice {
import guice.reflection.TypeDefinition;
import guice.reflection.TypeDefinitionFactory;
import guice.resolver.CircularDependencyMap;
import guice.resolver.ClassResolver;

public class InjectionClassBuilder {
	private var injector:IInjector;
	private var classResolver:ClassResolver;
	private var factory:TypeDefinitionFactory;

	public function buildContext( className:String ):IGuiceModule {
		var td:TypeDefinition = classResolver.resolveClassName(className, new CircularDependencyMap(), false );

		var classDependencies:Vector.<String> = td.getRuntimeDependencies();

		for ( var i:int=0; i<classDependencies.length; i++) {
			//this will either find the definition or force a proxy to be created for each
			factory.getDefinitionForName( classDependencies[i] );
		}

		return injector.getInstanceByDefinition( td );
	}

	public function buildClass( className:String ):Object {
		var td:TypeDefinition = factory.getDefinitionForName( className );

		return injector.getInstanceByDefinition(  td );
	}

	public function InjectionClassBuilder(injector:IInjector, classResolver:ClassResolver, factory:TypeDefinitionFactory) {
		this.injector = injector;
		this.classResolver = classResolver;
		this.factory = factory;
	}
}
}