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
import guice.IInjector;
import guice.binding.provider.IProvider;
import guice.reflection.TypeDefinition;
import guice.resolver.CircularDependencyMap;
import guice.resolver.IClassResolver;

public class ProviderTypeBinding implements IBinding{
	private var typeDefinition:TypeDefinition;
	private var providerTypeDefinition:TypeDefinition;
	private var classResolver:IClassResolver;
	private var isProxiedDefinition:Boolean = false;

	private var provider:IProvider;

	public function getTypeName():String {
		return typeDefinition.getClassName();
	}
	
	public function getScope():int {
		return Scope.Instance;
	}
	
	public function provide(injector:IInjector):* {
		
		if ( provider == null ) {
			//This one is temporary to get us up and going with interfaces... we will deal with it later

			if ( isProxiedDefinition ) {
				this.providerTypeDefinition = classResolver.resolveProxy( this.providerTypeDefinition, new CircularDependencyMap() );
			}

			provider = ( injector.getInstanceByDefinition( providerTypeDefinition ) ) as IProvider;
		}
		
		return provider.get();
	}

	public function ProviderTypeBinding(typeDefinition:TypeDefinition, providerTypeDefinition:TypeDefinition, classResolver:IClassResolver ) {
		this.typeDefinition = typeDefinition;
		this.providerTypeDefinition = providerTypeDefinition;
		this.classResolver = classResolver;

		if ( providerTypeDefinition.isProxy ) {
			isProxiedDefinition = true;
		}
		
	}
}
}