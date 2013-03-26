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
	import guice.resolver.ClassResolver;

	public class InjectionClassBuilder {
		private var injector:Injector;
		private var classResolver:ClassResolver;
		
		public function buildClass( className:String ):Object {
			var type:TypeDefinition = classResolver.resolveClassName(className);
			
			return injector.getInstanceByDefinition(type);
		}

		public function InjectionClassBuilder(injector:Injector, classResolver:ClassResolver) {
			this.injector = injector;
			this.classResolver = classResolver;
		}
	}
}