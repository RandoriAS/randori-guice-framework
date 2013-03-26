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
	import guice.binding.decorator.ContextDecorator;
	import guice.binding.decorator.SingletonDecorator;
	import guice.reflection.TypeDefinition;

	
	public class BindingFactory {
		private var binder:Binder; 
		private var typeDefinition:TypeDefinition;
		private var scope:int;
		
		public function to(dependency:Class):AbstractBinding {
			var abstractBinding:AbstractBinding = withDecoration( new TypeBinding( typeDefinition, new TypeDefinition(dependency) ) );
			
			binder.addBinding(abstractBinding);
			return abstractBinding;
		}
		
		public function toInstance( instance:Object ):AbstractBinding {
			//At first it seems silly to have a singleton decorator around an instance, but it affects our rules for overriding in ChildInjectors, so keep it
			var abstractBinding:AbstractBinding = withDecoration( new InstanceBinding( typeDefinition, instance ) );
			
			binder.addBinding(abstractBinding);
			return abstractBinding;
		}
		
		public function toProvider( providerType:Class ):AbstractBinding {
			var abstractBinding:AbstractBinding = withDecoration( new ProviderBinding(typeDefinition, new TypeDefinition(providerType) ) );
			binder.addBinding(abstractBinding);
			return abstractBinding;
		}
		
		public function inScope( scope:int ):BindingFactory {
			this.scope = scope;
			return this;
		}
		
		private function withDecoration( abstractBinding:AbstractBinding ):AbstractBinding {
			if (scope == Scope.Context) {
				abstractBinding = new ContextDecorator(abstractBinding);
			} else if (scope == Scope.Singleton ) {
				abstractBinding = new SingletonDecorator(abstractBinding);
			}
			
			return abstractBinding;
		}
		
		public function BindingFactory( binder:Binder, typeDefinition:TypeDefinition ) {
			this.binder = binder;
			this.typeDefinition = typeDefinition;			
		}
	}
}