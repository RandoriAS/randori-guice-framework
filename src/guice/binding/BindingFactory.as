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
import guice.binding.provider.IProvider;
import guice.reflection.TypeDefinition;
import guice.reflection.TypeDefinitionFactory;
import guice.resolver.IClassResolver;

public class BindingFactory {
	private var binder:IBinder;
	private var typeDefinition:TypeDefinition;
	private var scope:int;
	private var factory:TypeDefinitionFactory;
	private var classResolver:IClassResolver;
		
	public function to( dependency:Class ):IBinding {
		var abstractBinding:IBinding = withDecoration( new TypeBinding( typeDefinition, factory.getDefinitionForType( dependency ), classResolver ) );

		binder.addBinding( abstractBinding );
		return abstractBinding;
	}

	public function toInstance( instance:Object ):IBinding {
		//At first it seems silly to have a singleton decorator around an instance, but it affects our rules for overriding in ChildInjectors, so keep it
		var abstractBinding:IBinding = withDecoration( new InstanceBinding( typeDefinition, instance ) );

		binder.addBinding( abstractBinding );
		return abstractBinding;
	}

	public function toProvider( providerType:Class ):IBinding {
		var abstractBinding:IBinding = withDecoration( new ProviderTypeBinding( typeDefinition, factory.getDefinitionForType( providerType ), classResolver ) );
		binder.addBinding( abstractBinding );
		return abstractBinding;
	}

	public function toProviderInstance( provider:IProvider ):IBinding {
		var abstractBinding:IBinding = withDecoration( new ProviderBinding( typeDefinition, provider ) );
		binder.addBinding( abstractBinding );
		return abstractBinding;
	}

	public function inScope( scope:int ):BindingFactory {
		this.scope = scope;
		return this;
	}

	private function withDecoration( abstractBinding:IBinding ):IBinding {
		if (scope == Scope.Context) {
			abstractBinding = new ContextDecorator(abstractBinding);
		} else if (scope == Scope.Singleton ) {
			abstractBinding = new SingletonDecorator(abstractBinding);
		}

		return abstractBinding;
	}

	public function BindingFactory( binder:IBinder, typeDefinition:TypeDefinition, factory:TypeDefinitionFactory, classResolver:IClassResolver ) {
		this.binder = binder;
		this.typeDefinition = typeDefinition;
		this.factory = factory;
		this.classResolver = classResolver;
	}
}
}