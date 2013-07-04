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
import guice.binding.IBinder;
import guice.binding.IBinding;
import guice.reflection.TypeDefinition;
import guice.reflection.TypeDefinitionFactory;
import guice.resolver.ClassResolver;

public class ChildInjector extends Injector {
		private var parentInjector:IInjector;

		//Used in a child injector situation to configure a binder with a module at runtime
		internal function configureBinder( module:IGuiceModule ):void {
			if (module != null) {
				module.configure(binder);
			}
		}

	override public function getBinding(typeDefinition:TypeDefinition):IBinding {
		//First we try to resolve it on our own, without own AbstractBinding
		var abstractBinding:IBinding = binder.getBinding(typeDefinition);

		//if we do not have a specific AbstractBinding for it, we need to check to see if our parent injector has a specific AbstractBinding for it before we just go building stuff
		if (abstractBinding == null) {
			abstractBinding = parentInjector.getBinding(typeDefinition);
		}

		return abstractBinding;
	}

	public function ChildInjector(binder:IBinder, classResolver:ClassResolver, factory:TypeDefinitionFactory, parentInjector:IInjector) {
			super(binder, classResolver, factory);
			this.parentInjector = parentInjector;
			
			//Child injectors set themselves up as the new default Injector for the tree below them
			binder.bind(IInjector).toInstance(this);
			binder.bind(Injector).toInstance(this);
		}
	}
}