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
import guice.binding.Binder;
import guice.binding.IBinder;
import guice.binding.utility.BindingHashMap;
import guice.loader.SynchronousClassLoader;
import guice.reflection.TypeDefinitionFactory;
import guice.resolver.ClassResolver;
import guice.resolver.IClassResolver;

public class GuiceJs {
	protected var loader:SynchronousClassLoader;

	public function createInjector( module:IGuiceModule ):IInjector {
		var factory:TypeDefinitionFactory = new TypeDefinitionFactory();
		var hashMap:BindingHashMap = new BindingHashMap();
		var classResolver:IClassResolver = new ClassResolver( loader, factory );
		var binder:Binder = new Binder( hashMap, factory, classResolver );

		if (module != null) {
			module.configure(binder);
		}

		//We need runtime proxies for IInjector, IBinder and IClassResolver as we aren't creating the initial classes through injection
		factory.getDefinitionForName("guice.IInjector");
		factory.getDefinitionForName("guice.binding.IBinder");
		factory.getDefinitionForName("guice.resolver.IClassResolver");

		var injector:IInjector = new Injector(binder, classResolver, factory );
		binder.bind(Injector).toInstance(injector);
		binder.bind(IInjector).toInstance(injector);
		binder.bind(IBinder).to(Binder);
		binder.bind(TypeDefinitionFactory).toInstance(factory);
		binder.bind(IClassResolver).toInstance(classResolver);
		binder.bind(ClassResolver).toInstance(classResolver);
		binder.bind(SynchronousClassLoader).toInstance(loader);

		return injector;
	}

	//This is a little evil and I am not sure I like it, but it is the best way we can provide bindings to a child injector for now.
	public function configureInjector( injector:ChildInjector, module:IGuiceModule ):void {
		injector.configureBinder( module );
	}

	public function GuiceJs( loader:SynchronousClassLoader ) {
		this.loader = loader;
	}
}
}