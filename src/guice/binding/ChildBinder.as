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

public class ChildBinder extends Binder implements IChildBinder {
	private var parentBinder:IBinder;

	override public function getBinding( typeDefinition:TypeDefinition ):IBinding {
		var binding:IBinding = super.getBinding( typeDefinition );

		//if we do not have a specific binding for it, we need to check to see if our parent injector has a specific AbstractBinding for it before we just go building stuff
		if ( binding == null) {
			binding = parentBinder.getBinding(typeDefinition);
		}

		return binding;
	}

	public function ChildBinder( hashMap:BindingHashMap, factory:TypeDefinitionFactory, classResolver:IClassResolver, parentBinder:IBinder ) {
		super( hashMap, factory, classResolver );
		this.parentBinder = parentBinder;

		//Child binders set themselves up as the new default Binder for the tree below them
		bind(IBinder).toInstance(this);
		bind(Binder).toInstance(this);
	}
}
}