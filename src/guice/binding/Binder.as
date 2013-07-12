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
import guice.binding.utility.BindingHashMap;
import guice.reflection.TypeDefinition;
import guice.reflection.TypeDefinitionFactory;
import guice.resolver.IClassResolver;

public class Binder implements IBinder {
	private var hashMap:BindingHashMap;
	private var factory:TypeDefinitionFactory;
	private var classResolver:IClassResolver;

	public function getBinding(typeDefinition:TypeDefinition):IBinding {
		return hashMap[ typeDefinition.getClassName() ];
	}

	public function addBinding(abstractBinding:IBinding):void {
		hashMap[abstractBinding.getTypeName()] = abstractBinding;
	}

	public function destroy():void {
		for each ( var binding:IBinding in  hashMap ) {
			binding.destroy();
		}

		hashMap = null;
	}

	public function unbind(type:Class):void {
		var typeDefinition:TypeDefinition = factory.getDefinitionForType(type);
		var existingBinding:IBinding = getBinding(typeDefinition);

		if ( existingBinding ) {
			delete hashMap[ existingBinding.getTypeName() ];
			existingBinding.destroy();
		}
	}

	public function bind(type:Class):BindingFactory {
		var typeDefinition:TypeDefinition = factory.getDefinitionForType(type);
		var existingBinding:IBinding = getBinding(typeDefinition);

		//Do we already have a binding for this type?
		if (existingBinding != null) {
			/** Having a binding is actually not a problem, in most cases we accept that the last configured binding is the appropriate one
			 * However, in the case of a Singleton, this could actually wreak some havoc on the system, especially if this is a child injector situation and we now
			 * have multiple instances of a singleton..... SO, we throw an error if someone attempts to reconfigure a singleton. Incidentally, if you want your
			 * parent and child injectors to be able to override 'global-ish' singlteon like objects, use the Context scope or make your own object and use the
			 * instance binding.
			 **/
			if (existingBinding.getScope() == Scope.Singleton) {
				throw new Error("Overriding bindings for Singleton Scoped injections is not allowed.");
			}
		}

		return new BindingFactory(this, typeDefinition, factory, classResolver);
	}

	public function Binder( hashMap:BindingHashMap, factory:TypeDefinitionFactory, classResolver:IClassResolver ) {
		this.hashMap = hashMap;
		this.factory = factory;
		this.classResolver = classResolver;
	}
}
}