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

	public class Binder {
		private var hashMap:BindingHashMap;

		public function getBinding( typeDefinition:TypeDefinition ):AbstractBinding {
			return hashMap[typeDefinition.getClassName()];
		}
		
		public function addBinding( abstractBinding:AbstractBinding ):void {
			hashMap[abstractBinding.getTypeName()] = abstractBinding;
		}
		
		public function bind( type:Class ):BindingFactory {
			var typeDefinition:TypeDefinition = new TypeDefinition(type);
			var existingBinding:AbstractBinding = getBinding( typeDefinition );
			
			//Do we already have a binding for this type?
			if (existingBinding != null) {
				/** Having a binding is actually not a problem, in most cases we accept that the last configured binding is the appropriate one
				 * However, in the case of a Singleton, this could actually wreak some havoc on the system, especially if this is a child injector situation and we now
				 * have multiple instances of a singleton..... SO, we throw an error if someone attempts to reconfigure a singleton. Incidentally, if you want your 
				 * parent and child injectors to be able to override 'global-ish' singlteon like objects, use the Context scope or make your own object and use the 
				 * instance binding. 
				 **/
				if ( existingBinding.getScope() == Scope.Singleton ) {
					throw new Error("Overriding bindings for Singleton Scoped injections is not allowed.");
				}
			}
			
			return new BindingFactory(this, typeDefinition );
		}

		public function Binder( hashMap:BindingHashMap ) {
			this.hashMap = hashMap;
		}
	}
}