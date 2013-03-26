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
	import guice.binding.utility.BindingHashMap;
	import guice.loader.SynchronousClassLoader;
	import guice.resolver.ClassResolver;
	
	import randori.webkit.xml.XMLHttpRequest;
	
	public class GuiceJs {
		private var dynamicClassBaseUrl:String;
		
		public function createInjector( module:GuiceModule ):Injector {
			var hashMap:BindingHashMap = new BindingHashMap();
			var binder:Binder = new Binder( hashMap );
			var loader:SynchronousClassLoader = new SynchronousClassLoader(new XMLHttpRequest(), dynamicClassBaseUrl );
			var classResolver:ClassResolver = new ClassResolver( loader );
			
			if (module != null) {
				module.configure(binder);
			}
			
			var injector:Injector = new Injector(binder, classResolver);
			binder.bind(Injector).toInstance(injector);
			binder.bind(ClassResolver).toInstance(classResolver);
			binder.bind(SynchronousClassLoader).toInstance(loader);
			
			return injector;
		}		

		//This is a little evil and I am not sure I like it, but it is the best way we can provide bindings to a child injector for now.
		public function configureInjector( injector:ChildInjector, module:GuiceModule ):void {
			injector.configureBinder( module );
		}

		public function GuiceJs( dynamicClassBaseUrl:String = "generated/" ) {
			this.dynamicClassBaseUrl = dynamicClassBaseUrl;
		}
	}
}